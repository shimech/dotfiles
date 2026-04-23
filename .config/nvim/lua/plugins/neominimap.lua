return {
  "Isrothy/neominimap.nvim",
  version = "v3.*.*",
  lazy = false,
  init = function()
    vim.opt.wrap = false
    vim.opt.sidescrolloff = 36

    vim.g.neominimap = {
      auto_enable = true,
      layout = "split",
      split = {
        direction = "right",
        close_if_last_window = true,
      },
      minimap_width = 16,
      x_multiplier = 4,
      y_multiplier = 1,

      exclude_filetypes = {
        "help",
        "NvimTree",
        "neo-tree",
        "TelescopePrompt",
        "TelescopeResults",
        "lazy",
        "mason",
        "noice",
        "markdown",
      },
      exclude_buftypes = {
        "nofile",
        "nowrite",
        "quickfix",
        "terminal",
        "prompt",
      },

      click = { enabled = false },
      diagnostic = { enabled = true, severity = vim.diagnostic.severity.WARN },
      git = { enabled = true },
      search = { enabled = true },
      treesitter = { enabled = true },
      mark = { enabled = false },

      sync_cursor = true,
      delay = 200,
    }
  end,
  keys = {
    { "<leader>mm", "<cmd>Neominimap toggle<cr>", desc = "Toggle minimap (global)" },
    { "<leader>mb", "<cmd>Neominimap bufToggle<cr>", desc = "Toggle minimap (buffer)" },
    { "<leader>mw", "<cmd>Neominimap winToggle<cr>", desc = "Toggle minimap (window)" },
    { "<leader>mf", "<cmd>Neominimap focus<cr>", desc = "Focus minimap" },
    { "<leader>mu", "<cmd>Neominimap refresh<cr>", desc = "Refresh minimap" },
  },
}
