#!/usr/bin/env bash
# Rebuilds the Framework 13 EndeavourOS + Hyprland setup on a fresh install.
#
# Starting point: a fresh EndeavourOS (GNOME edition, systemd-boot) install,
# logged in as your user. Then either:
#
#   curl -fsSL https://raw.githubusercontent.com/Haadi-Khan/.config/framework/install.sh | bash
#
# or, if ~/.config is already the repo:
#
#   ~/.config/install.sh
#
# Safe to re-run: every step checks before it changes anything.
set -euo pipefail

REPO_URL="https://github.com/Haadi-Khan/.config.git"
REPO_SSH="git@github.com:Haadi-Khan/.config.git"
BRANCH="framework"
CONFIG="$HOME/.config"
INSTALL="$CONFIG/install"

step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
info() { printf '    %s\n' "$*"; }
warn() { printf '\033[1;33m    %s\033[0m\n' "$*"; }
ask()  { local r; read -r -p "    $* [y/N] " r </dev/tty; [[ $r == [yY]* ]]; }
pkgs() { sed 's/#.*//' "$1" | awk 'NF{print $1}'; }

[[ $EUID -ne 0 ]] || { echo "Run as your user, not root (sudo is used where needed)."; exit 1; }

sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# --------------------------------------------------------------------------
step "Dotfiles repo in ~/.config"
if git -C "$CONFIG" rev-parse --is-inside-work-tree &>/dev/null; then
    info "already a git repo"
else
    sudo pacman -S --needed --noconfirm git
    mkdir -p "$CONFIG"
    git -C "$CONFIG" init -q -b "$BRANCH"
    git -C "$CONFIG" remote add origin "$REPO_URL"
    git -C "$CONFIG" fetch -q origin "$BRANCH"
    git -C "$CONFIG" checkout -q -f -B "$BRANCH" --track "origin/$BRANCH"
    info "checked out $BRANCH into ~/.config"
fi
# ~/.config is mostly app data; only show files that are explicitly tracked
git -C "$CONFIG" config status.showUntrackedFiles no

# --------------------------------------------------------------------------
step "pacman repos (multilib, Cider)"
if grep -q '^#\[multilib\]' /etc/pacman.conf; then
    sudo sed -i '/^#\[multilib\]/{s/^#//;n;s/^#//}' /etc/pacman.conf
    info "enabled multilib"
fi
if ! grep -q '^\[cidercollective\]' /etc/pacman.conf; then
    curl -fsSL https://repo.cider.sh/ARCH-GPG-KEY | sudo pacman-key --add -
    sudo pacman-key --lsign-key A0CD6B993438E22634450CDD2A236C3F42A61682
    printf '\n[cidercollective]\nSigLevel = Required TrustedOnly\nServer = https://repo.cider.sh/arch\n' \
        | sudo tee -a /etc/pacman.conf >/dev/null
    info "added cidercollective repo"
fi

# --------------------------------------------------------------------------
step "Packages"
sudo pacman -Syu --needed --noconfirm base-devel yay
mapfile -t repo_pkgs < <(pkgs "$INSTALL/pacman.txt")
sudo pacman -S --needed --noconfirm "${repo_pkgs[@]}"
mapfile -t aur_pkgs < <(pkgs "$INSTALL/aur.txt")
yay -S --needed --noconfirm --answerdiff None --answerclean None "${aur_pkgs[@]}"
fc-cache -f >/dev/null

# --------------------------------------------------------------------------
step "System files"
# keyd: caps lock = esc on tap, super on hold; right ctrl = F13 (dictation)
sudo install -Dm644 "$INSTALL/system/etc/keyd/default.conf" /etc/keyd/default.conf
# keyd can segfault on a live reload; make systemd bring it back
sudo install -Dm644 "$INSTALL/system/etc/systemd/system/keyd.service.d/restart.conf" \
    /etc/systemd/system/keyd.service.d/restart.conf
