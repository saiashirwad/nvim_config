-- nv.lua: A robust abstraction for Neovim's API
-- Usage: require('nv')

---@diagnostic disable: undefined-global

-- ================================
-- Type Definitions
-- ================================

---@alias BufferNumber integer
---@alias WindowID integer
---@alias TabPageID integer
---@alias LineNumber integer
---@alias ColumnNumber integer
---@alias Namespace integer
---@alias AutocmdID integer
---@alias AugroupID integer
---@alias UserCommandID integer
---@alias ExtmarkID integer

---@class Position
---@field row LineNumber 1-indexed row
---@field col ColumnNumber 0-indexed column

---@class Range
---@field start Position Start position
---@field end Position End position

---@class TextRange
---@field start_row LineNumber 0-indexed start row
---@field start_col ColumnNumber 0-indexed start column
---@field end_row LineNumber 0-indexed end row
---@field end_col ColumnNumber 0-indexed end column

---@class WindowConfig
---@field relative? string 'editor'|'win'|'cursor'|'mouse'
---@field win? WindowID Window ID for relative='win'
---@field anchor? string 'NW'|'NE'|'SW'|'SE'
---@field width integer Window width
---@field height integer Window height
---@field bufpos? {[1]: integer, [2]: integer} Position in buffer
---@field row integer Row position
---@field col integer Column position
---@field focusable? boolean Whether the floating window is focusable
---@field external? boolean Create as external window
---@field zindex? integer Stack order
---@field style? string 'minimal'|nil
---@field border? string|string[] Border style
---@field title? string Window title
---@field title_pos? string 'left'|'center'|'right'
---@field footer? string Window footer
---@field footer_pos? string 'left'|'center'|'right'
---@field noautocmd? boolean Don't trigger autocommands

---@class NvWindowOptions : WindowConfig
---@field bufnr? BufferNumber Buffer to display
---@field enter? boolean Enter the window

---@class NvDiagnosticOpts
---@field bufnr? BufferNumber Buffer to get diagnostics from
---@field title? string Title for diagnostic report
---@field format? string Format string for each diagnostic
---@field empty_message? string Message when no diagnostics found
---@field severity? integer|string Minimum severity level

---@class NvDiagnosticCounts
---@field error integer Number of error diagnostics
---@field warn integer Number of warning diagnostics
---@field info integer Number of info diagnostics
---@field hint integer Number of hint diagnostics
---@field total integer Total number of diagnostics

---@class NvFormatListOpts
---@field title? string Optional title for the list
---@field numbered? boolean Use numbered list
---@field bullet? string Bullet character
---@field separator? string Line separator
---@field empty_message? string Message when list is empty
---@field no_blank_after_title? boolean Don't add blank line after title

---@class NvLspOptions
---@field capabilities? table Client capabilities
---@field on_attach? fun(client: table, bufnr: BufferNumber) Function called when client attaches
---@field settings? table Server specific settings
---@field commands? table Additional commands
---@field init_options? table Initialization options
---@field root_dir? string|function Root directory or function to determine it
---@field filetypes? string[] Supported filetypes
---@field handlers? table<string, function> LSP request handlers
---@field flags? table Additional flags for the client

---@class NvHighlightOptions
---@field fg? string Foreground color
---@field bg? string Background color
---@field sp? string Special color (undercurl)
---@field blend? integer Background blend
---@field bold? boolean Bold attribute
---@field standout? boolean Standout attribute
---@field underline? boolean Underline attribute
---@field undercurl? boolean Undercurl attribute
---@field underdouble? boolean Double underline attribute
---@field underdotted? boolean Dotted underline attribute
---@field underdashed? boolean Dashed underline attribute
---@field strikethrough? boolean Strikethrough attribute
---@field italic? boolean Italic attribute
---@field reverse? boolean Reverse attribute
---@field nocombine? boolean Don't combine with other highlights
---@field link? string Link to another highlight group
---@field default? boolean Don't override existing definition

---@class NvMappingOptions
---@field noremap? boolean Don't allow remapping (default: true)
---@field silent? boolean Don't echo mapping (default: true)
---@field expr? boolean Expression mapping
---@field desc? string Description of mapping
---@field buffer? BufferNumber|boolean Buffer-local mapping
---@field nowait? boolean Don't wait for more input
---@field replace_keycodes? boolean Replace keycodes in expression
---@field unique? boolean Error if mapping exists
---@field script? boolean Use scriptrequire for remapping

---@class NvCompletionItem
---@field word string Word to complete
---@field abbr? string Abbreviation to display
---@field menu? string Extra text after match
---@field info? string Preview info
---@field kind? string Kind of completion
---@field icase? integer Case matching behavior
---@field equal? integer Apply equalalways for filtering
---@field dup? integer Handle duplicate matches
---@field empty? integer Match empty string
---@field user_data? any Custom data

---@class NvExtmarkOptions
---@field id? ExtmarkID Use this ID instead of generating one
---@field end_row? integer End row (inclusive)
---@field end_col? integer End column (exclusive)
---@field hl_group? string|integer Highlight group or ID
---@field hl_eol? boolean Highlight to end of line
---@field virt_text? table[] Virtual text to display
---@field virt_text_pos? string Virtual text position ('eol'|'overlay'|'right_align')
---@field virt_text_win_col? integer Screen column to display virtual text
---@field virt_text_hide? boolean Hide virtual text when line is folded
---@field hl_mode? string Highlight mode ('replace'|'combine'|'blend')
---@field virt_lines? table[] Virtual lines to display
---@field virt_lines_above? boolean Show virtual lines above instead of below
---@field virt_lines_leftcol? boolean Show virtual lines at left column
---@field ephemeral? boolean Remove when unfocused
---@field priority? integer Priority of extmark
---@field strict? boolean Throw error instead of adjusting position
---@field sign_text? string Text for sign column
---@field sign_hl_group? string Highlight group for sign
---@field number_hl_group? string Highlight group for line number
---@field line_hl_group? string Highlight group for line
---@field cursorline_hl_group? string Highlight group for cursorline
---@field conceal? string Character to use for concealing
---@field spell? boolean Apply spell checking
---@field ui_watched? boolean Generate events on changes
---@field url? string URL to open on right-click

---@class NvHistory
---@field histories table<string, string[]> Map of history types to their entries
---@field add fun(self:NvHistory, hist_type:string, entry:string) Add entry to history
---@field get fun(self:NvHistory, hist_type:string, count?:integer):string[] Get history entries
---@field clear fun(self:NvHistory, hist_type?:string) Clear history

---@class NvCache
---@field values table<string, any> Cached values
---@field get fun(self:NvCache, key:string, default?:any):any Get cached value
---@field set fun(self:NvCache, key:string, value:any, ttl?:integer) Set cached value
---@field has fun(self:NvCache, key:string):boolean Check if key exists
---@field remove fun(self:NvCache, key:string) Remove key from cache
---@field clear fun(self:NvCache) Clear all cached values

---@class NvUndoState
---@field seq_cur integer Current sequence number
---@field seq_last integer Last sequence number
---@field time_cur integer Time of current state
---@field save_last integer Last saved sequence
---@field entries NvUndoEntry[] Undo entries

---@class NvUndoEntry
---@field seq integer Sequence number
---@field time integer Timestamp
---@field curhead boolean Is current head
---@field alt {[1]:integer, [2]:integer} Alternate entry

local api = vim.api
local fn = vim.fn
local cmd = vim.cmd
local uv = vim.loop

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
---@param listed? boolean Only consider listed buffers
---@return BufferNumber|nil
function M.buf_find(pattern, listed)
  local buffers = api.nvim_list_bufs()

  for _, bufnr in ipairs(buffers) do
    -- Skip unlisted buffers if requested
    if listed and not api.nvim_buf_get_option(bufnr, 'buflisted') then
      goto continue
    end

    local name = api.nvim_buf_get_name(bufnr)
    if name:match(pattern) then
      return bufnr
    end

    ::continue::
  end
  return nil
end

---Find all buffers matching a pattern
---@param pattern string Pattern to match against buffer names
---@param listed? boolean Only consider listed buffers
---@return BufferNumber[]
function M.buf_find_all(pattern, listed)
  local matches = {}
  local buffers = api.nvim_list_bufs()

  for _, bufnr in ipairs(buffers) do
    -- Skip unlisted buffers if requested
    if listed and not api.nvim_buf_get_option(bufnr, 'buflisted') then
      goto continue
    end

    local name = api.nvim_buf_get_name(bufnr)
    if name:match(pattern) then
      table.insert(matches, bufnr)
    end

    ::continue::
  end
  return matches
end

---Create a new buffer
---@param opts? {listed?:boolean, scratch?:boolean, name?:string, filetype?:string} Buffer options
---@return BufferNumber
function M.buf_new(opts)
  opts = opts or {}
  local bufnr = api.nvim_create_buf(opts.listed or false, opts.scratch or false)

  -- Set name if provided
  if opts.name then
    api.nvim_buf_set_name(bufnr, opts.name)
  end

  -- Set filetype if provided
  if opts.filetype then
    api.nvim_buf_set_option(bufnr, 'filetype', opts.filetype)
  end

  return bufnr
end

---Delete a buffer
---@param bufnr? BufferNumber Buffer to delete (default: current buffer)
---@param force? boolean Force deletion (default: false)
---@param wipe? boolean Wipe buffer instead of deleting
---@return boolean Success
function M.buf_del(bufnr, force, wipe)
  bufnr = bufnr or M.buf()

  if not M.buf_exists(bufnr) then
    return false
  end

  -- Check if buffer is modified and not forced
  if not force and api.nvim_buf_get_option(bufnr, 'modified') then
    return false
  end

  if wipe then
    -- Use bwipeout command
    cmd('bwipeout' .. (force and '!' or '') .. ' ' .. bufnr)
  else
    -- Use nvim_buf_delete API
    api.nvim_buf_delete(bufnr, { force = force or false })
  end

  return true
end

---Get buffer lines
---@param start? integer Start line (0-indexed, default: 0)
---@param stop? integer End line (0-indexed, exclusive, default: -1)
---@param bufnr? BufferNumber Buffer to get lines from (default: current buffer)
---@return string[] Lines from the buffer
function M.lines(start, stop, bufnr)
  bufnr = bufnr or M.buf()
  start = start or 0
  stop = stop or -1
  return api.nvim_buf_get_lines(bufnr, start, stop, false)
end

---Set buffer lines
---@param lines string[] Lines to set
---@param start? integer Start line (0-indexed, default: 0)
---@param stop? integer End line (0-indexed, exclusive, default: -1)
---@param bufnr? BufferNumber Buffer to set lines in (default: current buffer)
function M.set_lines(lines, start, stop, bufnr)
  bufnr = bufnr or M.buf()
  start = start or 0
  stop = stop or -1
  api.nvim_buf_set_lines(bufnr, start, stop, false, lines)
end

---Get line count
---@param bufnr? BufferNumber Buffer to get line count from (default: current buffer)
---@return integer Number of lines in the buffer
function M.line_count(bufnr)
  bufnr = bufnr or M.buf()
  return api.nvim_buf_line_count(bufnr)
end

---Get single line content
---@param lnum LineNumber Line number (1-indexed)
---@param bufnr? BufferNumber Buffer to get line from (default: current buffer)
---@return string|nil Line content
function M.line(lnum, bufnr)
  bufnr = bufnr or M.buf()
  return api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1]
end

---Set single line content
---@param lnum LineNumber Line number (1-indexed)
---@param line string Line content
---@param bufnr? BufferNumber Buffer to set line in (default: current buffer)
function M.set_line(lnum, line, bufnr)
  bufnr = bufnr or M.buf()
  api.nvim_buf_set_lines(bufnr, lnum - 1, lnum, false, { line })
end

---Append lines to a buffer
---@param lines string[] Lines to append
---@param bufnr? BufferNumber Buffer to append lines to (default: current buffer)
function M.append_lines(lines, bufnr)
  bufnr = bufnr or M.buf()
  local count = M.line_count(bufnr)
  api.nvim_buf_set_lines(bufnr, count, count, false, lines)
end

---Prepend lines to a buffer
---@param lines string[] Lines to prepend
---@param bufnr? BufferNumber Buffer to prepend lines to (default: current buffer)
function M.prepend_lines(lines, bufnr)
  bufnr = bufnr or M.buf()
  api.nvim_buf_set_lines(bufnr, 0, 0, false, lines)
end

---Get buffer text between start and end points
---@param range TextRange Text range
---@param bufnr? BufferNumber Buffer to get text from (default: current buffer)
---@return string[] Text from the buffer
function M.text(range, bufnr)
  bufnr = bufnr or M.buf()
  return api.nvim_buf_get_text(
    bufnr,
    range.start_row,
    range.start_col,
    range.end_row,
    range.end_col,
    {}
  )
end

---Set buffer text between start and end points
---@param range TextRange Text range
---@param lines string[] Text to set
---@param bufnr? BufferNumber Buffer to set text in (default: current buffer)
function M.set_text(range, lines, bufnr)
  bufnr = bufnr or M.buf()
  api.nvim_buf_set_text(
    bufnr,
    range.start_row,
    range.start_col,
    range.end_row,
    range.end_col,
    lines
  )
end

---Create a scratch buffer with content
---@param content string|string[] Content to fill the buffer with
---@param opts? {filetype?:string, name?:string, listed?:boolean, mappings?:table<string,function>} Additional options
---@return BufferNumber
function M.scratch_buf(content, opts)
  opts = opts or {}

  -- Create new scratch buffer
  local bufnr = M.buf_new {
    listed = opts.listed or false,
    scratch = true,
    name = opts.name or '[Scratch]',
    filetype = opts.filetype,
  }

  -- Convert string content to table of lines
  local lines
  if type(content) == 'string' then
    lines = vim.split(content, '\n')
  else
    lines = content
  end

  -- Set content
  M.set_lines(lines, 0, -1, bufnr)

  -- Mark as unmodified
  api.nvim_buf_set_option(bufnr, 'modified', false)

  -- Set up mappings if provided
  if opts.mappings then
    for lhs, rhs in pairs(opts.mappings) do
      M.map('n', lhs, rhs, { buffer = bufnr })
    end
  end

  return bufnr
