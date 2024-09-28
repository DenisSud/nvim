-- Packer plugin manager setup
vim.cmd [[packadd packer.nvim]]

require('packer').startup(function(use)
    -- Existing plugins
    use 'wbthomason/packer.nvim'
    use {
        'williamboman/mason.nvim',
        'neovim/nvim-lspconfig',
        'williamboman/mason-lspconfig.nvim'
    }
    use {
        'nvim-telescope/telescope.nvim',
        requires = { 'nvim-lua/plenary.nvim' }
    }
    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate'
    }
    use {
        'kyazdani42/nvim-tree.lua',
        requires = { 'kyazdani42/nvim-web-devicons' }
    }
    use 'kdheepak/lazygit.nvim'
    use {'neoclide/coc.nvim', branch = 'release'}
    use 'windwp/nvim-autopairs'
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-cmdline'
    use 'L3MON4D3/LuaSnip'
    use 'saadparwaiz1/cmp_luasnip'

    -- New plugins for enhanced IDE experience
    use 'nvim-lualine/lualine.nvim' -- Status line
    use 'lewis6991/gitsigns.nvim' -- Git integration
    use 'numToStr/Comment.nvim' -- Easy commenting
    use 'folke/which-key.nvim' -- Key binding helper
    use 'akinsho/bufferline.nvim' -- Buffer line
    use "lukas-reineke/indent-blankline.nvim"
    use 'goolord/alpha-nvim' -- Start screen
    use 'folke/trouble.nvim' -- Pretty diagnostics
    use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
    use({
        "kylechui/nvim-surround",
        tag = "*", -- Use for stability; omit to use `main` branch for the latest features
        config = function()
            require("nvim-surround").setup({
                -- Configuration here, or leave empty to use defaults
            })
        end
    })

    -- AI Shit
    use {
        'yetone/avante.nvim',
        -- Trigger loading the plugin on demand (optional, can be removed if you want it to load immediately)
        event = 'VeryLazy',
        -- Always load the latest version (optional, can be removed if you want stable versions)
        version = false,
        -- Any specific options you want to pass
        opts = {
            -- Add options here
        },
        -- Run `make` after installation to build the plugin
        run = 'make',
        requires = {
            { 'nvim-treesitter/nvim-treesitter' },
            { 'stevearc/dressing.nvim' },
            { 'nvim-lua/plenary.nvim' },
            { 'MunifTanjim/nui.nvim' },
            { 'nvim-tree/nvim-web-devicons', opt = true }, -- optional
            { 'zbirenbaum/copilot.lua', opt = true }, -- optional

            -- Optional dependency for image pasting
            {
                'HakonHarnes/img-clip.nvim',
                event = 'VeryLazy',
                opts = {
                    default = {
                        embed_image_as_base64 = false,
                        prompt_for_file_name = false,
                        drag_and_drop = {
                            insert_mode = true,
                        },
                        use_absolute_path = true, -- required for Windows users
                    },
                },
            },
            -- Optional dependency for markdown rendering
            {
                'MeanderingProgrammer/render-markdown.nvim',
                ft = { 'markdown', 'Avante' }, -- Load for specific file types
                opts = {
                    file_types = { 'markdown', 'Avante' },
                },
            },
        },
    }

    use {
        "supermaven-inc/supermaven-nvim",
        config = function()
            require("supermaven-nvim").setup({})
        end,
    }
end)

-- Basic settings
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.softtabstop = 4
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.wo.number = true
vim.wo.relativenumber = true
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.mouse = 'a'

-- Set leader key
vim.g.mapleader = ' '

-- Mason setup
require('mason').setup()
require('mason-lspconfig').setup({
    ensure_installed = { 'lua_ls', 'pyright', 'rust_analyzer', 'gopls', 'rnix' }
})

-- LSP setup
local lspconfig = require('lspconfig')
local mason_lspconfig = require('mason-lspconfig')

