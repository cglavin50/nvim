vim.pack.add({
  "https://github.com/sindrets/diffview.nvim",
})
require("diffview").setup({})
-- see :h diffview-merge-tool :h diffview-config-view.x.layout for help with merge conflicts + view

local function diffview_toggle()
  local lib = require("diffview.lib")
  local view = lib.get_current_view()
  if view then
    vim.cmd("DiffviewClose")
  else
    vim.cmd("DiffviewOpen")
  end
end

vim.keymap.set("n", "<leader>gd", diffview_toggle, { desc = "Toggle [G]it [D]iffview" })
