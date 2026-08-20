-- autocompletion
-- LuaSnip is our snip enginge, backed with friendly snippets for some language defaults

vim.pack.add({
  "https://github.com/L3MON4D3/LuaSnip", -- TODO: replace with mini-snippets
  {
    src = "https://github.com/saghen/blink.cmp",
    version = vim.version.range("^1"),
  },
  "https://github.com/rafamadriz/friendly-snippets",
})
-- NOTE: see https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps for more advanced snippet keymaps
require("luasnip").setup({})
require("luasnip.loaders.from_vscode").lazy_load() -- provide pre-built snippets to Lua snip

require("blink.cmp").setup({
  keymap = {
    -- See `:help blink-cmp-config-keymap` for defining your own keymap
    preset = "default",
  },

  appearance = {
    nerd_font_variant = "mono",
    use_nvim_cmp_as_default = true,
  },

  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 500 },
  },

  sources = {

    default = { "lsp", "path", "snippets", "buffer" },
    per_filetype = {
      sql = { "snippets", "dadbod", "buffer" },
    },
    -- add vim-dadbod-completion to your completion providers
    providers = {
      dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
    },
  },

  snippets = { preset = "luasnip" },

  fuzzy = { implementation = "prefer_rust_with_warning" },

  -- Shows a signature help window while you type arguments for a function
  signature = { enabled = true },
})
