" Config for Text and Markdown Files
autocmd BufRead,BufNewFile *.md call SetTextFileOptions()
autocmd BufRead,BufNewFile *.txt call SetTextFileOptions()
autocmd BufRead,BufNewFile *.org call SetTextFileOptions()

function SetTextFileOptions()
	setlocal wrap
	setlocal linebreak
	setlocal spell
	setlocal colorcolumn=500
endfunction

