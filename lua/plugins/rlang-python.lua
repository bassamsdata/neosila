return {
	{
		"R-nvim/R.nvim",
		ft = { "r", "rmd", "quarto" },
		config = function()
			local opts = {
				csv_app = function(tsv_file)
					vim.schedule(function()
						vim.ui.input(
							{ prompt = "Enter the application name: " },
							function(input)
								if input == "" then
									input = "tv"
								end
								vim.cmd("tabnew | terminal " .. input .. " " .. tsv_file)
								vim.cmd( -- set local: nonumber norelativenumber nosign-column ocursorcolumn
									[[silent! setl nonu nornu nobl nolist nocul ]]
								) -- buffer-history, backtrace
								vim.cmd("startinsert")
							end
						)
					end)
				end,
				R_args = { "--quiet", "--no-save" },
				hook = {
					after_ob_open = function()
						vim.cmd("redraw")
					end,
					after_config = function()
            -- This function will be called at the FileType event
            -- of files supported by R.nvim. This is an
            -- opportunity to create mappings local to buffers.
            -- stylua: ignore start
            if vim.o.syntax ~= "rbrowser" then
              vim.api.nvim_buf_set_keymap( 0, "n", "<Enter>", "<Plug>RDSendLine", {})
              vim.api.nvim_buf_set_keymap( 0, "v", "<Enter>", "<Plug>RSendSelection", {})
            end
						-- stylua: ignore end
					end,
				},
				min_editor_width = 72,
				rconsole_width = 78,
				disable_cmds = {
					"RClearConsole",
					"RCustomStart",
					"RSPlot",
					"RSaveClose",
				},
			}
			-- Check if the environment variable "R_AUTO_START" exists.
			-- If using fish shell, you could put in your config.fish:
			-- alias r "R_AUTO_START=true nvim"
			if vim.env.R_AUTO_START == "true" then
				opts.auto_start = 1
				opts.objbr_auto_start = true
			end
			require("r").setup(opts)
		end,
	},
	{
		"R-nvim/cmp-r",
		ft = { "r", "rmd", "quarto" },
		config = function()
			require("cmp_r").setup({})
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
	{ -- TODO: check why this doesn't work
		"lukas-reineke/headlines.nvim",
		lazy = true,
		-- ft = { "markdown", "norg", "org", "qml", "quarto" },
		dependencies = "nvim-treesitter/nvim-treesitter",
		config = function()
			local opts = {
				headline_highlights = {},
				codeblock_highlight = "CodeBlock",
				fat_headlines = false,
			}
			local quarto_opts = {
				query = vim.treesitter.query.parse(
					"markdown",
					[[ (fenced_code_block) @codeblock ]]
				),
				codeblock_highlight = "CodeBlock",
				treesitter_language = "markdown",
			}

			require("headlines").setup({
				markdown = opts,
				norg = opts,
				org = opts,
				rmd = opts,
				quarto = quarto_opts,
			})

			local function set_default_hlgroups()
				local set_hl = require("utils.hi").apply_highlight
        -- stylua: ignore start 
        set_hl("CodeBlock",                     { bg = "New" })
        set_hl( "markdownCode",                 { bg = "New", fg = "markdownCode" })
        set_hl("@text.literal.markdown_inline", { bg = "New", fg = "@text.literal.markdown_inline", })
				-- stylua: ignore end
			end
			set_default_hlgroups()

			vim.api.nvim_create_autocmd("ColorScheme", {
				group = vim.api.nvim_create_augroup("HeadlinesSetDefaultHlGroups", {}),
				desc = "Set default highlight groups for headlines.nvim.",
				callback = set_default_hlgroups,
			})
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
