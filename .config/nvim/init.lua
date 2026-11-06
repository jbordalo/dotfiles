-- ~/.config/nvim/init.lua

----------------------------------------------------------------------
-- Leader (must be set before lazy.nvim)
----------------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

----------------------------------------------------------------------
-- Options
----------------------------------------------------------------------
local o = vim.opt

o.showmatch = true
o.ignorecase = true
o.smartcase = true            -- case-sensitive if search has uppercase
o.hlsearch = true
o.incsearch = true
o.wrap = true                 -- soft-wrap long lines (toggle: <leader>w)
o.linebreak = true            -- wrap at word boundaries
o.breakindent = true          -- wrapped lines keep their indentation
o.showbreak = "↪ "            -- marker on wrapped continuation lines
o.number = true
o.colorcolumn = "80"
o.termguicolors = true
o.mouse = "a"
o.clipboard = "unnamedplus"
o.wildmode = "longest,list"
o.undofile = true             -- stored in stdpath("state")/undo
o.scrolloff = 5
o.signcolumn = "yes"
o.splitright = true
o.splitbelow = true
o.updatetime = 250

-- Indentation
o.tabstop = 4
o.softtabstop = 4
o.shiftwidth = 4
o.expandtab = true
o.autoindent = true
o.smartindent = true

-- Shift+arrows/Home/End start a selection (no "stopsel": it would make plain
-- arrows cancel Visual mode, breaking v + arrows; use Esc to deselect)
o.keymodel = "startsel"
o.whichwrap:append("<,>,[,],h,l")

----------------------------------------------------------------------
-- Plugins (lazy.nvim)
----------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
    local langs = { "python", "c", "bash", "json", "yaml", "markdown", "latex" }
    require("nvim-treesitter").install(langs)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = langs,
      callback = function() pcall(vim.treesitter.start) end,
    })
   end,
  },
  -- Colorscheme
  {
    "shaunsingh/nord.nvim",
    lazy = false,
    priority = 1000,
    config = function() vim.cmd.colorscheme("nord") end,
  },

  -- Auto-close brackets/quotes
  {
    "m4xshen/autoclose.nvim",
    event = "InsertEnter",
    opts = { options = { disable_when_touch = true } },
  },

  -- File explorer sidebar
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      require("nvim-tree").setup({
        view = { width = 32 },
        update_focused_file = { enable = true },
      })
    end,
  },

  -- Fuzzy finder (install ripgrep for live_grep)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { options = { theme = "nord" } },
  },

  -- Shows available keybindings as you type
  { "folke/which-key.nvim", event = "VeryLazy", opts = {} },

  -- Renders Markdown in the buffer (headings, code blocks, tables, checkboxes)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    ft = { "markdown" },   -- lazy-load only for markdown files
    opts = {},             -- passed to require("render-markdown").setup({})
    keys = {
      { "<leader>m", "<cmd>RenderMarkdown toggle<CR>", desc = "Toggle markdown render" },
    },
  },
}, {
  -- lazy.nvim resets runtimepath; keep the distro's bundled parsers visible
  performance = {
    rtp = { paths = { "/usr/lib/nvim", "/usr/lib64/nvim" } },
  },
})

----------------------------------------------------------------------
-- Keymaps
----------------------------------------------------------------------
local map = vim.keymap.set

-- Files / search
map("n", "<C-b>", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file tree" })
map("n", "<C-p>", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Grep project" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Buffers" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>", { desc = "Recent files" })
map("n", "<leader>h", "<cmd>nohlsearch<CR>", { desc = "Clear highlight" })

-- Save
map("n", "<C-s>", "<cmd>w<CR>")
map("i", "<C-s>", "<Esc><cmd>w<CR>gi")

-- Move lines with Alt+Up/Down
map("n", "<A-Up>", "<cmd>m .-2<CR>==")
map("n", "<A-Down>", "<cmd>m .+1<CR>==")
map("i", "<A-Up>", "<Esc><cmd>m .-2<CR>==gi")
map("i", "<A-Down>", "<Esc><cmd>m .+1<CR>==gi")
map("v", "<A-Up>", ":m '<-2<CR>gv=gv", { silent = true })
map("v", "<A-Down>", ":m '>+1<CR>gv=gv", { silent = true })

-- Shift+Tab to dedent
map("n", "<S-Tab>", "<<")
map("i", "<S-Tab>", "<C-d>")

-- Ctrl+Shift+Left/Right: select by word (needs terminal support)
map("n", "<C-S-Left>", "vb")
map("n", "<C-S-Right>", "ve")
map("i", "<C-S-Left>", "<C-o>vb")
map("i", "<C-S-Right>", "<C-o>ve")
map("v", "<C-S-Left>", "b")
map("v", "<C-S-Right>", "e")

-- Ctrl+Backspace deletes previous word in insert mode
map("i", "<C-BS>", "<C-w>")

-- Ctrl+w deletes previous word in normal mode too (window cmds unused: tmux splits)
map("n", "<C-w>", "db")

-- Disable accidental macro recording / Ex mode (macros still on <leader>q)
map("n", "q", "<Nop>")
map("n", "<leader>q", "q", { desc = "Record macro" })
map("n", "Q", "<Nop>")

-- Move by visual (wrapped) lines; counts like 5j still use real lines
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true })
map("i", "<Down>", "<C-o>gj")
map("i", "<Up>", "<C-o>gk")

-- Toggle soft wrap
map("n", "<leader>w", "<cmd>set wrap!<CR>", { desc = "Toggle wrap" })

-- Window navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

----------------------------------------------------------------------
-- Terminal
----------------------------------------------------------------------
map("n", "<leader>t", "<cmd>botright split | terminal<CR>", { desc = "Terminal" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Leave terminal mode" })
map("t", "<C-h>", "<C-\\><C-n><C-w>h")
map("t", "<C-j>", "<C-\\><C-n><C-w>j")
map("t", "<C-k>", "<C-\\><C-n><C-w>k")
map("t", "<C-l>", "<C-\\><C-n><C-w>l")

vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.colorcolumn = ""
    vim.cmd("startinsert")
  end,
})
