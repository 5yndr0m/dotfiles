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

-- =============================================================================
--  COLOR CONFIGURATION (MATUGEN MAPPER)
-- =============================================================================

-- Default Fallback (Nord) in case matugen file is missing
local theme = {
  none      = "NONE",
  bg        = "#2e3440",
  fg        = "#d8dee9",
  fg_gutter = "#4c566a",
  comment   = "#88c0d0",
  cyan      = "#8fbcbb",
  blue      = "#81a1c1",
  purple    = "#b48ead",
  red       = "#bf616a",
  orange    = "#d08770",
  yellow    = "#ebcb8b",
  green     = "#a3be8c",
}

-- Try to load Matugen generated colors
-- Ensure you configured Matugen to output to: ~/.config/nvim/lua/matugen_colors.lua
local ok, matugen = pcall(require, "matugen_colors")

if ok then
    -- MAP MATUGEN TOKENS TO YOUR LOGICAL KEYS
    -- We map Material Design tokens to the keys your config uses (blue, cyan, etc.)
    theme = {
        none      = "NONE",
        -- Use "NONE" for bg if you want transparency, or matugen.bg_default for opaque
        bg        = "NONE", 
        fg        = matugen.fg_default,
        fg_gutter = matugen.outline_variant,
        comment   = matugen.outline,      -- Comments are usually subtle
        
        -- Mapping logic:
        -- Primary -> Blue equivalent (Keywords, Functions)
        -- Secondary -> Cyan equivalent
        -- Tertiary -> Purple equivalent
        -- Error -> Red
        
        blue      = matugen.primary,
        cyan      = matugen.secondary,
        purple    = matugen.tertiary,
        red       = matugen.error,
        
        -- Containers usually provide good variation for other syntax colors
        green     = matugen.inverse_primary, -- Using inverse for contrast
        yellow    = matugen.on_surface_variant, -- Subtler highlights
        orange    = matugen.tertiary, -- Reusing tertiary or define a custom mapping
    }
end

-- Apply Colors
vim.cmd.colorscheme("default")           -- clean slate
vim.o.background = "dark" 
vim.o.termguicolors = true

-- Core highlights
vim.api.nvim_set_hl(0, "Normal",       { fg = theme.fg,        bg = "NONE" })
vim.api.nvim_set_hl(0, "NormalFloat",  { fg = theme.fg,        bg = "NONE" })
-- Using fg_gutter (outline) for cursorline background to be subtle
vim.api.nvim_set_hl(0, "CursorLine",   { bg = theme.fg_gutter })                  
vim.api.nvim_set_hl(0, "LineNr",       { fg = theme.fg_gutter })
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = theme.blue, bold = true })
vim.api.nvim_set_hl(0, "SignColumn",   { bg = "NONE" })
vim.api.nvim_set_hl(0, "Comment",      { fg = theme.comment, italic = true })
vim.api.nvim_set_hl(0, "String",       { fg = theme.green })
vim.api.nvim_set_hl(0, "Keyword",      { fg = theme.blue, bold = true })
vim.api.nvim_set_hl(0, "Function",     { fg = theme.cyan })
vim.api.nvim_set_hl(0, "Identifier",   { fg = theme.fg, bold = true })
vim.api.nvim_set_hl(0, "Type",         { fg = theme.blue })
vim.api.nvim_set_hl(0, "Constant",     { fg = theme.purple })
vim.api.nvim_set_hl(0, "Number",       { fg = theme.orange })
vim.api.nvim_set_hl(0, "Statement",    { fg = theme.blue, italic = true })
vim.api.nvim_set_hl(0, "PreProc",      { fg = theme.purple })
vim.api.nvim_set_hl(0, "Special",      { fg = theme.yellow })

-- Pmenu (completion)
vim.api.nvim_set_hl(0, "Pmenu",        { fg = theme.fg, bg = theme.fg_gutter })
vim.api.nvim_set_hl(0, "PmenuSel",     { fg = theme.bg, bg = theme.blue })
vim.api.nvim_set_hl(0, "PmenuSbar",    { bg = theme.fg_gutter })
vim.api.nvim_set_hl(0, "PmenuThumb",   { bg = theme.blue })

-- Statusline (your custom one)
vim.api.nvim_set_hl(0, "StatusLine",      { fg = theme.fg, bg = "NONE" })
vim.api.nvim_set_hl(0, "StatusLineLeft",  { fg = theme.cyan })
vim.api.nvim_set_hl(0, "StatusLineRight", { fg = theme.orange })
vim.api.nvim_set_hl(0, "StatusLinePos",   { fg = theme.purple })

-- GitSigns, LSP, etc.
vim.api.nvim_set_hl(0, "GitSignsAdd",    { fg = theme.green })
vim.api.nvim_set_hl(0, "GitSignsChange", { fg = theme.yellow })
vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = theme.red })
vim.api.nvim_set_hl(0, "DiagnosticError", { fg = theme.red })
vim.api.nvim_set_hl(0, "DiagnosticWarn",  { fg = theme.yellow })
vim.api.nvim_set_hl(0, "DiagnosticInfo",  { fg = theme.blue })
vim.api.nvim_set_hl(0, "DiagnosticHint",  { fg = theme.cyan })

-- Oil.nvim
vim.api.nvim_set_hl(0, "OilDir",  { fg = theme.blue })
vim.api.nvim_set_hl(0, "OilFile", { fg = theme.fg })

-- Mini.indentscope
vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { fg = theme.comment })

-- =============================================================================
--  END COLOR CONFIGURATION
-- =============================================================================

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
