-- those for image.nvim to work
package.path = table.concat({
	package.path,
	vim.fs.normalize("~/.luarocks/share/lua/5.1/?/init.lua"),
	vim.fs.normalize("~/.luarocks/share/lua/5.1/?.lua"),
}, ";")
return {
	{ -- for images
		"3rd/image.nvim",
		event = {
			"FileType markdown,norg,quarto",
			"BufRead *.png,*.jpg,*.gif,*.webp,*.ipynb",
		},
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		opts = {
			backend = "kitty",
			integrations = {
				markdown = {
					enabled = true,
					clear_in_insert_mode = false,
					download_remote_images = true,
					only_render_image_at_cursor = false,
					filetypes = { "markdown", "vimwiki", "quarto" },
				},
			},
			max_width = 80,
			max_height = 20,
			max_width_window_percentage = math.huge,
			max_height_window_percentage = math.huge,
			kitty_method = "normal",
		},
	},
	{
		"iamcco/markdown-preview.nvim",
		build = "cd app && npm install && cd - && git restore .",
		ft = "markdown",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
			vim.g.mkdp_auto_close = 0
			vim.g.mkdp_theme = "light"
		end,
	},
}
