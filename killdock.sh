!#bin/sh


# if you want to restore the dock, here's the command
# defaults delete com.apple.dock autohide-delay; killall Dock

defaults write com.apple.dock autohide -bool true && killall Dock                     ─╯
defaults write com.apple.dock autohide-delay -float 1000 && killall Dock
defaults write com.apple.dock no-bouncing -bool TRUE && killall Dock
