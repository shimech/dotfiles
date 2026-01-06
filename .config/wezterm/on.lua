local wezterm = require 'wezterm'
local mux = wezterm.mux

local color_fg = '#161821'

local function format_left_status(color_bg, text, icon)
  local icon_text = icon and ' ' .. icon or ''
  return wezterm.format({
    { Attribute = { Intensity = 'Bold' } },
    { Background = { Color = color_bg } },
    { Foreground = { Color = color_fg } },
    { Text = icon_text .. ' ' .. text .. ' ' },
    { Background = { Color = color_fg } },
    { Foreground = { Color = color_bg } },
    { Text = wezterm.nerdfonts.pl_left_hard_divider },
  })
end

local function update_left_status(window, pane)
  if window:leader_is_active() then
    window:set_left_status(format_left_status('#e27878', 'LEADER', wezterm.nerdfonts.oct_sparkle_fill))
    return
  end

  local name = window:active_key_table()
  if name == 'copy_mode' then
    window:set_left_status(format_left_status('#e2a478', 'COPY', wezterm.nerdfonts.fa_clipboard_list))
    return
  end

  window:set_left_status(format_left_status('#84a0c6', 'NORMAL'))
end

local function update_right_status(window, pane)
  window:set_right_status(wezterm.format({
    { Attribute = { Intensity = 'Bold' } },
    { Background = { Color = '#1e2132' } },
    { Foreground = { Color = '#84a0c6' } },
    { Text = wezterm.nerdfonts.pl_right_hard_divider },
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

wezterm.on('gui-startup', function(window)
    local tab, pane, window = mux.spawn_window(cmd or {})
    local gui_window = window:gui_window();
    gui_window:maximize()
  end
)

-- 絶対パスを表示用のパスに変換する。
local function get_display_path(cwd_path, fallback)
  local home = wezterm.home_dir

  -- カレントディレクトリがホームディレクトリの場合、"~"で早期リターンする。
  if cwd_path == home then
    return '~'
  end

  local display_path = cwd_path
  if display_path:sub(1, #home) == home then
    -- カレントディレクトリがホームディレクトリ配下の場合、ホームディレクトリまでを"~"で置換する。
    -- 例: /User/username/Documents/foo/bar/baz -> ~/Documents/foo/bar/baz
    display_path = '~' .. cwd_path:sub(#home + 1)
  else
    -- カレントディレクトリがホームディレクトリ配下でない場合、フォールバックを返す。
    return fallback
  end

  local parts = {}
  for part in string.gmatch(display_path, '[^/]+') do
    table.insert(parts, part)
  end

  -- 最後の要素以外は頭文字のみにする。
  -- 例: ~/Documents/foo/bar/baz -> ~/D/f/b/baz
  for i = 1, #parts - 1 do
    parts[i] = parts[i]:sub(1, 1)
  end

  local prefix = (display_path:sub(1, 1) == '/') and '/' or ''
  return prefix .. table.concat(parts, '/')
end

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
    local pane = tab.active_pane
    local cwd = pane.current_working_dir

    if cwd then
      -- file_pathの末尾は"/"であるため削除する。
      local display_path = get_display_path(cwd.file_path:sub(1, -2), pane.title)

      return {
        { Text = ' ' .. wezterm.nerdfonts.md_tab .. '  ' .. tab.tab_index + 1 .. ' ' .. display_path .. ' ' },
      }
    end

    return pane.title
  end
)
