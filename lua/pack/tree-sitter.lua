local G = require('G')
local nvim_treesitter_config = require('nvim-treesitter.configs')

require("nvim-treesitter.install").prefer_git = true

require("onedark").setup({
  function_style = "italic",
  sidebars = {"qf", "vista_kind", "terminal", "packer"},

  -- Change the "hint" color to the "orange0" color, and make the "error" color bright red
  colors = {hint = "orange0", error = "#ff0000"},

  -- Overwrite the highlight groups
  overrides = function(c)
    return {
      htmlTag = {fg = c.red0, bg = "#282c34", sp = c.hint, style = "underline"},
      DiagnosticHint = {link = "LspDiagnosticsDefaultHint"},
      -- this will remove the highlight groups
      TSField = {},
    }
  end
})

nvim_treesitter_config.setup {
    options = {
      theme = 'onedark',
    },
    ensure_installed = { "tsx","json","html","scss","vue","typescript","javascript" },
    ignore_install = { "swift", "phpdoc" },

    highlight = {
        enable = false,
        additional_vim_regex_highlighting = false
    },
}
G.hi({
    Variable = {fg="NONE"};
    Function = {fg=32};
    Operator = {fg=166};

    KeywordOperator = {fg=166};

    Keyword = {fg=1};
    KeywordFunction = {fg=32};
    Exception = {fg=32};

    Statement = {fg=166};
    Special = {fg=172};
    Comment= {fg=71,sp='italic'};
    Include = {fg=1};
    Type = {fg=179};
    TypeBuiltin = {fg=150};
    PunctBracket = {fg=151};

    Constructor = {fg=172};
    Namespace = {fg=172};

    String = {fg=37};
    Number = {fg=37};
    Boolean = {fg=37};
})
G.map({ { 'n', 'H', ':TSHighlightCapturesUnderCursor<CR>', {silent = true, noremap = true}} })
