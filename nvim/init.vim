for f in split(glob('~/.config/nvim/plugins/*.vim'), '\n')
    exe 'source' f
endfor

syntax on

" Best Color Scheme
set termguicolors
colorscheme onedark
set background=dark
set colorcolumn=80

" Basic stuff to not go insane
set noerrorbells
set mouse=a
set tabstop=4
set shiftwidth=4
set smartindent

"Sets working directory in NERDTree to current
set exrc
set hidden

" Easy af for vertical navigation
set number
set relativenumber
set signcolumn=yes
set nowrap
set scrolloff=12

" Searching stuff: 1st no highlight search, 2nd capital sensitive searching
set nohlsearch
set smartcase
set incsearch

" All swapfiles and crap left in separate file
set noswapfile
set nobackup
set undodir=~/.config/nvim/undodir
set undofile

" Should probably use syntax, but this is easier until I write the funcs
set foldmethod=indent

set clipboard=unnamedplus

let mapleader = " "
