return {
  "christoomey/vim-tmux-navigator",
  lazy = false,
  init = function()
    -- prevent plugin from setting its own maps so ours below take precedence
    vim.g.tmux_navigator_no_mappings = 1
  end,
  keys = {
    { "<C-h>",  "<cmd>TmuxNavigateLeft<cr>",     mode = "n" },
    { "<C-j>",  "<cmd>TmuxNavigateDown<cr>",     mode = "n" },
    { "<C-k>",  "<cmd>TmuxNavigateUp<cr>",       mode = "n" },
    { "<C-l>",  "<cmd>TmuxNavigateRight<cr>",    mode = "n" },
    { "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", mode = "n" },
  },
}
