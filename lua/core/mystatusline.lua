-- Statusline setup
_G.statusline = {}

---Total rewrite of highlight function. Thanks to @MariaSolOs for the original idea.
---Keeps track of the highlight groups I've already created.
---@type table
statusline.highlight_definitions = {}

---@param name string
---@param hl_or_color string
---@param color_type? "bg"|"fg"
---@param bold? boolean
---@return string
function statusline.define_highlight(name, hl_or_color, color_type, bold)
  local hl_name = "Statusline" .. name

  statusline.highlight_definitions[hl_name] = {
    name = name,
    hl_or_color = hl_or_color,
    color_type = color_type,
    bold = bold,
  }

  statusline.create_or_update_hl(
    hl_name,
    statusline.highlight_definitions[hl_name]
  )

  return hl_name
end

-- Function to create or update a highlight
function statusline.create_or_update_hl(hl_name, def)
  local bg_hl = vim.api.nvim_get_hl(0, { name = "StatusLine" })
  local normal_hl = vim.api.nvim_get_hl(0, { name = "Normal" })
  local fg_color

  if def.hl_or_color:sub(1, 1) == "#" then
    fg_color = def.hl_or_color
  else
    local src_hl = vim.api.nvim_get_hl(0, { name = def.hl_or_color })
    ---@diagnostic disable-next-line: undefined-field
    if src_hl.link then -- handle highlight links
      ---@diagnostic disable-next-line: undefined-field
      src_hl = vim.api.nvim_get_hl(0, { name = src_hl.link })
    end
    local color_key = (def.color_type == "bg") and "bg" or "fg"
    fg_color = ("#%06x"):format(src_hl[color_key] or normal_hl[color_key])
  end

  vim.api.nvim_set_hl(0, hl_name, {
    bg = (bg_hl.bg ~= nil) and ("#%06x"):format(bg_hl.bg) or normal_hl.bg,
    fg = fg_color,
    bold = def.bold or false,
  })
end

-- Function to reload all defined highlights
function statusline.reload_highlights()
  for hl_name, def in pairs(statusline.highlight_definitions) do
    statusline.create_or_update_hl(hl_name, def)
  end
end

-- Function to setup the module
function statusline.init()
  -- Set up autocommand to reload highlights on colorscheme change
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup(
      "StatuslineHighlightReload",
      { clear = true }
    ),
    callback = statusline.reload_highlights,
  })
end

local mini_icons_loaded = false
local MiniIcons = nil

local function load_mini_icons()
  if not mini_icons_loaded then
    local ok
    ok, MiniIcons = pcall(require, "mini.icons")
    mini_icons_loaded = ok
  end
  return MiniIcons
end

-- Function to get the current mode text
---@return string
-- stylua: ignore start
local function get_mode()
  local modes = {
    ["n"]      = "NO",
    ["no"]     = "OP",
    ["nov"]    = "OC",
    ["noV"]    = "OL",
    ["no\x16"] = "OB",
    ["nt"]     = "NT",
    ["ntT"]    = "TM",
    ["v"]      = "VI",
    [""]     = "I",
    ["V"]      = "VL",
    ["s"]      = "SE",
    ["S"]      = "SL",
    ["\x13"]   = "SB",
    ["i"]      = "IN",
    ["ic"]     = "IC",
    ["ix"]     = "IX",
    ["R"]      = "RE",
    ["Rc"]     = "RC",
    ["Rx"]     = "RX",
    ["Rv"]     = "RV",
    ["Rvc"]    = "RC",
    ["Rvx"]    = "RX",
    ["c"]      = "CO",
    ["cv"]     = "CV",
    ["r"]      = "PR",
    ["rm"]     = "PM",
    ["r?"]     = "P?",
    ["!"]      = "SH",
    ["t"]      = "TE",
  }
  -- stylua: ignore end 
  local hl = vim.bo.mod and "TermCursor" or "Statusline"
  return string.format(
    "%%#%s# %s",
    hl,
    modes[vim.api.nvim_get_mode().mode] or "UNKNOWN"
  )
end

-- Function to get the current working directory name
---@return string
local function get_cwd()
  return string.format(
    " %%<%%#StatusLinePath# %s ",
    ---@diagnostic disable-next-line: undefined-field
    vim.fn.fnamemodify(vim.uv.cwd(), ":t")
  )
end

