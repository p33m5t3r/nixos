---------------------- baseline options ----------------------
vim.opt.ignorecase = true
vim.opt.hidden = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.autoindent = true
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.undofile = true
vim.opt.showmode = false
vim.opt.smartcase = true
vim.opt.cmdheight = 0   -- no permanent cmdline row; ":" draws over the statusline
vim.opt.mouse = 'a'
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.backspace = {'indent', 'eol', 'start'}
vim.opt.clipboard = 'unnamedplus'
vim.opt.completeopt = "menuone,noinsert,noselect"
vim.opt.shortmess = vim.opt.shortmess + "c"
vim.g.netrw_bufsettings = 'noma nomod nu rnu nobl nowrap ro'
vim.cmd([[
  autocmd FileType lua setlocal shiftwidth=2 softtabstop=2
  autocmd FileType nix setlocal shiftwidth=2 softtabstop=2
  autocmd FileType python setlocal shiftwidth=4 softtabstop=4
  autocmd FileType typescriptreact,typescript setlocal shiftwidth=2 softtabstop=2
]])

vim.g.mapleader = " "
---------------------- colorscheme ----------------------
local Theme = os.getenv('THEME') or 'default'

local colorschemes = {
  default = { dark = 'nightfox', light = 'dayfox' },
  nina    = { dark = 'nina',     light = 'nina'   },
}

local set_colorscheme = function(mode)
  local pick = colorschemes[Theme] or colorschemes.default
  local name = (mode == 'light') and pick.light or pick.dark
  if not pcall(vim.cmd, 'colorscheme ' .. name) then
    vim.cmd('colorscheme default')
  end
end

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
  { "sindrets/diffview.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
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
  view = { width = 60, preserve_window_proportions = true },
  renderer = { group_empty = true },
})

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

