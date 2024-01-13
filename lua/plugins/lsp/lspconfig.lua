return {
	{
		"neovim/nvim-lspconfig",
		cond = not vim.g.vscode,
		cmd = { "LspInfo", "LspStart" },
		event = {
			"BufReadPre",
			"BufNewFile",
		},
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			{ "ray-x/lsp_signature.nvim" },
		},

		config = function()
			-- TODO: I took this fn as is from Maria. change this to simple if statement
			--- Returns the editor's capabilities + some overrides.
			vim.schedule(function()
				local client_capabilities = function()
					return vim.tbl_deep_extend(
						"force",
						vim.lsp.protocol.make_client_capabilities(),
						-- nvim-cmp supports additional completion capabilities, so broadcast that to servers.
						require("cmp_nvim_lsp").default_capabilities(),
						{
							workspace = {
								-- PERF: didChangeWatchedFiles is too slow.
								-- TODO: Remove this when https://github.com/neovim/neovim/issues/23291#issuecomment-1686709265 is fixed.
								didChangeWatchedFiles = { dynamicRegistration = false },
							},
						}
					)
				end
				-- import lspconfig plugin
				local lspconfig = require("lspconfig")
				-- used to enable autocompletion (assign to every lsp server config)
				local capabilities = client_capabilities()
				-- local capabilities = cmp_nvim_lsp.default_capabilities()

				local lsp_signature = require("lsp_signature")
				if lsp_signature then
					lsp_signature.setup({
						hint_enable = true,
						bind = true,
						border = "rounded",
						wrap = false,
						max_width = 120,
					})
				end

				-- Configure diagnostic display
				vim.diagnostic.config({
					virtual_text = {
						false,
						-- prefix = "■", -- Prefix for virtual text
						-- source = "always", -- Show source of diagnostic in virtual text
						-- spacing = 2, -- Spacing between virtual text lines
						-- severity_limit = "Warning", -- Don't show virtual text for hints
					},
					signs = true, -- Show signs in the sign column
					underline = true, -- Underline diagnostic text
					update_in_insert = false, -- Don't update diagnostics in insert mode
					severity_sort = true, -- Sort diagnostics by severity
					float = {
						border = "rounded", -- Rounded border for floating window
						source = "always", -- Show source of diagnostic in floating window
					},
				})

				local map = vim.keymap.set -- for conciseness
				local opts = { noremap = true, silent = true }
				vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
					vim.lsp.handlers.hover,
					{ border = "rounded", max_width = 80 }
				)

				vim.lsp.handlers["textDocument/signatureHelp"] =
					vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

				require("lspconfig.ui.windows").default_options.border = "rounded"
				local on_attach = function(client, bufnr)
					opts.buffer = bufnr

					-- set keybinds
					opts.desc = "Show LSP references"
					map("n", "gr", "<cmd>Pick lsp scope='references'<CR>", opts) -- show definition, references
					opts.desc = "Go to Definition"
					map("n", "gd", vim.lsp.buf.references, opts) -- go to declaration
					opts.desc = "Show LSP definitions"
					map("n", "gD", "<cmd>Pick lsp scope='definition'<CR>", opts) -- show lsp definitions
					opts.desc = "Show LSP implementations"
					map("n", "gi", "<cmd>Pick lsp scope='implementation'<CR>", opts) -- show lsp implementations
					-- TODO: change this keymap
					-- opts.desc = "Show LSP type definitions"
					-- map("n", "gt", "<cmd>Pick lsp scope='type_definition'<CR>", opts) -- show lsp type definitions

					opts.desc = "See available code actions"
					map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

					opts.desc = "Smart rename"
					map("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename
					opts.desc = "Signature help"
					map({ "i", "n" }, "<C-k>", function()
						require("lsp_signature").toggle_float_win()
					end, opts)

					opts.desc = "Show buffer diagnostics"
					map("n", "<leader>D", "<cmd>Pick diagnostic<CR>", opts) -- show  diagnostics for file

					opts.desc = "Toggle Diagnostics"
					map("n", "<leader>ud", function()
						local is_disabled = vim.diagnostic.is_disabled()
						if is_disabled then
							vim.diagnostic.enable()
						else
							vim.diagnostic.disable()
						end
					end, opts)

					opts.desc = "Show line diagnostics"
					map("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

					opts.desc = "Go to previous diagnostic"
					map("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

					opts.desc = "Go to next diagnostic"
					map("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

					opts.desc = "Show documentation for what is under cursor"
					map("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor
					opts.desc = "Restart LSP"
					map("n", "<leader>rs", "<cmd>LspRestart<cr>", opts) -- mapping to restart lsp if necessary
				end

				-- Change the Diagnostic symbols in the sign column (gutter)
				local signs =
					{ Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
				for type, icon in pairs(signs) do
					local hl = "DiagnosticSign" .. type
					vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
				end

				-- configure html server
				lspconfig["html"].setup({
					capabilities = capabilities,
					on_attach = on_attach,
				})

				-- configure css server
				lspconfig["cssls"].setup({
					capabilities = capabilities,
					on_attach = on_attach,
				})

				-- configure python server
				lspconfig["pyright"].setup({
					capabilities = capabilities,
					on_attach = on_attach,
				})

				-- configure r langauge server
				lspconfig["r_language_server"].setup({
					capabilities = capabilities,
					on_attach = on_attach,
				})

				-- lspconfig["sqlls"].setup({
				-- 	capabilities = capabilities,
				-- 	on_attach = on_attach,
				-- cmd = { "sql-language-server", "up", "--method", "stdio" },
				-- 	filetypes = { "sql"},
				-- 	root_dir = function(_)
				-- 		return vim.loop.cwd()
				-- 	end,
				-- })
				-- configure r langauge server
				lspconfig["marksman"].setup({
					capabilities = capabilities,
					on_attach = on_attach,
					-- filetypes = { "markdown", "quarto" },
				})
				lspconfig["ruff_lsp"].setup({
					on_attach = on_attach,
					on_init = function(client)
						if client.name == "ruff_lsp" then
							-- Disable hover in favor of Pyright
							client.server_capabilities.hoverProvider = false
						end
					end,
				})

				-- configure lua server (with special settings)
				lspconfig["lua_ls"].setup({
					capabilities = capabilities,
					on_attach = on_attach,
					on_init = function(client)
						local path = client.workspace_folders
							and client.workspace_folders[1]
							and client.workspace_folders[1].name
						if
							not path
							or not (
								vim.loop.fs_stat(path .. "/.luarc.lua")
								or vim.loop.fs_stat(path .. "/.luarc")
							)
						then
							client.config.settings =
								vim.tbl_deep_extend("force", client.config.settings, {
									Lua = {
										runtime = {
											version = "LuaJIT",
										},
										workspace = {
											checkThirdParty = false,
											library = {
												vim.env.VIMRUNTIME,
												"${3rd}/luv/library",
											},
										},
									},
								})
							client.notify(
								vim.lsp.protocol.Methods.workspace_didChangeConfiguration,
								{ settings = client.config.settings }
							)
						end

						return true
					end,
					settings = { -- custom settings for lua
						Lua = {
							-- Using stylua for formatting.
							format = { enable = false },
							hint = {
								enable = true,
								arrayIndex = "Disable",
							},
							completion = { callSnippet = "Replace", displayContext = 1 },
							-- make the language server recognize "vim" global
							diagnostics = {
								globals = { "vim" },
							},
							workspace = {
								-- make language server aware of runtime files
								library = {
									[vim.fn.stdpath("config") .. "/lua"] = true,
									[vim.fn.expand("$VIMRUNTIME/lua")] = true,
								},
							},
						},
					},
				})
			end)
		end,
	},
}
