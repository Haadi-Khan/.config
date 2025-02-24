local M = {}

local with_alpha = function(color, alpha)
  if alpha > 1.0 or alpha < 0.0 then
    return color
  end
  return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
end

local transparent = 0x00000000

local one_dark = {
  base = 0xff282c34,
  surface = 0xff353b45,
  overlay = 0xff3e4451,
  muted = 0xff565c64,
  subtle = 0xff828997,
  text = 0xffabb2bf,
  red = 0xffe06c75,
  orange = 0xffd19a66,
  yellow = 0xffe5c07b,
  purple = 0xffc678dd,
  blue = 0xff61afef,
  green = 0xff98c379,
  highlight_low = 0xff2c323c,
  highlight_med = 0xff3e4451,
}


M.sections = {
  bar = {
    bg = one_dark.base,
    border = transparent,
  },
  item = {
    bg = one_dark.overlay,
    border = one_dark.highlight_low,
    text = one_dark.text,
  },
  apple = one_dark.blue,
  spaces = {
    icon = {
      color = one_dark.subtle,
      highlight = one_dark.text,
    },
    label = {
      color = one_dark.subtle,
      highlight = one_dark.blue,
    },
    indicator = one_dark.purple,
  },
  media = {
    label = one_dark.subtle,
  },
  widgets = {
    battery = {
      low = one_dark.red,
      mid = one_dark.yellow,
      high = one_dark.blue,
    },
    wifi = { icon = one_dark.blue },
    volume = {
      icon = one_dark.green,
      popup = {
        item = one_dark.subtle,
        highlight = one_dark.text,
      },
      slider = {
        highlight = one_dark.green,
        bg = one_dark.highlight_med,
        border = one_dark.highlight_low,
      },
    },
    messages = { icon = one_dark.red },
  },
  calendar = {
    label = one_dark.subtle,
  },
}

return M
