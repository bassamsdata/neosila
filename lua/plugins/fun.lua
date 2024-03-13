-- for fun plugins,
return {
	{
		"ThePrimeagen/vim-apm",
		enabled = not vim.g.bigfile,
		event = "BufReadPost",
		config = function()
			local apm = require("vim-apm")
			apm:setup({})
			vim.keymap.set("n", "<leader>apm", function()
				apm:toggle_monitor()
			end)
		end,
	},
	-- this plugins make your code rains,slide, scramble etc
	{
		"eandrju/cellular-automaton.nvim",
		cmd = { "CellularAutomaton" },
		keys = {
			{
				"<localleader>fm",
				"<cmd>CellularAutomaton make_it_rain<cr>",
				desc = "Fun make it rain",
			},
			{
				"<localleader>fg",
				"<cmd>CellularAutomaton game_of_life<cr>",
				desc = "Fun game of life",
			},
			{
				"<localleader>fs",
				"<cmd>CellularAutomaton scramble<cr>",
				desc = "Fun scramble",
			},
			{
				"<localleader>fs",
				"<cmd>CellularAutomaton slide<cr>",
				desc = "Fun slide",
			},
		},
		config = function()
			local slide = {
				fps = 60,
				name = "slide",
			}
			slide.update = function(grid)
				for i = 1, #grid do
					local prev = grid[i][#grid[i]]
					for j = 1, #grid[i] do
						grid[i][j], prev = prev, grid[i][j]
					end
				end
				return true
			end
			require("cellular-automaton").register_animation(slide)
		end,
	},
}
