-- disable netrw at the very start of your init.lua
--vim.g.loaded_netrw = 1
--vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true


local function my_on_attach(bufnr)
    local api = require "nvim-tree.api"

    local function opts(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    -- default mappings
    api.config.mappings.default_on_attach(bufnr)

    -- custom mappings
    vim.keymap.set('n', 'l', api.node.open.edit, opts('Into'))
    vim.keymap.set('n', 'h', api.node.navigate.parent_close, opts('Help'))
end

-- pass to setup along with your other options
require("nvim-tree").setup {
    ---
    ---
}

require("nvim-tree").setup({
    sort = {
        sorter = "case_sensitive",
    },
    view = {
        width = 30,
        side = "right"
    },
    renderer = {
        group_empty = true,
    },
    filters = {
        dotfiles = true,
    },
    on_attach = my_on_attach,
})

local wk = require("which-key")
wk.add({
    { "<leader>op", vim.cmd.NvimTreeToggle, desc = "Toggle File Tree", mode = "n" },
})
