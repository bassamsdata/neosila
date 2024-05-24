local ft =
  { "lua", "norg", "quarto", "py", "go", "markdown", "R", "v", "yaml", "toml" }
return {
  {
    "echasnovski/mini.indentscope",
    ft = { "lua", "go", "r", "py", "quarto", "v" },
    cond = not vim.g.vscode,
    enabled = function()
      return not vim.b.bigfile
    end,
    config = function()
      local indentscope = require("mini.indentscope")
      indentscope.setup({
        draw = {
          delay = 100,
          animation = indentscope.gen_animation.none(),
        },
        -- Module mappings. Use `''` (empty string) to disable one.
        mappings = {
          object_scope = "ii",
          object_scope_with_border = "ai",

          goto_top = "[i",
          goto_bottom = "]i",
        },

        symbol = "│",
        options = { try_as_border = true },
      })
    end,
  },

  {
    "echasnovski/mini.map",
    cond = not vim.g.vscode,
    enabled = function()
      return not vim.b.bigfile
    end,
    ft = ft,
    config = function()
      local map = require("mini.map")
      local gen_integr = map.gen_integration
      if map then
        map.setup({
          integrations = {
            gen_integr.builtin_search(),
            gen_integr.diagnostic(),
            gen_integr.diff(),
          },
          window = {
            show_integration_count = false,
            width = 1,
            winblend = 0,
            zindex = 75,
          },
        })
        for _, key in ipairs({ "n", "N", "*" }) do
          vim.keymap.set(
            "n",
            key,
            key
              .. "zv<Cmd>lua MiniMap.refresh({}, { lines = false, scrollbar = false })<CR>"
          )
        end
        local autocmd = vim.api.nvim_create_autocmd
        -- vim.api.nvim_set_hl(0, "MiniMapSymbolLine", { fg = "#f38ba9" })

        autocmd({ "FileType" }, {
          pattern = ft,
          callback = function()
            vim.schedule(function()
              map.open()
            end)
            if vim.bo.buftype == "nofile" or vim.bo.buftype == "" then
              map.close()
            end
          end,
        })
        --
        -- autocmd({ "WinScrolled", "WinResized" }, {
        --  callback = function()
        --    vim.schedule(function()
        --      map.open()
        --    end)
        --  end,
        -- })
        -- autocmd("CursorHold", {
        --  callback = function()
        --    -- Delay map.close by 1000 ms
        --    vim.schedule(function()
        --      vim.defer_fn(function()
        --        map.close()
        --      end, 1500)
        --    end)
        --  end,
        -- })
      end
    end,
  },

  {
    "echasnovski/mini.notify",
    cond = not vim.g.vscode,
    event = "VeryLazy",
    config = function()
      local mini_notify = require("mini.notify")
      vim.notify = mini_notify.make_notify()
      -- FIX: convert the output to strings so it can appear in notify
      -- print = mini_notify.make_notify()
      -- vim.api.nvim_echo = mini_notify.make_notify()
      local cus_format = function(notif)
        local time = vim.fn.strftime("%H:%M:%S", math.floor(notif.ts_update))
        local icon = "\nNotification ❰❰"
        return string.format("%s │ %s %s", time, notif.msg, icon)
      end
      local row = function()
        local has_statusline = vim.o.laststatus > 0
        local bottom_space = vim.o.cmdheight + (has_statusline and 1 or 0)
        return vim.o.lines - bottom_space
      end
      mini_notify.setup({
        window = {
          config = function()
            return {
              col = vim.o.columns - 2,
              row = row(),
              anchor = "SE",
              title = "Notification ❰❰",
              title_pos = "right",
              border = "solid",
            }
          end,
          max_width_share = 0.6,
        },
      })
    end,
  },

  {
    "echasnovski/mini.misc",
    opts = {},
    keys = {
      { "<leader>mm", "<cmd>lua MiniMisc.zoom()<cr>", desc = "Zoom" },
      {
        "<leader>ur",
        function()
          require("mini.misc").setup_auto_root()
        end,
        desc = "[U]I [Root]",
      },
    },
  },

  { "echasnovski/mini.sessions", lazy = true, opts = {} },

  {
    "echasnovski/mini.align",
    keys = {
      { "ga", mode = { "v", "n" } },
      { "gA", mode = { "v", "n" } },
    },
    opts = {},
  },
  {
    "folke/todo-comments.nvim",
    event = "BufRead",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      keywords = {
        -- stylua: ignore start 
        FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = "󰓅 ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
        TEST = { icon = "󰙨", color = "test", alt = { "TESTING", "PASSED", "FAILED" }, },
        DEL = { icon = " ", color = "error", alt = { "DELETE" } },
        SUG = { icon = "󰭙 ", color = "info", alt = { "SUGGEST" } },
        -- stylua: ignore end
      },
      colors = {
        error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
        warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
        info = { "DiagnosticInfo", "#2563EB" },
        hint = { "DiagnosticHint", "#10B981" },
        default = { "Identifier", "#7C3AED" },
        test = { "Identifier", "#FF00FF" },
      },
    },
  },
  -- {
  --  --- apply one highlight for bg and another for fg
  --  "echasnovski/mini.hipatterns",
  --  cond = function()
  --    return not vim.b.large_file
  --  end,
  --  event = "BufReadPost",
  --  config = function()
  --    local mini_hipatterns = require("mini.hipatterns")
  --
  --    if mini_hipatterns then
  --      local keywords = { "NOTE", "BUG", "LOVE", "TODO", "FIX" }
  --      local icons = { "󰎞 ", "󰃤 ", "󰩖 ", "󰸞 ", "󰁨 " }
  --      local highlighters = {
  --        hex_color = mini_hipatterns.gen_highlighter.hex_color(),
  --        hsl_color = { -- thanks to https://github.com/craftzdog/dotfiles-public/blob/master/.config/nvim/lua/plugins/editor.lua
  --          pattern = "hsl%(%d+,? %d+%%?,? %d+%%?%)",
  --          group = function(_, match)
  --            local utils = require("utils.hi")
  --            --- @type string, string, string
  --            local nh, ns, nl =
  --              match:match("hsl%((%d+),? (%d+)%%?,? (%d+)%%?%)")
  --            --- @type number?, number?, number?
  --            local h, s, l = tonumber(nh), tonumber(ns), tonumber(nl)
  --            --- @type string
  --            local hex_color = utils.hslToHex(h, s, l)
  --            return mini_hipatterns.compute_hex_color_group(hex_color, "bg")
  --          end,
  --        },
  --      }
  --      for _, keyword in ipairs(keywords) do
  --        -- this is how we get attributes `fg = vim.api.nvim_get_hl(0, { name = 'NonText' }).fg,`
  --        local lowerKeyword = string.lower(keyword)
  --        -- local highlightGroup = string.format("HiPatterns%s", keyword)
  --        -- local fg = vim.api.nvim_get_hl(0, { name = highlightGroup }).fg
  --        highlighters[lowerKeyword] = {
  --          pattern = string.format("%s:", keyword),
  --          group = "IncSearch",
  --          extmark_opts = {
  --            sign_text = icons[_],
  --            sign_hl_group = "IncSearch",
  --          },
  --        }
  --        highlighters[string.format("%s_trail", lowerKeyword)] = {
  --          pattern = string.format("%s: ()%%S+.*()", keyword),
  --          group = "IncSearch",
  --        }
  --      end
  --
  --      mini_hipatterns.setup({ highlighters = highlighters })
  --    end
  --  end,
  -- },

  {
    "echasnovski/mini.bufremove",
    keys = {
      {
        "<localleader>x",
        function() -- credit to LazyVim for this implementation
          local bd = require("mini.bufremove").delete
          if vim.bo.modified then
            local choice = vim.fn.confirm(
              ("Save changes to %q?"):format(vim.fn.bufname()),
              "&Yes\n&No\n&Cancel"
            )
            if choice == 1 then -- Yes
              vim.cmd.write()
              bd(0)
            elseif choice == 2 then -- No
              bd(0, true)
            end
          else
            bd(0)
          end
        end,
        desc = "Delete Buffer",
      },
      {
        "<localleader>X",
        function()
          require("mini.bufremove").delete(0, true)
        end,
        desc = "Delete Buffer (Force)",
      },
    },
  },
}
