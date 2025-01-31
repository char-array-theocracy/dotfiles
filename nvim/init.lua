-- Initialize Plug for plugin management
vim.cmd([[
call plug#begin()
  Plug 'preservim/nerdtree'
  Plug 'xiyaowong/transparent.nvim'
  Plug 'itchyny/lightline.vim'
  Plug 'ziglang/zig.vim'
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  Plug 'nvim-telescope/telescope.nvim'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'neovim/nvim-lspconfig'
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
call plug#end()
]])

-- General settings
vim.g.mapleader = " "
vim.o.showmatch = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.mouse = "a"
vim.o.hlsearch = true
vim.o.incsearch = true
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.wildmode = "longest,list"
vim.o.clipboard = "unnamedplus"
vim.o.cursorline = true
vim.o.termguicolors = true
vim.o.swapfile = false
vim.o.backup = false
vim.o.undodir = os.getenv("HOME") .. "/.config/nvim/undodir"
vim.o.undofile = true
vim.o.updatetime = 300
vim.o.signcolumn = "yes"


vim.g.clipboard = {
    copy = {
        ['+'] = {'wl-copy'},
        ['*'] = {'wl-copy'}
    },
    paste = {
        ['+'] = {'wl-paste'},
        ['*'] = {'wl-paste'}
    }
}


-- Enable filetype plugin and indent
vim.cmd('filetype plugin indent on')
vim.cmd('syntax on')

-- Set colorscheme to Ayu
vim.g.ayucolor = "dark"
vim.o.background = "dark"
vim.cmd.colorscheme "tempus_future"

-- Lightline configuration
vim.g.lightline = { colorscheme = 'one' }

-- Disable Zig autosave formatting
vim.g.zig_fmt_autosave = 0

-- Keybindings
vim.api.nvim_set_keymap('n', '<leader>t', ':NERDTreeToggle<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>n', ':NERDTreeFocus<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>e', ':TransparentToggle<CR>', { noremap = true, silent = true })

-- Cursor settings for foot terminal
vim.o.guicursor = "n-v-c:block,i:ver25"

-- Enable true colors
vim.o.termguicolors = true

-- NERDTree auto-open and auto-close
vim.cmd([[
autocmd vimenter * if !argc() | NERDTree | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | quit | endif
]])

-- Remap space as leader key
vim.api.nvim_set_keymap('', '<Space>', '<Nop>', { noremap = true, silent = true })

-- Telescope
vim.api.nvim_set_keymap('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { noremap = true, silent = true })

-- Better window navigation
vim.api.nvim_set_keymap('n', '<C-h>', '<C-w>h', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-j>', '<C-w>j', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-k>', '<C-w>k', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-l>', '<C-w>l', { noremap = true })

-- Better indenting
vim.api.nvim_set_keymap('v', '<', '<gv', { noremap = true })
vim.api.nvim_set_keymap('v', '>', '>gv', { noremap = true })

-- Move selected line / block of text in visual mode
vim.api.nvim_set_keymap('x', 'K', ":move '<-2<CR>gv-gv", { noremap = true, silent = true })
vim.api.nvim_set_keymap('x', 'J', ":move '>+1<CR>gv-gv", { noremap = true, silent = true })

-- CoC.nvim mappings
vim.api.nvim_set_keymap('n', 'gd', '<Plug>(coc-definition)', {})
vim.api.nvim_set_keymap('n', 'gy', '<Plug>(coc-type-definition)', {})
vim.api.nvim_set_keymap('n', 'gi', '<Plug>(coc-implementation)', {})
vim.api.nvim_set_keymap('n', 'gr', '<Plug>(coc-references)', {})

-- Autocomplete
vim.cmd([[
inoremap <silent><expr> <C-Space> coc#refresh()
]])

-- Use K to show documentation in preview window
vim.cmd([[
nnoremap <silent> K :call ShowDocumentation()<CR>
function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction
]])

-- Set up clangd for ESP-IDF with LSP
require'lspconfig'.clangd.setup{
    cmd = { "clangd", "--compile-commands-dir=build" },
    root_dir = require'lspconfig'.util.root_pattern("CMakeLists.txt", ".git"),
}

