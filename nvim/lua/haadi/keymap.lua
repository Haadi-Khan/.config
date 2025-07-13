-- Escape insert mode by pressing 'jk'
vim.keymap.set("i", "jk", "<Esc>")

-- Move selected lines up or down in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Normal mode enhancements
vim.keymap.set("n", "M", "`")
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzzz")

-- Paste over selection without overwriting the default register
vim.keymap.set("x", "<leader>p", "\"_dP")

vim.keymap.set("n", "QQ", "gqq")
