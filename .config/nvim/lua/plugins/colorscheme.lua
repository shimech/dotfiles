return {
  "oahlen/iceberg.nvim",
  lazy = false, -- make sure we load this during startup if it is your main colorscheme
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    vim.cmd([[colorscheme iceberg]])
    vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#161821" })
    vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#6b7089", bg = "#161821" })
    vim.api.nvim_set_hl(0, "NoiceCmdlinePopup", { bg = "#161821" })
    vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { bg = "#161821" })
    vim.api.nvim_set_hl(0, "WhichKeyNormal", { bg = "#161821" })
    vim.api.nvim_set_hl(0, "WhichKeyBorder", { bg = "#161821" })
    vim.api.nvim_set_hl(0, "NoiceHover", { bg = "#161821" })
    vim.api.nvim_set_hl(0, "NoiceHoverBorder", { fg = "#6b7089", bg = "#161821" })
    vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "#1e2132" })
    vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { fg = "#6b7089" })
    vim.api.nvim_set_hl(0, "MasonNormal", { bg = "#161821" })
    vim.api.nvim_set_hl(0, "MasonMutedBlock", { bg = "#161821" })
    vim.api.nvim_set_hl(0, "MasonHeader", { bg = "#161821" })
    vim.api.nvim_set_hl(0, "MasonHeaderSecondary", { bg = "#161821" })
    vim.api.nvim_set_hl(0, "LazyNormal", { bg = "#161821" })
    vim.api.nvim_set_hl(0, "LazyButton", { bg = "#161821" })
    vim.api.nvim_set_hl(0, "LazyButtonActive", { bg = "#1e2132" })
  end,
}
