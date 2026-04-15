return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  opts = {
    formatters_by_ft = {
      typescript = { "oxfmt", "prettier", stop_after_first = true },
      typescriptreact = { "oxfmt", "prettier", stop_after_first = true },
      javascript = { "oxfmt", "prettier", stop_after_first = true },
      javascriptreact = { "oxfmt", "prettier", stop_after_first = true },
      lua = { "stylua" },
    },
    format_on_save = {
      timeout_ms = 3000,
      lsp_format = "fallback",
    },
  },
}
