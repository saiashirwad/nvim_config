-- scratch.lua
-- A simple plugin that opens a scratch markdown file on startup
-- and provides a command to open it anytime
local M = {}

-- Path to the scratch file
M.scratch_path = vim.fn.expand '~/scratch.md'

-- Function to check if today's date header already exists
function M.has_todays_date()
  -- Get today's date in YYYY-MM-DD format
  local today = os.date '%Y-%m-%d'
  local date_pattern = '# ' .. today

  -- Use grep/rg if available to search for the date pattern
  local cmd
  if vim.fn.executable 'rg' == 1 then
    cmd = string.format(
      'rg -q "%s" %s',
      date_pattern,
      vim.fn.shellescape(M.scratch_path)
    )
  elseif vim.fn.executable 'grep' == 1 then
    cmd = string.format(
      'grep -q "%s" %s',
      date_pattern,
      vim.fn.shellescape(M.scratch_path)
    )
  else
    -- Fallback to reading the file if grep/rg not available
    local file = io.open(M.scratch_path, 'r')
    if not file then
      return false
    end
    local content = file:read '*all'
    file:close()
    return content:find(date_pattern, 1, true) ~= nil
  end

  -- Run the command and check the exit code
  local success = os.execute(cmd)
  return success == 0 or success == true
end

-- Function to add today's date
function M.add_todays_date()
  local today = os.date '%Y-%m-%d'
  local file = io.open(M.scratch_path, 'a')
  if file then
    file:write('\n\n# ' .. today .. '\n\n')
    file:close()
    return true
  end
  return false
end

-- Function to open the scratch file
function M.open_scratch()
  -- Check if the file exists, create it if it doesn't
  if vim.fn.filereadable(M.scratch_path) == 0 then
    -- Create the file with a header
    local file = io.open(M.scratch_path, 'w')
    if file then
      local today = os.date '%Y-%m-%d'
      file:write('# Scratch Notes\n\n# ' .. today .. '\n\n')
      file:close()
    end
  else
    -- File exists, check if we need to add today's date
    if not M.has_todays_date() then
      M.add_todays_date()
    end
  end

  -- Open the scratch file in the current window
  nv.cmd('edit ' .. vim.fn.fnameescape(M.scratch_path))

  -- Explicitly set filetype to markdown
  nv.set('filetype', 'markdown', 'buf')

  -- Move cursor to the end of the file
  nv.cmd 'normal! G$'
end

-- Setup function to be called in your init.lua
function M.setup(opts)
  -- Override default options with user options
  opts = opts or {}
  if opts.scratch_path then
    M.scratch_path = vim.fn.expand(opts.scratch_path)
  end

  -- Create user command to open the scratch file
  nv.create_command('OpenScratch', M.open_scratch)

  -- Auto-command to open scratch file on startup when no arguments are provided
  nv.augroup_cmds('ScratchStartup', true, {
    {
      'VimEnter',
      {
        callback = function()
          -- Only open scratch if no arguments were passed and not in diff mode
          local argc = vim.fn.argc()
          if argc == 0 and vim.o.diff == false then
            M.open_scratch()
          end
        end,
      },
    },
  })

  -- Create an autocmd to ensure markdown is recognized when opening the scratch file
  nv.augroup_cmds('ScratchFiletype', true, {
    {
      { 'BufRead', 'BufNewFile' },
      {
        pattern = '*/scratch.md',
        callback = function()
          nv.set('filetype', 'markdown', 'buf')
        end,
      },
    },
  })
end

return M