end

---Check if the buffer is empty
---@param bufnr? BufferNumber Buffer to check (default: current buffer)
---@return boolean True if buffer is empty
function M.is_buf_empty(bufnr)
  bufnr = bufnr or M.buf()
  return M.line_count(bufnr) == 1 and M.line(1, bufnr) == ''
end

---Get filetype of a buffer
---@param bufnr? BufferNumber Buffer to check (default: current buffer)
---@return string Filetype
function M.get_filetype(bufnr)
  bufnr = bufnr or M.buf()
  return api.nvim_buf_get_option(bufnr, 'filetype')
end

---Check if buffer has changed on disk
---@param bufnr? BufferNumber Buffer to check (default: current buffer)
---@return boolean True if buffer is changed on disk
function M.buf_changed_on_disk(bufnr)
  bufnr = bufnr or M.buf()
  return api.nvim_buf_get_option(bufnr, 'modified')
end

---Create namespaced buffer variable (b:)
---@param bufnr BufferNumber Buffer to set variable on
---@param namespace string Namespace prefix for variable
---@param var_name string Variable name
---@param value any Value to set
function M.buf_set_ns_var(bufnr, namespace, var_name, value)
  api.nvim_buf_set_var(bufnr, namespace .. '_' .. var_name, value)
end

---Get namespaced buffer variable (b:)
---@param bufnr BufferNumber Buffer to get variable from
---@param namespace string Namespace prefix for variable
---@param var_name string Variable name
---@param default? any Default value if not found
---@return any Value of variable or nil
function M.buf_get_ns_var(bufnr, namespace, var_name, default)
  local status, value =
    pcall(api.nvim_buf_get_var, bufnr, namespace .. '_' .. var_name)
  if not status then
    return default
  end
  return value
end

---Set buffer keymap for multiple modes
---@param modes string|string[] Mode or modes for the mapping
---@param lhs string Left-hand side of the mapping
---@param rhs string|function Right-hand side of the mapping
---@param bufnr? BufferNumber Buffer to set mapping for (default: current buffer)
---@param opts? NvMappingOptions Additional options
function M.buffer_map(modes, lhs, rhs, bufnr, opts)
  bufnr = bufnr or M.buf()
  opts = opts or {}
  opts.buffer = bufnr
  ---@diagnostic disable-next-line: param-type-mismatch
  vim.keymap.set(modes, lhs, rhs, opts)
end

-- ================================
-- Extmarks and Highlights
-- ================================

---Create a new namespace
---@param name string Namespace name
---@return Namespace
function M.create_namespace(name)
  return api.nvim_create_namespace(name)
end

---Get namespace by name
---@param name string Namespace name
---@return Namespace
function M.get_namespace(name)
  return api.nvim_get_namespace(name)
end

---Set an extmark
---@param namespace Namespace|string Namespace ID or name
---@param bufnr? BufferNumber Buffer to set mark in (default: current)
---@param row integer Line number (0-indexed)
---@param col integer Column number (0-indexed)
---@param opts? NvExtmarkOptions Extmark options
---@return ExtmarkID
function M.set_extmark(namespace, bufnr, row, col, opts)
  bufnr = bufnr or M.buf()
  opts = opts or {}

  -- Convert namespace name to ID if needed
  if type(namespace) == 'string' then
    namespace = api.nvim_create_namespace(namespace)
  end

  return api.nvim_buf_set_extmark(bufnr, namespace, row, col, opts)
end

---Delete an extmark
---@param namespace Namespace|string Namespace ID or name
---@param bufnr? BufferNumber Buffer containing the mark (default: current)
---@param id ExtmarkID Extmark ID to delete
---@return boolean Success
function M.del_extmark(namespace, bufnr, id)
  bufnr = bufnr or M.buf()

  -- Convert namespace name to ID if needed
  if type(namespace) == 'string' then
    namespace = api.nvim_get_namespace(namespace)
  end

  return api.nvim_buf_del_extmark(bufnr, namespace, id)
end

---Get extmark by ID
---@param namespace Namespace|string Namespace ID or name
---@param bufnr? BufferNumber Buffer containing the mark (default: current)
---@param id ExtmarkID Extmark ID to retrieve
---@param opts? table Options for retrieval
---@return table Extmark details
function M.get_extmark(namespace, bufnr, id, opts)
  bufnr = bufnr or M.buf()
  opts = opts or {}

  -- Convert namespace name to ID if needed
  if type(namespace) == 'string' then
    namespace = api.nvim_get_namespace(namespace)
  end

  return api.nvim_buf_get_extmark_by_id(bufnr, namespace, id, opts)
end

---Get extmarks in a range
---@param namespace Namespace|string Namespace ID or name
---@param bufnr? BufferNumber Buffer to query (default: current)
---@param start_pos {[1]:integer, [2]:integer} Start position [row, col]
---@param end_pos {[1]:integer, [2]:integer} End position [row, col]
---@param opts? table Additional options
---@return table[] List of extmarks
function M.get_extmarks(namespace, bufnr, start_pos, end_pos, opts)
  bufnr = bufnr or M.buf()
  opts = opts or {}

  -- Convert namespace name to ID if needed
  if type(namespace) == 'string' then
    namespace = api.nvim_get_namespace(namespace)
  end

  return api.nvim_buf_get_extmarks(bufnr, namespace, start_pos, end_pos, opts)
end

---Clear extmarks in a range
---@param namespace Namespace|string Namespace ID or name
---@param bufnr? BufferNumber Buffer to clear marks from (default: current)
---@param start_pos {[1]:integer, [2]:integer}|nil Start position [row, col] (nil = beginning)
---@param end_pos {[1]:integer, [2]:integer}|nil End position [row, col] (nil = end)
function M.clear_extmarks(namespace, bufnr, start_pos, end_pos)
  bufnr = bufnr or M.buf()

  -- Convert namespace name to ID if needed
  if type(namespace) == 'string' then
    namespace = api.nvim_get_namespace(namespace)
  end

  start_pos = start_pos or { 0, 0 }
  end_pos = end_pos or { -1, -1 }

  -- Get and delete all extmarks in range
  local marks =
    api.nvim_buf_get_extmarks(bufnr, namespace, start_pos, end_pos, {})
  for _, mark in ipairs(marks) do
    local id = mark[1]
    api.nvim_buf_del_extmark(bufnr, namespace, id)
  end
end

---Create or update a highlight group
---@param name string Highlight group name
---@param opts NvHighlightOptions Highlight attributes
function M.set_highlight(name, opts)
  api.nvim_set_hl(0, name, opts)
end

---Get highlight group definition
---@param name string Highlight group name
---@param as_rgb? boolean Return RGB colors rather than names
---@return table Highlight attributes
function M.get_highlight(name, as_rgb)
  return api.nvim_get_hl(
    0,
    { name = name, link = false, create = false, rgb = as_rgb }
  )
end

---Clear a highlight group
---@param name string Highlight group name
function M.clear_highlight(name)
  pcall(api.nvim_set_hl, 0, name, {})
end

---Highlight a region of text
---@param bufnr? BufferNumber Buffer to highlight (default: current)
---@param namespace Namespace|string Namespace ID or name
---@param hl_group string Highlight group name
---@param range TextRange Range to highlight
---@param priority? integer Priority of highlight (higher = stronger)
---@return ExtmarkID
function M.highlight_range(bufnr, namespace, hl_group, range, priority)
  bufnr = bufnr or M.buf()

  -- Convert namespace name to ID if needed
  if type(namespace) == 'string' then
    namespace = api.nvim_create_namespace(namespace)
  end

  return api.nvim_buf_set_extmark(
    bufnr,
    namespace,
    range.start_row,
    range.start_col,
    {
      end_row = range.end_row,
      end_col = range.end_col,
      hl_group = hl_group,
      priority = priority or 100,
    }
  )
end

---Highlight a line
---@param bufnr? BufferNumber Buffer to highlight (default: current)
---@param namespace Namespace|string Namespace ID or name
---@param hl_group string Highlight group name
---@param line_num integer Line number (0-indexed)
---@param priority? integer Priority of highlight
---@return ExtmarkID
function M.highlight_line(bufnr, namespace, hl_group, line_num, priority)
  bufnr = bufnr or M.buf()

  -- Convert namespace name to ID if needed
  if type(namespace) == 'string' then
    namespace = api.nvim_create_namespace(namespace)
  end

  return api.nvim_buf_set_extmark(bufnr, namespace, line_num, 0, {
    line_hl_group = hl_group,
    priority = priority or 100,
  })
end

---Add virtual text to a line
---@param bufnr? BufferNumber Buffer to add text to (default: current)
---@param namespace Namespace|string Namespace ID or name
---@param line_num integer Line number (0-indexed)
---@param chunks {[1]:string, [2]:string}[] Text chunks with highlight groups
---@param opts? table Additional options
---@return ExtmarkID
function M.set_virtual_text(bufnr, namespace, line_num, chunks, opts)
  bufnr = bufnr or M.buf()
  opts = opts or {}

  -- Convert namespace name to ID if needed
  if type(namespace) == 'string' then
    namespace = api.nvim_create_namespace(namespace)
  end

  return api.nvim_buf_set_extmark(bufnr, namespace, line_num, 0, {
    virt_text = chunks,
    virt_text_pos = opts.pos or 'eol',
    virt_text_win_col = opts.win_col,
    hl_mode = opts.hl_mode or 'combine',
    priority = opts.priority or 100,
  })
end

---Add virtual lines at a position
---@param bufnr? BufferNumber Buffer to add virtual lines to (default: current)
---@param namespace Namespace|string Namespace ID or name
---@param line_num integer Line number (0-indexed)
---@param chunks {[1]:string, [2]:string}[][] Text chunks for each virtual line
---@param opts? table Additional options
---@return ExtmarkID
function M.set_virtual_lines(bufnr, namespace, line_num, chunks, opts)
  bufnr = bufnr or M.buf()
  opts = opts or {}

  -- Convert namespace name to ID if needed
  if type(namespace) == 'string' then
    namespace = api.nvim_create_namespace(namespace)
  end

  return api.nvim_buf_set_extmark(bufnr, namespace, line_num, 0, {
    virt_lines = chunks,
    virt_lines_above = opts.above,
    hl_mode = opts.hl_mode or 'combine',
    priority = opts.priority or 100,
  })
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
---@param bufnr? BufferNumber|nil Buffer to find (default: current buffer)
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

---Find all windows displaying a buffer
---@param bufnr? BufferNumber Buffer to find (default: current buffer)
---@return WindowID[] Array of window IDs
function M.win_find_buf_all(bufnr)
  bufnr = bufnr or M.buf()
  local windows = {}

  for _, winid in ipairs(M.wins()) do
    if api.nvim_win_get_buf(winid) == bufnr then
      table.insert(windows, winid)
    end
  end

  return windows
end

---Create a new window
---@param opts? NvWindowOptions Window options
---@return WindowID
function M.win_new(opts)
  opts = opts or {}

  -- Create default buffer if none specified
  local bufnr = opts.bufnr or M.buf_new { listed = false, scratch = true }

  -- Prepare window config
  local config = {
    relative = opts.relative or 'editor',
    width = opts.width or 80,
    height = opts.height or 24,
    row = opts.row or 1,
    col = opts.col or 1,
    style = opts.style or 'minimal',
    border = opts.border or 'none',
    title = opts.title,
    title_pos = opts.title_pos,
    footer = opts.footer,
    footer_pos = opts.footer_pos,
    zindex = opts.zindex,
    focusable = opts.focusable ~= false,
    noautocmd = opts.noautocmd,
  }

  -- Handle window-relative positioning
  if opts.relative == 'win' then
    config.win = opts.win or api.nvim_get_current_win()
  end

  return api.nvim_open_win(bufnr, opts.enter ~= false, config)
end

---Close a window
---@param winid? WindowID Window to close (default: current window)
---@param force? boolean Force closure (default: false)
---@return boolean Success
function M.win_close(winid, force)
  winid = winid or M.win()

  if not M.win_exists(winid) then
    return false
  end

  pcall(api.nvim_win_close, winid, force or false)
  return not M.win_exists(winid)
end

---Set buffer in window
---@param bufnr BufferNumber Buffer to set
---@param winid? WindowID Window to set buffer in (default: current window)
function M.win_set_buf(bufnr, winid)
  winid = winid or M.win()
  api.nvim_win_set_buf(winid, bufnr)
end

---Get window cursor position (row, col)
---@param winid? WindowID Window to get cursor from (default: current window)
---@return {[1]: LineNumber, [2]: ColumnNumber} Cursor position [row, col]
function M.cursor(winid)
  winid = winid or M.win()
  return api.nvim_win_get_cursor(winid)
end

---Set window cursor position
---@param row LineNumber Row (1-indexed)
---@param col ColumnNumber Column (0-indexed)
---@param winid? WindowID Window to set cursor in (default: current window)
function M.set_cursor(row, col, winid)
  winid = winid or M.win()
  api.nvim_win_set_cursor(winid, { row, col })
end

---Save window view
---@param winid? WindowID Window to save view of (default: current window)
---@return table View data
function M.win_save_view(winid)
  winid = winid or M.win()
  return {
    cursor = api.nvim_win_get_cursor(winid),
    topline = api.nvim_call_function('line', { 'w0' }),
    botline = api.nvim_call_function('line', { 'w$' }),
  }
end

---Restore window view
---@param view table View data from win_save_view
---@param winid? WindowID Window to restore view of (default: current window)
function M.win_restore_view(view, winid)
  winid = winid or M.win()

  if M.win_exists(winid) then
    -- Set cursor position
    if view.cursor then
      pcall(api.nvim_win_set_cursor, winid, view.cursor)
    end

    -- Scroll to restore view if needed
    if view.topline then
      pcall(api.nvim_command, 'normal! ' .. view.topline .. 'zt')
    end
  end
end

---Check if window is a floating window
---@param winid? WindowID Window to check (default: current window)
---@return boolean True if window is floating
function M.win_is_float(winid)
  winid = winid or M.win()
  return api.nvim_win_get_config(winid).relative ~= ''
