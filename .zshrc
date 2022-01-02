# Use powerline
USE_POWERLINE="true"

autoload -U colors && colors
PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "

EDITOR=vim

# History in cache directory:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zshhistory
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

alias cdoc="cd /run/media/haadi/Storage/Documents"
alias cdwn="cd /run/media/haadi/Storage/Downloads"
alias vi="nvim"
alias vim="nvim"
alias vimrc="nvim ~/.config/nvim/ ."
alias i3c="nvim ~/.config/i3/config"
alias ytmp3="youtube-dl --prefer-ffmpeg --extract-audio --audio-format mp3"
alias cdh="cd ~"
alias btop="btop --utf-force"
alias tmux="tmux -f ~/.dotfiles/tmux/tmux.conf"
alias blc="cd ~/Applications && ./BadlionClient_2b786aee9df7ac8ea9752d318ea76329"
alias td="cd ~docs/org/ && nvim todolist.org"
hash -d docs=/run/media/haadi/Storage/Documents
hash -d dwn=/run/media/haadi/Storage/Downloads
vicd() {
    cd "$1" && nvim .
}
mkcd () {
  mkdir "$1" && cd "$1"
}

