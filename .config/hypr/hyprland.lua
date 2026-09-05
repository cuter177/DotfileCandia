-- Converted from hyprland.conf. Backup: hyprland.conf.bak
-- https://wiki.hypr.land/Configuring/Start/

require("waydroid-mode")

----------------
---- MONITORS ----
----------------

hl.monitor({
    output = "DP-1",
    mode = "1920x1080@144",
    position = "0x0",
    scale = 1,
})

-------------------
---- MY PROGRAMS ----
-------------------

local terminal = "kitty"
local fileManager = "dolphin"
local menu = "wofi -show drun"
local browser = "~/.tarball-installations/zen/zen"
local mail = "thunderbird"
local music = "flatpak run com.spotify.Client --force-device-scale-factor=0.9"

-----------------
---- AUTOSTART ----
-----------------

hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    -- hl.exec_cmd("xdg-desktop-portal-hyprland")
    hl.exec_cmd("swww-daemon")
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 12")
    hl.exec_cmd("sleep 2 && waybar")
    hl.exec_cmd("sleep 6 && ~/.config/waybar/scripts/monitorea-fondo.sh")
    hl.exec_cmd("mako")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")

hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "0")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
-- hl.env("LIBVA_DRIVER_NAME", "nvidia")
-- hl.env("GMB_BACKEND", "nvidia-drm")
hl.env("XDG_SESSION_TYPE", "wayland")
-- hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("WLR_NO_HARDWARE_CURSORS", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("MOZ_ENABLE_WAYLAND", "1")

-----------------------
----- PERMISSIONS -----
-----------------------

-- hl.config({
--     ecosystem = {
--         enforce_permissions = true,
--     },
-- })

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in = 0,
        gaps_out = 0,
        border_size = 0,

        col = {
            active_border = { colors = { "rgba(bb9af7ff)", "rgba(724aaaff)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },

        -- last value from the original conf (false then true)
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },

    decoration = {
        rounding = 10,
        rounding_power = 2,

        active_opacity = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled = true,
            range = 50,
            render_power = 9,
            color = "rgba(0,0,0,0.6)",
        },

        blur = {
            enabled = false,
            size = 8,
            passes = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "easeOutQuint", style = "slidefade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 2.5, bezier = "easeOutQuint", style = "slidefade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 2.5, bezier = "easeOutQuint", style = "slidefade" })

-- Smart gaps / no gaps when only (commented in the original)
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({
--     name = "no-gaps-wtv1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding = 0,
-- })
-- hl.window_rule({
--     name = "no-gaps-f1",
--     match = { float = false, workspace = "f[1]" },
--     border_size = 0,
--     rounding = 0,
-- })

hl.config({
    dwindle = {
        preserve_split = true,
    },
    master = {
        new_status = "master",
    },
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo = false,
    },
})

---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout = "us,latam",
        kb_variant = "",
        kb_model = "",
        kb_options = "grp:alt_shift_toggle",
        kb_rules = "",

        follow_mouse = 1,
        sensitivity = 0.0,
        accel_profile = "pointer",
        numlock_by_default = true,

        touchpad = {
            disable_while_typing = false,
            natural_scroll = true,
            scroll_factor = 0.15,
            tap_and_drag = true,
        },
    },

    xwayland = {
        force_zero_scaling = true,
    },
})

hl.device({
    name = "logitech-g203-lightsync-gaming-mouse",
    sensitivity = -0.6,
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + slash", hl.dsp.exec_cmd(music))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(mail))

-- Move focus with mainMod + WASD
hl.bind(mainMod .. " + A", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + D", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + W", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + S", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + left", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ workspace = "e+1" }))

-- Same key as movefocus down in the original conf (SUPER + S)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(mainMod .. " + TAB", hl.dsp.exec_cmd([[bash -c 'mkdir -p ~/screen && n=$(ls ~/screen/*.png 2>/dev/null | xargs -I{} basename {} .png | grep -E "^[0-9]+$" | sort -n | tail -1) && grim -g "$(slurp)" ~/screen/$((${n:-0}+1)).png']]))

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.bind(mainMod .. " + I", hl.dsp.window.fullscreen({ mode = "maximized" }))

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.window_rule({
    name = "xwayland-no-initial-focus",
    match = { xwayland = true },
    no_initial_focus = true,
})

hl.window_rule({
    name = "float-calendar",
    match = { title = "float-calendar" },
    float = true,
    move = { 1020, 30 },
    border_size = 0,
})

hl.window_rule({
    name = "float-volume",
    match = { title = "float-volume" },
    float = true,
    move = { 990, 30 },
    border_size = 0,
})

hl.window_rule({
    name = "float-brightness",
    match = { title = "float-brightness" },
    float = true,
    move = { 920, 30 },
    border_size = 0,
})

hl.window_rule({
    name = "wifi-popup",
    match = { title = "networkmanager_dmenu" },
    float = true,
    move = { 1500, 40 },
    size = { 420, 500 },
})

hl.window_rule({
    name = "yad_wifi",
    match = { title = "yad_wifi" },
    float = true,
    move = { 900, 45 },
    size = { 380, 130 },
    border_size = 0,
})
