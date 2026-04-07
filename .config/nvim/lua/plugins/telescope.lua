return {
  "nvim-telescope/telescope.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  keys = {
    { "<leader> ", "<cmd>Telescope find_files hidden=true no_ignore=true<cr>", desc = "Find Files" },
    { "<leader>/", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
  },
  config = function()
    require("telescope").setup({
      defaults = {
        file_ignore_patterns = { "%.git/", "node_modules/", "%.claude/worktrees" },
      },
    })
    require("telescope").load_extension("fzf")
  end,
}
