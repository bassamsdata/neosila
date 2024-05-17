---@diagnostic disable: undefined-field
local autocmd = vim.api.nvim_create_autocmd
return {
	{
		"echasnovski/mini.files",
		-- Thanks  to Bekaboo for the init function https://github.com/Bekaboo/nvim
		init = function() -- Load files on startup only when editing a directory
			-- vim.g.loaded_fzf_file_explorer = 1
			-- vim.g.loaded_netrw = 1
			-- vim.g.loaded_netrwPlugin = 1
			vim.api.nvim_create_autocmd("BufWinEnter", {
				nested = true,
				callback = function(info)
					local path = info.file
					if path == "" then
						return
					end
					local stat = vim.uv.fs_stat(path)
					if stat and stat.type == "directory" then
						vim.api.nvim_del_autocmd(info.id)
						require("mini.files")
						vim.cmd.edit({
							bang = true,
							mods = { keepjumps = true },
						})
						return true
					end
				end,
			})
		end,
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
					local MiniFiles = require("mini.files")
					local current_file = vim.fn.expand("%")
					local _ = MiniFiles.close() or MiniFiles.open(current_file, false)
					vim.defer_fn(function()
						MiniFiles.reveal_cwd()
					end, 30)
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
			local cacheTimeout = 2000 -- in milliseconds

			local function mapSymbols(status)
				local statusMap = {
          -- stylua: ignore start 
          [" M"] = { symbol = "•", hlGroup  = "MiniDiffSignChange"}, -- Modified in the working directory
          ["M "] = { symbol = "✹", hlGroup  = "MiniDiffSignChange"}, -- modified in index
          ["MM"] = { symbol = "≠", hlGroup  = "MiniDiffSignChange"}, -- modified in both working tree and index
          ["A "] = { symbol = "+", hlGroup  = "MiniDiffSignAdd"   }, -- Added to the staging area, new file
          ["AA"] = { symbol = "≈", hlGroup  = "MiniDiffSignAdd"   }, -- file is added in both working tree and index
          ["D "] = { symbol = "-", hlGroup  = "MiniDiffSignDelete"}, -- Deleted from the staging area
          ["AM"] = { symbol = "⊕", hlGroup  = "MiniDiffSignChange"}, -- added in working tree, modified in index
          ["AD"] = { symbol = "-•", hlGroup = "MiniDiffSignChange"}, -- Added in the index and deleted in the working directory
          ["R "] = { symbol = "→", hlGroup  = "MiniDiffSignChange"}, -- Renamed in the index
          ["U "] = { symbol = "‖", hlGroup  = "MiniDiffSignChange"}, -- Unmerged path
          ["UU"] = { symbol = "⇄", hlGroup  = "MiniDiffSignAdd"   }, -- file is unmerged
          ["UA"] = { symbol = "⊕", hlGroup  = "MiniDiffSignAdd"   }, -- file is unmerged and added in working tree
          ["??"] = { symbol = "?", hlGroup  = "MiniDiffSignDelete"}, -- Untracked files
          ["!!"] = { symbol = "!", hlGroup  = "MiniDiffSignChange"}, -- Ignored files
					-- stylua: ignore end
				}

				local result = statusMap[status]
					or { symbol = "?", hlGroup = "NonText" }
				return result.symbol, result.hlGroup
			end

			---@param cwd string
			---@param callback function
			local function fetchGitStatus(cwd, callback)
				local function on_exit(content)
					if content.code == 0 then
						callback(content.stdout)
						vim.g.content = content.stdout
					end
				end
				vim.system(
					{ "git", "status", "--ignored", "--porcelain" },
					{ text = true, cwd = cwd },
					on_exit
				)
			end

			---@param str string?
			local function escapePattern(str)
				if str then
					return str:gsub("([%^%$%(%)%%%[%]%*%+%-%?%.])", "%%%1")
				end
			end

			---@param buf_id integer
			---@param gitStatusMap table
			local function updateMiniWithGit(buf_id, gitStatusMap)
				vim.schedule(function()
					local nlines = vim.api.nvim_buf_line_count(buf_id)
					local cwd = vim.fs.root(vim.env.PWD, ".git")
					local escapedcwd = escapePattern(cwd)
					if vim.fn.has("win32") == 1 then
						if escapedcwd then
							escapedcwd = escapedcwd:gsub("\\", "/")
						end
					end

					for i = 1, nlines do
						local entry = MiniFiles.get_fs_entry(buf_id, i)
						if not entry then
							break
						end
						local relativePath = entry.path:gsub("^" .. escapedcwd .. "/", "")
						local status = gitStatusMap[relativePath]

						if status then
							local symbol, hlGroup = mapSymbols(status)
							vim.api.nvim_buf_set_extmark(buf_id, nsMiniFiles, i - 1, 0, {
								sign_text = symbol,
								sign_hl_group = hlGroup,
								priority = 2,
							})
						else
						end
					end
				end)
			end

			-- Thanks for the idea of gettings https://github.com/refractalize/oil-git-status.nvim signs for dirs
			---@param content string
			---@return table
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

			---@param buf_id integer
			local function updateGitStatus(buf_id)
				if not vim.fs.root(vim.env.PWD, ".git") then
					return
				end
				local cwd = vim.fn.expand("%:p:h")
				-- local cwd = vim.fs.root(vim.uv.cwd(), ".git")
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
					end
				end,
			})
		end,
	},
}
