return {
	"echasnovski/mini.comment",
	keys = {
		{ "gcc", desc = "Toggle line comment" },
		{ "gc", mode = { "n", "x" }, desc = "Toggle comment" },
	},
	config = function()
		local mygroup =
			vim.api.nvim_create_augroup("MyCommentSettings", { clear = true })
		local autocmd = vim.api.nvim_create_autocmd
		autocmd({ "FileType" }, {
			group = mygroup,
			pattern = { "v", "vsh", "vv", "json" },
			callback = function()
				vim.bo.commentstring = "// %s"
			end,
		})
		autocmd({ "FileType" }, {
			group = mygroup,
			pattern = { "sql", "plpgsql", "plsql", "psql", "postgresql", "prql" },
			callback = function()
				vim.bo.commentstring = "-- %s"
			end,
		})
		require("mini.comment").setup({
			mappings = {
				-- Define 'comment' textobject (like `dgc` - delete whole comment block)
				-- Works also in Visual mode if mapping differs from `comment_visual`
				textobject = "tc",
			},
		})
	end,
}
