---------------------- baseline options ----------------------
local home = os.getenv("HOME")
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
vim.cmd([[
  autocmd FileType lua setlocal shiftwidth=2 softtabstop=2
  autocmd FileType nix setlocal shiftwidth=2 softtabstop=2
  autocmd FileType python setlocal shiftwidth=4 softtabstop=4
  autocmd FileType typescriptreact,typescript setlocal shiftwidth=2 softtabstop=2
]])


---------------------- colorscheme ----------------------
-- vim.cmd("colorscheme peachpuff")

local theme = 'carbonfox'
local set_colorscheme = function(mode)
  if mode == 'light' then theme = 'dayfox' end
  local ok, _ = pcall(vim.cmd, string.format("colorscheme %s", theme))
  if not ok then
    vim.cmd("colorscheme default")
  end

  -- local is_tty = os.getenv('TERM') == 'tmux-256color'
  -- if is_tty then
  --     vim.cmd("colorscheme elflord") -- ron, murphy, 
  -- end

end
set_colorscheme(os.getenv('COLORCONFIG'))

---------------------- keybinds -------------------------
vim.g.mapleader = " "
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
vim.keymap.set("n", "<leader>nn", function()
  local nt_open = false
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "nerdtree" then
      nt_open = true
      break
    end
  end
  if nt_open then
    vim.cmd("NERDTreeClose")
    return
  end
  local f = vim.fn.expand("%:p")
  if f == "" or vim.fn.filereadable(f) == 0 then
    vim.cmd("NERDTree")
    return
  end
  local dir = vim.fn.fnamemodify(f, ":h")
  local root = vim.fn.systemlist({
    "git", "-C", dir, "rev-parse", "--show-toplevel"
  })[1]
  if vim.v.shell_error == 0 and root and root ~= "" then
    vim.cmd("NERDTree " .. vim.fn.fnameescape(root))
    vim.cmd("NERDTreeFind " .. vim.fn.fnameescape(f))
  else
    vim.cmd("NERDTreeFind")
  end
end, { silent = true, desc = "Toggle NERDTree (reveal buffer at git root)" })
vim.keymap.set("n", "<leader>nr", ":NERDTreeRefresh<CR>",
{ silent = true, desc = "Refresh NERDTree" })

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
-- vim.keymap.set('n', '<leader>l', ':sp | terminal lua %<CR>',
--   { noremap = true, silent = true, desc = "Run current Lua file in terminal" })

-- Completely nuke treesitter for markdown at runtime
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = { "markdown" },
--   callback = function()
--     local buf = vim.api.nvim_get_current_buf()
--     -- Stop any treesitter activity
--     pcall(vim.treesitter.stop, buf)
--     -- Force traditional syntax
--     vim.bo[buf].syntax = "markdown"
--     -- Disable concealing
--     vim.wo.conceallevel = 0
--   end,
-- })

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

-- same but haskell
vim.api.nvim_create_autocmd("FileType", {
  pattern = "haskell",
  callback = function()
    vim.keymap.set('n', '<leader>r', ':!runhaskell %<CR>', { buffer = true })
  end,
})

-- same but C
vim.api.nvim_create_autocmd("FileType", {
  pattern = "c",
  callback = function()
    vim.keymap.set('n', '<leader>rr', ':!./run.sh %<CR>', { buffer = true })
  end,
})

---------------------- packer ---------------------------
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ "git", "clone", "--depth", "1",
                "https://github.com/wbthomason/packer.nvim",
                install_path
    })
    vim.cmd([[packadd packer.nvim]])
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()
local status_ok, packer = pcall(require, 'packer')
if not status_ok then
  print("Failed to load packer")
  return
end

