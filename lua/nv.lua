-- nv.lua: A cleaner abstraction for Neovim's API
-- Usage: require('nv')

---@diagnostic disable: undefined-global
---@alias BufferNumber integer
---@alias WindowID integer
---@alias TabPageID integer
---@alias LineNumber integer
---@alias ColumnNumber integer

local api = vim.api
local fn = vim.fn
local cmd = vim.cmd

local M = {}

-- ================================
-- Buffer operations
-- ================================

---Get current buffer number
---@return BufferNumber
function M.buf()
  return api.nvim_get_current_buf()
end

---Get buffer by name/pattern (returns first match)
---@param pattern string Pattern to match against buffer names
---@return BufferNumber|nil
function M.buf_find(pattern)
  for _, bufnr in ipairs(api.nvim_list_bufs()) do
    local name = api.nvim_buf_get_name(bufnr)
    if name:match(pattern) then
      return bufnr
    end
  end
  return nil
end

---Create a new buffer
---@param listed boolean|nil Whether the buffer should be listed (default: false)
---@param scratch boolean|nil Whether the buffer is a scratch buffer (default: false)
---@return BufferNumber
function M.buf_new(listed, scratch)
  return api.nvim_create_buf(listed or false, scratch or false)
end

---Delete a buffer
---@param bufnr BufferNumber|nil Buffer to delete (default: current buffer)
---@param force boolean|nil Force deletion (default: false)
function M.buf_del(bufnr, force)
  bufnr = bufnr or M.buf()
  api.nvim_buf_delete(bufnr, { force = force or false })
end

---Get buffer lines
---@param start integer|nil Start line (0-indexed, default: 0)
---@param stop integer|nil End line (0-indexed, exclusive, default: -1)
---@param bufnr BufferNumber|nil Buffer to get lines from (default: current buffer)
---@return string[] Lines from the buffer
function M.lines(start, stop, bufnr)
  bufnr = bufnr or M.buf()
  start = start or 0
  stop = stop or -1
  return api.nvim_buf_get_lines(bufnr, start, stop, false)
end

---Set buffer lines
---@param lines string[] Lines to set
---@param start integer|nil Start line (0-indexed, default: 0)
---@param stop integer|nil End line (0-indexed, exclusive, default: -1)
---@param bufnr BufferNumber|nil Buffer to set lines in (default: current buffer)
function M.set_lines(lines, start, stop, bufnr)
  bufnr = bufnr or M.buf()
  start = start or 0
  stop = stop or -1
  api.nvim_buf_set_lines(bufnr, start, stop, false, lines)
end

---Get line count
---@param bufnr BufferNumber|nil Buffer to get line count from (default: current buffer)
---@return integer Number of lines in the buffer
function M.line_count(bufnr)
  bufnr = bufnr or M.buf()
  return api.nvim_buf_line_count(bufnr)
end

---Get single line content
---@param lnum LineNumber Line number (1-indexed)
---@param bufnr BufferNumber|nil Buffer to get line from (default: current buffer)
---@return string|nil Line content
function M.line(lnum, bufnr)
  bufnr = bufnr or M.buf()
  return api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1]
end

---Set single line content
---@param lnum LineNumber Line number (1-indexed)
---@param line string Line content
---@param bufnr BufferNumber|nil Buffer to set line in (default: current buffer)
function M.set_line(lnum, line, bufnr)
  bufnr = bufnr or M.buf()
  api.nvim_buf_set_lines(bufnr, lnum - 1, lnum, false, { line })
end

---Get buffer text between start and end points
---@param start_row LineNumber Start row (0-indexed)
---@param start_col ColumnNumber Start column (0-indexed)
---@param end_row LineNumber End row (0-indexed)
---@param end_col ColumnNumber End column (0-indexed)
---@param bufnr BufferNumber|nil Buffer to get text from (default: current buffer)
---@return string[] Text from the buffer
function M.text(start_row, start_col, end_row, end_col, bufnr)
  bufnr = bufnr or M.buf()
  return api.nvim_buf_get_text(
    bufnr,
    start_row,
    start_col,
    end_row,
    end_col,
    {}
  )
end

---Set buffer text between start and end points
---@param start_row LineNumber Start row (0-indexed)
---@param start_col ColumnNumber Start column (0-indexed)
---@param end_row LineNumber End row (0-indexed)
---@param end_col ColumnNumber End column (0-indexed)
---@param lines string[] Text to set
---@param bufnr BufferNumber|nil Buffer to set text in (default: current buffer)
function M.set_text(start_row, start_col, end_row, end_col, lines, bufnr)
  bufnr = bufnr or M.buf()
  api.nvim_buf_set_text(bufnr, start_row, start_col, end_row, end_col, lines)
