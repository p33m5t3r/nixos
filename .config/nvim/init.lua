---------------------- baseline options ----------------------
vim.opt.ignorecase = true
vim.opt.hidden = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.autoindent = true
vim.opt.mouse = 'a'
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.backspace = {'indent', 'eol', 'start'}
vim.opt.clipboard = 'unnamedplus'
vim.opt.completeopt = "menuone,noinsert,noselect"
vim.opt.shortmess = vim.opt.shortmess + "c"
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true
vim.opt.cmdheight = 1
vim.opt.showmode = false
vim.cmd([[
  autocmd FileType lua setlocal shiftwidth=2 softtabstop=2
  autocmd FileType nix setlocal shiftwidth=2 softtabstop=2
  autocmd FileType python setlocal shiftwidth=4 softtabstop=4
  autocmd FileType typescriptreact,typescript setlocal shiftwidth=2 softtabstop=2
]])

-- leader must be set before lazy.nvim loads
vim.g.mapleader = " "

---------------------- colorscheme ----------------------
-- carbonfox / dayfox both come from nightfox.nvim
local theme = 'nightfox'
local set_colorscheme = function(mode)
  if mode == 'light' then theme = 'dayfox' end
  local ok, _ = pcall(vim.cmd, string.format("colorscheme %s", theme))
  if not ok then
    vim.cmd("colorscheme default")
  end
end
-- (applied after lazy loads the colorscheme plugin, see below)

---------------------- keybinds -------------------------
vim.keymap.set("n", "<C-d>", "<C-d>zz",
{ desc = "Scroll down keeping cursor centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz",
{ desc = "Scroll up keeping cursor centered" })
vim.keymap.set("n", "n", "nzzzv",
{ desc = "Next search result centered" })
vim.keymap.set("n", "N", "Nzzzv",
{ desc = "Previous search result centered" })
vim.keymap.set('n', '<leader>nt', ':tabnew<CR>',
{ silent = true, desc = "New tab" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float,
{ desc = "Show LSP error" })
vim.keymap.set("n", "<leader>gs", vim.cmd.Git,
{ desc = "Open Git status" })
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle,
{ desc = "Toggle undotree" })
vim.keymap.set("n", "<leader>fb", vim.cmd.Ex,
{ desc = "Open netrw explorer" })

vim.keymap.set("n", "<leader>fm", function () vim.lsp.buf.format() end,
{ desc = "invoke lsp formatter" })

vim.keymap.set("n", "<leader>yp", function()
  local abs = vim.fn.expand("%:p")
  if abs == "" then
    vim.notify("no file in buffer", vim.log.levels.WARN)
    return
  end
  local root = vim.fn.systemlist({
    "git", "-C", vim.fn.fnamemodify(abs, ":h"), "rev-parse", "--show-toplevel"
  })[1]
  if vim.v.shell_error ~= 0 or not root or root == "" then
    vim.notify("not in a git repo", vim.log.levels.WARN)
    return
  end
  local rel = abs:sub(#root + 2)
  vim.fn.setreg("+", rel)
  vim.fn.setreg('"', rel)
  vim.notify("yanked: " .. rel)
end, { desc = "Yank buffer path relative to git root" })

vim.keymap.set("n", "<leader>cc", function()
    local current_cc = vim.wo.colorcolumn
    if current_cc == "" then
        vim.wo.colorcolumn = "80"
    else
        vim.wo.colorcolumn = ""
    end
end, { desc = "Toggle 80 char column" })
vim.keymap.set('v', '<leader>x', "y<cmd>lua load(vim.fn.getreg('\"'))()<CR>",
{ noremap = true, silent = true, desc = "Execute selected Lua code" })
vim.keymap.set('n', '<leader>x', 'V"zy<cmd>lua load(vim.fn.getreg("z"))()<CR>',
{ noremap = true, silent = true, desc = "Execute current line as Lua code" })

-- Lua file execution (only in Lua files)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    vim.keymap.set({'n', 'v'}, '<leader>r', ':luafile %<CR>',
      { noremap = true, silent = true, buffer = true, desc = "Run current Lua file" })
  end
})

-- TypeScript file execution (only in TypeScript files)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "typescript",
  callback = function()
    vim.keymap.set('n', '<leader>r', ':!bun run dev<CR>',
      { noremap = true, silent = true, buffer = true, desc = "Run current TypeScript file" })
  end
})

