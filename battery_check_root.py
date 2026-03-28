#!/usr/bin/env python3
# battery_check_root.py — esegui come root da systemd (oneshot)
# Funzioni:
# - Legge stato batteria via tlp-stat -b (richiede root su questo sistema)
# - Valuta soglie: WARNING (<75%) e REPLACE (<60% o status critico)
# - Notifica alla sessione utente Wayland tramite systemd-run --user
# - Log minimale su journalctl (prefisso [battery-check])
import subprocess, re, pwd, sys

TLP         = "/usr/bin/tlp-stat"
NOTIFY      = "/usr/bin/notify-send"
SYSTEMD_RUN = "/usr/bin/systemd-run"

# Soglie
WARNING_THRESHOLD = 75.0     # warning informativo
REPLACE_THRESHOLD = 60.0     # "da sostituire"

BAD_STATES = {"replace", "poor", "bad", "dead"}

# ── Icone Freedesktop (Papirus-Dark le riconosce tutte) ──────────────────────
ICON_REPLACE = "battery-caution"
ICON_WARNING = "battery-low"
ICON_ERROR   = "dialog-error"
ICON_OK      = "battery-good"   # non usato, solo per completezza

# ── Helper per barra progresso Unicode ───────────────────────────────────────
def progress_bar(pct: float, width: int = 10) -> str:
    """Restituisce una barra stile: ██████░░░░ 76%"""
    if pct < 0:
        return "─" * width + " N/A"
    filled = round(pct / 100 * width)
    bar    = "█" * filled + "░" * (width - filled)
    return f"{bar} {pct:.1f}%"

# ── Stato batteria → etichetta leggibile ─────────────────────────────────────
STATUS_LABELS = {
    "discharging":  "In scarica",
    "charging":     "In carica",
    "full":         "Carica completa",
    "not charging": "Non in carica",
    "unknown":      "Sconosciuto",
    "replace":      "Da sostituire",
    "poor":         "Scarsa",
    "bad":          "Degradata",
    "dead":         "Esaurita",
}

def fmt_status(s: str) -> str:
    return STATUS_LABELS.get(s.lower(), s.capitalize())

# ─────────────────────────────────────────────────────────────────────────────
def log(msg):
    print(f"[battery-check] {msg}", flush=True)

def get_active_uid():
    try:
        out = subprocess.check_output(
            ["/usr/bin/loginctl", "list-sessions", "--no-legend"], text=True
        )
        for line in out.splitlines():
            parts = line.split()
            if len(parts) >= 5:
                user, state = parts[1], parts[4]
                if state in ("active", "online"):
                    return pwd.getpwnam(user).pw_uid
    except Exception:
        pass
    try:
        out = subprocess.check_output(
            ["/usr/bin/loginctl", "list-users", "--no-legend"], text=True
        )
        return int(out.split()[0])
    except Exception:
        return 1000

def notify_for_uid(uid, title, body, urgency="normal", icon=None, expire_ms=None):
    """
    Invia una notifica all'utente uid.
    - icon:      nome icona freedesktop (es. "battery-caution")
    - expire_ms: durata in ms (0 = permanente; None = usa il default mako)
    - body:      supporta Pango markup (<b>, <i>, <span color="…"> …)
    """
    cmd_base = [
        NOTIFY,
        "--urgency", urgency,
        "--app-name", "battery-check",
        "--category", "device",
    ]
    if icon:
        cmd_base += ["--icon", icon]
    if expire_ms is not None:
        cmd_base += ["--expire-time", str(expire_ms)]
    cmd_base += [title, body]

    env_vars = [
        f"XDG_RUNTIME_DIR=/run/user/{uid}",
        f"DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/{uid}/bus",
    ]

    # Metodo 1: sudo + env + systemd-run --user
    try:
        subprocess.run(
            ["/usr/bin/sudo", "-u", f"#{uid}",
             "/usr/bin/env", "-i", *env_vars,
             SYSTEMD_RUN, "--user", "--collect", "--quiet",
             *cmd_base],
            check=True
        )
        log(f"notify via systemd-run --user uid={uid} urgency={urgency}")
        return True
    except Exception as e:
        log(f"notify via systemd-run failed: {e}")

    # Metodo 2: --machine
    try:
        user_name = pwd.getpwuid(uid).pw_name
        subprocess.run(
            [SYSTEMD_RUN, f"--machine={user_name}@.host",
             "--user", "--collect", "--quiet",
             *cmd_base],
            check=True
        )
        log(f"notify via --machine uid={uid} urgency={urgency}")
        return True
    except Exception as e:
        log(f"notify via --machine failed: {e}")

    # Metodo 3: fallback diretto
    try:
        subprocess.run(
            ["/usr/bin/sudo", "-u", f"#{uid}",
             "/usr/bin/env", "-i", *env_vars,
             *cmd_base],
            check=False
        )
        log(f"notify direct uid={uid} urgency={urgency}")
        return True
    except Exception as e:
        log(f"notify direct failed: {e}")
        return False

