call plug#begin('~/.vim/plugged')
    Plug 'git@github.com:ChristianChiarulli/nvcode-color-schemes.vim.git' " Colors
    Plug 'tpope/vim-fugitive'                                     " Git Plugin
    Plug 'neoclide/coc.nvim', {'branch': 'release'}               " AutoComplete
    Plug 'sheerun/vim-polyglot'                                   " Syn. Highlight
    Plug 'git@github.com:bfrg/vim-cpp-modern.git'                 " C++ Syntax Highlight
    Plug 'git@github.com:vim-python/python-syntax.git'            " Python Syntax Highlight
    Plug 'git@github.com:BurntSushi/ripgrep.git'                  " Fast Grep
    Plug 'mbbill/undotree'                                        " Undo History
    Plug 'git@github.com:preservim/nerdtree.git'                  " File Tree
    Plug 'git@github.com:kien/ctrlp.vim.git'                      " File Search
    Plug 'git@github.com:Yggdroot/indentLine.git'                 " Indent Guides
call plug#end()
