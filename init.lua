local nv = require 'nv'

nv.set_var('mapleader', ' ')
nv.set_var('maplocalleader', ' ')
nv.set_var('have_nerd_font', true)

nv.set_opts {
  breakindent = true,
  number = true,
  relativenumber = true,
  cursorline = true,
  expandtab = true,
  hlsearch = false,
  ignorecase = true,
  inccommand = 'split',
  mouse = 'a',
  shiftwidth = 2,
  title = true,
  showmode = false,
  smartcase = true,
  softtabstop = 2,
  splitbelow = true,
  signcolumn = 'yes',
  splitright = true,
  swapfile = false,
  tabstop = 2,
  termguicolors = true,
  timeoutlen = 300,
  undofile = true,
  updatetime = 250,
  wrap = false,
  laststatus = 1,
  cmdheight = 0,
  clipboard = 'unnamedplus',
  list = false,
  scrolloff = 5,
}

nv.maps({
  { 'n', '<Esc>', '<cmd>nohlsearch<CR>' },
  { 'n', '<leader>oi', '<cmd>TSToolsOrganizeImports<CR>' },
  { 'n', '<C-v>c', '<cmd>e $MYVIMRC<CR>' },
  { 'n', 'L', '<cmd>:bn<cr>' },
  { 'n', 'H', '<cmd>:bp<cr>' },
  { 'n', '<C-d>', '<C-d>zz' },
  { 'n', '<C-u>', '<C-u>zz' },
  { 'n', 'n', 'nzz' },
  { 'n', 'N', 'Nzz' },
  -- LSP diagnostics keymaps using function wrappers
  {
    'n',
    '[d',
    function()
      vim.diagnostic.goto_prev()
    end,
  },
  {
    'n',
    ']d',
    function()
      vim.diagnostic.goto_next()
    end,
  },
  { 'n', '<Esc><Esc>', '<C-\\><C-n>' },
  { 'n', 'q', '<Nop>' },
  {
    'n',
    '<leader>rb',
    function()
      nv.cmd '!bun run %'
    end,
  },
  {
    'n',
    '<leader>q',
    function()
      vim.diagnostic.setloclist()
    end,
  },
}, { silent = true, remap = true })

