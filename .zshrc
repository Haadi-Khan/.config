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
alias vimrc="nvim ~/.vim/config/init.vim"
alias ytmp3="youtube-dl --prefer-ffmpeg --extract-audio --audio-format mp3"
cdvi() {                                                                                         
    cd "$1" && nvim .                                                                                    
}      
mkcd () {
  mkdir "$1" && cd "$1"
}

