-- install lazy.nvim if not already installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- load plugins from specifications (The leader key must be set before this)
require("lazy").setup({
	{ import = "plugins" },
	{ import = "plugins.lsp" },
}, {
	ui = { border = "rounded" },
	install = {
		-- Do not automatically install on startup.
		missing = false,
		colorscheme = { "cockatoo", "nano" },
	},
	-- I like to play with my configs alot so less clutter please.
	change_detection = { notify = false },
	performance = {
		cache = {
			enabled = true,
		},
		rtp = {
			-- Stuff I don't use.
			disabled_plugins = {
				"gzip",
				"netrwPlugin",
				"rplugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
				"health",
				"man",
				"matchit",
				"matchparen",
			},
		},
	},
	dev = {
		-- directory where you store your local plugin projects
		path = "~/repos",
		---@type string[] plugins that match these patterns will use your local versions instead of being fetched from GitHub
		patterns = {}, -- For example {"folke"}
		fallback = false, -- Fallback to git when local plugin doesn't exist
	},
})
-- vim.cmd.colorscheme("nano")
