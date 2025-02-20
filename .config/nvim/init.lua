
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


---------------------- keybinds -------------------------
vim.g.mapleader = " "
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set('n', '<leader>nt', ':tabnew<CR>', { silent = true })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
vim.keymap.set("n", "<leader>fb", vim.cmd.Ex)
vim.keymap.set("n", "<leader>cc", function () 
    local current_cc = vim.wo.colorcolumn
    if current_cc == "" then
        vim.wo.colorcolumn = "80"
    else
        vim.wo.colorcolumn = ""
    end
end)

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

  -- colorschemes
  use("EdenEast/nightfox.nvim")
  use("rebelot/kanagawa.nvim")
  use("rafi/awesome-vim-colorschemes")
  vim.cmd("colorscheme jellybeans")
  
  -- lsp
  use("neovim/nvim-lspconfig")              
    use{  -- lsp progress bar
      "j-hui/fidget.nvim",
      config = function()
        require("fidget").setup()
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

  use("simrat39/rust-tools.nvim")           -- ?
  use("nvim-lua/popup.nvim")                -- ?
  -- file nav
  use("nvim-lua/plenary.nvim")
  use("nvim-telescope/telescope.nvim")
  use("theprimeagen/harpoon")

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

  use {                                     -- haskell
      'mrcjkb/haskell-tools.nvim',
      requires = {
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope.nvim',    -- (optional)
      },
      branch = '1.x.x',
  }
  require('lualine').setup {
    options = {
      theme = "jellybeans"
    },
    sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch', 'diff', 'diagnostics'},
        lualine_c = {'filename'},
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
  
  vim.opt.showmode = false
  if vim.fn.has("termguicolors") then
    vim.opt.termguicolors = true
  end
end)

if packer_bootstrap then
  require("packer").sync()
end


------------------------ file jumping ----------------------------
--- <C-v>	Go to file selection as a vsplit
--- <C-t>	Go to a file in a new tab
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})

local mark = require("harpoon.mark")
local ui = require("harpoon.ui")
vim.keymap.set('n', '<leader>a', mark.add_file)
vim.keymap.set('n', '<leader>h', ui.toggle_quick_menu)
vim.keymap.set('n', '<leader>g1', function () ui.nav_file(1) end)
vim.keymap.set('n', '<leader>g2', function () ui.nav_file(2) end)
vim.keymap.set('n', '<leader>g3', function () ui.nav_file(3) end)
vim.keymap.set('n', '<leader>g4', function () ui.nav_file(4) end)

vim.keymap.set("n", "<leader>gt", function()
    require('gitsigns').toggle_signs()
end)

vim.keymap.set("n", "<leader>gh", function()
    require('gitsigns').preview_hunk()
end)

------------------------ LSP config ----------------------------
local lspconfig = require('lspconfig')

-- rust
require("rust-tools").setup({
  tools = {
    runnables = {
      use_telescope = true,
    },
    inlay_hints = {
      auto = true,
      show_parameter_hints = false,
      parameter_hints_prefix = "",
      other_hints_prefix = "",
    },
  },
  server = {
    on_attach = function(client, buffer)
    end,
    settings = {
      ["rust-analyzer"] = {
        checkOnSave = {
          command = "clippy",
        },
      },
    },
  },
})

-- python
lspconfig.pylsp.setup{
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = {
            enabled = false,
        }
      }
    }
  }
}

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
lspconfig.hls.setup{}

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
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
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





