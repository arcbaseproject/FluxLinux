-- FluxLinux default Neovim configuration
-- Pure built-ins only: no plugin manager, nothing fetched over the network.

local opt = vim.opt
local g = vim.g

g.mapleader = " "
g.maplocalleader = " "

opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.ignorecase = true
opt.smartcase = true
opt.splitright = true
opt.splitbelow = true
opt.undofile = true
opt.updatetime = 250
opt.termguicolors = true
opt.signcolumn = "yes"
opt.scrolloff = 8
opt.wrap = false
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.cursorline = true
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Built-in dark theme, then tint it teal to match the rest of FluxLinux (WM/waybar/mako).
vim.cmd.colorscheme("habamax")
local accent = "#6ee7c7"
local hl = vim.api.nvim_set_hl
hl(0, "CursorLine", { bg = "#161a20" })
hl(0, "CursorLineNr", { fg = accent, bold = true })
hl(0, "Visual", { bg = "#2c2f38" })
hl(0, "Search", { bg = accent, fg = "#0c0e12" })
hl(0, "IncSearch", { bg = accent, fg = "#0c0e12" })
hl(0, "StatusLine", { fg = accent, bg = "#161a20" })
hl(0, "StatusLineNC", { fg = "#8b949e", bg = "#161a20" })
hl(0, "Pmenu", { bg = "#161a20" })
hl(0, "PmenuSel", { bg = accent, fg = "#0c0e12" })
hl(0, "MatchParen", { fg = accent, bold = true })

-- netrw as the file browser: tree view, no banner clutter
g.netrw_banner = 0
g.netrw_liststyle = 3
g.netrw_winsize = 25

local map = vim.keymap.set
map("n", "<leader>e", vim.cmd.Explore, { desc = "File explorer" })
map("n", "<leader>w", vim.cmd.write, { desc = "Save" })
map("n", "<leader>q", vim.cmd.quit, { desc = "Quit" })
map("n", "<esc>", vim.cmd.nohlsearch, { desc = "Clear search highlight" })

map("n", "<C-h>", "<C-w>h", { desc = "Focus window left" })
map("n", "<C-l>", "<C-w>l", { desc = "Focus window right" })
map("n", "<C-j>", "<C-w>j", { desc = "Focus window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Focus window up" })

map("v", "<", "<gv", { desc = "Indent left, keep selection" })
map("v", ">", ">gv", { desc = "Indent right, keep selection" })
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Minimal statusline: relative path, modified flag, filetype, line:col
opt.laststatus = 3
opt.statusline = " %f %m%=%y  %l:%c "
