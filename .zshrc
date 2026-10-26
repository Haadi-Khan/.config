# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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

alias vi="nvim"
alias vim="nvim"
alias vimrc="nvim ~/.config/nvim/ ."
# alias tmux="tmux -f ~/.dotfiles/tmux/tmux.conf"  # not needed: tmux reads ~/.config/tmux/tmux.conf
alias gp="git add --all && git commit -m \"Commit\" && git push"
alias tty-clock="tty-clock -s -x -C 6 -t"
alias remacs="killall emacs && /usr/bin/emacs --daemon &"
alias ls="eza --icons=auto"
alias la="eza -a --icons=auto"
alias pdf="sioyek --enable-features=UseOzonePlatform --ozone-platform=wayland "
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gs="git status"
alias gch="git checkout"
alias gcm="git checkout main"
alias ff="fastfetch"
vicd() {
    cd "$1" && nvim .
}
mkcd () {
  mkdir "$1" && cd "$1"
}
alias code="/usr/bin/code --ozone-platform=wayland"

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.config/emacs/bin:$PATH"
. "$HOME/.cargo/env"

source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
