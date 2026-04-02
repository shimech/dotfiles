return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  opts = {
    indent = {
      char = "│",
      highlight = "IblIndent",
    },
    scope = {
      highlight = "IblScope",
    },
  },
  config = function(_, opts)
    vim.api.nvim_set_hl(0, "IblIndent", { fg = "#3e4359" })
    vim.api.nvim_set_hl(0, "IblScope", { fg = "#6b7089" })
    require("ibl").setup(opts)
  end,
}
