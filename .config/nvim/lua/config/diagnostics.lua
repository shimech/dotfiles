vim.opt.updatetime = 250

vim.diagnostic.config({
  float = {
    border = "rounded",
    source = true,
    header = "",
    prefix = "",
  },
})

vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, {
      focus = false,
      scope = "cursor",
    })
  end,
})
