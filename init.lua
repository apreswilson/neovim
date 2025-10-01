-- opts
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.undofile = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 0 -- set to 0 to default to tabstop value

vim.g.mapleader = " "

--require("config.lazy")
---- Visit the project page for the latest installation instructions
-- https://github.com/folke/lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
      {    "vague2k/vague.nvim",
    lazy = false,  -- Ensure it's loaded during startup if it's your main colorscheme
    priority = 1000,  -- Load before other plugins
    config = function()
      require("vague").setup({
        -- Optional configuration here
      })
      vim.cmd("colorscheme vague")
    end
  },

      {
        "stevearc/oil.nvim",
        opts = {},
        keys = {
            { "<Leader>e", "<Cmd>Oil<CR>", desc = "Open Oil file explorer" },
    },
    },
        {
        "echasnovski/mini.pick",
        config = function()
            require("mini.pick").setup({
                -- Optional: customize behavior
                prompt = "Pick> ",
                search_prompt = "Search> ",
                mapping = {
                    close = "q",
                    confirm = "<CR>",
                },
            })
        end,
        keys = {
            { "<Leader>p", function() vim.cmd("Pick files") end, desc = "Pick files" },
        },
    },
        {
        "https://github.com/windwp/nvim-autopairs",
        event = "InsertEnter", -- Only load when you enter Insert mode
        config = function()
            require("nvim-autopairs").setup()
        end,
    },
        {
        "https://github.com/tpope/vim-sleuth",
        event = { "BufReadPost", "BufNewFile" }, -- Load after your file content
    },
        {
        "https://github.com/VonHeikemen/lsp-zero.nvim",
        dependencies = {
            "https://github.com/williamboman/mason.nvim",
            "https://github.com/williamboman/mason-lspconfig.nvim",
            "https://github.com/neovim/nvim-lspconfig",
            "https://github.com/hrsh7th/cmp-nvim-lsp",
            "https://github.com/hrsh7th/nvim-cmp",
            "https://github.com/L3MON4D3/LuaSnip",
        },
        config = function()
            local lsp_zero = require('lsp-zero')

            lsp_zero.on_attach(function(client, bufnr)
                lsp_zero.default_keymaps({buffer = bufnr})
            end)

            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    -- See https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
                    "pyright", -- Python
                    "rust_analyzer", -- Rust
                    "lua_ls",

                },
                handlers = {
                    lsp_zero.default_setup,
                },
            })
        end,
    },
    
    -- nvim-ts-autotag for HTML/JSX/TSX
    {
        "windwp/nvim-ts-autotag",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "html", "javascript", "typescript", "tsx" },
                highlight = { enable = true },
            })

            require("nvim-ts-autotag").setup({
                opts = {
                    enable_close = true,
                    enable_rename = true,
                    enable_close_on_slash = false,
                },
                per_filetype = {
                    ["html"] = { enable_close = true },
                    ["javascriptreact"] = { enable_close = true },
                    ["typescriptreact"] = { enable_close = true },
                },
            })
        end,
    },

})

vim.cmd("hi StatusLine guibg=NONE")
