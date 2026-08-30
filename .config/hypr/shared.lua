
hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",
        follow_mouse = 1,
        sensitivity = -0.5,
        natural_scroll = true,
        touchpad = {
            natural_scroll = true,
        },
    },
})


hl.config({
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        disable_autoreload      = false,
    },
})

hl.config({ xwayland = { force_zero_scaling = true } })
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})


local mainMod = "SUPER"

local hs = require("hyprsplit")
hs.config({ num_workspaces = 10 })

-- name workspaces by their per-monitor index (11 -> "1", 12 -> "2", ...)
for i = 1, 30 do
    hl.workspace_rule({
        workspace    = tostring(i),
        default_name = tostring((i - 1) % 10 + 1),
    })
end

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,           hs.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,   hs.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + g", hs.dsp.grab_rogue_windows())

hl.bind(mainMod .. " + Return",        hl.dsp.exec_cmd(Terminal))
hl.bind(mainMod .. " + SHIFT + q",     hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + e",     hl.dsp.exit())
hl.bind(mainMod .. " + d",             hl.dsp.exec_cmd(Menu))
hl.bind(mainMod .. " + space",         hl.dsp.exec_cmd(Menu))
hl.bind(mainMod .. " + SHIFT + space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + f",             hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + t",             hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + c",         hl.dsp.send_shortcut({ mods = "CTRL",       key = "c" }))
hl.bind(mainMod .. " + v",         hl.dsp.send_shortcut({ mods = "CTRL",       key = "v" }))
hl.bind(mainMod .. " + z",         hl.dsp.send_shortcut({ mods = "CTRL",       key = "z" }))
hl.bind(mainMod .. " + SHIFT + z", hl.dsp.send_shortcut({ mods = "CTRL SHIFT", key = "z" }))
hl.bind(mainMod .. " + SHIFT + c", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mainMod .. " + SHIFT + r", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mainMod .. " + BackSpace", hl.dsp.exec_cmd("swaylock -c 000000"))
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + minus",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + minus", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mainMod .. " + b",             hl.dsp.exec_cmd("pkill -SIGUSR1 -f waybar"))
hl.bind(mainMod .. " + SHIFT + b",     hl.dsp.exec_cmd("pkill -SIGUSR2 -f waybar"))
hl.bind(mainMod .. " + SHIFT + semicolon", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + semicolon",     hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + e",             hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + s",             hl.dsp.window.pseudo()) -- stacking layout equivalent
hl.bind(mainMod .. " + w",             hl.dsp.window.pseudo()) -- tabbed layout equivalent
hl.bind(mainMod .. " + a", hl.dsp.focus({ urgent_or_last = true }))

hl.bind(mainMod .. " + r", hl.dsp.submap("resize"))
hl.define_submap("resize", "reset", function()
    hl.bind("h", hl.dsp.window.resize({ x = -10, y = 0 }))
    hl.bind("j", hl.dsp.window.resize({ x = 0,   y = 10 }))
    hl.bind("k", hl.dsp.window.resize({ x = 0,   y = -10 }))
    hl.bind("l", hl.dsp.window.resize({ x = 10,  y = 0 }))
    hl.bind("escape",          hl.dsp.submap("reset"))
    hl.bind("return",          hl.dsp.submap("reset"))
    hl.bind(mainMod .. " + r", hl.dsp.submap("reset"))
end)

hl.bind(
  "XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"),
  { locked = true, repeating = true }
)
hl.bind(
  "XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"),
  { locked = true, repeating = true }
)
hl.bind(
  "XF86AudioMute", hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"),
  { locked = true, repeating = true }
)
hl.bind(
  "XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
  { locked = true, repeating = true }
)
hl.bind(
  "XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),
  { locked = true, repeating = true }
)
hl.bind(
  "XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),
  { locked = true, repeating = true }
)

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
