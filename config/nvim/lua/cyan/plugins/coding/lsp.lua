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
      for server_name, config in pairs(opts.servers) do
        vim.lsp.config(server_name, config)
        vim.lsp.enable(server_name)
      end
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
    config = function(_, opts)
      -- Remove when navic passes for_buf to make_text_document_params, including retries.
      local lib = require 'nvim-navic.lib'
      local request_symbol = lib.request_symbol
      lib.request_symbol = function(bufnr, handler, client, file_uri, retry_count)
        if not vim.api.nvim_buf_is_loaded(bufnr) then
          return
        end
        return vim.api.nvim_buf_call(bufnr, function()
          return request_symbol(bufnr, handler, client, file_uri, retry_count)
        end)
      end
      require('nvim-navic').setup(opts)
    end,
  },
}
