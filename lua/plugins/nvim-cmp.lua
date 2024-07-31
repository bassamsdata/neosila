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

      local kind_icons = {
        ellipsis_char = "...",
        Copilot = "",
        Supermaven = "",
        Codeium = "",
        Otter = "🦦",
        Cody = "",
        Cmp_r = "R",
      }

      cmp.setup({
        enabled = function()
          return not vim.b.bigfile
        end,
        preselect = cmp.PreselectMode.None,
        view = {
          entries = {
            follow_cursor = true,
          },
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-p>"] = cmp.mapping.select_prev_item({
            behavior = cmp.SelectBehavior.Select,
          }),
          ["<C-n>"] = cmp.mapping.select_next_item({
            behavior = cmp.SelectBehavior.Select,
          }),
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
          ["<C-y>"] = cmp.mapping.confirm({ select = true }),
          ["<C-m>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.confirm({ select = true })
            else
              fallback()
            end
          end),
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
          {
            name = "buffer",
            max_item_count = 8,
            option = {
              get_bufnrs = get_bufnrs,
            },
          }, -- text within current buffer
          { name = "path", priority = 50 }, -- file system paths
        }),

        formatting = {
          format = function(_, vim_item)
            local icon, hl, is_default =
              require("mini.icons").get("lsp", vim_item.kind)
            -- If the icon is not found in mini.icons (is_default is true), use the fallback
            if is_default then
              icon = kind_icons[vim_item.kind] or "󰞋"
              hl = "CmpItemKind" .. vim_item.kind
            end
            vim_item.kind = icon -- .. " " .. vim_item.kind
            vim_item.kind_hl_group = hl
            return vim_item
          end,
          fields = { "kind", "abbr" }, -- "menu",
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
