local lsp = require('lsp-zero')

lsp.preset('recommended')

require('mason').setup()
require('mason-lspconfig').setup()
require('lsp-zero').extend_lspconfig()
require("mason-lspconfig").setup { ensure_installed = { "lua_ls", "clangd", "rust_analyzer", "pyright" }, }
require("lspconfig").lua_ls.setup {}
require("lspconfig").clangd.setup {}
require("lspconfig").pyright.setup {}


require 'lspconfig'.rust_analyzer.setup {
    settings = {
        ['rust-analyzer'] = {
            diagnostics = {
                enable = false,
            }
        }
    }
}

local wk = require("which-key")
-- This is where you enable features that only work
-- if there is a language server active in the file
vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'LSP actions',
    callback = function(event)
        local opts = { buffer = event.buf }
        wk.add({
            { 'K',          '<cmd>lua vim.lsp.buf.hover()<cr>',                 opts,                                  desc = "",                     mode = "n" },
            { 'gd',         '<cmd>lua vim.lsp.buf.definition()<cr>',            opts,                                  desc = "Goto Definition",      mode = "n" },
            { 'gD',         '<cmd>lua vim.lsp.buf.implementation()<cr>',        opts,                                  desc = "Goto Implemnetations", mode = "n" },

            { '<leader>c',  group = "code" },
            { '<leader>cr', '<cmd>lua vim.lsp.buf.rename()<cr>',                opts,                                  desc = "Rename Symbol",        mode = "n" },
            { '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>',           opts,                                  desc = "Code Actions",         mode = "n" },
            { '<leader>cf', '<cmd>lua vim.lsp.buf.format({async = true})<cr>',  opts,                                  desc = "Code Format",          mode = "n" },
            { "<leader>cx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Diagnostics (Trouble)", },
            { "<leader>cX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)", },
        })
    end,
})




local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_kinds = {
    Text = '  ',
    Method = '  ',
    Function = '  ',
    Constructor = '  ',
    Field = '  ',
    Variable = '  ',
    Class = '  ',
    Interface = '  ',
    Module = '  ',
    Property = '  ',
    Unit = '  ',
    Value = '  ',
    Enum = '  ',
    Keyword = '  ',
    Snippet = '  ',
    Color = '  ',
    File = '  ',
    Reference = '  ',
    Folder = '  ',
    EnumMember = '  ',
    Constant = '  ',
    Struct = '  ',
    Event = '  ',
    Operator = '  ',
    TypeParameter = '  ',
}

cmp.setup({
    mapping = cmp.mapping.preset.insert({
        ['<C-j>'] = cmp.mapping.select_next_item(cmp_select),
        ['<C-k>'] = cmp.mapping.select_prev_item(cmp_select),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<TAB>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),

    formatting = {
        fields = { "kind", "abbr" },
        format = function(_, vim_item)
            vim_item.kind = cmp_kinds[vim_item.kind] or ""
            return vim_item
        end,
    }

})

lsp.setup()