nv.augroup_cmds('kickstart-highlight-yank', true, {
  {
    'TextYankPost',
    {
      callback = function()
        vim.highlight.on_yank()
      end,
    },
  },
})

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    lazyrepo,
    lazypath,
  }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  'tpope/vim-sleuth',

  -- {
  --   'nvim-lualine/lualine.nvim',
  --   dependencies = { 'nvim-tree/nvim-web-devicons' },
  --   opts = {},
  -- },

  { 'echasnovski/mini.starter', version = false, opts = {} },

  {
    'f-person/auto-dark-mode.nvim',
    opts = {},
  },

  {
    'supermaven-inc/supermaven-nvim',
    config = function()
      require('supermaven-nvim').setup {}
    end,
  },

  {
    'folke/ts-comments.nvim',
    opts = {},
    event = 'VeryLazy',
    enabled = vim.fn.has 'nvim-0.10.0' == 1,
  },

  {
    'marilari88/twoslash-queries.nvim',
    opts = {
      multi_line = true,
      is_enabled = true,
      highlight = 'Type',
    },
  },

  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },

    config = function()
      require('telescope').setup {
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      local builtin = require 'telescope.builtin'

      nv.maps {
        { 'n', '<leader>sh', builtin.help_tags },
        { 'n', '<leader>sk', builtin.keymaps },
        {
          'n',
          '<leader>ff',
          builtin.find_files,
        },
        {
          'n',
          '<leader>ss',
          builtin.builtin,
        },
        {
          'n',
          '<leader>fW',
          builtin.grep_string,
        },
        {
          'n',
          '<leader>fw',
          builtin.live_grep,
        },
        {
          'n',
          '<leader>fd',
          builtin.diagnostics,
        },
        { 'n', '<leader>fr', builtin.resume },
        {
          'n',
          '<leader>s.',
          builtin.oldfiles,
        },
        {
          'n',
          '<leader><leader>',
          builtin.buffers,
        },
        {
          'n',
          '<leader>/',
          builtin.current_buffer_fuzzy_find,
        },

        {
          'n',
          '<leader>sn',
          function()
            builtin.find_files { cwd = vim.fn.stdpath 'config' }
          end,
        },
      }
    end,
  },

  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', opts = {} },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
      { 'saghen/blink.cmp' },
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup(
          'kickstart-lsp-attach',
          { clear = true }
        ),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            nv.map(
              mode,
              keys,
              func,
              { buffer = event.buf, desc = 'LSP: ' .. desc }
            )
          end
          map(
            'gd',
            require('telescope.builtin').lsp_definitions,
            '[G]oto [D]efinition'
          )
          map(
            'gr',
            require('telescope.builtin').lsp_references,
            '[G]oto [R]eferences'
          )
          map(
            'gI',
            require('telescope.builtin').lsp_implementations,
            '[G]oto [I]mplementation'
          )
          map(
            '<leader>D',
            require('telescope.builtin').lsp_type_definitions,
            'Type [D]efinition'
          )
          map(
            '<leader>ds',
            require('telescope.builtin').lsp_document_symbols,
            '[D]ocument [S]ymbols'
          )
          map(
            '<leader>ws',
            require('telescope.builtin').lsp_dynamic_workspace_symbols,
            '[W]orkspace [S]ymbols'
          )
          map('<leader>rn', function()
            vim.lsp.buf.rename()
          end, '[R]e[n]ame')
          map('<leader>ca', function()
            vim.lsp.buf.code_action()
          end, '[C]ode [A]ction', { 'n', 'x' })
          map('gD', function()
            vim.lsp.buf.declaration()
          end, '[G]oto [D]eclaration')
        end,
      })

      local vtsls = {
        settings = {
          complete_function_calls = true,
          vtsls = {
            enableMoveToFileCodeAction = true,
            autoUseWorkspaceTsdk = true,
            experimental = {
              maxInlayHintLength = 30,
              -- completion = {
              --   enableServerSideFuzzyMatch = true,
              -- },
            },
          },
          typescript = {
            updateImportsOnFileMove = { enabled = 'always' },
            suggest = {
              completeFunctionCalls = true,
            },
            inlayHints = {
              enumMemberValues = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
              parameterNames = { enabled = 'literals' },
              parameterTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
              variableTypes = { enabled = false },
            },
          },
        },
      }

      local servers = {
        marksman = {},
        vtsls = vtsls,
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              format = {
                enable = true,
                defaultConfig = {
                  indent_style = 'space',
                  indent_size = '2',
                  column_width = '80', -- Fixed the typo (was column_with)
                },
              },
              workspace = {
                checkThirdParty = false,
              },
              telemetry = {
                enable = false,
              },
              diagnostics = {
                globals = { 'vim', 'nv' }, -- Recognize vim and nv globals
              },
            },
          },
          on_attach = function(client, bufnr)
            -- Use the native API directly for buffer-local commands
            vim.api.nvim_buf_create_user_command(bufnr, 'FormatLua', function()
              vim.lsp.buf.format {
                bufnr = bufnr,
                filter = function(c)
                  return c.name == 'lua_ls'
                end,
              }
            end, {})
          end,
        },
      }

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua',
      })

      require('mason-tool-installer').setup {
        ensure_installed = ensure_installed,
      }

      require('mason-lspconfig').setup {
        ensure_installed = {},
        automatic_installation = true,
        handlers = {
          function(server_name)
            local server = servers[server_name]
            local capabilities = require('blink.cmp').get_lsp_capabilities(
              vim.lsp.protocol.make_client_capabilities()
            )
            server.capabilities = vim.tbl_deep_extend(
              'force',
              {},
              capabilities,
              server.capabilities or {}
            )
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },

  -- Rest of lazy plugin configs remain the same
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
        local lsp_format_opt
        if disable_filetypes[vim.bo[bufnr].filetype] then
          lsp_format_opt = 'never'
        else
          lsp_format_opt = 'fallback'
        end
        return {
          timeout_ms = 500,
          lsp_format = lsp_format_opt,
        }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        javascript = { 'dprint' },
        typescript = { 'dprint' },
        typescriptreact = { 'dprint' },
        prisma = { 'prisma' },
        python = { 'black' },
        haskell = { 'fourmolu' },
        ocaml = { 'ocamlformat' },
        c = { 'clang-format' },
        cpp = { 'clang-format' },
        elm = { 'elm-format' },
        rust = { 'rustfmt' },
        purescript = { 'purty' },
        clojure = { 'cljstyle' },
        clojuredart = { 'cljstyle' },
        cljd = { 'cljstyle' },
        fennel = { 'fnlfmt' },
        dart = { 'dart_format' },
        rescript = { 'rescript' },
        zig = { 'zig' },
      },
      formatters = {
        prisma = {
          command = 'bun prisma format',
        },
      },
    },
  },

  {
    'saghen/blink.cmp',
    dependencies = 'rafamadriz/friendly-snippets',
    version = '*',
    opts = {
      keymap = {
        preset = 'default',
        ['<CR>'] = { 'accept', 'fallback' },
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono',
      },
      sources = {
        default = { 'lsp', 'path', 'buffer' },
      },
      fuzzy = { implementation = 'prefer_rust_with_warning' },
    },
    opts_extend = { 'sources.default' },
  },

  -- Color scheme
  {
    'f4z3r/gruvbox-material.nvim',
    name = 'gruvbox-material',
    lazy = false,
    priority = 1000,
    opts = {
      italics = false,
      contrast = 'hard',
      float = {
        force_background = true,
      },
      signs = {
        highlight = true,
      },
    },
  },

  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    priority = 1000,
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = {
        'bash',
        'c',
        'diff',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
      },
      auto_install = true,
      highlight = {
        enable = true,
      },
      indent = { enable = true, disable = { 'ruby' } },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<CR>',
          node_incremental = '<CR>',
          scope_incremental = false,
          node_decremental = '<BS>',
        },
      },
    },
  },

  -- Other plugins
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = true,
  },

  {
    'nvim-pack/nvim-spectre',
    lazy = false,
    event = 'BufRead',
    opts = {},
    keys = {
      { '<leader>sr', '<cmd>Spectre<CR>' },
    },
  },

  { 'mg979/vim-visual-multi', lazy = false },

  {
    'windwp/nvim-ts-autotag',
    opts = {
      opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = true,
      },
      per_filetype = { ['html'] = { enable_close = false } },
    },
  },

  {
    'LintaoAmons/cd-project.nvim',
    tag = 'v0.6.1',
    keys = {
      { '<leader>cd', '<cmd>CdProject<CR>' },
    },
    config = function()
      require('cd-project').setup {
        projects_config_filepath = vim.fs.normalize(
          vim.fn.stdpath 'config' .. '/cd-project.nvim.json'
        ),
        project_dir_pattern = {
          '.git',
          '.gitignore',
          'Cargo.toml',
          'package.json',
          'go.mod',
        },
        choice_format = 'both',
        projects_picker = 'vim-ui',
        auto_register_project = false,
        hooks = {
          {
            callback = function(dir)
              vim.notify('switched to dir: ' .. dir)
            end,
          },
          {
            callback = function(_)
              vim.cmd 'Telescope find_files'
            end,
          },
          {
            callback = function(dir)
              vim.notify('switched to dir: ' .. dir)
            end,
            name = 'cd hint',
            order = 1,
            pattern = 'cd-project.nvim',
            trigger_point = 'DISABLE',
            match_rule = function(dir)
              return true
            end,
          },
        },
      }
    end,
  },

  {
    'kylechui/nvim-surround',
    version = '*',
    event = 'VeryLazy',
    config = function()
      require('nvim-surround').setup {}
    end,
  },

  {
    'stevearc/oil.nvim',
    opts = {
      view_options = {
        show_hidden = true,
        icons = false,
      },
      float = {
        padding = 0,
        max_width = 30,
        max_height = 30,
      },
    },
    keys = function()
      local oil = require 'oil'
      return {
        { '<C-f><C-o>', oil.open },
        { '<leader>fo', oil.open_float },
      }
    end,
  },

  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {},
    init = function()
      local jump = require('flash').jump
      nv.map('n', 's', jump)
      nv.map('x', 's', jump)
      nv.map('o', 's', jump)
    end,
  },

  {
    'roobert/hoversplit.nvim',
    config = function()
      require('hoversplit').setup {
        key_bindings = {
          split_remain_focused = '<leader>hs',
          vsplit_remain_focused = '<leader>hv',
          split = '<leader>hS',
          vsplit = '<leader>hV',
        },
      }
    end,
  },
}, {
  ui = {},
})

-- Function to check if current file is JS or TS
local function is_js_or_ts_file()
  local extension = vim.fn.expand '%:e'
  return extension == 'js' or extension == 'ts' or extension == 'tsx'
end

-- JS/TS specific keymaps
nv.map('n', '<leader>br', function()
  if is_js_or_ts_file() then
    nv.cmd '!bun run %'
  end
end)

nv.map('n', '<leader>bt', function()
  if is_js_or_ts_file() then
    nv.cmd '!bun test %'
  end
end)

nv.create_command('CopyErrors', function()
  nv.diag.copy_to_clipboard {
    title = 'Errors from ' .. vim.fn.bufname(nv.buf()),
    empty_message = 'No errors found.',
    format = '[%d:%d] [%s] %s', -- [LINE:COL] [SEVERITY] Message
  }
end)

-- Disable semantic tokens for LSP clients on attach
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client then
      client.server_capabilities.semanticTokensProvider = nil
    end
  end,
})
