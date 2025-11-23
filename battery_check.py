#!/usr/bin/env python3
import subprocess, re, sys

def run(cmd):
    return subprocess.check_output(cmd, text=True, stderr=subprocess.DEVNULL)

try:
    output = run(["tlp-stat", "-b"])
except Exception as e:
    # Notifica errore esecuzione
    subprocess.run(["notify-send", "-u", "critical", "Batteria", f"Errore tlp-stat: {e}"])
    sys.exit(1)

cycle = re.search(r"cycle_count\s*=\s*(\d+)", output)
cap   = re.search(r"Capacity\s*=\s*([\d.]+)\s*\[?%", output)
stat  = re.search(r"status\s*=\s*(\w+)", output)

cycle_count = cycle.group(1) if cycle else "N/A"
capacity    = float(cap.group(1)) if cap else -1.0
status      = stat.group(1).lower() if stat else "unknown"

print(f"Cycle count: {cycle_count}")
print(f"Capacity: {capacity if capacity>=0 else 'N/A'}")
print(f"Status: {status}")

# Criteri “da sostituire”: capacità < 80% o status in {replace, poor, bad}
needs_replace = (capacity >= 0 and capacity < 80.0) or status in {"replace", "poor", "bad", "dead"}

if needs_replace:
    body = f"Capacità: {capacity:.1f}% | Cicli: {cycle_count} | Stato: {status}"
    subprocess.run(["notify-send", "-u", "critical", "-a", "Battery Check", "Batteria da sostituire", body])

