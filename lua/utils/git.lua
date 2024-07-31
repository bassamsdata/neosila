-- Get Git branch Name ---------------------------------------------
local M = {}
-- Utility function to perform checks --------------------------------
---@param buf_id number
---@return boolean
local function is_valid_git_repo(buf_id)
  -- Check if it's a valid buffer
  local path = vim.api.nvim_buf_get_name(buf_id)
  if path == "" or vim.fn.filereadable(path) ~= 1 then
    return false
  end
  -- Check if the current directory is a Git repository
  if vim.fs.root(path, ".git") == 0 then
    return false
  end

  return true
end

local branch_cache = {}

-- Function to clear the Git branch cache -----------------------------
---@return nil
M.clear_git_branch_cache = function()
  -- Clear by doing an empty table :)
  branch_cache = {}
end

---@param data table
---@param cwd string
M.update_git_branch = function(data, cwd)
  if not is_valid_git_repo(data.buf) then
    return
  end

  -- Check if branch is already cached
  ---@type string
  local cached_branch = branch_cache[data.buf]
  if cached_branch then
    vim.b.git_branch = cached_branch
    return
  end

  ---@param content table
  ---@see vim.system
  local function on_exit(content)
    if content.code == 0 then
      vim.b.git_branch = content.stdout:gsub("\n", "") -- Remove newline character
      branch_cache[data.buf] = vim.b.git_branch -- Cache the branch name
    end
  end
  vim.system(
    { "git", "-C", vim.fs.root(0, ".git"), "branch", "--show-current" },
    { text = true, cwd = cwd },
    on_exit
  )
end

---@return string?
M.copy_hunk_ref_text = function()
  local _, MiniDiff = pcall(require, "mini.diff")
  local buf_data = MiniDiff.get_buf_data()
  if buf_data == nil then
    return
  end

  -- Get hunk under cursor
  local cur_line, cur_hunk = vim.fn.line("."), nil
  for _, h in ipairs(buf_data.hunks) do
    local count = math.max(h.buf_count, 1)
    if h.buf_start <= cur_line and cur_line <= h.buf_start + count then
      cur_hunk = h
    end
  end
  if cur_hunk == nil then
    return
  end

  -- Get hunk's reference lines
  local ref_lines = vim.split(buf_data.ref_text, "\n")
  local from, to =
    cur_hunk.ref_start, cur_hunk.ref_start + cur_hunk.ref_count - 1
  local hunk_ref_lines = vim.list_slice(ref_lines, from, to)

  -- Populate register '"' (to be usable with plain `p`) with target lines
  vim.fn.setreg('"', hunk_ref_lines, "l")
end

return M
------------------------------------------------------------------------
