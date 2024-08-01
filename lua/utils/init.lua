---@diagnostic disable: deprecated
local M = {}

function M.custom_notify(message, level)
  local levels = {
    DEBUG = 1,
    ERROR = 4,
    INFO = 2,
    OFF = 5,
    TRACE = 0,
    WARN = 3,
  }
  local highlight = {
    [levels.ERROR] = "ErrorMsg",
    [levels.WARN] = "WarningMsg",
    [levels.INFO] = "None",
    [levels.DEBUG] = "Comment",
  }
  local style = {
    [levels.ERROR] = "✗",
    [levels.WARN] = "⚠",
    [levels.INFO] = "ℹ",
    [levels.DEBUG] = "☰",
  }
  -- Check if level is a string or a number
  local levelValue = type(level) == "number" and level or levels[level]
  local icon = style[levelValue] or "ℹ"
  local hl = highlight[levelValue] or "None"
  vim.notify(icon .. ": " .. message, levelValue, { highlight = hl })
end

local swap_pairs = {
  { "true", "false" },
  { "1", "0" },
  { "foo", "bar" },
  { "TRUE", "FALSE" },
  { "True", "False" },
  { "fg", "bg" },
  { "open", "close" },
  { "always", "never" },
}

function M.swapBooleanInLine()
  local line = vim.api.nvim_get_current_line()
  for _, pair in ipairs(swap_pairs) do
    local a, b = unpack(pair)
    line = line:find(a) and line:gsub(a, b)
      or line:find(b) and line:gsub(b, a)
      or line
  end
  vim.api.nvim_set_current_line(line)
end

--- A simple and clean fold function, thanks https://github.com/tamton-aquib/essentials.nvim
---@return string: foldtext
M.simple_fold = function()
  local fs, fe = vim.v.foldstart, vim.v.foldend
  local start_line = vim.fn.getline(fs):gsub("\t", ("\t"):rep(vim.opt.ts:get()))
  local end_line = vim.trim(vim.fn.getline(fe))
  local spaces = (" "):rep(
    vim.o.columns - start_line:len() - end_line:len() - 7
  )

  return start_line .. "  " .. end_line .. spaces
end
-- set this: vim.opt.foldtext = 'v:lua.require("essentials").simple_fold()'

M.file_path = vim.fn.stdpath("config") .. "/plugin/colorswitch.lua"

---@param old string
---@param new string
---@return nil
function M.replace_word(old, new)
  local file, err = io.open(M.file_path, "r")
  if not file then
    vim.notify("Failed to open file: " .. err, vim.log.levels.ERROR)
    return
  end
  local content = file:read("*all")
  file:close()
  -- Escape dashes in both old and new strings
  local escaped_old = string.gsub(old, "([%-])", "%%%1")
  local escaped_new = string.gsub(new, "([%-])", "%%%1")
  -- local added_pattern = string.gsub(old, "-", "%%-") -- add % before - if exists
  local new_content = content:gsub(escaped_old, escaped_new)
  file, err = io.open(M.file_path, "w")
  if not file then
    vim.notify("Failed to open file for writing: " .. err, vim.log.levels.ERROR)
    return
  end
  file:write(new_content)
  file:close()
end

-- idea thanks to MariaSolOs:
-- https://github.com/MariaSolOs/dotfiles/blob/main/.config/nvim/lua/commands.lua#L36
-- Function to open GitHub links in lua and go
function M.gxhandler()
  local file = vim.fn.expand("<cfile>")
  local ft = vim.bo.filetype
  if ft == "lua" then
    local link = file:match("%w[%w%-]+/[%w%-%._]+")
    if link then
      vim.fn.system("open https://www.github.com/" .. link)
    end
  elseif ft == "go" then
    vim.fn.system("open https://www." .. file)
  else
    vim.notify("Unsupported filetype for gxhandler")
  end
end

-- Function to open dotfyle links for lua plugins
function M.gxdotfyle()
  local file = vim.fn.expand("<cfile>")
  -- Consider anything that looks like string/string a GitHub link.
  local link = file:match("%w[%w%-]+/[%w%-%._]+")
  if link then
    vim.fn.system("open https://www.dotfyle.com/plugins/" .. link)
  else
    vim.notify("Failed to open link: " .. file, vim.log.levels.ERROR)
  end
end

