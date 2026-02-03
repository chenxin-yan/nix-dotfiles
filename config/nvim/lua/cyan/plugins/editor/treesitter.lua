return {
  {
    'windwp/nvim-ts-autotag',
    event = { 'VeryLazy' },
    opts = {},
  },

  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    event = { 'VeryLazy' },
    build = ':TSUpdate',
    opts_extend = { 'ensure_installed' }, -- Enable array merging from language modules
    opts = {
      ensure_installed = {
        'bash',
        'diff',
        'printf',
        'query',
        'regex',
        'vim',
        'vimdoc',
        'xml',
        'git_config',
        'gitcommit',
        'git_rebase',
        'gitignore',
        'gitattributes',
      },
    },
    config = function(_, opts)
      local ts = require 'nvim-treesitter'

      -- Get already installed parsers
      local installed = ts.get_installed 'parsers'
      local installed_set = {}
      for _, lang in ipairs(installed) do
        installed_set[lang] = true
      end

      -- Install only missing parsers from merged ensure_installed
      local to_install = vim.tbl_filter(function(lang)
        return not installed_set[lang]
      end, opts.ensure_installed or {})

      if #to_install > 0 then
        ts.install(to_install, { summary = true })
      end

      -- FileType autocmd for highlighting and indentation
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local buf = args.buf
          local ft = vim.bo[buf].filetype
          if ft == '' or vim.bo[buf].buftype ~= '' then
            return
          end

          local lang = vim.treesitter.language.get_lang(ft) or ft
          local ok = pcall(vim.treesitter.language.add, lang)
          if not ok then
            return
          end

          -- Enable highlighting
          vim.treesitter.start(buf, lang)

          -- Enable indentation (skip ruby)
          if ft ~= 'ruby' then
            vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-context',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      mode = 'cursor',
      multiline_threshold = 1,
      max_lines = 3,
    },
    keys = {
      {
        '<leader>uc',
        function()
          require('treesitter-context').toggle()
        end,
        desc = 'Toggle treesitter Context',
      },
    },
  },

  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    event = { 'VeryLazy' },
    config = function()
      require('nvim-treesitter-textobjects').setup {
        move = { enable = true, set_jumps = true },
        swap = { enable = true },
      }

      local move = require 'nvim-treesitter-textobjects.move'
      local swap = require 'nvim-treesitter-textobjects.swap'

      -- Swap keymaps
      vim.keymap.set('n', '<leader>c]', function()
        swap.swap_next '@parameter.inner'
      end, { desc = 'Swap Next argument' })
      vim.keymap.set('n', '<leader>c}', function()
        swap.swap_next '@function.outer'
      end, { desc = 'Swap Next function' })
      vim.keymap.set('n', '<leader>c[', function()
        swap.swap_previous '@parameter.inner'
      end, { desc = 'Swap Previous argument' })
      vim.keymap.set('n', '<leader>c{', function()
        swap.swap_previous '@function.outer'
      end, { desc = 'Swap Previous function' })

      -- Move keymaps
      vim.keymap.set({ 'n', 'x', 'o' }, ']f', function()
        move.goto_next_start('@function.outer', 'textobjects')
      end, { desc = 'Next function/method start' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']a', function()
        move.goto_next_start('@parameter.outer', 'textobjects')
      end, { desc = 'Next argument' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[f', function()
        move.goto_previous_start('@function.outer', 'textobjects')
      end, { desc = 'Previous function/method start' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[a', function()
        move.goto_previous_start('@parameter.outer', 'textobjects')
      end, { desc = 'Previous argument' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']F', function()
        move.goto_next_end('@function.outer', 'textobjects')
      end, { desc = 'Next function/method end' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[F', function()
        move.goto_previous_end('@function.outer', 'textobjects')
      end, { desc = 'Previous function/method end' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']o', function()
        move.goto_next_start({ '@block.outer', '@conditional.outer', '@loop.outer' }, 'textobjects')
      end, { desc = 'Next code block' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[o', function()
        move.goto_previous_start({ '@block.outer', '@conditional.outer', '@loop.outer' }, 'textobjects')
      end, { desc = 'Previous code block' })
    end,
  },
}
