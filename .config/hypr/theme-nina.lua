
-- nina — paper, ink, and one electric blue.
--
-- A theme is this file plus a directory of assets at ~/.config/themes/<name>/.
-- hyprland.lua loads whichever one $THEME names, so this is reached by starting
-- the compositor as `THEME=nina Hyprland`. Everything below is either a command
-- another program is launched with, an environment variable that program reads
-- its own theme from, or hyprland's own look.
--
-- How each program is reached:
--   kitty   $KITTY_CONFIG_DIRECTORY — replaces the config dir wholesale, so it
--           themes every kitty, not just the ones bound to a key
--   waybar  -c / -s flags, via Bar
--   wofi    -c / -s flags, via Menu
--   nvim    $THEME, switched on in ~/.config/nvim/init.lua
--   tmux    $THEME, switched on in ~/.tmux.conf
--
-- Colours live in ~/.config/themes/nina/palette. The ones repeated here are
-- hyprland's own chrome: window borders and nothing else.

local home  = os.getenv("HOME")
local theme = home .. "/.config/themes/nina"

Terminal = "kitty"
Menu = ("wofi -c %s/wofi.conf -s %s/wofi.css --show drun"):format(theme, theme)
Bar  = ("waybar -c %s/waybar.jsonc -s %s/waybar.css"):format(theme, theme)

-- $THEME itself is exported by hyprland.lua, for every theme
hl.env("KITTY_CONFIG_DIRECTORY", theme)

-- wofi is a GTK app; its CSS handles the launcher itself, but this keeps every
-- other GTK dialog on the same side of light/dark
hl.env("GTK_THEME", "Adwaita")

hl.env("XCURSOR_THEME", "Vanilla-DMZ")
hl.env("XCURSOR_SIZE", "24")

-- flat cool paper with a faint blue grid — regenerate with themes/nina/wallpaper.sh
--
-- Only starts swaybg if it isn't already up; this fires on reload as well as at
-- startup, and within a theme the wallpaper never changes, so the reload case
-- exists only to bring it back if it died.
--
-- The match is deliberately not `pgrep -x swaybg`: on nixos swaybg is a wrapped
-- binary whose comm is ".swaybg-wrapped", so an exact match never hits and every
-- reload would leave another copy behind. (`killall swaybg`, the obvious way to
-- write this, is broken for exactly that reason.) A loose comm match catches the
-- wrapper, and unlike `pgrep -f swaybg` it won't match this guard's own shell.
--
-- After regenerating the PNGs, `pkill swaybg` and reload to pick them up.
local function set_wallpaper()
    local w1 = home .. "/wallpaper/nina-main.png"
    local w2 = home .. "/wallpaper/nina-side.png"
    hl.exec_cmd(([[
      pgrep swaybg >/dev/null || swaybg -o DP-1 -i %s -o HDMI-A-1 -i %s -m fill
    ]]):format(w1, w2))
end

hl.on("config.reloaded", set_wallpaper)
hl.on("hyprland.start", set_wallpaper)
hl.on("hyprland.start", function()
    hl.exec_cmd(Bar)
end)

hl.config({
    general = {
        gaps_in  = 6,
        gaps_out = { top = 2, right = 12, bottom = 12, left = 12 },
        border_size = 2,

        col = {
            -- flat accent, no gradient: nothing else in this theme is a ramp
            active_border   = "rgb(2b2bd8)",
            inactive_border = "rgba(14140f40)",
        },

        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        -- the whole point of nina: no radius anywhere
        rounding       = 0,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        -- a shadow on a paper background reads as grime; the border does the
        -- separating instead
        shadow = {
            enabled = false,
        },

        -- kept only for the bar and the launcher, which sit at 0.94/0.96 alpha
        blur = {
            enabled  = true,
            size     = 4,
            passes   = 2,
            vibrancy = 0.0,
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