end

-- ================================
-- Window operations
-- ================================

---Get current window
---@return WindowID
function M.win()
  return api.nvim_get_current_win()
end

---Get all windows
---@return WindowID[]
function M.wins()
  return api.nvim_list_wins()
end

---Find window displaying a buffer
---@param bufnr BufferNumber|nil Buffer to find (default: current buffer)
---@return WindowID|nil Window ID if found, nil otherwise
function M.win_find_buf(bufnr)
  bufnr = bufnr or M.buf()
  for _, winid in ipairs(M.wins()) do
    if api.nvim_win_get_buf(winid) == bufnr then
      return winid
    end
  end
  return nil
end

---Create a new window
---@param options table|nil Window options
---@return WindowID
function M.win_new(options)
  options = options or {}
  return api.nvim_open_win(
    options.bufnr or M.buf_new(true, false),
    options.enter or true,
    {
      relative = options.relative or 'editor',
      width = options.width or 80,
      height = options.height or 24,
      row = options.row or 1,
      col = options.col or 1,
      style = options.style or 'minimal',
      border = options.border or 'none',
    }
  )
end

---Close a window
---@param winid WindowID|nil Window to close (default: current window)
---@param force boolean|nil Force closure (default: false)
function M.win_close(winid, force)
  winid = winid or M.win()
  api.nvim_win_close(winid, force or false)
end

---Set buffer in window
---@param bufnr BufferNumber Buffer to set
---@param winid WindowID|nil Window to set buffer in (default: current window)
function M.win_set_buf(bufnr, winid)
  winid = winid or M.win()
  api.nvim_win_set_buf(winid, bufnr)
end

---Get window cursor position (row, col)
---@param winid WindowID|nil Window to get cursor from (default: current window)
---@return {[1]: LineNumber, [2]: ColumnNumber} Cursor position [row, col]
function M.cursor(winid)
  winid = winid or M.win()
  return api.nvim_win_get_cursor(winid)
end

---Set window cursor position
---@param row LineNumber Row (1-indexed)
---@param col ColumnNumber Column (0-indexed)
---@param winid WindowID|nil Window to set cursor in (default: current window)
function M.set_cursor(row, col, winid)
  winid = winid or M.win()
  api.nvim_win_set_cursor(winid, { row, col })
end

-- ================================
-- Tab operations
-- ================================

---Get current tabpage
---@return TabPageID
function M.tab()
  return api.nvim_get_current_tabpage()
end

---Get all tabpages
---@return TabPageID[]
function M.tabs()
  return api.nvim_list_tabpages()
end

---Create a new tabpage
---@return TabPageID
function M.tab_new()
  cmd 'tabnew'
  return M.tab()
end

---Close a tabpage
---@param tabid TabPageID|nil Tab to close (default: current tab)
function M.tab_close(tabid)
  local tab_idx = nil
  if tabid then
    for i, t in ipairs(M.tabs()) do
      if t == tabid then
        tab_idx = i
        break
      end
    end
    if tab_idx then
      cmd('tabclose ' .. tab_idx)
    end
  else
    cmd 'tabclose'
  end
end

-- ================================
-- Command/exec operations
-- ================================

---Run a Vim command
---@param command string Command to run
function M.cmd(command)
  cmd(command)
end

---Run Lua code as string
---@param code string Lua code to execute
---@return any Result of the code execution
function M.exec(code)
  return loadstring(code)()
end

-- ================================
-- Options and variables
-- ================================

---Get option value (global, buffer, window)
---@param name string Option name
---@param scope string|nil Option scope: 'global', 'buf'/'buffer', 'win'/'window' (default: 'global')
---@param id integer|nil ID of the scope object (default: current buffer/window)
---@return any Option value
function M.get(name, scope, id)
  scope = scope or 'global'
  if scope == 'buf' or scope == 'buffer' then
    return api.nvim_buf_get_option(id or M.buf(), name)
  elseif scope == 'win' or scope == 'window' then
    return api.nvim_win_get_option(id or M.win(), name)
  else
    return api.nvim_get_option(name)
  end
end

---Set option value
---@param name string Option name
---@param value any Option value
---@param scope string|nil Option scope: 'global', 'buf'/'buffer', 'win'/'window' (default: 'global')
---@param id integer|nil ID of the scope object (default: current buffer/window)
function M.set(name, value, scope, id)
  scope = scope or 'global'
  if scope == 'buf' or scope == 'buffer' then
    api.nvim_buf_set_option(id or M.buf(), name, value)
  elseif scope == 'win' or scope == 'window' then
    api.nvim_win_set_option(id or M.win(), name, value)
  else
    api.nvim_set_option(name, value)
  end
