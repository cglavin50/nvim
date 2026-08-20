-- TODO: replace with mini.clue
vim.pack.add({
  "https://github.com/folke/which-key.nvim",
})
require("which-key").setup({
  delay = 0,
  icons = { mappings = vim.g.have_nerd_font },
  plugins = {
    marks = true,
    presets = {
      operators = true,
      motions = true,
      z = true,
      g = true,
    },
  },
  -- Document existing key chains
  -- spec = {
  --   { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
  --   { '<leader>t', group = '[T]oggle' },
  --   { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } }, -- Enable gitsigns recommended keymaps first
  --   { 'gr', group = 'LSP Actions', mode = { 'n' } },
  -- },
})
