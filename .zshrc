# Use powerline
USE_POWERLINE="true"

alias cdoc="cd /run/media/haadi/Storage/Documents"
alias cdwn="cd /run/media/haadi/Storage/Downloads"
alias vi="nvim"
alias vim="nvim"
alias vimrc="nvim ~/.dotfiles/nvim ."
alias i3c="nvim ~/.config/i3/config"
alias ytmp3="youtube-dl --prefer-ffmpeg --extract-audio --audio-format mp3"
alias cdh="cd ~"
alias tmux="tmux -f ~/.dotfiles/tmux/tmux.conf"
alias blc="./~/Applications/BadlionClient_2b786aee9df7ac8ea9752d318ea76329"
hash -d docs=/run/media/haadi/Storage/Documents
hash -d dwn=/run/media/haadi/Storage/Downloads
vicd() {                                                                                         
    cd "$1" && nvim .                                                                                    
}      
mkcd () {
  mkdir "$1" && cd "$1"
}
