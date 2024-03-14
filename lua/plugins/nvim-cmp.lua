local function get_bufnrs() -- this fn from Nv-macro, thanks
	return vim.b.bigfile and {} or { vim.api.nvim_get_current_buf() }
end

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
		event = "LspAttach",
	},
	{
		"hrsh7th/cmp-cmdline",
		event = "CmdlineEnter",
		dependencies = "hrsh7th/nvim-cmp",
	},
	{
		"hrsh7th/nvim-cmp",
		cond = not vim.b.bigfile,
		event = { "LspAttach", "BufReadPost" },
		dependencies = {
			"hrsh7th/cmp-path", -- source for file system paths
			"L3MON4D3/LuaSnip", -- snippet engine
			"saadparwaiz1/cmp_luasnip", -- for autocompletion
			"rafamadriz/friendly-snippets", -- useful snippets
			"onsails/lspkind.nvim", -- vs-code like pictograms
			-- {
			-- 	"Exafunction/codeium.nvim",
			-- 	cmd = "Codeium",
			-- 	build = ":Codeium Auth",
			-- 	opts = {},
			-- },
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local lspkind = require("lspkind")
			-- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
			require("luasnip.loaders.from_vscode").lazy_load()
			-- when cmp completion is loaded, clear the virtual text from codium

			cmp.event:on("menu_opened", function()
				if vim.g.codeium_enabled == true then
					return vim.fn["codeium#Clear"]()
				end
			end)

			-- if vim.g.codeium_enabled == true then
			-- cmp.event:on("menu_opened", function()
			-- 	return vim.fn["codeium#Clear"]()
			-- end)
			-- end
			cmp.setup({
				-- Other configurations...
				enabled = function()
					return vim.bo.ft ~= "" and not vim.b.bigfile
				end,
				-- enabled = function()
				-- 	return vim.g.cmp_enabled
				-- end,
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
					["<C-m>"] = cmp.mapping.complete({ -- trigger ai sources only
						config = {
							sources = {
								{ name = "codeium" },
								{ name = "cody" },
							},
						},
					}),
					-- TODO: I should add invoke codeium to use it and remove it from `ai.lua` file
					["<C-e>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.abort()
							return vim.fn["codeium#Complete"]()
						else
							fallback()
						end
					end),
					["<C-l>"] = cmp.mapping.close(),
					-- ["<Down>"] = function(fb)
					-- 	cmp.close()()
					-- end,
					["<CR>"] = cmp.mapping.confirm({ select = false }),
					-- TODO: if statement to accept codeium suggestions.
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
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
					{ name = "cody" },
					{ name = "otter" },
					{ name = "cmp_r" },
					{ name = "nvim_lsp" },
					-- { name = "cmp_tabnine" },
					{ name = "luasnip" }, -- snippets
					{
						name = "buffer",
						max_item_count = 8,
						option = {
							get_bufnrs = get_bufnrs,
						},
					}, -- text within current buffer
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
							Cody = "",
							cmp_nvim_r = "R",
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
				-- experimental = {
				-- 	ghost_text = { hl_group = "LspCodeLens" },
				-- },
			})
			cmp.setup.cmdline({ "/", "?" }, {
				view = {
					entries = { name = "wildmenu", separator = "|" },
				},
				sources = {
					{
						name = "buffer",
						option = {
							get_bufnrs = get_bufnrs,
						},
					},
				},
			})
			-- TODO: implement exceptions: https://github.com/hrsh7th/nvim-cmp/wiki/Advanced-techniques#disabling-cmdline-completion-for-certain-commands-such-as-increname
			cmp.setup.cmdline(":", {
				view = {
					entries = { name = "wildmenu", separator = "|" },
				},
				sources = {
					{ name = "path", group_index = 1 },
					{
						name = "cmdline",
						option = {
							ignore_cmds = {},
						},
						group_index = 2,
					},
				},
			})
		end,
	},
}
