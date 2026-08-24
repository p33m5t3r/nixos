
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
        gaps_in  = 0,
        gaps_out = 12,
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
        rounding       = 0,
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
        enabled = false,
    },
})
