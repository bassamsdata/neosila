-- Get Git branch Name ---------------------------------------------
local M = {}
-- Utility function to perform checks
---@param buf_id number
---@return boolean
local function is_valid_git_repo(buf_id)
	-- Check if it's a valid buffer
	local path = vim.api.nvim_buf_get_name(buf_id)
	if path == "" or vim.fn.filereadable(path) ~= 1 then
		return false
	end
	-- Check if the current directory is a Git repository
	if vim.fn.isdirectory(".git") == 0 then
		return false
	end

	return true
end

local branch_cache = {}

-- Function to clear the Git branch cache
---@return nil
M.clear_git_branch_cache = function()
	-- Clear by doing an empty table :)
	branch_cache = {}
end

---@param data table
M.update_git_branch = function(data)
	if not is_valid_git_repo(data.buf) then
		return
	end

	-- Check if branch is already cached
	local cached_branch = branch_cache[data.buf]
	if cached_branch then
		vim.b.git_branch = cached_branch
		return
	end

	local stdout = vim.uv.new_pipe(false)
	local handle, pid
	handle, pid = vim.uv.spawn(
		"git",
		{
			args = { "-C", vim.fn.expand("%:p:h"), "branch", "--show-current" },
			stdio = { nil, stdout, nil },
		},
		vim.schedule_wrap(function(code, signal)
			if code == 0 then
				stdout:read_start(function(err, content)
					if content then
						vim.b.git_branch = content:gsub("\n", "") -- Remove newline character
						branch_cache[data.buf] = vim.b.git_branch -- Cache the branch name
						stdout:close()
					end
				end)
			else
				stdout:close()
			end
		end)
	)
end

return M
------------------------------------------------------------------------
