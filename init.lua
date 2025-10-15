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
    opts = {
      view_options = {
        show_hidden = true, -- show dotfiles
        is_always_hidden = function(name, _)
          -- hide the .git directory only
          return name == ".git"
        end,
      },
    },
    keys = {
      { "<Leader>e", "<Cmd>Oil<CR>", desc = "Open Oil file explorer" },
    },
  },
{
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local fzf = require("fzf-lua")

    fzf.setup({
      winopts = {
        height = 0.85,
        width = 0.80,
        row = 0.35,
        col = 0.50,
        border = "rounded",
        preview = {
          layout = "horizontal",     -- 👈 preview on the right (Telescope-like)
          horizontal = "right:50%",  -- preview takes 50% of width
          flip_columns = 120,        -- auto-flip to vertical if window too narrow
        },
      },

      files = {
        prompt = "  Files❯ ",
        cmd = table.concat({
          "fd",
          "--type", "f",
          "--hidden",
          "--follow",
          "--strip-cwd-prefix",
          "--exclude", ".git",
          "--exclude", "node_modules",
          "--exclude", "dist",
          "--exclude", "build",
          "--exclude", ".svn"
        }, " "),
        git_icons = false,
        file_icons = true,
        color_icons = true,
      },

      grep = {
        prompt = "  Grep❯ ",
        rg_opts = table.concat({
          "--column",
          "--line-number",
          "--no-heading",
          "--color=always",
          "--smart-case",
          "--hidden",
          "--glob", "!.git/*",
          "--glob", "!node_modules/*",
          "--glob", "!dist/*",
          "--glob", "!build/*",
          "--glob", "!.svn/*",
        }, " "),
      },

      buffers = {
        prompt = "﬘  Buffers❯ ",
        sort_mru = true,
        ignore_current_buffer = true,
      },

      help_tags = { prompt = "  Help❯ " },
    })

    -- 🔑 Keymaps (same as before)
    vim.keymap.set("n", "<Leader>f", fzf.files, { desc = "Find files" })
    vim.keymap.set("n", "<Leader>g", fzf.live_grep, { desc = "Live grep" })
    vim.keymap.set("n", "<Leader>b", fzf.buffers, { desc = "List buffers" })
    vim.keymap.set("n", "<Leader>h", fzf.help_tags, { desc = "Help tags" })
  end,
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
      vim.g.mkdp_auto_start = 0      -- don't auto-start preview
      vim.g.mkdp_auto_close = 1      -- auto close preview when buffer is closed
      vim.g.mkdp_refresh_slow = 0
      vim.g.mkdp_browser = ""        -- leave empty to use system default
      vim.g.mkdp_theme = "dark"      -- can be "dark" or "light"
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
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover info" })
vim.keymap.set("n", "<Leader>d", function()
  vim.diagnostic.open_float(nil, { focusable = false })
end, { desc = "Show diagnostics for current line/item" })
vim.keymap.set("n", "<Leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<Leader>bn", ":bnext<CR>", { desc = "Next buffer" })
