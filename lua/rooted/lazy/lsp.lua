-- lua/rooted/lazy/lsp.lua
return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "williamboman/mason.nvim",               config = true },
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      { "j-hui/fidget.nvim",                     opts   = {} },
      { "nvim-telescope/telescope.nvim",         dependencies = { "nvim-lua/plenary.nvim" } },
      { "folke/neodev.nvim",                     opts   = {} },
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local mason     = require("mason")
      local mlc       = require("mason-lspconfig")
      local installer = require("mason-tool-installer")
      local fidget    = require("fidget")
      local cmp_lsp   = require("cmp_nvim_lsp")
      local telescope = require("telescope.builtin")

      local capabilities = cmp_lsp.default_capabilities(
        vim.lsp.protocol.make_client_capabilities()
      )

      -- <<< Updated on_attach starts here >>>
      local on_attach = function(_, bufnr)
        local map = vim.keymap.set
        local opts = { buffer = bufnr, silent = true }

        -- GO TO DEFINITION
        map("n", "gd", function()
          local defs = vim.lsp.buf.get_definition()
          if not defs or vim.tbl_isempty(defs) then return end
          if #defs == 1 then
            vim.lsp.util.jump_to_location(defs[1])
          else
            telescope.lsp_definitions()
          end
        end, vim.tbl_extend("force", opts, { desc = "Telescope: Definitions" }))

        -- FIND REFERENCES
        map("n", "gr", function()
          local refs = vim.lsp.buf.get_references()
          if not refs or vim.tbl_isempty(refs) then return end
          if #refs == 1 then
            vim.lsp.util.jump_to_location(refs[1])
          else
            telescope.lsp_references()
          end
        end, vim.tbl_extend("force", opts, { desc = "Telescope: References" }))

        -- other mappings unchanged
        map("n", "gI", telescope.lsp_implementations, vim.tbl_extend("force", opts, { desc = "Telescope: Implementations" }))
        map("n", "<leader>D", telescope.lsp_type_definitions,
                                            vim.tbl_extend("force", opts, { desc = "Telescope: Type Definitions" }))
        map("n", "gD", vim.lsp.buf.declaration,       vim.tbl_extend("force", opts, { desc = "LSP: Declaration" }))
        map("n", "K",  vim.lsp.buf.hover,             vim.tbl_extend("force", opts, { desc = "LSP: Hover Docs" }))
        map("n", "[d", vim.diagnostic.goto_prev,      vim.tbl_extend("force", opts, { desc = "LSP: Prev Diagnostic" }))
        map("n", "]d", vim.diagnostic.goto_next,      vim.tbl_extend("force", opts, { desc = "LSP: Next Diagnostic" }))
        map("n", "<leader>e", vim.diagnostic.open_float,
                                            vim.tbl_extend("force", opts, { desc = "LSP: Show Diagnostics" }))
        map("n", "<leader>q", vim.diagnostic.setloclist,
                                            vim.tbl_extend("force", opts, { desc = "LSP: Quickfix Diagnostics" }))
      end
      -- <<< Updated on_attach ends here >>>

      fidget.setup({})
      mason.setup()
      installer.setup({ ensure_installed = { "clangd", "pyright", "bashls", "lua_ls" } })

      mlc.setup({
        ensure_installed = { "clangd", "pyright", "bashls", "lua_ls" },
        handlers = {
          function(server_name)
            lspconfig[server_name].setup({
              on_attach    = on_attach,
              capabilities = capabilities,
            })
          end,
          lua_ls = function()
            lspconfig.lua_ls.setup({
              on_attach    = on_attach,
              capabilities = capabilities,
              settings = {
                Lua = {
                  runtime     = { version = "LuaJIT" },
                  diagnostics = { globals = { "vim" } },
                  workspace   = { library = vim.api.nvim_get_runtime_file("", true) },
                },
              },
            })
          end,
        },
      })

      vim.diagnostic.config({
        float = {
          border    = "rounded",
          source    = "always",
          focusable = false,
          style     = "minimal",
        },
      })
    end,
  },
}

