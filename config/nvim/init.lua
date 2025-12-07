local opt = vim.opt
local global = vim.g
local keymap = vim.keymap
local lsp = vim.lsp

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.wrap = false

opt.signcolumn = "yes"
opt.undofile = true
opt.updatetime = 250

opt.clipboard = "unnamedplus"
        
opt.tabstop = 2
opt.softtabstop = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

opt.laststatus = 3
opt.cmdheight = 0

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true

opt.swapfile = false
opt.winborder = "rounded"

global.mapleader = " "

keymap.set('n', '<leader>o', ':update<CR> :source<CR>')
keymap.set('n', '<leader>w', ':write<CR>')
keymap.set('n', '<leader>q', ':quit<CR>')

vim.pack.add({
        { src = "https://github.com/stevearc/oil.nvim" },
        { src = "https://github.com/echasnovski/mini.pick" },
        { src = "https://github.com/neovim/nvim-lspconfig" },
        { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
        { src = "https://github.com/mason-org/mason.nvim" },
        { src = "https://github.com/christoomey/vim-tmux-navigator" },
        { src = "https://github.com/github/copilot.vim" },
})

require "mason".setup()
require "mini.pick".setup()
require "oil".setup()

keymap.set('n', '<leader>lf', vim.lsp.buf.format)
vim.lsp.enable({ 'lua_ls', 'hyprls', 'clangd', 'python-lsp-server', 'basedpyright', 'qmlls',  })
vim.lsp.config('lua_ls', {
        settings = {
                Lua = {
                        workspace = {
                                library = vim.api.nvim_get_runtime_file("", true),
                        }
                }
        }
})

vim.keymap.set('n', '<leader>f', ':Pick files<CR>')
vim.keymap.set('n', '<leader>h', ':Pick help<CR>')
vim.keymap.set('n', '<leader>e', ':Oil<CR>')

vim.keymap.set({ 'n', 'v', 'x' }, '<leader>y', '"+y<CR>')
vim.keymap.set({ 'n', 'v', 'x' }, '<leader>d', '"+d<CR>')

vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')

local nord = {
  none      = "NONE",
  bg        = "#2e3440",  -- nord0
  fg        = "#d8dee9",  -- nord4
  fg_gutter = "#4c566a",  -- nord3
  comment   = "#88c0d0",  -- nord8
  cyan      = "#8fbcbb",  -- nord7
  blue      = "#81a1c1",  -- nord9
  purple    = "#b48ead",  -- nord15
  red       = "#bf616a",  -- nord11
  orange    = "#d08770",  -- nord12
  yellow    = "#ebcb8b",  -- nord13
  green     = "#a3be8c",  -- nord14
}

-- Apply Nord colors
vim.cmd.colorscheme("default")           -- clean slate
vim.o.background = "dark" 
vim.o.termguicolors = true

-- Core highlights
vim.api.nvim_set_hl(0, "Normal",       { fg = nord.fg,        bg = "NONE" })
vim.api.nvim_set_hl(0, "NormalFloat",  { fg = nord.fg,        bg = "NONE" })
vim.api.nvim_set_hl(0, "CursorLine",   { bg = "#3b4252" })                     -- nord1
vim.api.nvim_set_hl(0, "LineNr",       { fg = nord.fg_gutter })
vim.api.nvim_set_hl(0, "CursorLineNr",{ fg = nord.blue, bold = true })
vim.api.nvim_set_hl(0, "SignColumn",   { bg = "NONE" })
vim.api.nvim_set_hl(0, "Comment",      { fg = nord.comment, italic = true })
vim.api.nvim_set_hl(0, "String",       { fg = nord.green })
vim.api.nvim_set_hl(0, "Keyword",      { fg = nord.blue, bold = true })
vim.api.nvim_set_hl(0, "Function",     { fg = nord.cyan })
vim.api.nvim_set_hl(0, "Identifier",   { fg = nord.fg, bold = true })
vim.api.nvim_set_hl(0, "Type",         { fg = nord.blue })
vim.api.nvim_set_hl(0, "Constant",     { fg = nord.purple })
vim.api.nvim_set_hl(0, "Number",       { fg = nord.orange })
vim.api.nvim_set_hl(0, "Statement",    { fg = nord.blue, italic = true })
vim.api.nvim_set_hl(0, "PreProc",      { fg = nord.purple })
vim.api.nvim_set_hl(0, "Special",      { fg = nord.yellow })

-- Pmenu (completion)
vim.api.nvim_set_hl(0, "Pmenu",        { fg = nord.fg, bg = "#3b4252" })
vim.api.nvim_set_hl(0, "PmenuSel",     { fg = nord.bg, bg = nord.blue })
vim.api.nvim_set_hl(0, "PmenuSbar",    { bg = "#434c5e" })
vim.api.nvim_set_hl(0, "PmenuThumb",   { bg = nord.blue })

-- Statusline (your custom one)
vim.api.nvim_set_hl(0, "StatusLine",      { fg = nord.fg, bg = "NONE" })
vim.api.nvim_set_hl(0, "StatusLineLeft",  { fg = nord.cyan })
vim.api.nvim_set_hl(0, "StatusLineRight", { fg = nord.orange })
vim.api.nvim_set_hl(0, "StatusLinePos",   { fg = nord.purple })

-- GitSigns, LSP, etc.
vim.api.nvim_set_hl(0, "GitSignsAdd",    { fg = nord.green })
vim.api.nvim_set_hl(0, "GitSignsChange", { fg = nord.yellow })
vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = nord.red })
vim.api.nvim_set_hl(0, "DiagnosticError", { fg = nord.red })
vim.api.nvim_set_hl(0, "DiagnosticWarn",  { fg = nord.yellow })
vim.api.nvim_set_hl(0, "DiagnosticInfo",  { fg = nord.blue })
vim.api.nvim_set_hl(0, "DiagnosticHint",  { fg = nord.cyan })