-- Function to get the current file path relative to CWD and modified status
---@return string
local function get_filename()
  if vim.bo.filetype == "intro" then
    return ""
  end
  local file = vim.fn.expand("%:p") -- Get the full path of the current file
---@diagnostic disable-next-line: undefined-field
  local cwd = vim.uv.cwd()
  local modified = vim.bo.modified and "  " or ""

  -- Calculate the relative path by removing the CWD from the full path
  local relative_path = file:gsub(cwd .. "/", "")
  vim.b.filename_statusline = relative_path

  -- If the file is directly inside the CWD, show only the file name
  if relative_path == file then
    relative_path = vim.fn.expand("%:t")
  end
  local _, MiniIcons = pcall(require, "mini.icons")
  local icon, hl, is_default = MiniIcons.get("file", tostring(relative_path))
  hl = statusline.define_highlight("Fileicon", hl)
  -- hl = require("utils.hi").blend_highlight_groups(hl, "StatusLine", "bg", 0.7)
  icon = is_default and "" or icon

  return string.format("%%#%s#%s %%#%s#%s%%#%s#%s ",
    hl,
    icon,
    "StatusLine",
    relative_path,
    statusline.define_highlight("Modified", "Special", nil,
      true), modified)
end

---@return string
local function get_git_status()
  local minidiff = vim.b.minidiff_summary
  local branch_name = vim.b.git_branch and "  " .. vim.b.git_branch or ""
  if not minidiff then
    return string.format(
      "%%#StatusLineGitBranch#%s ",
      branch_name
    )
  end
  -- this is a modfified logic from NvChad statusline ui (thank you) to show only if > 0.
  -- Define custom highlight groups for git status
  -- stylua: ignore start

  local added_hl   = statusline.define_highlight("GitAdded",   "MiniDiffSignAdd")
  local changed_hl = statusline.define_highlight("GitChanged", "MiniDiffSignChange")
  local removed_hl = statusline.define_highlight("GitRemoved", "MiniDiffSignDelete")
  -- Use the new highlight groups
  local added   = minidiff.add and minidiff.add       ~= 0 and string.format("%%#%s# +%d", added_hl,   minidiff.add) or ""
  local changed = minidiff.change and minidiff.change ~= 0 and string.format("%%#%s# ~%d", changed_hl, minidiff.change) or ""
  local removed = minidiff.delete and minidiff.delete ~= 0 and string.format("%%#%s# -%d", removed_hl, minidiff.delete) or ""
  -- stylua: ignore end
  return string.format(
    "%%#StatusLineGitBranch#%s %s%s%s",
    branch_name,
    added,
    changed,
    removed
  )
end


-- Function to get the LSP status
---@return string
local function get_lsp_status()
  local clients = vim.lsp.get_clients()
  for _, client in ipairs(clients) do
    ---@diagnostic disable-next-line: undefined-field
    local filetypes = client.config.filetypes
    if filetypes and vim.fn.index(filetypes, vim.bo.filetype) ~= -1 then
      return string.format("%%#StatusLineLSP#[%s]", client.name)
    end
  end
  return ""
end

local function getDiffSource()
  local buf_id = vim.api.nvim_get_current_buf()
  local diff_source = vim.b[buf_id].diffCompGit
  if not diff_source then
    return ""
  end
  return string.format("%%#StatusLineLSP#[%s]", diff_source)
end

-- Function to get the LLM status for CodeCompanion
-- TODO: add avante.nvim to it when it is ready
---@return string
local function get_llm_name()
  vim.api.nvim_create_autocmd("User", {
    pattern = "CodeCompanionChatAdapter",
    callback = function(args)
      -- vim.print(args.data.adapter)
      if args.data.adapter and not vim.tbl_isempty(args.data) then
        vim.b[args.data.bufnr].llm_name = args.data.adapter.name
        -- vim.b[args.data.bufnr].llm_model = args.data.adapter.schema.model.order
      end
    end,
  })

  local bufnr = vim.api.nvim_get_current_buf()
  local llm_name = vim.b[bufnr].llm_name
  -- local llm_model = vim.b[bufnr].llm_model

  if not llm_name then
    return ""
  end

  return vim.bo.filetype == "codecompanion" and string.format("%%#StatusLineLSP#[%s]", llm_name ) or ""
end

