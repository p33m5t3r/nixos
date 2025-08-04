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
vim.cmd([[
  autocmd FileType lua setlocal shiftwidth=2 softtabstop=2
  autocmd FileType nix setlocal shiftwidth=2 softtabstop=2
  autocmd FileType python setlocal shiftwidth=4 softtabstop=4
]])


---------------------- colorscheme ----------------------
-- vim.cmd("colorscheme peachpuff")

local theme = 'nordfox'
local set_colorscheme = function(mode)
  if mode == 'light' then theme = 'dayfox' end
  local ok, _ = pcall(vim.cmd, string.format("colorscheme %s", theme))
  if not ok then
    vim.cmd("colorscheme default")
  end
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
  use("theprimeagen/harpoon")
  -- file nav
  -- use("nvim-lua/plenary.nvim")
  -- use("nvim-telescope/telescope.nvim")
  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} }
  }

  -- line indents
  -- use("lukas-reineke/indent-blankline.nvim")
  -- local highlight = {
  --     -- "CursorColumn",
  --     "Whitespace",
  --     "Function",
  --     "Label",
  -- }
  -- local ibl = require('ibl')
  -- ibl.setup {
  --     enabled = false,
  --     indent = { 
  --       highlight = highlight,
  --       char = "▏",
  --       tab_char = {"a", "b"},
  --     },
  --     whitespace = {
  --       highlight = highlight,
  --       remove_blankline_trail = false,
  --     },
  --     scope = { enabled = false },
  -- }
  -- vim.keymap.set("n", "<leader>w", vim.cmd.IBLToggle,
  -- { desc = "toggle indent guides" })

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
            path=3,
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
        lualine_a = {'branch'},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {'windows'},
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

require('nvim-treesitter.configs').setup {
  modules = {},
  ignore_install = {},

  -- A list of parser names, or "all" (the listed parsers should be installed)
  ensure_installed = { "c", "python", "haskell", "lua", "vim", "vimdoc", "query" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers
  auto_install = true,

  highlight = {
    enable = true,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },

  indent = {
    enable = true
  },
}

-- Set folding based on treesitter
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
-- Start with all folds open
vim.opt.foldenable = false

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    -- Set conceallevel for markdown files (you already have this)
    vim.opt_local.conceallevel = 2

    -- Define conceal for code block fences
    vim.fn.matchadd('Conceal', '```\\%(\\_s*\\w*\\)\\?', 10, -1, {conceal=''})
  end
})


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
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<C-f>', builtin.current_buffer_fuzzy_find, {})
vim.keymap.set('n', '<leader>j', builtin.jumplist, {})
-- vim.keymap.set('n', '

local mark = require("harpoon.mark")
local ui = require("harpoon.ui")
vim.keymap.set('n', '<leader>a', mark.add_file)
vim.keymap.set('n', '<leader>h', ui.toggle_quick_menu)
vim.keymap.set('n', '<leader>g1', function () ui.nav_file(1) end)
vim.keymap.set('n', '<leader>g2', function () ui.nav_file(2) end)
vim.keymap.set('n', '<leader>g3', function () ui.nav_file(3) end)
vim.keymap.set('n', '<leader>g4', function () ui.nav_file(4) end)

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

------------------------ LSP config ----------------------------
local lspconfig = require('lspconfig')

-- rust
-- require("rust-tools").setup({
--   tools = {
--     runnables = {
--       use_telescope = true,
--     },
--     -- inlay_hints = {
--     --   auto = true,
--     --   show_parameter_hints = false,
--     --   parameter_hints_prefix = "",
--     --   other_hints_prefix = "",
--     -- },
--   },
--   server = {
--     on_attach = function(_, _)
--     end,
--     settings = {
--       ["rust-analyzer"] = {
--         checkOnSave = {
--           command = "clippy",
--         },
--       },
--     },
--   },
-- })

lspconfig.rust_analyzer.setup({
  settings = {
    ["rust-analyzer"] = {
      checkOnSave = {
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

-- python
require("lspconfig").pyright.setup({
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

-- lua
require('lspconfig').lua_ls.setup {
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
        -- This is the critical part:
        library = vim.api.nvim_get_runtime_file("", true)
      }
    })
  end,
  settings = {
    Lua = {}
  }
}

-- lspconfig.pylsp.setup{
--   settings = {
--     pylsp = {
--       plugins = {
--         pycodestyle = {
--             enabled = false,
--         }
--       }
--     }
--   }
-- }

-- terraform
lspconfig.terraformls.setup{}
vim.api.nvim_create_autocmd({"BufWritePre"}, {
  pattern = {"*.tf", "*.tfvars"},
  callback = function()
    vim.lsp.buf.format()
  end,
})


-- golang
lspconfig.gopls.setup{
    cmd = {"gopls", "serve"},
    filetypes = {"go", "gomod"},
    root_dir = lspconfig.util.root_pattern("go.work", "go.mod", ".git"),
    settings = {
      gopls = {
        analyses = {
          unusedparams = true,
        },
        staticcheck = true,
      },
    },
}

-- ocaml
lspconfig.ocamllsp.setup{}

-- clangd
lspconfig.clangd.setup{
    cmd = {"clangd"},
    filetypes = {"c", "cu", "cuda", "cpp", "objc", "objcpp"},
    root_dir = lspconfig.util.root_pattern("compile_commands.json", ".git"),
    settings = {
        clangd = {
            arguments = {"--background-index", "--clang-tidy"},
        },
    },
}

-- haskell
-- lspconfig.hls.setup{}


-- typescript
lspconfig.ts_ls.setup{}


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
require('torchfix').setup()

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







