vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true
vim.opt.breakindent = true
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.hlsearch = false
vim.opt.ignorecase = true
vim.opt.inccommand = 'split'
vim.opt.mouse = 'a'
-- vim.opt.number = true
-- vim.opt.relativenumber = true
vim.opt.shiftwidth = 2
vim.opt.title = true
vim.opt.showmode = false
vim.opt.smartcase = true
vim.opt.softtabstop = 2
vim.opt.splitbelow = true
vim.opt.signcolumn = 'yes'
vim.opt.splitright = true
vim.opt.swapfile = false
vim.opt.tabstop = 2
vim.opt.termguicolors = true
vim.opt.timeoutlen = 300
vim.opt.undofile = true
vim.opt.updatetime = 250
vim.opt.wrap = false
vim.opt.laststatus = 0
vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.cmdheight = 0
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)
vim.opt.timeoutlen = 300
vim.opt.list = false

vim.opt.scrolloff = 5

local set_keymaps = function(keymaps)
  for _, keymap in ipairs(keymaps) do
    vim.keymap.set(keymap[1], keymap[2], keymap[3], {
      silent = true,
      remap = true,
    })
  end
end

set_keymaps {
  { 'n', '<Esc>', '<cmd>nohlsearch<CR>' },
  { 'n', '<leader>oi', '<cmd>TSToolsOrganizeImports<CR>' },
  { 'n', '<C-v>c', '<cmd>e $MYVIMRC<CR>' },
  { 'n', 'L', '<cmd>:bn<cr>' },
  { 'n', 'H', '<cmd>:bp<cr>' },
  { 'n', '<C-d>', '<C-d>zz' },
  { 'n', '<C-u>', '<C-u>zz' },
  { 'n', 'n', 'nzz' },
  { 'n', 'N', 'Nzz' },
  { 'n', '[d', vim.diagnostic.goto_prev },
  { 'n', ']d', vim.diagnostic.goto_next },
  {
    'n',
    '<leader>rb',
    function()
      vim.cmd [[ !bun run % ]]
    end,
  },
  {
    'n',
    '<leader>q',
    vim.diagnostic.setloclist,
    { desc = 'Open diagnostic [Q]uickfix list' },
  },
  {
    'n',
    '<Esc><Esc>',
    '<C-\\><C-n>',
  },
}

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

  {
    'supermaven-inc/supermaven-nvim',
    config = function()
      require('supermaven-nvim').setup {}
    end,
  },

  {
    'marilari88/twoslash-queries.nvim',
    config = function()
      require('twoslash-queries').setup {
        multi_line = true, -- to print types in multi line mode
        is_enabled = true, -- to keep disabled at startup and enable it on request with the TwoslashQueriesEnable
        highlight = 'Type', -- to set up a highlight group for the virtual text
      }
    end,
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
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>fW', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>fw', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      vim.keymap.set('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
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
      -- 'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
        end,
      })

      local signs = { ERROR = '', WARN = '', INFO = '', HINT = '' }
      local diagnostic_signs = {}
      for type, icon in pairs(signs) do
        diagnostic_signs[vim.diagnostic.severity[type]] = icon
      end
      vim.diagnostic.config { signs = { text = diagnostic_signs } }

      -- local capabilities = vim.lsp.protocol.make_client_capabilities()
      -- capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
      capabilities = require('blink.cmp').get_lsp_capabilities(vim.lsp.protocol.make_client_capabilities())

      local servers = {
        marksman = {},
        ocamllsp = {},
        vtsls = {},
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
            },
          },
        },
      }

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      ---@diagnostic disable-next-line: missing-fields
      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },

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
    -- optional: provides snippets for the snippet source
    dependencies = 'rafamadriz/friendly-snippets',

    -- use a release tag to download pre-built binaries
    version = '*',
    -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    -- build = 'cargo build --release',
    -- If you use nix, you can build from source using latest nightly rust with:
    -- build = 'nix run .#build-plugin',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept, C-n/C-p for up/down)
      -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys for up/down)
      -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
      --
      -- All presets have the following mappings:
      -- C-space: Open menu or open docs if already open
      -- C-e: Hide menu
      -- C-k: Toggle signature help
      --
      -- See the full "keymap" documentation for information on defining your own keymap.
      keymap = {
        preset = 'default',

        ['<CR>'] = { 'accept', 'fallback' },
      },

      appearance = {
        -- Sets the fallback highlight groups to nvim-cmp's highlight groups
        -- Useful for when your theme doesn't support blink.cmp
        -- Will be removed in a future release
        use_nvim_cmp_as_default = true,
        -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono',
      },

      -- Default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      sources = {
        default = { 'lsp', 'path', 'buffer' },
      },

      -- Blink.cmp uses a Rust fuzzy matcher by default for typo resistance and significantly better performance
      -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
      -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
      --
      -- See the fuzzy documentation for more information
      fuzzy = { implementation = 'prefer_rust_with_warning' },
    },
    opts_extend = { 'sources.default' },
  },

  -- {
  --   'hrsh7th/nvim-cmp',
  --   event = 'InsertEnter',
  --   dependencies = {
  --     {
  --       'L3MON4D3/LuaSnip',
  --       build = (function()
  --         if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
  --           return
  --         end
  --         return 'make install_jsregexp'
  --       end)(),
  --       dependencies = {},
  --     },
  --     'saadparwaiz1/cmp_luasnip',
  --     'hrsh7th/cmp-nvim-lsp',
  --     'hrsh7th/cmp-path',
  --   },
  --   config = function()
  --     local cmp = require 'cmp'
  --     local luasnip = require 'luasnip'
  --     luasnip.config.setup {}
  --
  --     cmp.setup {
  --       snippet = {
  --         expand = function(args)
  --           luasnip.lsp_expand(args.body)
  --         end,
  --       },
  --
  --       completion = { completeopt = 'menu,menuone,noinsert', autocomplete = false },
  --
  --       mapping = cmp.mapping.preset.insert {
  --         ['<C-n>'] = cmp.mapping.select_next_item(),
  --         ['<C-p>'] = cmp.mapping.select_prev_item(),
  --         ['<C-b>'] = cmp.mapping.scroll_docs(-4),
  --         ['<C-f>'] = cmp.mapping.scroll_docs(4),
  --         ['<Cr>'] = cmp.mapping.confirm { select = true },
  --         ['<C-Space>'] = cmp.mapping.complete {},
  --         ['<C-l>'] = cmp.mapping(function()
  --           if luasnip.expand_or_locally_jumpable() then
  --             luasnip.expand_or_jump()
  --           end
  --         end, { 'i', 's' }),
  --         ['<C-h>'] = cmp.mapping(function()
  --           if luasnip.locally_jumpable(-1) then
  --             luasnip.jump(-1)
  --           end
  --         end, { 'i', 's' }),
  --       },
  --       sources = {
  --         {
  --           name = 'lazydev',
  --           group_index = 0,
  --         },
  --         { name = 'nvim_lsp' },
  --         { name = 'luasnip' },
  --         { name = 'path' },
  --       },
  --     }
  --   end,
  -- },

  {
    'f4z3r/gruvbox-material.nvim',
    name = 'gruvbox-material',
    lazy = false,
    priority = 1000,
    opts = {
      italics = false, -- enable italics in general
      contrast = 'hard', -- set contrast, can be any of "hard", "medium", "soft"
      float = {
        force_background = true, -- force background on floats even when background.transparent is set
        background_color = nil, -- set color for float backgrounds. If nil, uses the default color set
        -- by the color scheme
      },
      signs = {
        highlight = true, -- whether to highlight signs
      },
      customize = nil, -- customize the theme in any way you desire, see below what this
      -- configuration accepts
    },
  },

  -- {
  --   'loctvl842/monokai-pro.nvim',
  --   priority = 1000,
  --   opts = {
  --     styles = {
  --       comment = { italic = false },
  --       keyword = { italic = false }, -- any other keyword
  --       type = { italic = false }, -- (preferred) int, long, char, etc
  --       storageclass = { italic = false }, -- static, register, volatile, etc
  --       structure = { italic = false }, -- struct, union, enum, etc
  --       parameter = { italic = false }, -- parameter pass in function
  --       annotation = { italic = false },
  --       tag_attribute = { italic = false }, -- attribute of tag in reactjs
  --     },
  --     filter = 'pro', -- classic | octagon | pro | machine | ristretto | spectrum
  --   },
  --   config = function()
  --     -- require('monokai-pro').setup()
  --     vim.cmd.colorscheme 'monokai-pro'
  --   end,
  -- },

  -- {
  --
  --
  --
  --   'rose-pine/neovim',
  --   priority = 1000,
  --   opts = {
  --     styles = {
  --       bold = false,
  --       italic = false,
  --       transparency = false,
  --     },
  --   },
  --   config = function()
  --     vim.cmd.colorscheme 'rose-pine'
  --   end,
  -- },

  -- {
  --   'navarasu/onedark.nvim',
  --   priority = 1000,
  --   opts = {
  --     style = 'cool', -- Default theme style. Choose between 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer' and 'light'
  --   },
  --   config = function()
  --     vim.cmd.colorscheme 'onedark'
  --   end,
  -- },

  -- {
  --   'nvim-lualine/lualine.nvim',
  --   dependencies = { 'nvim-tree/nvim-web-devicons' },
  --   opts = {},
  -- },

  {
    'nvim-treesitter/nvim-treesitter',
    priority = 1000,
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts

    opts = {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },

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
      opts = { enable_close = true, enable_rename = true, enable_close_on_slash = true },
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
        projects_config_filepath = vim.fs.normalize(vim.fn.stdpath 'config' .. '/cd-project.nvim.json'),
        project_dir_pattern = { '.git', '.gitignore', 'Cargo.toml', 'package.json', 'go.mod' },
        choice_format = 'both', -- optional, you can switch to "name" or "path"
        projects_picker = 'vim-ui', -- optional, you can switch to `telescope`
        auto_register_project = false, -- optional, toggle on/off the auto add project behaviour
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
            end, -- required, action when trigger the hook
            name = 'cd hint', -- optional
            order = 1, -- optional, the exection order if there're multiple hooks to be trigger at one point
            pattern = 'cd-project.nvim', -- optional, trigger hook if contains pattern
            trigger_point = 'DISABLE', -- optional, enum of trigger_points, default to `AFTER_CD`
            match_rule = function(dir) -- optional, a function return bool. if have this fields, then pattern will be ignored
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
      vim.keymap.set('n', 's', jump)
      vim.keymap.set('x', 's', jump)
      vim.keymap.set('o', 's', jump)
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

local function is_js_or_ts_file()
  local extension = vim.fn.expand '%:e'
  return extension == 'js' or extension == 'ts' or extension == 'tsx'
end

vim.keymap.set('n', '<leader>br', function()
  if is_js_or_ts_file() then
    vim.cmd '!bun run %'
  end
end, { silent = true })

vim.keymap.set('n', '<leader>bt', function()
  if is_js_or_ts_file() then
    vim.cmd '!bun test %'
  end
end, { silent = true })

vim.keymap.set('n', 'q', '<Nop>', { noremap = true })

-- Function to collect all diagnostic errors and copy them to clipboard
local function copy_errors_to_clipboard()
  -- Get the current buffer number
  local current_buf = vim.api.nvim_get_current_buf()

  -- Get all diagnostics for the current buffer
  local diagnostics = vim.diagnostic.get(current_buf)

  -- Format each diagnostic into readable lines
  local lines = {}
  table.insert(lines, '# Errors from ' .. vim.fn.bufname(current_buf))
  table.insert(lines, '')

  if #diagnostics == 0 then
    table.insert(lines, 'No errors found.')
  else
    for i, diag in ipairs(diagnostics) do
      local severity = vim.diagnostic.severity[diag.severity] or 'UNKNOWN'
      local line_num = diag.lnum + 1 -- Convert to 1-based line numbering
      local col_num = diag.col + 1 -- Convert to 1-based column numbering
      local message = diag.message:gsub('\n', ' ') -- Replace any newlines in the message

      -- Format: [LINE:COL] [SEVERITY] Message
      table.insert(lines, string.format('[%d:%d] [%s] %s', line_num, col_num, severity, message))
    end
  end

  -- Join all lines with newline characters
  local error_text = table.concat(lines, '\n')

  -- Copy to clipboard
  vim.fn.setreg('+', error_text) -- Copy to system clipboard
  vim.fn.setreg('"', error_text) -- Copy to unnamed register

  -- Notify the user
  local count = #diagnostics
  local message = count .. ' error' .. (count == 1 and '' or 's') .. ' copied to clipboard'
  vim.notify(message, vim.log.levels.INFO)
end

-- Register the command
vim.api.nvim_create_user_command('CopyErrors', function()
  copy_errors_to_clipboard()
end, {})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    -- Disable semantic tokens for the attached LSP client
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client then
      client.server_capabilities.semanticTokensProvider = nil
    end
  end,
})