end

---Get window dimensions and position
---@param winid? WindowID Window to get dimensions of (default: current window)
---@return {width:integer, height:integer, row:integer, col:integer} Dimensions
function M.win_get_dimensions(winid)
  winid = winid or M.win()

  local config = api.nvim_win_get_config(winid)

  return {
    width = config.width,
    height = config.height,
    row = config.row,
    col = config.col,
  }
end

---Set window dimensions and position
---@param winid? WindowID Window to set dimensions of (default: current window)
---@param width? integer New width
---@param height? integer New height
---@param row? integer New row position
---@param col? integer New column position
function M.win_set_dimensions(winid, width, height, row, col)
  winid = winid or M.win()

  local config = api.nvim_win_get_config(winid)

  -- Only modify provided dimensions
  if width then
    config.width = width
  end
  if height then
    config.height = height
  end
  if row then
    config.row = row
  end
  if col then
    config.col = col
  end

  api.nvim_win_set_config(winid, config)
end

---Get window option
---@param name string Option name
---@param winid? WindowID Window to get option from (default: current window)
---@return any Option value
function M.win_get_option(name, winid)
  winid = winid or M.win()
  return api.nvim_win_get_option(winid, name)
end

---Set window option
---@param name string Option name
---@param value any Option value
---@param winid? WindowID Window to set option for (default: current window)
function M.win_set_option(name, value, winid)
  winid = winid or M.win()
  api.nvim_win_set_option(winid, name, value)
end

---Set multiple window options at once
---@param opts table<string, any> Table of option names and values
---@param winid? WindowID Window to set options for (default: current window)
function M.win_set_options(opts, winid)
  winid = winid or M.win()

  for name, value in pairs(opts) do
    pcall(api.nvim_win_set_option, winid, name, value)
  end
end

---Get window height
---@param winid? WindowID Window to get height of (default: current window)
---@return integer Window height
function M.win_get_height(winid)
  winid = winid or M.win()
  return api.nvim_win_get_height(winid)
end

---Set window height
---@param height integer New height
---@param winid? WindowID Window to set height of (default: current window)
function M.win_set_height(height, winid)
  winid = winid or M.win()
  api.nvim_win_set_height(winid, height)
end

---Get window width
---@param winid? WindowID Window to get width of (default: current window)
---@return integer Window width
function M.win_get_width(winid)
  winid = winid or M.win()
  return api.nvim_win_get_width(winid)
end

---Set window width
---@param width integer New width
---@param winid? WindowID Window to set width of (default: current window)
function M.win_set_width(width, winid)
  winid = winid or M.win()
  api.nvim_win_set_width(winid, width)
end

---Create or reuse a split window
---@param direction? 'horizontal'|'vertical'|'tab' Split direction (default: 'horizontal')
---@param bufnr? BufferNumber Buffer to display in the split (default: current buffer)
---@param focus? boolean Focus the new split (default: true)
---@return WindowID
function M.split(direction, bufnr, focus)
  direction = direction or 'horizontal'
  bufnr = bufnr or M.buf()

  if focus == nil then
    focus = true
  end

  local cmd_table = {
    horizontal = 'split',
    vertical = 'vsplit',
    tab = 'tabnew',
  }

  local command = cmd_table[direction]
  if not command then
    error('Invalid split direction: ' .. direction)
  end

  -- Create the split
  cmd(command)

  -- Get the window and set the buffer
  local winid = M.win()
  M.win_set_buf(bufnr, winid)

  -- Return to previous window if not focusing
  if not focus then
    cmd 'wincmd p'
  end

  return winid
end

---Create a centered floating window
---@param opts? NvWindowOptions Window options
---@return WindowID, BufferNumber Window ID and buffer number
function M.centered_float(opts)
  opts = opts or {}

  -- Get editor dimensions
  local editor_width = vim.o.columns
  local editor_height = vim.o.lines

  -- Calculate window size (default to 80% of editor size)
  local width = opts.width or math.floor(editor_width * 0.8)
  local height = opts.height or math.floor(editor_height * 0.8)

  -- Calculate position (centered)
  local row = math.floor((editor_height - height) / 2)
  local col = math.floor((editor_width - width) / 2)

  -- Create buffer if not provided
  local bufnr = opts.bufnr
    or M.buf_new {
      listed = opts.listed or false,
      scratch = opts.scratch ~= false,
    }

  -- Create window configuration
  local win_opts = vim.tbl_extend('force', opts, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = opts.style or 'minimal',
    border = opts.border or 'rounded',
    bufnr = bufnr,
  })

  -- Create window
  local winid = M.win_new(win_opts)

  return winid, bufnr
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
---@param focus? boolean Focus the new tab (default: true)
---@param bufnr? BufferNumber Buffer to display in the new tab
---@return TabPageID
function M.tab_new(focus, bufnr)
  if focus == nil then
    focus = true
  end

  -- Save current tab to return to if not focusing
  local current_tab = nil
  if not focus then
    current_tab = M.tab()
  end

  -- Create new tab
  cmd 'tabnew'
  local new_tab = M.tab()

  -- Set buffer if specified
  if bufnr then
    M.win_set_buf(bufnr, api.nvim_tabpage_get_win(new_tab))
  end

  -- Return to previous tab if not focusing
  if not focus and current_tab then
    for i, tabid in ipairs(M.tabs()) do
      if tabid == current_tab then
        cmd(i .. 'tabnext')
        break
      end
    end
  end

  return new_tab
end

---Close a tabpage
---@param tabid? TabPageID Tab to close (default: current tab)
---@return boolean Success
function M.tab_close(tabid)
  tabid = tabid or M.tab()

  if not M.tab_exists(tabid) then
    return false
  end

  -- Find tab index
  local tab_idx = nil
  for i, t in ipairs(M.tabs()) do
    if t == tabid then
      tab_idx = i
      break
    end
  end

  if tab_idx then
    pcall(cmd, 'tabclose ' .. tab_idx)
    return not M.tab_exists(tabid)
  end

  return false
end

---Get all windows in a tabpage
---@param tabid? TabPageID Tab to get windows from (default: current tab)
---@return WindowID[]
function M.tab_win_list(tabid)
  tabid = tabid or M.tab()
  return api.nvim_tabpage_list_wins(tabid)
end

---Get active window in a tabpage
---@param tabid? TabPageID Tab to get active window from (default: current tab)
---@return WindowID
function M.tab_active_win(tabid)
  tabid = tabid or M.tab()
  return api.nvim_tabpage_get_win(tabid)
end

---Set active window in a tabpage
---@param winid WindowID Window to make active
---@param tabid? TabPageID Tab to set active window in (default: current tab)
function M.tab_set_active_win(winid, tabid)
  tabid = tabid or M.tab()

  -- Check if window is in the tabpage
  for _, tab_win in ipairs(M.tab_win_list(tabid)) do
    if tab_win == winid then
      api.nvim_set_current_win(winid)
      return true
    end
  end

  return false
end

---Get tabpage variable
---@param name string Variable name
---@param tabid? TabPageID Tab to get variable from (default: current tab)
---@param default? any Default value if not found
---@return any
function M.tab_var(name, tabid, default)
  tabid = tabid or M.tab()
  local status, value = pcall(api.nvim_tabpage_get_var, tabid, name)
  if not status then
    return default
  end
  return value
end

---Set tabpage variable
---@param name string Variable name
---@param value any Value to set
---@param tabid? TabPageID Tab to set variable on (default: current tab)
function M.tab_set_var(name, value, tabid)
  tabid = tabid or M.tab()
  api.nvim_tabpage_set_var(tabid, name, value)
end

---Get tab number for a tabpage
---@param tabid? TabPageID Tab to get number for (default: current tab)
---@return integer Tab number (1-indexed)
function M.tab_get_number(tabid)
  tabid = tabid or M.tab()
  return api.nvim_tabpage_get_number(tabid)
end

---Go to a specific tab by number
---@param tab_number integer Tab number (1-indexed)
---@return boolean Success
function M.goto_tab(tab_number)
  if tab_number < 1 or tab_number > #M.tabs() then
    return false
  end

  cmd(tab_number .. 'tabnext')
  return true
end

-- ================================
-- Command/exec operations
-- ================================

---Run a Vim command
---@param command string Command to run
---@param silent? boolean Run silently (default: false)
---@param output? boolean Capture output (default: false)
---@return string|nil Command output if requested
function M.cmd(command, silent, output)
  if output then
    return api.nvim_exec2(command, { output = true }).output
  else
    if silent then
      cmd('silent! ' .. command)
    else
      cmd(command)
    end
    return nil
  end
end

---Run Lua code as string
---@param code string Lua code to execute
---@param safe? boolean Use pcall for safety (default: false)
---@return any, string|nil Result of the code execution, error message if safe is true
function M.exec(code, safe)
  if safe then
    local fn, err = loadstring(code)
    if not fn then
      return nil, 'Compilation error: ' .. err
    end
    local success, result = pcall(fn)
    if not success then
      return nil, 'Runtime error: ' .. result
    end
    return result
  else
    return loadstring(code)()
  end
end

---Execute a shell command and return the output
---@param cmd string Command to execute
---@param timeout? integer Timeout in milliseconds
---@param show_errors? boolean Show error messages (default: false)
---@return string|nil stdout output, string|nil stderr output
function M.system(cmd, timeout, show_errors)
  local stdout = {}
  local stderr = {}
  local handle

  -- Determine appropriate shell
  local shell = vim.o.shell
  local shellcmdflag = vim.o.shellcmdflag

  -- Setup command with appropriate shell
  local command = shell .. ' ' .. shellcmdflag .. ' ' .. cmd

  -- Create job
  handle = vim.fn.jobstart(command, {
    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= '' then
            table.insert(stdout, line)
          end
        end
      end
    end,
    on_stderr = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= '' then
            table.insert(stderr, line)
          end
        end
      end
    end,
    stdout_buffered = true,
    stderr_buffered = true,
  })

  -- Wait for job to complete
  local res = vim.fn.jobwait({ handle }, timeout or -1)[1]

  -- Handle errors
  if res == -1 then
    vim.fn.jobstop(handle)
    return nil, 'Command timed out'
  elseif res == -2 then
    return nil, 'Command interrupted'
  elseif res ~= 0 and show_errors then
    local err = table.concat(stderr, '\n')
    if err and err ~= '' then
      M.notify('Command failed: ' .. err, 'error')
    else
      M.notify('Command failed with exit code ' .. res, 'error')
    end
  end

  return table.concat(stdout, '\n'), table.concat(stderr, '\n')
end

-- ================================
-- Options and variables
-- ================================

---Get option value (global, buffer, window)
---@param name string Option name
---@param scope? 'global'|'buf'|'buffer'|'win'|'window' Option scope (default: 'global')
---@param id? integer ID of the scope object (default: current buffer/window)
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
---@param scope? 'global'|'buf'|'buffer'|'win'|'window' Option scope (default: 'global')
---@param id? integer ID of the scope object (default: current buffer/window)
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
---@param opts table<string, any> Table of option names and values
---@param scope? 'global'|'buf'|'buffer'|'win'|'window' Option scope (default: 'global')
---@param id? integer ID of the scope object (default: current buffer/window)
function M.set_opts(opts, scope, id)
  for name, value in pairs(opts) do
    M.set(name, value, scope, id)
  end
end

---Get option default value
---@param name string Option name
---@return any Default value
function M.get_default(name)
  return api.nvim_get_option_info(name).default
end

---Get variable value (global, buffer, window, tabpage)
---@param name string Variable name
---@param scope? 'g'|'global'|'b'|'buf'|'w'|'win'|'t'|'tab'|'v'|'vim' Variable scope (default: 'g')
---@param id? integer ID of the scope object (default: current buffer/window/tab)
---@param default? any Default value if not found
---@return any Variable value
function M.var(name, scope, id, default)
  scope = scope or 'g'

  -- Function to safely get a variable with a default value
  local function safe_get(get_fn)
    local status, value = pcall(get_fn)
    if not status then
      return default
    end
    return value
  end

  if scope == 'b' or scope == 'buf' then
    return safe_get(function()
      return api.nvim_buf_get_var(id or M.buf(), name)
    end)
  elseif scope == 'w' or scope == 'win' then
    return safe_get(function()
      return api.nvim_win_get_var(id or M.win(), name)
    end)
  elseif scope == 't' or scope == 'tab' then
    return safe_get(function()
      return api.nvim_tabpage_get_var(id or M.tab(), name)
    end)
  elseif scope == 'v' or scope == 'vim' then
    return safe_get(function()
      return vim[name]
    end)
  else
    return safe_get(function()
      return api.nvim_get_var(name)
    end)
  end
end

---Set variable value
---@param name string Variable name
---@param value any Variable value
---@param scope? 'g'|'global'|'b'|'buf'|'w'|'win'|'t'|'tab' Variable scope (default: 'g')
---@param id? integer ID of the scope object (default: current buffer/window/tab)
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

---Delete a variable
---@param name string Variable name
---@param scope? 'g'|'global'|'b'|'buf'|'w'|'win'|'t'|'tab' Variable scope (default: 'g')
---@param id? integer ID of the scope object (default: current buffer/window/tab)
function M.del_var(name, scope, id)
  scope = scope or 'g'
  local status = pcall(function()
    if scope == 'b' or scope == 'buf' then
      api.nvim_buf_del_var(id or M.buf(), name)
    elseif scope == 'w' or scope == 'win' then
      api.nvim_win_del_var(id or M.win(), name)
    elseif scope == 't' or scope == 'tab' then
      api.nvim_tabpage_del_var(id or M.tab(), name)
    else
      api.nvim_del_var(name)
    end
  end)
  return status
end

---Get or create a namespaced variable
---@param ns string Namespace
---@param name string Variable name
---@param default any Default value if not found
---@param scope? 'g'|'global'|'b'|'buf'|'w'|'win'|'t'|'tab' Variable scope (default: 'g')
---@param id? integer ID of the scope object (default: current buffer/window/tab)
---@return any Variable value
function M.ns_var(ns, name, default, scope, id)
  local key = ns .. '_' .. name
  local value = M.var(key, scope, id)

  if value == nil then
    M.set_var(key, default, scope, id)
    return default
  end

  return value
