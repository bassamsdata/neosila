return {
	{
		"jiaoshijie/undotree",
		dependencies = "nvim-lua/plenary.nvim",
		config = true,
		keys = {
			{ "<leader>ut", "<cmd>lua require('undotree').toggle()<cr>" },
		},
	},
}
