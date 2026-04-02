return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      ensure_installed = {
        "lua",
        "javascript",
        "typescript",
        "tsx",
        "python",
        "go",
        "html",
        "css",
        "json",
        "yaml",
        "markdown",
        "bash",
      },
      highlight = { enable = true },
      indent = { enable = true },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      max_lines = 5,
      separator = "─",
    },
  },
}
