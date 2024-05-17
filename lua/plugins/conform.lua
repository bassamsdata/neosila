-- Formatting.
return {
	{
		"stevearc/conform.nvim",
		event = { "LspAttach", "BufWritePre" },
		dependencies = { "mason.nvim" }, -- it doesn't work without this
		cmd = "ConformInfo",
		keys = {
			{
				"<leader>cF",
				function()
					require("conform").format({ formatters = { "injected" } })
				end,
				mode = { "n", "v" },
				desc = "Format Injected Langs",
			},
		},
		config = function()
			local conform = require("conform")
			conform.setup({
				formatters_by_ft = {
					lua = { "stylua" },
					go = { "goimports", "gofmt" },
					sql = { "sqlfmt" },
					python = function(bufnr)
						if
							require("conform").get_formatter_info("ruff_format", bufnr).available
						then
							return { "ruff_format" }
						else
							return { "isort", "black" }
						end
					end,
				},
				format_after_save = {
					lsp_fallback = true,
					async = true,
					timeout_ms = 2000,
				},
			})
			vim.keymap.set({ "n", "v" }, "<leader>mp", function()
				conform.format({
					lsp_fallback = true,
					async = false,
					timeout_ms = 1000,
				})
			end, { desc = "Format file or range (in visual mode)" })
		end,
	},
}
