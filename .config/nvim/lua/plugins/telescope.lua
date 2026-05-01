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
    { "<leader>fo", "<cmd>Telescope oldfiles<cr>", desc = "Old Files (history)" },
    { "<leader>fr", "<cmd>Telescope oldfiles cwd_only=true<cr>", desc = "Recent Files (cwd)" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
  },
  config = function()
    require("telescope").setup({
      defaults = {
        file_ignore_patterns = { "%.git/" },
      },
    })
    require("telescope").load_extension("fzf")
  end,
}
