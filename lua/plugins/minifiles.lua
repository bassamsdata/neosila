return {
	{
		"echasnovski/mini.files",
		keys = {
			{ -- one keymapping to toggle
				"<leader>e",
				function()
					-- added this just to open the mini.files at the current file location
					local bufname = vim.api.nvim_buf_get_name(0)
					local _ = require("mini.files").close()
						or require("mini.files").open(bufname, false)
				end,
				{ desc = "File explorer" },
			},
		},
		config = function()
			-- create mappings for splits
			local map_split = function(buf_id, lhs, direction)
				local rhs = function()
					local window = MiniFiles.get_target_window()
					-- ensure doesn't make weired behaviour on directories
					if
						window == nil or MiniFiles.get_fs_entry().fs_type == "directory"
					then
						return
					end
					-- Make new window and set it as target
					local new_target_window
					vim.api.nvim_win_call(window, function()
						vim.cmd(direction .. " split")
						new_target_window = vim.api.nvim_get_current_win()
					end)
					MiniFiles.set_target_window(new_target_window)
					MiniFiles.go_in()
					MiniFiles.close()
				end

				-- Adding `desc` will result into `show_help` entries
				local desc = "Split " .. direction
				vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
			end

			vim.api.nvim_create_autocmd("User", {
				pattern = "MiniFilesBufferCreate",
				callback = function(args)
					local buf_id = args.data.buf_id
					-- Tweak keys to your liking
					map_split(buf_id, "<C-s>", "belowright horizontal")
					map_split(buf_id, "<C-v>", "belowright vertical")
				end,
			})
			-- make rounded borders, credit to MariaSolos
			vim.api.nvim_create_autocmd("User", {
				desc = "Add rounded corners to minifiles window",
				pattern = "MiniFilesWindowOpen",
				callback = function(args)
					vim.api.nvim_win_set_config(args.data.win_id, { border = "rounded" })
				end,
			})
			require("mini.files").setup({
				mappings = {
					show_help = "?",
					go_in_plus = "<cr>",
					go_out_plus = "<tab>",
				},
				options = { permanent_delete = false },
			})
		end,
	},
}
