" Set file explorer view toggle to Ctrl N
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
" Map rename to F2
nmap <F2> <Plug>(coc-rename)
vmap <F2> <Plug>(coc-rename)
" Run Python Code
autocmd FileType python map <buffer> <F5> :w<CR>:exec '!python3' shellescape(@%, 1)<CR>
autocmd FileType python imap <buffer> <F5> <esc>:w<CR>:exec '!python3' shellescape(@%, 1)<CR> 
" Pastes while keeping old paste 
vnoremap p "_dP