# battery: PCI runtime PM, power-saver on battery / balanced on AC
sudo install -Dm644 -t /etc/udev/rules.d "$INSTALL"/system/etc/udev/rules.d/*.rules
sudo install -Dm755 "$INSTALL/system/usr/local/bin/power-profile-auto" /usr/local/bin/power-profile-auto
sudo install -Dm644 "$INSTALL/system/etc/systemd/system/power-profile-auto.service" \
    /etc/systemd/system/power-profile-auto.service
sudo udevadm control --reload
sudo systemctl daemon-reload

step "System services"
for unit in keyd bluetooth tailscaled power-profiles-daemon power-profile-auto paccache.timer fstrim.timer; do
    sudo systemctl enable --now "$unit" >/dev/null 2>&1 && info "enabled $unit" || warn "could not enable $unit"
done
# restart rather than `keyd reload`, which has crashed keyd here before
sudo systemctl restart keyd 2>/dev/null || true

# --------------------------------------------------------------------------
step "Home files"
cp -rT "$INSTALL/home" "$HOME"
chmod +x "$HOME"/.local/bin/vicinae-*
ln -sfn "$CONFIG/.zshrc" "$HOME/.zshrc"
ln -sfn "$CONFIG/.p10k.zsh" "$HOME/.p10k.zsh"
mkdir -p "$HOME/.vim/undodir"
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

if [[ $(getent passwd "$USER" | cut -d: -f7) != /usr/bin/zsh ]]; then
    sudo chsh -s /usr/bin/zsh "$USER"
    info "default shell is now zsh"
fi

step "User services"
# gcr SSH agent (SSH_AUTH_SOCK is set in hypr/modules/env.lua); polkit agent
# is also started from hypr autostart since there is no graphical-session.target
systemctl --user enable gcr-ssh-agent.socket hyprpolkitagent.service >/dev/null 2>&1 \
    || warn "could not enable user services (run again from a graphical session)"

step "Dictation (voxtype + local LLM cleanup)"
# Hold Right Ctrl to dictate, double-tap to lock. Pieces: keyd (Right Ctrl -> F13),
# hypr/modules/keybinds.lua -> voxtype/ptt.sh, voxtype/config.toml (Parakeet,
# types via wtype), voxtype/cleanup.py -> llama-cleanup.service, quickshell/Dictation.qml.
# voxtype/screen_context.py OCRs the focused window on key press so cleanup can
# spell on-screen terms (file names, identifiers) correctly.
if [[ $(readlink -f /usr/bin/voxtype) != *voxtype-onnx* ]]; then
    sudo voxtype setup onnx --enable    # Parakeet needs the ONNX build
fi
# int8 Parakeet (~2x faster on CPU). voxtype's own server 403s on it, so pull from HF.
parakeet="$HOME/.local/share/voxtype/models/parakeet-tdt-0.6b-v3-int8"
if [[ ! -f $parakeet/encoder-model.int8.onnx ]]; then
    mkdir -p "$parakeet"
    for f in encoder-model.int8.onnx decoder_joint-model.int8.onnx config.json vocab.txt; do
        curl -fL --retry 3 -o "$parakeet/$f.part" \
            "https://huggingface.co/istupakov/parakeet-tdt-0.6b-v3-onnx/resolve/main/$f" \
            && mv "$parakeet/$f.part" "$parakeet/$f" \
            || warn "Parakeet download failed ($f); rerun install.sh"
    done
fi
cleanup_model="$HOME/.local/share/models/Qwen3-4B-Instruct-2507-Q4_K_M.gguf"
if [[ ! -f $cleanup_model ]]; then
    mkdir -p "${cleanup_model%/*}"
    curl -fL --retry 3 -o "$cleanup_model.part" \
        https://huggingface.co/unsloth/Qwen3-4B-Instruct-2507-GGUF/resolve/main/Qwen3-4B-Instruct-2507-Q4_K_M.gguf \
        && mv "$cleanup_model.part" "$cleanup_model" \
        || warn "cleanup model download failed (dictation still works, just uncleaned)"
fi
systemctl --user enable llama-cleanup.service voxtype.service >/dev/null 2>&1 \
    || warn "could not enable llama-cleanup/voxtype (run again from a graphical session)"

# --------------------------------------------------------------------------
step "Toolchains"
if [[ ! -x $HOME/.cargo/bin/rustup ]]; then
    # .zshrc already sources ~/.cargo/env
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
fi
if [[ ! -x $HOME/.local/bin/uv ]]; then
    curl -LsSf https://astral.sh/uv/install.sh | env UV_NO_MODIFY_PATH=1 sh
fi
"$HOME/.local/bin/uv" tool install ty >/dev/null 2>&1 || true    # Python LSP for Doom
if [[ ! -e $HOME/.local/bin/claude ]]; then
    curl -fsSL https://claude.ai/install.sh | bash
fi
# Doom's stylesheet/JS formatters
npm ls -g stylelint js-beautify >/dev/null 2>&1 || sudo npm install -g stylelint js-beautify

# --------------------------------------------------------------------------
step "Neovim plugins"
packer="$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"
[[ -d $packer ]] || git clone -q --depth 1 https://github.com/wbthomason/packer.nvim "$packer"
# Load only the plugin list: the full config errors until the plugins exist
timeout 600 nvim --headless -u NONE \
    --cmd "set rtp+=$CONFIG/nvim packpath+=$HOME/.local/share/nvim/site" \
    -c 'packadd packer.nvim' -c 'lua require("haadi.packer")' \
    -c 'autocmd User PackerComplete quitall' -c 'PackerSync' >/dev/null 2>&1 \
    || warn "PackerSync didn't finish; run :PackerSync in nvim"
timeout 300 nvim --headless -c 'TSUpdateSync' -c 'qa!' >/dev/null 2>&1 || true
info "Mason installs the language servers on first launch"

step "Doom Emacs"
if [[ ! -d $CONFIG/emacs ]]; then
    git clone -q --depth 1 https://github.com/doomemacs/doomemacs "$CONFIG/emacs"
    "$CONFIG/emacs/bin/doom" install --force --no-config </dev/null
fi
# stdin closed: doom sync otherwise hangs asking to restart a running daemon
"$CONFIG/emacs/bin/doom" sync </dev/null

step "tmux plugins"
tpm="$CONFIG/tmux/plugins/tpm"
[[ -d $tpm ]] || git clone -q --depth 1 https://github.com/tmux-plugins/tpm "$tpm"
"$tpm/bin/install_plugins" >/dev/null || warn "tpm install failed; press prefix + I inside tmux"

# --------------------------------------------------------------------------
step "Interactive steps"
if [[ ! -f $HOME/.ssh/id_ed25519 ]] && ask "Generate an SSH key?"; then
    ssh-keygen -t ed25519 -C "haadikhan05@gmail.com" -f "$HOME/.ssh/id_ed25519" </dev/tty
fi
if ! gh auth status >/dev/null 2>&1 && ask "Log in to GitHub (gh auth login)?"; then
    gh auth login </dev/tty
fi
if [[ $(git -C "$CONFIG" remote get-url origin) == "$REPO_URL" && -f $HOME/.ssh/id_ed25519 ]]; then
    git -C "$CONFIG" remote set-url origin "$REPO_SSH"
    info "repo remote switched to SSH"
fi
if ! tailscale status >/dev/null 2>&1 && ask "Log in to Tailscale?"; then
    sudo tailscale up
fi
if ! fprintd-list "$USER" 2>/dev/null | grep -q ' - #' && ask "Enroll a fingerprint (for hyprlock)?"; then
    # run as root so sudo handles auth; no polkit agent outside Hyprland
    sudo fprintd-enroll "$USER" </dev/tty
fi
if ! efibootmgr 2>/dev/null | grep -q rEFInd && ask "Install the One Dark rEFInd boot menu?"; then
    sudo "$INSTALL/refind-onedark/install.sh"
fi
if ask "Check for firmware updates (fwupd)?"; then
    fwupdmgr refresh --force >/dev/null 2>&1 || true
    fwupdmgr update </dev/tty || true
fi

# --------------------------------------------------------------------------
step "Done. Left to do by hand:"
cat <<'EOF'
    - Log out, pick Hyprland in GDM, and log in with your password (this unlocks
      the keyring; fingerprint works on the hyprlock lock screen, Super+Esc).
    - Cider: Settings > Visual > Custom CSS, paste
      ~/.config/sh.cider.genten/themes/one-dark.css; set the font to
      "Recursive Sans Linear Static"; turn off the tray icon.
    - Mailspring: Preferences > Appearance > "One Dark"; turn off the tray icon.
    - Beeper: command bar > "Reload custom CSS".
    - Calibre: Preferences > Look & feel > Customize colors > Import
      ~/one-dark.calibre-palette, with the palette set to Dark.
    - Vimium: Options > Backup and Restore > Restore ~/.config/vimium/vimium-options.json.
    - BIOS: optionally set an 80% charge limit.
EOF
