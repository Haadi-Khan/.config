local lsp = require('lsp-zero')
local luasnip = require('luasnip')

lsp.preset('recommended')

require('mason').setup()
require('mason-lspconfig').setup()
require('lsp-zero').extend_lspconfig()
require("mason-lspconfig").setup {
    ensure_installed = {
        "lua_ls",
        "clangd",
        "rust_analyzer",
        "pyright",
        "tinymist",
        "ts_ls",
        "tailwindcss"
    },
}
require("lspconfig").lua_ls.setup {}
require("lspconfig").clangd.setup {}
require("lspconfig").pyright.setup {}
require("lspconfig").tinymist.setup {}
require("lspconfig").ts_ls.setup {}
require("lspconfig").tailwindcss.setup {}

require 'lspconfig'.rust_analyzer.setup {
    settings = {
        ['rust-analyzer'] = {
            diagnostics = {
                enable = false,
            }
        }
    }
}

require("lspconfig")["tinymist"].setup {
    settings = {
        formatterMode = "typstyle",
        exportPdf = "onType",
        semanticTokens = "disable"
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
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },

    mapping = cmp.mapping.preset.insert({
        ['<C-j>'] = cmp.mapping.select_next_item(cmp_select),
        ['<C-k>'] = cmp.mapping.select_prev_item(cmp_select),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<TAB>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.confirm({ select = true })
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { "i", "s" }),
        ['<S-TAB>'] = cmp.mapping(function(fallback)
            if luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
    }),

    formatting = {
        fields = { "kind", "abbr" },
        format = function(_, vim_item)
            vim_item.kind = cmp_kinds[vim_item.kind] or ""
            return vim_item
        end,
    },

    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'copilot' },
        { name = 'luasnip' },
        { name = 'buffer' },
        { name = 'path' }
    }),
})

lsp.setup()
