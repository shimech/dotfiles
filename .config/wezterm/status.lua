local wezterm = require 'wezterm'

local color_fg = '#161821'

local status_variant = {
  leader = {
    text = 'LEADER',
    color_bg = '#b4be82',
    icon = wezterm.nerdfonts.oct_sparkle_fill,
  },
  copy = {
    text = 'COPY',
    color_bg = '#e2a478',
    icon = wezterm.nerdfonts.fa_clipboard_list,
  },
  normal = {
    text = 'NORMAL',
    color_bg = '#84a0c6',
  }
}

local function format_left_status(text, color_bg, icon)
  local icon_text = icon and ' ' .. icon or ''

  return wezterm.format {
    { Attribute = { Intensity = 'Bold' } },
    { Background = { Color = color_bg } },
    { Foreground = { Color = color_fg } },
    { Text = icon_text .. ' ' .. text .. ' ' },
    { Background = { Color = color_fg } },
    { Foreground = { Color = color_bg } },
    { Text = wezterm.nerdfonts.pl_left_hard_divider },
  }
end

local function set_left_status(window, variant)
  window:set_left_status(
    format_left_status(
      variant.text,
      variant.color_bg,
      variant.icon
    )
  )
end

local function get_status(window)
  if window:leader_is_active() then
    return 'leader'
  end

  local name = window:active_key_table()
  if name == 'copy_mode' then
    return 'copy'
  end

  return 'normal'
end

local function update_left_status(window, pane)
  local status = get_status(window)
  set_left_status(window, status_variant[status])
end

local function update_right_status(window, pane)
  window:set_right_status(wezterm.format({
    { Background = { Color = '#84a0c6' } },
    { Foreground = { Color = color_fg } },
    { Text = ' ' .. wezterm.nerdfonts.oct_device_desktop .. ' ' .. pane:get_domain_name() .. ' ' },
  })
  )
end

wezterm.on('update-status', function(window, pane)
   update_left_status(window, pane)
   update_right_status(window, pane)
  end
)
