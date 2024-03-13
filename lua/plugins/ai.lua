return {
	{
		"Exafunction/codeium.nvim",
		cond = not vim.g.vscode,
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		cmd = "Codeium",
		build = ":Codeium Auth",
		opts = {},
	},
	{
		"tzachar/cmp-tabnine",
		event = "InsertEnter",
		build = "./install.sh",
		dependencies = "hrsh7th/nvim-cmp",
		opts = {
			show_prediction_strength = false,
		},
		opts = { enable_cody = true },
	},

	{
		"Exafunction/codeium.vim",
		event = { "BufReadPost", "InsertEnter" },
		config = function()
			vim.g.codeium_enabled = true
      -- stylua: ignore start 
			vim.keymap.set("i", "<C-y>", function() return vim.fn["codeium#Accept"]() end, { expr = true, silent = true })
			-- vim.keymap.set('i', '<c-;>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true, silent = true })
			-- vim.keymap.set('i', '<c-,>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true, silent = true })
			-- NOTE: here duble 2 C-e will hide cmp and show the suggestions
			vim.keymap.set("i", "<C-e>", function() return vim.fn["codeium#Complete"]() end, { expr = true, silent = true })
			-- stylua: ignore end
			vim.g.codeium_filetypes = {
				text = false, -- for password files like `pass`
			}
		end,
	},
	-- {
	-- 	"codota/tabnine-nvim",
	-- 	cmd = "TabnineEnable",
	-- 	-- event = "InsertEnter",
	-- 	build = "./dl_binaries.sh",
	-- 	config = function()
	-- 		require("tabnine").setup({
	-- 			disable_auto_comment = true,
	-- 			accept_keymap = "<Tab>",
	-- 			dismiss_keymap = "<C-]>",
	-- 			debounce_ms = 800,
	-- 			suggestion_color = { gui = "#808080", cterm = 244 },
	-- 			exclude_filetypes = { "TelescopePrompt", "NvimTree" },
	-- 			log_file_path = nil, -- absolute path to Tabnine log file
	-- 		})
	-- 	end,
	-- },
}
