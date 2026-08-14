vim.opt.termguicolors = true

-- core nvim settings (see kickstart)
do
  -- Enable faster startup by caching compiled Lua modules
  vim.loader.enable()

  -- Set <space> as the leader key
  -- See `:help mapleader`
  --  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '

  -- Set to true if you have a Nerd Font installed and selected in the terminal
  vim.g.have_nerd_font = true

  -- Default options
  -- NOTE: See `:help option-list`
  vim.o.number = true
  vim.o.relativenumber = true
  vim.o.mouse = 'a'
  vim.o.showmode = false -- TODO: configure status line
  vim.o.autocomplete = true -- TODO: configure sources
  vim.o.ignorecase = true
  vim.o.smartcase = true -- ignore case UNTIL we add caps
  vim.o.undofile = true
  vim.o.signcolumn = 'yes' -- TODO: gitsigns + other gutter
  vim.o.cursorline = true
  vim.o.scrolloff = 20
  vim.o.sidescrolloff = 20 -- helpful for dadbod
  vim.o.confirm = true -- prompt to confirm when operation main fail/overwrite
  vim.o.showmatch = true

  vim.o.list = true
  vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' } -- how we show tab, trail, etc

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
  vim.schedule(function() vim.o.clipboard = 'unnamedplus' end) -- TODO: configure clipboard manager
end

-- basic keymaps (again from kickstart)
do
  -- diagnostics config
  --  See `:help vim.diagnostic.Opts`
  vim.diagnostic.config {
    update_in_insert = false, -- wait until exiting insert to update diagnostics
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    underline = { severity = { min = vim.diagnostic.severity.WARN } },

    -- Can switch between these as you prefer
    virtual_text = false, -- Text shows up at the end of the line
    virtual_lines = true, -- Text shows up underneath the line, with virtual lines

    -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
    jump = {
      on_jump = function(_, bufnr)
        vim.diagnostic.open_float {
          bufnr = bufnr,
          scope = 'cursor',
          focus = false,
        }
      end,
    },
  }
  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

  vim.keymap.set('n', '<leader>E', vim.cmd.Ex, { desc = '[E]xplore files' }) -- TODO: assess this tooling, checkout oil

  vim.keymap.set('n', 'j', function()
    return vim.v.count == 0 and 'gj' or 'j'
  end, { expr = true, silent = true, desc = "Down (wrap-aware)"})
  vim.keymap.set('n', 'k', function()
    return vim.v.count == 0 and 'gk' or 'k'
  end, { expr = true, silent = true, desc = "Up (wrap-aware)"})

  -- TODO: configure tmux.nvim and combine keybinds

  vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
    callback = function() vim.hl.on_yank() end,
  })
end

-- general autocmds
do
  -- return to last cursor position
  vim.api.nvim_create_autocmd("BufReadPost", {
    group = vim.api.nvim_create_augroup('return-last-cursor', { clear = true }),
    desc = "Restore last cursor position",
    callback = function()
      if vim.o.diff then -- except in diff mode
        return
      end

      local last_pos = vim.api.nvim_buf_get_mark(0, '"') -- {line, col}
      local last_line = vim.api.nvim_buf_line_count(0)

      local row = last_pos[1]
      if row < 1 or row > last_line then
        return
      end

      pcall(vim.api.nvim_win_set_cursor, 0, last_pos)
    end,
  })
end

-- UI
do
  vim.pack.add({
    { src = 'https://github.com/nvim-mini/mini.nvim', version = 'stable' },
  })
  require('mini.icons').setup()
    -- Used for backwards compatibility with plugins that require `nvim-web-devicons` (e.g. telescope.nvim)
    MiniIcons.mock_nvim_web_devicons()


  require('mini.diff').setup()

  -- TODO: write statusline.lua and extend as standalone
  local statusline = require 'mini.statusline'
  statusline.setup { use_icons = vim.g.have_nerd_font }
  statusline.section_location = function() return '%2l:%-2v' end -- cursor as LINE:COLUMN

  vim.pack.add({
    "https://github.com/sainnhe/everforest",
    'https://github.com/catppuccin/nvim'
  })
  vim.o.background = 'light'
  require('catppuccin').setup {
    background = { -- :h background
        light = "latte",
        dark = "mocha",
    },
  }
  -- vim.g.everforest_background = "soft"
  vim.cmd.colorscheme 'catppuccin'
end

