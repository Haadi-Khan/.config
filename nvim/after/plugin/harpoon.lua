local harpoon = require("harpoon")
local wk = require("which-key")
local telescope = require('telescope.builtin')
harpoon:setup()

wk.add({

    { "<leader>a",  function() harpoon:list():add() end,                         desc = "Add to Harpoon",      mode = "n" },

    { "<leader>j",  group = "harpoon" },
    { "<leader>ja", function() harpoon:list():select(1) end,                     desc = "Harpoon 1",           mode = "n" },
    { "<leader>js", function() harpoon:list():select(2) end,                     desc = "Harpoon 2",           mode = "n" },
    { "<leader>jd", function() harpoon:list():select(3) end,                     desc = "Harpoon 3",           mode = "n" },
    { "<leader>jf", function() harpoon:list():select(4) end,                     desc = "Harpoon 4",           mode = "n" },

    { "<leader>jm", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, desc = "Harpoon Menu",        mode = "n" },
    { "<leader>jP", function() harpoon:list():prev() end,                        desc = "Harpoon Swap Previous", mode = "n" },
    { "<leader>jF", function() harpoon:list():next() end,                        desc = "Harpoon Swap Next",   mode = "n" },

})
