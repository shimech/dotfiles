return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  opts = {
    options = {
      icon_enabled = true,
      theme = "iceberg_dark",
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", "diff" },
      lualine_c = { "diagnostics", { "filename", path = 3 } },
      lualine_x = { "encoding", "lsp_status", "filetype" },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
  },
}
