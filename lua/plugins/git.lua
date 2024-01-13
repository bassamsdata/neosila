return {
	{
		"chrisgrieser/nvim-tinygit",
		ft = { "gitrebase", "gitcommit" }, -- so ftplugins are loaded
		dependencies = {
			"stevearc/dressing.nvim",
		},
	},
	{
		"NeogitOrg/neogit",
		cmd = "Neogit",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"sindrets/diffview.nvim",
		},
		opts = {
			disable_signs = false,
			disable_context_highlighting = true,
			disable_commit_confirmation = false,
			kind = "vsplit",
			signs = {
				-- { CLOSED, OPENED }
				hunk = { "", "" },
				item = { "", "" },
				section = { "", "" },
			},
			integrations = { diffview = true },
			commit_editor = {
				kind = "split",
			},
			commit_select_view = {
				kind = "tab",
			},
			commit_view = {
				kind = "split",
			},
			popup = {
				kind = "split",
			},
			-- TODO: Change mappings and keys
			mappings = {
				-- modify status buffer mappings
				status = {
					-- Adds a mapping with "B" as key that does the "BranchPopup" command
					-- ["B"] = "BranchPopup",
					-- ["C"] = "CommitPopup",
					-- ["P"] = "PullPopup",
					-- ["S"] = "Stage",
					-- ["D"] = "Discard",
					-- Removes the default mapping of "s"
					-- ["s"] = "",
				},
			},
		},
	},
	{
		"sindrets/diffview.nvim",
		dependencies = "nvim-lua/plenary.nvim",
		cmd = {
			"DiffviewOpen",
			"DiffviewClose",
			"DiffviewToggleFiles",
			"DiffviewFocusFiles",
			"DiffviewRefresh",
			"DiffviewFileHistory",
		},
		opts = {
			view = {
				use_icons = true,
				default = {
					-- layout = "diff2_horizontal",
					winbar_info = false, -- See ':h diffview-config-view.x.winbar_info'
				},
			},
		},
		keys = {
			{ "<leader>gdo", "<cmd>DiffviewOpen<cr>", desc = "Diffview [O]pen" },
			{ "<leader>gdc", "<cmd>DiffviewClose<cr>", desc = "Diffview [C]lose" },
		},
	},
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPost", "BufNewFile", "BufWritePre" },
		opts = {
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
				untracked = { text = "▎" },
			},
			preview_config = { border = "rounded" },
			on_attach = function(buffer)
				local gs = package.loaded.gitsigns

				local function map(mode, l, r, desc)
					vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
				end

      -- stylua: ignore start
      map("n", "]h", gs.next_hunk, "Next Hunk")
      map("n", "[h", gs.prev_hunk, "Prev Hunk")
      map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
      map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
      map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
      map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
      map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
      map("n", "<leader>ghp", gs.preview_hunk, "Preview Hunk")
      map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
      map("n", "<leader>ghd", gs.diffthis, "Diff This")
      map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
      map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
			end,
		},
	},
}
