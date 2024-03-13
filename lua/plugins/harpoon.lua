-- TODO: delete either harpoon or Arrow
local function harpoon()
	return require("harpoon")
end
return {
	"theprimeagen/harpoon",
	cond = not vim.g.vscode,
	branch = "harpoon2",
	keys = {
    -- stylua: ignore start
		{ "<leader>ha", function() harpoon():list():append() end, desc = "Add file to Harpoon" },
		{ "<A-j>",     function() harpoon():list():select(1) end, desc = "Select file in Harpoon" },
		{ "<A-k>",     function() harpoon():list():select(2) end, },
		{ "<C-n>",     function() harpoon():list():select(3) end, },
		{ "<C-s>",     function() harpoon():list():select(4) end, },
		{ "<C-S-P>",   function() harpoon():list():prev() end,    },
		{ "<C-S-N>",   function() harpoon():list():next() end,    },
		-- stylua: ignore end
		{
			"<localleader>]",
			function()
				harpoon().ui:toggle_quick_menu(harpoon():list())
			end,
			desc = "Toggle Harpoon Menu",
		},
	},
	config = function()
		harpoon().setup({
			menu = {
				width = vim.api.nvim_win_get_width(0) - 4,
			},
		})
	end,
}
