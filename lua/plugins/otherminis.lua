return {
	-- TODO: change the highlight color of the view map 'MiniMapSymbolView'
	-- and add mini map to the help pages as well :)
	-- {
	-- 	"echasnovski/mini.notify",
	-- 	event = "VeryLazy",
	-- 	config = function()
	-- 		local mini_notify = require("mini.notify")
	-- 		vim.notify = mini_notify.make_notify()
	-- 		-- print = mini_notify.make_notify()
	-- 		vim.api.nvim_echo = mini_notify.make_notify()
	-- 		-- TODO: make it work,the actual message content in different color and italic and add the level name like `ERROR`
	-- 		-- ref; https://github.com/j-hui/fidget.nvim/blob/main/lua/fidget/notification/window.lua#L410
	-- 		local cus_format = function(notif)
	-- 			local time = vim.fn.strftime("%H:%M:%S", math.floor(notif.ts_update))
	-- 			local icon = "\nNotification ❰❰" -- TODO: the problem with this that I need to make it complex to justify the icon ❰❰ to the right
	-- 			return string.format("%s │ %s %s", time, notif.msg, icon)
	-- 		end
	-- 		local row = function()
	-- 			local has_statusline = vim.o.laststatus > 0
	-- 			local bottom_space = vim.o.cmdheight + (has_statusline and 1 or 0)
	-- 			return vim.o.lines - bottom_space
	-- 		end
	-- 		mini_notify.setup({
	-- 			content = {
	-- 				format = nil,
	-- 			},
	-- 			lsp_progress = {
	-- 				duration_last = 500,
	-- 			},
	-- 			window = {
	-- 				config = {
	-- 					-- all of that to do `Notification ❰❰` on the right side
	-- 					border = "solid",
	-- 					-- { -- different style
	-- 					-- 	"",
	-- 					-- 	"─",
	-- 					-- 	"┐",
	-- 					-- 	"│",
	-- 					-- 	"",
	-- 					-- 	"",
	-- 					-- 	"",
	-- 					-- 	"",
	-- 					-- },
	-- 					anchor = "SE",
	-- 					row = row(),
	-- 					title = "Notification ❰❰",
	-- 					title_pos = "right",
	-- 				},
	-- 				winblend = 25,
	-- 			},
	-- 		})
	-- 	end,
	-- },
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
	{ "echasnovski/mini.sessions", event = "VeryLazy", opts = {} },
	{
		"echasnovski/mini.align",
		keys = {
			{ "ga", mode = { "v", "n" } },
			{ "gA", mode = { "v", "n" } },
		},
		opts = {},
	},
	{
		"echasnovski/mini.map",
		event = "FileType lua,norg,quarto",
		config = function()
			local map = require("mini.map")
			local gen_integr = map.gen_integration
			if map then
				map.setup({
					integrations = {
						gen_integr.builtin_search(),
						gen_integr.diagnostic(),
						gen_integr.gitsigns(),
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
		"echasnovski/mini.hipatterns",
		event = "BufReadPost",
		config = function()
			local mini_hipatterns = require("mini.hipatterns")

			if mini_hipatterns then
				mini_hipatterns.setup({
					highlighters = {
						hex_color = mini_hipatterns.gen_highlighter.hex_color(),
						todo = {
							-- TODO: test
							pattern = "TODO",
							group = "SkyBlue_bg",
							extmark_opts = { sign_text = "󰸞", sign_hl_group = "SkyBlue" },
						},
						todo_trail = {
							pattern = "TODO: ()%S+.*()",
							group = "SkyBlue",
						},
						-- LOVE: do some love
						love = {
							pattern = "LOVE",
							group = "Ochre_bg",
							extmark_opts = { sign_text = "󰩖", sign_hl_group = "Ochre" },
						},
						-- highlight the text after LOVE with different highlightv
						love_trail = {
							pattern = "LOVE: ()%S+.*()",
							group = "Ochre",
						},
					},
				})
			end
		end,
	},
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