end

-- ================================
-- Key mappings
-- ================================

---Set keymap
---@param mode string|string[] Mode(s) for the mapping ('n', 'i', 'v', etc.)
---@param lhs string Left-hand side of the mapping
---@param rhs string|function Right-hand side of the mapping
---@param opts? NvMappingOptions Options for the mapping
function M.map(mode, lhs, rhs, opts)
  opts = vim.tbl_extend('force', { noremap = true, silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

---Set keymap for normal mode
---@param lhs string Left-hand side of the mapping
---@param rhs string|function Right-hand side of the mapping
---@param opts? NvMappingOptions Options for the mapping
function M.nmap(lhs, rhs, opts)
  M.map('n', lhs, rhs, opts)
end

---Set keymap for insert mode
---@param lhs string Left-hand side of the mapping
---@param rhs string|function Right-hand side of the mapping
---@param opts? NvMappingOptions Options for the mapping
function M.imap(lhs, rhs, opts)
  M.map('i', lhs, rhs, opts)
end

---Set keymap for visual mode
---@param lhs string Left-hand side of the mapping
---@param rhs string|function Right-hand side of the mapping
---@param opts? NvMappingOptions Options for the mapping
function M.vmap(lhs, rhs, opts)
  M.map('v', lhs, rhs, opts)
end

---Set keymap for terminal mode
---@param lhs string Left-hand side of the mapping
---@param rhs string|function Right-hand side of the mapping
---@param opts? NvMappingOptions Options for the mapping
function M.tmap(lhs, rhs, opts)
  M.map('t', lhs, rhs, opts)
end

---Unset keymap
---@param mode string|string[] Mode(s) for the mapping ('n', 'i', 'v', etc.)
---@param lhs string Left-hand side of the mapping
---@param opts? NvMappingOptions Additional options
function M.unmap(mode, lhs, opts)
  pcall(vim.keymap.del, mode, lhs, opts)
end

---@class NvMapDefinition
---@field [1] string|string[] Mode(s) for the mapping
---@field [2] string Left-hand side of the mapping
---@field [3] string|function Right-hand side of the mapping
---@field [4]? NvMappingOptions Options for the mapping

---Set multiple keymaps at once
---@param maps NvMapDefinition[] Array of keymap definitions
---@param default_opts? NvMappingOptions Default options to apply to all keymaps
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

---Create a mapping with a description
---@param mode string|string[] Mode(s) for the mapping
---@param lhs string Left-hand side of the mapping
---@param rhs string|function Right-hand side of the mapping
---@param desc string Description for the mapping
---@param opts? NvMappingOptions Additional options
function M.map_with_desc(mode, lhs, rhs, desc, opts)
  opts = opts or {}
  opts.desc = desc
  M.map(mode, lhs, rhs, opts)
end

---Create buffer-local mapping
---@param mode string|string[] Mode(s) for the mapping
---@param lhs string Left-hand side of the mapping
---@param rhs string|function Right-hand side of the mapping
---@param bufnr? BufferNumber Buffer to set mapping for (default: current buffer)
---@param opts? NvMappingOptions Additional options
function M.buf_map(mode, lhs, rhs, bufnr, opts)
  bufnr = bufnr or M.buf()
  opts = opts or {}
  opts.buffer = bufnr
  vim.keymap.set(mode, lhs, rhs, opts)
end

---Remove buffer-local mapping
---@param mode string|string[] Mode(s) for the mapping
---@param lhs string Left-hand side of the mapping
---@param bufnr? BufferNumber Buffer to remove mapping from (default: current buffer)
function M.buf_unmap(mode, lhs, bufnr)
  bufnr = bufnr or M.buf()
  pcall(vim.keymap.del, mode, lhs, { buffer = bufnr })
end

---Check if a mapping exists
---@param mode string Mode to check
---@param lhs string Left-hand side of the mapping
---@param bufnr? BufferNumber Buffer to check (default: 0 for global)
---@return boolean
function M.has_map(mode, lhs, bufnr)
  local maps = vim.api.nvim_get_keymap(mode)
  if bufnr then
    maps = vim.api.nvim_buf_get_keymap(bufnr, mode)
  end

  for _, map in ipairs(maps) do
    if map.lhs == lhs then
      return true
    end
  end

  return false
end

---Get information about a mapping
---@param mode string Mode to check
---@param lhs string Left-hand side of the mapping
---@param bufnr? BufferNumber Buffer to check (default: 0 for global)
---@return table|nil Mapping information
function M.get_map_info(mode, lhs, bufnr)
  local maps = vim.api.nvim_get_keymap(mode)
  if bufnr then
    maps = vim.api.nvim_buf_get_keymap(bufnr, mode)
  end

  for _, map in ipairs(maps) do
    if map.lhs == lhs then
      return map
    end
  end

  return nil
end

-- ================================
-- Autocommands
-- ================================

---Create an autocommand group
---@param name string Augroup name
---@param clear? boolean Whether to clear existing commands (default: true)
---@return AugroupID
function M.augroup(name, clear)
  clear = clear ~= false -- Default to true if nil
  return api.nvim_create_augroup(name, { clear = clear })
end

---Create an autocommand
---@param event string|string[] Event(s) to trigger on
---@param opts table Options including pattern, callback, group, etc.
---@return AutocmdID
function M.autocmd(event, opts)
  return api.nvim_create_autocmd(event, opts)
end

---Delete an autocommand
---@param id AutocmdID Autocommand ID to delete
function M.del_autocmd(id)
  pcall(api.nvim_del_autocmd, id)
end

---@class NvAugroupCmdDefinition
---@field [1] string|string[] Event(s) to trigger on
---@field [2] table Options including pattern, callback, etc.

---Create multiple autocommands in a group
---@param group_name string Augroup name
---@param clear_existing_commands? boolean Whether to clear existing commands (default: true)
---@param definitions NvAugroupCmdDefinition[]
---@return AugroupID
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

---Create autocommands for a specific buffer
---@param bufnr BufferNumber Buffer to create autocommands for
---@param group_name string Augroup name
---@param definitions NvAugroupCmdDefinition[]
---@return AugroupID
function M.buf_autocmds(bufnr, group_name, definitions)
  local group_id = M.augroup(group_name, true)

  for _, def in ipairs(definitions) do
    local event = def[1]
    local opts = vim.deepcopy(def[2] or {})
    opts.group = group_id
    opts.buffer = bufnr
    M.autocmd(event, opts)
  end

  return group_id
end

---Get all autocommands
---@param opts? {event?:string|string[], group?:string|integer, pattern?:string|string[], buffer?:BufferNumber} Filter options
---@return table[] Autocommands
function M.get_autocmds(opts)
  return api.nvim_get_autocmds(opts or {})
end

---Check if an autocommand exists
---@param event string|string[] Event(s) to check
---@param pattern? string|string[] Pattern(s) to check
---@param group? string|integer Group to check
---@return boolean
function M.has_autocmd(event, pattern, group)
  local opts = {
    event = event,
  }

  if pattern then
    opts.pattern = pattern
  end

  if group then
    opts.group = group
  end

  local cmds = api.nvim_get_autocmds(opts)
  return #cmds > 0
end

-- ================================
-- User commands
-- ================================

---Create a user command
---@param name string Command name (without leading :)
---@param command function|string Command function or string
---@param opts? table Command options
---@return UserCommandID
function M.create_command(name, command, opts)
  opts = opts or {}
  return api.nvim_create_user_command(name, command, opts)
end

---Delete a user command
---@param name string Command name
---@param global? boolean Delete a global command (default: true)
function M.del_command(name, global)
  if global == false then
    -- Delete buffer-local command
    pcall(api.nvim_buf_del_user_command, M.buf(), name)
  else
    -- Delete global command
    pcall(api.nvim_del_user_command, name)
  end
end

---Create a buffer-local command
---@param name string Command name (without leading :)
---@param command function|string Command function or string
---@param opts? table Command options
---@param bufnr? BufferNumber Buffer to create command in (default: current buffer)
---@return UserCommandID
function M.buf_command(name, command, opts, bufnr)
  bufnr = bufnr or M.buf()
  opts = opts or {}
  return api.nvim_buf_create_user_command(bufnr, name, command, opts)
end

---Get all user commands
---@param opts? {builtin:boolean} Include builtin commands
---@return table<string, table> Commands
function M.get_commands(opts)
  return api.nvim_get_commands(opts or {})
end

---Get all buffer-local user commands
---@param bufnr? BufferNumber Buffer to get commands from (default: current buffer)
---@return table<string, table> Commands
function M.get_buf_commands(bufnr)
  bufnr = bufnr or M.buf()
  return api.nvim_buf_get_commands(bufnr, {})
end

---Check if a command exists
---@param name string Command name
---@param buf_only? boolean Only check buffer-local commands
---@return boolean
function M.command_exists(name, buf_only)
  if not buf_only then
    -- Check global commands
    local status, _ = pcall(vim.api.nvim_get_commands, {})
    if status and _[name] then
      return true
    end
  end

  -- Check buffer-local commands
  local status, commands = pcall(vim.api.nvim_buf_get_commands, M.buf(), {})
  return status and commands and commands[name] ~= nil
end

-- ================================
-- UI operations
-- ================================

---Show a notification
---@param msg string Message to show
---@param level? 'info'|'warn'|'error'|'debug'|'trace'|integer Log level (default: 'info')
---@param opts? table Additional options
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

  vim.notify(msg, levels[level] or level, opts)
end

---Show error notification
---@param msg string Error message
---@param opts? table Additional options
function M.error(msg, opts)
  M.notify(msg, 'error', opts)
end

---Show warning notification
---@param msg string Warning message
---@param opts? table Additional options
function M.warn(msg, opts)
  M.notify(msg, 'warn', opts)
end

---Show info notification
---@param msg string Info message
---@param opts? table Additional options
function M.info(msg, opts)
  M.notify(msg, 'info', opts)
end

---Show input prompt
---@param prompt? string Prompt to show
---@param default? string Default value
---@param completion? string Completion type
---@param opts? table Additional options
---@return string User input
function M.input(prompt, default, completion, opts)
  opts = opts or {}
  opts.prompt = prompt or ''
  opts.default = default or ''
  opts.completion = completion

  return fn.input(opts)
end

---Show password input prompt (hidden text)
---@param prompt? string Prompt to show
---@return string User input
function M.password(prompt)
  local og_stars = vim.o.showcmd
  vim.o.showcmd = false

  -- Store the original mapping for <CR>
  local cr_map = M.get_map_info('c', '<CR>')

  -- Create a temporary mapping for <CR> in cmdline mode
  M.map('c', '<CR>', function()
    -- Restore the original mapping for <CR>
    if cr_map then
      M.map('c', '<CR>', cr_map.rhs, { expr = cr_map.expr == 1 })
    else
      M.unmap('c', '<CR>')
    end

    -- Restore showcmd
    vim.o.showcmd = og_stars

    -- Execute the Enter key
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes('<CR>', true, false, true),
      'n',
      false
    )
  end)

  -- Get input without showing characters
  return fn.inputsecret(prompt or 'Password: ')
end

---Show confirmation dialog
---@param msg string Message to show
---@param default? boolean Default selection (default: false)
---@return boolean User selection
function M.confirm(msg, default)
  return fn.confirm(msg, '&Yes\n&No', default and 1 or 2) == 1
end

---Show selection menu
---@param items string[]|table[] Items to select from
---@param prompt? string Prompt to show
---@param opts? table Additional options
---@param on_choice function Callback function to handle selection
function M.select(items, prompt, opts, on_choice)
  opts = opts or {}
  opts.prompt = prompt or 'Select item'

  vim.ui.select(items, opts, on_choice)
end

---Show a popup notification
---@param msg string Message to show
---@param opts? {timeout?:integer, title?:string, pos?:string} Additional options
function M.popup(msg, opts)
  opts = opts or {}

  -- Create buffer
  local bufnr = M.buf_new { scratch = true }

  -- Set content
  if type(msg) == 'string' then
    M.set_lines(vim.split(msg, '\n'), 0, -1, bufnr)
  else
    M.set_lines(msg, 0, -1, bufnr)
  end

  -- Calculate dimensions
  local width = 0
  local height = 0

  local lines = M.lines(0, -1, bufnr)
  for _, line in ipairs(lines) do
    width = math.max(width, vim.fn.strwidth(line))
  end
  height = #lines

  -- Add margins
  width = width + 4
  height = height + 2

  -- Add title height if provided
  if opts.title then
    height = height + 1
  end

  -- Determine position
  local pos = opts.pos or 'center'
  local row, col

  if pos == 'center' then
    row = math.floor((vim.o.lines - height) / 2)
    col = math.floor((vim.o.columns - width) / 2)
  elseif pos == 'top' then
    row = 1
    col = math.floor((vim.o.columns - width) / 2)
  elseif pos == 'bottom' then
    row = vim.o.lines - height - 1
    col = math.floor((vim.o.columns - width) / 2)
  end

  -- Create window
  local winid = M.win_new {
    bufnr = bufnr,
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = height,
    style = 'minimal',
    border = 'rounded',
    title = opts.title,
  }

  -- Set up autoclose
  if opts.timeout then
    local timer = vim.loop.new_timer()
    timer:start(
      opts.timeout,
      0,
      vim.schedule_wrap(function()
        if M.win_exists(winid) then
          M.win_close(winid, true)
        end
        timer:close()
      end)
    )
  end

  -- Close on any keypress
  M.buf_map({ 'n', 'i' }, '<Space>', function()
    M.win_close(winid, true)
  end, bufnr)
  M.buf_map({ 'n', 'i' }, '<CR>', function()
    M.win_close(winid, true)
  end, bufnr)
  M.buf_map({ 'n', 'i' }, '<Esc>', function()
    M.win_close(winid, true)
  end, bufnr)

  return winid, bufnr
end

---Redraw the screen
function M.redraw()
  api.nvim_command 'redraw'
end

---Echo a message
---@param msg string|string[] Message to echo
---@param hl_group? string Highlight group
---@param history? boolean Add to message history
function M.echo(msg, hl_group, history)
  hl_group = hl_group or 'None'

  if history == nil then
    history = true
  end

  if type(msg) == 'table' then
    msg = table.concat(msg, '\n')
  end

  if history then
    vim.cmd(
      string.format(
        'echohl %s | echo "%s" | echohl None',
        hl_group,
        msg:gsub('"', '\\"')
      )
    )
  else
    vim.cmd(
      string.format(
        'echohl %s | echon "%s" | echohl None',
        hl_group,
        msg:gsub('"', '\\"')
      )
    )
  end
end

---Echo a message with multiple highlight groups
---@param chunks {[1]:string, [2]:string}[] Text chunks with highlight groups
function M.echon(chunks)
  for _, chunk in ipairs(chunks) do
    local text = chunk[1]
    local hl = chunk[2] or 'None'

    vim.cmd(
      string.format(
        'echohl %s | echon "%s" | echohl None',
        hl,
        text:gsub('"', '\\"')
      )
    )
  end
end

---Clear command line
function M.clear_cmdline()
  vim.cmd 'echo ""'
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
        M.text({
          start_row = row - 1,
          start_col = start_col - 1,
          end_row = row - 1,
          end_col = end_col,
        }, M.buf())
      )
    end
    return lines
  end

  return M.text({
    start_row = start_row - 1,
    start_col = start_col - 1,
    end_row = end_row - 1,
    end_col = end_col,
  }, M.buf())
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

