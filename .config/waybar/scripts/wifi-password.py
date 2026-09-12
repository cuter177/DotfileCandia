#!/usr/bin/env python3
"""Ask for a Wi-Fi password with a show/hide toggle. Prints the password to stdout."""

from __future__ import annotations

import sys

try:
    import gi

    gi.require_version("Gtk", "3.0")
    from gi.repository import Gdk, GLib, Gtk
except (ImportError, ValueError):
    sys.exit(2)

SSID = sys.argv[1] if len(sys.argv) > 1 else ""

CSS = b"""
window {
    background-color: rgba(18, 18, 18, 0.94);
    border-radius: 16px;
    border: 1px solid rgba(131, 102, 103, 0.55);
    font-family: "JetBrainsMono Nerd Font", "Inter", sans-serif;
}

label.title {
    color: #c0caf5;
    font-weight: 600;
    font-size: 13px;
}

entry {
    background: rgba(255, 255, 255, 0.08);
    color: #ffffff;
    border-radius: 8px;
    border: 1px solid rgba(255, 255, 255, 0.08);
    padding: 8px 10px;
    min-height: 28px;
}

entry:focus {
    border: 1px solid #836667;
}

button {
    border-radius: 8px;
    border: none;
    padding: 6px 14px;
    min-height: 28px;
    font-weight: 500;
}

button.eye {
    background: rgba(255, 255, 255, 0.08);
    color: #c0caf5;
    padding: 4px 8px;
}

button.eye:hover {
    background: rgba(255, 255, 255, 0.14);
}

button.cancel {
    background: rgba(255, 255, 255, 0.08);
    color: #c0caf5;
}

button.cancel:hover {
    background: rgba(255, 255, 255, 0.14);
}

button.connect {
    background: #836667;
    color: #ffffff;
}

button.connect:hover {
    background: #6f5657;
}
"""


class PasswordDialog(Gtk.Window):
    def __init__(self) -> None:
        super().__init__(title="wifi-password")
        GLib.set_prgname("wifi-password")
        self.set_name("wifi-password")
        self.set_decorated(False)
        self.set_resizable(False)
        self.set_keep_above(True)
        self.set_skip_taskbar_hint(True)
        self.set_type_hint(Gdk.WindowTypeHint.DIALOG)
        self.set_default_size(400, 180)
        # Let Hyprland window rules place this; CENTER fights `move`.
        self.password: str | None = None

        provider = Gtk.CssProvider()
        provider.load_from_data(CSS)
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION,
        )

        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        box.set_margin_top(20)
        box.set_margin_bottom(16)
        box.set_margin_start(20)
        box.set_margin_end(20)

        title = Gtk.Label(label=f"Contraseña para {SSID}", xalign=0)
        title.get_style_context().add_class("title")
        title.set_line_wrap(True)

        entry_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        self.entry = Gtk.Entry()
        self.entry.set_visibility(False)
        self.entry.set_invisible_char("•")
        self.entry.set_placeholder_text("Contraseña")
        self.entry.set_hexpand(True)
        self.entry.connect("activate", self.on_connect)

        self.eye = Gtk.Button()
        self.eye.set_relief(Gtk.ReliefStyle.NONE)
        self.eye.get_style_context().add_class("eye")
        self.eye_icon = Gtk.Image.new_from_icon_name(
            "view-reveal-symbolic", Gtk.IconSize.BUTTON
        )
        self.eye.add(self.eye_icon)
        self.eye.set_tooltip_text("Mostrar contraseña")
        self.eye.connect("clicked", self.toggle_visibility)

        entry_row.pack_start(self.entry, True, True, 0)
        entry_row.pack_start(self.eye, False, False, 0)

        buttons = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        buttons.set_halign(Gtk.Align.END)

        cancel = Gtk.Button(label="Cancelar")
        cancel.get_style_context().add_class("cancel")
        cancel.connect("clicked", lambda *_: self.close_cancel())

        connect = Gtk.Button(label="Conectar")
        connect.get_style_context().add_class("connect")
        connect.connect("clicked", self.on_connect)

        buttons.pack_start(cancel, False, False, 0)
        buttons.pack_start(connect, False, False, 0)

        box.pack_start(title, False, False, 0)
        box.pack_start(entry_row, False, False, 0)
        box.pack_start(buttons, False, False, 0)
        self.add(box)

        self.connect("key-press-event", self.on_key)
        self.connect("destroy", self.on_destroy)

    def toggle_visibility(self, *_args) -> None:
        visible = not self.entry.get_visibility()
        self.entry.set_visibility(visible)
        if visible:
            self.eye_icon.set_from_icon_name(
                "view-conceal-symbolic", Gtk.IconSize.BUTTON
            )
            self.eye.set_tooltip_text("Ocultar contraseña")
        else:
            self.eye_icon.set_from_icon_name(
                "view-reveal-symbolic", Gtk.IconSize.BUTTON
            )
            self.eye.set_tooltip_text("Mostrar contraseña")

    def on_key(self, _widget, event) -> bool:
        if event.keyval == Gdk.KEY_Escape:
            self.close_cancel()
            return True
        return False

    def on_connect(self, *_args) -> None:
        text = self.entry.get_text()
        if not text:
            return
        self.password = text
        Gtk.main_quit()

    def close_cancel(self) -> None:
        self.password = None
        Gtk.main_quit()

    def on_destroy(self, *_args) -> None:
        Gtk.main_quit()


def main() -> int:
    win = PasswordDialog()
    win.show_all()
    win.present()
    win.entry.grab_focus()
    Gtk.main()
    if not win.password:
        return 1
    print(win.password)
    return 0


if __name__ == "__main__":
    sys.exit(main())
