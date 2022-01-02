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

	" Code Autocomplete and highlighting
	Plug 'neovim/nvim-lspconfig' 								 				" Setup nvim LSP				
	Plug 'hrsh7th/nvim-compe' 								 					" Autocompletion engine			
	Plug 'git@github.com:L3MON4D3/LuaSnip' 										" Snippets Engine
	Plug 'git@github.com:jiangmiao/auto-pairs' 									" Auto Pairs ([], (), {})
	Plug 'git@github.com:sheerun/vim-polyglot'                             		" Syntax Highlight for most languages
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
	  org_indent_mode = indent
	})
EOF

" Auto completion with native LSP
lua << EOF
	vim.o.completeopt = "menuone,noselect"

	require'compe'.setup {
	  enabled = true;
	  autocomplete = true;
	  debug = false;
	  min_length = 1;
	  preselect = 'enable';
	  throttle_time = 80;
	  source_timeout = 200;
	  incomplete_delay = 400;
	  max_abbr_width = 100;
	  max_kind_width = 100;
	  max_menu_width = 100;
	  documentation = false;

	  source = {
		path = true;
		buffer = true;
		calc = true;
		vsnip = true;
		nvim_lsp = true;
		nvim_lua = true;
		spell = true;
		tags = true;
		snippets_nvim = true;
		treesitter = true;
	  };
	}
	local t = function(str)
	  return vim.api.nvim_replace_termcodes(str, true, true, true)
	end

	local check_back_space = function()
		local col = vim.fn.col('.') - 1
		if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
			return true
		else
			return false
		end
	end

	-- Use (s-)tab to:
	--- move to prev/next item in completion menuone
	--- jump to prev/next snippet's placeholder
	_G.tab_complete = function()
	  if vim.fn.pumvisible() == 1 then
		return t "<C-n>"
	  elseif vim.fn.call("vsnip#available", {1}) == 1 then
		return t "<Plug>(vsnip-expand-or-jump)"
	  elseif check_back_space() then
		return t "<Tab>"
	  else
		return vim.fn['compe#complete']()
	  end
	end
	_G.s_tab_complete = function()
	  if vim.fn.pumvisible() == 1 then
		return t "<C-p>"
	  elseif vim.fn.call("vsnip#jumpable", {-1}) == 1 then
		return t "<Plug>(vsnip-jump-prev)"
	  else
		-- If <S-Tab> is not working in your terminal, change it to <C-h>
		return t "<S-Tab>"
	  end
	end

	vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
	vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
	vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
	vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})


	-- Languages: Python, Org
	require'lspconfig'.pyright.setup{}
	-- require'lspconfig'.jdtls.setup{} Will set this up later
	require'compe'.setup({
      source = {
        orgmode = true
      }
    })
EOF
