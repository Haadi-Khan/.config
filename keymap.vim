" Set file explorer view toggle to F2
map <C-N> :NERDTreeToggle<CR> 
" Map Ctrl-Backspace to delete the previous word in insert mode.
inoremap <C-w> <C-\><C-o>dB
inoremap <C-BS> <C-\><C-o>db
" Use H/L to switch tabs in vim
nmap H gT
nmap L gt
" Ctrl / clears search highlights
map <C-/> :noh
