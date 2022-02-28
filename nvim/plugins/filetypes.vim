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


augroup latex
	let g:UltiSnipsExpandTrigger = '<tab>'
	let g:UltiSnipsJumpForwardTrigger = '<tab>'
	let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'
	let g:tex_flavor='latex'
	let g:vimtex_view_method='zathura'
	let g:vimtex_quickfix_mode=0
	set conceallevel=1
	let g:tex_conceal='abdmg'
	hi Conceal ctermbg=none

	autocmd BufRead, BufNewFile .tex inoremap <C-l> <c-g>u<Esc>[s1z=`]a<c-g>u
augroup END
