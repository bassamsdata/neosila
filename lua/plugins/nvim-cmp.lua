if vim.env.NVIM_TESTING then
  return {}
end
local function get_bufnrs() -- this fn from Nv-macro, thanks
  return vim.b.bigfile and {} or { vim.api.nvim_get_current_buf() }
end

-- Initialize global variable for cmp-nvim toggle
vim.g.cmp_enabled = true
return {
  {
    "hrsh7th/cmp-buffer", -- source for text in buffer
    enabled = function()
      return not vim.b.bigfile
    end,
    event = { "CmdlineEnter", "InsertEnter" },
    dependencies = "hrsh7th/nvim-cmp",
  },
  {
    "hrsh7th/cmp-nvim-lsp",
    enabled = function()
      return not vim.b.bigfile
    end,
    event = "LspAttach",
  },
  {
    "hrsh7th/cmp-cmdline",
    enabled = function()
      return not vim.b.bigfile
    end,
    event = "CmdlineEnter",
    dependencies = "hrsh7th/nvim-cmp",
  },
  {
    "hrsh7th/nvim-cmp",
    enabled = function()
      return not vim.b.bigfile
    end,
    cond = not vim.g.vscode,
    event = { "LspAttach", "BufReadPost" },
    dependencies = {
      "hrsh7th/cmp-path", -- source for file system paths
      -- "L3MON4D3/LuaSnip", -- snippet engine
      -- "saadparwaiz1/cmp_luasnip", -- for autocompletion
      "rafamadriz/friendly-snippets", -- useful snippets
      "onsails/lspkind.nvim", -- vs-code like pictograms
    },
    config = function()
      local cmp = require("cmp")
      local neocodeium = require("neocodeium")
      -- local luasnip = require("luasnip")
      -- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
      -- require("luasnip.loaders.from_vscode").lazy_load()
      -- when cmp completion is loaded, clear the virtual text from codium

      cmp.event:on("menu_opened", function()
        if vim.g.codeium_enabled == true then
          return vim.fn["codeium#Clear"]()
        end
      end)

      cmp.setup({
        -- Other configurations...
        enabled = function()
          return not vim.b.bigfile
        end,
        -- snippet = { -- configure how nvim-cmp interacts with snippet engine
        -- 	expand = function(args)
        -- 		luasnip.lsp_expand(args.body)
        -- 	end,
        -- },
        preselect = cmp.PreselectMode.None,
        view = {
          entries = {
            follow_cursor = true,
          },
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-p>"] = cmp.mapping.select_prev_item(), -- previous suggestion
          ["<C-n>"] = cmp.mapping.select_next_item(), -- next suggestion
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-,>"] = cmp.mapping.complete(), -- show completion suggestions
          ["<C-j>"] = cmp.mapping.complete({ -- trigger ai sources only
            config = {
              sources = {
                { name = "codeium" },
                { name = "cody" },
              },
            },
          }),
          ["<C-e>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.abort()
              -- return vim.fn["codeium#Complete"]()
            else
              fallback()
            end
          end),
          ["<C-l>"] = cmp.mapping.close(),
          -- ["<Down>"] = function(fb)
          -- 	cmp.close()()
          -- end,
          ["<C-y>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if neocodeium.visible() then
              neocodeium.accept()
            elseif cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { "i", "s", "c" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
            else
              fallback()
            end
          end, { "i", "s", "c" }),
        }),
        -- sources for autocompletion
        sources = cmp.config.sources({
          { name = "supermaven", group_index = 1, priority = 100 },
          { name = "codeium", group_index = 2, priority = 99 },
          { name = "cody" },
          { name = "otter" },
          { name = "cmp_r" },
          { name = "nvim_lsp" },
          -- { qame = "cmp_tabnine" },
          -- { name = "luasnip" }, -- snippets
          {
            name = "buffer",
            max_item_count = 8,
            option = {
              get_bufnrs = get_bufnrs,
            },
          }, -- text within current buffer
          { name = "path", priority = 50 }, -- file system paths
        }),
        -- configure lspkind for vs-code like pictograms in completion menu
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function(entry, vim_item)
            local function commom_format(e, item)
              local kind = require("lspkind").cmp_format({
                -- mode = "symbol_text",
                maxwidth = 50,
                ellipsis_char = "...",
                symbol_map = {
                  Supermaven = "",
                  Codeium = "",
                  otter = "🦦",
                  Cody = "",
                  cmp_r = "R",
                },
                -- show_labelDetails = true, -- show labelDetails in menu. Disabled by default
              })(e, item)
              local strings = vim.split(kind.kind, "%s", { trimempty = true })
              kind.kind = " " .. (strings[1] or "") .. " "
              kind.menu = ""
              kind.concat = kind.abbr
              return kind
            end
            return commom_format(entry, vim_item)
          end,
          -- format = lspkind.cmp_format({
          -- 	-- mode = "symbol_text",
          -- 	maxwidth = 50,
          -- 	ellipsis_char = "...",
          -- 	symbol_map = {
          -- 		Codeium = "",
          -- 		otter = "🦦",
          -- 		Cody = "",
          -- 		cmp_nvim_r = "R",
          -- 	},
          -- }),
        },
        window = {
          -- completion = {
          -- 	winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
          -- },
          ---@diagnostic disable-next-line: missing-fields
          completion = {
            col_offset = -3,
            side_padding = 0,
            border = "rounded",
            winhighlight = "",
          },
          -- ---@diagnostic disable-next-line: missing-fields
          documentation = {
            border = "rounded",
            winhighlight = "", -- or winhighlight
            max_height = math.floor(vim.o.lines * 0.5),
            max_width = math.floor(vim.o.columns * 0.4),
          },
        },
        -- experimental = {
        -- 	ghost_text = { hl_group = "LspCodeLens" },
        -- },
      })
      cmp.setup.cmdline({ "/", "?" }, {
        -- view = {
        -- 	entries = { name = "wildmenu", separator = "|" },
        -- },
        sources = {
          {
            name = "buffer",
          },
        },
      })
      cmp.setup.cmdline(":", {
        -- view = {
        -- 	entries = { name = "wildmenu", separator = "|" },
        -- },
        sources = {
          { name = "path", group_index = 1 },
          {
            name = "cmdline",
            group_index = 2,
          },
        },
      })
    end,
  },
}