require("packer").startup(function(use)
  use("wbthomason/packer.nvim")

  -- treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
      ts_update()
    end,
  }

  -- use({
  -- "lukas-reineke/headlines.nvim",
  -- config = function()
  --   require("headlines").setup {
  --     markdown = {
  --       codeblock_highlight = "CodeBlock",
  --       quote_highlight = "Quote",
  --       -- Enable concealing of code blocks
  --       codeblock_concealer = true
  --     }
  --   }

  --   -- Set conceallevel for markdown files
  --   vim.api.nvim_create_autocmd("FileType", {
  --     pattern = "markdown",
  --     callback = function()
  --       vim.opt_local.conceallevel = 2
  --     end
  --   })
  -- end,
  -- })


  -- colorschemes
  use("EdenEast/nightfox.nvim")
  use("rebelot/kanagawa.nvim")
  use("rafi/awesome-vim-colorschemes")

  -- lsp
  use("neovim/nvim-lspconfig")
    use{  -- lsp progress bar
      "j-hui/fidget.nvim",
      config = function()
        require("fidget").setup({})
      end
    }
    -- autocomplete
  use("hrsh7th/nvim-cmp")
  use({
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-vsnip",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-buffer",
    after = { "hrsh7th/nvim-cmp" },
    requires = { "hrsh7th/nvim-cmp" },
  })
  use('hrsh7th/vim-vsnip')

  -- use("simrat39/rust-tools.nvim")           -- ?
  use("nvim-lua/popup.nvim")                -- ?
  -- use("ThePrimeagen/harpoon")
  use("nvim-lua/plenary.nvim")
  use {
      "ThePrimeagen/harpoon",
      branch = "harpoon2",
      requires = { {"nvim-lua/plenary.nvim"} }
  }

  -- file nav
  -- use("nvim-lua/plenary.nvim")
  -- use("nvim-telescope/telescope.nvim")
  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} }
  }

  -- line indents
  use("lukas-reineke/indent-blankline.nvim")
  local highlight = {
      -- "CursorColumn",
      "Whitespace",
      "Function",
      "Label",
  }
  local ibl = require('ibl')
  ibl.setup {
      enabled = false,
      indent = {
        highlight = highlight,
        char = "▏",
        tab_char = {"a", "b"},
      },
      whitespace = {
        highlight = highlight,
        remove_blankline_trail = false,
      },
      scope = { enabled = false },
  }
  vim.keymap.set("n", "<leader>w", vim.cmd.IBLToggle,
  { desc = "toggle indent guides" })

  -- git
  use("tpope/vim-fugitive")
  use {'lewis6991/gitsigns.nvim',
    config = function()
        require('gitsigns').setup({
            signs = {
                add = { text = '+' },
                change = { text = '~' },
                delete = { text = '-' },
            }
        })
    end
  }

  -- undo tree
  use('mbbill/undotree')

  use("onsails/lspkind.nvim")               -- lsp completion icons
  use("preservim/nerdtree")                 -- file explorer
  use("lervag/vimtex")                      -- TeX compilation
  use {                                     -- status bar
    'nvim-lualine/lualine.nvim',
    requires = { 'nvim-tree/nvim-web-devicons', opt = true }
  }
  use({                                     -- scroll bar
    "petertriho/nvim-scrollbar",
    config = function()
      require("scrollbar").setup()
    end
  })

  use('mrcjkb/haskell-tools.nvim')

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
        lualine_x = {'encoding', 'filetype'},
        lualine_y = { activelsp },
        lualine_z = {'progress'}
    },
    inactive_sections = {
        -- lualine_a = {'branch'},
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
        -- lualine_y = {'windows'},
        lualine_y = {},
        lualine_z = {}
    },
  }

  -- nvim dev lua stuff
  use {
    "folke/neodev.nvim",
      config = function()
        require("neodev").setup()
      end,
    }

  vim.opt.showmode = false
  if vim.fn.has("termguicolors") then
    vim.opt.termguicolors = true
  end
end)

if packer_bootstrap then
  require("packer").sync()
end

