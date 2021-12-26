" Quick return to normal mode
inoremap jk <Esc>
" Use H/L to switch tabs in vim
nmap H gT
nmap L gt
" Map Ctrl-Backspace to delete the previous word in insert mode.
inoremap <C-w> <C-\><C-o>dB
inoremap <C-BS> <C-\><C-o>db
" Pastes while keeping old paste 
vnoremap <leader>p "_dP

" Run Python Code
autocmd FileType python map <buffer> <F5> :w<CR>:exec '!python3' shellescape(@%, 1)<CR>
autocmd FileType python imap <buffer> <F5> <esc>:w<CR>:exec '!python3' shellescape(@%, 1)<CR> 

" Set file explorer view toggle to Ctrl N
map <C-N> :NERDTreeToggle<CR> 
" Ctrl / to comment code
map <C-_> <plug>NERDCommenterToggle

" Toggle terminal on/off
nnoremap tr :call TermToggle(12)<CR>
inoremap <leader>tr :call TermToggle(12)<CR>

" Terminal go back to normal mode
tnoremap <Esc> <C-\><C-n>
tnoremap :q! <C-\><C-n>:q!<CR>
