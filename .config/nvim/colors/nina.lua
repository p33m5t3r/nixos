-- nina — a light, paper-and-ink colourscheme
--
-- Lives in colors/ so plain `:colorscheme nina` finds it; init.lua picks it when
-- $THEME is "nina" (set by ~/.config/hypr/theme-nina.lua). The palette is shared
-- with waybar, wofi, kitty and tmux — see ~/.config/themes/nina/palette.
--
-- Hand-written rather than a prebuilt theme because the design asks for a very
-- particular restraint: one electric blue carries every emphasis, one teal is
-- the second voice, and everything structural is grey. Syntax is deliberately
-- low-contrast — keywords are italic and dim rather than coloured, so the code
-- reads as text on a page instead of a highlighted listing.

local c = {
  paper   = '#f6f2ee',
  panel   = '#ebe9e2',
  ink     = '#14140f',
  accent  = '#2b2bd8',
  accent2 = '#1c6f68',
  sel     = '#d9d9f3',
  wash    = '#efece7',
  rule    = '#7a7a73',
  muted   = '#908f8a',
  faint   = '#b7b6b0',
  hair    = '#d5d2c8',

  red     = '#9d2233',
  green   = '#2f6d43',
  yellow  = '#8a6212',
  magenta = '#6b3fd8',
}

vim.cmd('highlight clear')
if vim.fn.exists('syntax_on') == 1 then vim.cmd('syntax reset') end
vim.o.background = 'light'
vim.g.colors_name = 'nina'

local hl = function(groups)
  for name, spec in pairs(groups) do
    vim.api.nvim_set_hl(0, name, spec)
  end
end