---------------------- status bar (lualine) ------------
-- show the lsp client(s) attached to the current buffer
local function activelsp()
  local names = {}
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    names[#names + 1] = c.name
  end
  return table.concat(names, ',')
end

-- lualine builds the 'statusline' string itself and defines its own highlight
-- groups per section, per mode. That's why the colorscheme doesn't reach it and
-- it needs a theme of its own: a table of {fg,bg,gui} for sections a/b/c in
-- each mode. (nightfox.nvim ships one - `theme = 'nightfox'` - but it's the
-- blocky kind. This one is flat: shared background, colour only on the mode.)
--
-- One palette per $THEME, same slot names, so the flat() builder below is
-- written once. 'pink' is whatever colour normal mode should be.
local palettes = {
  default = {
    bg      = '#192330',
    fg      = '#cdcecf',
    dim     = '#71839b',
    faint   = '#575860',
    blue    = '#719cd6',
    green   = '#81b29a',
    magenta = '#9d79d6',
    red     = '#c94f6d',
    orange  = '#f4a261',
    cyan    = '#63cdcf',
    pink    = '#b48ead',
  },
  -- nina rations colour: the accent blue is normal mode, everything else is
  -- the darkest legible version of its hue on paper
  nina = {
    bg      = '#f6f2ee',
    fg      = '#14140f',
    dim     = '#908f8a',
    faint   = '#b7b6b0',
    blue    = '#2b2bd8',
    green   = '#2f6d43',
    magenta = '#6b3fd8',
    red     = '#9d2233',
    orange  = '#8a6212',
    cyan    = '#1c6f68',
    pink    = '#2b2bd8',
  },
}
local nf = palettes[Theme] or palettes.default

-- every section shares the editor background, so nothing reads as a block;
-- the mode word is the only thing that changes colour.
local function flat(accent)
  return {
    a = { fg = accent,   bg = nf.bg, gui = 'bold' },
    b = { fg = nf.dim,   bg = nf.bg },
    c = { fg = nf.faint, bg = nf.bg },
  }
end

local flat_theme = {
  normal   = flat(nf.pink),
  insert   = flat(nf.green),
  visual   = flat(nf.magenta),
  replace  = flat(nf.red),
  command  = flat(nf.orange),
  terminal = flat(nf.cyan),
  inactive = {
    a = { fg = nf.faint, bg = nf.bg },
    b = { fg = nf.faint, bg = nf.bg },
    c = { fg = nf.faint, bg = nf.bg },
  },
}

-- cmdheight=0 leaves nowhere for "recording @q" to appear, so show it here
local function macro_recording()
  local reg = vim.fn.reg_recording()
  if reg == '' then return '' end
  return 'rec @' .. reg
end

require('lualine').setup {
  options = {
    theme = flat_theme,
    section_separators = '',
    component_separators = '',
  },
  sections = {
      lualine_a = {{ 'mode', fmt = string.lower }},
      lualine_b = {
        { 'branch', icon = '' },
        { 'diff', symbols = { added = '+', modified = '~', removed = '-' } },
        { 'diagnostics', symbols = { error = 'E', warn = 'W', info = 'I', hint = 'H' } },
      },
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
      lualine_x = {{ macro_recording, color = { fg = nf.red, gui = 'bold' } }},
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

-- RecordingLeave fires before reg_recording() clears, hence the schedule()
vim.api.nvim_create_autocmd('RecordingEnter', {
  callback = function() require('lualine').refresh() end,
})
vim.api.nvim_create_autocmd('RecordingLeave', {
  callback = function() vim.schedule(function() require('lualine').refresh() end) end,
})

---------------------- treesitter ----------------------
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
vim.opt.foldlevelstart = 99

---------------------- telescope -----------------------
require('telescope').setup({
    pickers = {
      colorscheme = {
        enable_preview = true
      }
    }
  })
local builtin = require('telescope.builtin')
local actions = require('telescope.actions')

------------------------ marks ----------------------------

local function picker_with(picker, binds, opts)
  return function()
    picker(vim.tbl_extend('force', opts or {}, {
      attach_mappings = function(_, map)
        for _, b in ipairs(binds) do map(b[1], b[2], b[3]) end
        return true
      end,
    }))
  end
end

local function mark_entry_maker(item)
  local entry = require('telescope.make_entry').gen_from_marks({})(item)
  if not entry then return nil end
  local mark = entry.ordinal:match('^%s*(%S+)')
  local file = entry.filename or vim.api.nvim_buf_get_name(0)
  entry.display = string.format('%-3s %s:%d', mark:lower(), vim.fn.fnamemodify(file, ':t'), entry.lnum)
  return entry
end

---------------------- gitsigns -------------------------
local gitsigns = require('gitsigns')
local function diffview_toggle(args)
    if next(require('diffview.lib').views) then
        vim.cmd('DiffviewClose')
    else
        vim.cmd('DiffviewOpen ' .. args)
    end
end

------------------------- binds ------------------------------

-- core
-- a
vim.keymap.set('n', '<leader>a', picker_with(builtin.marks, {
                                   { 'n', 'dd', actions.delete_mark } },
                                   { entry_maker = mark_entry_maker }),
                                   { desc = "Telescope: marks (dd deletes)" })

-- s
vim.keymap.set('n', '<leader>s',  vim.lsp.buf.references,      { desc = 'LSP: list references' })

-- d
vim.keymap.set('n', '<leader>d',  vim.lsp.buf.definition,      { desc = 'LSP: go to definition' })
vim.keymap.set('n', '<leader>D',  vim.lsp.buf.type_definition, { desc = 'LSP: type definition' })

-- f
vim.keymap.set('n', '<leader>ff', builtin.live_grep, { desc = "Telescope: live grep" })
vim.keymap.set('n', '<leader>fd', builtin.find_files, { desc = "Telescope: find files" })
vim.keymap.set('n', '<leader>fg', builtin.git_files, { desc = "Telescope: git files" })
vim.keymap.set('n', '<leader>fc', builtin.current_buffer_fuzzy_find, { desc = "Telescope: fuzzy find in buffer" })
vim.keymap.set('n', '<leader>fw', function()
  builtin.live_grep({ default_text = vim.fn.expand("<cWORD>") })
end, { desc = "Telescope: live grep WORD under cursor" })

-- g <git stuff below>
-- h
vim.keymap.set('n', '<leader>h', builtin.jumplist, { desc = "Telescope: jumplist" })

-- j
vim.keymap.set('n', '<leader>j', '<C-i>', { desc = "travel up jump stack" })

-- k
vim.keymap.set('n', '<leader>k', '<C-o>', { desc = "travel down jump stack" })

-- l
vim.keymap.set('n', '<leader>l', '<C-t>', { desc = "pop tag stack" })

-- ;

-- text
vim.keymap.set('x', '<A-j>', ":m '>+1<CR>gv=gv",  { silent = true, desc = "Move selection down" })
vim.keymap.set('x', '<A-k>', ":m '<-2<CR>gv=gv",  { silent = true, desc = "Move selection up" })
vim.keymap.set("x", "p",     "P",                 { desc = "Paste over selection without yanking it" })

-- telescope
vim.keymap.set('n', '<leader>r', builtin.resume,  { desc = "Telescope: resume" })
vim.keymap.set('n', '<leader>t', builtin.builtin, { desc = "Telescope: pickers" })

-- file explorers
vim.keymap.set("n", "<leader>fb", function()
  vim.cmd(vim.bo.filetype == "netrw" and "Rex" or "Ex")
end, { desc = "Toggle netrw explorer" })
vim.keymap.set("n", "<leader>nn", ":NvimTreeFindFileToggle<CR>", { silent = true, desc = "Toggle nvim-tree" })
vim.keymap.set("n", "<leader>nr", ":NvimTreeRefresh<CR>", { silent = true, desc = "Refresh nvim-tree" })

-- nav
vim.keymap.set('n', '<leader>q', '<cmd>q<CR>',    { desc = "Close window" })
vim.keymap.set("n", "<C-j>",     "<C-w>j",        { desc = "Window down" })
vim.keymap.set("n", "<C-k>",     "<C-w>k",        { desc = "Window up" })
vim.keymap.set("n", "<C-l>",     "<C-w>l",        { desc = "Window right" })
vim.keymap.set("n", "<A-l>",     "gt",            { desc = "Next tab" })
vim.keymap.set('n', '<leader>nt', ':tabnew<CR>',  { silent = true, desc = "New tab" })
-- vim.keymap.set('n', '<C-f>', builtin.live_grep, { desc = "Telescope: live grep" })
-- vim.keymap.set('n', 'K',          vim.lsp.buf.hover,           { desc = 'LSP: hover docs' })

-- scrolling
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up keeping cursor centered" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down keeping cursor centered" })
vim.keymap.set("n", "n", "nzzzv",       { desc = "Next search result centered" })
vim.keymap.set("n", "N", "Nzzzv",       { desc = "Previous search result centered" })

-- misc
vim.keymap.set("n", "<leader>gs", vim.cmd.Git,          { desc = "Open Git status" })
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle,{ desc = "Toggle undotree" })
vim.keymap.set("n", "<Esc>",     "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })
vim.keymap.set("n", "<C-h>",     "<C-w>h",              { desc = "Window left" })
vim.keymap.set("n", "<A-h>",     "gT",                  { desc = "Previous tab" })

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

vim.keymap.set("n", "<leader>w", vim.cmd.IBLToggle, { desc = "toggle indent guides" })

-- marks
for c in ('abcdefghijklmnopqrstuvwxyz'):gmatch('.') do
  vim.keymap.set({ 'n', 'x', 'o' }, 'm' .. c, 'm' .. c:upper())
  vim.keymap.set({ 'n', 'x', 'o' }, "'" .. c, "'" .. c:upper())
  vim.keymap.set({ 'n', 'x', 'o' }, '`' .. c, '`' .. c:upper())
end

-- lsp
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename,                   { desc = 'LSP: rename symbol' })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float,             { desc = "Show LSP error" })
vim.keymap.set("n", "<leader>fm", function () vim.lsp.buf.format() end, { desc = "invoke lsp formatter" })
vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action,     { desc = 'LSP: code action' })
vim.keymap.set('n', 'gd',         vim.lsp.buf.definition,               { desc = 'LSP: go to definition' })
vim.keymap.set('n', 'gD',         vim.lsp.buf.declaration,              { desc = 'LSP: go to declaration' })
vim.keymap.set('n', 'gr',         vim.lsp.buf.references,               { desc = 'LSP: list references' })
vim.keymap.set('n', 'gr',         vim.lsp.buf.references,               { desc = 'LSP: list references' })

