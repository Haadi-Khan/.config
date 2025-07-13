# Use powerline
USE_POWERLINE="true"

setopt autocd
autoload -U colors && colors
PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "

EDITOR=nvim

# History in cache directory:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/zshhistory
setopt appendhistory

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)               # Include hidden files.

# Custom ZSH Binds
bindkey '^ ' autosuggest-accept
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
source /usr/share/autojump/autojump.zsh 2>/dev/null

alias blf="hyprshade on blue-light-filter"
alias blo="hyprshade off"
alias vi="nvim"
alias vim="nvim"
alias vimrc="nvim ~/.config/nvim/ ."
alias tmux="tmux -f ~/.dotfiles/tmux/tmux.conf"
alias gp="git add --all && git commit -m \"Commit\" && git push"
alias tty-clock="tty-clock -s -x -C 6 -t"
alias remacs="killall emacs && /usr/bin/emacs --daemon &"
alias ls="eza --icons"
alias la="eza -a --icons"
alias pdf="sioyek --enable-features=UseOzonePlatform --ozone-platform=wayland "
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gs="git status"
alias gch="git checkout"
alias gcm="git checkout main"
alias touchpad_fix="sudo titdb -d /dev/input/event2 -m f"
alias ff="fastfetch"
vicd() {
    cd "$1" && nvim .
}
mkcd () {
  mkdir "$1" && cd "$1"
}
alias code="/usr/bin/code --ozone-platform=wayland"
