return {
  {
    'romus204/tree-sitter-manager.nvim',
    init = function()
      vim.treesitter.language.register('terraform', { 'opentofu', 'opentofu-vars' })
    end,
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { 'terraform', 'hcl' })
    end,
  },
  {
    'neovim/nvim-lspconfig',
    -- nvim maps *.tf -> 'tf' and doesn't detect *.tofu; tofu-ls expects the
    -- 'opentofu'/'opentofu-vars' filetypes, so remap as the tofu-ls docs advise.
    init = function()
      vim.filetype.add {
        extension = {
          tf = 'opentofu',
          tofu = 'opentofu',
          tfvars = 'opentofu-vars',
        },
      }
    end,
    opts = {
      servers = {
        tofu_ls = {},
      },
    },
  },
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        opentofu = { 'tofu_fmt' },
        ['opentofu-vars'] = { 'tofu_fmt' },
      },
    },
  },
  {
    'mfussenegger/nvim-lint',
    opts = {
      linters_by_ft = {
        opentofu = { 'tofu' },
      },
    },
  },
}