---Run a function on the next tick of the event loop
---@param func function Function to run
---@param ... any Arguments to pass to the function
function M.defer(func, ...)
  local args = { ... }
  vim.schedule(function()
    func(unpack(args))
  end)
end

---Get the cursor position as a byte index
---@param bufnr? BufferNumber Buffer to check (default: current buffer)
---@param winid? WindowID Window to check (default: current window)
---@return integer Cursor position as byte index
function M.cursor_byte_offset(bufnr, winid)
  bufnr = bufnr or M.buf()
  winid = winid or M.win()

  local cursor = M.cursor(winid)
  local line = M.line(cursor[1], bufnr)

  if not line then
    return 0
  end

  -- Get all previous lines and count bytes
  local offset = 0
  local lines = M.lines(0, cursor[1] - 1, bufnr)
  for _, l in ipairs(lines) do
    offset = offset + #l + 1 -- +1 for newline
  end

  -- Add current line offset
  return offset + vim.fn.byteidx(line, cursor[2])
end

---Get the length of a buffer in bytes
---@param bufnr? BufferNumber Buffer to check (default: current buffer)
---@return integer Buffer length in bytes
function M.buf_byte_size(bufnr)
  bufnr = bufnr or M.buf()

  local lines = M.lines(0, -1, bufnr)
  local size = 0

  for i, line in ipairs(lines) do
    size = size + #line
    if i < #lines then
      size = size + 1 -- Add newline
    end
  end

  return size
end

---Create a unique ID
---@param prefix? string Prefix for the ID (default: '')
---@return string Unique ID
function M.uuid(prefix)
  prefix = prefix or ''
  return prefix
    .. tostring(math.floor(uv.hrtime() / 1000))
    .. tostring(math.random(1000, 9999))
end

---Check if a directory exists
---@param path string Directory path
---@return boolean
function M.dir_exists(path)
  return vim.fn.isdirectory(path) == 1
end

---Check if a file exists
---@param path string File path
---@return boolean
function M.file_exists(path)
  return vim.fn.filereadable(path) == 1
end

---Create a directory if it doesn't exist
---@param path string Directory path
---@param mode? string Unix-style permissions (default: '0755')
---@param parents? boolean Create parent directories if needed (default: true)
---@return boolean Success
function M.mkdir(path, mode, parents)
  if M.dir_exists(path) then
    return true
  end

  mode = mode or '0755'
  if parents == nil then
    parents = true
  end

  return vim.fn.mkdir(path, parents and 'p' or '', mode) == 1
end

---Join path components
---@param ... string Path components
---@return string Joined path
function M.path_join(...)
  local path_sep = vim.loop.os_uname().sysname:match 'Windows' and '\\' or '/'
  local result = table.concat({ ... }, path_sep):gsub(path_sep .. '+', path_sep)
  return result
end

---Get the root of a file or directory
---@param patterns string[] Patterns to match for root detection
---@param path? string Starting path (default: current directory)
---@param stop_at_cwd? boolean Stop at current working directory (default: false)
---@return string|nil Root path if found
function M.find_root(patterns, path, stop_at_cwd)
  path = path or vim.fn.getcwd()

  if stop_at_cwd == nil then
    stop_at_cwd = false
  end
  local cwd = vim.fn.getcwd()

  -- Convert single pattern to table
  if type(patterns) == 'string' then
    patterns = { patterns }
  end

  -- Check current directory
  for _, pattern in ipairs(patterns) do
    local test_path = M.path_join(path, pattern)
    if M.file_exists(test_path) or M.dir_exists(test_path) then
      return path
    end
  end

  -- Stop at root or cwd if requested
  local parent = vim.fn.fnamemodify(path, ':h')
  if parent == path or (stop_at_cwd and path == cwd) then
    return nil
  end

  -- Check parent directories
  return M.find_root(patterns, parent, stop_at_cwd)
end

---Parse JSON string
---@param str string JSON string
---@param default? any Default value if parsing fails
---@return any|nil Parsed value or nil
function M.parse_json(str, default)
  local status, result = pcall(vim.fn.json_decode, str)
  if not status then
    return default
  end
  return result
end

---Convert value to JSON string
---@param value any Value to encode
---@param pretty? boolean Pretty-print JSON (default: false)
---@return string|nil JSON string or nil
function M.to_json(value, pretty)
  local status, result = pcall(function()
    if pretty then
      return vim.fn.json_encode(value)
    else
      return vim.json.encode(value)
    end
  end)

  if not status then
    return nil
  end

  return result
end

---Escape a string for use in a pattern
---@param str string String to escape
---@return string Escaped string
function M.escape_pattern(str)
  return str:gsub('([%(%)%.%[%]%*%+%-%?%$%^])', '%%%1')
end

---Check if a table contains a value
---@generic T
---@param tbl T[] Table to check
---@param value T Value to look for
---@return boolean
function M.tbl_contains(tbl, value)
  for _, v in ipairs(tbl) do
    if v == value then
      return true
    end
  end
  return false
end

---Filter a table using a predicate function
---@generic T
---@param tbl T[] Table to filter
---@param predicate fun(item:T):boolean Predicate function
---@return T[] Filtered table
function M.tbl_filter(tbl, predicate)
  local result = {}
  for _, v in ipairs(tbl) do
    if predicate(v) then
      table.insert(result, v)
    end
  end
  return result
end

---Map a function over a table
---@generic T, U
---@param tbl T[] Table to map
---@param fn fun(item:T):U Mapping function
---@return U[] Mapped table
function M.tbl_map(tbl, fn)
  local result = {}
  for i, v in ipairs(tbl) do
    result[i] = fn(v)
  end
  return result
end

