vim.pack.add({
  {
    src = "https://github.com/obsidian-nvim/obsidian.nvim",
    version = vim.version.range("*"), -- use latest release, remove to use latest commit
  },
})

require("obsidian").setup({
  legacy_commands = false,
  workspaces = {
    {
      name = "main",
      path = "~/Documents/obsidian-vault/",
    },
  },
  picker = {
    -- TODO: change mappings to make it easier to create new note
    name = "telescope.nvim",
    note_mappings = {
      new_note = "<C-CR>",
    },
  },
  daily_notes = {
    enabled = true,
    folder = "Daily Notes",
    date_format = "YYYY-MM-DD",
    default_tags = { "daily" },
    template = "~/Documents/obsidian-vault/templates/Daily Note",
  },
  checkbox = {
    enabled = true,
    create_new = true,
    order = { " ", "x", "~", "!" },
  },
  cache = {
    enabled = true,
  },
  callbacks = {
    -- TODO: set keybinds for back tracing and seeing links
    -- FIX: plenary errors on daily notes + telescope
    enter_note = function()
      vim.keymap.set("n", "<leader>ch", "<cmd>Obsidian toggle_checkbox<cr>", {
        buffer = true,
        desc = "Toggle checkbox",
      })
    end,
  },
})

-- TODO: search for aliases as well
vim.keymap.set(
  "n",
  "<leader>so",
  "<cmd>Obsidian quick_switch<CR>",
  { desc = "[S]earch [O]bsidian Vault (quick switch)" }
)

-- NOTE: setting <leader>o as my obsidian entrypoint
vim.keymap.set("n", "<leader>od", "<cmd>Obsidian today<CR>", { desc = "[O]bsidian: open today's daily note" })
vim.keymap.set("n", "<leader>on", "<cmd>Obsidian new<CR>", { desc = "[O]bsidian: [N]ew Note" })
vim.keymap.set("n", "<leader>ob", "<cmd>Obsidian backlinks<CR>", { desc = "[O]bsidian: [B]acklinks" })
