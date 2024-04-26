local content = vim.g.content
for line in content:gmatch("[^\r\n]+") do
	local status, filePath = line:match("^.(.).(.*)")
	print("status: " .. status, "filePath: " .. filePath)
end

local s = "hello world from Lua"
for w in string.gmatch(s, "%a+") do
	print(w)
end

local t = {}
s = "from=world, to=Lua"
for k, v in string.gmatch(s, "(%w+)=(%w+)") do
	t[k] = v
end
print(t.from, t.to)

-- Hey you can use pylance with lspconfig with some little trick.
-- ```cd ~/.vscode/extensions/ms-python.vscode-pylance-*/dist &&awk 'BEGIN{RS=ORS=";"} /if\(!process/ && !found {sub(/return!0x1/, "return!0x0"); found=1} 1' server.bundle.js |awk 'BEGIN{RS=ORS=";"} /throw new/ && !found {sub(/throw new/, ""); found=1} 1' > server_nvim.js```
-- Then create folder in your `~/.config/nvim` as my repo https://github.com/nullchilly/vscode-lsp.nvim You can now call `require'lspconfig'.pylance.setup {}`
