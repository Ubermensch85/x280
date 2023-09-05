#!/usr/bin/python3

import subprocess
import re

# Esegui tlp-stat -b e cattura l'output
output = subprocess.check_output(["sudo", "tlp-stat", "-b"], text=True)

# Cerca le informazioni desiderate utilizzando espressioni regolari
cycle_count_match = re.search(r"cycle_count\s*=\s*(\d+)", output)
capacity_match = re.search(r"Capacity\s*=\s*([\d.]+)\s*\[?%", output)
status_match = re.search(r"status\s*=\s*(\w+)", output)

# Estrai le informazioni corrispondenti alle espressioni regolari
cycle_count = cycle_count_match.group(1) if cycle_count_match else "N/A"
capacity = capacity_match.group(1) if capacity_match else "N/A"
status = status_match.group(1) if status_match else "N/A"

# Stampa le informazioni
print("Cycle count:", cycle_count)
print("Capacity:", capacity)
print("Status:", status)
