nnoremap <C-[> :CtrlPCommandPalette<cr>

function GradleBuild()
    exec '!./gradlew build'
endfunction

function GradleDeploy()
    exec '!./gradlew deploy'
endfunction


let g:commandPalette = {
    \ 'Ignorecase: Toggle': 'set ignorecase!',
    \ 'File: save and close': 'wc',
    \ 'WPILib: Build Robot Code': 'call GradleBuild()',
    \ 'WPILib: Deploy Robot Code': 'call GradleDeploy()'}

