-- ~/.config/nvim/init.lua

----------------------------------------------------------------------
-- Leader (must be set before lazy.nvim)
----------------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

----------------------------------------------------------------------
-- LSP settings
----------------------------------------------------------------------
-- Servers to install (via mason) and enable. To add a language, add its
-- nvim-lspconfig server name here (see README), then restart nvim.
local lsp_servers = { "rust_analyzer", "pyright", "clangd" }
-- Set to false to start nvim with LSP off (toggle at runtime: <leader>l)
vim.g.lsp_enabled = true

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

  -- Persistent toggleable terminals (keys: <leader>t / <leader>T, see below)
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      size = 15,
      direction = "horizontal",
      start_in_insert = true,
      persist_mode = false,  -- don't restore Normal mode when reopening
      float_opts = { border = "curved" },
    },
  },

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

  -- Treesitter: syntax highlighting (independent of LSP). Needs gcc and
  -- tree-sitter-cli to compile parsers. Add languages to `langs` (parser
  -- names) and, if the filetype name differs, to `filetypes` too.
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local langs = {
        "python", "c", "cpp", "bash", "json", "yaml", "markdown", "latex",
        "lua", "vim", "vimdoc", "query",
      }
      require("nvim-treesitter").install(langs)

      -- Filetype names differ from parser names (sh -> bash, tex -> latex)
      local filetypes = {
        "python", "c", "cpp", "sh", "bash", "json", "yaml", "markdown",
        "tex", "lua", "vim", "help", "query",
      }
      vim.api.nvim_create_autocmd("FileType", {
        pattern = filetypes,
        callback = function() pcall(vim.treesitter.start) end,
      })
    end,
  },

  -- Completion: popup menu fed by LSP, paths, snippets and buffer words
  {
    "saghen/blink.cmp",
    version = "1.*",  -- release tags ship a prebuilt fuzzy matcher (no Rust needed)
    opts = {
      -- Tab / Shift+Tab cycle through items, Enter accepts the selected one
      -- (and is a normal newline if nothing is selected). Also: Up/Down or
      -- Ctrl+n/p select, Ctrl+e hides, Ctrl+Space opens manually.
      keymap = {
        preset = "enter",
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      },
      completion = {
        -- nothing pre-selected: the first Tab selects the first item
        list = { selection = { preselect = false, auto_insert = false } },
        documentation = { auto_show = true, auto_show_delay_ms = 300 },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        min_keyword_length = 2,  -- raise to 3 if it still pops up too eagerly
      },
      signature = { enabled = true },  -- parameter hints while typing calls
    },
  },

  -- LSP: lspconfig provides server definitions, mason installs the servers
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = lsp_servers,
        automatic_enable = false,  -- we enable servers ourselves (toggleable)
      })

      -- Tell every server what blink.cmp can handle
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      -- Per-server settings go here, e.g. lua_ls knowing about `vim`
      vim.lsp.config("lua_ls", {
        settings = { Lua = { diagnostics = { globals = { "vim" } } } },
      })

      if vim.g.lsp_enabled then vim.lsp.enable(lsp_servers) end
    end,
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

----------------------------------------------------------------------
-- Terminal
----------------------------------------------------------------------
map("n", "<leader>t", "<cmd>1ToggleTerm direction=horizontal<CR>", { desc = "Terminal (bottom)" })
map("n", "<leader>T", "<cmd>2ToggleTerm direction=float<CR>", { desc = "Terminal (float)" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Leave terminal mode" })
-- No terminal-mode Ctrl+h/j/k/l maps: the shell needs them (Ctrl+l clears, etc.).

vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.colorcolumn = ""
    vim.cmd("startinsert")
  end,
})

----------------------------------------------------------------------
-- LSP behavior
----------------------------------------------------------------------
vim.diagnostic.config({ virtual_text = true, severity_sort = true })

-- Toggle LSP on/off (stops running servers when turning off)
map("n", "<leader>l", function()
  vim.g.lsp_enabled = not vim.g.lsp_enabled
  if vim.g.lsp_enabled then
    vim.lsp.enable(lsp_servers)
  else
    vim.lsp.enable(lsp_servers, false)
    for _, c in ipairs(vim.lsp.get_clients()) do c:stop() end
  end
  vim.notify("LSP " .. (vim.g.lsp_enabled and "on" or "off"))
end, { desc = "Toggle LSP" })

-- Buffer-local keymaps + completion, set when a server attaches
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local function bmap(lhs, rhs, desc)
      map("n", lhs, rhs, { buffer = ev.buf, desc = desc })
    end
    bmap("<F2>", vim.lsp.buf.rename, "Rename symbol")
    bmap("gd", vim.lsp.buf.definition, "Go to definition")
    bmap("<leader>ca", vim.lsp.buf.code_action, "Code action")
    bmap("<leader>e", vim.diagnostic.open_float, "Line diagnostics")
  end,
})