end

---Set multiple option values at once
---@param opts table Table of option names and values {option_name = value, ...}
---@param scope string|nil Option scope: 'global', 'buf'/'buffer', 'win'/'window' (default: 'global')
---@param id integer|nil ID of the scope object (default: current buffer/window)
function M.set_opts(opts, scope, id)
  for name, value in pairs(opts) do
    M.set(name, value, scope, id)
  end
end

---Get variable value (global, buffer, window, tabpage)
---@param name string Variable name
---@param scope string|nil Variable scope: 'g'/'global', 'b'/'buf', 'w'/'win', 't'/'tab' (default: 'g')
---@param id integer|nil ID of the scope object (default: current buffer/window/tab)
---@return any Variable value
function M.var(name, scope, id)
  scope = scope or 'g'
  if scope == 'b' or scope == 'buf' then
    return api.nvim_buf_get_var(id or M.buf(), name)
  elseif scope == 'w' or scope == 'win' then
    return api.nvim_win_get_var(id or M.win(), name)
  elseif scope == 't' or scope == 'tab' then
    return api.nvim_tabpage_get_var(id or M.tab(), name)
  else
    return api.nvim_get_var(name)
  end
end

---Set variable value
---@param name string Variable name
---@param value any Variable value
---@param scope string|nil Variable scope: 'g'/'global', 'b'/'buf', 'w'/'win', 't'/'tab' (default: 'g')
---@param id integer|nil ID of the scope object (default: current buffer/window/tab)
function M.set_var(name, value, scope, id)
  scope = scope or 'g'
  if scope == 'b' or scope == 'buf' then
    api.nvim_buf_set_var(id or M.buf(), name, value)
  elseif scope == 'w' or scope == 'win' then
    api.nvim_win_set_var(id or M.win(), name, value)
  elseif scope == 't' or scope == 'tab' then
    api.nvim_tabpage_set_var(id or M.tab(), name, value)
  else
    api.nvim_set_var(name, value)
  end
end

-- ================================
-- Key mappings
-- ================================

---Set keymap
---@param mode string|string[] Mode(s) for the mapping ('n', 'i', 'v', etc.)
---@param lhs string Left-hand side of the mapping
---@param rhs string|function Right-hand side of the mapping
---@param opts table|nil Options for the mapping (default: {noremap = true, silent = true})
function M.map(mode, lhs, rhs, opts)
  opts = opts or { noremap = true, silent = true }
  vim.keymap.set(mode, lhs, rhs, opts)
end

---Set keymap for normal  mode
---@param lhs string Left-hand side of the mapping
---@param rhs string|function Right-hand side of the mapping
---@param opts table|nil Options for the mapping (default: {noremap = true, silent = true})
function M.nmap(lhs, rhs, opts)
  opts = opts or { noremap = true, silent = true }
  vim.keymap.set('n', lhs, rhs, opts)
end

---Unset keymap
---@param mode string|string[] Mode(s) for the mapping ('n', 'i', 'v', etc.)
---@param lhs string Left-hand side of the mapping
function M.unmap(mode, lhs)
  vim.keymap.del(mode, lhs)
end

---Set multiple keymaps at once
---@param maps table[] Array of keymap definitions [{mode, lhs, rhs, opts}, ...]
---@param default_opts table|nil Default options to apply to all keymaps
function M.maps(maps, default_opts)
  default_opts = default_opts or { noremap = true, silent = true }
  for _, map_def in ipairs(maps) do
    local mode = map_def[1]
    local lhs = map_def[2]
    local rhs = map_def[3]
    local opts = map_def[4] or {}

    -- Merge default_opts with map-specific opts
    local merged_opts =
      vim.tbl_extend('force', vim.deepcopy(default_opts), opts)

    M.map(mode, lhs, rhs, merged_opts)
  end
end

-- ================================
-- Autocommands
-- ================================

---Create an autocommand group
---@param name string Augroup name
---@param clear boolean|nil Whether to clear existing commands (default: true)
---@return integer Augroup ID
function M.augroup(name, clear)
  clear = clear ~= false -- Default to true if nil
  return api.nvim_create_augroup(name, { clear = clear })
end

---Create an autocommand
---@param event string|string[] Event(s) to trigger on
---@param opts table Options including pattern, callback, group, etc.
---@return integer Autocommand ID
function M.autocmd(event, opts)
  return api.nvim_create_autocmd(event, opts)
