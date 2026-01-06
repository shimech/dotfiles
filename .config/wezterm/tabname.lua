local wezterm = require 'wezterm'

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
        { Text = ' ' .. wezterm.nerdfonts.md_tab .. ' ' .. tab.tab_index + 1 .. ' ' .. display_path .. ' ' },
      }
    end

    return pane.title
  end
)
