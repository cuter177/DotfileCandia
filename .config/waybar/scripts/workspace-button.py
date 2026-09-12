#!/usr/bin/env python3
"""Waybar workspace button for Hyprland 0.56+ (Lua dispatch)."""

from __future__ import annotations

import json
import os
import re
import socket
import subprocess
import sys
from pathlib import Path

WS_ID = int(sys.argv[1])


def define_color(name: str, fallback: str) -> str:
    css = Path(__file__).resolve().parent.parent / "colors.css"
    try:
        match = re.search(
            rf"@define-color\s+{re.escape(name)}\s+(\S+)\s*;",
            css.read_text(),
        )
    except OSError:
        return fallback
    return match.group(1) if match else fallback


MAGENTA = define_color("magenta", "#bb9af7")
BLUE = define_color("blue", "#7aa2f7")
ORANGE = define_color("orange", "#e0af68")

ICONS = {
    "active": f"<span font='11' color='{ORANGE}'>󰮯</span>",
    "empty": f"<span font='10'><span font='7' color='{MAGENTA}'></span></span>",
    "persistent": f"<span font='10' color='{BLUE}'>󰊠</span>",
}

INTERESTING = (
    "workspace",
    "focusedmon",
    "createworkspace",
    "destroyworkspace",
    "openwindow",
    "closewindow",
    "movewindow",
)


def hyprctl_json(command: str):
    out = subprocess.check_output(["hyprctl", "-j", command], text=True)
    return json.loads(out)


def emit() -> None:
    active = hyprctl_json("activeworkspace")["id"]
    windows = 0
    for workspace in hyprctl_json("workspaces"):
        if workspace["id"] == WS_ID:
            windows = int(workspace.get("windows") or 0)
            break

    if active == WS_ID:
        state = "active"
    elif windows > 0:
        state = "persistent"
    else:
        state = "empty"

    print(
        json.dumps(
            {
                "text": ICONS[state],
                "class": ["ws-btn", state],
                "tooltip": f"Workspace {WS_ID}",
            },
            ensure_ascii=False,
        ),
        flush=True,
    )


def socket_path() -> str:
    runtime = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
    signature = os.environ["HYPRLAND_INSTANCE_SIGNATURE"]
    return f"{runtime}/hypr/{signature}/.socket2.sock"


def listen() -> None:
    emit()
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.connect(socket_path())
    buf = b""
    while True:
        data = sock.recv(4096)
        if not data:
            break
        buf += data
        while b"\n" in buf:
            line, buf = buf.split(b"\n", 1)
            event = line.split(b">>", 1)[0].decode("utf-8", "replace")
            if event.startswith(INTERESTING):
                emit()


if __name__ == "__main__":
    try:
        listen()
    except (BrokenPipeError, KeyboardInterrupt):
        pass
    except Exception:
        emit()
        while True:
            try:
                import time

                time.sleep(0.5)
                emit()
            except (BrokenPipeError, KeyboardInterrupt):
                break
