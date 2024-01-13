return {
	-- TODO: fix this
	"stevearc/dressing.nvim",
	lazy = true,
	init = function()
		---@diagnostic disable-next-line: duplicate-set-field
		vim.ui.select = function(...)
			require("lazy").load({ plugins = { "dressing.nvim" } })
			return vim.ui.select(...)
		end
		---@diagnostic disable-next-line: duplicate-set-field
		vim.ui.input = function(...)
			require("lazy").load({ plugins = { "dressing.nvim" } })
			return vim.ui.input(...)
		end
	end,
	opts = { select = { backend = { "builtin" } } },
	-- event = "VeryLazy",
	-- opts = {},
	--   config = function()
	--   require "dressing".setup {
	--     input = {
	--       -- enabled = false
	--       border = "rounded",
	--       relative = "editor",
	--       -- title_pos = "center",
	--     },
	--     select = {
	--       -- enabled = false
	--       backend = { "builtin" },
	--       builtin = {
	--         border = "rounded",
	--         relative = "editor",
	--       }
	--     }
	--   }
	-- end
}
