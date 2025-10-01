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
    {
        "vague2k/vague.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("vague").setup({})
            vim.cmd("colorscheme vague")
        end,
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
                prompt = "Pick> ",
                search_prompt = "Search> ",
                mapping = { close = "q", confirm = "<CR>" },
            })
        end,
        keys = {
            { "<Leader>p", function() vim.cmd("Pick files") end, desc = "Pick files" },
        },
    },
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function() require("nvim-autopairs").setup() end,
    },
    { "tpope/vim-sleuth", event = { "BufReadPost", "BufNewFile" } },
    {
        "VonHeikemen/lsp-zero.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "neovim/nvim-lspconfig",
            "hrsh7th/nvim-cmp",
            "hrsh7th/cmp-nvim-lsp",
            "L3MON4D3/LuaSnip",
        },
        config = function()
            local cmp = require("cmp")
            local cmp_nvim_lsp = require("cmp_nvim_lsp")
            local luasnip = require("luasnip")

            local capabilities = vim.tbl_extend(
                "force",
                vim.lsp.protocol.make_client_capabilities(),
                cmp_nvim_lsp.default_capabilities()
            )

            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(event)
                    local opts = { buffer = event.buf }
                    local keymaps = { K = vim.lsp.buf.hover, gd = vim.lsp.buf.definition, gr = vim.lsp.buf.references }
                    for k, v in pairs(keymaps) do
                        vim.keymap.set("n", k, v, opts)
                    end
                end,
            })

            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = { "pyright", "rust_analyzer", "lua_ls", "ts_ls", "html" },
            })

            local servers = { "pyright", "rust_analyzer", "lua_ls", "ts_ls", "html" }
            for _, server in ipairs(servers) do
                vim.lsp.config(server, { capabilities = capabilities })
                vim.lsp.enable(server)
            end

            cmp.setup({
                snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
                mapping = {
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                },
                sources = cmp.config.sources({ { name = "nvim_lsp" }, { name = "luasnip" } }, { { name = "buffer" } }),
                completion = { autocomplete = { require("cmp.types").cmp.TriggerEvent.TextChanged } },
            })
        end,
    },
    {
        "windwp/nvim-ts-autotag",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "html", "javascript", "typescript", "tsx" },
                highlight = { enable = true },
            })
            require("nvim-ts-autotag").setup({
                opts = { enable_close = true, enable_rename = true, enable_close_on_slash = false },
                per_filetype = {
                    html = { enable_close = true },
                    javascriptreact = { enable_close = true },
                    typescriptreact = { enable_close = true },
                },
            })
        end,
    },
    -- conform.nvim for autoformat on save
    {
        "stevearc/conform.nvim",
        config = function()
            require("conform").setup({
                format_on_save = {
                    timeout_ms = 500,
                    lsp_format = "fallback",
                },
            })
        end,
        event = { "BufReadPost", "BufNewFile" },
    },
})
vim.cmd("hi StatusLine guibg=NONE")
