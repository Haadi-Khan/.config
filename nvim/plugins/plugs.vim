call plug#begin('~/.config/nvim/plugged')
	" Themes and Airline
	Plug 'joshdick/onedark.vim' 							 					" Colors
	Plug 'vim-airline/vim-airline' 				 								" Status Bar
	Plug 'tc50cal/vim-terminal' 												" Integrated Terminal
	Plug 'scrooloose/nerdcommenter' 											" Comment Out Code
	Plug 'tiagofumo/vim-nerdtree-syntax-highlight' 								" File Tree Coloring
	Plug 'ryanoasis/vim-devicons' 				  								" File Icons in Tree
	Plug 'kyazdani42/nvim-web-devicons'		  									" File Icons in Tabs
	Plug 'romgrk/barbar.nvim' 													" Tab Line
	Plug 'lukas-reineke/indent-blankline.nvim'

	" Git Stuff
	Plug 'nvim-lua/plenary.nvim'
	Plug 'TimUntersberger/neogit' 												" Magit
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
call plug#end()

