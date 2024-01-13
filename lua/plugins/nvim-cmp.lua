-- Initialize global variable for cmp-nvim toggle
vim.g.cmp_enabled = true
return {
	{
		"hrsh7th/cmp-buffer", -- source for text in buffer
		event = { "CmdlineEnter", "InsertEnter" },
		dependencies = "hrsh7th/nvim-cmp",
	},
	{
		"hrsh7th/cmp-nvim-lsp",
		event = "InsertEnter",
	},
	{
		"hrsh7th/cmp-cmdline",
		event = "CmdlineEnter",
		dependencies = "hrsh7th/nvim-cmp",
	},
	{
		"hrsh7th/nvim-cmp",
		event = { "LspAttach", "InsertCharPre" },
		dependencies = {
			"hrsh7th/cmp-path", -- source for file system paths
			"L3MON4D3/LuaSnip", -- snippet engine
			"saadparwaiz1/cmp_luasnip", -- for autocompletion
			"rafamadriz/friendly-snippets", -- useful snippets
			"onsails/lspkind.nvim", -- vs-code like pictograms
			{
				"Exafunction/codeium.nvim",
				cmd = "Codeium",
				build = ":Codeium Auth",
				opts = {},
			},
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local lspkind = require("lspkind")
			-- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
			require("luasnip.loaders.from_vscode").lazy_load()
			cmp.setup({
				-- Other configurations...
				enabled = function()
					return vim.g.cmp_enabled
				end,
				completion = {
					completeopt = "menu,menuone,preview,noselect",
				},
				snippet = { -- configure how nvim-cmp interacts with snippet engine
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
					["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-,>"] = cmp.mapping.complete(), -- show completion suggestions
					["<C-e>"] = cmp.mapping.abort(), -- close completion window
					["<§>"] = cmp.mapping.close(),
					-- ["<Down>"] = function(fb)
					-- 	cmp.close()()
					-- end,
					["<CR>"] = cmp.mapping.confirm({ select = false }),
					-- TODO: if statement to accept codeium suggestions.
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
						elseif luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s", "c" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
						elseif luasnip.expand_or_locally_jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s", "c" }),
				}),
				-- sources for autocompletion
				sources = cmp.config.sources({
					{ name = "codeium", group_index = 1, priority = 100 },
					{ name = "cmp_tabnine" },
					{ name = "otter" },
					{ name = "nvim_lsp" },
					{ name = "luasnip" }, -- snippets
					{ name = "buffer" }, -- text within current buffer
					{ name = "path" }, -- file system paths
				}),
				-- configure lspkind for vs-code like pictograms in completion menu
				formatting = {
					format = lspkind.cmp_format({
						-- mode = "symbol",
						maxwidth = 50,
						ellipsis_char = "...",
						symbol_map = {
							Codeium = "",
							otter = "🦦",
							TabNine = "",
						},
					}),
				},
				window = {
					-- completion = cmp.config.window.bordered(),
					---@diagnostic disable-next-line: missing-fields
					completion = {
						border = "rounded",
						winhighlight = "",
						-- winhighlight = 'CursorLine:Normal',
						scrollbar = "║",
					},
					---@diagnostic disable-next-line: missing-fields
					documentation = {
						border = "rounded",
						winhighlight = "", -- or winhighlight
						max_height = math.floor(vim.o.lines * 0.5),
						max_width = math.floor(vim.o.columns * 0.4),
					},
				},
				experimental = {
					ghost_text = { hl_group = "LspCodeLens" },
				},
			})
			cmp.setup.cmdline({ "/", "?" }, {
				view = {
					entries = { name = "wildmenu", separator = "|" },
				},
				sources = {
					{ name = "buffer" },
				},
			})
			-- TODO: implement exceptions: https://github.com/hrsh7th/nvim-cmp/wiki/Advanced-techniques#disabling-cmdline-completion-for-certain-commands-such-as-increname
			cmp.setup.cmdline(":", {
				view = {
					entries = { name = "wildmenu", separator = "|" },
				},
				sources = {
					{ name = "path" },
					{ name = "cmdline" },
				},
			})
		end,
	},
}
