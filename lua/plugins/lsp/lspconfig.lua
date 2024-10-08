if vim.env.NVIM_TESTING then
  return {}
end
return {
  { -- LSP signature help
    "deathbeam/autocomplete.nvim",
    dev = true, -- SCHE: next-weekend night, until it's merged
    enabled = vim.fn.has("nvim-0.10") == 1,
    ft = { "lua", "r", "python", "sql", "markdown" },
    config = function()
      require("autocomplete.signature").setup({
        border = "rounded", -- Signature help border style
        debounce_delay = 100,
        max_width = 80,
        keymap = { toggle_signature = "<C-f>" },
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    enabled = function()
      return not vim.b.bigfile
    end,
    cmd = { "LspInfo", "LspStart" },
    event = {
      "BufReadPost",
      -- "BufNewFile"
    },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      cond = function()
        return not vim.g.vscode or not vim.b.bigfile
      end,
    },
    opts = {
      -- provide the code lenses.
      codelens = {
        enabled = true,
      },
      -- Enable lsp cursor word highlighting
      document_highlight = {
        enabled = true,
      },
    },

    config = function()
      -- I took this fn as is from Maria.
      --- Returns the editor's capabilities + some overrides.
      local client_capabilities = function()
        return vim.tbl_deep_extend(
          "force",
          vim.lsp.protocol.make_client_capabilities(),
          -- nvim-cmp supports additional completion capabilities, so broadcast that to servers.
          require("cmp_nvim_lsp").default_capabilities(),
          {
            workspace = {
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

      -- local lsp_signature = require("lsp_signature")
      -- if lsp_signature then
      -- 	lsp_signature.setup({
      -- 		hint_enable = true,
      -- 		bind = true,
      -- 		border = "rounded",
      -- 		wrap = false,
      -- 		max_width = 120,
      -- 	})
      -- end

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
          source = true, -- Show source of diagnostic in floating window
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
        local methods = vim.lsp.protocol.Methods

        -- set keybinds
        -- map("n", "gr", "<cmd>Pick lsp scope='references'<CR>", opts) -- show definition, references
        map("n", "gr", vim.lsp.buf.references, opts)
        map("n", "gd", vim.lsp.buf.definition, opts)
        -- map("n", "gD", "<cmd>Pick lsp scope='definition'<CR>", opts) -- show lsp definitions
        map("n", "gi", "<cmd>Pick lsp scope='implementation'<CR>", opts) -- show lsp implementations
        -- TODO: change this keymap
        -- map("n", "gt", "<cmd>Pick lsp scope='type_definition'<CR>", opts) -- show lsp type definitions
        map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection
        map("n", "<leader>rn", require("utils.lsp").lsp_rename, opts) -- smart rename
        map("n", "<leader>D", "<cmd>Pick diagnostic scope='current'<CR>", opts) -- show  diagnostics for file
        map("n", "<leader>ud", function()
          vim.diagnostic.enable(not vim.diagnostic.is_enabled())
        end, opts)
        map("n", "<leader>ui", function()
          vim.lsp.inlay_hint.enable(true)
        end, { desc = "Toggle inlay hints" })
        map("n", "<leader>d", vim.diagnostic.open_float) -- show diagnostics for line
        map("n", "K", vim.lsp.buf.hover) -- show documentation for what is under cursor
        map("n", "<leader>rs", "<cmd>LspRestart<cr>") -- mapping to restart lsp if necessary
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
      -- lspconfig["pyright"].setup({
      -- 	capabilities = capabilities,
      -- 	on_attach = on_attach,
      -- })

      require("lspconfig").pylance.setup({})

      -- Find the root of a Python project, starting from file 'main.py'
      -- vim.fs.root(
      -- 	vim.fs.joinpath(vim.env.PWD, "main.py"),
      -- 	{ "pyproject.toml", "setup.py" }
      -- )
      -- lspconfig["basedpyright"].setup({
      -- 	capabilities = capabilities,
      -- 	on_attach = on_attach,
      -- 	settings = {
      -- 		disableLanguageServices = true,
      -- 	},
      -- TODO: add this and modify it
      -- 	-- before_init = function(_, config)
      -- 	-- 	local default_venv_path =
      -- 	-- 		path.join(vim.env.HOME, "virtualenvs", "nvim-venv", "bin", "python")
      -- 	-- 	config.settings.python.pythonPath = default_venv_path
      -- 	-- end,
      -- })

      -- configure r langauge server
      lspconfig["r_language_server"].setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      lspconfig["gopls"].setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          gopls = {
            gofumpt = true,
            usePlaceholders = true,
            completeFunctionCalls = true,
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = false,
              rangeVariableTypes = true,
            },
            -- codelens
            codelenses = {
              gc_details = false,
              generate = true,
              regenerate_cgo = true,
              run_govulncheck = true,
              test = true,
              tidy = true,
              upgrade_dependency = true,
              vendor = true,
            },
            completeUnimported = true,
            staticcheck = true,
            directoryFilters = {
              "-.git",
              "-.vscode",
              "-.idea",
              "-.vscode-test",
              "-node_modules",
            },
            semanticTokens = true,
            analyses = {
              unusedparams = true,
              shadow = true,
            },
          },
          gofmt = true,
          --[[ init_options = {
                            usePlaceholders = true,
                            completeFunctionCalls = true,
                        }, ]]
        },
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
      -- lspconfig["marksman"].setup({
      --   capabilities = capabilities,
      --   on_attach = on_attach,
      --   -- filetypes = { "markdown", "quarto" },
      -- })
      lspconfig["ruff_lsp"].setup({
        on_attach = on_attach,
        on_init = function(client)
          if client.name == "ruff_lsp" then
            -- Disable hover in favor of Pyright
            client.server_capabilities.hoverProvider = false
          end
        end,
      })
      lspconfig["v_analyzer"].setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })
      -- lspconfig["harper_ls"].setup({
      --   capabilities = capabilities,
      --   on_attach = on_attach,
      -- })

      -- configure lua server (with special settings)
      lspconfig["lua_ls"].setup({
        capabilities = capabilities,
        on_attach = on_attach,
        root_dir = function(fname)
          return require("lspconfig.util").find_git_ancestor(fname)
            or require("lspconfig.util").path.dirname(fname)
        end,
        ---@param client vim.lsp.Client
        on_init = function(client)
          local path = client.workspace_folders
            and client.workspace_folders[1]
            and client.workspace_folders[1].name
          if
            not path
            or not (
              vim.uv.fs_stat(path .. "/.luarc.json")
              or vim.uv.fs_stat(path .. "/.luarc.jsonc")
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
                      vim.fn.stdpath("config"),
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
            codeLens = {
              enable = true,
            },
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
              library = {
                vim.fn.expand("$VIMRUNTIME/lua"),
                vim.fn.stdpath("config") .. "/lua",
              },
              maxPreload = 1000,
              preloadFileSize = 10000,
            },
          },
        },
      })
    end,
  },
}
