return {
	{
		"2kabhishek/nerdy.nvim",
		dependencies = { "echasnovski/mini.pick" },
		cmd = "Nerdy",
	},

	{
		"otavioschwanck/arrow.nvim",
		-- dev = true,
		-- event = "BufReadPost",
		cmd = "Arrow open",
		keys = {
			-- { ";" },
			{ "<tab>" },
		},
		config = function()
			vim.g.arrow_enabled = true
			require("arrow").setup({
				show_icons = true,
				leader_key = "<tab>",
				separate_save_and_remove = true, -- if true, will remove the toggle and create the save/remove keymaps.
				always_show_path = true,
				window = {
					border = "rounded",
				},
			})
		end,
	},

	{
		"NStefan002/15puzzle.nvim",
		cmd = "Play15puzzle",
		config = true,
	},

	{
		"dstein64/vim-startuptime",
		cmd = "StartupTime",
		config = function()
			vim.g.startuptime_tries = 10
		end,
	},

	{
		"brenoprata10/nvim-highlight-colors",
		cond = not vim.g.vscode or not vim.b.bigfile,
		event = "BufReadPost",
		opts = {},
	},

	{
		"b0o/incline.nvim",
		cond = not vim.g.vscode or not vim.b.bigfile,
		event = "BufReadPost",
		opts = {
			hide = {
				cursorline = "focused_win",
				focused_win = false,
				only_win = true,
			},
		},
	},

	{
		"bfredl/nvim-miniyank",
    -- stylua: ignore start 
		keys = {
      { "p", "<plug>(miniyank-autoput)", mode = "", desc = "autoput with miniyank", },
			{ "P", "<plug>(miniyank-autoPut)", mode = "", desc = "autoput with miniyank", },
		},
		-- stylua: ignore end
		event = { "TextYankPost" },
	},

	{
		"kawre/neotab.nvim",
		cond = not vim.g.vscode or not vim.b.bigfile,
		event = "InsertEnter",
		opts = {},
	},

	{ "lunarvim/bigfile.nvim", event = "VeryLazy", opts = {} },

	{ "laytan/cloak.nvim", cmd = "CloakToggle", ft = "sh", opts = {} },
}