end

---@alias NvAugroupCmdDefinition {event: string|string[], opts: table}

---Create multiple autocommands in a group
---@param group_name string Augroup name
---@param clear_existing_commands boolean|nil Whether to clear existing commands (default: true)
---@param definitions NvAugroupCmdDefinition[]
---@return integer Augroup ID
function M.augroup_cmds(group_name, clear_existing_commands, definitions)
  local group_id = M.augroup(group_name, clear_existing_commands)

  for _, def in ipairs(definitions) do
    local event = def[1]
    local opts = def[2] or {}
    opts.group = group_id
    M.autocmd(event, opts)
  end

  return group_id
end

-- ================================
-- User commands
-- ================================

---Create a user command
---@param name string Command name (without leading :)
---@param command function|string Command function or string
---@param opts table|nil Command options
function M.create_command(name, command, opts)
  opts = opts or {}
  api.nvim_create_user_command(name, command, opts)
end

-- ================================
-- UI operations
-- ================================

---Show a notification
---@param msg string Message to show
---@param level string|nil Log level: 'info', 'warn', 'error', 'debug', 'trace' (default: 'info')
---@param opts table|nil Additional options
function M.notify(msg, level, opts)
  level = level or 'info'
  opts = opts or {}

  local levels = {
    INFO = vim.log.levels.INFO,
    WARN = vim.log.levels.WARN,
    ERROR = vim.log.levels.ERROR,
    DEBUG = vim.log.levels.DEBUG,
    TRACE = vim.log.levels.TRACE,
    info = vim.log.levels.INFO,
    warn = vim.log.levels.WARN,
    error = vim.log.levels.ERROR,
    debug = vim.log.levels.DEBUG,
    trace = vim.log.levels.TRACE,
  }

  vim.notify(msg, levels[level] or vim.log.levels.INFO, opts)
end

---Show input prompt
---@param prompt string|nil Prompt to show
---@param default string|nil Default value
---@param completion string|nil Completion type
---@return string User input
function M.input(prompt, default, completion)
  return fn.input {
    prompt = prompt or '',
    default = default or '',
    completion = completion,
  }
end

---Show selection menu
---@param items table Items to select from
---@param prompt string|nil Prompt to show
---@param callback function Callback function to handle selection
function M.select(items, prompt, callback)
  vim.ui.select(items, { prompt = prompt or 'Select item' }, callback)
end

-- ================================
-- Utility functions
-- ================================

---Check if a buffer exists
---@param bufnr BufferNumber Buffer to check
---@return boolean
function M.buf_exists(bufnr)
  return bufnr and api.nvim_buf_is_valid(bufnr)
end

---Check if a window exists
---@param winid WindowID Window to check
---@return boolean
function M.win_exists(winid)
  return winid and api.nvim_win_is_valid(winid)
end

---Check if a tabpage exists
---@param tabid TabPageID Tab to check
---@return boolean
function M.tab_exists(tabid)
  for _, t in ipairs(M.tabs()) do
    if t == tabid then
      return true
    end
  end
  return false
end

---Get visual selection
---@return string[]|string Visual selection content
function M.visual_selection()
  local start_pos = fn.getpos "'<"
  local end_pos = fn.getpos "'>"
  local start_row, start_col = start_pos[2], start_pos[3]
  local end_row, end_col = end_pos[2], end_pos[3]

  -- Account for selection mode
  if fn.visualmode() == 'V' then -- Line-wise
    start_col = 1
    end_col = 2 ^ 31 - 1
  elseif fn.visualmode() == '\22' then -- Block-wise (^V)
    -- Complex, handling differently
    local lines = {}
    for row = start_row, end_row do
      table.insert(
        lines,
        M.text(row - 1, start_col - 1, row - 1, end_col, M.buf())
      )
    end
    return lines
  end

  return M.text(start_row - 1, start_col - 1, end_row - 1, end_col, M.buf())
end

---Check if running in headless mode
---@return boolean
function M.is_headless()
  return #api.nvim_list_uis() == 0
end

---Debounce a function
---@param func function Function to debounce
---@param timeout integer Timeout in milliseconds
---@return function Debounced function
function M.debounce(func, timeout)
  local timer = nil
  return function(...)
    if timer then
      timer:stop()
    end
    local args = { ... }
    timer = vim.loop.new_timer()
    timer:start(
      timeout,
      0,
      vim.schedule_wrap(function()
        func(unpack(args))
        timer:close()
      end)
    )
  end
end

