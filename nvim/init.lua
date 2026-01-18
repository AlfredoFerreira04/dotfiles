-- Bootstrap lazy.nvim if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
  { "folke/tokyonight.nvim", lazy = false, priority = 1000 },
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  { "neovim/nvim-lspconfig" },

  -- Function Signature while typing cause I have goldfish memory and I like it
  { 
  "ray-x/lsp_signature.nvim",
  event = "BufRead",  -- lazy-load when a buffer is opened
  config = function()
    require("lsp_signature").setup({
      bind = true,             -- mandatory
      floating_window = true,  -- show signature in a floating window
      hint_enable = true,      -- show inline hint
      handler_opts = { border = "rounded" },
    })
  end
  },

  -- Tabbing

  {
  "tpope/vim-sleuth",
  event = { "BufReadPost", "BufNewFile" },
  },

  -- Autocompletion
  {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
  },
  },


  -- 🔹 Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local npairs = require("nvim-autopairs")
      npairs.setup({})

      -- If using nvim-cmp, integrate it:
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },
})

-- UI settings
vim.cmd.colorscheme("tokyonight")
require("lualine").setup()

-- Treesitter (syntax highlighting)
require("nvim-treesitter.configs").setup({
  ensure_installed = { "lua", "python", "javascript", "typescript", "c", "cpp" },
  highlight = { enable = true },
  indent = { enable = true },
})

-- === LSP + nvim-cmp modern setup ===


local lspconfig = require("lspconfig")
local cmp_nvim_lsp = require("cmp_nvim_lsp")
local capabilities = cmp_nvim_lsp.default_capabilities()

-- LSP servers
local servers = {
  lua_ls = {},
  pyright = {},
  ts_ls = {},
  clangd = { filetypes = { "c", "cpp", "objc", "objcpp" } },
}

for name, opts in pairs(servers) do
  opts.capabilities = capabilities
  lspconfig[name].setup(opts)
end

-- === nvim-cmp Setup ===
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
  }, {
    { name = "buffer" },
    { name = "path" },
  }),
})

-- === VSCode-like keymaps ===
local map = vim.keymap.set

-- Undo / Redo
vim.keymap.set("i", "<C-z>", "<C-u>", { desc = "Swap CTRL U for CTRL Z" })
map("n", "<C-z>", "u", { noremap = true, silent = true })              -- Ctrl+Z = undo
map("n", "<C-S-z>", "<C-r>", { noremap = true, silent = true })        -- Ctrl+Shift+Z = redo

-- Save / Quit
map("n", "<C-s>", ":w<CR>", { noremap = true, silent = true })         -- Ctrl+S = save
map("i", "<C-s>", "<Esc>:w<CR>a", { noremap = true, silent = true })   -- Ctrl+S in insert mode
map("n", "<C-q>", ":q<CR>", { noremap = true, silent = true })         -- Ctrl+Q = quit

-- nvim-cmp setup (add at bottom of config)
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
  }, {
    { name = "buffer" },
    { name = "path" },
  }),
})

-- == System Settings ==

vim.opt.clipboard = "unnamedplus"

-- === Custom navigation keymaps ===

-- Swap j and k for up/down movement
-- Normal, Visual, and Operator-pending modes
map({ "n", "v", "o" }, "j", "k", { noremap = true })
map({ "n", "v", "o" }, "k", "j", { noremap = true })

-- Also swap gj / gk (for wrapped lines)
map({ "n", "v", "o" }, "gj", "gk", { noremap = true })
map({ "n", "v", "o" }, "gk", "gj", { noremap = true })


-- Ctrl+PageUp / Ctrl+PageDown to move between vertical splits
map("n", "<C-PageUp>", "<C-w>h", { noremap = true, silent = true })   -- go left split
map("n", "<C-PageDown>", "<C-w>l", { noremap = true, silent = true }) -- go right split


