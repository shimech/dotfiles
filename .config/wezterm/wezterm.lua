local wezterm = require 'wezterm'

local config = wezterm.config_builder()

local keybinds = require 'keybinds'
config.keys = keybinds.keys
config.key_tables = keybinds.key_tables
config.leader = keybinds.leader

require 'on'

-- https://wezterm.org/config/lua/config/automatically_reload_config.html
config.automatically_reload_config = true

config.color_scheme = 'iceberg-dark'
config.colors = {
  split = '#ccc',
}
config.inactive_pane_hsb = {
  saturation = 0,
  brightness = 5,
}
config.window_background_opacity = 0.8
-- https://wezterm.org/config/lua/config/macos_window_background_blur.html
config.macos_window_background_blur = 10

config.window_decorations = 'RESIZE'
config.native_macos_fullscreen_mode = true
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.tab_max_width = 48

config.font = wezterm.font_with_fallback { 'Hack', 'Noto Sans JP' }
config.pane_select_font = wezterm.font 'Hack'
config.font_size = 14.0

config.use_ime = true

return config