hl {
  ---------------------- editor chrome ----------------------
  Normal       = { fg = c.ink, bg = c.paper },
  NormalFloat  = { fg = c.ink, bg = '#fcfcfa' },
  FloatBorder  = { fg = c.rule, bg = '#fcfcfa' },
  FloatTitle   = { fg = c.accent, bg = '#fcfcfa', bold = true },
  Cursor       = { fg = c.paper, bg = c.accent },
  CursorLine   = { bg = c.wash },
  CursorColumn = { bg = c.wash },
  ColorColumn  = { bg = c.wash },
  CursorLineNr = { fg = c.accent },
  LineNr       = { fg = c.faint },
  SignColumn   = { bg = c.paper },
  VertSplit    = { fg = c.hair },
  WinSeparator = { fg = c.hair },
  Folded       = { fg = c.muted, bg = c.wash, italic = true },
  FoldColumn   = { fg = c.faint },
  Visual       = { bg = c.sel },
  Search       = { fg = c.ink, bg = '#e6dfae' },
  IncSearch    = { fg = c.paper, bg = c.accent },
  CurSearch    = { fg = c.paper, bg = c.accent },
  MatchParen   = { fg = c.accent, bold = true, underline = true },
  NonText      = { fg = c.faint },
  Whitespace   = { fg = '#dfdcd2' },
  SpecialKey   = { fg = c.faint },
  Directory    = { fg = c.accent },
  Title        = { fg = c.ink, bold = true },
  Conceal      = { fg = c.muted },
  EndOfBuffer  = { fg = c.paper },

  StatusLine   = { fg = c.ink, bg = c.panel },
  StatusLineNC = { fg = c.muted, bg = c.panel },
  TabLine      = { fg = c.muted, bg = c.panel },
  TabLineFill  = { bg = c.panel },
  TabLineSel   = { fg = c.ink, bg = c.paper, bold = true },
  WinBar       = { fg = c.muted, bg = c.paper },
  WinBarNC     = { fg = c.faint, bg = c.paper },

  Pmenu        = { fg = c.ink, bg = '#fcfcfa' },
  PmenuSel     = { fg = '#fbfbfd', bg = c.accent },
  PmenuSbar    = { bg = c.panel },
  PmenuThumb   = { bg = c.faint },
  WildMenu     = { fg = '#fbfbfd', bg = c.accent },

  ErrorMsg     = { fg = c.red, bold = true },
  WarningMsg   = { fg = c.yellow },
  ModeMsg      = { fg = c.muted },
  MoreMsg      = { fg = c.accent2 },
  Question     = { fg = c.accent2 },
  QuickFixLine = { bg = c.sel },

  ---------------------- syntax ----------------------
  -- keywords carry no colour; italic is the whole signal
  Comment     = { fg = c.muted, italic = true },
  Constant    = { fg = c.accent2 },
  String      = { fg = c.accent2 },
  Character   = { fg = c.accent2 },
  Number      = { fg = c.accent },
  Boolean     = { fg = c.accent },
  Float       = { fg = c.accent },

  Identifier  = { fg = c.ink },
  Function    = { fg = c.ink, bold = true },

  Statement   = { fg = c.ink, italic = true },
  Conditional = { fg = c.ink, italic = true },
  Repeat      = { fg = c.ink, italic = true },
  Label       = { fg = c.ink, italic = true },
  Operator    = { fg = c.muted },
  Keyword     = { fg = c.ink, italic = true },
  Exception   = { fg = c.red, italic = true },

  PreProc     = { fg = c.magenta },
  Include     = { fg = c.magenta },
  Define      = { fg = c.magenta },
  Macro       = { fg = c.magenta },
  PreCondit   = { fg = c.magenta },

  Type        = { fg = c.ink, underline = false },
  StorageClass = { fg = c.ink, italic = true },
  Structure   = { fg = c.ink },
  Typedef     = { fg = c.ink },

  Special     = { fg = c.accent },
  SpecialChar = { fg = c.accent },
  Delimiter   = { fg = c.muted },
  SpecialComment = { fg = c.muted, italic = true, bold = true },
  Debug       = { fg = c.red },

  Underlined  = { fg = c.accent, underline = true },
  Ignore      = { fg = c.faint },
  Error       = { fg = c.red, bold = true },
  Todo        = { fg = c.paper, bg = c.yellow, bold = true },

  ---------------------- treesitter ----------------------
  ['@comment']           = { link = 'Comment' },
  ['@string']            = { link = 'String' },
  ['@string.escape']     = { fg = c.accent },
  ['@number']            = { link = 'Number' },
  ['@boolean']           = { link = 'Boolean' },
  ['@constant']          = { fg = c.accent2 },
  ['@constant.builtin']  = { fg = c.accent },
  ['@variable']          = { fg = c.ink },
  ['@variable.builtin']  = { fg = c.magenta, italic = true },
  ['@variable.parameter'] = { fg = c.ink },
  ['@variable.member']   = { fg = c.ink },
  ['@property']          = { fg = c.ink },
  ['@field']             = { fg = c.ink },
  ['@function']          = { link = 'Function' },
  ['@function.builtin']  = { fg = c.magenta },
  ['@function.call']     = { fg = c.ink },
  ['@function.method']   = { link = 'Function' },
  ['@constructor']       = { fg = c.ink, bold = true },
  ['@keyword']           = { link = 'Keyword' },
  ['@keyword.operator']  = { fg = c.muted, italic = true },
  ['@keyword.import']    = { fg = c.magenta, italic = true },
  ['@keyword.return']    = { fg = c.ink, italic = true, bold = true },
  ['@operator']          = { link = 'Operator' },
  ['@punctuation.bracket']   = { fg = c.muted },
  ['@punctuation.delimiter'] = { fg = c.muted },
  ['@punctuation.special']   = { fg = c.accent },
  ['@type']              = { link = 'Type' },
  ['@type.builtin']      = { fg = c.ink, italic = true },
  ['@attribute']         = { fg = c.magenta },
  ['@tag']               = { fg = c.ink, italic = true },
  ['@tag.attribute']     = { fg = c.accent2 },
  ['@tag.delimiter']     = { fg = c.muted },
  ['@markup.heading']    = { fg = c.ink, bold = true },
  ['@markup.link']       = { fg = c.accent, underline = true },
  ['@markup.raw']        = { fg = c.accent2 },
  ['@markup.list']       = { fg = c.accent },
  ['@markup.strong']     = { bold = true },
  ['@markup.italic']     = { italic = true },
  ['@diff.plus']         = { fg = c.green },
  ['@diff.minus']        = { fg = c.red },

  ---------------------- lsp / diagnostics ----------------------
  DiagnosticError = { fg = c.red },
  DiagnosticWarn  = { fg = c.yellow },
  DiagnosticInfo  = { fg = c.accent },
  DiagnosticHint  = { fg = c.accent2 },
  DiagnosticOk    = { fg = c.green },
  DiagnosticUnderlineError = { sp = c.red, undercurl = true },
  DiagnosticUnderlineWarn  = { sp = c.yellow, undercurl = true },
  DiagnosticUnderlineInfo  = { sp = c.accent, undercurl = true },
  DiagnosticUnderlineHint  = { sp = c.accent2, undercurl = true },
  DiagnosticVirtualTextError = { fg = c.red, italic = true },
  DiagnosticVirtualTextWarn  = { fg = c.yellow, italic = true },
  DiagnosticVirtualTextInfo  = { fg = c.muted, italic = true },
  DiagnosticVirtualTextHint  = { fg = c.muted, italic = true },

  LspReferenceText  = { bg = c.sel },
  LspReferenceRead  = { bg = c.sel },
  LspReferenceWrite = { bg = c.sel, underline = true },
  LspSignatureActiveParameter = { fg = c.accent, bold = true },

  ---------------------- diff / git ----------------------
  DiffAdd    = { bg = '#e2eee5' },
  DiffChange = { bg = '#e8e8f5' },
  DiffDelete = { fg = c.red, bg = '#f3e2e4' },
  DiffText   = { bg = '#d9d9f3', bold = true },
  Added      = { fg = c.green },
  Changed    = { fg = c.accent },
  Removed    = { fg = c.red },

  GitSignsAdd    = { fg = c.green },
  GitSignsChange = { fg = c.accent },
  GitSignsDelete = { fg = c.red },

  ---------------------- plugins in use ----------------------
  -- nvim-tree
  NvimTreeNormal       = { fg = c.ink, bg = c.panel },
  NvimTreeNormalNC     = { fg = c.ink, bg = c.panel },
  NvimTreeWinSeparator = { fg = c.hair, bg = c.panel },
  NvimTreeRootFolder   = { fg = c.muted, italic = true },
  NvimTreeFolderName   = { fg = c.ink },
  NvimTreeOpenedFolderName = { fg = c.ink, bold = true },
  NvimTreeEmptyFolderName  = { fg = c.faint },
  NvimTreeFolderIcon   = { fg = c.muted },
  NvimTreeOpenedFile   = { fg = c.accent },
  NvimTreeSpecialFile  = { fg = c.accent2 },
  NvimTreeIndentMarker = { fg = c.hair },
  NvimTreeCursorLine   = { bg = '#e0ddd3' },

  -- indent-blankline (off by default; leader-w toggles it)
  IblIndent = { fg = '#e2dfd5' },
  IblScope  = { fg = c.faint },

  -- nvim-scrollbar
  ScrollbarHandle = { bg = '#e0ddd3' },
  ScrollbarCursor = { fg = c.accent },
  ScrollbarSearch = { fg = c.yellow },
  ScrollbarError  = { fg = c.red },
  ScrollbarWarn   = { fg = c.yellow },
  ScrollbarInfo   = { fg = c.accent },
  ScrollbarHint   = { fg = c.accent2 },

  -- telescope
  TelescopeNormal       = { fg = c.ink, bg = '#fcfcfa' },
  TelescopeBorder       = { fg = c.rule, bg = '#fcfcfa' },
  TelescopeTitle        = { fg = c.accent, bold = true },
  TelescopeSelection    = { fg = '#fbfbfd', bg = c.accent },
  TelescopeMatching     = { fg = c.accent2, bold = true },
  TelescopePromptPrefix = { fg = c.accent },
}
