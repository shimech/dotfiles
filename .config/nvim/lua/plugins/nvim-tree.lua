local float_win_id = nil

local function close_float()
  if float_win_id and vim.api.nvim_win_is_valid(float_win_id) then
    vim.api.nvim_win_close(float_win_id, true)
  end
  float_win_id = nil
end

return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons", -- optional, but recommended
    },
    lazy = false, -- neo-tree will lazily load itself
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle Neo-tree" },
    },
    config = function(_, opts)
      vim.api.nvim_set_hl(0, "NeoTreeFloatName", { fg = "#c7c9d1", bg = "#161821" })
      vim.api.nvim_set_hl(0, "NeoTreeFloatNameBorder", { fg = "#6b7089", bg = "#161821" })
      require("neo-tree").setup(opts)

      -- neo-treeのgit statusをリアルタイムでリフレッシュする
      vim.api.nvim_create_autocmd({ "FocusGained", "BufWritePost", "TermClose", "TermLeave" }, {
        callback = function()
          if package.loaded["neo-tree.sources.manager"] then
            require("neo-tree.sources.manager").refresh()
          end
        end,
      })
    end,
    opts = {
      event_handlers = {
        {
          event = "vim_cursor_moved",
          handler = function()
            close_float()
            if vim.bo.filetype ~= "neo-tree" then
              return
            end
            local ok, state = pcall(function()
              return require("neo-tree.sources.manager").get_state_for_window()
            end)
            if not ok or not state or not state.tree then
              return
            end
            local node_ok, node = pcall(state.tree.get_node, state.tree)
            if not node_ok or not node or not node.name then
              return
            end
            local line = vim.api.nvim_get_current_line()
            if line:find(node.name, 1, true) then
              return
            end
            local buf = vim.api.nvim_create_buf(false, true)
            local display_text = " " .. node.name .. " "
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, { display_text })
            float_win_id = vim.api.nvim_open_win(buf, false, {
              relative = "cursor",
              row = 1,
              col = 0,
              width = vim.fn.strdisplaywidth(display_text),
              height = 1,
              style = "minimal",
              border = "rounded",
              focusable = false,
            })
            vim.api.nvim_set_option_value("winhl", "Normal:NeoTreeFloatName,FloatBorder:NeoTreeFloatNameBorder", { win = float_win_id })
          end,
        },
        {
          event = "neo_tree_buffer_leave",
          handler = function()
            close_float()
          end,
        },
      },
      window = {
        mappings = {
          ["<space>"] = "none",
          ["q"] = "none",
        },
      },
      default_component_configs = {
        git_status = {
          symbols = {
            added     = "+",
            modified  = "M",
            deleted   = "x",
            renamed   = "→",
            untracked = "",
            ignored   = "i",
            unstaged  = "U",
            staged    = "",
            conflict  = "",
          },
        },
      },
      filesystem = {
        follow_current_file = {
          enabled = true,
          leave_dirs_open = true,
        },
        async_directory_scan = "auto",
        use_libuv_file_watcher = true,
        window = {
          mappings = {
            ["<bs>"] = "none",
            ["."] = "none",
          },
        },
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
    },
  }
}
