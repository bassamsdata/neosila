local M = {
	work_duration = nil,
	break_duration = nil,
	counter = nil,
	timer = nil,
	state = nil,
	previous_state = nil,
}
M.virtual_text_enabled = false

local STATE_WORKING = 0
local STATE_PAUSED = 1
local STATE_BREAK = 2

local STATE_MESSAGE_MAPPING = {
	[STATE_WORKING] = "Working",
	[STATE_PAUSED] = "Paused",
	[STATE_BREAK] = "Break",
}

-- Assuming you have a function to notify with the timer name
local function notify_with_timer_name(state_message)
	local timer_name = "Pomodoro" -- You can make this dynamic based on user input
	vim.notify(timer_name .. " - " .. state_message)
end

local function play_macos_alert_sound()
	os.execute("afplay /System/Library/Sounds/Submarine.aiff")
end

local function format_seconds(seconds)
	local hh = string.format("%02.f", math.floor(seconds / 3600))
	local mm = string.format("%02.f", math.floor(seconds / 60 - (hh * 60)))
	local ss = string.format("%02.f", math.floor(seconds - hh * 3600 - mm * 60))
	return hh .. ":" .. mm .. ":" .. ss
end

function M.initializeTimer(callback)
	M.timer = vim.loop.new_timer()
	M.timer:start(
		0,
		1000,
		vim.schedule_wrap(function()
			callback()
		end)
	)
end

function M.terminateTimer()
	if M.timer ~= nil then
		M.timer:close()
		M.timer = nil
	end
	vim.notify("Stopped at " .. format_seconds(M.counter) .. " seconds")
end

function M.beginWorkSession(duration)
	if duration then
		M.work_duration = duration * 60
		M.break_duration = 5 * 60 -- Example break duration, make this configurable
		if M.previous_state ~= nil then
			M.state = M.previous_state
		else
			M.state = STATE_WORKING
		end
		M.counter = M.work_duration
		M.initializeTimer(M.handleTimerEvents)
		M.displayTimerStatus()
		notify_with_timer_name(STATE_MESSAGE_MAPPING[M.state])
		play_macos_alert_sound() -- Play sound when the session starts
	end
end

function M.pauseTimer()
	M.previous_state = M.state
	M.state = STATE_PAUSED
	vim.notify("Paused " .. format_seconds(M.counter) .. " seconds remain")
end

function M.resumeTimer()
	if M.state == STATE_PAUSED then
		M.state = M.previous_state
		M.initializeTimer(M.handleTimerEvents)
		vim.notify("Resumed " .. format_seconds(M.counter) .. " seconds remain")
	end
end

function M.switchTimerState()
	if M.state == STATE_WORKING then
		M.state = STATE_BREAK
		M.counter = M.break_duration
	else
		M.state = STATE_WORKING
		M.counter = M.work_duration
	end
	notify_with_timer_name(STATE_MESSAGE_MAPPING[M.state])
end

function M.displayTimerStatus()
	print("Counter: " .. tostring(M.counter))
	if M.state == STATE_WORKING then
		vim.notify("Working " .. format_seconds(M.counter) .. " seconds remain")
	elseif M.state == STATE_PAUSED then
		vim.notify("Paused")
	elseif M.state == STATE_BREAK then
		vim.notify("Break " .. format_seconds(M.counter) .. " seconds remain")
	end
end

function M.promptDurationInput()
	vim.ui.input({ prompt = "Enter duration in minutes: " }, function(duration)
		if duration then
			M.beginWorkSession(tonumber(duration))
		end
	end)
end

local ns_id = vim.api.nvim_create_namespace("pomodoro_timer")

-- Improved handleTimerEvents function
function M.handleTimerEvents()
	if M.state ~= STATE_PAUSED then
		M.counter = M.counter - 1
		if M.counter % 60 == 0 then -- Notify every minute
			notify_with_timer_name(format_seconds(M.counter) .. " seconds remain")
		end
		if M.counter <= 0 then
			M.switchTimerState()
		end
	end
	if M.virtual_text_enabled then
		-- Update the virtual text with the new time
		local win_width = vim.api.nvim_win_get_width(0)
		local opts = {
			virt_text = { { format_seconds(M.counter), "NonText" } },
			virt_text_pos = "right_align",
			virt_text_win_col = win_width - 1,
		}
		vim.api.nvim_buf_set_extmark(0, ns_id, 0, 0, opts)
	end
end

function M.toggle_virtual_text()
	if M.virtual_text_enabled then
		-- Clear the virtual text
		vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
		M.virtual_text_enabled = false
	else
		-- Set the virtual text at the top right of the window
		local win_width = vim.api.nvim_win_get_width(0)
		local opts = {
			virt_text = { { format_seconds(M.counter), "NonText" } },
			virt_text_pos = "right_align",
			virt_text_win_col = win_width - 1,
		}
		vim.api.nvim_buf_set_extmark(0, ns_id, 4, 0, opts)
		M.virtual_text_enabled = true
	end
end

function M.setup()
	vim.keymap.set(
		"n",
		"<leader>ti",
		M.promptDurationInput,
		{ desc = "Display the Pomodoro pop-up", silent = true }
	)
	vim.keymap.set(
		"n",
		"<leader>tr",
		M.resumeTimer,
		{ desc = "Resume the Pomodoro timer", silent = true }
	)
	vim.keymap.set(
		"n",
		"<leader>ts",
		M.terminateTimer,
		{ desc = "Stop the Pomodoro timer", silent = true }
	)
	vim.keymap.set(
		"n",
		"<leader>tp",
		M.pauseTimer,
		{ desc = "Pause the Pomodoro timer", silent = true }
	)
	vim.keymap.set("n", "<leader>tt", function()
		if M.counter then
			vim.notify("Remaining time: " .. format_seconds(M.counter))
		else
			vim.notify("No timer running.")
		end
	end, { desc = "Check remaining time of the Pomodoro timer", silent = true })
	vim.keymap.set("n", "<leader>tv", M.toggle_virtual_text, {
		desc = "Toggle virtual text for Pomodoro timer",
		silent = true,
	})
end

return M
