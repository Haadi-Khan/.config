call plug#begin('~/.config/nvim/plugged')
	" Themes and Airline
	Plug 'joshdick/onedark.vim' 							 					" Colors
	Plug 'vim-airline/vim-airline' 				 								" Status Bar
	Plug 'tc50cal/vim-terminal' 												" Integrated Terminal
	Plug 'scrooloose/nerdcommenter' 											" Comment Out Code
    Plug 'lukas-reineke/indent-blankline.nvim'                                  " Indent Guides
	Plug 'tiagofumo/vim-nerdtree-syntax-highlight' 								" File Tree Coloring
	Plug 'ryanoasis/vim-devicons' 				  								" File Icons in Tree
	Plug 'kyazdani42/nvim-web-devicons'		  									" File Icons in Tabs
	Plug 'romgrk/barbar.nvim' 													" Tab Line

	" Git Stuff
	Plug 'TimUntersberger/neogit'                                               " Magit Plugin
	Plug 'sindrets/diffview.nvim' 												" Magit Diffs
    Plug 'nvim-lua/plenary.nvim'
	Plug 'airblade/vim-gitgutter' 												" Edited Lines

	" Code Autocomplete and highlighting
	Plug 'neoclide/coc.nvim', {'branch': 'release'} 							" LSP
	Plug 'hrsh7th/vim-vsnip' 													" Snippets
	Plug 'hrsh7th/vim-vsnip-integ' 												" Needed for Snippets
	Plug 'git@github.com:bfrg/vim-cpp-modern.git'                 				" C++ Syntax Highlight 
	Plug 'numirias/semshi', { 'do': ':UpdateRemotePlugins' } 					" Python Syntax Highlight
	Plug 'uiiaoo/java-syntax.vim' 												" Java Syntax Highlight
	Plug 'z3t0/arduvim'
	
	" File navigation and searching
	Plug 'mbbill/undotree'   				                               		" Undo History
	Plug 'git@github.com:BurntSushi/ripgrep.git'                  				" Fast Grep
	Plug 'git@github.com:preservim/nerdtree.git'                  				" File Tree
	Plug 'Xuyuanp/nerdtree-git-plugin' 											" See Modified Files
	Plug 'git@github.com:kien/ctrlp.vim.git'                      				" File Search
	Plug 'dbeecham/ctrlp-commandpalette.vim' 									" Command Palette

"	Plug 'sirver/ultisnips' 													" Snippets
	Plug 'lervag/vimtex' 														" Latex
	Plug 'KeitaNakamura/tex-conceal.vim' 										" More Latex
call plug#end()

lua << EOF
require('neogit').setup {
	disable_commit_confirmation = true,
	integrations = {
		diffview = true
	}
}
EOF

