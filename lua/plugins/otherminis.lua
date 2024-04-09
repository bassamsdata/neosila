return {
	-- TODO: change the highlight color of the view map 'MiniMapSymbolView'
	{
		"echasnovski/mini.map",
		cond = function()
			return not vim.b.large_file
		end,
		event = "FileType lua,norg,quarto,py,go,markdown,R",
		config = function()
			local map = require("mini.map")
			local gen_integr = map.gen_integration
			if map then
				map.setup({
					integrations = {
						gen_integr.builtin_search(),
						gen_integr.diagnostic(),
						-- TODO: add minidiff integrations
						-- gen_integr.gitsigns(),
					},
					window = {
						show_integration_count = false,
						width = 2,
						winblend = 0,
						zindex = 75,
					},
				})
				for _, key in ipairs({ "n", "N", "*" }) do
					vim.keymap.set(
						"n",
						key,
						key
							.. "zv<Cmd>lua MiniMap.refresh({}, { lines = false, scrollbar = false })<CR>"
					)
				end

				vim.api.nvim_set_hl(0, "MiniMapSymbolCount", { fg = "#f38ba9" })
				map.open()
				vim.api.nvim_create_autocmd("VimResized", {
					callback = function()
						map.refresh()
					end,
				})
			end
		end,
	},

	{
		"echasnovski/mini.notify",
		event = "VeryLazy",
		config = function()
			local mini_notify = require("mini.notify")
			vim.notify = mini_notify.make_notify()
			-- FIX: convert the output to strings so it can appear in notify
			-- print = mini_notify.make_notify()
			-- vim.api.nvim_echo = mini_notify.make_notify()
			local cus_format = function(notif)
				local time = vim.fn.strftime("%H:%M:%S", math.floor(notif.ts_update))
				local icon = "\nNotification ❰❰"
				return string.format("%s │ %s %s", time, notif.msg, icon)
			end
			local row = function()
				local has_statusline = vim.o.laststatus > 0
				local bottom_space = vim.o.cmdheight + (has_statusline and 1 or 0)
				return vim.o.lines - bottom_space
			end
			mini_notify.setup({
				window = {
					config = function()
						return {
							col = vim.o.columns - 2,
							row = row(),
							anchor = "SE",
							title = "Notification ❰❰",
							title_pos = "right",
							---TODO: make max width 60%
							-- width = math.floor(0.6 * vim.o.columns),
							border = "solid",
						}
					end,
					max_width_share = 0.6,
				},
			})
		end,
	},

	{
		"echasnovski/mini.misc",
		opts = {},
		keys = {
			{ "<leader>mm", "<cmd>lua MiniMisc.zoom()<cr>", desc = "Zoom" },
			{
				"<leader>ur",
				"<cmd>lua MiniMisc.setup_auto_root()<cr>",
				desc = "[U]I [Root]",
			},
		},
	},

	{ "echasnovski/mini.sessions", lazy = true, opts = {} },

	{
		"echasnovski/mini.align",
		keys = {
			{ "ga", mode = { "v", "n" } },
			{ "gA", mode = { "v", "n" } },
		},
		opts = {},
	},
	{
		"folke/todo-comments.nvim",
		event = "BufRead",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			keywords = {
        -- stylua: ignore start 
				FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, },
				TODO = { icon = " ", color = "info" },
				HACK = { icon = " ", color = "warning" },
				WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
				PERF = { icon = "󰓅 ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
				NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
				TEST = { icon = "󰙨", color = "test", alt = { "TESTING", "PASSED", "FAILED" }, },
        DEL = { icon = " ", color = "error", alt = { "DELETE" } },
        SUG = { icon = "󰭙 ", color = "info", alt = { "SUGGEST" } },
				-- stylua: ignore end
			},
			colors = {
				error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
				warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
				info = { "DiagnosticInfo", "#2563EB" },
				hint = { "DiagnosticHint", "#10B981" },
				default = { "Identifier", "#7C3AED" },
				test = { "Identifier", "#FF00FF" },
			},
		},
	},
	-- {
	-- 	--- apply one highlight for bg and another for fg
	-- 	"echasnovski/mini.hipatterns",
	-- 	cond = function()
	-- 		return not vim.b.large_file
	-- 	end,
	-- 	event = "BufReadPost",
	-- 	config = function()
	-- 		local mini_hipatterns = require("mini.hipatterns")
	--
	-- 		if mini_hipatterns then
	-- 			local keywords = { "NOTE", "BUG", "LOVE", "TODO", "FIX" }
	-- 			local icons = { "󰎞 ", "󰃤 ", "󰩖 ", "󰸞 ", "󰁨 " }
	-- 			local highlighters = {
	-- 				hex_color = mini_hipatterns.gen_highlighter.hex_color(),
	-- 				hsl_color = { -- thanks to https://github.com/craftzdog/dotfiles-public/blob/master/.config/nvim/lua/plugins/editor.lua
	-- 					pattern = "hsl%(%d+,? %d+%%?,? %d+%%?%)",
	-- 					group = function(_, match)
	-- 						local utils = require("utils.hi")
	-- 						--- @type string, string, string
	-- 						local nh, ns, nl =
	-- 							match:match("hsl%((%d+),? (%d+)%%?,? (%d+)%%?%)")
	-- 						--- @type number?, number?, number?
	-- 						local h, s, l = tonumber(nh), tonumber(ns), tonumber(nl)
	-- 						--- @type string
	-- 						local hex_color = utils.hslToHex(h, s, l)
	-- 						return mini_hipatterns.compute_hex_color_group(hex_color, "bg")
	-- 					end,
	-- 				},
	-- 			}
	-- 			for _, keyword in ipairs(keywords) do
	-- 				-- this is how we get attributes `fg = vim.api.nvim_get_hl(0, { name = 'NonText' }).fg,`
	-- 				local lowerKeyword = string.lower(keyword)
	-- 				-- local highlightGroup = string.format("HiPatterns%s", keyword)
	-- 				-- local fg = vim.api.nvim_get_hl(0, { name = highlightGroup }).fg
	-- 				highlighters[lowerKeyword] = {
	-- 					pattern = string.format("%s:", keyword),
	-- 					group = "IncSearch",
	-- 					extmark_opts = {
	-- 						sign_text = icons[_],
	-- 						sign_hl_group = "IncSearch",
	-- 					},
	-- 				}
	-- 				highlighters[string.format("%s_trail", lowerKeyword)] = {
	-- 					pattern = string.format("%s: ()%%S+.*()", keyword),
	-- 					group = "IncSearch",
	-- 				}
	-- 			end
	--
	-- 			mini_hipatterns.setup({ highlighters = highlighters })
	-- 		end
	-- 	end,
	-- },

	{
		"echasnovski/mini.bufremove",
		keys = {
			{
				"<localleader>x",
				function() -- credit to LazyVim for this implementation
					local bd = require("mini.bufremove").delete
					if vim.bo.modified then
						local choice = vim.fn.confirm(
							("Save changes to %q?"):format(vim.fn.bufname()),
							"&Yes\n&No\n&Cancel"
						)
						if choice == 1 then -- Yes
							vim.cmd.write()
							bd(0)
						elseif choice == 2 then -- No
							bd(0, true)
						end
					else
						bd(0)
					end
				end,
				desc = "Delete Buffer",
			},
			{
				"<localleader>X",
				function()
					require("mini.bufremove").delete(0, true)
				end,
				desc = "Delete Buffer (Force)",
			},
		},
	},
}
