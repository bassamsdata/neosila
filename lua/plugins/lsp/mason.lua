local M = {
	"williamboman/mason-lspconfig.nvim",
	event = { "BufReadPre", "BufNewFile" },
	cmd = { "MasonInstall", "MasonUpdate" },
	dependencies = {
		"williamboman/mason.nvim",
	},
}

function M.config()
	local servers = {
		"pyright",
		"r_language_server",
		"lua_ls",
		"html",
		"cssls",
		"marksman",
		"taplo",
		"v_analyzer",
		"gopls",
	}
	require("mason").setup({
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

	require("mason-lspconfig").setup({
		ensure_installed = servers,
	})
end

return M
