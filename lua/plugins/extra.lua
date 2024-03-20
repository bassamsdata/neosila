return {
	{
		"2kabhishek/nerdy.nvim",
		dependencies = { "echasnovski/mini.pick" },
		cmd = "Nerdy",
	},

	{
		"bassamsdata/arrow.nvim",
		dev = true,
		-- event = "BufReadPost",
		cmd = "Arrow open",
		keys = {
			{ ";" },
			{ "<tab>" },
		},
		config = function()
			vim.g.arrow_enabled = true
			require("arrow").setup({
				show_icons = true,
				leader_key = "<tab>",
			})
		end,
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
		event = "BufReadPost",
		opts = {},
	},

	{ -- TODO: try to replicate it but simply
		"kawre/neotab.nvim",
		event = "InsertEnter",
		opts = {},
	},

	{ "lunarvim/bigfile.nvim", event = "VeryLazy", opts = {} },

	{ "laytan/cloak.nvim", cmd = "CloakToggle", ft = "sh", opts = {} },
}
