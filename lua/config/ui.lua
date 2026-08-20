-- general UI management

vim.pack.add({
  { src = "https://github.com/nvim-mini/mini.nvim", version = "stable" },
})

require("mini.diff").setup({
  view = {
    style = "sign",
  },
})

require("mini.icons").setup()
-- Used for backwards compatibility with plugins that require `nvim-web-devicons` (e.g. telescope.nvim)
MiniIcons.mock_nvim_web_devicons()

-- TODO: write statusline.lua and extend as standalone
local statusline = require("mini.statusline")
statusline.setup({ use_icons = vim.g.have_nerd_font })
statusline.section_location = function()
  return "%2l:%-2v"
end -- cursor as LINE:COLUMN

vim.pack.add({
  "https://github.com/zaldih/themery.nvim",
  "https://github.com/sainnhe/everforest",
  "https://github.com/catppuccin/nvim",
  "https://github.com/EdenEast/nightfox.nvim",
  "https://github.com/projekt0n/github-nvim-theme",
})

-- pre-work for catppuccin
require("catppuccin").setup({
  background = { -- :h background
    light = "latte",
    dark = "mocha",
  },
})

-- Using before and after.
require("themery").setup({
  themes = {
    {
      name = "GitHub Dark",
      colorscheme = "github_dark",
      before = [[
        vim.opt.background = "dark"
      ]],
    },
    {
      name = "Everfore Light",
      colorscheme = "everforest",
      before = [[
        vim.g.everforest_background = "soft"
        vim.opt.background = "light"
      ]],
    },
    {
      name = "Duskfox",
      colorscheme = "duskfox",
      before = [[
        vim.o.background = "dark"
      ]],
    },
    {
      name = "Catppuccin Latte",
      colorscheme = "catppuccin",
      before = [[
        vim.o.background = "light"
      ]],
    },
    {
      name = "Catppuccin Mocha",
      colorscheme = "catppuccin",
      before = [[
        vim.o.background = "dark"
      ]],
    },
  },
})
vim.keymap.set("n", "<leader>sT", "<cmd>Themery<CR>", { desc = "[S]earch [T]hemes (themary)" })
