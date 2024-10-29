vim.api.nvim_create_user_command("Mess", function()
  local scratch_buffer = vim.api.nvim_create_buf(false, true)
  vim.bo[scratch_buffer].filetype = "vim"
  local messages = vim.split(vim.fn.execute("messages", "silent"), "\n")
  vim.api.nvim_buf_set_lines(scratch_buffer, 0, -1, false, messages)
  vim.cmd.sbuffer(scratch_buffer)
  vim.cmd("normal! G")
  vim.api.nvim_set_option_value("modifiable", false, { buf = scratch_buffer })
  vim.api.nvim_set_option_value("wrap", true, { win = 0 })
  vim.api.nvim_win_set_height(0, 10)
end, {})

vim.api.nvim_create_user_command("CloseOtherBuffers", function()
  require("utils").close_other_buffers()
end, {})

vim.api.nvim_create_user_command("KeepOnlyArrowFiles", function()
  require("utils").keepOnlyArrowFiles()
end, {})

vim.api.nvim_create_user_command("Lg", function()
  require("localModules.nvterminal").create_tool("lazygit", 0.9, 0.9)
end, {})
