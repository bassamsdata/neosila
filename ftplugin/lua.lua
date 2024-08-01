-- vim.opt_local.suffixesadd:prepend(".lua")
-- vim.opt_local.suffixesadd:prepend("init.lua")
vim.opt_local.path:prepend(vim.fn.stdpath("config") .. "/lua")
-- Define the ReloadModule user command

local function reload_current_file()
  local current_file = vim.fn.expand("%:p")
  local module_name = vim.fn.fnamemodify(current_file, ":.:r")
  package.loaded[module_name] = nil
end

vim.api.nvim_create_user_command("ReloadModule", function()
  reload_current_file()
end, {
  force = true,
  desc = "Reload the current module",
})

-- Create an autocommand group to ensure no duplication
local group_id =
  vim.api.nvim_create_augroup("LuaReloadModule", { clear = true })

-- Register the autocommand for *.lua files starting with local M = {}
vim.api.nvim_create_autocmd("BufWritePost", {
  group = group_id,
  pattern = "*.lua",
  callback = function()
    -- Read the first line of the file
    local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
    if first_line and first_line:match("^local%s+M%s*=%s*{}") then
      reload_current_file()
      -- Display the notification at the bottom for a short time
      vim.notify("Module Reloaded", nil, {
        title = "Notification",
        timeout = 500, -- 1 second
        render = "compact", -- Minimal render style
      })
    end
  end,
  desc = "Reload the current module on save for Lua files starting with local M = {}",
})