-- Function to get the line and column info
---@return string
local function get_line_info()
  -- local line = vim.fn.line(".")
  local column = vim.fn.col(".")
  local total_lines = vim.fn.line("$")
  -- local percent = math.floor((line / total_lines) * 100) .. tostring("%%")
  return string.format(
    " %%#StatusLinePosition#%02d/%d ",
    column,
    -- line,
    total_lines
    -- percent
  )
end


-- Function to get diagnostics count with improved efficiency
-- TODO: use vim.diagnostic.count() when it is stable
---@return string
local function get_diagnostics()
  if not vim.diagnostic.is_enabled() or vim.bo.filetype == "intro" then
    return ""
  end
  local diagnostics = vim.diagnostic.get(0)
  local counts = { 0, 0, 0, 0 }

  for _, d in ipairs(diagnostics) do
    counts[d.severity] = (counts[d.severity] or 0) + 1
  end

  local result = {}
  local severities = { "Error", "Warn", "Info", "Hint" }

  for i, severity in ipairs(severities) do

  local _, MiniIcons = pcall(require, "mini.icons")
    local icon, hl = MiniIcons.get("lsp", severity)
    hl = statusline.define_highlight(severity, hl)
    if counts[i] > 0 then
      table.insert(
        result,
        string.format(
          "%%#%s#%s%d",
          hl,
          icon,
          counts[i]
        )
      )
    end
  end

  return table.concat(result, " ")
end

-- TODO: add token when the markdown file is in this dir /Users/bassam/.local/share/nvim/parrot/chats
-- Function to get word count for markdown files
---@return string
local function get_word_count()
  if vim.bo.filetype == "markdown" or vim.bo.filetype == "codecompanion" then
    if vim.fn.expand("%:p:h") == vim.fn.expand("$HOME/.local/share/nvim/parrot/chats") then
      local word_count = vim.fn.wordcount().words
      local line_count = vim.fn.line("$")
      local char_count = vim.fn.line2byte(line_count + 1) - 1
      local token_count = math.floor(char_count / 4)  -- approximate token count, assuming 4 characters per token
      return string.format(" %%#StatusLineWordCount#%d words, %d tokens ", word_count, token_count)
    else
      local word_count = vim.fn.wordcount().words
      return string.format(" %%#StatusLineWordCount#%d words ", word_count)
    end
  end
  return ""
end

--- TODO: refactor this to use the new APIs from Arrow
---@return string
local function arrow_knot()
  -- Check if arrow.nvim is loaded
  if vim.g.arrow_enabled == nil then
    return ""
  end
  -- local current_file = vim.fn.expand("%")
  local current_file = vim.b.filename_statusline
  local arrow_files = vim.g.arrow_filenames
  -- Check if current file is in the Arrow list
  local file_in_arrow = false
  for _, filename in ipairs(arrow_files) do
    if filename == current_file then
      file_in_arrow = true
      break -- Found it, no need to continue the loop
    end
  end

  if not file_in_arrow then
    return ""
  end -- Only proceed if file is in the list
  local total_items = #arrow_files

  if total_items == 0 then
    return ""
  end

  local icon = { "󱡁 " }
  for index = 1, math.min(total_items, 3) do -- Iterate up to a maximum of 3 (whatever is less)
    local hl
    if arrow_files[index] == current_file then
      hl = statusline.define_highlight("ArrowCurrentFile", "Error", nil, true)
    else
      hl = "StatusLine"
    end

    table.insert(icon, string.format("%%#%s#%d", hl, index))
  end

  return table.concat(icon, "")
end

-- funtion for seprator
---@param sep string
---@param hl string
---@param func function
---@return string
local function get_sep(sep, hl, func)
  local content = func()
  if content == "" then
    return ""
  else
    return string.format("%%#%s#%s", hl, sep)
  end
end

-- Setup the statusline
function statusline.active()
  return table.concat({
    get_mode(),
    get_cwd(),
    get_git_status(),
    " %<",
    "%=",
    get_filename(),
    "%<",
    "%=",
    arrow_knot(),
    get_sep("|", "StatusLineSeparator", arrow_knot),
    get_llm_name(),
    getDiffSource(),
    get_diagnostics(),
    get_lsp_status(),
    get_line_info(),
    get_word_count(),
  })
end

-- Set the statusline
vim.o.statusline = "%!v:lua.statusline.active()"
return statusline
