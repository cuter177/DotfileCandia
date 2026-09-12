#!/usr/bin/env python3
"""Emit Waybar JSON for circular volume / brightness / battery rings."""

from __future__ import annotations

import glob
import json
import os
import subprocess
import sys


def round_pct(value: int) -> int:
    value = max(0, min(100, int(value)))
    return int(round(value / 5.0) * 5)


def run(*args: str) -> str:
    return subprocess.check_output(args, text=True, stderr=subprocess.DEVNULL).strip()


def emit(text: str, classes: list[str], tooltip: str, percentage: int) -> None:
    print(
        json.dumps(
            {
                "text": text,
                "class": classes,
                "tooltip": tooltip,
                "percentage": percentage,
            },
            ensure_ascii=False,
        )
    )


def volume() -> None:
    try:
        vol = int(run("pamixer", "--get-volume"))
        muted = run("pamixer", "--get-mute") == "true"
    except (subprocess.CalledProcessError, ValueError, FileNotFoundError):
        vol, muted = 0, True

    classes = [f"p{round_pct(vol)}"]
    if muted:
        classes.append("muted")
        tooltip = f"Volumen {vol}% (silenciado)"
    else:
        tooltip = f"Volumen {vol}%"
    emit(" ", classes, tooltip, vol)


def brightness() -> None:
    val = 0
    try:
        raw = run("brightnessctl", "-m")
        val = int(raw.split(",")[3].replace("%", ""))
    except (subprocess.CalledProcessError, ValueError, IndexError, FileNotFoundError):
        try:
            val = int(float(run("light", "-G")))
        except (subprocess.CalledProcessError, ValueError, FileNotFoundError):
            val = 0

    emit(" ", [f"p{round_pct(val)}"], f"Brillo {val}%", val)


def _sysfs(path: str) -> str:
    with open(path, encoding="utf-8") as fh:
        return fh.read().strip()


def _battery_time(bat: str, status: str) -> str:
    def read_num(*names: str) -> int | None:
        for name in names:
            candidate = os.path.join(bat, name)
            if os.path.exists(candidate):
                try:
                    return int(_sysfs(candidate))
                except ValueError:
                    return None
        return None

    energy_now = read_num("energy_now", "charge_now")
    energy_full = read_num("energy_full", "charge_full")
    power_now = read_num("power_now")
    if power_now is None:
        current = read_num("current_now")
        voltage = read_num("voltage_now")
        if current and voltage:
            power_now = current * voltage // 1_000_000

    if not energy_now or not power_now or power_now <= 0:
        return ""

    if status == "Discharging":
        hours = energy_now / power_now
        label = "restantes"
    elif status == "Charging" and energy_full and energy_full > energy_now:
        hours = (energy_full - energy_now) / power_now
        label = "hasta carga completa"
    else:
        return ""

    hours = max(0.0, hours)
    h = int(hours)
    m = int((hours - h) * 60)
    if h <= 0 and m <= 0:
        return ""
    if h <= 0:
        return f"{m}m {label}"
    return f"{h}h {m:02d}m {label}"


def battery() -> None:
    bats = sorted(glob.glob("/sys/class/power_supply/BAT*"))
    if not bats:
        emit(" ", ["p100", "plugged"], "Sin batería", 100)
        return

    bat = bats[0]
    try:
        cap = int(_sysfs(os.path.join(bat, "capacity")))
    except (OSError, ValueError):
        cap = 0
    try:
        status = _sysfs(os.path.join(bat, "status"))
    except OSError:
        status = "Unknown"

    classes = [f"p{round_pct(cap)}"]
    discharging = status == "Discharging"
    charging = status == "Charging"
    plugged = status in ("Charging", "Full", "Not charging")

    if charging:
        classes.append("charging")
        state = "cargando"
    elif plugged:
        classes.append("plugged")
        state = "conectado"
    else:
        state = "descargando"
        if cap <= 10:
            classes.append("critical")
        elif cap <= 30:
            classes.append("warning")

    tooltip = f"Batería {cap}% ({state})"
    remaining = _battery_time(bat, status)
    if remaining:
        tooltip += f"\n{remaining}"
    if not discharging and not charging and status not in ("Full", "Not charging", "Unknown"):
        tooltip += f"\n{status}"

    emit(" ", classes, tooltip, cap)


def main() -> None:
    kind = sys.argv[1] if len(sys.argv) > 1 else ""
    handlers = {
        "volume": volume,
        "brightness": brightness,
        "battery": battery,
    }
    if kind not in handlers:
        print(
            f"usage: {sys.argv[0]} volume|brightness|battery",
            file=sys.stderr,
        )
        sys.exit(1)
    handlers[kind]()


if __name__ == "__main__":
    main()
