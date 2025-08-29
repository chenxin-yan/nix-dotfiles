return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { 
        "markdown",
        "markdown_inline",
        "yaml",
      },
    },
  },
  {
    'antonk52/markdowny.nvim',
    ft = 'markdown',
    config = true,
  },
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    ft = { 'markdown' },
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
        vim.g.mkdp_filetypes = { 'markdown' }
      end
    end,
    keys = {
      { '<leader>up', ft = 'markdown', '<cmd>MarkdownPreviewToggle<cr>', desc = 'Toggle Markdown [P]review' },
    },
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' },
    keys = {
      {
        '<leader>ur',
        '<cmd>RenderMarkdown toggle<cr>',
        desc = 'Toggle markdown [R]ender',
        ft = 'markdown',
      },
    },
    ft = { 'markdown' },
    opts = {
      file_types = { 'markdown' },
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
  }
}
