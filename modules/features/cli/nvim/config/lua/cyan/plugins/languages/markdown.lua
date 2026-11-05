return {
  {
    'chenxin-yan/footnote.nvim',
    ft = { 'markdown', 'markdown.mdx' },
    opts = {
      keys = {
        n = {
          new_footnote = '<leader>cfn',
          organize_footnotes = '<leader>cfo',
        },
      },
    },
  },
  {
    'romus204/tree-sitter-manager.nvim',
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
    build = function()
      vim.cmd [[Lazy load markdown-preview.nvim]]
      vim.fn['mkdp#util#install']()
    end,
    init = function()
      vim.g.mkdp_filetypes = { 'markdown', 'markdown.mdx' }
    end,
    keys = {
      { '<leader>up', ft = { 'markdown', 'markdown.mdx' }, '<cmd>MarkdownPreviewToggle<cr>', desc = 'Toggle Markdown [P]review' },
    },
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'echasnovski/mini.nvim' },
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
          -- `-` lints stdin; this list replaces the default args, so keep it.
          args = { '--config', vim.fn.expand '~/.markdownlint.json', '-' },
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
        marksman = {},
        harper_ls = {
          settings = {
            ['harper-ls'] = {
              -- harper-ls rejects a null config ("Settings must be an object"),
              -- so an explicit settings object must always be sent.
              linters = {
                SentenceCapitalization = false,
                SpellCheck = false,
              },
            },
          },
        },
      },
    },
  },
  {
    'stevearc/conform.nvim',
    opts = {
      formatters = {
        ['markdownlint-cli2'] = {
          args = { '--fix', '$FILENAME', '--config', vim.fn.expand '~/.markdownlint.json' },
        },
      },
      formatters_by_ft = {
        markdown = { 'oxfmt', 'markdownlint-cli2' },
        ['markdown.mdx'] = { 'oxfmt', 'markdownlint-cli2' },
      },
    },
  },
}
