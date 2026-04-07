local wezterm = require("wezterm")
local mux = wezterm.mux
local act = wezterm.action
local projects = dofile(wezterm.config_dir .. "/projects.local.lua")

return {
  switch_action = wezterm.action_callback(function(window, pane)
    local choices = {}
    for _, project in ipairs(projects) do
      table.insert(choices, { label = project.label })
    end

    window:perform_action(
      act.InputSelector({
        title = "Switch Workspace",
        choices = choices,
        action = wezterm.action_callback(function(window, pane, id, label)
          if not label then
            return
          end

          local project = nil
          for _, p in ipairs(projects) do
            if p.label == label then
              project = p
              break
            end
          end
          if not project then
            return
          end

          window:perform_action(
            act.SwitchToWorkspace({
              name = label,
              spawn = { cwd = project.cwd },
            }),
            pane
          )

          if project.layout then
            -- 新規セッションが作成されるまで0.5秒待つ。
            wezterm.time.call_after(0.5, function()
              for _, ws in ipairs(mux.all_windows()) do
                if ws:get_workspace() == label then
                  local tabs = ws:tabs()
                  local tab = tabs[1]
                  local first_pane = tab:panes()[1]
                  project.layout(tab, first_pane, ws, project.cwd)
                end
              end
            end)
          end
        end),
      }),
      pane
    )
  end),
}
