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

" CoC Keybinds
" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nnoremap <silent> [g <Plug>(coc-diagnostic-prev)
nnoremap <silent> ]g <Plug>(coc-diagnostic-next)
" GoTo code navigation.
nnoremap <silent> gd <Plug>(coc-definition)
nnoremap <silent> gy <Plug>(coc-type-definition)
nnoremap <silent> gi <Plug>(coc-implementation)
nnoremap <silent> gr <Plug>(coc-references)
" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>
" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nnoremap <leader>f  <Plug>(coc-format-selected)
" Map rename to F2
nmap <F2> <Plug>(coc-rename)
vmap <F2> <Plug>(coc-rename)

