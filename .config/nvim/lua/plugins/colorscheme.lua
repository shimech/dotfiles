return {
  {
    "oahlen/iceberg.nvim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      vim.cmd([[colorscheme iceberg]])
      vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "NoiceCmdlinePopup", { bg = "#161821" })
      vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { bg = "#161821" })
      vim.api.nvim_set_hl(0, "WhichKeyNormal", { bg = "#161821" })
      vim.api.nvim_set_hl(0, "WhichKeyBorder", { bg = "#161821" })
      vim.api.nvim_set_hl(0, "NoiceHover", { bg = "#161821" })
      vim.api.nvim_set_hl(0, "NoiceHoverBorder", { fg = "#6b7089", bg = "#161821" })
    end,
  },
}
