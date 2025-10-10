vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover info" })
-- opts
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.undofile = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2 -- set to 0 to default to tabstop value
vim.opt.shellslash = true

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
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local telescope = require("telescope")
            local actions = require("telescope.actions")

            telescope.setup({
                defaults = {
                    prompt_prefix = " ",
                    selection_caret = " ",
                    -- normalize backslashes for display
                    path_display = function(_, path)
                        return path:gsub("\\", "/")
                    end,
                    mappings = {
                        i = {
                            ["<Esc>"] = actions.close,
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-k>"] = actions.move_selection_previous,
                        },
                    },
                },
                pickers = {
                    find_files = {
                        find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*", "--path-separator", "/" },
                    },
                    buffers = {
                        -- normalize buffer names
                        path_display = function(_, path)
                            return path:gsub("\\", "/")
                        end,
                    },
                },
            })
        end,
        keys = {
            { "<Leader>f", "<Cmd>Telescope find_files<CR>", desc = "Find files" },
            { "<Leader>g", "<Cmd>Telescope live_grep<CR>",  desc = "Live grep" },
            { "<Leader>b", "<Cmd>Telescope buffers<CR>",    desc = "List buffers" },
            { "<Leader>h", "<Cmd>Telescope help_tags<CR>",  desc = "Help tags" },
        },
    },
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function() require("nvim-autopairs").setup() end,
    },
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
                ensure_installed = { "pyright", "rust_analyzer", "lua_ls", "ts_ls", "html", "cssls", "tailwindcss" },
            })

            local servers = { "pyright", "rust_analyzer", "lua_ls", "ts_ls", "html", "cssls", "tailwindcss" }
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
    {
        "akinsho/bufferline.nvim",
        version = "*",
        dependencies = "nvim-tree/nvim-web-devicons",
        config = function()
            require("bufferline").setup({
                options = {
                    -- Example options:
                    mode = "tabs",            -- or "buffers"
                    separator_style = "thin", -- "slant", "padded_slant", "thin", etc.
                    diagnostics = "nvim_lsp", -- show LSP diagnostics in bufferline
                    show_buffer_close_icons = false,
                    show_close_icon = false,
                    always_show_bufferline = true,
                },
            })
        end,
    },
    {
        "iamcco/markdown-preview.nvim",
        ft = { "markdown" },             -- load only for markdown files
        build = "cd app && npm install", -- install dependencies
        init = function()
            vim.g.mkdp_auto_start = 0    -- don't auto-start preview
            vim.g.mkdp_auto_close = 1    -- auto close preview when buffer is closed
            vim.g.mkdp_refresh_slow = 0
            vim.g.mkdp_browser = ""      -- leave empty to use system default
            vim.g.mkdp_theme = "dark"    -- can be "dark" or "light"
        end,
        keys = {
            { "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", desc = "Toggle Markdown Preview" },
        },
    },
})
vim.cmd("hi StatusLine guibg=NONE")
vim.keymap.set("n", "<leader>nt", "<cmd>tabnew<CR>", { desc = "New tab/buffer" })
vim.keymap.set("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", { silent = true })
vim.keymap.set("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { silent = true })
vim.keymap.set("n", "<leader>rt", "<cmd>bdelete<CR>", { desc = "Close current buffer" })
vim.keymap.set("n", "<leader>rs", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
vim.keymap.set("n", "<leader>fw", "*N", { desc = "Find word under cursor" })
vim.keymap.set('n', '<leader>.', vim.lsp.buf.code_action, { noremap = true, silent = true })
