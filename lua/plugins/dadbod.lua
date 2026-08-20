vim.pack.add({
  "https://github.com/tpope/vim-dadbod",
  "https://github.com/kristijanhusak/vim-dadbod-completion",
  "https://github.com/kristijanhusak/vim-dadbod-ui",
})
-- TODO: configure cmp/autocomplete to feed into dadbod
vim.api.nvim_create_autocmd("FileType", {
  pattern = "sql",
  callback = function()
    -- Set up completion for dadbod-ui and regular sql files
    require("blink.cmp").setup.buffer({
      sources = {
        { name = "vim-dadbod-completion" },
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "path" },
        { name = "nvim_lsp_signature_help" },
      },
    })
  end,
})
