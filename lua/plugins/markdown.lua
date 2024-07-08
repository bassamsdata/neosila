return {
  {
    "MeanderingProgrammer/markdown.nvim",
    ft = { "markdown", "rmd", "quarto" },
    name = "render-markdown",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "echasnovski/mini.icons",
    },
    opts = {
      file_types = { "markdown", "rmd", "quarto" },
    },
  },
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install && cd - && git restore .",
    ft = "markdown",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_auto_close = 0
      vim.g.mkdp_theme = "light"
    end,
  },
}
