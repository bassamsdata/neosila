local M = {}

-- thanks to tamton-aquib https://github.com/tamton-aquib/essentials.nvim/blob/b082e194dcd65656431411a4dd11c7f8b636616f/lua/essentials/init.lua#L93-L108

local fts = {
	python = "python %",
	lua = "lua %",
	r = "R %",
	sh = "chmod +x %", -- make script executable
	go = "go run %",
	sql = "duckdb -f %",
	quarto = "quarto render %",
	rmd = "R -e 'rmarkdown::render(\"%\")'",
	markdown = "pandoc % -o %:r.html",
}
M.run_file_term = function(option, term_height)
	local cmd = fts[vim.bo.ft]
	local height = term_height or 15
	vim.cmd(
		cmd and ("w | " .. (option or "") .. height .. "sp | term " .. cmd)
			or "echo 'No command for this filetype'"
	)
	vim.cmd("startinsert")
end

M.run_file = function(option)
	local cmd = fts[vim.bo.ft]
	vim.cmd(
		cmd and ("silent! w | " .. (option or "") .. "!" .. cmd)
			or "echo 'No command for this filetype'"
	)
end

------------------------------------------
-- delete all marks on current line
-- modified version - thanks to https://vi.stackexchange.com/questions/13984/how-do-i-delete-a-mark-in-current-line
M.delmarks = function()
	local marks = {}
	for i = string.byte("a"), string.byte("z") do
		local mark = string.char(i)
		local mark_line = vim.fn.getpos("'" .. mark .. "'")[2]
		if mark_line == vim.fn.line(".") then
			table.insert(marks, mark)
		end
	end
	local m = table.concat(marks)
	if m ~= "" then
		vim.cmd("delmarks " .. m)
	end
end

return M
