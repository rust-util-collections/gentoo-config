"=================== General Config ======================
set encoding=utf-8

set statusline=%F%=[Line:%l/%L,Column:%c]
set ruler

" Control
set nocompatible
filetype off
set fileencodings=utf-8
set backspace=2
set autoread
set nobackup
set confirm
set scrolloff=3
set history=1000
set mouse=
set selection=inclusive
set selectmode=mouse,key
set noswapfile
set hidden

set number
set laststatus=2
set ruler
set showcmd
set showmatch
set matchtime=1
set matchpairs={:},(:),[:],<:>
set hlsearch
set incsearch

" Format
set noexpandtab
set shiftwidth=4
set tabstop=4
set autoindent
set smartindent

"=================== Key Mappings ======================

let mapleader = '\'

" Use Ctrl-l and Ctrl-h to switch tabs
nnoremap <C-l> gt            
nnoremap <C-h> gT
"open and close tab
nnoremap <C-n> :tabnew<CR>
nnoremap <C-k> :tabc<CR>

"=================== Plugins ======================

let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()

Plug 'sainnhe/everforest'

Plug 'nvim-tree/nvim-tree.lua'
Plug 'jiangmiao/auto-pairs'

Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

" For vsnip users.
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

" Treesitter for better syntax highlighting
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" For luasnip users.
" Plug 'L3MON4D3/LuaSnip'
" Plug 'saadparwaiz1/cmp_luasnip'

" For mini.snippets users.
" Plug 'echasnovski/mini.snippets'
" Plug 'abeldekat/cmp-mini-snippets'

" For ultisnips users.
" Plug 'SirVer/ultisnips'
" Plug 'quangnguyen30192/cmp-nvim-ultisnips'

" For snippy users.
" Plug 'dcampos/nvim-snippy'
" Plug 'dcampos/cmp-snippy'

call plug#end()

" Colorscheme
set termguicolors
set background=dark
let g:everforest_background = 'medium' "Available values:   `'hard'`, `'medium'`, `'soft'`
let g:everforest_better_performance = 1
try
  colorscheme everforest
catch
  colorscheme default
endtry
let g:lightline = {'colorscheme' : 'everforest'}

lua <<EOF
  -- Safe require utility to prevent crashes on first install
  local function safe_require(module)
    local status_ok, loaded_module = pcall(require, module)
    if not status_ok then
      return nil
    end
    return loaded_module
  end

  -- Set up nvim-cmp.
  local cmp = safe_require('cmp')
  if cmp then
      cmp.setup({
        snippet = {
          expand = function(args) 
            vim.fn["vsnip#anonymous"](args.body)
          end,
        },
        window = {
          documentation = false,
        },
        mapping = {
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
          ["<Tab>"] = cmp.mapping(function(fallback) 
            if cmp.visible() then
              local entries = cmp.get_entries()
              if #entries == 1 then
                cmp.confirm({ select = true })
              else
                cmp.select_next_item()
              end
            elseif vim.fn["vsnip#available"](1) == 1 then
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Plug>(vsnip-expand-or-jump)", true, true, true), "m", true)
            else
              fallback()
            end
          end, { "i", "s" }),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<C-Space>'] = cmp.mapping.complete(),
        },
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'vsnip' },
        }, {
          { name = 'buffer' },
        })
      })

      -- To use git you need to install the plugin petertriho/cmp-git and uncomment lines below
      --[[ cmp.setup.filetype('gitcommit', {
        sources = cmp.config.sources({
          { name = 'git' },
        }, {
          { name = 'buffer' },
        })
     })
     require("cmp_git").setup() ]]-- 

      -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })
  end

  -- Set up lspconfig.
  local cmp_nvim_lsp = safe_require('cmp_nvim_lsp')
  local capabilities = cmp_nvim_lsp and cmp_nvim_lsp.default_capabilities() or vim.lsp.protocol.make_client_capabilities()
  
  -- Define on_attach function to set LSP keybindings
  local on_attach = function(client, bufnr)
    local opts = { noremap=true, silent=true, buffer=bufnr }

    -- Jump to definition with ;;
    vim.keymap.set('n', ';;', vim.lsp.buf.definition, opts)
  end

  -- Configure and enable LSP servers (Nvim 0.11+ style)
  if vim.lsp.config and vim.lsp.enable then
      -- rust_analyzer
      vim.lsp.config('rust_analyzer', {
        capabilities = capabilities,
        on_attach = on_attach,
      })
      vim.lsp.enable('rust_analyzer')

      -- gopls (Go)
      vim.lsp.config('gopls', {
        capabilities = capabilities,
        on_attach = on_attach,
      })
      vim.lsp.enable('gopls')

      -- pyright (Python)
      vim.lsp.config('pyright', {
        capabilities = capabilities,
        on_attach = on_attach,
      })
      vim.lsp.enable('pyright')
  else
      -- Fallback for older Neovim versions (though this config is mainly for 0.11+)
      local lspconfig = safe_require('lspconfig')
      if lspconfig then
          lspconfig.rust_analyzer.setup {
            capabilities = capabilities,
            on_attach = on_attach,
          }
          lspconfig.gopls.setup {
            capabilities = capabilities,
            on_attach = on_attach,
          }
          lspconfig.pyright.setup {
            capabilities = capabilities,
            on_attach = on_attach,
          }
      end
  end
EOF

lua <<EOF
-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- OR setup with some options
local status_tree, nvim_tree = pcall(require, "nvim-tree")
if status_tree then
    nvim_tree.setup({
      sort = {
        sorter = "case_sensitive",
      },
      view = {
        width = 26,
        side = "left",
      },
      renderer = {
        group_empty = true,
        icons = {
          show = {
            file = false,
            folder = false,
            git = false,
          },
          glyphs = {
            folder = {
              arrow_closed = "+",
              arrow_open = "-",
            }
          }
        },
      },
      filters = {
        dotfiles = true,
      },
    })
end
EOF


"-----NvimTree-----
nnoremap <F3> :NvimTreeToggle<CR> 
"nnoremap <Leader>o :NERDTreeFind<CR>

"=================== Treesitter ======================
lua <<EOF
local status_ts, configs = pcall(require, "nvim-treesitter.configs")
if not status_ts then
    status_ts, configs = pcall(require, "nvim-treesitter.config")
end

if status_ts then
    configs.setup {
      ensure_installed = { "go", "lua", "vim", "python" },
      highlight = {
        enable = true,
      },
    }
end
EOF

"=================== Go ======================
" Auto format on save
autocmd BufWritePre *.go lua vim.lsp.buf.format({ async = true })

"=================== Python ======================
" Auto format on save
autocmd BufWritePre *.py lua vim.lsp.buf.format({ async = true })