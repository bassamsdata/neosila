local autocmd = vim.api.nvim_create_autocmd
return {
	{
		"echasnovski/mini.files",
		keys = {
			{ -- one keymapping to toggle
				"<leader>e",
				function()
					-- open  at the current file location
					local bufname = vim.api.nvim_buf_get_name(0)
					if vim.bo.filetype == "minintro" then -- adding if because of the customized intro
						local _ = require("mini.files").close()
							or require("mini.files").open()
					else
						local _ = require("mini.files").close()
							or require("mini.files").open(bufname, false)
					end
				end,
				{ desc = "File explorer" },
			},
			{ -- nice way to do that like oil
				"-",
				function()
					local current_file = vim.fn.expand("%")
					local _ = require("mini.files").close()
						or require("mini.files").open(current_file, false)
					vim.cmd("normal @")
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
				options = { permanent_delete = false },
			})

			local nsMiniFiles = vim.api.nvim_create_namespace("mini_files_git")

			-- Cache for git status
			local gitStatusCache = {}
			local cacheTimeout = 10000 -- Cache timeout in milliseconds
			local gitStatusChecked = {} -- Table to track if git status has been checked for a buffer

			local function mapSymbols(status)
				local statusMap = {
					[" M"] = { symbol = "•", hlGroup = "MiniDiffSignChange" },
					["A "] = { symbol = "+", hlGroup = "MiniDiffSignAdd" },
					["D "] = { symbol = "-", hlGroup = "MiniDiffSignDelete" },
					["??"] = { symbol = "?", hlGroup = "MiniDiffOverContext" },
					["!!"] = { symbol = "!", hlGroup = "NonText" },
				}

				local result = statusMap[status]
					or { symbol = "?", hlGroup = "GitSignsUnknown" }
				return result.symbol, result.hlGroup
			end

			local function fetchParseGitStatus(buf_id, callback)
				local startTime = os.clock()
				local stdout = vim.uv.new_pipe(false)
				local handle, pid
				handle, pid = vim.uv.spawn(
					"git",
					{
						args = { "status", "--porcelain" },
						stdio = { nil, stdout, nil },
					},
					vim.schedule_wrap(function(code, signal)
						if code == 0 then
							stdout:read_start(function(err, content)
								if content then
									local gitStatusMap = {}
									for line in content:gmatch("[^\r\n]+") do
										local status, filePath = string.match(line, "^(..)%s+(.*)")
										gitStatusMap[filePath] = status
									end
									callback(gitStatusMap)
									stdout:close()
								end
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
				local endTime = os.clock()
				local elapsedTime = (endTime - startTime) * 1000
				vim.notify(
					"fetchParseGitStatus took " .. elapsedTime .. " ms to execute.",
					vim.log.levels.INFO
				)
			end

			local function updateMiniWithGit(buf_id, gitStatusMap)
				-- Schedule the function to run on the main thread
				vim.schedule(function()
					local nlines = vim.api.nvim_buf_line_count(buf_id)
					local cwd = vim.fn.expand("%:p:h") -- we can use vim.fn.getcwd()

					for i = 1, nlines do
						local entry = MiniFiles.get_fs_entry(buf_id, i)
						local relativePath = entry.path:gsub("^" .. cwd .. "/", "")
						local status = gitStatusMap[relativePath]

						if status then
							local symbol, hlGroup = mapSymbols(status)
							vim.api.nvim_buf_set_extmark(buf_id, nsMiniFiles, i - 1, 0, {
								virt_text = { { symbol, hlGroup } },
								virt_text_pos = "right_align",
							})
							vim.notify(
								"Updated git status for: " .. relativePath,
								vim.log.levels.INFO
							)
						else
							-- vim.notify(
							-- 	"No git status for: " .. relativePath,
							-- 	vim.log.levels.WARN
							-- )
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
			local function updateGitStatus(buf_id)
				if not gitStatusChecked[buf_id] and is_valid_git_repo() then
					local currentTime = os.time()
					if
						gitStatusCache[buf_id]
						and currentTime - gitStatusCache[buf_id].time < cacheTimeout
					then
						updateMiniWithGit(buf_id, gitStatusCache[buf_id].statusMap)
					else
						fetchParseGitStatus(buf_id, function(gitStatusMap)
							gitStatusCache[buf_id] = {
								time = currentTime,
								statusMap = gitStatusMap,
							}
							updateMiniWithGit(buf_id, gitStatusMap)
						end)
					end
					gitStatusChecked[buf_id] = true
				end
			end

			vim.api.nvim_create_autocmd("User", {
				pattern = "MiniFilesBufferUpdate",
				callback = function(sii)
					local bufnr = sii.data.buf_id
					updateGitStatus(bufnr)
				end,
			})

		end,
	},
}
