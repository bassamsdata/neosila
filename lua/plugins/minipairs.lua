return {
	{ -- TRY: try this one
		"altermo/ultimate-autopair.nvim",
		event = { "InsertEnter", "CmdlineEnter" },
		opts = {
			tabout = { -- *ultimate-autopair-map-tabout-config*
				enable = false,
				map = "<A-tab>", --string or table
				cmap = "<A-tab>", --string or table
				conf = {},
				--contains extension config
				multi = false,
				--use multiple configs (|ultimate-autopair-map-multi-config|)
				hopout = false,
				-- (|) > tabout > ()|
				do_nothing_if_fail = true,
				--add a module so that if close fails
				--then a `\t` will not be inserted
			},
		},
	},
	-- {
	-- 	"echasnovski/mini.pairs",
	-- 	event = "InsertEnter",
	-- 	opts = {},
	-- 	keys = {
	-- 		{
	-- 			"<leader>ta",
	-- 			function()
	-- 				local util = require("utils")
	-- 				vim.g.minipairs_disable = not vim.g.minipairs_disable
	-- 				if vim.g.minipairs_disable then
	-- 					util.custom_notify("Disabled auto pairs", "INFO")
	-- 				else
	-- 					util.custom_notify("Enabled auto pairs", "INFO")
	-- 				end
	-- 			end,
	-- 			desc = "Toggle auto pairs",
	-- 		},
	-- 	},
	-- },
	{
		"echasnovski/mini.surround",
		keys = { "gsa", { "gs", mode = "v" } },
		config = function()
			local MiniSurround = require("mini.surround")
			MiniSurround.setup({
				mappings = {
					add = "gsa", -- Add surrounding in Normal and Visual modes
					delete = "gsd", -- Delete surrounding
					find = "gsf", -- Find surrounding (to the right)
					find_left = "gsF", -- Find surrounding (to the left)
					highlight = "gsh", -- Highlight surrounding
					replace = "gsr", -- Replace surrounding
					update_n_lines = "gsn", -- Update `n_lines`
				},
			})
			-- I don't why but clue picked up long desc, so this is just for aesthtics
			if pcall(require, "mini.surround") then
				require("mini.clue").set_mapping_desc("n", "gsn", "Update n# lines")
			end
		end,
	},
}
