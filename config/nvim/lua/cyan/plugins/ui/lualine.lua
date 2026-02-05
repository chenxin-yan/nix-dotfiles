local function get_attached_clients()
  -- Get active clients for current buffer
  local buf_clients = vim.lsp.get_clients { bufnr = 0 }
  local buf_ft = vim.bo.filetype
  local lsp_client_names = {}
  local linter_names = {}
  local formatter_names = {}

  -- Add lsp-clients active in the current buffer
  for _, client in pairs(buf_clients) do
    table.insert(lsp_client_names, client.name)
  end

  -- Add linters for the current filetype (nvim-lint)
  local lint_success, lint = pcall(require, 'lint')
  if lint_success then
    for ft, ft_linters in pairs(lint.linters_by_ft) do
      if ft == buf_ft then
        if type(ft_linters) == 'table' then
          for _, linter in pairs(ft_linters) do
            table.insert(linter_names, linter)
          end
        else
          table.insert(linter_names, ft_linters)
        end
      end
    end
  end

  -- Add formatters (conform.nvim)
  local conform_success, conform = pcall(require, 'conform')
  if conform_success then
    for _, formatter in pairs(conform.list_formatters_for_buffer(0)) do
      if formatter then
        table.insert(formatter_names, formatter)
      end
    end
  end

  -- Build the display string
  local result = ''
  if #lsp_client_names > 0 then
    result = result .. '󰅡 ' .. table.concat(lsp_client_names, ' | ')
  end
  if #linter_names > 0 then
    if result ~= '' then
      result = result .. '  '
    end
    result = result .. '󰁨 ' .. table.concat(linter_names, ' | ')
  end
  if #formatter_names > 0 then
    if result ~= '' then
      result = result .. '  '
    end
    result = result .. '󰛖 ' .. table.concat(formatter_names, ' | ')
  end

  if result == '' then
    return ''
  end

  return result .. ' '
end

local colors = {
  lavender = '#b4befe',
  green = '#a6e3a1',
  maroon = '#eba0ac',
  flamingo = '#f2cdcd',
  mantle = '#181825',
  surface = '#313244',
  text = '#cdd6f4',
  subtext = '#9399b2',
}

local custom_catppuccin = {
  normal = {
    a = { fg = colors.mantle, bg = colors.lavender },
    b = { fg = colors.text, bg = colors.surface },
    c = { fg = colors.subtext },
  },

  insert = { a = { fg = colors.mantle, bg = colors.green } },
  visual = { a = { fg = colors.mantle, bg = colors.flamingo } },
  replace = { a = { fg = colors.mantle, bg = colors.maroon } },

  inactive = {
    a = { fg = colors.mantle, bg = colors.lavender },
    b = { fg = colors.text, bg = colors.surface },
    c = { fg = colors.subtext },
  },
}

return {
  'nvim-lualine/lualine.nvim',
  event = 'VeryLazy',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  init = function()
    vim.g.lualine_laststatus = vim.o.laststatus
    if vim.fn.argc(-1) > 0 then
      -- set an empty statusline till lualine loads
      vim.o.statusline = ' '
    else
      -- hide the statusline on the starter page
      vim.o.laststatus = 0
    end
  end,
  opts = function()
    local lualine_require = require 'lualine_require'
    lualine_require.require = require

    vim.o.laststatus = vim.g.lualine_laststatus
    local attached_clients = {
      get_attached_clients,
      color = {
        gui = 'bold',
      },
    }

    local opts = {
      options = {
        theme = custom_catppuccin,
        globalstatus = vim.o.laststatus == 3,
        disabled_filetypes = {
          statusline = { 'dashboard', 'alpha', 'ministarter', 'snacks_dashboard' },
          winbar = { 'dashboard', 'alpha', 'ministarter', 'snacks_dashboard' },
        },
        component_separators = ' ',
        section_separators = { left = '', right = '' },
      },
      sections = {
        lualine_a = {
          { 'mode', padding = { left = 2, right = 1 }, color = { gui = 'bold' } },
        },
        lualine_b = {
          { 'branch', icon = '', padding = { left = 1, right = 1 } },
          {
            'diff',
            symbols = { added = ' ', modified = ' ', removed = ' ' },
            padding = { right = 1 },
          },
        },
        lualine_c = {
          {
            '%=',
            component_separators = '',
          },
          {
            'diagnostics',
            symbols = {
              error = ' ',
              warn = ' ',
              info = ' ',
              hint = ' ',
            },
          },
        },
        lualine_x = {
          -- stylua: ignore
          {
            function() return require("noice").api.status.mode.get() end,
            cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
            color = function() return { fg = Snacks.util.color("Constant") } end,
          },
          -- stylua: ignore
          {
            function() return "  " .. require("dap").status() end,
            cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
            color = function() return { fg = Snacks.util.color("Debug") } end,
          },
          attached_clients,
        },
        lualine_y = {
          { 'progress', separator = ' ', padding = { left = 1, right = 0 } },
          { 'location', padding = { left = 0, right = 1 } },
        },
        lualine_z = {
          {
            function()
              return '󰉖 ' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
            end,
            padding = { left = 1, right = 2 },
            color = { gui = 'bold' },
          },
        },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {},
      },
      winbar = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
          {
            function()
              local folder = vim.fn.fnamemodify(vim.fn.expand '%:p:h', ':t')
              if folder ~= '' then
                return folder .. ' >'
              end
              return ''
            end,
            padding = { left = 2, right = 0 },
            color = { fg = colors.subtext },
          },
          { 'filetype', icon_only = true, padding = { right = 0 }, separator = '' },
          {
            'filename',
            symbols = {
              modified = '●',
              readonly = '',
              unnamed = '',
              newfile = '',
            },
            padding = { left = 0 },
            separator = '',
            color = { fg = colors.text },
          },
          {
            function()
              local navic_ok, navic = pcall(require, 'nvim-navic')
              if navic_ok and navic.is_available() then
                local location = navic.get_location()
                if location and location ~= '' then
                  return '>'
                end
              end
              return ''
            end,
            padding = { left = 1, right = 0 },
            separator = '',
            color = { fg = colors.subtext },
          },
          { 'navic', color_correction = 'dynamic' },
        },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
      inactive_winbar = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
          { 'filetype', icon_only = true, padding = { left = 2, right = 0 } },
          {
            function()
              local parent = vim.fn.fnamemodify(vim.fn.expand '%:p:h', ':t')
              if parent ~= '' then
                return parent .. '/'
              end
              return ''
            end,
            padding = { left = 0, right = 0 },
            separator = '',
            color = { fg = colors.subtext },
          },
          {
            'filename',
            symbols = {
              modified = '●',
              readonly = '',
              unnamed = '',
              newfile = '',
            },
            padding = { left = 0 },
          },
        },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
      extensions = {},
    }

    return opts
  end,
}
