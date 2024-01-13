return {
	{
		"mg979/vim-visual-multi",
		branch = "master",
		-- TODO: change the default keys and description for clues
		keys = {
			{ "<C-Down>" },
			{ "<C-n>" },
			{ "<C-Up>" },
		},
		opts = {},
		config = function()
			if pcall(require, "vim-visual-multi") then
				require("mini.clue").set_mapping_desc("VMmaps", "\\\\A", "Select All")
				-- require("mini.clue").set_mapping_desc("V-M", "\\\\A", "Select All")
				require("mini.clue").set_mapping_desc(
					"VM_maps",
					"\\\\",
					"Add Cursor At Pos"
				)
			end
		end,
	},
	{
		"epwalsh/pomo.nvim",
		dev = true,
		version = "*", -- Recommended, use latest release instead of latest commit
		lazy = true,
		cmd = { "TimerStart", "TimerRepeat" },
		opts = {
			notifiers = {
				-- The "Default" timer uses 'nvim-notify' to continuously display the timer
				{
					name = "Default",
					opts = {
						sticky = false, -- set to false if you don't want to see the timer the whole time
						title_icon = "󱎫",
						text_icon = "󰄉",
					},
				},
				{ name = "System" },
			},
		},
	},
	{ "LudoPinelli/comment-box.nvim", cmd = "CBllline", opts = {} },
	{ -- TODO: Delete this one - is it really useful?
		"kawre/neotab.nvim",
		event = "InsertEnter",
		opts = {
			-- configuration goes here
		},
	},
	{
		"dstein64/vim-startuptime",
		cmd = "StartupTime",
		config = function()
			vim.g.startuptime_tries = 10
		end,
	},
	-- {
	-- 	"m4xshen/hardtime.nvim",
	-- 	event = "VeryLazy",
	-- 	dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
	-- 	opts = {},
	-- },
	{
		"Bekaboo/deadcolumn.nvim",
		event = { "InsertEnter" },
		config = function()
			vim.opt.colorcolumn = "80"
		end,
	},
	{ "b0o/incline.nvim", event = "BufReadPost", opts = {} },
	{
		"folke/zen-mode.nvim",
		keys = { { "<leader>z", "<cmd>ZenMode<cr>", desc = "ZenMode" } },
		opts = {
			plugins = {
				gitsigns = { enabled = false },
				wezterm = {
					enabled = false,
					-- can be either an absolute font size or the number of incremental steps
					font = "+4", -- (10% increase per step)
				},
			},
		},
	},
}
