call plug#begin('~/.config/nvim/plugged')
	" Themes and Airline
	Plug 'git@github.com:joshdick/onedark.vim' 							 		" Colors
	Plug 'git@github.com:vim-airline/vim-airline' 								" Status Bar
	Plug 'git@github.com:Yggdroot/indentLine.git'                 				" Indent Guides
	Plug 'git@github.com:tc50cal/vim-terminal' 									" Integrated Terminal
	Plug 'git@github.com:scrooloose/nerdcommenter' 								" Comment Out Code
	Plug 'git@github.com:tiagofumo/vim-nerdtree-syntax-highlight' 				" File Tree Coloring
	Plug 'git@github.com:ryanoasis/vim-devicons' 				  				" File Icons in Tree

	" Git Stuff
	Plug 'git@github.com:tpope/vim-fugitive'                               		" Git Plugin
	Plug 'git@github.com:airblade/vim-gitgutter' 								" Edited Lines

	" Code Autocomplete and support
	Plug 'git@github.com:neoclide/coc.nvim', {'branch': 'release'}         		" Auto Complete
	Plug 'git@github.com:sheerun/vim-polyglot'                             		" Syn. Highlight
	Plug 'git@github.com:bfrg/vim-cpp-modern.git'                 				" C++ Syntax Highlight 
	Plug 'git@github.com:numirias/semshi', { 'do': ':UpdateRemotePlugins' } 	" Python Syntax Highlight
	" File navigation and searching
	Plug 'git@github.com:BurntSushi/ripgrep.git'                  				" Fast Grep
	Plug 'git@github.com:mbbill/undotree'                                  		" Undo History
	Plug 'git@github.com:preservim/nerdtree.git'                  				" File Tree
	Plug 'git@github.com:kien/ctrlp.vim.git'                      				" File Search

	" Org Mode Setup
	Plug 'git@github.com:nvim-treesitter/nvim-treesitter' 						" Needed for Org Mode
	Plug 'git@github.com:nvim-orgmode/orgmode' 									" Org Mode
	Plug 'git@github.com:akinsho/org-bullets.nvim' 								" Org Mode Bullets
	Plug 'git@github.com:dhruvasagar/vim-table-mode' 							" Org Mode Table
call plug#end()

" Treesitter crap for org mode
lua << EOF
local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.org = {
  install_info = {
    url = 'https://github.com/milisims/tree-sitter-org',
    revision = 'f110024d539e676f25b72b7c80b0fd43c34264ef',
    files = {'src/parser.c', 'src/scanner.cc'},
  },
  filetype = 'org',
}

require'nvim-treesitter.configs'.setup {
  -- If TS highlights are not enabled at all, or disabled via `disable` prop, highlighting will fallback to default Vim syntax highlighting
  highlight = {
    enable = true,
    disable = {'org'}, -- Remove this to use TS highlighter for some of the highlights (Experimental)
    additional_vim_regex_highlighting = {'org'}, -- Required since TS highlighter doesn't support all syntax features (conceal)
  },
  ensure_installed = {'org'}, -- Or run :TSUpdate org
}

require('orgmode').setup({
  org_agenda_files = {'/run/media/haadi/Storage/Documents/org/agenda/*'},
  org_default_notes_file = '/run/media/haadi/Storage/Documents/org/*',
})
EOF

