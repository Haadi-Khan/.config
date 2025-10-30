local wk = require("which-key")
local telescope = require('telescope.builtin')

-- local copilot_on = true
--
-- 	if copilot_on then
-- 		vim.cmd("Copilot disable")
-- 		print("Copilot OFF")
-- 	else
-- 		vim.cmd("Copilot enable")
-- 		print("Copilot ON")
-- 	end
-- 	copilot_on = not copilot_on

wk.add({
    -- General
    { '<leader>.',  telescope.find_files,                                                       desc = "Find File",         mode = "n" },
    { '<leader>/',  function() telescope.grep_string({ search = vim.fn.input("Grep > ") }) end, desc = "Search Project",    mode = "n" },
    { '<leader> ',  telescope.git_files,                                                        desc = "Find Project File", mode = "n" },
    { '<leader>,',  telescope.buffers,                                                          desc = "List Buffers",      mode = "n" },
    { "<leader>x",  function() vim.cmd.enew() end,                                              desc = "Scratch Buffer",    mode = "n" },


    -- File Group
    { "<leader>f",  group = "file" },
    { "<leader>ff", telescope.find_files,                                                       desc = "Find File",         mode = "n" },
    { "<leader>fn", desc = "New File" },
    { "<leader>fs", vim.cmd.w,                                                                  desc = "Save File",         mode = "n" },


    -- Buffers
    { "<leader>b",  group = "buffers" },
    { "<leader>bd", function() vim.cmd.bn() vim.cmd.bd("#") end,                                                                 desc = "Delete Buffer",     mode = "n" },
    { "<leader>bp", vim.cmd.bp,                                                                 desc = "Previous Buffer",   mode = "n" },
    { "<leader>bn", vim.cmd.bn,                                                                 desc = "Next Buffer",       mode = "n" },
    { "<leader>bk", vim.cmd.bwipeout,                                                           desc = "Kill All Buffers",  mode = "n" },
    { '<leader>bb', telescope.buffers,                                                          desc = "List Buffers",      mode = "n" },


    -- Windows
    { "<leader>w",  proxy = "<c-w>",                                                            group = "windows" },
    { "<leader>wh", "<C-w>h",                                                                   desc = "Move Left",         mode = "n" },
    { "<leader>wj", "<C-w>j",                                                                   desc = "Move Left",         mode = "n" },
    { "<leader>wk", "<C-w>k",                                                                   desc = "Move Left",         mode = "n" },
    { "<leader>wl", "<C-w>l",                                                                   desc = "Move Left",         mode = "n" },
    { "<leader>wH", "<C-w>H",                                                                   desc = "Move Window Left",  mode = "n" },
    { "<leader>wJ", "<C-w>J",                                                                   desc = "Move Window Left",  mode = "n" },
    { "<leader>wK", "<C-w>K",                                                                   desc = "Move Window Left",  mode = "n" },
    { "<leader>wL", "<C-w>L",                                                                   desc = "Move Window Left",  mode = "n" },
    { "<leader>ws", "<C-w>s",                                                                   desc = "Split Vertical",    mode = "n" },
    { "<leader>wv", "<C-w>v",                                                                   desc = "Split Horizontal",  mode = "n" },
    { "<leader>wd", "<C-w>q",                                                                   desc = "Kill Window",       mode = "n" },
    { "<leader>w>", "<C-w>>",                                                                   desc = "Grow Window Left",  mode = "n" },
    { "<leader>w<", "<C-w><",                                                                   desc = "Grow Window Right", mode = "n" },


    -- Project
    { "<leader>p",  group = "project" },
    { '<leader>pf', telescope.git_files,                                                        desc = "Find Project File", mode = "n" },
    { '<leader>ps', function() telescope.grep_string({ search = vim.fn.input("Grep > ") }) end, desc = "Search Project",    mode = "n" },

    -- Code
    { "<leader>c",  group = "code" },
    -- { '<leader>cg', function(),                                                        desc = "Find Project File", mode = "n" },

    -- Git
    { "<leader>g",  group = "git" },
    { "<leader>gg", vim.cmd.Neogit,                                                             desc = "Git Status",        mode = "n" },


    -- Open
    { "<leader>o",  group = "open" },


    {
        -- Nested mappings are allowed and can be added in any order
        -- Most attributes can be inherited or overridden on any level
        -- There's no limit to the depth of nesting
        mode = { "n", "v" },                      -- NORMAL and VISUAL mode
        { "<leader>q", "<cmd>q<cr>", desc = "Quit" }, -- no need to specify mode since it's inherited
    }
})
