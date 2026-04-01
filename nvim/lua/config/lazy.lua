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
        flavour = "frappe",
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
        ["sv"] = { "actions.select_vsplit", desc = "Open in vertical split" },
        ["ss"] = { "actions.select_split", desc = "Open in horizontal split" },
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
      columns = {
        "icon",
      },
    },
    config = function(_, opts)
      require("oil").setup(opts)
      require("oil-git-status").setup()
    end,
  },

  {
    "echasnovski/mini.icons",
    lazy = false,
    config = function()
      require("mini.icons").setup()
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

  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts = {
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        -- hunk単位でstage/unstage
        vim.keymap.set('n', '<leader>hs', gs.stage_hunk,      { buffer = bufnr, desc = 'Stage hunk' })
        vim.keymap.set('n', '<leader>hu', gs.undo_stage_hunk, { buffer = bufnr, desc = 'Unstage hunk' })

        -- 選択範囲でstage/unstage
        vim.keymap.set('v', '<leader>hs', function()
          gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, { buffer = bufnr, desc = 'Stage selected hunk' })

        -- hunk間の移動
        vim.keymap.set('n', ']h', gs.next_hunk, { buffer = bufnr, desc = 'Next hunk' })
        vim.keymap.set('n', '[h', gs.prev_hunk, { buffer = bufnr, desc = 'Prev hunk' })
      end,
    },
  },

  -- インデントを可視化
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "BufReadPre",
    main = "ibl",
    opts = {
      indent = {
        char = "│",
      },
      scope = {
        show_start = false,
        show_end = false,
      },
    },
  },

  {
    "b0o/incline.nvim",
    event = "BufReadPre",
    config = function()
      local colors = {
        bg       = "#414559",
        fg       = "#c6d0f5",
        modified = "#e78284",
        icon     = "#8caaee",
      }

      require("incline").setup({
        render = function(props)
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
          if filename == "" then filename = "[No Name]" end
          local modified = vim.bo[props.buf].modified
          local icon, _ = require("mini.icons").get("file", filename)

          return {
            { icon .. " ",                     guifg = colors.icon },
            { filename,                        guifg = colors.fg },
            { modified and " ●" or "",         guifg = colors.modified },
          }
        end,
        window = {
          padding = 1,
          margin = { horizontal = 1, vertical = 1 },
          winhighlight = {
            Normal = "Normal",
            EndOfBuffer = "Normal",
          },
          zindex = 50,
        },
      })
    end,
  },

  -- モードを色で表現
  {
    "mvllow/modes.nvim",
    event = { "CursorMoved", "CursorMovedI" },
    opts = {
      colors = {
        -- Catppuccin Frappe
        copy    = "#e5c890",  -- yellow
        delete  = "#e78284",  -- red
        insert  = "#a6d189",  -- green
        visual  = "#ca9ee6",  -- mauve
      },
      line_opacity = 0.3,  -- カーソルラインの色の濃さ
    },
  },

  -- 特定キーをprefixに連続操作を可能に
  {
    "nvimtools/hydra.nvim",
    config = function()
      local Hydra = require("hydra")

      Hydra({
        name = "Window resize",
        mode = "n",
        body = "<C-w>",
        heads = {
          { "H", "<cmd>vertical resize +2<cr>" },
          { "J", "<cmd>resize +2<cr>" },
          { "K", "<cmd>resize -2<cr>" },
          { "L", "<cmd>vertical resize -2<cr>" },
        },
      })
    end,
  },

  -- 自動で括弧等を閉じてくれる
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  -- {
  --   "folke/noice.nvim",
  --   event = "VeryLazy",
  --   dependencies = {
  --     "MunifTanjim/nui.nvim",
  --     "rcarriga/nvim-notify",
  --   },
  --   opts = {
  --     lsp = {
  --       override = {
  --         ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
  --         ["vim.lsp.util.stylize_markdown"] = true,
  --         ["cmp.entry.get_docs"] = true,
  --       },
  --     },
  --     presets = {
  --       bottom_search = true,         -- 検索をボトムに表示
  --       command_palette = true,       -- コマンドパレットスタイル
  --       long_message_to_split = true, -- 長いメッセージをsplitで表示
  --       inc_rename = false,
  --     },
  --   },
  -- },

})
