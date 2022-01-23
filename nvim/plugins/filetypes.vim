" Run Java Code
autocmd Filetype java set makeprg=javac\ %
set errorformat=%A%f:%l:\ %m,%-Z%p^,%-C%.%#
map <F9> :make<Return>:copen<Return>
map <F10> :cprevious<Return>
map <F11> :cnext<Return>
autocmd FileType java map <buffer> <F5> :w<CR>:exec '!java' shellescape(@%, 1)<CR>
autocmd FileType java imap <buffer> <F5> <esc>:w<CR>:exec '!java' shellescape(@%, 1)<CR> 

" Run Python Code
autocmd FileType python map <buffer> <F5> :w<CR>:exec '!python3' shellescape(@%, 1)<CR>
autocmd FileType python imap <buffer> <F5> <esc>:w<CR>:exec '!python3' shellescape(@%, 1)<CR> 


" Config for Text and Markdown Files
autocmd BufRead,BufNewFile *.md call SetTextFileOptions()
autocmd BufRead,BufNewFile *.txt call SetTextFileOptions()
autocmd BufRead,BufNewFile *.org call SetOrgFileOptions()

function SetTextFileOptions()
	setlocal wrap
	setlocal linebreak
	setlocal spell
	setlocal colorcolumn=500
endfunction

function SetOrgFileOptions()
	setlocal spell
	setlocal colorcolumn=500
endfunction

