return {
  {
    "nvim-telescope/telescope.nvim",
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    keys = {
      { "<leader>p", "<cmd>Telescope find_files hidden=true<cr>", desc = "Find Files" },
      { "<leader>:", "<cmd>Telescope commands<cr>", desc = "Commands" },
    },
  },
}