function M.diff_with_clipboard()
  local ftype = vim.api.nvim_get_option_value("filetype", {})
  local cmd = string.format(
    [[
    normal! "xy
    vsplit
    enew
    normal! P
    setlocal buftype=nowrite
    set filetype=%s
    diffthis
    normal! \<C-w>\<C-w>
    enew
    set filetype=%s
    normal! "xP
    diffthis
  ]],
    ftype,
    ftype
  )
  vim.api.nvim_exec2(cmd, {})
end

function M.diff_with_clipboard2()
  local selected_text = vim.fn.getreg('"')
  local _, diff = pcall(require, "mini.diff")
  diff.set_ref_text(0, selected_text)
  diff.toggle_overlay(0)
end

function M.messages_to_quickfix()
  -- Execute :messages command and capture output
  local messages = vim.fn.execute("messages")
  -- Split the output into lines
  local lines = vim.split(messages, "\n")
  -- Create a table of dictionaries for the quickfix list
  local qf_items = {}
  for _, line in ipairs(lines) do
    -- Trim leading and trailing whitespace
    local trimmed_line = line:gsub("^%s*(.-)%s*$", "%1")
    -- Skip if the line is empty
    if trimmed_line ~= "" then
      table.insert(qf_items, { text = trimmed_line })
    end
  end
  -- Set the quickfix list
  vim.fn.setqflist(qf_items, "r")
  vim.cmd.copen()
  vim.cmd("$")
end

---Read file contents
---@param path string
---@return string?
function M.read_file(path)
  local file = io.open(path, "r")
  if not file then
    return nil
  end
  local content = file:read("*a")
  file:close()
  return content or ""
end

function M.grepandopen()
  vim.ui.input({ prompt = "Enter pattern: " }, function(pattern)
    if pattern ~= nil then
      vim.cmd("silent grep! " .. pattern)
      vim.cmd("copen")
      vim.fn.matchadd("Search", pattern)
    end
  end)
end

---@return nil
function M.helpgrepnopen()
  vim.ui.input({ prompt = "Enter pattern: " }, function(pattern)
    if pattern ~= nil then
      vim.cmd("silent helpgrep " .. pattern)
      vim.cmd("copen")
      vim.fn.matchadd("Search", pattern)
    end
  end)
end

--This code below regarding statuscolumn was borrowed from LazyVim.
--credit to folke/LazyVim https://github.com/LazyVim/LazyVim
-- Returns a list of regular and extmark signs sorted by priority (low to high)
---@alias Sign {name:string, text:string, texthl:string, priority:number}

-- Returns a list of regular and extmark signs sorted by priority (low to high)
---@return Sign[]
---@param buf number
---@param lnum number
function M.get_signs(buf, lnum)
  -- Get regular signs
  ---@type Sign[]
  local signs = {}

  -- Get extmark signs
  local extmarks = vim.api.nvim_buf_get_extmarks(
    buf,
    -1,
    { lnum - 1, 0 },
    { lnum - 1, -1 },
    { details = true, type = "sign" }
  )
  for _, extmark in pairs(extmarks) do
    signs[#signs + 1] = {
      name = extmark[4].sign_hl_group or extmark[4].sign_name or "",
      text = extmark[4].sign_text,
      texthl = extmark[4].sign_hl_group,
      priority = extmark[4].priority,
    }
  end

  -- Sort by priority
  table.sort(signs, function(a, b)
    return (a.priority or 0) < (b.priority or 0)
  end)

  return signs
end

---@return Sign?
---@param buf number
---@param lnum number
function M.get_mark(buf, lnum)
  local marks = vim.fn.getmarklist(buf)
  vim.list_extend(marks, vim.fn.getmarklist())
  for _, mark in ipairs(marks) do
    if
      mark.pos[1] == buf
      and mark.pos[2] == lnum
      and mark.mark:match("[a-zA-Z]")
    then
      return { text = mark.mark:sub(2), texthl = "DiagnosticHint" }
    end
  end
end

---@param sign? Sign
---@param len? number
function M.icon(sign, len)
  sign = sign or {}
  len = len or 2
  local text = vim.fn.strcharpart(sign.text or "", 0, len) ---@type string
  text = text .. string.rep(" ", len - vim.fn.strchars(text))
  return sign.texthl and ("%#" .. sign.texthl .. "#" .. text .. "%*") or text
