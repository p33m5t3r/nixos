
-- main monitor
hl.monitor({
  output = "DP-1",
  mode = "3840x2160@120",
  position = "1440x900",
  scale = 1.5
})

-- side monitor
hl.monitor({
  output = "HDMI-A-1",
  mode = "2560x1440@60",
  position = "4000x100",
  scale = 1.0,
  transform = 3
})

-- tv
-- hl.monitor({
--   output = "DP-2",
--   mode = "1920x1080@60",
--   position = "-480x0",
--   scale = 1.0
-- })

-- others
hl.monitor({ output = "", disabled = true })

