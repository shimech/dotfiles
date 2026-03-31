return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "helix",
    win = {
      no_overlap = false,
      border = "rounded",
      padding = { 1, 2 },
      title = true,
      title_pos = "center",
    },
    layout = {
      width = { min = 20 },
      spacing = 3,
    },
    spec = {
      { "<leader>a", group = "AI/Claude" },
      { "<leader>f", group = "Find" },
      { "<leader>g", group = "Git" },
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
}