---Create a new history object
---@return NvHistory
function M.new_history()
  local history = {
    histories = {},

    -- Add entry to history
    add = function(self, hist_type, entry)
      if not self.histories[hist_type] then
        self.histories[hist_type] = {}
      end

      -- Don't add duplicate entries consecutively
      local entries = self.histories[hist_type]
      if #entries > 0 and entries[#entries] == entry then
        return
      end

      table.insert(self.histories[hist_type], entry)
    end,

    -- Get history entries
    get = function(self, hist_type, count)
      if not self.histories[hist_type] then
        return {}
      end

      local entries = self.histories[hist_type]

      if count then
        local start_idx = math.max(1, #entries - count + 1)
        local result = {}
        for i = start_idx, #entries do
          table.insert(result, entries[i])
        end
        return result
      end

      return vim.deepcopy(entries)
    end,

    -- Clear history
    clear = function(self, hist_type)
      if hist_type then
        self.histories[hist_type] = {}
      else
        self.histories = {}
      end
    end,
  }

  return history
end

---Create a new cache object
---@return NvCache
function M.new_cache()
  local cache = {
    values = {},
    ttls = {},

    -- Get cached value
    get = function(self, key, default)
      -- Check if TTL has expired
      if self.ttls[key] and self.ttls[key] < os.time() then
        self.values[key] = nil
        self.ttls[key] = nil
        return default
      end

      return self.values[key] ~= nil and self.values[key] or default
    end,

    -- Set cached value
    set = function(self, key, value, ttl)
      self.values[key] = value

      if ttl then
        self.ttls[key] = os.time() + ttl
      else
        self.ttls[key] = nil
      end
    end,

    -- Check if key exists
    has = function(self, key)
      -- Check if TTL has expired
      if self.ttls[key] and self.ttls[key] < os.time() then
        self.values[key] = nil
        self.ttls[key] = nil
        return false
      end

      return self.values[key] ~= nil
    end,

    -- Remove key
    remove = function(self, key)
      self.values[key] = nil
      self.ttls[key] = nil
    end,

    -- Clear all values
    clear = function(self)
      self.values = {}
      self.ttls = {}
    end,
  }

  return cache
end

---Get the undo history for a buffer
---@param bufnr? BufferNumber Buffer to get history for (default: current buffer)
---@return NvUndoState
function M.undo_history(bufnr)
  bufnr = bufnr or M.buf()

  local tree = vim.fn.undotree(bufnr)
  return tree
end

-- ================================
-- LSP operations
-- ================================

---@class NvLspModule LSP operations module
local lsp = {}

---Get all active language servers for a buffer
---@param bufnr? BufferNumber Buffer to check (default: current buffer)
---@return table[] List of LSP clients
function lsp.get_clients(bufnr)
  bufnr = bufnr or M.buf()
  return vim.lsp.get_active_clients { bufnr = bufnr }
end

---Check if a buffer has any attached LSP clients
---@param bufnr? BufferNumber Buffer to check (default: current buffer)
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

---Get a specific LSP client by name
---@param name string Client name
---@param bufnr? BufferNumber Buffer to check (default: current buffer)
---@return table|nil Client if found
function lsp.get_client_by_name(name, bufnr)
  bufnr = bufnr or M.buf()

  local clients = lsp.get_clients(bufnr)
  for _, client in ipairs(clients) do
    if client.name == name then
      return client
    end
  end

  return nil
end

---Start a new LSP client
---@param name string Server name
---@param opts? NvLspOptions Client options
---@return integer|nil Client ID if successful
function lsp.start(name, opts)
  opts = opts or {}

  local client_opts = {
    name = name,
    cmd = opts.cmd,
    root_dir = opts.root_dir or vim.fn.getcwd(),
    settings = opts.settings,
    init_options = opts.init_options,
    capabilities = opts.capabilities,
    handlers = opts.handlers,
    flags = opts.flags,
  }

  return vim.lsp.start(client_opts)
end

---Stop an LSP client
---@param client_id integer Client ID
---@return boolean Success
function lsp.stop(client_id)
  local client = lsp.get_client(client_id)
  if client then
    return client.stop()
  end
  return false
end

---Restart an LSP client
---@param client_id integer Client ID
---@return integer|nil New client ID if successful
function lsp.restart(client_id)
  local client = lsp.get_client(client_id)
  if not client then
    return nil
  end

  -- Store client config
  local config = {
    name = client.name,
    cmd = client.cmd,
    root_dir = client.root_dir,
    settings = client.settings,
    init_options = client.init_options,
    handlers = client.handlers,
    flags = client.flags,
  }

  -- Stop client
  client.stop()

  -- Restart with same config
  vim.defer_fn(function()
    return vim.lsp.start(config)
  end, 500)
end

-- Diagnostics operations

---Get diagnostics for a buffer
---@param bufnr? BufferNumber Buffer to get diagnostics for (default: current buffer)
---@param opts? table Options for filtering diagnostics
---@return table[] Diagnostics for the buffer
function lsp.diagnostics(bufnr, opts)
  bufnr = bufnr or M.buf()
  return vim.diagnostic.get(bufnr, opts)
end

---Get diagnostics by severity
---@param severity string|integer Severity level ('error', 'warn', 'info', 'hint') or vim.diagnostic.severity enum
---@param bufnr? BufferNumber Buffer to get diagnostics for (default: current buffer)
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

---Count diagnostics by severity
---@param bufnr? BufferNumber Buffer to count diagnostics for (default: current buffer)
---@return {error:integer, warn:integer, info:integer, hint:integer, total:integer} Counts by severity
function lsp.count_diagnostics(bufnr)
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

---Show diagnostics in a float window
---@param opts? table Options for the float window
---@return function Function to show diagnostics
function lsp.show_diagnostics(opts)
  return function()
    opts = opts or {}
    vim.diagnostic.open_float(opts)
  end
end

---Go to the previous diagnostic
---@param opts? table Options for movement
---@return function Function to go to previous diagnostic
function lsp.prev_diagnostic(opts)
  return function()
    opts = opts or {}
    vim.diagnostic.goto_prev(opts)
  end
end

---Go to the next diagnostic
---@param opts? table Options for movement
---@return function Function to go to next diagnostic
function lsp.next_diagnostic(opts)
  return function()
    opts = opts or {}
    vim.diagnostic.goto_next(opts)
  end
end

---Set diagnostics to the location list
---@param opts? table Options for the location list
---@return function Function to set diagnostics to location list
function lsp.diagnostics_setloclist(opts)
  return function()
    opts = opts or {}
    vim.diagnostic.setloclist(opts)
  end
end

---Enable diagnostics for a buffer
---@param bufnr? BufferNumber Buffer to enable diagnostics for (default: current buffer)
---@param namespace? integer Namespace to enable (default: nil for all namespaces)
function lsp.enable_diagnostics(bufnr, namespace)
  bufnr = bufnr or M.buf()
  vim.diagnostic.enable(bufnr, namespace)
end

---Disable diagnostics for a buffer
---@param bufnr? BufferNumber Buffer to disable diagnostics for (default: current buffer)
---@param namespace? integer Namespace to disable (default: nil for all namespaces)
function lsp.disable_diagnostics(bufnr, namespace)
  bufnr = bufnr or M.buf()
  vim.diagnostic.disable(bufnr, namespace)
end

---Hide diagnostic virtual text
---@param bufnr? BufferNumber Buffer to hide diagnostics for (default: current buffer)
function lsp.hide_diagnostic_text(bufnr)
  bufnr = bufnr or M.buf()

  local current = vim.diagnostic.config()
  local new_config = vim.deepcopy(current)
  new_config.virtual_text = false

  vim.diagnostic.config(new_config, bufnr)
end

---Show diagnostic virtual text
---@param bufnr? BufferNumber Buffer to show diagnostics for (default: current buffer)
---@param config? table Virtual text configuration
function lsp.show_diagnostic_text(bufnr, config)
  bufnr = bufnr or M.buf()

  local current = vim.diagnostic.config()
  local new_config = vim.deepcopy(current)

  if config then
    new_config.virtual_text = config
  else
    new_config.virtual_text = true
  end

  vim.diagnostic.config(new_config, bufnr)
end

-- Hover/Definition/References operations

---Show hover information
---@param opts? table Options for the hover request
---@return function Function to show hover
function lsp.hover(opts)
  return function()
    opts = opts or {}
    vim.lsp.buf.hover(opts)
  end
end

---Go to definition
---@param opts? table Options for the definition request
---@return function Function to go to definition
function lsp.definition(opts)
  return function()
    opts = opts or {}
    vim.lsp.buf.definition(opts)
  end
end

---Go to declaration
---@param opts? table Options for the declaration request
---@return function Function to go to declaration
function lsp.declaration(opts)
  return function()
    opts = opts or {}
    vim.lsp.buf.declaration(opts)
  end
end

---Show type definition
---@param opts? table Options for the type definition request
---@return function Function to show type definition
function lsp.type_definition(opts)
  return function()
    opts = opts or {}
    vim.lsp.buf.type_definition(opts)
  end
end

---Show implementations
---@param opts? table Options for the implementation request
---@return function Function to show implementations
function lsp.implementation(opts)
  return function()
    opts = opts or {}
    vim.lsp.buf.implementation(opts)
  end
end

---Show references
---@param opts? table Options for the references request
---@return function Function to show references
function lsp.references(opts)
  return function()
    opts = opts or { includeDeclaration = true }
    vim.lsp.buf.references(opts)
  end
end

---Get references as a list
---@param context? table Context object (includeDeclaration, etc.)
---@param bufnr? BufferNumber Buffer to get references from (default: current buffer)
---@return function Function that returns references
function lsp.get_references(context, bufnr)
  return function()
    bufnr = bufnr or M.buf()
    context = context or { includeDeclaration = true }

    local params = vim.lsp.util.make_position_params()
    params.context = context

    local result_locations = {}

    vim.lsp.buf_request(
      bufnr,
      'textDocument/references',
      params,
      function(err, result, _, _)
        if err or not result then
          return {}
        end
        result_locations = result
      end
    )

    return result_locations
  end
end

-- Code actions/symbols operations

---Show available code actions
---@param opts? table Options for the code action request
---@return function Function to show code actions
function lsp.code_action(opts)
  return function()
    opts = opts or {}
    vim.lsp.buf.code_action(opts)
  end
end

---Apply code action at cursor
---@param action_kind? string|string[] Kind of action to apply
---@param opts? table Additional options
---@return function Function to apply code action
function lsp.apply_action(action_kind, opts)
  return function()
    opts = opts or {}
    opts.filter = function(action)
      if not action_kind then
        return true
      end
      if type(action_kind) == 'string' then
        return action.kind == action_kind
      else
        for _, kind in ipairs(action_kind) do
          if action.kind == kind then
            return true
          end
        end
      end
      return false
    end

    opts.apply = true
    return vim.lsp.buf.code_action(opts)
  end
end

---Rename symbol
---@param new_name? string New name (default: prompt user for name)
---@param opts? table Options for the rename request
---@return function Function to rename symbol
function lsp.rename(new_name, opts)
  return function()
    opts = opts or {}
    vim.lsp.buf.rename(new_name, opts)
  end
end

---Show document symbols
---@param opts? table Options for the document symbols request
---@return function Function to show document symbols
function lsp.document_symbols(opts)
  return function()
    opts = opts or {}
    vim.lsp.buf.document_symbol(opts)
  end
end

---Show workspace symbols
---@param query? string Query string
---@param opts? table Options for the workspace symbols request
---@return function Function to show workspace symbols
function lsp.workspace_symbols(query, opts)
  return function()
    opts = opts or {}
    vim.lsp.buf.workspace_symbol(query, opts)
  end
end

---Get document symbols directly
---@param bufnr? BufferNumber Buffer to get symbols from (default: current buffer)
---@return function Function that returns symbols
function lsp.get_document_symbols(bufnr)
  return function()
    bufnr = bufnr or M.buf()

    local symbols = {}

    vim.lsp.buf_request_sync(
      bufnr,
      'textDocument/documentSymbol',
      vim.lsp.util.make_position_params(),
      1000
    )

    return symbols
  end
end

-- Formatting operations

---Format current buffer
---@param opts? table Options for the formatting request
---@return function Function to format buffer
function lsp.format(opts)
  return function()
    opts = opts or {}
    vim.lsp.buf.format(opts)
  end
end

---Format selected range
---@param start_pos {[1]:integer, [2]:integer} Start position [row, col]
---@param end_pos {[1]:integer, [2]:integer} End position [row, col]
---@param opts? table Options for the range formatting request
---@return function Function to format range
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
---@param opts? table Options for the formatting request
---@return function Function to format visual selection
function lsp.format_selection(opts)
  return function()
    opts = opts or {}
    local start_pos = vim.fn.getpos "'<"
    local end_pos = vim.fn.getpos "'>"
    vim.lsp.buf.format {
      range = {
        start = { line = start_pos[2] - 1, character = start_pos[3] - 1 },
        ['end'] = { line = end_pos[2] - 1, character = end_pos[3] },
      },
    }
  end
end

---Check if a buffer has a formatter
---@param bufnr? BufferNumber Buffer to check (default: current buffer)
---@return boolean True if buffer has formatter
function lsp.has_formatter(bufnr)
  bufnr = bufnr or M.buf()

  local clients = lsp.get_clients(bufnr)
  for _, client in ipairs(clients) do
    if client.server_capabilities.documentFormattingProvider then
      return true
    end
  end

  return false
end

-- Workspace operations

---Add folder to workspace
---@param workspace_folder? string Path to add (default: prompt user)
---@return function Function to add workspace folder
function lsp.add_workspace_folder(workspace_folder)
  return function()
    vim.lsp.buf.add_workspace_folder(workspace_folder)
  end
end

---Remove folder from workspace
---@param workspace_folder? string Path to remove (default: prompt user)
---@return function Function to remove workspace folder
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
---@param opts? table Options for the signature help request
---@return function Function to show signature help
function lsp.signature_help(opts)
  return function()
    opts = opts or {}
    vim.lsp.buf.signature_help(opts)
  end
end

---Enable or disable signature help on cursor move
---@param enable boolean Enable or disable
---@param opts? table Signature help options
---@param bufnr? BufferNumber Buffer to configure (default: current buffer)
function lsp.signature_help_on_move(enable, opts, bufnr)
  bufnr = bufnr or M.buf()

  if enable then
    -- Create autocmd for cursor movement
    local group =
      vim.api.nvim_create_augroup('NvLspSignatureHelp', { clear = false })

    vim.api.nvim_create_autocmd('CursorMovedI', {
      buffer = bufnr,
      group = group,
      callback = function()
        vim.lsp.buf.signature_help(opts or {})
      end,
      desc = 'Show signature help on cursor move',
    })
  else
    -- Clear autocmds
    local cmds = vim.api.nvim_get_autocmds {
      group = 'NvLspSignatureHelp',
      buffer = bufnr,
      event = 'CursorMovedI',
    }

    for _, cmd in ipairs(cmds) do
      vim.api.nvim_del_autocmd(cmd.id)
    end
  end
end

-- Call hierarchy

---Show incoming calls
---@param opts? table Options for the incoming calls request
---@return function Function to show incoming calls
function lsp.incoming_calls(opts)
  return function()
    opts = opts or {}
    vim.lsp.buf.incoming_calls(opts)
  end
end

---Show outgoing calls
---@param opts? table Options for the outgoing calls request
---@return function Function to show outgoing calls
function lsp.outgoing_calls(opts)
  return function()
    opts = opts or {}
    vim.lsp.buf.outgoing_calls(opts)
  end
end

-- Inlay hints

---Enable inlay hints
---@param bufnr? BufferNumber Buffer to enable hints for (default: current buffer)
function lsp.enable_inlay_hints(bufnr)
  bufnr = bufnr or M.buf()

  vim.lsp.inlay_hint.enable(bufnr, true)
end

---Disable inlay hints
---@param bufnr? BufferNumber Buffer to disable hints for (default: current buffer)
function lsp.disable_inlay_hints(bufnr)
  bufnr = bufnr or M.buf()

  vim.lsp.inlay_hint.enable(bufnr, false)
end

---Toggle inlay hints
---@param bufnr? BufferNumber Buffer to toggle hints for (default: current buffer)
function lsp.toggle_inlay_hints(bufnr)
  bufnr = bufnr or M.buf()

  local current = vim.lsp.inlay_hint.is_enabled(bufnr)
  vim.lsp.inlay_hint.enable(bufnr, not current)
end

-- Configuration

---Create default LSP keymappings for a buffer
---@param bufnr? BufferNumber Buffer to set mappings for (default: current buffer)
---@param opts? table Additional options
function lsp.setup_keymaps(bufnr, opts)
  bufnr = bufnr or M.buf()
  opts = opts or {}

  -- Use nv.map for key mappings with buffer local scope
  local map_opts = { buffer = bufnr, silent = true }

  M.map('n', 'gD', lsp.declaration(), map_opts)
  M.map('n', 'gd', lsp.definition(), map_opts)
  M.map('n', 'K', lsp.hover(), map_opts)
  M.map('n', 'gi', lsp.implementation(), map_opts)
  M.map('n', '<C-k>', lsp.signature_help(), map_opts)
  M.map('n', '<leader>wa', lsp.add_workspace_folder(), map_opts)
  M.map('n', '<leader>wr', lsp.remove_workspace_folder(), map_opts)
  M.map('n', '<leader>wl', function()
    M.notify(vim.inspect(vim.lsp.buf.list_workspace_folders()), 'info')
  end, map_opts)
  M.map('n', '<leader>D', lsp.type_definition(), map_opts)
  M.map('n', '<leader>rn', lsp.rename(), map_opts)
  M.map('n', '<leader>ca', lsp.code_action(), map_opts)
  M.map('n', 'gr', lsp.references(), map_opts)
  M.map('n', '<leader>f', lsp.format { async = true }, map_opts)

  -- Diagnostics mappings
  M.map('n', '[d', lsp.prev_diagnostic(), map_opts)
  M.map('n', ']d', lsp.next_diagnostic(), map_opts)
  M.map('n', '<leader>e', lsp.show_diagnostics(), map_opts)
  M.map('n', '<leader>q', function()
    vim.diagnostic.setloclist()
  end, map_opts)

  -- Custom extra mappings
  if opts.extra_mappings then
    for lhs, rhs in pairs(opts.extra_mappings) do
      M.map('n', lhs, rhs, map_opts)
    end
  end
end

---On-attach handler for LSP client
---@param client table LSP client
---@param bufnr BufferNumber Buffer the client attached to
---@param opts? table Additional options
function lsp.on_attach(client, bufnr, opts)
  opts = opts or {}

  -- Setup keymaps
  if opts.keymaps ~= false then
    lsp.setup_keymaps(bufnr, { extra_mappings = opts.extra_mappings })
  end

  -- Enable inlay hints
  if
    client.server_capabilities.inlayHintProvider and opts.inlay_hints ~= false
  then
    lsp.enable_inlay_hints(bufnr)
  end

  -- Setup autoformatting
  if
    client.server_capabilities.documentFormattingProvider
    and opts.autoformat ~= false
  then
    local format_group =
      vim.api.nvim_create_augroup('NvLspFormatting_' .. bufnr, { clear = true })
    vim.api.nvim_create_autocmd('BufWritePre', {
      buffer = bufnr,
      group = format_group,
      callback = function()
        vim.lsp.buf.format { async = false }
      end,
      desc = 'Format on save',
    })
  end

  -- Setup signature help on cursor move
  if
    client.server_capabilities.signatureHelpProvider
    and opts.signature_help_on_move
  then
    lsp.signature_help_on_move(true, {}, bufnr)
  end

  -- Run custom on_attach callback if provided
  if opts.on_attach then
    opts.on_attach(client, bufnr)
  end
end

---Setup LSP client with sensible defaults
---@param server_name string LSP server name
---@param opts? NvLspOptions Extra options to pass to the server
function lsp.setup(server_name, opts)
  opts = opts or {}

  -- Set default options
  local default_opts = {
    capabilities = vim.lsp.protocol.make_client_capabilities(),
    on_attach = function(client, bufnr)
      -- Setup features when LSP attaches to a buffer
      lsp.on_attach(client, bufnr, opts)
    end,
  }

  -- Enhance capabilities for better autocompletion
  local has_cmp, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
  if has_cmp then
    default_opts.capabilities =
      cmp_lsp.default_capabilities(default_opts.capabilities)
  end

  -- Merge default options with user options
  for k, v in pairs(opts) do
    -- Skip on_attach as we handle it specially
    if k ~= 'on_attach' then
      default_opts[k] = v
    end
  end

  -- Setup the LSP client
  local has_lspconfig, lspconfig = pcall(require, 'lspconfig')
  if has_lspconfig then
    lspconfig[server_name].setup(default_opts)
  else
    error "lspconfig module not found. Make sure it's installed."
  end
end

---Setup multiple LSP clients
---@param servers table<string, NvLspOptions> Table of server names and options
function lsp.setup_multiple(servers)
  for server_name, opts in pairs(servers) do
    lsp.setup(server_name, opts)
  end
end

---Set global LSP diagnostic config
---@param config table Diagnostic configuration
function lsp.set_diagnostic_config(config)
  vim.diagnostic.config(config)
end

---Get LSP server status
---@param bufnr? BufferNumber Buffer to check (default: current buffer)
---@return table Status information {attached:boolean, servers:table}
function lsp.status(bufnr)
  bufnr = bufnr or M.buf()

  local clients = lsp.get_clients(bufnr)
  local status = {
    attached = #clients > 0,
    servers = {},
  }

  for _, client in ipairs(clients) do
    table.insert(status.servers, {
      name = client.name,
      id = client.id,
      version = client.server_capabilities.version or 'unknown',
      progress = client.progress or {},
      capabilities = {
        formatting = client.server_capabilities.documentFormattingProvider
          or false,
        hover = client.server_capabilities.hoverProvider or false,
        completion = client.server_capabilities.completionProvider ~= nil,
        references = client.server_capabilities.referencesProvider or false,
        definition = client.server_capabilities.definitionProvider or false,
        rename = client.server_capabilities.renameProvider or false,
        codeAction = client.server_capabilities.codeActionProvider ~= nil,
        signature = client.server_capabilities.signatureHelpProvider ~= nil,
        inlayHint = client.server_capabilities.inlayHintProvider ~= nil,
      },
    })
  end

  return status
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
---@param to_unnamed? boolean Also copy to unnamed register (default: true)
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
---@param message? string Notification message (default: "Copied to clipboard")
---@param level? string Notification level (default: "info")
---@return nil
function clipboard.copy_with_notification(text, message, level)
  clipboard.copy(text)
  message = message or 'Copied to clipboard'
  M.notify(message, level or 'info')
end

---Copy current line to clipboard
---@param trim? boolean Trim whitespace (default: false)
---@return string Copied line
function clipboard.copy_line(trim)
  local line = M.line(vim.fn.line '.')

  if trim and line then
    line = vim.trim(line)
  end

  if line then
    clipboard.copy(line)
  end

  return line or ''
end

---Copy visual selection to clipboard
---@param trim? boolean Trim whitespace (default: false)
---@return string Copied text
function clipboard.copy_selection(trim)
  local text = M.visual_selection()

  if type(text) == 'table' then
    text = table.concat(text, '\n')
  end

  if trim and text then
    text = vim.trim(text)
  end

  if text then
    clipboard.copy(text)
  end

  return text or ''
end

---Copy buffer content to clipboard
---@param bufnr? BufferNumber Buffer to copy from (default: current)
---@return nil
function clipboard.copy_buf(bufnr)
  bufnr = bufnr or M.buf()

  local text = table.concat(M.lines(0, -1, bufnr), '\n')
  clipboard.copy(text)
end

---Clear clipboard
---@return nil
function clipboard.clear()
  vim.fn.setreg('+', '')
  vim.fn.setreg('"', '')
end

-- Add clipboard module to nv
M.clip = clipboard

-- ================================
-- Diagnostics utilities
-- ================================

---@class NvDiagnosticsModule Diagnostic utilities
local diagnostics = {}

---Format diagnostics as text
---@param opts? NvDiagnosticOpts Options for formatting
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
---@param opts? NvDiagnosticOpts Options for formatting (see format_as_text)
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
---@param bufnr? BufferNumber Buffer to check (default: current buffer)
---@return NvDiagnosticCounts
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

---Get first diagnostic message at cursor
---@param severity? string|integer Optional severity filter
---@param opts? table Additional options
---@return string|nil Diagnostic message
function diagnostics.get_message_at_cursor(severity, opts)
  opts = opts or {}
  local diags =
    vim.diagnostic.get_line_diagnostics(0, vim.fn.line '.' - 1, opts)

  if #diags == 0 then
    return nil
  end

  -- Filter by severity if specified
  if severity then
    local sev_value = severity

    -- Convert string to integer
    if type(severity) == 'string' then
      local severity_map = {
        error = vim.diagnostic.severity.ERROR,
        warn = vim.diagnostic.severity.WARN,
        warning = vim.diagnostic.severity.WARN,
        info = vim.diagnostic.severity.INFO,
        information = vim.diagnostic.severity.INFO,
        hint = vim.diagnostic.severity.HINT,
      }
      sev_value = severity_map[severity:lower()]
    end

    -- Find first diagnostic with matching severity
    for _, diag in ipairs(diags) do
      if diag.severity == sev_value then
        return diag.message
      end
    end

    return nil
  end

  -- Return first diagnostic message
  return diags[1].message
end

---Get diagnostic summary message for a buffer
---@param bufnr? BufferNumber Buffer to get summary for (default: current)
---@return string Summary message
function diagnostics.summary(bufnr)
  bufnr = bufnr or M.buf()

  local counts = diagnostics.count(bufnr)

  -- Format counts
  local parts = {}
  if counts.error > 0 then
    table.insert(
      parts,
      counts.error .. ' error' .. (counts.error > 1 and 's' or '')
    )
  end

  if counts.warn > 0 then
    table.insert(
      parts,
      counts.warn .. ' warning' .. (counts.warn > 1 and 's' or '')
    )
  end

  if counts.info > 0 then
    table.insert(
      parts,
      counts.info .. ' info' .. (counts.info > 1 and 's' or '')
    )
  end

  if counts.hint > 0 then
    table.insert(
      parts,
      counts.hint .. ' hint' .. (counts.hint > 1 and 's' or '')
    )
  end

  if #parts == 0 then
    return 'No diagnostics'
  end

  return table.concat(parts, ', ')
end

---Format diagnostics for statusline
---@param bufnr? BufferNumber Buffer to get diagnostics for (default: current)
---@return string Formatted statusline string
function diagnostics.statusline(bufnr)
  bufnr = bufnr or M.buf()

  local counts = diagnostics.count(bufnr)
  local parts = {}

  if counts.error > 0 then
    table.insert(parts, 'E:' .. counts.error)
  end

  if counts.warn > 0 then
    table.insert(parts, 'W:' .. counts.warn)
  end

  if counts.info > 0 then
    table.insert(parts, 'I:' .. counts.info)
  end

  if counts.hint > 0 then
    table.insert(parts, 'H:' .. counts.hint)
  end

  if #parts == 0 then
    return ''
  end

  return table.concat(parts, ' ')
end

---Create highlighting for diagnostics
---@param namespace? integer|string Namespace for highlights
function diagnostics.setup_highlights(namespace)
  if type(namespace) == 'string' then
    namespace = api.nvim_create_namespace(namespace)
  end

  namespace = namespace or api.nvim_create_namespace 'nv_diagnostics'

  vim.diagnostic.config({
    underline = true,
    virtual_text = {
      prefix = '●',
      source = 'if_many',
    },
    signs = true,
    severity_sort = true,
    float = {
      border = 'rounded',
      source = 'always',
      header = '',
      prefix = '',
    },
  }, namespace)
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
---@param separator? string Separator (default: newline)
---@return string
function text.join(lines, separator)
  return table.concat(lines, separator or '\n')
end

---Split text into lines
---@param text string Text to split
---@param sep? string Separator pattern (default: newline)
---@return string[]
function text.split(text, sep)
  sep = sep or '\n'
  local lines = {}
  local pattern = string.format('([^%s]+)', sep)

  for line in string.gmatch(text, pattern) do
    table.insert(lines, line)
  end

  return lines
end

---Create a formatted list from items
---@param items table List of items
---@param opts? NvFormatListOpts Options for formatting
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
---@param plural? string Plural form (default: singular + "s")
---@return string Pluralized word
function text.pluralize(count, singular, plural)
  if count == 1 then
    return singular
  else
    return plural or (singular .. 's')
  end
end

---Convert a string to title case
---@param str string String to convert
---@return string Title-cased string
function text.titlecase(str)
  return str:gsub("(%a)([%w_']*)", function(first, rest)
    return first:upper() .. rest:lower()
  end)
end

---Truncate a string to max length with ellipsis
---@param str string String to truncate
---@param max_length integer Maximum length
---@param ellipsis? string Ellipsis string (default: "...")
---@return string Truncated string
function text.truncate(str, max_length, ellipsis)
  ellipsis = ellipsis or '...'

  if #str <= max_length then
    return str
  end

  return string.sub(str, 1, max_length - #ellipsis) .. ellipsis
end

---Pad a string to a specific length
---@param str string String to pad
---@param length integer Target length
---@param char? string Pad character (default: " ")
---@param right? boolean Pad right side instead of left (default: false)
---@return string Padded string
function text.pad(str, length, char, right)
  char = char or ' '
  local padding = string.rep(char, length - #str)

  if right then
    return str .. padding
  else
    return padding .. str
  end
end

---Center a string within a specific width
---@param str string String to center
---@param width integer Target width
---@param char? string Pad character (default: " ")
---@return string Centered string
function text.center(str, width, char)
  char = char or ' '
  local padding = width - #str

  if padding <= 0 then
    return str
  end

  local left_pad = math.floor(padding / 2)
  local right_pad = padding - left_pad

  return string.rep(char, left_pad) .. str .. string.rep(char, right_pad)
end

---Escape special characters in a string for pattern matching
---@param str string String to escape
---@return string Escaped string
function text.escape_pattern(str)
  return str:gsub('[%(%)%.%+%-%*%?%[%]%^%$%%]', '%%%1')
end

---Strip ANSI color codes from a string
---@param str string String with ANSI codes
---@return string Clean string
function text.strip_ansi(str)
  return str:gsub('\27%[[0-9;:]*m', '')
end

---Create an indented block of text
---@param text string|string[] Text to indent
---@param indent? string|integer Indent string or number of spaces (default: 2)
---@return string Indented text
function text.indent(text, indent)
  -- Convert indent if it's a number
  if type(indent) == 'number' then
    indent = string.rep(' ', indent)
  elseif indent == nil then
    indent = '  '
  end

  -- Convert string to lines
  local lines
  if type(text) == 'string' then
    lines = vim.split(text, '\n')
  else
    lines = text
  end

  -- Indent each line
  for i, line in ipairs(lines) do
    if line ~= '' then
      lines[i] = indent .. line
    end
  end

  return table.concat(lines, '\n')
end

---Generate a random string
---@param length? integer Length of string (default: 8)
---@param chars? string Characters to use (default: alphanumeric)
---@return string Random string
function text.random_string(length, chars)
  length = length or 8
  chars = chars
    or 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'

  math.randomseed(os.time())

  local result = {}
  for i = 1, length do
    local rnd = math.random(1, #chars)
    table.insert(result, string.sub(chars, rnd, rnd))
  end

  return table.concat(result, '')
end

---Create a slug from text (lowercase, dashes)
---@param str string String to convert
---@return string Slug
function text.slugify(str)
  local slug = string.lower(str)
  slug = slug:gsub('%s+', '-')
  slug = slug:gsub('[^%w%-]', '')
  slug = slug:gsub('%-+', '-')
  slug = slug:gsub('^%-', '')
  slug = slug:gsub('%-$', '')
  return slug
end

---Create a snippet of text around a position
---@param text string Full text
---@param pos integer Position index
---@param context_chars? integer Characters of context (default: 20)
---@return string Snippet
function text.snippet_around(text, pos, context_chars)
  context_chars = context_chars or 20

  local start_pos = math.max(1, pos - context_chars)
  local end_pos = math.min(#text, pos + context_chars)

  local prefix = start_pos > 1 and '...' or ''
  local suffix = end_pos < #text and '...' or ''

  return prefix .. string.sub(text, start_pos, end_pos) .. suffix
end

-- Add text utilities to nv
M.text = text

-- ================================
-- File operations
-- ================================

---@class NvFileModule File operations module
local file = {}

---Read a file into a string
---@param path string File path
---@param default? string Default value if file not found
---@return string|nil, string|nil Contents and error message
function file.read(path)
  local f, err = io.open(path, 'r')
  if not f then
    return nil, err
  end

  local content = f:read '*all'
  f:close()

  return content
end

---Read a file into a table of lines
---@param path string File path
---@param default? table Default value if file not found
---@return table|nil, string|nil Lines and error message
function file.read_lines(path)
  local content, err = file.read(path)
  if not content then
    return nil, err
  end

  return vim.split(content, '\n')
end

---Write a string to a file
---@param path string File path
---@param content string|table Content to write
---@param append? boolean Append to file instead of overwriting (default: false)
---@return boolean, string|nil Success and error message
function file.write(path, content, append)
  local mode = append and 'a' or 'w'
  local f, err = io.open(path, mode)
  if not f then
    return false, err
  end

  -- Convert table to string if needed
  if type(content) == 'table' then
    content = table.concat(content, '\n')
  end

  f:write(content)
  f:close()

  return true
end

---Append to a file
---@param path string File path
---@param content string|table Content to append
---@return boolean, string|nil Success and error message
function file.append(path, content)
  return file.write(path, content, true)
end

---Check if a file exists
---@param path string File path
---@return boolean
function file.exists(path)
  local f = io.open(path, 'r')
  if f then
    f:close()
    return true
  end
  return false
end

---Get file extension
---@param path string File path
---@return string Extension
function file.extension(path)
  return path:match '%.([^%.]+)$' or ''
end

---Get file size
---@param path string File path
---@return integer|nil Size in bytes
function file.size(path)
  local f = io.open(path, 'r')
  if not f then
    return nil
  end

  local size = f:seek 'end'
  f:close()

  return size
end

---Copy a file
---@param src string Source path
---@param dst string Destination path
---@param force? boolean Overwrite if exists (default: false)
---@return boolean, string|nil Success and error message
function file.copy(src, dst, force)
  -- Check source exists
  if not file.exists(src) then
    return false, 'Source file does not exist'
  end

  -- Check destination doesn't exist or force
  if file.exists(dst) and not force then
    return false, 'Destination file already exists'
  end

  -- Read source
  local content, err = file.read(src)
  if not content then
    return false, err
  end

  -- Write to destination
  return file.write(dst, content)
end

---Move/rename a file
---@param src string Source path
---@param dst string Destination path
---@param force? boolean Overwrite if exists (default: false)
---@return boolean, string|nil Success and error message
function file.move(src, dst, force)
  -- Try OS-level rename first
  local ok, err = os.rename(src, dst)
  if ok then
    return true
  end

  -- Fall back to copy and delete
  local copy_ok, copy_err = file.copy(src, dst, force)
  if not copy_ok then
    return false, copy_err
  end

  os.remove(src)
  return true
end

---Delete a file
---@param path string File path
---@return boolean, string|nil Success and error message
function file.delete(path)
  local ok, err = os.remove(path)
  if not ok then
    return false, err
  end
  return true
end

---Create a directory
---@param path string Directory path
---@param mode? string Permissions (default: "755")
---@param recursive? boolean Create parent directories (default: true)
---@return boolean, string|nil Success and error message
function file.mkdir(path, mode, recursive)
  mode = mode or '755'
  if recursive ~= false then
    recursive = true
  end

  local command
  if vim.fn.has 'win32' == 1 then
    command = recursive and 'mkdir "' .. path .. '"' or 'mkdir "' .. path .. '"'
  else
    command = recursive and 'mkdir -p "' .. path .. '"'
      or 'mkdir -m ' .. mode .. ' "' .. path .. '"'
  end

  local result = vim.fn.system(command)
  if vim.v.shell_error ~= 0 then
    return false, result
  end

  return true
end

---Remove a directory
---@param path string Directory path
---@param recursive? boolean Remove recursively (default: false)
---@return boolean, string|nil Success and error message
function file.rmdir(path, recursive)
  local command
  if vim.fn.has 'win32' == 1 then
    command = recursive and 'rmdir /s /q "' .. path .. '"'
      or 'rmdir "' .. path .. '"'
  else
    command = recursive and 'rm -rf "' .. path .. '"'
      or 'rmdir "' .. path .. '"'
  end

  local result = vim.fn.system(command)
  if vim.v.shell_error ~= 0 then
    return false, result
  end

  return true
end

---List directory contents
---@param path string Directory path
---@param pattern? string Pattern to filter results
---@return table|nil, string|nil List of files and error message
function file.ls(path, pattern)
  local command
  if vim.fn.has 'win32' == 1 then
    command = 'dir /b "' .. path .. '"'
  else
    command = 'ls -1 "' .. path .. '"'
  end

  local result = vim.fn.system(command)
  if vim.v.shell_error ~= 0 then
    return nil, result
  end

  local files = vim.split(result, '\n')

  -- Filter out empty entries
  local filtered = {}
  for _, name in ipairs(files) do
    if name ~= '' then
      if not pattern or name:match(pattern) then
        table.insert(filtered, name)
      end
    end
  end

  return filtered
end

---Get temporary directory path
---@return string Temp directory
function file.temp_dir()
  if vim.fn.has 'win32' == 1 then
    return vim.fn.expand '$TEMP'
  else
    return '/tmp'
  end
end

---Create a temporary file
---@param prefix? string Filename prefix
---@param suffix? string Filename suffix
---@param content? string|table Content to write
---@return string|nil, string|nil Path and error message
function file.temp_file(prefix, suffix, content)
  prefix = prefix or 'nv_'
  suffix = suffix or ''

  local tmp_dir = file.temp_dir()
  local path = M.path_join(tmp_dir, prefix .. M.text.random_string(8) .. suffix)

  if content then
    local ok, err = file.write(path, content)
    if not ok then
      return nil, err
    end
  end

  return path
end

---Get absolute path
---@param path string File path
---@return string Absolute path
function file.abs_path(path)
  if vim.fn.has 'win32' == 1 and not path:match '^%a:' then
    -- Windows relative path
    return vim.fn.fnamemodify(path, ':p')
  elseif not path:match '^/' then
    -- Unix relative path
    return vim.fn.fnamemodify(path, ':p')
  else
    -- Already absolute
    return path
  end
end

---Get relative path
---@param path string File path
---@param base? string Base directory (default: current directory)
---@return string Relative path
function file.rel_path(path, base)
  base = base or vim.fn.getcwd()

  -- Ensure both paths are absolute
  path = file.abs_path(path)
  base = file.abs_path(base)

  -- Try to use built-in function first
  local rel = vim.fn.fnamemodify(path, ':~:.')

  -- If it starts with ~, we need a different approach
  if rel:match '^~' then
    -- Windows-specific logic
    if vim.fn.has 'win32' == 1 then
      path = path:gsub('/', '\\')
      base = base:gsub('/', '\\')

      -- Remove drive letters if they're the same
      local path_drive = path:match '^(%a:)'
      local base_drive = base:match '^(%a:)'

      if
        path_drive
        and base_drive
        and path_drive:lower() == base_drive:lower()
      then
        path = path:sub(3)
        base = base:sub(3)
      end
    end

    -- Add trailing slash to base for proper path calculation
    if not base:match '[/\\]$' then
      base = base .. (vim.fn.has 'win32' == 1 and '\\' or '/')
    end

    -- Count directory levels needed to go up
    local common_prefix_len = 0
    local path_parts = vim.split(path, vim.fn.has 'win32' == 1 and '\\' or '/')
    local base_parts = vim.split(base, vim.fn.has 'win32' == 1 and '\\' or '/')

    for i = 1, math.min(#path_parts, #base_parts) do
      if path_parts[i]:lower() == base_parts[i]:lower() then
        common_prefix_len = i
      else
        break
      end
    end

    local up_dirs = #base_parts - common_prefix_len
    local remaining_dirs = {}

    for i = common_prefix_len + 1, #path_parts do
      table.insert(remaining_dirs, path_parts[i])
    end

    local sep = vim.fn.has 'win32' == 1 and '\\' or '/'
    local up_path = string.rep('..' .. sep, up_dirs)

    rel = up_path .. table.concat(remaining_dirs, sep)
  end

  return rel
end

-- Add file module to nv
M.file = file

-- ================================
-- Plugin development helpers
-- ================================

---@class NvPluginModule Plugin development utilities
local plugin = {}

---Lazy load a module
---@param module_name string Module name
---@param default? any Default value if module not found
---@return any Module or default value
function plugin.require(module_name, default)
  local ok, module = pcall(require, module_name)
  if not ok then
    return default
  end
  return module
end

---Get plugin configuration directory
---@return string Config directory path
function plugin.config_dir()
  if vim.fn.has 'win32' == 1 then
    return vim.fn.expand '$LOCALAPPDATA/nvim'
  else
    return vim.fn.expand '$HOME/.config/nvim'
  end
end

---Get plugin data directory
---@return string Data directory path
function plugin.data_dir()
  if vim.fn.has 'win32' == 1 then
    return vim.fn.expand '$LOCALAPPDATA/nvim-data'
  else
    return vim.fn.expand '$HOME/.local/share/nvim'
  end
end

---Create a plugin setup function
---@param default_opts table Default options
---@return function Setup function
function plugin.create_setup(default_opts)
  local opts = vim.deepcopy(default_opts) or {}

  return function(user_opts)
    if user_opts then
      opts = vim.tbl_deep_extend('force', opts, user_opts)
    end

    return opts
  end
end

---Register an autocommand group for a plugin
---@param plugin_name string Plugin name
---@param definitions table Autocommand definitions
---@param clear? boolean Clear existing commands (default: true)
---@return integer Augroup ID
function plugin.augroup(plugin_name, definitions, clear)
  local group_name = plugin_name .. 'AutoCommands'

  return M.augroup_cmds(group_name, clear, definitions)
end

---Create a plugin command
---@param name string Command name
---@param callback function|string Command callback or string
---@param opts? table Command options
function plugin.command(name, callback, opts)
  opts = opts or {}

  M.create_command(name, callback, opts)
end

---Define plugin key mappings
---@param mappings table<string, {[1]:string|string[], [2]:string|function, [3]:table?}> Mapping definitions
function plugin.mappings(mappings)
  for key, mapping in pairs(mappings) do
    local modes = mapping[1]
    local rhs = mapping[2]
    local opts = mapping[3] or {}

    M.map(modes, key, rhs, opts)
  end
end

---Check if a plugin is installed
---@param plugin_name string Plugin name
---@return boolean Is installed
function plugin.is_installed(plugin_name)
  -- Check based on package manager
  local has_packer = pcall(require, 'packer')
  local has_lazy = pcall(require, 'lazy')

  if has_packer then
    local packer = require 'packer'
    local plugins = packer.get_plugins()

    for name, _ in pairs(plugins) do
      if name:match(plugin_name) then
        return true
      end
    end
  elseif has_lazy then
    local lazy = require 'lazy'
    local plugins = lazy.plugins()

    for _, plugin in ipairs(plugins) do
      if plugin.name == plugin_name then
        return true
      end
    end
  else
    -- Fallback: check if module can be loaded
    return pcall(require, plugin_name)
  end

  return false
end

---Create a plugin-specific namespace
---@param plugin_name string Plugin name
---@return Namespace
function plugin.namespace(plugin_name)
  return api.nvim_create_namespace(plugin_name)
end

---Create a plugin user settings table
---@param plugin_name string Plugin name
---@param default_settings table Default settings
---@return table User settings
function plugin.settings(plugin_name, default_settings)
  local user_settings = vim.g[plugin_name .. '_settings'] or {}

  return vim.tbl_deep_extend('force', default_settings, user_settings)
end

---Create a path in plugin data directory
---@param plugin_name string Plugin name
---@param ... string Path components
---@return string Full path
function plugin.data_path(plugin_name, ...)
  local base = M.path_join(plugin.data_dir(), plugin_name)

  -- Create directory if it doesn't exist
  if not M.dir_exists(base) then
    M.mkdir(base)
  end

  if select('#', ...) > 0 then
    return M.path_join(base, ...)
  else
    return base
  end
end

---Load plugin data from JSON file
---@param plugin_name string Plugin name
---@param filename string File name
---@param default? table Default data if file not found
---@return table Data
function plugin.load_data(plugin_name, filename, default)
  default = default or {}

  local path = plugin.data_path(plugin_name, filename)
  if not M.file_exists(path) then
    return default
  end

  local content = M.file.read(path)
  if not content then
    return default
  end

  local data = vim.json.decode(content)
  if not data then
    return default
  end

  return data
end

---Save plugin data to JSON file
---@param plugin_name string Plugin name
---@param filename string File name
---@param data table Data to save
---@return boolean Success
function plugin.save_data(plugin_name, filename, data)
  local path = plugin.data_path(plugin_name, filename)

  local content = vim.json.encode(data)
  if not content then
    return false
  end

  return M.file.write(path, content)
end

---Handle plugin error
---@param err string|table Error message or error object
---@param level? string|integer Log level (default: "error")
function plugin.handle_error(err, level)
  level = level or 'error'

  if type(err) == 'table' and err.message then
    err = err.message .. (err.traceback and ('\n' .. err.traceback) or '')
  end

  M.notify('Plugin error: ' .. err, level)

  -- Log to file if possible
  pcall(function()
    local log_path = plugin.data_path 'plugin_errors.log'
    local timestamp = os.date '%Y-%m-%d %H:%M:%S'
    local log_entry = timestamp .. ' - ' .. err .. '\n'
    M.file.append(log_path, log_entry)
  end)
end

-- Add plugin module to nv
M.plugin = plugin

-- ================================
-- Additional integrations
-- ================================

---@class NvIntegrationsModule Integrations with other plugins
local integrations = {}

---Check if a plugin is loaded
---@param plugin_name string Plugin name
---@return boolean Plugin is loaded
function integrations.has_plugin(plugin_name)
  return M.plugin.is_installed(plugin_name)
end

-- Telescope integration
integrations.telescope = setmetatable({}, {
  __index = function(_, key)
    if not integrations.has_plugin 'telescope.nvim' then
      error 'Telescope is not installed'
    end

    local telescope = require 'telescope.builtin'

    if telescope[key] then
      return telescope[key]
    end

    error('Unknown Telescope function: ' .. key)
  end,
})

-- nvim-cmp integration
integrations.cmp = setmetatable({}, {
  __index = function(_, key)
    if not integrations.has_plugin 'nvim-cmp' then
      error 'nvim-cmp is not installed'
    end

    local cmp = require 'cmp'

    if cmp[key] then
      return cmp[key]
    end

    error('Unknown nvim-cmp function: ' .. key)
  end,
})

-- Tree-sitter integration
integrations.treesitter = {}

---Get syntax tree at cursor
---@param bufnr? BufferNumber Buffer to get tree from (default: current)
---@return table|nil Syntax tree
function integrations.treesitter.get_tree(bufnr)
  if not integrations.has_plugin 'nvim-treesitter' then
    error 'nvim-treesitter is not installed'
  end

  bufnr = bufnr or M.buf()

  local ts_parsers = require 'nvim-treesitter.parsers'
  local ts_utils = require 'nvim-treesitter.ts_utils'

  local lang = ts_parsers.get_buf_lang(bufnr)
  if not ts_parsers.has_parser(lang) then
    return nil
  end

  return ts_utils.get_tree_root(ts_utils.get_node_at_cursor())
end

---Get treesitter node at cursor
---@return table|nil Node
function integrations.treesitter.get_node_at_cursor()
  if not integrations.has_plugin 'nvim-treesitter' then
    error 'nvim-treesitter is not installed'
  end

  local ts_utils = require 'nvim-treesitter.ts_utils'
  return ts_utils.get_node_at_cursor()
end

---Get node text
---@param node table Treesitter node
---@param bufnr? BufferNumber Buffer to get text from (default: current)
---@return string Node text
function integrations.treesitter.get_node_text(node, bufnr)
  if not integrations.has_plugin 'nvim-treesitter' then
    error 'nvim-treesitter is not installed'
  end

  bufnr = bufnr or M.buf()

  local ts_utils = require 'nvim-treesitter.ts_utils'
  return ts_utils.get_node_text(node, bufnr)
end

-- Add integrations module to nv
M.integrations = integrations

-- ================================
-- Module exports
-- ================================

-- Set global for easy access in commands
_G.nv = M

-- Return module
return M
