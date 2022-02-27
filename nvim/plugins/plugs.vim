call plug#begin('~/.config/nvim/plugged')
	" Themes and Airline
	Plug 'joshdick/onedark.vim' 							 					" Colors
	Plug 'vim-airline/vim-airline' 				 								" Status Bar
	Plug 'git@github.com:Yggdroot/indentLine.git'                 				" Indent Guides
	Plug 'tc50cal/vim-terminal' 												" Integrated Terminal
	Plug 'scrooloose/nerdcommenter' 											" Comment Out Code
	Plug 'tiagofumo/vim-nerdtree-syntax-highlight' 								" File Tree Coloring
	Plug 'ryanoasis/vim-devicons' 				  								" File Icons in Tree
	Plug 'kyazdani42/nvim-web-devicons'		  									" File Icons in Tabs
	Plug 'romgrk/barbar.nvim' 													" Tab Line

	" Git Stuff
	Plug 'tpope/vim-fugitive'                            				   		" Git Plugin
	Plug 'airblade/vim-gitgutter' 												" Edited Lines

	" Code Autocomplete and highlighting
	Plug 'neoclide/coc.nvim', {'branch': 'release'}
	Plug 'hrsh7th/vim-vsnip' 													" Snippets
	Plug 'hrsh7th/vim-vsnip-integ' 												" Needed for Snippets
	Plug 'git@github.com:bfrg/vim-cpp-modern.git'                 				" C++ Syntax Highlight 
	Plug 'numirias/semshi', { 'do': ':UpdateRemotePlugins' } 					" Python Syntax Highlight
	Plug 'uiiaoo/java-syntax.vim' 												" Java Syntax Highlight
	
	" File navigation and searching
	Plug 'mbbill/undotree'   				                               		" Undo History
	Plug 'git@github.com:BurntSushi/ripgrep.git'                  				" Fast Grep
	Plug 'git@github.com:preservim/nerdtree.git'                  				" File Tree
	Plug 'git@github.com:kien/ctrlp.vim.git'                      				" File Search
	Plug 'dbeecham/ctrlp-commandpalette.vim' 									" Command Palette

	" Org Mode Setup
	Plug 'nvim-treesitter/nvim-treesitter' 										" Needed for Org Mode
	Plug 'nvim-orgmode/orgmode' 												" Org Mode
	Plug 'akinsho/org-bullets.nvim' 											" Org Mode Bullets
	Plug 'dhruvasagar/vim-table-mode' 											" Org Mode Table
call plug#end()

lua << EOF
-- Org Mode Setup
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
	  org_agenda_files = {'~/Documents/org/*'},
	  org_default_notes_file = '~/Documents/org/todos.org',
	  org_indent_mode = indent
	})
EOF
