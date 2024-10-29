if vim.env.NVIM_TESTING then
  return {}
end
-- Formatting.
return {
  { -- Autoformat
    "stevearc/conform.nvim",
    event = { "LspAttach", "BufReadPost" },
    opts = {
      notify_on_error = false,
      format_on_save = {
        timeout_ms = 2000,
        lsp_fallback = true,
      },
      formatters_by_ft = {
        lua = { "stylua" },
        -- Conform can also run multiple formatters sequentially
        python = function(bufnr)
          if
            require("conform").get_formatter_info("ruff_format", bufnr).available
          then
            return { "ruff_fix", "ruff_format", "ruff_organize_imports" }
          else
            return { "isort", "black" }
          end
        end,
        quarto = { "injected" },
        go = { "goimports", "gofumpt", "gomodifytags" },
      },
      formatters = {
        injected = {
          -- Set the options field
          options = {
            -- Set to true to ignore errors
            ignore_errors = false,
            -- Map of treesitter language to file extension
            -- A temporary file name with this extension will be generated during formatting
            -- because some formatters care about the filename.
            lang_to_ext = {
              bash = "sh",
              c_sharp = "cs",
              elixir = "exs",
              javascript = "js",
              julia = "jl",
              latex = "tex",
              markdown = "md",
              python = "py",
              ruby = "rb",
              rust = "rs",
              teal = "tl",
              r = "r",
              typescript = "ts",
            },
            -- Map of treesitter language to formatters to use
            -- (defaults to the value from formatters_by_ft)
            lang_to_formatters = {},
          },
        },
      },
      -- Customize the "injected" formatter
    },
  },
}
