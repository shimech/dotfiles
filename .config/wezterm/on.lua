local wezterm = require 'wezterm'
local mux = wezterm.mux

wezterm.on('update-status', function(window, pane)
    if window:leader_is_active() then
      window:set_left_status(wezterm.format({
        { Attribute = { Intensity = 'Bold' } },
        { Background = { Color = '#e27878' } },
        { Foreground = { Color = '#161821' } },
        { Text = ' ✨ LEADER ' },
      }))
      return
    end

    local name = window:active_key_table()
    if name == 'copy_mode' then
      window:set_left_status(wezterm.format({
        { Attribute = { Intensity = 'Bold' } },
        { Background = { Color = '#e2a478' } },
        { Foreground = { Color = '#161821' } },
        { Text = ' 📋 COPY MODE ' },
      }))
      return
    end

    window:set_left_status('')
  end
)

wezterm.on('gui-startup', function(window)
    local tab, pane, window = mux.spawn_window(cmd or {})
    local gui_window = window:gui_window();
    gui_window:maximize()
  end
)

-- 絶対パスを表示用のパスに変換する。
local function get_display_path(cwd_path)
  local home = wezterm.home_dir

  if cwd_path == home then
    return '~'
  end

  if cwd_path:sub(1, #home) == home then
    return '~' .. cwd_path:sub(#home + 1)
  end

  return cwd_path
end

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
    local pane = tab.active_pane
    local cwd = pane.current_working_dir

    if cwd then
      -- 末尾は"/"であるため、削除する。
      local display_path = get_display_path(cwd.file_path:sub(1, -2))

      return {
        { Text = ' ' .. tab.tab_index + 1 .. ': ' .. display_path .. ' ' },
      }
    end

    return pane.title
  end
)
