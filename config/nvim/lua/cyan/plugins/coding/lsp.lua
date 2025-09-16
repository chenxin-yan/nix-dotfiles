return {
  {
    'saecki/live-rename.nvim',
    keys = {
      {
        '<leader>rn',
        "<cmd>lua require('live-rename').rename()<cr>",
        desc = 'Rename',
      },
    },
  },

  -- glance lsp locations
  {
    'dnlhc/glance.nvim',
    cmd = 'Glance',
    opts = {
      height = 24,
      border = {
        enable = true, -- Show window borders. Only horizontal borders allowed
      },
      use_trouble_qf = true,
    },
    keys = {
      { 'gd', '<CMD>Glance definitions<CR>', desc = '[G]oto Definition' },
      { 'gr', '<CMD>Glance references<CR>', desc = '[G]oto References' },
      { 'gt', '<CMD>Glance type_definitions<CR>', desc = '[G]oto Type Definition' },
      { 'gI', '<CMD>Glance implementations<CR>', desc = '[G]oto implementations' },
    },
  },
  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    event = 'VeryLazy',
    opts = {
      servers = {},
    },
    config = function(_, opts)
      -- require('java').setup {
      --   jdk = { auto_install = false },
      -- }

      for server_name, config in pairs(opts.servers) do
        vim.lsp.config(server_name, config)
        vim.lsp.enable(server_name)
      end

      -- vim.lsp.config('jdtls', {
      --   handlers = {
      --     ['$/progress'] = function(_, result, ctx) end,
      --   },
      -- })
      --
      -- vim.lsp.enable 'jdtls'
    end,
  },
  {
    'SmiteshP/nvim-navic',
    lazy = true,
    opts = {
      highlight = true,
      depth_limit = 5,
      lazy_update_context = true,
    },
  },
}
