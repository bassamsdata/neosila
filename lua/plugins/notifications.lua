return {
	{
		"j-hui/fidget.nvim",
		event = "VeryLazy",
		config = function()
			local fidget = require("fidget")
			vim.notify = fidget.notify
			require("fidget").setup({
				progress = {
					display = {
						format_message = function(msg)
							local formatted_message =
								require("fidget.progress.display").default_format_message(msg)
							local time = os.date("%Y-%m-%d %H:%M:%S") -- Get the current time
							return formatted_message .. " " .. time -- Append the time to the message
						end,
					},
				},
				-- Options related to notification subsystem
				notification = {
					poll_rate = 15, -- How frequently to update and render notifications
					filter = vim.log.levels.INFO, -- Minimum notifications level
					history_size = 128, -- Number of removed messages to retain in history
					override_vim_notify = true, -- Automatically override vim.notify() with Fidget
					-- How to configure notification groups when instantiated
					configs = {
						annote_style = "Question",
						debug_annote = "DEBUG",
						debug_style = "Comment",
						error_annote = "ERROR",
						error_style = "ErrorMsg",
						group_style = "Title",
						icon = "❰❰",
						icon_style = "Special",
						info_annote = "INFO",
						info_style = "Question",
						name = "Notifications",
						ttl = 5,
						warn_annote = "WARN",
						warn_style = "WarningMsg",
					},
					-- Conditionally redirect notifications to another backend
					redirect = function(msg, level, opts)
						if opts and opts.on_open then
							return require("fidget.integration.nvim-notify").delegate(
								msg,
								level,
								opts
							)
						end
					end,

					-- Options related to how notifications are rendered as text
					view = {
						stack_upwards = false, -- Display notification items from bottom to top
						icon_separator = " ", -- Separator between group name and icon
						group_separator = "---", -- Separator between notification groups
						-- Highlight group used for group separator
						group_separator_hl = "Comment",
					},

					-- Options related to the notification window and buffer
					window = {
						normal_hl = "Comment", -- Base highlight group in the notification window
						winblend = 100, -- Background color opacity in the notification window
						border = "rounded", -- Border around the notification window
						zindex = 45, -- Stacking priority of the notification window
						max_width = 0, -- Maximum width of the notification window
						max_height = 0, -- Maximum height of the notification window
						x_padding = 1, -- Padding from right edge of window boundary
						y_padding = 0, -- Padding from bottom edge of window boundary
						align = "bottom", -- How to align the notification window
						relative = "editor", -- What the notification window position is relative to
					},
				},

				-- Options related to integrating with other plugins
				integration = {
					["nvim-tree"] = {
						enable = true, -- Integrate with nvim-tree/nvim-tree.lua (if installed)
					},
				},

				-- Options related to logging
				logger = {
					level = vim.log.levels.WARN, -- Minimum logging level
					float_precision = 0.01, -- Limit the number of decimals displayed for floats
					-- Where Fidget writes its logs to
					path = string.format("%s/fidget.nvim.log", vim.fn.stdpath("cache")),
				},
			})
		end,
	},
}
