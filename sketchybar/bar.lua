local colors = require("colors").sections.bar

-- Equivalent to the --bar domain
sbar.bar {
  topmost = "window",
  height = 35,
  color = colors.bg,
  padding_right = 4,
  padding_left = 4,
  margin = 4,
  corner_radius = 12,
  y_offset = 4,
  border_color = colors.border,
  border_width = 0,
  blur_radius = 40,
}
