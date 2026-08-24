
Terminal = "kitty"
Menu = "wofi -s ~/.config/wofi/styles.css --show drun"
Bar = "waybar"

hl.env("XCURSOR_THEME", "Vanilla-DMZ")
hl.env("XCURSOR_SIZE", "24")

local function set_wallpaper()
    local w1 = "~/wallpaper/polyre-left.png"
    local w2 = "~/wallpaper/polyre-right.png"
    hl.exec_cmd(([[
      killall -q swaybg 2>/dev/null;\
      swaybg -o DP-1 -i %s -o HDMI-A-1 -i %s -m fill
    ]]):format(w1,w2))
end

hl.on("config.reloaded", set_wallpaper)
hl.on("hyprland.start", set_wallpaper)
hl.on("hyprland.start", function()
    hl.exec_cmd(Bar)
end)

hl.config({
    general = {
        gaps_in  = 3,
        gaps_out = { top = 2, right = 12, bottom = 12, left = 12 },
        border_size = 1,

        col = {
            active_border   = { colors = { "rgba(b48eadee)", "rgba(81a1c1ee)" }, angle = 45 },
            inactive_border = "rgba(3b4252aa)",
        },

        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 5,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = "rgba(2e3440ee)",
        },

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})

-- Quick, snappy window motion. speed is in deciseconds (lower = faster).
hl.curve("snap", { type = "bezier", points = { { 0.2, 1 }, { 0.25, 1 } } })

hl.animation({ leaf = "global",     enabled = true, speed = 1.8, bezier = "snap" })
hl.animation({ leaf = "windows",    enabled = true, speed = 1.8, bezier = "snap" })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 1.4, bezier = "snap", style = "popin 92%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.1, bezier = "snap", style = "popin 92%" })
hl.animation({ leaf = "border",     enabled = true, speed = 1.4, bezier = "snap" })
hl.animation({ leaf = "fade",       enabled = true, speed = 1.1, bezier = "snap" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.8, bezier = "snap", style = "slide" })

-- Frosted glass behind the bar: waybar draws no background of its own.
hl.layer_rule({
    name  = "waybar-blur",
    match = { namespace = "^waybar$" },
    blur  = true,
})

hl.layer_rule({
    name  = "wofi-blur",
    match = { namespace = "^wofi$" },
    blur  = true,
})
