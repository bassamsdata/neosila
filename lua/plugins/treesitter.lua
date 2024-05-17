return {
	{
		"nvim-treesitter/nvim-treesitter",
		-- enabled = function()
		-- 	return not vim.b.bigfile
		-- end,
		version = false, -- last release is way too old
		cmd = {
			"TSInstall",
			"TSBufEnable",
			"TSUpdate",
			"TSBufDisable",
			"TSModuleInfo",
		},
		build = ":TSUpdate",
		event = {
			"BufReadPost",
		},
		keys = {
			{ "<C-cr>", desc = "Increment selection" },
			{ "<bs>", desc = "Decrement selection", mode = "x" },
		},

		dependencies = {
			{
				"nvim-treesitter/nvim-treesitter-textobjects",
			},
			{
				"nvim-treesitter/nvim-treesitter-context",
			},
		},
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"c",
					"bash",
					"json",
					"lua",
					"luadoc",
					"markdown",
					"markdown_inline",
					"python",
					"query",
					"toml",
					"vim",
					"vimdoc",
					"r",
					"query",
					"sql",
					"go",
					"rnoweb",
				},
				sync_install = false,
				ignore_install = {},
				highlight = {
					enable = not vim.g.vscode,
					disable = function(ft, buf)
						return ft == "latex"
							or vim.b[buf].bigfile == true
							or vim.fn.win_gettype() == "command"
					end,
					-- Enable additional vim regex highlighting
					-- in markdown files to get vimtex math conceal
					additional_vim_regex_highlighting = { "markdown" },
				},
				endwise = {
					enable = true,
				},
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = false,
						node_incremental = "an",
						scope_incremental = "aN",
						node_decremental = "in",
					},
				},
				textobjects = {
					select = {
						enable = true,
						lookahead = true, -- Automatically jump forward to textobj
						keymaps = {
							-- You can use the capture groups defined in textobjects.scm
							["am"] = "@function.outer",
							["im"] = "@function.inner",
							["al"] = "@loop.outer",
							["il"] = "@loop.inner",
							["ak"] = "@class.outer",
							["ik"] = "@class.inner",
							-- ["aa"] = "@parameter.outer",
							["ia"] = "@parameter.inner",
							["a/"] = "@comment.outer",
							["a*"] = "@comment.outer",
							["ao"] = "@block.outer",
							["io"] = "@block.inner",
							["a?"] = "@conditional.outer",
							["i?"] = "@conditional.inner",
						},
					},
					move = {
						enable = true,
						set_jumps = true, -- whether to set jumps in the jumplist
						goto_next_start = {
							["]m"] = "@function.outer",
							["]l"] = "@loop.outer",
							["]]"] = "@function.outer",
							["]k"] = "@class.outer",
							["]a"] = "@parameter.outer",
							["]o"] = "@block.outer",
							["]?"] = "@conditional.outer",
						},
						goto_next_end = {
							["]M"] = "@function.outer",
							["]L"] = "@loop.outer",
							["]["] = "@function.outer",
							["]K"] = "@class.outer",
							["]A"] = "@parameter.outer",
							["]/"] = "@comment.outer",
							["]*"] = "@comment.outer",
							["]O"] = "@block.outer",
						},
						goto_previous_start = {
							["[m"] = "@function.outer",
							["[l"] = "@loop.outer",
							["[["] = "@function.outer",
							["[k"] = "@class.outer",
							["[a"] = "@parameter.outer",
							["[/"] = "@comment.outer",
							["[*"] = "@comment.outer",
							["[o"] = "@block.outer",
							["[?"] = "@conditional.outer",
						},
						goto_previous_end = {
							["[M"] = "@function.outer",
							["[L"] = "@loop.outer",
							["[]"] = "@function.outer",
							["[K"] = "@class.outer",
							["[A"] = "@parameter.outer",
							["[O"] = "@block.outer",
						},
					},
					swap = {
						enable = true,
						swap_next = {
							["<M-C-L>"] = "@parameter.inner",
						},
						swap_previous = {
							["<M-C-H>"] = "@parameter.inner",
						},
					},
					lsp_interop = {
						enable = true,
						border = "solid",
						peek_definition_code = {
							["<M-e>"] = "@fuNction.outer",
						},
					},
				},
			})
		end,
	},
	{ "nvim-treesitter/nvim-treesitter-textobjects", lazy = true },
	enabled = function()
		return not vim.b.bigfile
	end,
	{
		"nvim-treesitter/nvim-treesitter-context",
		enabled = function()
			return not vim.b.bigfile
		end,
		-- Match the context lines to the source code.
		-- multiline_threshold = 1,
		lazy = true,
		opts = { mode = "cursor", max_lines = 3, separator = "─" },
		keys = {
			{
				"[c",
				function()
					-- IDK why but it doesn't work without vim.schedule - hint from Maria config
					vim.schedule(function()
						require("treesitter-context").go_to_context()
					end)
				end,
				desc = "Jump to upper context",
				-- expr = true,
			},
		},
	},
}
