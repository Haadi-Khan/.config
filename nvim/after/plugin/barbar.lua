require('barbar')
vim.keymap.set("n",'H',vim.cmd.BufferPrevious)
vim.keymap.set("n",'L',vim.cmd.BufferNext)

vim.keymap.set("n",'<M-H>',vim.cmd.BufferMovePrevious)
vim.keymap.set("n",'<M-L>',vim.cmd.BufferMoveNext)

vim.keymap.set("n",'<M-1>','vim.cmd.BufferGoto 1')
vim.keymap.set("n",'<M-2>','vim.cmd.BufferGoto 2')
vim.keymap.set("n",'<M-3>','vim.cmd.BufferGoto 3')
vim.keymap.set("n",'<M-4>','vim.cmd.BufferGoto 4')
vim.keymap.set("n",'<M-5>','vim.cmd.BufferGoto 5')
vim.keymap.set("n",'<M-6>','vim.cmd.BufferGoto 6')
vim.keymap.set("n",'<M-7>','vim.cmd.BufferGoto 7')
vim.keymap.set("n",'<M-8>','vim.cmd.BufferGoto 8')
vim.keymap.set("n",'<M-9>','vim.cmd.BufferLast')

-- Pin/unpin buffer
vim.keymap.set("n",'<M-p>',vim.cmd.BufferPin)
-- Close buffer
vim.keymap.set("n",'<M-c>',vim.cmd.BufferClose)
-- Wipeout buffer

-- Magic buffer-picking mode
vim.keymap.set("n",'<M-s>',vim.cmd.BufferPick)

-- Sort automatically by...
vim.keymap.set("n",'<leader>bb',vim.cmd.BufferOrderByBufferNumber)
vim.keymap.set("n",'<leader>bd',vim.cmd.BufferOrderByDirectory)
vim.keymap.set("n",'<leader>bl',vim.cmd.BufferOrderByLanguage)
vim.keymap.set("n",'<leader>bw',vim.cmd.BufferOrderByWindowNumber)
