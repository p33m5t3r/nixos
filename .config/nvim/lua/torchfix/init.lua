local M = {}

local torch_proc = nil
local pending_requests = {}
local current_response = {}
local in_doc = false

local function show_docs(title, content)
  local lines = vim.split(content, '\n')
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'wrap', true)
  vim.api.nvim_buf_set_option(buf, 'linebreak', true)
  
  local win = vim.api.nvim_open_win(buf, true, {  -- Change false to true here!
    relative = 'cursor', 
    width = 120, 
    height = 20, 
    col = 0, 
    row = 1,
    style = 'minimal', 
    border = 'rounded', 
    title = ' ' .. title .. ' '
  })
  
  -- Set up close keymaps
  local function close_win()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end
  
  vim.keymap.set('n', 'q', close_win, { buffer = buf })
  vim.keymap.set('n', '<Esc>', close_win, { buffer = buf })
  
  -- Also close on any movement that would leave the window
  vim.keymap.set('n', '<C-c>', close_win, { buffer = buf })
end


local function get_torch_function()
  local word = vim.fn.expand('<cword>')
  -- local word = 'SGD'
  local line = vim.api.nvim_get_current_line()
  local col = vim.fn.col('.') - 1
  local before_cursor = line:sub(1, col)
  
  -- Try to build the full torch path
  if before_cursor:match('torch%.optim%.' .. word) then
    return 'torch.optim.' .. word
  elseif before_cursor:match('torch%.nn%.functional%.' .. word) or before_cursor:match('F%.' .. word) then
    return 'torch.nn.functional.' .. word
  elseif before_cursor:match('torch%.nn%.' .. word) then
    return 'torch.nn.' .. word
  elseif before_cursor:match('torch%.' .. word) then
    return 'torch.' .. word
  else
    -- Fallback: try common patterns
    return word, {
      'torch.' .. word,
      'torch.nn.' .. word,
      'torch.nn.functional.' .. word,
      'torch.optim.' .. word,
    }
  end
end

local function start_torch_process()
  torch_proc = vim.fn.jobstart({'python3', '-c', [[
import torch
import sys
while True:
    try:
        path = input().strip()
        if path == 'EXIT':
            break
        obj = eval(path)
        doc = getattr(obj, '__doc__', None)
        print('START_DOC')
        if doc:
            print(doc)
        else:
            print('NO_DOC_FOUND')
        print('END_DOC')
        sys.stdout.flush()
    except Exception as e:
        print('START_DOC')
        print('ERROR: ' + str(e))
        print('END_DOC')
        sys.stdout.flush()
]]}, {
    on_stdout = function(_, data)
      handle_torch_response(data)
    end,
    on_exit = function()
      torch_proc = nil
    end
  })
end

function handle_torch_response(data)
  for _, line in ipairs(data) do
    if line == 'START_DOC' then
      current_response = {}
      in_doc = true
    elseif line == 'END_DOC' then
      in_doc = false
      local content = table.concat(current_response, '\n')
      if #pending_requests > 0 then
        local req = table.remove(pending_requests, 1)
        if content ~= 'NO_DOC_FOUND' and not content:match('^ERROR:') then
          show_docs(req.path, content)
        elseif #req.fallbacks > 0 then
          -- Try next fallback
          req.path = table.remove(req.fallbacks, 1)
          vim.fn.chansend(torch_proc, req.path .. '\n')
          table.insert(pending_requests, 1, req)
        else
          print("No docs found")
        end
      end
    elseif in_doc then
      table.insert(current_response, line)
    end
  end
end

local function get_torch_docs()
  if not torch_proc then
    -- print("Starting torch process...")
    start_torch_process()
    vim.defer_fn(get_torch_docs, 100) -- retry in 100ms
    return
  end
  
  local torch_path, fallbacks = get_torch_function()
  local paths_to_try = fallbacks or {torch_path}
  
  local req = {
    path = table.remove(paths_to_try, 1),
    fallbacks = paths_to_try
  }
  
  table.insert(pending_requests, req)
  vim.fn.chansend(torch_proc, req.path .. '\n')
end


-- Public API
function M.show_docs()
  get_torch_docs()
end

function M.setup(opts)
  opts = opts or {}

  -- Set up the keymap
  local keymap = opts.keymap or '<leader>t'
  vim.keymap.set('n', keymap, M.show_docs, { desc = 'PyTorch docs' })
end

return M
