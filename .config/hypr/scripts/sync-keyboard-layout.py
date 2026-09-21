#!/usr/bin/env python3
"""Keep every keyboard on the same XKB layout and refresh the waybar indicator.

Hyprland tracks the layout state per keyboard, so toggling with grp:alt_shift_toggle
only affects the keyboard you are typing on. This daemon listens to the
`activelayout` IPC event and applies the new layout to all keyboards, then signals
waybar so the indicator stays in sync.
"""
import json
import os
import socket
import subprocess
import sys
import time

SIGNATURE = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
RUNTIME = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
SOCKET_PATH = os.path.join(RUNTIME, "hypr", SIGNATURE or "", ".socket2.sock")


def hyprctl_json(*args):
    out = subprocess.run(["hyprctl", "-j", *args], capture_output=True, text=True)
    return json.loads(out.stdout or "{}")


def set_all(idx):
    subprocess.run(["hyprctl", "switchxkblayout", "all", str(idx)], capture_output=True)
    subprocess.run(["pkill", "-RTMIN+3", "waybar"], capture_output=True)


def current_index(device):
    for kb in hyprctl_json("devices").get("keyboards", []):
        if kb["name"] == device:
            return kb["active_layout_index"]
    return None


def initial_index():
    keyboards = hyprctl_json("devices").get("keyboards", [])
    for kb in keyboards:
        if kb.get("main"):
            return kb["active_layout_index"]
    return keyboards[0]["active_layout_index"] if keyboards else None


def main():
    if not SIGNATURE:
        print("HYPRLAND_INSTANCE_SIGNATURE not set", file=sys.stderr)
        return 1

    last = initial_index()
    if last is not None:
        set_all(last)

    while True:
        try:
            with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as sock:
                sock.connect(SOCKET_PATH)
                buf = b""
                while True:
                    data = sock.recv(4096)
                    if not data:
                        break
                    buf += data
                    while b"\n" in buf:
                        raw, buf = buf.split(b"\n", 1)
                        line = raw.decode(errors="replace")
                        if not line.startswith("activelayout>>"):
                            continue
                        device = line[len("activelayout>>"):].split(",", 1)[0]
                        idx = current_index(device)
                        if idx is None or idx == last:
                            continue
                        last = idx
                        set_all(idx)
        except (ConnectionError, FileNotFoundError, OSError):
            pass
        time.sleep(2)


if __name__ == "__main__":
    sys.exit(main())
