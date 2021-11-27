" Set file explorer view toggle to F2
map <C-N> :NERDTreeToggle<CR> 
" Map Ctrl-Backspace to delete the previous word in insert mode.
inoremap <C-w> <C-\><C-o>dB
inoremap <C-BS> <C-\><C-o>db
" Use H/L to switch tabs in vim
nmap H gT
nmap L gt
" Ctrl ' clears search highlights
map <C-'> :noh<CR>
" Ctrl / to comment code
map <C-_> <plug>NERDCommenterToggle
" Run Python Code
autocmd FileType python map <buffer> <F5> :w<CR>:exec '!python3' shellescape(@%, 1)<CR>
