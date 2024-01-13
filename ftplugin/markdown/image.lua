local api = vim.api
local ui = vim.ui
local fn = vim.fn
local uv = vim.uv
local cmd = vim.cmd

---Make directory for the image
local function make_image_dir(path)
	local stat = uv.fs_stat(path)
	if not stat or stat.type ~= "directory" then
		fn.mkdir(path, "p")
	end
end

---Get image name
local function get_image_name()
	local name
	ui.input({
		prompt = "Image name: ",
		default = os.date("%y-%m-%d-%H-%M-%S"),
	}, function(input)
		name = input
	end)
	if not name or string.match(name, "^%s*$") then
		return
	end
	return name
end

---Insert a link for the image
---@param fname string filename of the image
---@param path string path to the image
local function insert_link(fname, path)
	cmd("silent! lcd " .. fn.expand("%:p:h"))
	local link =
		string.format("![%s](%s)", fn.fnamemodify(fname, ":t:r"), fn.fnamemodify(vim.fs.joinpath(path, fname), ":~:."))
	cmd("silent! lcd -")
	fn.append(fn.line("."), link)
end

---Insert an image
local function insert_image()
	local title = get_image_name()
	if not title then
		return
	end

	-- create directory and blank image file
	local fname = title:gsub("%s+", "_"):lower() .. ".drawio.png"
	local path = vim.fs.joinpath(fn.expand("%:p:h") --[[@as string]], "pic", fn.expand("%:t:r"))
	make_image_dir(path)
	vim.system({
		"cp",
		vim.fs.joinpath(fn.stdpath("config") --[[@as string]], "ftplugin", "markdown", "reousrces", "blank.drawio.png"),
		vim.fs.joinpath(path, fname),
	})

	-- insert link
	insert_link(fname, path)

	-- copy file path to system clipboard
	os.execute('echo "' .. path .. '" | xclip -sel clip')

	-- open drawio
	if _G.handler_drawio and not _G.handler_drawio:is_closing() then
		_G.handler_drawio:close()
	end
	_G.handler_drawio = uv.spawn(
		"drawio",
		---@diagnostic disable-next-line: missing-fields
		{
			args = { vim.fs.joinpath(path, fname) },
			detached = true,
		},
		vim.schedule_wrap(function(code_drawio, _)
			if _G.handler_drawio and not _G.handler_drawio:is_closing() then
				_G.handler_drawio:close()
			end
			if code_drawio ~= 0 then
				vim.notify(string.format("task failed with code %d", code_drawio), vim.log.levels.ERROR)
			end
		end)
	)
end

---Paste an iamge from system clipboard
local function paste_image()
	local command = "xclip -selection clipboard -o -t TARGETS"
	local target_atoms = io.popen(command):lines()
	if not target_atoms then
		return
	end
	local atoms_list = {}
	for atom in target_atoms do
		table.insert(atoms_list, atom)
	end
	if not vim.tbl_contains(atoms_list, "image/png") then
		return -- no image in clipboard
	end

	-- Make directory for the image
	local path = vim.fs.joinpath(fn.expand("%:p:h") --[[@as string]], "pic", fn.expand("%:t:r"))
	make_image_dir(path)

	-- Get image name
	local title = get_image_name()
	if not title then
		return
	end

	-- Save image to file
	os.execute('xclip -selection clipboard -o -t image/png > "' .. vim.fs.joinpath(path, title .. ".png") .. '"')

	-- Insert link
	insert_link(title .. ".png", path)
end

api.nvim_buf_create_user_command(0, "MarkdownInsertImage", insert_image, {
	desc = "Insert an image on the current line",
})

api.nvim_buf_create_user_command(0, "MarkdownPasteImage", paste_image, {
	desc = "Paste an image from system clipboard",
})