-- Oil.nvim
vim.api.nvim_set_hl(0, "OilDir",  { fg = nord.blue })
vim.api.nvim_set_hl(0, "OilFile", { fg = nord.fg })

-- Mini.indentscope
vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { fg = nord.comment })

vim.keymap.set({ 'n', 'i' }, '<Esc>', function()
        if vim.fn.mode() == 'n' then
                vim.cmd.nohlsearch()
        end
        return '<Esc>'
end, { expr = true })

vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(ev)
                local client = vim.lsp.get_client_by_id(ev.data.client_id)
                if client:supports_method('textDocument/completion') then
                        vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
                end
        end,
})
vim.cmd("set completeopt+=noselect")
-- Fix selection visibility in foot/alacritty/kitty with transparent background

-- Noob corner
-- Disable arrows movement
vim.keymap.set('', '<Up>', '<Nop>')
vim.keymap.set('', '<Down>', '<Nop>')
vim.keymap.set('', '<Left>', '<Nop>')
vim.keymap.set('', '<Right>', '<Nop>')

local mode_names = {
        n = "NORMAL",
        i = "INSERT",
        v = "VISUAL",
        ['␖'] = "V-BLOCK",
        V = "V-LINE",
        c = "COMMAND",
        ['!'] = "SHELL",
        r = "REPLACE",
        s = "SELECT",
        t = "TERMINAL",
}

_G.statusline = function()
        local file_path = vim.fn.expand('%:p:~:.')
        local left = '%#StatusLineLeft#' .. file_path

        local mode = mode_names[vim.fn.mode()] or "NORMAL"
        local line = vim.fn.line('.')
        local col = vim.fn.col('.')
        local right = '%#StatusLineRight# -- ' .. mode .. ' -- %#StatusLinePos# ' .. line .. ' ' .. col .. ' '

        return left .. '%=' .. right
end

vim.opt.statusline = '%!v:lua.statusline()'

