local toggle_modes = { "n", "t" }
return {
	{
		"NvChad/nvterm",
		keys = {
			{
				"<M-t>",
				function()
					require("nvterm.terminal").toggle("horizontal")
				end,
				mode = toggle_modes,
			},
			{
				"<M-v>",
				function()
					require("nvterm.terminal").toggle("vertical")
				end,
				mode = toggle_modes,
			},
			{
				"<M-f>",
				function()
					require("nvterm.terminal").toggle("float")
				end,
				mode = toggle_modes,
			},
		},
		config = function()
			require("nvterm").setup({
				terminals = {
					type_opts = {
						float = {
							relative = "editor",
							width = 0.8,
							height = 0.6,
							border = "single",
						},
					},
				},
			})
		end,
	},
}
