# Use powerline
USE_POWERLINE="true"
autoload -U colors && colors
PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "

export EDITOR=nvim
# export EDITOR='emacsclient -c -a \"Emacs\"'

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

# Quality of life rebinds
alias ls="exa -a" # Superior ls prompt
alias grep="rg" # Use ripgrep always instead of grep
alias mk="mkdir"

# CDs and links to frequent locations
alias cdoc="cd /run/media/haadi/Storage/Documents"
alias cdp="cd /run/media/haadi/Storage/Documents/Programs"
alias cdwn="cd /run/media/haadi/Storage/Downloads"
hash -d docs=/run/media/haadi/Storage/Documents
hash -d dwn=/run/media/haadi/Storage/Downloads

# Quality of Life aliases
alias vi="nvim"
alias vim="nvim"
alias em="emacsclient -c -a \"Emacs\""
alias remacs="killall emacs && /usr/bin/emacs --daemon &"

# Config file Binds
alias vimrc="nvim ~/.config/nvim/ ."
alias i3c="emacs ~/.config/i3/config"

# Random stuff to be lazy
alias ytmp3="youtube-dl --prefer-ffmpeg --extract-audio --audio-format mp3"
alias btop="btop --utf-force"
alias tmux="tmux -f ~/.dotfiles/tmux/tmux.conf"
alias gp="git add --all && git commit -m \"Commit\" && git push"

# Misc.
alias ml="jupyter lab --no-browser"
alias tty-clock="tty-clock -s -x -C 6 -t"
eval $(thefuck --alias)

# CD into a directory and open vim
vicd() {
    cd "$1" && nvim .
}

# Make a new directory and cd into it
mkcd () {
  mkdir "$1" && cd "$1"
}

# Macro to find files of the same extension type
finext() {
    find . -type f -name "*.$1"
}

# Macro to make compiling c++ code easier
gcomp() {
    g++ -g $(find ./src -type f -iregex ".*\.cpp") -o ./bin/"$1"
}
# Simple Timer
timer() {
    start="$(( $(date '+%s') + $1))"
    while [ $start -ge $(date +%s) ]; do
        time="$(( $start - $(date +%s) ))"
        printf '%s\r' "$(date -u -d "@$time" +%H:%M:%S)"
        sleep 0.1
    done
}

# Flutter Crap
unset JAVA_OPTS
#export JAVA_OPTS='-XX:+IgnoreUnrecognizedVMOptions --add-modules java.se.ee'
#export JAVA_HOME='/usr/lib/jvm/java-8-openjdk'
export ANDROID_HOME="/opt/android-sdk"
export ANDROID_SDK_ROOT=$ANDROID_HOME
#export PATH=$PATH:$ANDROID_HOME/emulator
#export PATH=$PATH:$ANDROID_HOME/platform-tools/
#export PATH=$PATH:$ANDROID_HOME/tools/bin/
#export PATH=$PATH:$ANDROID_HOME/tools/
#export PATH=$ANDROID_HOME/emulator:$PATH
export PATH="/home/haadi/.flutter/flutter/bin:$PATH"
