local wezterm = require 'wezterm'
local mux = wezterm.mux

wezterm.on('update-right-status', function(window, pane)
    local name = window:active_key_table()
    if name == 'copy_mode' then
      window:set_right_status(wezterm.format({
        { Background = { Color = '#ebcb8b' } },
        { Foreground = { Color = '#000000' } },
        { Text = ' 📋 COPY MODE ' },
      }))
    else
      window:set_right_status('')
    end
  end)

wezterm.on('gui-startup', function(window)
    local tab, pane, window = mux.spawn_window(cmd or {})
    local gui_window = window:gui_window();
    gui_window:maximize()
  end)
