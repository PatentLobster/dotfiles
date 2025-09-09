require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "typescript", "pyright", "bashls", "jsonls", "lua_ls", "gopls" }
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers 
