return {
	{
		"benlubas/molten-nvim",
		ft = "python",
		event = "BufEnter *.ipynb",
		dependencies = {
			"3rd/image.nvim",
			cond = function()
				return not vim.g.vscode or not vim.g.neovide
			end,
		},
		build = ":UpdateRemotePlugins",
		init = function()
			-- vim.g.molten_show_mimetype_debug = true
			vim.g.molten_auto_open_output = false
			-- if not vim.g.neovide then
			-- vim.g.molten_image_provider = "image.nvim"
			-- end
			-- vim.g.molten_output_show_more = true
			vim.g.molten_output_win_border = { "", "━", "", "" }
			vim.g.molten_output_win_max_height = 14
			-- vim.g.molten_output_virt_lines = true
			vim.g.molten_virt_text_output = true
			vim.g.molten_use_border_highlights = true
			vim.g.molten_virt_lines_off_by_1 = true
			vim.g.molten_wrap_output = true
			vim.g.molten_tick_rate = 175

			local autocmd = vim.api.nvim_create_autocmd
			local map = vim.keymap.set
      -- stylua: ignore start 
      map( "n", "<localleader>im", ":MoltenInit<CR>", { desc = "Initialize Molten", silent = true })
      map("n",  "<localleader>ir", function() vim.cmd("MoltenInit rust") end,
        { desc = "Initialize Molten for Rust", silent = true })
			-- stylua: ignore end
			map("n", "<localleader>ip", function()
				local venv = os.getenv("VIRTUAL_ENV")
				if venv ~= nil then
					-- in the form of /home/benlubas/.virtualenvs/VENV_NAME
					venv = string.match(venv, "/.+/(.+)")
					vim.cmd(("MoltenInit %s"):format(venv))
				else
					vim.cmd("MoltenInit python3")
				end
			end, {
				desc = "Initialize Molten for python3",
				silent = true,
				noremap = true,
			})

			autocmd("User", {
				pattern = "MoltenInitPost",
				callback = function()
					-- quarto code runner mappings
					local r = require("quarto.runner")
          -- stylua: ignore start 
          map( "n", "<localleader>rc", r.run_cell,  { desc = "run cell",           silent = true })
          map( "n", "<localleader>ra", r.run_above, { desc = "run cell and above", silent = true })
          map( "n", "<localleader>rb", r.run_below, { desc = "run cell and below", silent = true })
          map( "n", "<localleader>ml", r.run_line,  { desc = "run line",           silent = true })
          map( "n", "<localleader>rA", r.run_all,   { desc = "run all cells",      silent = true })
          map("n",  "<localleader>RA", function() r.run_all(true) end,     { desc = "run all cells & languages", silent = true })
          -- setup some molten specific keybindings
          map( "n", "<localleader>ml", ":MoltenEvaluateLine<CR>",          { desc = "evalute line",              silent = true })
          map( "n", "<localleader>e",  ":MoltenEvaluateOperator<CR>",      { desc = "evaluate operator",         silent = true })
          map( "n", "<localleader>rr", ":MoltenReevaluateCell<CR>",        { desc = "re-eval cell",              silent = true })
          map( "v", "<localleader>mv",  ":<C-u>MoltenEvaluateVisual<CR>gv", { desc = "execute visual selection",  silent = true })
          map( "n", "<localleader>os", ":noautocmd MoltenEnterOutput<CR>", { desc = "open output window",        silent = true })
          map( "n", "<localleader>oh", ":MoltenHideOutput<CR>",            { desc = "close output window",       silent = true })
          map( "n", "<localleader>md", ":MoltenDelete<CR>",                { desc = "delete Molten cell",        silent = true })
          local open = false
          map("n", "<localleader>ot", function() open = not open vim.fn.MoltenUpdateOption("auto_open_output", open) end) -- stylua: ignore end
          -- if we're in a python file, change the configuration a little
          if vim.bo.filetype == "python" then
            vim.fn.MoltenUpdateOption("molten_virt_lines_off_by_1", false)
            vim.fn.MoltenUpdateOption("molten_virt_text_output", false)
          end
				end,
			})

			-- change the configuration when editing a python file
			autocmd("BufEnter", {
				pattern = "*.py",
				callback = function(e)
					if string.match(e.file, ".otter.") then
						return
					end
					if require("molten.status").initialized() == "Molten" then
						vim.fn.MoltenUpdateOption("molten_virt_lines_off_by_1", false)
						vim.fn.MoltenUpdateOption("molten_virt_text_output", false)
					end
				end,
			})

			-- Undo those config changes when we go back to a markdown or quarto file
			-- vim.api.nvim_create_autocmd("BufEnter", {
			-- 	pattern = { "*.qmd", "*.md", "*.ipynb" },
			-- 	callback = function()
			-- 		if require("molten.status").initialized() == "Molten" then
			-- 			vim.fn.MoltenUpdateOption("molten_virt_lines_off_by_1", true)
			-- 			vim.fn.MoltenUpdateOption("molten_virt_text_output", true)
			-- 		end
			-- 	end,
			-- })

			-- automatically import output chunks from a jupyter notebook
			-- vim.api.nvim_create_autocmd("BufWinEnter", {
			-- 	pattern = { "*.ipynb" },
			-- 	callback = function(e)
			-- 		local kernels = vim.fn.MoltenAvailableKernels()
			--
			-- 		local try_kernel_name = function()
			-- 			local metadata =
			-- 				vim.json.decode(io.open(e.file, "r"):read("a"))["metadata"]
			-- 			return metadata.kernelspec.name
			-- 		end
			-- 		local ok, kernel_name = pcall(try_kernel_name)
			--
			-- 		if not ok or not vim.tbl_contains(kernels, kernel_name) then
			-- 			kernel_name = nil
			-- 			local venv = os.getenv("VIRTUAL_ENV")
			-- 			if venv ~= nil then
			-- 				kernel_name = string.match(venv, "/.+/(.+)")
			-- 			end
			-- 		end
			--
			-- 		if kernel_name ~= nil and vim.tbl_contains(kernels, kernel_name) then
			-- 			vim.cmd(("MoltenInit %s"):format(kernel_name))
			-- 		end
			-- 		vim.cmd("MoltenImportOutput")
			-- 	end,
			-- })

			-- automatically export output chunks to a jupyter notebook
			autocmd("BufWritePost", {
				pattern = { "*.ipynb" },
				callback = function()
					if require("molten.status").initialized() == "Molten" then
						vim.cmd("MoltenExportOutput!")
					end
				end,
			})
		end,
	},
}
