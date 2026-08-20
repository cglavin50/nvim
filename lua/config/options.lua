-- core nvim settings (see kickstart)

vim.opt.termguicolors = true

-- Enable faster startup by caching compiled Lua modules
vim.loader.enable()

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- Default options
-- NOTE: See `:help option-list`
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = "a"
vim.o.showmode = false -- TODO: configure status line
vim.o.autocomplete = false
vim.o.ignorecase = true
vim.o.smartcase = true -- ignore case UNTIL we add caps
vim.o.undofile = true
vim.o.signcolumn = "yes" -- TODO: gitsigns + other gutter
vim.o.cursorline = true
vim.o.scrolloff = 20
vim.o.sidescrolloff = 20 -- helpful for dadbod
vim.o.confirm = true -- prompt to confirm when operation main fail/overwrite
vim.o.showmatch = true
vim.o.conceallevel = 2 -- conceal/replace characters

vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" } -- how we show tab, trail, etc

-- tab/indent
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2 -- indent width
vim.opt.expandtab = true -- use spaces
vim.o.breakindent = true
vim.o.autoindent = true
vim.o.smartindent = true

-- window/split behavior
vim.o.splitright = true
vim.o.splitbelow = true

-- misc configs I don't quite understand/care
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
vim.schedule(function()
  vim.o.clipboard = "unnamedplus"
end) -- TODO: configure clipboard manager
