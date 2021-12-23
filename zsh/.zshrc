# Use powerline
USE_POWERLINE="true"
# Source manjaro-zsh-configuration
if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
  source /usr/share/zsh/manjaro-zsh-config
fi
# Use manjaro zsh prompt
if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
  source /usr/share/zsh/manjaro-zsh-prompt
fi

alias shopt='/usr/bin/shopt'
alias cdoc="cd /run/media/haadi/Storage/Documents"
alias cdwn="cd /run/media/haadi/Storage/Downloads"
alias vi="nvim"
alias vim="nvim"
alias vimrc="nvim ~/.dotfiles/nvim ."
alias i3c="nvim ~/.config/i3/config"
alias ytmp3="youtube-dl --prefer-ffmpeg --extract-audio --audio-format mp3"
alias cdh="cd ~"
alias tmux="tmux -f ~/.dotfiles/tmux/tmux.conf"
hash -d docs=/run/media/haadi/Storage/Documents
hash -d dwn=/run/media/haadi/Storage/Downloads
bindkey -v # Vim Mode for Terminal
vicd() {                                                                                         
    cd "$1" && nvim .                                                                                    
}      
mkcd () {
  mkdir "$1" && cd "$1"
}
