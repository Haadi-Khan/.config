call plug#begin('~/.vim/plugged')
	Plug 'git@github.com:joshdick/onedark.vim' 							 		" Colors
	Plug 'git@github.com:tpope/vim-fugitive'                               		" Git Plugin
	Plug 'git@github.com:airblade/vim-gitgutter' 								" Edited Lines
	Plug 'git@github.com:neoclide/coc.nvim', {'branch': 'release'}         		" Auto Complete
	Plug 'git@github.com:sheerun/vim-polyglot'                             		" Syn. Highlight
	Plug 'git@github.com:bfrg/vim-cpp-modern.git'                 				" C++ Syntax Highlight
	Plug 'git@github.com:numirias/semshi', { 'do': ':UpdateRemotePlugins' } 	" Python Syntax Highlight

	Plug 'git@github.com:BurntSushi/ripgrep.git'                  				" Fast Grep
	Plug 'git@github.com:mbbill/undotree'                                  		" Undo History
	Plug 'git@github.com:preservim/nerdtree.git'                  				" File Tree
	Plug 'git@github.com:tiagofumo/vim-nerdtree-syntax-highlight' 				" File Tree Coloring
	Plug 'git@github.com:ryanoasis/vim-devicons' 				  				" File Icons in Tree
	Plug 'git@github.com:kien/ctrlp.vim.git'                      				" File Search
	Plug 'git@github.com:nvim-telescope/telescope.nvim' 						" Search Across Files
	Plug 'git@github.com:Yggdroot/indentLine.git'                 				" Indent Guides
	Plug 'git@github.com:tc50cal/vim-terminal' 									" Integrated Terminal
	Plug 'git@github.com:scrooloose/nerdcommenter' 								" Comment Out Code
call plug#end()
