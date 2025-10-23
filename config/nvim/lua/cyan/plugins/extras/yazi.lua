return {
  'mikavilpas/yazi.nvim',
  init = function()
    -- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
    -- vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
  end,
  keys = {
    {
      '-',
      '<cmd>Yazi<cr>',
      desc = 'Open yazi at the current file',
    },
    {
      -- Open in the current working directory
      '<c-e>',
      '<cmd>Yazi cwd<cr>',
      desc = "Open the file manager in nvim's working directory",
    },
  },
  opts = {
    yazi_floating_window_border = 'none',
    keymaps = {
      replace_in_directory = '<c-r>',
      grep_in_directory = '<c-g>',
      change_working_directory = '`',
    },
    integrations = {
      --- What should be done when the user wants to grep in a directory
      grep_in_directory = function(directory)
        require('fzf-lua').live_grep { cwd = directory }
      end,

      grep_in_selected_files = function(selected_files)
        local file_paths = {}
        for _, file in ipairs(selected_files) do
          table.insert(file_paths, type(file) == 'table' and file.name or file)
        end

        require('fzf-lua').live_grep {
          rg_opts = table.concat(
            vim.tbl_map(function(path)
              return string.format("-g '%s'", path)
            end, file_paths),
            ' '
          ) .. ' --column --line-number --no-heading --color=always --smart-case',
          cwd = vim.fn.fnamemodify(file_paths[1], ':h'),
        }
      end,
    },
  },
}