-- vimtex configuration
vim.g.vimtex_view_method = 'zathura'
vim.g.vimtex_compiler_method = 'latexmk'
vim.g.vimtex_compiler_latexmk = {
    options = {
        '-pdf',
        '-shell-escape',
        '-verbose',
        '-file-line-error',
        '-synctex=1',
        '-interaction=nonstopmode',
    },
}
vim.g.vimtex_quickfix_mode = 0
vim.g.tex_flavor = 'latex'
-- Disable ALL concealment to prevent crashes
-- vim.g.vimtex_syntax_conceal_enable = 0
-- vim.g.tex_conceal = ''

-- vimtex keybindings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  callback = function()
    vim.keymap.set('n', '<leader>ll', ':VimtexCompile<CR>', { buffer = true, desc = "Compile LaTeX" })
    vim.keymap.set('n', '<leader>lv', ':VimtexView<CR>', { buffer = true, desc = "View PDF" })
    vim.keymap.set('n', '<leader>lc', ':VimtexClean<CR>', { buffer = true, desc = "Clean aux files" })
    vim.keymap.set('n', '<leader>le', ':VimtexErrors<CR>', { buffer = true, desc = "Show errors" })
    vim.keymap.set('n', '<leader>lt', ':VimtexTocToggle<CR>', { buffer = true, desc = "Toggle TOC" })
  end
})

require('nvim-treesitter').setup()

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
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
-- Start with all folds open
vim.opt.foldenable = false

-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "markdown",
--   callback = function()
--     -- Set conceallevel for markdown files (you already have this)
--     vim.opt_local.conceallevel = 2
-- 
--     -- Define conceal for code block fences
--     vim.fn.matchadd('Conceal', '```\\%(\\_s*\\w*\\)\\?', 10, -1, {conceal=''})
--   end
-- })


local ht = require('haskell-tools')
local ht_bufnr = vim.api.nvim_get_current_buf()
local ht_opts = { noremap = true, silent = true, buffer = ht_bufnr }
vim.keymap.set('n', '<leader>cr', vim.lsp.codelens.run, ht_opts)
vim.keymap.set('n', '<leader>cs', ht.hoogle.hoogle_signature, ht_opts)
vim.keymap.set('n', '<leader>cg', function()
  ht.repl.toggle(vim.api.nvim_buf_get_name(0))
end, ht_opts)
vim.keymap.set('n', '<leader>cq', ht.repl.quit, ht_opts)

local telescope = require('telescope').setup({
    pickers = {
      colorscheme = {
        enable_preview = true
      }
    }
  })
require('telescope').load_extension('ht')
------------------------ file jumping ----------------------------
--- <C-v>	Go to file selection as a vsplit
--- <C-t>	Go to a file in a new tab
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.current_buffer_fuzzy_find, {})
vim.keymap.set('n', '<C-f>', builtin.live_grep, {})
vim.keymap.set('n', '<leader>j', builtin.jumplist, {})
-- vim.keymap.set('n', '

local harpoon = require("harpoon")
harpoon:setup()
vim.keymap.set('n', '<leader>ha', function() harpoon:list():add() end)
vim.keymap.set('n', '<leader>hh', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
vim.keymap.set('n', '<leader>h1', function () harpoon:list():select(1) end)
vim.keymap.set('n', '<leader>h2', function () harpoon:list():select(2) end)
vim.keymap.set('n', '<leader>h3', function () harpoon:list():select(3) end)
vim.keymap.set('n', '<leader>h4', function () harpoon:list():select(4) end)

local gitsigns = require('gitsigns')
vim.keymap.set("n", "<leader>gt", function()
    gitsigns.toggle_signs()
end)

vim.keymap.set("n", "<leader>gh", function()
    gitsigns.preview_hunk_inline()
end)

vim.keymap.set("n", "<leader>gu", function()
    gitsigns.reset_hunk()
end)

vim.keymap.set("n", "<leader>gw", function()
    gitsigns.toggle_word_diff()
end)

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

-- rust
vim.lsp.config('rust_analyzer', {
  settings = {
    ["rust-analyzer"] = {
      check = {
        command = "clippy",
      },
      diagnostics = {
        enable = true,
        experimental = {
          enable = true,
        },
      },
    },
  },
})
vim.lsp.enable('rust_analyzer')

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

-- terraform
vim.lsp.config('terraformls', {})
vim.lsp.enable('terraformls')
vim.api.nvim_create_autocmd({"BufWritePre"}, {
  pattern = {"*.tf", "*.tfvars"},
  callback = function()
    vim.lsp.buf.format()
  end,
})

-- golang
vim.lsp.config('gopls', {
  cmd = {"gopls", "serve"},
  filetypes = {"go", "gomod"},
  root_markers = {"go.work", "go.mod", ".git"},
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
    },
  },
})
vim.lsp.enable('gopls')

