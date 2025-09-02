return {
  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'dockerfile' } },
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