---Throttle a function
---@param func function Function to throttle
---@param timeout integer Timeout in milliseconds
---@return function Throttled function
function M.throttle(func, timeout)
  local timer = nil
  local last_exec = 0
  return function(...)
    local current_time = vim.loop.now()
    local args = { ... }
    if current_time - last_exec >= timeout then
      func(unpack(args))
      last_exec = current_time
    elseif not timer then
      timer = vim.loop.new_timer()
      timer:start(
        timeout - (current_time - last_exec),
        0,
        vim.schedule_wrap(function()
          func(unpack(args))
          last_exec = vim.loop.now()
          timer:close()
          timer = nil
        end)
      )
    end
  end
end

-- ================================
-- LSP operations
-- ================================

---@class NvLspModule LSP operations module
local lsp = {}

---Get all active language servers for a buffer
---@param bufnr BufferNumber|nil Buffer to check (default: current buffer)
---@return table[] List of LSP clients
function lsp.get_clients(bufnr)
  bufnr = bufnr or M.buf()
  return vim.lsp.get_active_clients { bufnr = bufnr }
end

---Check if a buffer has any attached LSP clients
---@param bufnr BufferNumber|nil Buffer to check (default: current buffer)
---@return boolean True if the buffer has LSP clients
function lsp.has_clients(bufnr)
  bufnr = bufnr or M.buf()
  return #lsp.get_clients(bufnr) > 0
end

---Get a specific LSP client by ID
---@param client_id integer Client ID
---@return table|nil Client if found
function lsp.get_client(client_id)
  return vim.lsp.get_client_by_id(client_id)
end

---Start a new LSP client
---@param name string Server name
---@param opts table|nil Client options
---@return integer|nil Client ID if successful
function lsp.start(name, opts)
  opts = opts or {}
  return vim.lsp.start {
    name = name,
    cmd = opts.cmd,
    root_dir = opts.root_dir or fn.getcwd(),
  }
end

---Stop an LSP client
---@param client_id integer Client ID
function lsp.stop(client_id)
  local client = lsp.get_client(client_id)
  if client then
    client.stop()
  end
end

-- Diagnostics operations

---Get diagnostics for a buffer
---@param bufnr BufferNumber|nil Buffer to get diagnostics for (default: current buffer)
---@param opts table|nil Options for filtering diagnostics
---@return table[] Diagnostics for the buffer
function lsp.diagnostics(bufnr, opts)
  bufnr = bufnr or M.buf()
  return vim.diagnostic.get(bufnr, opts)
end

---Get diagnostics by severity
---@param severity string|integer Severity level ('error', 'warn', 'info', 'hint') or vim.diagnostic.severity enum
---@param bufnr BufferNumber|nil Buffer to get diagnostics for (default: current buffer)
---@return table[] Diagnostics with the specified severity
function lsp.diagnostics_by_severity(severity, bufnr)
  bufnr = bufnr or M.buf()

  -- Convert string severity to integer if needed
  if type(severity) == 'string' then
    local severity_map = {
      error = vim.diagnostic.severity.ERROR,
      warn = vim.diagnostic.severity.WARN,
      warning = vim.diagnostic.severity.WARN,
      info = vim.diagnostic.severity.INFO,
      information = vim.diagnostic.severity.INFO,
      hint = vim.diagnostic.severity.HINT,
    }
    severity = severity_map[severity:lower()]
  end

  return vim.diagnostic.get(bufnr, { severity = severity })
end

---Show diagnostics in a float window
---@param opts table|nil Options for the float window
function lsp.show_diagnostics(opts)
  return function()
    opts = opts or {}
    vim.diagnostic.open_float(opts)
  end
end

---Go to the previous diagnostic
---@param opts table|nil Options for movement
function lsp.prev_diagnostic(opts)
  return function()
    opts = opts or {}
    vim.diagnostic.goto_prev(opts)
  end
end

---Go to the next diagnostic
---@param opts table|nil Options for movement
function lsp.next_diagnostic(opts)
  return function()
    opts = opts or {}
    vim.diagnostic.goto_next(opts)
  end
end

---Set diagnostics to the location list
---@param opts table|nil Options for the location list
function lsp.diagnostics_setloclist(opts)
  return function()
    opts = opts or {}
    vim.diagnostic.setloclist(opts)
  end
end

-- Hover/Definition/References operations

---Show hover information
---@param opts table|nil Options for the hover request
function lsp.hover(opts)
  return function()
    opts = opts or {}
    vim.lsp.buf.hover(opts)
  end
end

---Go to definition
---@param opts table|nil Options for the definition request
function lsp.definition(opts)
  return function()
    opts = opts or {}
    vim.lsp.buf.definition(opts)
  end
