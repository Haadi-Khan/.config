local wk = require("which-key")

wk.add({
    { "<leader>u", vim.cmd.UndotreeToggle, desc = "Undo Tree", mode = "n" }
})
