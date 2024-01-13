return {
	-- { "cmpadden/pomodoro.nvim", keys = { "<leader>p" }, opts = {} },
	{
		"echasnovski/mini.pick",
		dependencies = {
			{ "echasnovski/mini.extra", opts = {} },
			{ "echasnovski/mini.visits", opts = {} },
			{ "echasnovski/mini.fuzzy", opts = {} },
		},
		cmd = "Pick",
		config = function()
			local MiniPick = require("mini.pick")
			local MiniExtra = require("mini.extra")

			-- copy the item under the cursor
			local copy_to_register = {
				char = "<C-y>",
				func = function()
					local line = vim.fn.line(".")
					local current_line = vim.fn.getline(line)
					vim.fn.setreg("+", current_line)
				end,
			}
			-- scrll by margin of 4 lines to not diorient
			local scroll_up = {
				char = "<C-k>",
				func = function()
					-- this is special character in insert mode press C-v then y
					-- while holding Ctrl to invoke
					vim.cmd("normal! 4")
				end,
			}
			local scroll_down = {
				char = "<C-j>",
				func = function()
					vim.cmd("norm! 4")
				end,
			}

			-- Setup 'mini.pick' with default window in the ceneter
			MiniPick.setup({
				use_cache = true,
				window = {
					config = function()
						local height = math.floor(0.618 * vim.o.lines)
						local width = math.floor(0.618 * vim.o.columns)
						return {
							border = "rounded",
							anchor = "NW",
							height = height,
							width = width,
							row = math.floor(0.5 * (vim.o.lines - height)),
							col = math.floor(0.5 * (vim.o.columns - width)),
						}
					end,
				},
				mappings = {
					copy_to_register = copy_to_register,
					scroll_up_a_bit = scroll_up,
					scroll_down_a_bit = scroll_down,
				},
			})
			vim.ui.select = MiniPick.ui_select
			-- == Styles ==
			-- 1 - File picker configuration that follows cursor
			local cursor_win_config = {
				border = "rounded",
				relative = "cursor",
				anchor = "NW",
				row = 0,
				col = 0,
				width = 50,
				height = 16,
			}
			-- 2 - Right side picker configuration
			local right_win_config = {
				border = "rounded",
				relative = "editor",
				anchor = "SE",
				row = vim.o.lines,
				col = vim.o.columns,
				height = 16,
				width = 50,
			}
			-- 3 - Center small window
			local height = math.floor(0.40 * vim.o.lines)
			local width = math.floor(0.40 * vim.o.columns)
			local center_small = {
				border = "rounded",
				anchor = "NW",
				height = height,
				width = width,
				row = math.floor(0.5 * (vim.o.lines - height)),
				col = math.floor(0.5 * (vim.o.columns - width)),
				-- relative = "editor",
			}

			-- Define a new picker for the quickfix list
			MiniPick.registry.quickfix = function()
				return MiniExtra.pickers.list({ scope = "quickfix" }, {})
			end

			-- Modify the 'files' picker directly
			MiniPick.registry.files = function()
				return MiniPick.builtin.files(
					{},
					{ window = { config = cursor_win_config } }
				)
			end

			-- Modify the 'old_files' picker directly
			MiniPick.registry.oldfiles = function()
				return MiniExtra.pickers.oldfiles(
					{},
					{ window = { config = cursor_win_config } }
				)
			end

			-- Modify the 'buffers' picker directly
			MiniPick.registry.buffers = function()
				return MiniPick.builtin.buffers(
					{},
					{ window = { config = right_win_config } }
				)
			end

			-- Modify the 'old_files' picker directly
			MiniPick.registry.history = function()
				return MiniExtra.pickers.history(
					{},
					{ window = { config = center_small } }
				)
			end
			-- TODO: enhance this one by remocving mini.fuzzy dependencies and move things outside loops
			-- this got it from https://github.com/echasnovski/mini.nvim/discussions/609#
			MiniPick.registry.frecency = function()
				local visit_paths = MiniVisits.list_paths()
				local current_file = vim.fn.expand("%")
				MiniPick.builtin.files(nil, {
					source = {
						match = function(stritems, indices, query)
							-- Concatenate prompt to a single string
							local prompt = vim.pesc(table.concat(query))

							-- If ignorecase is on and there are no uppercase letters in prompt,
							-- convert paths to lowercase for matching purposes
							local convert_path = function(str)
								return str
							end
							if vim.o.ignorecase and string.find(prompt, "%u") == nil then
								convert_path = function(str)
									return string.lower(str)
								end
							end

							local current_file_cased = convert_path(current_file)
							local paths_length = #visit_paths

							-- Flip visit_paths so that paths are lookup keys for the index values
							local flipped_visits = {}
							for index, path in ipairs(visit_paths) do
								local key = vim.fn.fnamemodify(path, ":.")
								flipped_visits[convert_path(key)] = index - 1
							end

							local result = {}
							for _, index in ipairs(indices) do
								local path = stritems[index]
								local match_score = prompt == "" and 0
									or MiniFuzzy.match(prompt, path).score
								if match_score >= 0 then
									local visit_score = flipped_visits[path] or paths_length
									table.insert(result, {
										index = index,
										-- Give current file high value so it's ranked last
										score = path == current_file_cased and 999999
											or match_score + visit_score * 10,
									})
								end
							end

							table.sort(result, function(a, b)
								return a.score < b.score
							end)

							return vim.tbl_map(function(val)
								return val.index
							end, result)
						end,
					},
					window = { config = cursor_win_config },
				})
			end
		end,
	},
}