-- Git
vim.keymap.set("n", "<leader>gt", function() gitsigns.toggle_signs() end,        { desc = "toggle signs" })
vim.keymap.set("n", "<leader>gh", function() gitsigns.preview_hunk_inline() end, { desc = "preview hunk" })
vim.keymap.set("n", "<leader>gu", function() gitsigns.reset_hunk() end,          { desc = "reset hunk" })
vim.keymap.set("n", "<leader>gw", function() gitsigns.toggle_word_diff() end,    { desc = "word diff" })
vim.keymap.set("n", "<leader>gd", function() 
  diffview_toggle('main...HEAD')
end, { desc = "diff" })
vim.keymap.set("n", "<leader>gl", function()
    diffview_toggle('main...HEAD --imply-local')
end, { desc = "diff, incl. uncommitted" })
vim.keymap.set("n", "<leader>gD", function()
    diffview_toggle('')
end, { desc = "diff uncommitted only" })

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


---------------------- legacy --------------------------
-- local harpoon = require("harpoon")
-- harpoon:setup()
-- vim.keymap.set('n', '<leader>ha', function() harpoon:list():add() end, { desc = "Harpoon: add file" })
-- vim.keymap.set('n', '<leader>hh', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon: toggle menu" })
-- vim.keymap.set('n', '<leader>h1', function () harpoon:list():select(1) end, { desc = "Harpoon: file 1" })
-- vim.keymap.set('n', '<leader>h2', function () harpoon:list():select(2) end, { desc = "Harpoon: file 2" })
-- vim.keymap.set('n', '<leader>h3', function () harpoon:list():select(3) end, { desc = "Harpoon: file 3" })
-- vim.keymap.set('n', '<leader>h4', function () harpoon:list():select(4) end, { desc = "Harpoon: file 4" })

-- superseded by the global LSP keymaps in the LSP config section
-- vim.keymap.set('n', '<leader>d', function() vim.notify('no lsp', vim.log.levels.WARN) end, { desc = 'LSP: go to definition'})
-- vim.api.nvim_create_autocmd('LspAttach', {
--   group = vim.api.nvim_create_augroup('UserLspConfig', {}),
--   callback = function(ev)
--     -- Enable completion triggered by <c-x><c-o>
--     vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
--     local function map(mode, lhs, rhs, desc)
--       vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
--     end
--     map('n', 'gd', vim.lsp.buf.definition,           'LSP: go to definition')
--     map('n', '<leader>d', vim.lsp.buf.definition,     'LSP: go to definition')
--     map('n', 'gD', vim.lsp.buf.declaration,          'LSP: go to declaration')
--     map('n', 'gi', vim.lsp.buf.implementation,       'LSP: go to implementation')
--     map('n', 'gr', vim.lsp.buf.references,           'LSP: list references')
--     map('n', 'K',  vim.lsp.buf.hover,                'LSP: hover docs')
--     map('n', '<leader>D',  vim.lsp.buf.type_definition, 'LSP: type definition')
--     map('n', '<leader>rn', vim.lsp.buf.rename,          'LSP: rename symbol')
--     map({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, 'LSP: code action')
--   end,
-- })
