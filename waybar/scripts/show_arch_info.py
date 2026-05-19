#!/usr/bin/env python3
import os, subprocess, sys, tty, termios, shutil, re

# ─── UTILITY ──────────────────────────────────────────────────────────────────

def getch():
    fd = sys.stdin.fileno()
    old = termios.tcgetattr(fd)
    try:
        tty.setraw(fd)
        ch = sys.stdin.read(1)
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old)
    return ch

def cols():
    return shutil.get_terminal_size((80, 24)).columns

ANSI = re.compile(r'\033\[[0-9;]*m')
def vlen(s):
    return len(ANSI.sub('', s))

# ─── SYSTEM INFO ──────────────────────────────────────────────────────────────

def get_sys_info():
    try:
        ip = subprocess.check_output(
            "ip -4 a show wlan0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1",
            shell=True).decode().strip() or "Offline"
    except:
        ip = "Offline"
    try:
        boot = subprocess.check_output(
            "systemd-analyze | awk -F'=' '{print $2}' | awk '{print $1}'",
            shell=True).decode().strip()
    except:
        boot = "N/A"
    return f"\n\033[1;36m Boot:\033[0m {boot}s  |  \033[1;32m IP:\033[0m {ip}"

# ─── KEYBINDINGS (dalla tua config reale) ─────────────────────────────────────

BINDS = {
    "  APP": [
        ("SUPER + RETURN",      "Kitty  (terminale)"),
        ("SUPER + B",           "Firefox Developer Edition"),
        ("SUPER + C",           "Brave Browser"),
        ("SUPER + D",           "Wofi  (launcher)"),
        ("SUPER + N",           "Nemo  (file manager)"),
        ("SUPER + M",           "Nota  (script Alacritty)"),
        ("SUPER + SHIFT + A",   "Ghostwriter  (markdown editor)"),
        ("F9",                  "Nano → hyprland.conf"),
    ],
    "  SISTEMA & ENERGIA": [
        ("SUPER + Q",           "Chiudi finestra attiva"),
        ("SUPER + E",           "Esci da Hyprland"),
        ("SUPER + ESC",         "Reboot"),
        ("SUPER + DELETE",      "Poweroff"),
        ("SUPER + R",           "Ricarica config Hyprland"),
        ("SUPER + I",           "Controlla batteria"),
        ("SUPER + F10",         "Toggle Bluetooth"),
        ("SUPER + F11",         "DPMS off  (spegni schermo)"),
        ("SUPER + F12",         "DPMS on   (accendi schermo)"),
        ("F8",                  "Toggle WiFi"),
    ],
    "  FINESTRE": [
        ("SUPER + F",           "Fullscreen"),
        ("SUPER + O",           "Toggle Float"),
        ("SUPER + P",           "Pseudo Tiling"),
        ("SUPER + W",           "Toggle display"),
        ("SUPER + A",           "Toggle Waybar"),
        ("SUPER + S",           "Screensaver  (hyprdvd)"),
        ("SUPER + PRINT",       "Screenshot area  (grimblast)"),
        ("SUPER + SHIFT + S",   "Sposta → special:magic"),
    ],
    "  FOCUS & MOUSE": [
        ("SUPER + H / L",       "Focus ←  /  →"),
        ("SUPER + K / J",       "Focus ↑  /  ↓"),
        ("SUPER + frecce",      "Focus con frecce"),
        ("SUPER + LMB drag",    "Trascina finestra"),
        ("SUPER + RMB drag",    "Ridimensiona finestra"),
        ("SUPER + scroll",      "Workspace ±1"),
    ],
    "  WORKSPACE": [
        ("SUPER + 1-9 / 0",     "Vai al workspace 1-10"),
        ("SUPER + SHIFT + 1-9", "Sposta finestra → WS N"),
    ],
    "  AUDIO": [
        ("F1  / XF86Mute",      "Mute audio"),
        ("F2  / XF86VolDown",   "Volume giù"),
        ("F3  / XF86VolUp",     "Volume su"),
        ("F4",                  "Toggle microfono"),
    ],
    "  LUMINOSITÀ": [
        ("F5  / XF86BrightDown","Luminosità giù"),
        ("F6  / XF86BrightUp",  "Luminosità su"),
    ],
}

# ─── HELP VIEW ────────────────────────────────────────────────────────────────

def render_section(name, binds):
    lines = []
    lines.append(f"\033[1;4;37m{name}\033[0m")
    for key, desc in binds:
        pad = max(1, 26 - len(key))
        lines.append(f"  \033[1;33m{key}\033[0m{' ' * pad}\033[36m{desc}\033[0m")
    lines.append("")
    return lines

def show_help():
    while True:
        os.system('clear')
        w = cols()

        title = " HYPRLAND KEYBINDINGS "
        print(f"\033[1;35m{'═' * w}\033[0m")
        print(f"\033[1;35m{title.center(w)}\033[0m")
        print(f"\033[1;35m{'═' * w}\033[0m")

        sections = list(BINDS.items())
        use_two_cols = w >= 100

        if use_two_cols:
            mid = (len(sections) + 1) // 2
            left_secs  = sections[:mid]
            right_secs = sections[mid:]
            col_w = (w - 4) // 2

            left_lines  = []
            for name, binds in left_secs:
                left_lines.extend(render_section(name, binds))
            right_lines = []
            for name, binds in right_secs:
                right_lines.extend(render_section(name, binds))

            max_rows = max(len(left_lines), len(right_lines))
            left_lines  += [""] * (max_rows - len(left_lines))
            right_lines += [""] * (max_rows - len(right_lines))

            sep = "\033[90m│\033[0m"
            for l, r in zip(left_lines, right_lines):
                pad = max(0, col_w - vlen(l) + 1)
                print(f" {l}{' ' * pad}{sep} {r}")
        else:
            for name, binds in sections:
                for line in render_section(name, binds):
                    print(line)

        print(f"\033[1;35m{'═' * w}\033[0m")
        print("\033[90m  [q] torna  •  ridimensiona la finestra per layout 2 colonne (≥100 col)\033[0m")

        ch = getch().lower()
        if ch in ('q', '\x03', '\r', '\n', 'h'):
            break

# ─── MAIN LOOP ────────────────────────────────────────────────────────────────

def main_loop():
    while True:
        os.system('clear')
        logo_w = max(20, min(38, cols() // 3))
        subprocess.run([
            "fastfetch",
            "--logo-type", "kitty",
            "--logo-width", str(logo_w),
            "--logo-height", "15",
            "--logo-preserve-aspect-ratio", "true",
        ])
        print(get_sys_info())
        print("\n\033[1;33m[q]\033[0m Esci  |  \033[1;32m[h]\033[0m Keybindings")

        ch = getch().lower()
        if ch in ('q', '\x03'):
            os.system('clear')
            break
        elif ch == 'h':
            show_help()

# ─── ENTRY POINT ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    if os.environ.get("TERM") != "xterm-kitty":
        subprocess.run(['kitty', '--class', 'floating_term', '--title', 'Arch Info',
                        'python3', __file__])
    else:
        main_loop()