-- ocaml
vim.lsp.config('ocamllsp', {})
vim.lsp.enable('ocamllsp')

-- clangd
vim.lsp.config('clangd', {
  cmd = {"clangd"},
  filetypes = {"c", "cu", "cuda", "cpp", "objc", "objcpp"},
  root_markers = {"compile_commands.json", ".git"},
  settings = {
    clangd = {
      arguments = {"--background-index", "--clang-tidy"},
    },
  },
})
vim.lsp.enable('clangd')

-- haskell
-- vim.lsp.config('hls', {}); vim.lsp.enable('hls')

-- typescript
vim.lsp.config('ts_ls', {})
vim.lsp.enable('ts_ls')


vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<space>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
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

    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<Tab>"] = cmp.mapping.select_next_item(),
    -- ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    -- ["<C-f>"] = cmp.mapping.scroll_docs(4),
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
      -- The function below will be called before any actual modifications from lspkind
      -- so that you can provide more controls on popup customization. 
      -- (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
      before = function (entry, vim_item)
        return vim_item
      end
    })
  },

  -- Installed sources
  sources = {
    -- { name = "copilot" },
    { name = "nvim_lsp" },
    { name = "vsnip" },
    { name = "path" },
    { name = "buffer" },
  },
})


-- hs stuff
function OpenGhci()
  -- Get the full path of the current file
  local filename = vim.fn.expand('%:p')

  -- Open a new split
  vim.cmd('split')

  -- Open terminal in insert mode
  vim.cmd('terminal')
  vim.cmd('startinsert')

  -- Resize the split
  vim.cmd('resize 15')

  -- Function to send command to terminal
  local function send_to_terminal(command)
    vim.api.nvim_input(command)
  end

  -- Use vim.schedule to ensure the terminal is ready
  vim.schedule(function()
    -- Clear the terminal (optional)
    send_to_terminal('clear<CR>')

    -- Start GHCi and load the current file
    send_to_terminal('ghci ' .. vim.fn.shellescape(filename) .. '<CR>')
  end)
end

-- Map this function to a key, e.g., <Leader>g
vim.api.nvim_set_keymap('n', '<Leader>gg', ':lua OpenGhci()<CR>', {noremap = true, silent = true})


---------------------- custom plugins -------------------
-- require('debug-plug')
-- require('mother-nvim').setup()
-- require('torchfix').setup()

-- Visual mode mappings for LLM replace commands
vim.keymap.set('v', '<Leader>lrc', ':LLMReplaceWithContext<CR>', { noremap = true, silent = true })
vim.keymap.set('v', '<Leader>lrr', ':LLMReplace<CR>', { noremap = true, silent = true })

-- Normal mode mappings for context management
vim.keymap.set('n', '<Leader>lca', ':LLMAddFileToContext<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>lcr', ':LLMRemoveFileFromContext<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>lcl', ':LLMListContext<CR>', { noremap = true })

-- Normal mode mappings for chatting
vim.keymap.set('n', '<C-c>', ':LLMChat<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>llc', ':LLMChat<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>lls', ':LLMStop<CR>', { noremap = true })







