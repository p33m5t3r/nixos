require("monitor")

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