def read_tlp():
    return subprocess.check_output([TLP, "-b"], text=True)

def parse_battery(output: str):
    """
    Estrae cicli, capacità e stato dalla output di tlp-stat -b.

    Fix rispetto alla versione precedente:
    - status: la regex ora cattura l'intera stringa fino a '[' o fine riga,
      così "Not charging" non viene troncato a "Not".
    - capacity: invariata, già corretta.
    """
    cycle = re.search(r"cycle_count\s*=\s*(\d+)", output)
    cap   = re.search(r"Capacity\s*=\s*([\d.]+)\s*\[?%", output)

    # FIX: cattura tutto il valore, non solo la prima parola
    stat  = re.search(
        r"/sys/class/power_supply/BAT\d/status\s*=\s*(.+?)(?:\s*\[|$)",
        output,
        re.MULTILINE | re.IGNORECASE,
    )

    cycle_count = cycle.group(1) if cycle else "N/A"
    capacity    = float(cap.group(1)) if cap else -1.0
    status      = stat.group(1).strip().lower() if stat else "unknown"

    return cycle_count, capacity, status

# ── Colori Nord ───────────────────────────────────────────────────────────────
C_ACCENT  = "#3281EA"
C_MUTED   = "#81A1C1"
C_RED     = "#BF616A"
C_FG      = "#D8DEE9"
C_GREEN   = "#A3BE8C"
C_YELLOW  = "#EBCB8B"

def _row(label: str, value: str, color: str = C_MUTED) -> str:
    return (
        f'<span color="{C_FG}"><b>{label}</b></span>  '
        f'<span color="{color}">{value}</span>'
    )

def build_body_replace(capacity: float, cycle_count: str, status: str) -> str:
    bar   = progress_bar(capacity)
    lines = [
        _row("Capacità", bar,              C_RED),
        _row("Cicli",    cycle_count,      C_YELLOW),
        _row("Stato",    fmt_status(status), C_RED),
        "",
        f'<span color="{C_MUTED}"><i>Considera la sostituzione della batteria.</i></span>',
    ]
    return "\n".join(lines)

def build_body_warning(capacity: float, cycle_count: str, status: str) -> str:
    bar   = progress_bar(capacity)
    lines = [
        _row("Capacità", bar,              C_YELLOW),
        _row("Cicli",    cycle_count,      C_MUTED),
        _row("Stato",    fmt_status(status), C_MUTED),
        "",
        f'<span color="{C_MUTED}"><i>Usura elevata rilevata.</i></span>',
    ]
    return "\n".join(lines)

def build_body_error(error: str) -> str:
    return (
        f'<span color="{C_RED}"><b>Impossibile leggere i dati.</b></span>\n'
        f'<span color="{C_MUTED}"><i>{error}</i></span>'
    )

# ─────────────────────────────────────────────────────────────────────────────
def main():
    log("start")
    try:
        output = read_tlp()
    except Exception as e:
        uid = get_active_uid()
        log(f"tlp error: {e}")
        notify_for_uid(
            uid,
            title     = "⚠ Errore monitoraggio batteria",
            body      = build_body_error(str(e)),
            urgency   = "critical",
            icon      = ICON_ERROR,
            expire_ms = 0,
        )
        return 0

    cycle_count, capacity, status = parse_battery(output)
    log(f"parsed cap={capacity} cycles={cycle_count} status={status!r}")

    uid = get_active_uid()

    replace_cond = (capacity >= 0 and capacity < REPLACE_THRESHOLD) or status in BAD_STATES
    warning_cond = (capacity >= 0 and capacity < WARNING_THRESHOLD)

    if replace_cond:
        notify_for_uid(
            uid,
            title     = "🔋 Batteria da sostituire",
            body      = build_body_replace(capacity, cycle_count, status),
            urgency   = "critical",
            icon      = ICON_REPLACE,
            expire_ms = 0,
        )
        log("notification REPLACE sent")
    elif warning_cond:
        notify_for_uid(
            uid,
            title     = "🔋 Batteria: usura elevata",
            body      = build_body_warning(capacity, cycle_count, status),
            urgency   = "normal",
            icon      = ICON_WARNING,
            expire_ms = 12000,
        )
        log("notification WARNING sent")
    else:
        log("no notification needed")

    return 0

if __name__ == "__main__":
    sys.exit(main())
