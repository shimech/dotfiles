return {
  "chikko80/error-lens.nvim",
  event = "BufRead",
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  opts = {},
  config = function(_, opts)
    require("error-lens").setup(opts)
    local handler = vim.diagnostic.handlers.error_lens
    if handler and handler.show then
      local original_show = handler.show
      handler.show = function(namespace, bufnr, diagnostics, opts2)
        local line_count = vim.api.nvim_buf_line_count(bufnr)
        local filtered = vim.tbl_filter(function(d)
          return d.lnum < line_count
        end, diagnostics)
        original_show(namespace, bufnr, filtered, opts2)
      end
    end
  end,
}
