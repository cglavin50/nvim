vim.pack.add({
  "https://github.com/nvim-mini/mini.trailspace",
})

require("mini.trailspace").setup()
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    require("mini.trailspace").trim()
    require("mini.trailspace").trim_last_lines()
  end,
})
