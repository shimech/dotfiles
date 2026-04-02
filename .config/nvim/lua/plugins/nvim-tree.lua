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