end

---FOLD FUNCTION --------------------
---@return string
function M.foldtext()
  local start_line = vim.api.nvim_buf_get_lines(
    0,
    vim.v.foldstart - 1,
    vim.v.foldstart,
    false
  )[1]
  local end_line =
    vim.api.nvim_buf_get_lines(0, vim.v.foldend - 1, vim.v.foldend, false)[1]

  -- Replace tabs with spaces
  start_line = start_line:gsub("\t", string.rep(" ", vim.bo.tabstop))

  -- Trim whitespace
  end_line = end_line:gsub("^%s*(.-)%s*$", "%1")

  return start_line .. " ... " .. end_line
end

function M.statuscolumn()
  local win = vim.g.statusline_winid
  local buf = vim.api.nvim_win_get_buf(win)
  local is_file = vim.bo[buf].buftype == ""
  local show_signs = vim.wo[win].signcolumn ~= "no"

  local components = { "", "", "" } -- left, middle, right

  if show_signs then
    local signs = M.get_signs(buf, vim.v.lnum)

    ---@type Sign?,Sign?,Sign?
    local left, right, fold, githl
    for _, s in ipairs(signs) do
      if s.name and (s.name:find("GitSign") or s.name:find("MiniDiffSign")) then
        right = s
      else
        left = s
      end
    end

    -- Left: mark or non-git sign
    components[1] = M.icon(M.get_mark(buf, vim.v.lnum) or left)
    -- Right: fold icon or git sign (only if file)
    components[3] = is_file and M.icon(fold or right) or ""
  end

  -- Numbers in Neovim are weird
  -- They show when either number or relativenumber is true
  local is_num = vim.wo[win].number
  local is_relnum = vim.wo[win].relativenumber
  if (is_num or is_relnum) and vim.v.virtnum == 0 then
    if vim.fn.has("nvim-0.11") == 1 then
      components[2] = "%l" -- 0.11 handles both the current and other lines with %l
    else
      if vim.v.relnum == 0 then
        components[2] = is_num and "%l" or "%r" -- the current line
      else
        components[2] = is_relnum and "%r" or "%l" -- other lines
      end
    end
    components[2] = "%=" .. components[2] .. " " -- right align
  end

  if vim.v.virtnum ~= 0 then
    components[2] = "%= "
  end

  return table.concat(components, "")
end

--- Merge one or more tables into the first table.
---@generic T
---@param base T
---@vararg T
---@return T
function M.mergeTables(base, ...)
  for _, additional in ipairs({ ... }) do
    for k, v in pairs(additional) do
      base[k] = v
    end
  end
  return base
end

-- Neovim Utils
--- returns current vim mode name
function M.get_mode_name()
  local mode_names = {
    n = "no",
    no = "n?",
    nov = "n?",
    noV = "n?",
    ["no\22"] = "n?",
    niI = "ni",
    niR = "nr",
    niV = "nv",
    nt = "nt",
    v = "vi",
    vs = "vs",
    V = "v_",
    Vs = "vs",
    ["\22"] = "^V",
    ["\22s"] = "^V",
    s = "se",
    S = "s_",
    ["\19"] = "^S",
    i = "in",
    ic = "ic",
    ix = "ix",
    R = "re",
    Rc = "rc",
    Rx = "rx",
    Rv = "rv",
    Rvc = "rv",
    Rvx = "rv",
    c = "co",
    cv = "ex",
    r = "..",
    rm = "m.",
    ["r?"] = "??",
    ["!"] = "!!",
    t = "te",
  }
  return mode_names[vim.api.nvim_get_mode().mode]
end

--- returns current vim mode highlight
--- @return string
function M.get_mode_hl()
  local mode_hls = {
    n = "NormalMode" and "NormalMode" or "CursorLineNr",
    i = "InsertMode" and "InsertMode" or "TermCursor",
    v = "VisualMode",
    V = "VisualMode",
    ["\22"] = "VisualMode",
    c = "CommandMode",
    s = "SelectMode",
    S = "SelectMode",
    ["\19"] = "SelectMode",
    R = "ControlMode",
    r = "ControlMode",
    ["!"] = "NormalMode",
    t = "TerminalMode",
  }

  return mode_hls[vim.api.nvim_get_mode().mode]
end

return M
