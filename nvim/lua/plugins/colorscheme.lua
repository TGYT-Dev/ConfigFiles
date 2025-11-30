return {
  -- Add gruvbox.nvim
  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("gruvbox").setup({
        contrast = "soft", -- soft variant
      })
      vim.cmd([[colorscheme gruvbox]])
    end,
  },

  -- Configure LazyVim to use gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },
}
