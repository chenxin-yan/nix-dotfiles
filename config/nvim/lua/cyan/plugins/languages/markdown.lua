return {
  {
    'chenxin-yan/footnote.nvim',
    ft = { 'markdown', 'markdown.mdx' },
    opts = {
      keys = {
        n = {
          new_footnote = '<leader>cfn',
          organize_footnotes = '<leader>cfo',
          next_footnote = ']f',
          prev_footnote = '[f',
        },
        i = {
          new_footnote = '<C-f>',
        },
      },

      organize_on_save = false,
      organize_on_new = false,
    },
  },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'markdown', 'markdown_inline', 'yaml', 'latex' } },
  },
  {
    'antonk52/markdowny.nvim',
    ft = { 'markdown', 'markdown.mdx' },
    config = function()
      require('markdowny').setup()
    end,
  },
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    ft = { 'markdown', 'markdown.mdx' },
    build = function(plugin)
      if vim.fn.executable 'npx' then
        vim.cmd('!cd ' .. plugin.dir .. ' && cd app && npx --yes yarn install')
      else
        vim.cmd [[Lazy load markdown-preview.nvim]]
        vim.fn['mkdp#util#install']()
      end
    end,
    init = function()
      if vim.fn.executable 'npx' then
        vim.g.mkdp_filetypes = { 'markdown', 'markdown.mdx' }
      end
    end,
    keys = {
      { '<leader>up', ft = { 'markdown', 'markdown.mdx' }, '<cmd>MarkdownPreviewToggle<cr>', desc = 'Toggle Markdown [P]review' },
    },
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' },
    init = function()
      vim.filetype.add {
        extension = {
          mdx = 'markdown.mdx',
        },
      }
    end,
    keys = {
      {
        '<leader>ur',
        '<cmd>RenderMarkdown toggle<cr>',
        desc = 'Toggle markdown [R]ender',
        ft = { 'markdown', 'markdown.mdx' },
      },
    },
    ft = { 'markdown', 'markdown.mdx' },
    opts = {
      file_types = { 'markdown', 'markdown.mdx' },
      code = {
        sign = false,
        width = 'block',
        right_pad = 1,
      },
      heading = {
        sign = false,
        icons = {},
      },
      bullet = {
        enabled = false,
      },
    },
  },
  {
    'mfussenegger/nvim-lint',
    opts = {
      linters = {
        ['markdownlint-cli2'] = {
          args = { '--config', vim.fn.expand '~/.markdownlint.jsonc' },
        },
      },
      linters_by_ft = {
        markdown = { 'markdownlint-cli2' },
        ['markdown.mdx'] = { 'markdownlint-cli2' },
      },
    },
  },
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        marksman = {
          filetypes = { 'markdown', 'markdown.mdx' },
        },
        harper_ls = {},
      },
    },
  },
  {
    'stevearc/conform.nvim',
    opts = {
      ['markdownlint-cli2'] = {
        args = { '--fix', '$FILENAME', '--config', vim.fn.expand '~/.markdownlint.jsonc' },
      },
      formatters_by_ft = {
        markdown = { 'prettierd', 'markdownlint-cli2' },
        ['markdown.mdx'] = { 'prettierd', 'markdownlint-cli2' },
      },
    },
  },
}