-- Automatically setup all installed servers
mason_lspconfig.setup()

local installed_servers = mason_lspconfig.get_installed_servers()

for _, server in ipairs(installed_servers) do
  lspconfig[server].setup {}
end

-- Treesitter setup
require('nvim-treesitter.configs').setup {
    ensure_installed = { 'lua', 'python', 'rust', 'nix', 'bash', 'toml', 'markdown', 'yaml', 'json' },
    highlight = { enable = true },
    indent = { enable = true }
}

-- Telescope setup
require('telescope').setup {
    extensions = {
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        }
    }
}

-- Safely load the fzf extension
pcall(require('telescope').load_extension, 'fzf')

-- nvim-tree setup
require('nvim-tree').setup {
    git = {
        enable = true,
        ignore = false,
        timeout = 500,
    }
}

-- CoC setup
vim.cmd([[
    inoremap <silent><expr> <tab> pumvisible() ? "\<C-n>" : "\<tab>"
    inoremap <silent><expr> <S-tab> pumvisible() ? "\<C-p>" : "\<C-h>"
]])

-- nvim-autopairs setup
require('nvim-autopairs').setup {}

-- Setup nvim-cmp
local cmp = require('cmp')
local npairs = require('nvim-autopairs.completion.cmp')

cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
        ['<C-e>'] = cmp.mapping.abort(),
    }),
    sources = {
        { name = "supermaven" },
        { name = 'nvim_lsp' },
        { name = 'buffer' },
        { name = 'path' },
        { name = 'luasnip' },
    },
})

cmp.event:on('confirm_done', npairs.on_confirm_done())

-- Lualine setup
require('lualine').setup {
options = {
theme = 'auto',
component_separators = '|',
section_separators = { left = '', right = '' },
},
}

-- Gitsigns setup
require('gitsigns').setup()

-- Comment.nvim setup
require('Comment').setup()

-- Which-key setup
require('which-key').setup()

-- Bufferline setup
require('bufferline').setup{}

-- Replace the old indent-blankline setup with this:
require("ibl").setup {
    indent = {
        char = "│",
        tab_char = "│",
    },
    scope = { enabled = false },
    exclude = {
        filetypes = {
            "help",
            "alpha",
            "dashboard",
            "neo-tree",
            "Trouble",
            "lazy",
            "mason",
            "notify",
            "toggleterm",
            "lazyterm",
        },
    },
}

-- Trouble setup
require('trouble').setup {}

-- Keybindings
local opts = { noremap = true, silent = true }

-- Telescope
vim.api.nvim_set_keymap('n', '<leader>ff', ':Telescope find_files<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>fg', ':Telescope live_grep<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>fb', ':Telescope buffers<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>fh', ':Telescope help_tags<CR>', opts)

-- nvim-tree
vim.api.nvim_set_keymap('n', '<leader>e', ':NvimTreeToggle<CR>', opts)

-- LazyGit
vim.api.nvim_set_keymap('n', '<leader>lg', ':LazyGit<CR>', opts)

-- Trouble
vim.api.nvim_set_keymap("n", "<leader>xx", "<cmd>Trouble<cr>", opts)
vim.api.nvim_set_keymap("n", "<leader>xw", "<cmd>Trouble workspace_diagnostics<cr>", opts)
vim.api.nvim_set_keymap("n", "<leader>xd", "<cmd>Trouble document_diagnostics<cr>", opts)

-- Bufferline
vim.api.nvim_set_keymap('n', '<TAB>', ':BufferLineCycleNext<CR>', opts)
vim.api.nvim_set_keymap('n', '<S-TAB>', ':BufferLineCyclePrev<CR>', opts)

-- LSP
vim.api.nvim_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
vim.api.nvim_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
vim.api.nvim_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)

-- Set transparent background
vim.api.nvim_set_hl(0, "Normal", { bg = "NONE", ctermbg = "NONE" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE", ctermbg = "NONE" })

