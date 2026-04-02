vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  command = "if mode() != 'c' | checktime | endif",
})

vim.opt.number = true
vim.opt.clipboard = "unnamedplus"
-- yankしたときに改行が入らないようにする
vim.g.clipboard = {
  name = "macOS-no-trailing-newline",
  copy = {
    ["+"] = { "sh", "-c", "perl -pe 'chomp if eof' | pbcopy" },
    ["*"] = { "sh", "-c", "perl -pe 'chomp if eof' | pbcopy" },
  },
  paste = {
    ["+"] = { "pbpaste" },
    ["*"] = { "pbpaste" },
  },
  cache_enabled = 0,
}
vim.opt.list = true
vim.opt.listchars = { tab = "→ ", trail = "·", lead = "·", space = "·" }
vim.api.nvim_set_hl(0, "TrailWhitespace", { fg = "#e27878", bg = "#33252a" })
vim.fn.matchadd("TrailWhitespace", [[\s\+$]])

vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.smartindent = true
vim.cmd("filetype plugin indent on")
