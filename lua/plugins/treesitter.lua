return {
	{
		"nvim-treesitter/nvim-treesitter",
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
			-- "VeryLazy",
			-- "FileType", --testing this new one
			"BufReadPre",
			"BufNewFile",
		},
		keys = {
			{ "<C-cr>", desc = "Increment selection" },
			{ "<bs>", desc = "Decrement selection", mode = "x" },
		},

		dependencies = {
			{ "nvim-treesitter/nvim-treesitter-textobjects" },
			{ "nvim-treesitter/nvim-treesitter-context" },
		},
		config = function()
			local function dd(bufnr) -- Disable in files with more than 5K
				return vim.api.nvim_buf_line_count(bufnr) > 5000
			end
			vim.schedule(function()
				require("nvim-treesitter.configs").setup({
					highlight = { enable = not vim.g.vscode },
					indent = { enable = true },
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
					},
					additional_vim_regex_highlighting = false,
					incremental_selection = {
						enable = true,
						keymaps = {
							init_selection = "<C-cr>",
							node_incremental = "<C-cr>",
							scope_incremental = "<localleader>s",
							node_decremental = "<bs>",
						},
					},
					textobjects = {
						select = {
							enable = true,
							-- Automatically jump forward to textobj, similar to targets.vim
							lookahead = true,

							keymaps = {
								-- You can use the capture groups defined in textobjects.scm
								["af"] = "@function.outer",
								["if"] = "@function.inner",
								["al"] = "@loop.outer",
								["il"] = "@loop.inner",
								["ac"] = "@conditional.outer",
								-- You can optionally set descriptions to the mappings (used in the desc parameter of
								-- nvim_buf_set_keymap) which plugins like which-key display
								["ic"] = {
									query = "@conditional.inner",
									desc = "Select inner part of a class region",
								},
								-- You can also use captures from other query groups like `locals.scm`
								["as"] = {
									query = "@scope",
									query_group = "locals",
									desc = "Select language scope",
								},
							},
							-- You can choose the select mode (default is charwise 'v')
							--
							-- Can also be a function which gets passed a table with the keys
							-- * query_string: eg '@function.inner'
							-- * method: eg 'v' or 'o'
							-- and should return the mode ('v', 'V', or '<c-v>') or a table
							-- mapping query_strings to modes.
							selection_modes = {
								["@parameter.outer"] = "v", -- charwise
								["@function.outer"] = "V", -- linewise
								["@class.outer"] = "<c-v>", -- blockwise
							},
							-- If you set this to `true` (default is `false`) then any textobject is
							-- extended to include preceding or succeeding whitespace. Succeeding
							-- whitespace has priority in order to act similarly to eg the built-in
							-- `ap`.
							--
							-- Can also be a function which gets passed a table with the keys
							-- * query_string: eg '@function.inner'
							-- * selection_mode: eg 'v'
							-- and should return true of false
							include_surrounding_whitespace = true,
						},
					},
					move = {
						enable = true,
						goto_next_start = {
							["]f"] = "@function.outer",
							["]c"] = "@class.outer",
						},
						goto_next_end = {
							["]F"] = "@function.outer",
							["]C"] = "@class.outer",
						},
						goto_previous_start = {
							["[f"] = "@function.outer",
							["[c"] = "@class.outer",
						},
						goto_previous_end = {
							["[F"] = "@function.outer",
							["[C"] = "@class.outer",
						},
					},
				})
			end, 0)
		end,
	},
	{ "nvim-treesitter/nvim-treesitter-textobjects", lazy = true },
	{
		"nvim-treesitter/nvim-treesitter-context",
		-- Match the context lines to the source code.
		-- multiline_threshold = 1,
		lazy = true,
		enabled = true,
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
