if vim.env.NVIM_TESTING then
  return {}
end
return {
  "onsails/lspkind.nvim",
  enabled = function()
    return not vim.b.bigfile
  end,
  event = { "LspAttach", "InsertEnter" },
  config = function()
    require("lspkind").init({
      symbol_map = {
        Array = "  ",
        Boolean = " 󰨙 ",
        Class = " 󰯳 ",
        Codeium = " 󰘦 ",
        Color = "  ",
        Control = "  ",
        Collapsed = " > ",
        Constant = " 󰯱 ",
        Constructor = "  ",
        Copilot = "  ",
        Enum = " 󰯹 ",
        EnumMember = "  ",
        Event = "  ",
        Field = "  ",
        File = "  ",
        Folder = "  ",
        Function = " 󰡱 ",
        Interface = " 󰰅 ",
        Key = "  ",
        Keyword = " 󱕴 ",
        Method = " 󰰑 ",
        Module = " 󰆼 ",
        Namespace = " 󰰔 ",
        Null = "  ",
        Number = " 󰰔 ",
        Object = " 󰲟 ",
        Operator = "  ",
        Package = " 󰰚 ",
        Property = " 󰲽 ",
        Reference = " 󰰠 ",
        Snippet = "  ",
        String = "  ",
        Struct = " 󰰣 ",
        TabNine = " 󰏚 ",
        Text = " 󱜥 ",
        TypeParameter = " 󰰦 ",
        Unit = " 󱜥 ",
        Value = "  ",
        Variable = " 󰄛 ",
      },
    })
  end,
}
