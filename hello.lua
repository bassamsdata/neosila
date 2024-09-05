local content = vim.g.content
for line in content:gmatch("[^\r\n]+") do
  local status, filePath = line:match("^.(.).(.*)")
  print("status: " .. status, "filePath: " .. filePath)
end

local s = "world world from Lua"
for w in string.gmatch(s, "%a+") do
  print(w)
end

local t = {}
s = "from=world, to=Lua"
for k, v in string.gmatch(s, "(%w+)=(%w+)") do
  t[k] = v
end
print(t.from, t.to)

if root_dir then
	print("Found git repository at", root_dir)
end
-- Hey you can use pylance with lspconfig with some little trick.
-- ```cd ~/.vscode/extensions/ms-python.vscode-pylance-*/dist &&awk 'BEGIN{RS=ORS=";"} /if\(!process/ && !found {sub(/return!0x1/, "return!0x0"); found=1} 1' server.bundle.js |awk 'BEGIN{RS=ORS=";"} /throw new/ && !found {sub(/throw new/, ""); found=1} 1' > server_nvim.js```
-- Then create folder in your `~/.config/nvim` as my repo https://github.com/nullchilly/vscode-lsp.nvim You can now call `require'lspconfig'.pylance.setup {}`

local M = {}

M.file_path = vim.fn.stdpath("config") .. "/hello1.lua"
function M.replace_word(old, new)
	local file, err = io.open(M.file_path, "r")
	if not file then
		file, _ = io.open(M.file_path, "w")
		file, err = io.write(file, "Hello World")
		file:close()
		vim.notify(err .. ", so new file has been created", vim.log.levels.ERROR)
	end
	local content = file:read("*all")
	file:close()
	-- local added_pattern = string.gsub(old, "-", "%%-") -- add % before - if exists
	local new_content = content:gsub(old, new)
	file, err = io.open(M.file_path, "w")
	if not file then
		vim.notify("Failed to open file for writing: " .. err, vim.log.levels.ERROR)
		return
	end
	file:write(new_content)
	file:close()
end
M.replace_word("world", "yay")

return M