-- LSP
do
  -- Enable the following language servers
  --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
  --  See `:help lsp-config` for information about keys and how to configure
  ---@type table<string, vim.lsp.Config>
  local servers = {
    pyright = {},
    ts_ls = {},
    stylua = {},

    -- Special Lua Config, as recommended by neovim help docs
    lua_ls = {
      on_init = function(client)
        client.server_capabilities.documentFormattingProvider = false -- Disable formatting (formatting is done by stylua)

        if client.workspace_folders then
          local path = client.workspace_folders[1].name
          if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
        end

        local current_settings = client.config.settings --[[@as lspconfig.settings.lua_ls]]
        client.config.settings.Lua = vim.tbl_deep_extend('force', current_settings.Lua, {
          runtime = {
            version = 'LuaJIT',
            path = { 'lua/?.lua', 'lua/?/init.lua' },
          },
          workspace = {
            checkThirdParty = false,
            -- NOTE: this is a lot slower and will cause issues when working on your own configuration.
            --  See https://github.com/neovim/nvim-lspconfig/issues/3189
            library = vim.api.nvim_get_runtime_file('', true),
          },
        })
      end,
      ---@type lspconfig.settings.lua_ls
      settings = {
        Lua = {
          format = { enable = false }, -- Disable formatting (formatting is done by stylua)
        },
      },
    },
  }

  vim.pack.add({
    "https://github.com/neovim/nvim-lspconfig", -- sets sensible default configs for any LSP server
    "https://github.com/mason-org/mason.nvim",
    'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim', -- allows us to define "ensure_installed" for mason
    "https://github.com/mason-org/mason-lspconfig.nvim",           -- bridge mason names to lspconfig so we get defaults automatically
  })
  require('mason').setup {}
  local ensure_installed = vim.tbl_keys(servers)
  require('mason-tool-installer').setup { ensure_installed = ensure_installed }

  for name, server in pairs(servers) do
    vim.lsp.config(name, server)
    vim.lsp.enable(name)
  end
end

-- search and navigation
do
  vim.pack.add({
    'https://github.com/nvim-telescope/telescope.nvim',
    'https://github.com/nvim-lua/plenary.nvim',
    'https://github.com/nvim-telescope/telescope-fzf-native.nvim',
    'https://github.com/nvim-telescope/telescope-ui-select.nvim'
  })

  local builtin = require('telescope.builtin')
  -- Enable Telescope extensions if they are installed
  pcall(require('telescope').load_extension, 'fzf')
  pcall(require('telescope').load_extension, 'ui-select')

  -- Add Telescope-based LSP pickers when an LSP attaches to a buffer.
  -- If you later switch picker plugins, this is where to update these mappings.
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
    callback = function(event)
      local buf = event.buf

      -- Find references for the word under your cursor.
      vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })

      -- Jump to the implementation of the word under your cursor.
      -- Useful when your language has ways of declaring types without an actual implementation.
      vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })

      -- Jump to the definition of the word under your cursor.
      -- This is where a variable was first declared, or where a function is defined, etc.
      -- To jump back, press <C-t>.
      vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })

      -- Fuzzy find all the symbols in your current document.
      -- Symbols are things like variables, functions, types, etc.
      vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })

      -- Fuzzy find all the symbols in your current workspace.
      -- Similar to document symbols, except searches over your entire project.
      vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })

      -- Jump to the type of the word under your cursor.
      -- Useful when you're not sure what type a variable is and you want to see
      -- the definition of its *type*, not where it was *defined*.
      vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })
    end,
  })

  -- Override default behavior and theme when searching
  vim.keymap.set('n', '<leader>/', function()
    -- You can pass additional configuration to Telescope to change the theme, layout, etc.
    builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      winblend = 10,
      previewer = false,
    })
  end, { desc = '[/] Fuzzily search in current buffer' })

  -- It's also possible to pass additional configuration options.
  --  See `:help telescope.builtin.live_grep()` for information about particular keys
  vim.keymap.set(
    'n',
    '<leader>s/',
    function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end,
    { desc = '[S]earch [/] in Open Files' }
  )

  vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
  vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
  vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
  vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
  vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
  vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
  vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
  vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
  vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
  vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
  vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
end


-- plugins (vim.pack)
-- TODO: separate? figure out repo structure
do
 vim.pack.add({
  { src = 'https://github.com/folke/which-key.nvim', version = 'main' },
 })
  require('which-key').setup {
    delay = 0,
    icons = { mappings = vim.g.have_nerd_font },
    -- Document existing key chains
    -- spec = {
    --   { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
    --   { '<leader>t', group = '[T]oggle' },
    --   { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } }, -- Enable gitsigns recommended keymaps first
    --   { 'gr', group = 'LSP Actions', mode = { 'n' } },
    -- },
  }

  vim.pack.add({
    'https://github.com/nvim-mini/mini.trailspace'
  })
  require('mini.trailspace').setup()
  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
      require("mini.trailspace").trim()
      require("mini.trailspace").trim_last_lines()
    end,
  })
end
