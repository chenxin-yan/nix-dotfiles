return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { 'nix' },
    },
  },
  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    event = 'VeryLazy',
    opts = {
      servers = {
        nil_ls = {}
      }
    },
  },
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        nix = { "nixfmt" },
      },
    }
  }
}
