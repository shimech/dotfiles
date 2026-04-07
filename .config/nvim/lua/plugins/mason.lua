return {
  {
    "mason-org/mason.nvim",
    opts = {},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = { "ts_ls", "lua_ls", "eslint" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "saghen/blink.cmp" },
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      vim.lsp.config("ts_ls", {
        capabilities = capabilities,
      })
      vim.lsp.enable("ts_ls")

      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
          },
        },
      })
      vim.lsp.enable("lua_ls")

      vim.lsp.config("eslint", {
        capabilities = capabilities,
      })
      vim.lsp.enable("eslint")

      -- 保存時に足りない import を自動追加 (TypeScript)
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },
        callback = function(args)
          local clients = vim.lsp.get_clients({ bufnr = args.buf, name = "ts_ls" })
          if #clients == 0 then
            return
          end
          vim.lsp.buf.code_action({
            context = {
              only = { "source.addMissingImports.ts" },
              diagnostics = {},
            },
            apply = true,
          })
          -- code_action は非同期なので少し待つ
          vim.wait(1000, function() end)
        end,
      })

      -- LSP keymaps (LSP がアタッチされたバッファのみ)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local buf = args.buf
          local opts = { buffer = buf }
          vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<cr>", opts)
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<cr>", opts)
          vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<cr>", opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        end,
      })
    end,
  },
}