---------------------- lazy.nvim bootstrap ----------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- treesitter (main branch — required for neovim 0.12; native highlighting below)
  { "nvim-treesitter/nvim-treesitter", branch = "main", build = ":TSUpdate" },

  -- colorscheme (carbonfox / dayfox)
  { "EdenEast/nightfox.nvim", priority = 1000 },

  -- lsp + completion
  "neovim/nvim-lspconfig",
  { "j-hui/fidget.nvim", opts = {} },               -- lsp progress bar
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-vsnip",
  "hrsh7th/cmp-path",
  "hrsh7th/cmp-buffer",
  "hrsh7th/vim-vsnip",
  "onsails/lspkind.nvim",                            -- lsp completion icons
  { "folke/lazydev.nvim", ft = "lua", opts = {} },  -- nvim lua dev (neodev successor)

  -- fuzzy find + nav
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
  { "ThePrimeagen/harpoon", branch = "harpoon2", dependencies = { "nvim-lua/plenary.nvim" } },

  -- file explorer
  { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } },

  -- git
  "tpope/vim-fugitive",
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '-' },
      },
    },
  },

  -- ui
  "mbbill/undotree",
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
  { "petertriho/nvim-scrollbar", config = function() require("scrollbar").setup() end },
  "lukas-reineke/indent-blankline.nvim",
})

---------------------- colorscheme (apply) -------------
set_colorscheme(os.getenv('COLORCONFIG'))

---------------------- file explorer (nvim-tree) -------
require('nvim-tree').setup({
  disable_netrw = false,   -- keep <leader>fb (netrw) working
  hijack_netrw = false,
  view = { width = 35, preserve_window_proportions = true },
  renderer = { group_empty = true },
})
vim.keymap.set("n", "<leader>nn", ":NvimTreeFindFileToggle<CR>",
{ silent = true, desc = "Toggle nvim-tree (reveal current file)" })
vim.keymap.set("n", "<leader>nr", ":NvimTreeRefresh<CR>",
{ silent = true, desc = "Refresh nvim-tree" })

---------------------- indent guides (off by default) --
local ibl_highlight = {
    -- "CursorColumn",
    "Whitespace",
    "Function",
    "Label",
}
require('ibl').setup {
    enabled = false,
    indent = {
      highlight = ibl_highlight,
      char = "▏",
      tab_char = {"a", "b"},
    },
    whitespace = {
      highlight = ibl_highlight,
      remove_blankline_trail = false,
    },
    scope = { enabled = false },
}
vim.keymap.set("n", "<leader>w", vim.cmd.IBLToggle,
{ desc = "toggle indent guides" })

---------------------- status bar (lualine) ------------
-- show the lsp client(s) attached to the current buffer
local function activelsp()
  local names = {}
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    names[#names + 1] = c.name
  end
  return table.concat(names, ',')
end

require('lualine').setup {
  options = {
    theme = theme
  },
  sections = {
      lualine_a = {'mode'},
      lualine_b = {'branch', 'diff', 'diagnostics'},
      lualine_c =
      {{
          'filename',
          file_status = true,
          path=1,
          symbols = {
              modified = '[+]',
              readonly = '[RO!]',
          }
      }},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {}
  },
  inactive_sections = {
      lualine_a = {},
      lualine_b = {{
          'filename',
          file_status = true,
          path=1,
          symbols = {
              modified = '[+]',
              readonly = '[RO!]',
          }
      }},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {}
  },
}

---------------------- treesitter ----------------------
-- main branch: install parsers here, highlight natively via vim.treesitter.start
-- (autocmd below). install() is async + idempotent (skips already-installed).
-- note: "latex" omitted on purpose — the nixos tree-sitter CLI is too new for
-- nvim-treesitter's generate step (rejects --no-bindings), so it can't compile
-- here. add it back via a nix-provided parser if you want latex-in-markdown.
require('nvim-treesitter').install({
  "python", "typescript", "tsx", "javascript",
  "lua", "vim", "vimdoc", "query",
  "bash", "json", "yaml", "toml", "nix",
  "markdown", "markdown_inline",
  "c", "diff", "git_config", "gitcommit",
})

-- Enable treesitter highlighting (built-in neovim, new API)
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    local disabled = { latex = true, tex = true }
    if not disabled[ft] then
      pcall(vim.treesitter.start, args.buf)
    end
  end,
})

-- Set folding based on treesitter
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- Start with all folds open
vim.opt.foldenable = false

---------------------- telescope -----------------------
require('telescope').setup({
    pickers = {
      colorscheme = {
        enable_preview = true
      }
    }
  })
