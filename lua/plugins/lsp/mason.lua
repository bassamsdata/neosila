return {
	"williamboman/mason-lspconfig.nvim",
	cmd = { "Mason", "MasonInstall", "MasonInstallAll", "MasonUpdate" },
	-- event = { "BufReadPost", "BufNewFile" },
	dependencies = {
		"williamboman/mason.nvim",
	},
	config = function()
		local mason = require("mason")
		local mason_lspconfig = require("mason-lspconfig")
		mason.setup({
			ui = {
				border = "rounded",
				width = 0.7,
				height = 0.8,
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})
		mason_lspconfig.setup({
			-- list of servers for mason to install
			ensure_installed = {
				"pyright",
				"r_language_server",
				"lua_ls",
				"html",
				"cssls",
				"marksman",
				"taplo",
			},
			-- auto-install configured servers (with lspconfig)
			automatic_installation = true, -- not the same as ensure_installed
		})
	end,
}
