source ~/.vim/config/plugs.vim
source ~/.vim/config/keymap.vim
source ~/.vim/config/coc.vim

syntax on

set noerrorbells
set tabstop=4
set shiftwidth=4
set smartindent
set nu
set nowrap
set smartcase
set noswapfile
set nobackup
set undodir=~/.vim/undodir
set undofile
set incsearch
set foldmethod=syntax
let mapleader = " "

set colorcolumn=120
highlight ColorColumn ctermbg=0 guibg=lightgrey


colorscheme onedark
set background=dark
let g:onedark_termcolors = 256

if executable('rg')
	let g:rg_derive_root='true'
endif

" Ignores all files ignored by .gitignore
let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']
let g:netrw_browse_split=2
let g:netrw_banner = 0
let g:netrw_winsize = 25

let g:ctrlp_use_caching = 0