end

---Go to declaration
---@param opts table|nil Options for the declaration request
function lsp.declaration(opts)
  return function()
    opts = opts or {}
    vim.lsp.buf.declaration(opts)
  end
end

---Show type definition
---@param opts table|nil Options for the type definition request
function lsp.type_definition(opts)
  return function()
    opts = opts or {}
    vim.lsp.buf.type_definition(opts)
  end
end

---Show implementations
---@param opts table|nil Options for the implementation request
function lsp.implementation(opts)
  return function()
    opts = opts or {}
    vim.lsp.buf.implementation(opts)
  end
end

---Show references
---@param opts table|nil Options for the references request
function lsp.references(opts)
  return function()
    opts = opts or { includeDeclaration = true }
    vim.lsp.buf.references(opts)
  end
end

-- Code actions/symbols operations

---Show available code actions
---@param opts table|nil Options for the code action request
function lsp.code_action(opts)
  return function()
    opts = opts or {}
    vim.lsp.buf.code_action(opts)
  end
end

---Rename symbol
---@param new_name string|nil New name (default: prompt user for name)
---@param opts table|nil Options for the rename request
function lsp.rename(new_name, opts)
  return function()
    opts = opts or {}
    vim.lsp.buf.rename(new_name, opts)
  end
end

---Show document symbols
---@param opts table|nil Options for the document symbols request
function lsp.document_symbols(opts)
  return function()
    opts = opts or {}
    vim.lsp.buf.document_symbol(opts)
  end
end

---Show workspace symbols
---@param query string|nil Query string
---@param opts table|nil Options for the workspace symbols request
function lsp.workspace_symbols(query, opts)
  return function()
    opts = opts or {}
    vim.lsp.buf.workspace_symbol(query, opts)
  end
end

-- Formatting operations

---Format current buffer
---@param opts table|nil Options for the formatting request
function lsp.format(opts)
  return function()
    opts = opts or {}
    vim.lsp.buf.format(opts)
  end
end

---Format selected range
---@param start_pos table Start position {row, col}
---@param end_pos table End position {row, col}
---@param opts table|nil Options for the range formatting request
function lsp.range_format(start_pos, end_pos, opts)
  return function()
    opts = opts or {}
    opts.range = {
      start = { line = start_pos[1], character = start_pos[2] },
      ['end'] = { line = end_pos[1], character = end_pos[2] },
    }
    vim.lsp.buf.format(opts)
  end
end

---Format visual selection
---@param opts table|nil Options for the formatting request
function lsp.format_selection(opts)
  return function()
    opts = opts or {}
    local start_pos = fn.getpos "'<"
    local end_pos = fn.getpos "'>"
    vim.lsp.buf.format {
      range = {
        start = { line = start_pos[2] - 1, character = start_pos[3] - 1 },
        ['end'] = { line = end_pos[2] - 1, character = end_pos[3] },
      },
    }
  end
end

-- Workspace operations

---Add folder to workspace
---@param workspace_folder string|nil Path to add (default: prompt user)
function lsp.add_workspace_folder(workspace_folder)
  return function()
    vim.lsp.buf.add_workspace_folder(workspace_folder)
  end
end

---Remove folder from workspace
---@param workspace_folder string|nil Path to remove (default: prompt user)
function lsp.remove_workspace_folder(workspace_folder)
  return function()
    vim.lsp.buf.remove_workspace_folder(workspace_folder)
  end
end

---List workspace folders
---@return function Function that returns workspace folders
function lsp.list_workspace_folders()
  return function()
    return vim.lsp.buf.list_workspace_folders()
  end
end

-- Signature help

---Show signature help
---@param opts table|nil Options for the signature help request
function lsp.signature_help(opts)
  return function()
    opts = opts or {}
    vim.lsp.buf.signature_help(opts)
  end
end

-- Call hierarchy

---Show incoming calls
---@param opts table|nil Options for the incoming calls request
function lsp.incoming_calls(opts)
  return function()
    opts = opts or {}
    vim.lsp.buf.incoming_calls(opts)
  end
end

---Show outgoing calls
---@param opts table|nil Options for the outgoing calls request
function lsp.outgoing_calls(opts)
  return function()
    opts = opts or {}
    vim.lsp.buf.outgoing_calls(opts)
  end
end

-- Configuration

