
"===================通用配置======================
set encoding=utf-8

set statusline=%F%=[Line:%l/%L,Column:%c] "显示文件名、行数
"set statusline=[%F]%r%m%*%=[Line:%l/%L,Column:%c][%p%%] "显示文件名：总行数，总的字符数
set ruler "在编辑过程中，在右下角显示光标位置的状态行

" 控制
set nocompatible              "关闭vi兼容
filetype off                  "关闭文件类型侦测,vundle需要
set fileencodings=utf-8       "使用utf-8
"syntax on                     "语法高亮
set backspace=2               "退格键正常模式
"set whichwrap=<,>,[,]         "当光标到行首或行尾，允许左右方向键换行
set autoread                  "文件在vim外修改过，自动重载      
set nobackup                  "不使用备份
set confirm                   "在处理未保存或只读文件时，弹出确认消息   
set scrolloff=3               "光标移动到距离顶部或底部开始滚到距离
set history=1000              "历史记录数
set mouse=                    "关闭鼠标
set selection=inclusive       "选择包含最后一个字符
set selectmode=mouse,key      "启动选择模式的方式
"set completeopt=longest,menu  "智能补全,弹出菜单，无歧义时才自动填充
set noswapfile                "关闭交换文件
set hidden                    "允许在有未保存的修改时切换缓冲区

"set t_Co=65536                  "可以使用的颜色数目
set number                    "显示行号
set laststatus=2              "显示状态行
set ruler                     "显示标尺
set showcmd                   "显示输入的命令
set showmatch                 "高亮括号匹配
set matchtime=1               "匹配括号高亮的时间(十分之一秒)
set matchpairs={:},(:),[:],<:>        "匹配括号"{}""()"...等    
set hlsearch                  "检索时高亮匹配项
set incsearch                 "边检索边显示匹配

"格式
set noexpandtab               "不要将tab转换为空格
set shiftwidth=4              "自动缩进的距离,也是平移字符的距离
set tabstop=4                 "tab键对应的空格数
set autoindent                "自动缩进
set smartindent               "智能缩进

"===================按键映射======================

"按键映射的起始字符
let mapleader = '\'             

"使用Ctrl-l 和 Ctrl+h 切换标签页
nnoremap <C-l> gt            
nnoremap <C-h> gT
"open and close tab
nnoremap <C-n> :tabnew<CR>
nnoremap <C-k> :tabc<CR>

"===================插件配置======================

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

""配色方案
set termguicolors
set background=dark " or `'light'`
let g:everforest_background = 'medium' "Available values:   `'hard'`, `'medium'`, `'soft'`
let g:everforest_better_performance = 1
colorscheme everforest
let g:lightline = {'colorscheme' : 'everforest'}

lua <<EOF
  -- Set up nvim-cmp.
  local cmp = require'cmp'

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
  -- Set configuration for specific filetype.
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

  -- -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  -- cmp.setup.cmdline(':', {
  --   mapping = cmp.mapping.preset.cmdline(),
  --   sources = cmp.config.sources({
  --     { name = 'path' }
  --   }, {
  --     { name = 'cmdline' }
  --   }),
  --   matching = { disallow_symbol_nonprefix_matching = false }
  -- })

  -- Set up lspconfig.
  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  
  -- 定义 on_attach 函数，在这里设置 LSP 快捷键
  local on_attach = function(client, bufnr)
    local opts = { noremap=true, silent=true, buffer=bufnr }

    -- 设置快捷键 <leader>d 来跳转到定义
    vim.keymap.set('n', '<leader>d', vim.lsp.buf.definition, opts)
  end

  -- 为 rust_analyzer 设置 LSP
  require('lspconfig').rust_analyzer.setup {
    capabilities = capabilities,
    on_attach = on_attach, -- 将 on_attach 函数传递给 setup
  }
EOF

lua <<EOF
-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- empty setup using defaults
require("nvim-tree").setup()

-- OR setup with some options
require("nvim-tree").setup({
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    width = 28,
  },
  renderer = {
    group_empty = true,
    icons = {
      show = {
        file = false,          -- 不显示文件图标
        folder = false,        -- 不显示文件夹图标
        git = false,           -- 不显示 git 状态图标
      },
      glyphs = {
        folder = {
          arrow_closed = "+", -- 闭合文件夹
          arrow_open = "-",   -- 展开文件夹
        }
      }
    },
  },
  filters = {
    dotfiles = true,
  },
})
EOF


"-----NvimTree-----
nnoremap <F3> :NvimTreeToggle<CR> 
"nnoremap <Leader>o :NERDTreeFind<CR>
