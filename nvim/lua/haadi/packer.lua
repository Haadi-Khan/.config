-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt` vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use) -- Packer can manage itself
    use('wbthomason/packer.nvim')

    -- UI
    use('navarasu/onedark.nvim')
    use('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' })
    use('freddiehaddad/feline.nvim')

    -- Git
    use('sindrets/diffview.nvim')
    use {
        "NeogitOrg/neogit",
        integrations = {
            diffview = true,
        },
        config = function()
            require('neogit').setup()
        end
    }

    -- Navigation + Undo
    use('mbbill/undotree')

    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.5', -- or , branch = '0.1.x',
        requires = { { 'nvim-lua/plenary.nvim' } }
    }

    use('nvim-tree/nvim-tree.lua')
    use('nvim-tree/nvim-web-devicons')

    use {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup {}
        end
    }

    use {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end
    }


    use {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        requires = {
            { "nvim-lua/plenary.nvim" }
        }
    }

    -- LSP
    use {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',

        requires = {
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },

            -- LSP Support
            { 'neovim/nvim-lspconfig' },

            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'L3MON4D3/LuaSnip' },

        }
    }

    use {
        "folke/trouble.nvim",
        config = function()
            require('trouble').setup()
        end
    }

    use {
        "folke/which-key.nvim",
        config = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
            require("which-key").setup {}
        end
    }
end)
