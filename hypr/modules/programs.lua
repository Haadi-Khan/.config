---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use
return {
    terminal    = "ghostty",
    fileManager = "files",
    browser     = "zen-browser",
    menu        = "vicinae toggle",
    -- Region shot opens satty for markup: Enter copies + closes, Ctrl+S saves, Esc cancels
    sshot       = "hyprshot -m region --raw | satty --filename - --copy-command wl-copy --early-exit --actions-on-enter save-to-clipboard --output-filename ~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png",
    sshotFull   = "hyprshot -m output -m active --clipboard-only",
    scratch     = [[emacsclient -c -F '((name . "emacs-scratch"))' -a "" -e '(doom/switch-to-scratch-buffer)']],
    clipboard   = "vicinae cmd launch clipboard:history",
    colorPicker = "hyprpicker -a",  -- copies the hex value to the clipboard
}
