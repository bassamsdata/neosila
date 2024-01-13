-- whitespace and indentation guides.
return {
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		enabled = function()
			return not vim.b.large_file
		end,
		-- event = { "BufReadPost", "BufNewFile" },
		-- for setting shiftwidth and tabstop automatically.
		-- dependencies = "tpope/vim-sleuth",
		config = function()
			vim.schedule(
				function() -- delay ibl so it doesn't affect nvim "filename" startup
					require("ibl").setup({
						indent = {
							char = "│",
							tab_char = "│",
						},
						scope = {
							-- enabled = false, -- I could use mini indentation module
							show_start = false,
							show_end = false,
							highlight = "CursorLineNr",
							include = { -- this is to highlight some additional node_type :h ibl.scope
								-- if something wierd happens I could use:
								-- lua = { "return_statement", "table_constructor" }
								node_type = { lua = { "*" } },
							},
						},
						exclude = {
							filetypes = {
								"help",
								"starter",
								"lazy",
								"mason",
								"notify",
								"quarto",
							},
						},
					})
				end
			) -- in milliseconds - usually nvim starts up time is 54,so this is after
		end,
	},
}
