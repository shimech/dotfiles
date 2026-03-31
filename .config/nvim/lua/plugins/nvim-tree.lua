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