---Create default LSP keymappings for a buffer
---@param bufnr BufferNumber|nil Buffer to set mappings for (default: current buffer)
function lsp.setup_keymaps(bufnr)
  bufnr = bufnr or M.buf()

  -- Use nv.map for key mappings with buffer local scope
  local opts = { buffer = bufnr }

  M.map('n', 'gD', lsp.declaration(), opts)
  M.map('n', 'gd', lsp.definition(), opts)
  M.map('n', 'K', lsp.hover(), opts)
  M.map('n', 'gi', lsp.implementation(), opts)
  M.map('n', '<C-k>', lsp.signature_help(), opts)
  M.map('n', '<leader>wa', lsp.add_workspace_folder(), opts)
  M.map('n', '<leader>wr', lsp.remove_workspace_folder(), opts)
  M.map('n', '<leader>wl', function()
    M.notify(vim.inspect(vim.lsp.buf.list_workspace_folders()), 'info')
  end, opts)
  M.map('n', '<leader>D', lsp.type_definition(), opts)
  M.map('n', '<leader>rn', lsp.rename(), opts)
  M.map('n', '<leader>ca', lsp.code_action(), opts)
  M.map('n', 'gr', lsp.references(), opts)
  M.map('n', '<leader>f', lsp.format { async = true }, opts)

  -- Diagnostics mappings
  M.map('n', '[d', lsp.prev_diagnostic(), opts)
  M.map('n', ']d', lsp.next_diagnostic(), opts)
  M.map('n', '<leader>e', lsp.show_diagnostics(), opts)
  M.map('n', '<leader>q', function()
    vim.diagnostic.setloclist()
  end, opts)
end

---Setup LSP client with sensible defaults
---@param server_name string LSP server name
---@param opts table|nil Extra options to pass to the server
function lsp.setup(server_name, opts)
  opts = opts or {}

  -- Set default options
  local default_opts = {
    capabilities = vim.lsp.protocol.make_client_capabilities(),
    on_attach = function(client, bufnr)
      -- Setup keymaps when LSP attaches to a buffer
      lsp.setup_keymaps(bufnr)
    end,
  }

  -- Merge default options with user options
  for k, v in pairs(opts) do
    default_opts[k] = v
  end

  -- Setup the LSP client
  require('lspconfig')[server_name].setup(default_opts)
end

-- Expose LSP module
M.lsp = lsp

-- ================================
-- Clipboard operations
-- ================================

---@class NvClipboardModule Clipboard utilities
local clipboard = {}

---Copy text to clipboard
---@param text string Text to copy
---@param to_unnamed boolean|nil Also copy to unnamed register (default: true)
---@return nil
function clipboard.copy(text, to_unnamed)
  to_unnamed = to_unnamed ~= false -- Default to true
  vim.fn.setreg('+', text) -- Copy to system clipboard
  if to_unnamed then
    vim.fn.setreg('"', text) -- Copy to unnamed register
  end
end

---Get text from clipboard
---@return string Clipboard content
function clipboard.get()
  return vim.fn.getreg '+'
end

---Copy text to clipboard and show notification
---@param text string Text to copy
---@param message string|nil Notification message (default: "Copied to clipboard")
---@param level string|nil Notification level (default: "info")
---@return nil
function clipboard.copy_with_notification(text, message, level)
  clipboard.copy(text)
  message = message or 'Copied to clipboard'
  M.notify(message, level or 'info')
end

-- Add clipboard module to nv
M.clip = clipboard

-- ================================
-- Diagnostics utilities
-- ================================

---@class NvDiagnosticsModule Diagnostic utilities
local diagnostics = {}

---Format diagnostics as text
---@param opts table|nil Options for formatting:
---  - bufnr: Buffer number (default: current buffer)
---  - title: Title for the diagnostic report (default: "Diagnostics")
---  - format: Format string for each diagnostic (default: "[%d:%d] [%s] %s")
---  - empty_message: Message when no diagnostics (default: "No diagnostics found")
---  - severity: Filter by minimum severity level (nil = all)
---@return string Formatted diagnostics text
function diagnostics.format_as_text(opts)
  opts = opts or {}
  local bufnr = opts.bufnr or M.buf()
  local diags = vim.diagnostic.get(bufnr)
  local title = opts.title or ('Diagnostics for ' .. vim.fn.bufname(bufnr))
  local format = opts.format or '[%d:%d] [%s] %s' -- [LINE:COL] [SEVERITY] MESSAGE

  local lines = {}
  table.insert(lines, '# ' .. title)
  table.insert(lines, '')

  -- Filter by severity if requested
  if opts.severity then
    local filtered = {}
    local severity_value = opts.severity

    -- Convert string severity to number if needed
    if type(severity_value) == 'string' then
      local severity_map = {
        error = vim.diagnostic.severity.ERROR,
        warn = vim.diagnostic.severity.WARN,
        warning = vim.diagnostic.severity.WARN,
        info = vim.diagnostic.severity.INFO,
        information = vim.diagnostic.severity.INFO,
        hint = vim.diagnostic.severity.HINT,
      }
      severity_value = severity_map[severity_value:lower()] or severity_value
    end

    for _, diag in ipairs(diags) do
      if diag.severity <= severity_value then
        table.insert(filtered, diag)
      end
    end
    diags = filtered
  end

  if #diags == 0 then
    table.insert(lines, opts.empty_message or 'No diagnostics found.')
  else
    for _, diag in ipairs(diags) do
      local severity = vim.diagnostic.severity[diag.severity] or 'UNKNOWN'
      local line_num = diag.lnum + 1 -- Convert to 1-based
      local col_num = diag.col + 1 -- Convert to 1-based
      local message = diag.message:gsub('\n', ' ') -- Replace newlines

      table.insert(
        lines,
        string.format(format, line_num, col_num, severity, message)
      )
    end
  end

  return table.concat(lines, '\n')
