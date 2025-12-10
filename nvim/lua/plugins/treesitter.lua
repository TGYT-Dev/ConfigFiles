return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  opts = {
    ensure_installed = {
      "html",
      "css",
      "javascript",
      "python",
      "java",
      "c",
      "cpp",
    },
    highlight = {
      enable = true, -- enable treesitter-based highlighting
      additional_vim_regex_highlighting = false,
    },
  },
}