------------------------ file jumping ----------------------------
--- <C-v>	Go to file selection as a vsplit
--- <C-t>	Go to a file in a new tab
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', builtin.git_files, { desc = "Telescope: git files" })
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Telescope: find files" })
vim.keymap.set('n', '<leader>fg', builtin.current_buffer_fuzzy_find, { desc = "Telescope: fuzzy find in buffer" })
vim.keymap.set('n', '<C-f>', builtin.live_grep, { desc = "Telescope: live grep" })
vim.keymap.set('n', '<leader>j', builtin.jumplist, { desc = "Telescope: jumplist" })

---------------------- harpoon --------------------------
local harpoon = require("harpoon")
harpoon:setup()
vim.keymap.set('n', '<leader>ha', function() harpoon:list():add() end, { desc = "Harpoon: add file" })
vim.keymap.set('n', '<leader>hh', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon: toggle menu" })
vim.keymap.set('n', '<leader>h1', function () harpoon:list():select(1) end, { desc = "Harpoon: file 1" })
vim.keymap.set('n', '<leader>h2', function () harpoon:list():select(2) end, { desc = "Harpoon: file 2" })
vim.keymap.set('n', '<leader>h3', function () harpoon:list():select(3) end, { desc = "Harpoon: file 3" })
vim.keymap.set('n', '<leader>h4', function () harpoon:list():select(4) end, { desc = "Harpoon: file 4" })

---------------------- gitsigns -------------------------
local gitsigns = require('gitsigns')
vim.keymap.set("n", "<leader>gt", function()
    gitsigns.toggle_signs()
end, { desc = "Gitsigns: toggle signs" })

vim.keymap.set("n", "<leader>gh", function()
    gitsigns.preview_hunk_inline()
end, { desc = "Gitsigns: preview hunk inline" })

vim.keymap.set("n", "<leader>gu", function()
    gitsigns.reset_hunk()
end, { desc = "Gitsigns: reset hunk" })

vim.keymap.set("n", "<leader>gw", function()
    gitsigns.toggle_word_diff()
end, { desc = "Gitsigns: toggle word diff" })

vim.keymap.set("n", "<leader>gb", function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == 'gitsigns-blame' then
            vim.api.nvim_win_close(win, false)
            return
        end
    end
    vim.cmd('Gitsigns blame')
end, { desc = "Toggle Gitsigns blame panel" })

------------------------ LSP config ----------------------------

-- python
vim.lsp.config('pyright', {
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        extraPaths = {},
      }
    }
  }
})
vim.lsp.enable('pyright')

-- lua
vim.lsp.config('lua_ls', {
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if path ~= vim.fn.stdpath('config') and (vim.loop.fs_stat(path..'/.luarc.json') or vim.loop.fs_stat(path..'/.luarc.jsonc')) then
        return
      end
    end
    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = {
        version = 'LuaJIT'
      },
      diagnostics = {
        globals = {'vim'},
      },
      workspace = {
        checkThirdParty = false,
        library = vim.api.nvim_get_runtime_file("", true)
      }
    })
  end,
  settings = {
    Lua = {}
  }
})
vim.lsp.enable('lua_ls')

-- typescript
vim.lsp.config('ts_ls', {})
vim.lsp.enable('ts_ls')


vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
    end
    map('n', 'gd', vim.lsp.buf.definition,           'LSP: go to definition')
    map('n', 'gD', vim.lsp.buf.declaration,          'LSP: go to declaration')
    map('n', 'gi', vim.lsp.buf.implementation,       'LSP: go to implementation')
    map('n', 'gr', vim.lsp.buf.references,           'LSP: list references')
    map('n', 'K',  vim.lsp.buf.hover,                'LSP: hover docs')
    map('n', '<leader>D',  vim.lsp.buf.type_definition, 'LSP: type definition')
    map('n', '<leader>rn', vim.lsp.buf.rename,          'LSP: rename symbol')
    map({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, 'LSP: code action')
  end,
})

-- Setup Completion
-- See https://github.com/hrsh7th/nvim-cmp#basic-configuration
local lspkind = require('lspkind')
local cmp = require("cmp")
cmp.setup({
  preselect = cmp.PreselectMode.None,
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.close(),
    ["<CR>"] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = false,
    }),
  },

  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol', -- show only symbol annotations
      maxwidth = 50,
      ellipsis_char = '...',
      before = function (entry, vim_item)
        return vim_item
      end
    })
  },

  -- Installed sources
  sources = {
    { name = "nvim_lsp" },
    { name = "vsnip" },
    { name = "path" },
    { name = "buffer" },
  },
})
