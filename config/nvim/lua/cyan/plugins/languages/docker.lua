return {
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { 'dockerfile' })
    end,
  },
  {
    'neovim/nvim-lspconfig',
    init = function()
      vim.filetype.add {
        filename = {
          ['docker-compose.yml'] = 'yaml.docker-compose',
          ['docker-compose.yaml'] = 'yaml.docker-compose',
          ['compose.yml'] = 'yaml.docker-compose',
          ['compose.yaml'] = 'yaml.docker-compose',
        },
      }
    end,
    opts = {
      servers = {
        dockerls = {},
        docker_compose_language_service = {},
      },
    },
  },
  {
    'mfussenegger/nvim-lint',
    opts = {
      linters_by_ft = {
        dockerfile = { 'hadolint' },
      },
    },
  },
}
