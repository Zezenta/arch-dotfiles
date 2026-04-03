vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.clipboard = "unnamedplus"

-- Evitar que Neovim use " como prefijo de registro en modo normal
vim.g.mapleader = " "
vim.g.maplocalleader = " "


vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.cursorline = true
vim.opt.termguicolors = true

-- Instalar Lazy.nvim automáticamente
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- LSP y Autocompletado
  "neovim/nvim-lspconfig",
  "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "L3MON4D3/LuaSnip",

  -- Resaltado de sintaxis (Treesitter)
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- Colores (Opcional pero recomendado)
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
})

vim.cmd.colorscheme "catppuccin"


require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "ts_ls", "clangd" }
})

-- En lugar de require('lspconfig'), usamos la nueva API de Neovim
-- Si el servidor está instalado por Mason, Neovim lo encontrará
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Configuración para TypeScript / JS
vim.lsp.config('ts_ls', {
    capabilities = capabilities,
})

-- Configuración para C++
vim.lsp.config('clangd', {
    capabilities = capabilities,
})

-- Para activar los servidores automáticamente
vim.lsp.enable('ts_ls')
vim.lsp.enable('clangd')

-- Fix para escribir comillas dobles en layout internacional
vim.keymap.set('i', '"', '"', { noremap = true })
vim.keymap.set('c', '"', '"', { noremap = true })


-- 4. Configuración de Autocompletado (Lo que faltaba en Arch)
local cmp = require("cmp")
cmp.setup({
    snippet = {
        expand = function(args) require("luasnip").lsp_expand(args.body) end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<Tab>'] = cmp.mapping.select_next_item(),
        ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
    }),
    -- Autocompletado automático (más conservador)
    completion = {
        completeopt = 'menu,menuone,noinsert,noselect',
        keyword_length = 2,
    },
    -- No preseleccionar nada
    preselect = cmp.PreselectMode.None,
})

-- ===================================================================
-- FIX PARA COMILLAS DOBLES EN LAYOUT INTERNACIONAL ESPAÑOL
-- ===================================================================

-- Método 1: Remover el uso de " como operador de registro
vim.cmd([[
  " En modo insert, mapear " para que inserte literalmente
  inoremap " "

  " También para modo comando
  cnoremap " "
]])

-- Método 2: Timeout más corto para evitar que espere una segunda tecla
vim.opt.timeout = false
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 100

-- Método 3: Mapping simple para comillas (ya no necesario si cmp está deshabilitado correctamente)
-- Este mapping permite escribir comillas sin que cmp interfiera
vim.keymap.set('i', '"', '"', { expr = false, noremap = true })
