" Quick return to normal mode
inoremap jk <Esc>
" Map Ctrl-Backspace to delete the previous word in insert mode.
inoremap <C-w> <C-\><C-o>dB
inoremap <C-BS> <C-\><C-o>db
" Pastes while keeping old paste 
vnoremap <leader>p "_dP

" Set file explorer view toggle to Ctrl H
map <C-H> :NERDTreeToggle<CR> 
" Ctrl / to comment code
map <C-_> <plug>NERDCommenterToggle

" Toggle terminal on/off
nnoremap tr :call TermToggle(12)<CR>
inoremap <leader>tr :call TermToggle(12)<CR>

" Terminal go back to normal mode
tnoremap <Esc> <C-\><C-n>
tnoremap :q! <C-\><C-n>:q!<CR>
