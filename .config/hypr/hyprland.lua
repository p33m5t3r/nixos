local themes = {
    default = true,
    nina    = true,
}

local theme = os.getenv("THEME")
if not themes[theme] then
    theme = "default"
end

require("theme-" .. theme)
hl.env("THEME", theme)

require("shared")

-- per-machine bits (monitors, side wallpaper outputs, input tweaks)
local f = io.open("/etc/hostname")
local host = f and f:read("l") or ""
if f then f:close() end
if io.open(os.getenv("HOME") .. "/.config/hypr/host-" .. host .. ".lua") then
    require("host-" .. host)
end
