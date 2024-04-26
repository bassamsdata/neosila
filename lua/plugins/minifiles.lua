---@diagnostic disable: undefined-field
local autocmd = vim.api.nvim_create_autocmd
return {
	{
		"echasnovski/mini.files",
		keys = {
			{ -- one keymapping to toggle
				"<leader>e",
				function()
					-- open  at the current file location
					-- local bufname = vim.api.nvim_buf_get_name(0)
					-- if vim.bo.filetype == "minintro" then -- adding if because of the customized intro
					local _ = require("mini.files").close()
						or require("mini.files").open()
					-- else
					-- 	local _ = require("mini.files").close()
					-- 		or require("mini.files").open(bufname, false)
					-- end
				end,
				{ desc = "File explorer" },
			},
			{ -- nice way to do that like oil
				"-",
				function()
					local current_file = vim.fn.expand("%")
					local _ = require("mini.files").close()
						or require("mini.files").open(current_file, false)
					vim.schedule(function()
						vim.defer_fn(function()
							vim.cmd("normal @")
						end, 10)
					end)
				end,
			},
		},
		config = function()
			-- create mappings for splits
			local map_split = function(buf_id, lhs, direction)
				local ok, MiniFiles = pcall(require, "mini.files")
				if not ok then
					return
				end
				local rhs = function()
					local window = MiniFiles.get_target_window()
					-- ensure doesn't make weired behaviour on directories
					if
						window == nil or MiniFiles.get_fs_entry().fs_type == "directory"
					then
						return
					end
					-- Make new window and set it as target
					local new_target_window
					vim.api.nvim_win_call(window, function()
						vim.cmd(direction .. " split")
						new_target_window = vim.api.nvim_get_current_win()
					end)
					MiniFiles.set_target_window(new_target_window)
					MiniFiles.go_in()
					MiniFiles.close()
				end

				-- Adding `desc` will result into `show_help` entries
				local desc = "Split " .. direction
				vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
			end

			autocmd("User", {
				pattern = "MiniFilesBufferCreate",
				callback = function(args)
					local buf_id = args.data.buf_id
					-- Tweak keys to your liking
					map_split(buf_id, "<C-s>", "belowright horizontal")
					map_split(buf_id, "<C-v>", "belowright vertical")
				end,
			})
			-- make rounded borders, credit to MariaSolos
			autocmd("User", {
				desc = "Add rounded corners to minifiles window",
				pattern = "MiniFilesWindowOpen",
				callback = function(args)
					vim.api.nvim_win_set_config(args.data.win_id, { border = "rounded" })
				end,
			})
			require("mini.files").setup({
				mappings = {
					show_help = "?",
					go_in_plus = "<cr>",
					go_out_plus = "<tab>",
				},
				options = {
					permanent_delete = false,
					use_as_default_explorer = true,
				},
				windows = {
					width_focus = 35,
					width_nofocus = 20,
				},
			})

			local nsMiniFiles = vim.api.nvim_create_namespace("mini_files_git")

			-- Cache for git status
			local gitStatusCache = {}
			local cacheTimeout = 2000 -- Cache timeout in milliseconds

			local function mapSymbols(status)
				local statusMap = {
					[" M"] = { symbol = "•", hlGroup = "MiniDiffSignChange" },
					["A "] = { symbol = "+", hlGroup = "MiniDiffSignAdd" },
					["D "] = { symbol = "-", hlGroup = "MiniDiffSignDelete" },
					["??"] = { symbol = "?", hlGroup = "MiniDiffSignDelete" },
					["!!"] = { symbol = "!", hlGroup = "MiniDiffSignChange" },
				}

				local result = statusMap[status]
					or { symbol = "?", hlGroup = "NonText" }
				return result.symbol, result.hlGroup
			end

			local function fetchGitStatus(cwd, callback)
				local stdout = (vim.uv or vim.loop).new_pipe(false)
				---@diagnostic disable-next-line: unused-local
				local handle, pid
				---@diagnostic disable-next-line: unused-local
				handle, pid = (vim.uv or vim.loop).spawn(
					"git",
					{
						args = { "status", ".", "--ignored", "--porcelain" },
						cwd = cwd,
						stdio = { nil, stdout, nil },
					},
					---@diagnostic disable-next-line: unused-local
					vim.schedule_wrap(function(code, signal)
						if code == 0 then
							---@diagnostic disable-next-line: unused-local
							stdout:read_start(function(err, content)
								if content then
									callback(content)
									vim.g.content = content
								end
								stdout:close()
							end)
						else
							vim.notify(
								"Git command failed with exit code: " .. code,
								vim.log.levels.ERROR
							)
							stdout:close()
						end
					end)
				)
			end

			local function escapePattern(str)
				return str:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
			end

			local function updateMiniWithGit(buf_id, gitStatusMap)
				vim.schedule(function()
					local nlines = vim.api.nvim_buf_line_count(buf_id)
					local cwd = vim.fn.getcwd() --  vim.fn.expand("%:p:h")
					local escapedcwd = escapePattern(cwd)

					for i = 1, nlines do
						local entry = MiniFiles.get_fs_entry(buf_id, i)
						-- TODO: probably we can use fnamemodify()
						-- local entry1 = vim.fn.fnamemodify(entry.path, ":t")
						-- vim.print(entry1)
						local relativePath = entry.path:gsub("^" .. escapedcwd .. "/", "")
						local status = gitStatusMap[relativePath]

						if status then
							local symbol, hlGroup = mapSymbols(status)
							vim.api.nvim_buf_set_extmark(buf_id, nsMiniFiles, i - 1, 0, {
								-- NOTE: if you want the signs on the right uncomment those and comment
								-- the 3 lines after
								-- virt_text = { { symbol, hlGroup } },
								-- virt_text_pos = "right_align",
								sign_text = symbol,
								sign_hl_group = hlGroup,
								priority = 2,
							})
						else
						end
					end
				end)
			end

			local function is_valid_git_repo()
				if vim.fn.isdirectory(".git") == 0 then
					return false
				end
				return true
			end

			-- Thanks for the idea of gettings https://github.com/refractalize/oil-git-status.nvim signs for dirs
			local function parseGitStatus(content)
				local gitStatusMap = {}
				-- lua match is faster than vim.split (in my experience )
				for line in content:gmatch("[^\r\n]+") do
					local status, filePath = string.match(line, "^(..)%s+(.*)")
					-- Split the file path into parts
					local parts = {}
					for part in filePath:gmatch("[^/]+") do
						table.insert(parts, part)
					end
					-- Start with the root directory
					local currentKey = ""
					for i, part in ipairs(parts) do
						if i > 1 then
							-- Concatenate parts with a separator to create a unique key
							currentKey = currentKey .. "/" .. part
						else
							currentKey = part
						end
						-- If it's the last part, it's a file, so add it with its status
						if i == #parts then
							gitStatusMap[currentKey] = status
						else
							-- If it's not the last part, it's a directory. Check if it exists, if not, add it.
							if not gitStatusMap[currentKey] then
								gitStatusMap[currentKey] = status
							end
						end
					end
				end
				return gitStatusMap
			end

			local function updateGitStatus(buf_id)
				if not is_valid_git_repo() then
					return print("Not a valid Git repository")
				end
				local cwd = vim.fn.expand("%:p:h")

				local currentTime = os.time()

				if
					gitStatusCache[cwd]
					and currentTime - gitStatusCache[cwd].time < cacheTimeout
				then
					updateMiniWithGit(buf_id, gitStatusCache[cwd].statusMap)
				else
					fetchGitStatus(cwd, function(content)
						local gitStatusMap = parseGitStatus(content)
						gitStatusCache[cwd] = {
							time = currentTime,
							statusMap = gitStatusMap,
						}
						updateMiniWithGit(buf_id, gitStatusMap)
					end)
				end
			end

			local function clearCache()
				gitStatusCache = {}
			end

			local function augroup(name)
				return vim.api.nvim_create_augroup(
					"MiniFiles_" .. name,
					{ clear = true }
				)
			end

			autocmd("User", {
				group = augroup("start"),
				pattern = "MiniFilesExplorerOpen",
				-- pattern = { "minifiles" },
				callback = function()
					local bufnr = vim.api.nvim_get_current_buf()
					updateGitStatus(bufnr)
				end,
			})

			autocmd("User", {
				group = augroup("close"),
				pattern = "MiniFilesExplorerClose",
				callback = function()
					clearCache()
				end,
			})

			autocmd("User", {
				group = augroup("update"),
				pattern = "MiniFilesBufferUpdate",
				callback = function(args)
					local bufnr = args.data.buf_id
					local cwd = vim.fn.expand("%:p:h")
					if gitStatusCache[cwd] then
						updateMiniWithGit(bufnr, gitStatusCache[cwd].statusMap)
						-- vim.notify("Git update updated", vim.log.levels.INFO)
					end
				end,
			})
		end,
	},
}