end

---Copy diagnostics to clipboard with notification
---@param opts table|nil Options for formatting (see format_as_text)
---@return nil
function diagnostics.copy_to_clipboard(opts)
  opts = opts or {}
  local bufnr = opts.bufnr or M.buf()
  local diags = vim.diagnostic.get(bufnr)
  local formatted_text = diagnostics.format_as_text(opts)

  clipboard.copy(formatted_text)

  -- Create notification message
  local count = #diags
  local message = count
    .. ' diagnostic'
    .. (count == 1 and '' or 's')
    .. ' copied to clipboard'
  M.notify(message, 'info')
end

---Get diagnostics count by severity
---@param bufnr BufferNumber|nil Buffer to check (default: current buffer)
---@return {error: integer, warn: integer, info: integer, hint: integer, total: integer}
function diagnostics.count(bufnr)
  bufnr = bufnr or M.buf()
  local all_diags = vim.diagnostic.get(bufnr)

  local counts = {
    error = 0,
    warn = 0,
    info = 0,
    hint = 0,
    total = #all_diags,
  }

  for _, diag in ipairs(all_diags) do
    if diag.severity == vim.diagnostic.severity.ERROR then
      counts.error = counts.error + 1
    elseif diag.severity == vim.diagnostic.severity.WARN then
      counts.warn = counts.warn + 1
    elseif diag.severity == vim.diagnostic.severity.INFO then
      counts.info = counts.info + 1
    elseif diag.severity == vim.diagnostic.severity.HINT then
      counts.hint = counts.hint + 1
    end
  end

  return counts
end

-- Add diagnostics module to nv
M.diag = diagnostics

-- ================================
-- Text/string utilities
-- ================================

---@class NvTextModule Text and string manipulation utilities
local text = {}

---Join lines with a separator
---@param lines string[] Lines to join
---@param separator string|nil Separator (default: newline)
---@return string
function text.join(lines, separator)
  return table.concat(lines, separator or '\n')
end

---Create a formatted list from items
---@param items table List of items
---@param opts table|nil Options for formatting:
---  - title: Optional title for the list
---  - numbered: If true, number each item (1. item)
---  - bullet: Use a bullet character instead of numbers ("- item")
---  - separator: Line separator (default: newline)
---  - empty_message: Message when list is empty
---@return string Formatted text
function text.format_list(items, opts)
  opts = opts or {}
  local lines = {}

  if opts.title then
    table.insert(lines, opts.title)
    if not opts.no_blank_after_title then
      table.insert(lines, '')
    end
  end

  if #items == 0 and opts.empty_message then
    table.insert(lines, opts.empty_message)
  else
    for i, item in ipairs(items) do
      local line
      if opts.numbered then
        line = string.format('%d. %s', i, item)
      elseif opts.bullet then
        line = string.format('%s %s', opts.bullet, item)
      else
        line = item
      end
      table.insert(lines, line)
    end
  end

  return table.concat(lines, opts.separator or '\n')
end

---Pluralize a word based on count
---@param count integer Count to check
---@param singular string Singular form
---@param plural string|nil Plural form (default: singular + "s")
---@return string Pluralized word
function text.pluralize(count, singular, plural)
  if count == 1 then
    return singular
  else
    return plural or (singular .. 's')
  end
end

-- Add text utilities to nv
M.text = text

-- ================================
-- Module exports
-- ================================

-- Set global for easy access in commands
_G.nv = M

-- Return module
return M
