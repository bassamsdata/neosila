return {
	{ "jamespeapen/Nvim-R", branch = "master", ft = { "r", "rmd", "quarto" } },
	{
		"jalvesaq/cmp-nvim-r",
		ft = { "r", "rmd", "quarto" },
		config = function()
			require("cmp_nvim_r").setup({})
		end,
	},
	{
		"GCBallesteros/jupytext.nvim",
		lazy = true,
		opts = {
			style = "markdown",
			output_extension = "md",
			force_ft = "markdown",
		},
	},
	{
		"quarto-dev/quarto-nvim",
		dependencies = {
			{ "jmbuhr/otter.nvim" }, -- , dev = true },
			"hrsh7th/nvim-cmp",
			"neovim/nvim-lspconfig",
			"nvim-treesitter/nvim-treesitter",
		},
		ft = { "quarto", "markdown", "norg" },
		config = function()
			local quarto = require("quarto")
			quarto.setup({
				lspFeatures = {
					languages = { "r", "python" },
					chunks = "all", -- 'curly' or 'all'
					diagnostics = {
						enabled = true,
						triggers = { "BufWritePost" },
					},
					completion = {
						enabled = true,
					},
				},
				keymap = {
					hover = "H",
					definition = "gd",
					rename = "<leader>rn",
					references = "gr",
					format = "<leader>gf",
				},
				codeRunner = {
					enabled = true,
					ft_runners = {
						bash = "slime",
					},
					default_method = "molten",
				},
			})

			vim.keymap.set(
				"n",
				"<localleader>qp",
				quarto.quartoPreview,
				{ desc = "Preview the Quarto document", silent = true, noremap = true }
			)
			-- to create a cell in insert mode, I have the ` snippet
			vim.keymap.set(
				"n",
				"<localleader>cc",
				"i`<c-j>",
				{ desc = "Create a new code cell", silent = true }
			)
			vim.keymap.set(
				"n",
				"<localleader>cs",
				"i```\r\r```{}<left>",
				{ desc = "Split code cell", silent = true, noremap = true }
			)
		end,
	},
	-- {
	-- 	"jmbuhr/otter.nvim",
	-- 	ft = { "markdown", "quarto" },
	-- 	dependencies = {
	-- 		"hrsh7th/nvim-cmp",
	-- 		"neovim/nvim-lspconfig",
	-- 		"nvim-treesitter/nvim-treesitter",
	-- 	},
	-- 	config = function() end,
	-- },
}
