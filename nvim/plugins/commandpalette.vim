nnoremap <C-[> :CtrlPCommandPalette<cr>

function GradleBuild()
    exec '!./gradlew build'
endfunction

function GradleDeploy()
    exec '!./gradlew deploy'
endfunction

function NewSubsystem()
	exec '0r ~/.config/nvim/templates/frc/Subsystem.java'
endfunction

function NewCommand()
	exec '0r ~/.config/nvim/templates/frc/Command.java'
endfunction

function ParDeadGroup()
	exec '0r ~/.config/nvim/templates/frc/ParallelDeadlineGroup.java'
endfunction
function ParCmdGroup()
	exec '0r ~/.config/nvim/templates/frc/ParallelCommandGroup.java'
endfunction
function ParRaceGroup()
	exec '0r ~/.config/nvim/templates/frc/ParallelRaceGroup.java'
endfunction
function SeqCmdGroup()
	exec '0r ~/.config/nvim/templates/frc/SequentialCommandGroup.java'
endfunction

let g:commandPalette = {
    \ 'Ignorecase: Toggle': 'set ignorecase!',
    \ 'File: save and close': 'wc',
    \ 'WPILib: Build Robot Code': 'call GradleBuild()',
    \ 'WPILib: Deploy Robot Code': 'call GradleDeploy()',
    \ 'WPILib: New Subsystem': 'call NewSubsystem()',
    \ 'WPILib: New Command': 'call NewCommand()',
    \ 'WPILib: New ParallelDeadlineGroup': 'call ParDeadGroup()',
    \ 'WPILib: New ParallelCommandGroup': 'call ParCmdGroup()',
    \ 'WPILib: New ParallelRaceGroup': 'call ParRaceGroup()',
    \ 'WPILib: New SequentialComandGroup': 'call SeqCmdGroup()',
	\ 'Open Magit': ':Neogit'}
