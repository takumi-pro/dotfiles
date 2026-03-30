-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    lazyrepo, lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.opt.termguicolors = true

      require("catppuccin").setup({
        flavour = "mocha",
        integrations = {
          treesitter = true,
        },
      })

      vim.cmd.colorscheme("catppuccin")
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      vim.opt.termguicolors = true

      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local ok = pcall(vim.treesitter.start, args.buf)
          if not ok then
            return
          end
          --local lang = vim.treesitter.language.get_lang(args.match)
          --if not lang then return end
          --pcall(vim.treesitter.start, args.buf, lang)
        end,
      })
    end,
  },

  {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = {
      "echasnovski/mini.icons",
      "refractalize/oil-git-status.nvim",
    },
    keys = {
      {
        "<leader>e",
        function() vim.cmd.Oil() end,
        desc = "Open file explorer",
      },
    },
    init = function()
      -- Auto open oil when opening a directory
      local oilPathPatterns = { "oil://", "oil-ssh://", "oil-trash://" }
      local path = vim.fn.expand("%:p")
      local isDir = vim.fn.isdirectory(path) == 1
      local isOilPath = vim.iter(oilPathPatterns):any(function(opp)
        return (string.find(path, opp, 1, true)) ~= nil
      end)
      if isDir or isOilPath then require("oil") end
    end,
    opts = {
      default_file_explorer = true,
      keymaps = {
        ["<C-h>"] = false,
        ["<C-l>"] = false,
        ["<C-x>"] = { "actions.select_vsplit", desc = "Open in vertical split" },
        ["<C-s>"] = { "actions.select_split", desc = "Open in horizontal split" },
        ["<C-p>"] = "actions.preview",       -- Preview file
        ["`"]     = "actions.cd",            -- Change directory
        ["g."]    = "actions.toggle_hidden", -- Toggle hidden files
      },
      view_options = {
        show_hidden = true,  -- Show hidden files by default
      },
      delete_to_trash = true,  -- Send deleted files to trash
      win_options = {
        signcolumn = "yes:2",  -- Space for git status icons
      },
    },
    config = function(_, opts)
      require("oil").setup(opts)
      require("oil-git-status").setup()
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",  -- コンパイルが必要
      },
    },
    config = function()
      local telescope = require("telescope")

      telescope.setup({
        defaults = {
          mappings = {
            i = {
              ["<C-j>"] = "move_selection_next",
              ["<C-k>"] = "move_selection_previous",
              ["<C-d>"] = "preview_scrolling_down",
              ["<C-u>"] = "preview_scrolling_up",
              ["<C-v>"] = "select_vertical",
              ["<C-s>"] = "select_horizontal",
              ["<Esc>"] = "close",         
            },
          }
        },
        extensions = {
          fzf = {
            fuzzy = true,                   -- Fuzzy search on
            override_generic_sorter = true, -- Replace default sorter
            override_file_sorter = true,    -- Replace file sorter
            case_mode = "smart_case",       -- Smart case matching
          },
        },
      })

      -- Load the extension
      telescope.load_extension("fzf")

      -- Keymaps
      local builtin = require("telescope.builtin")
      vim.keymap.set('n', '<leader>ff', builtin.find_files,  { desc = 'Find files' })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep,   { desc = 'Live grep' })
      vim.keymap.set('n', '<leader>fb', builtin.buffers,     { desc = 'List buffers' })
      vim.keymap.set('n', '<leader>fr', builtin.oldfiles,    { desc = 'Recent files' })
    end,
  },

  {
    "ahmedkhalf/project.nvim",
    event = "VeryLazy",
    config = function()
      require("project_nvim").setup({
        patterns = {
          -- git
          ".git",
          -- shell
          "Makefile",
          -- node
          "package.json",
          "tsconfig.json",
          "node_modules",
          -- lua
          "stylua.toml",
          ".stylua.toml",
          -- go
          "go.mod",
          -- python
          "pyproject.toml",
          ".venv",
        },
      })

      -- Integrate with telescope
      require("telescope").load_extension("projects")

      -- Open project list with telescope
      vim.keymap.set("n", "<leader>fp", function()
        require("telescope").extensions.projects.projects()
      end, { desc = "Find projects" })
    end,
  },

  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewFileHistory",
    },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>",        desc = "Open diffview" },
      { "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "File history" },
      { "<leader>gx", "<cmd>DiffviewClose<cr>",       desc = "Close diffview" },
    },
    opts = {},
  },

  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
    },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>",  desc = "Navigate left" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>",  desc = "Navigate down" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>",    desc = "Navigate up" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Navigate right" },
    },
  },
})
