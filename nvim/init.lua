vim.g.mapleader = " "

-- =============================================================================
-- Lazy設定
-- =============================================================================
require("config.lazy")

-- =============================================================================
-- 基本設定
-- =============================================================================

vim.opt.number = true          -- 行番号を表示
vim.opt.relativenumber = true  -- 相対行番号を表示
vim.opt.tabstop = 2            -- タブ幅を2に
vim.opt.shiftwidth = 2         -- インデント幅を2に
vim.opt.expandtab = true       -- タブをスペースに変換
vim.opt.smartindent = true     -- 賢いインデント
vim.opt.wrap = false           -- 折り返しなし
vim.opt.cursorline = true      -- カーソル行をハイライト
vim.opt.termguicolors = true   -- 256色対応
vim.opt.clipboard = "unnamedplus" -- システムクリップボードと共有
vim.opt.ignorecase = true      -- 検索で大文字小文字を無視
vim.opt.smartcase = true       -- 大文字を含む場合は区別する
vim.opt.hlsearch = true        -- 検索結果をハイライト
vim.opt.incsearch = true       -- インクリメンタルサーチ


-- =============================================================================
-- キーマップ
-- =============================================================================

vim.keymap.set('i', 'jj', '<Esc>', { desc = 'ノーマルモードに戻る' })

-- Emacs風キーバインド（インサートモード）
vim.keymap.set('i', '<C-f>', '<Right>',    { desc = '1文字右へ' })
vim.keymap.set('i', '<C-b>', '<Left>',     { desc = '1文字左へ' })
vim.keymap.set('i', '<C-n>', '<Down>',     { desc = '1行下へ' })
vim.keymap.set('i', '<C-p>', '<Up>',       { desc = '1行上へ' })
vim.keymap.set('i', '<C-a>', '<Home>',     { desc = '行頭へ' })
vim.keymap.set('i', '<C-e>', '<End>',      { desc = '行末へ' })
vim.keymap.set('i', '<C-d>', '<Del>',      { desc = '1文字削除（前方）' })
vim.keymap.set('i', '<C-k>', '<C-o>D',    { desc = '行末まで削除' })
vim.keymap.set('i', '<C-h>', '<BS>',       { desc = '1文字削除（後方）' })

-- 画面分割
vim.keymap.set("n", "ss", "<cmd>split<cr>")
vim.keymap.set("n", "sv", "<cmd>vsplit<cr>")

-- 画面移動
vim.keymap.set('n', '<C-h>', '<cmd>TmuxNavigateLeft<cr>',  { desc = 'Navigate left' })
vim.keymap.set('n', '<C-j>', '<cmd>TmuxNavigateDown<cr>',  { desc = 'Navigate down' })
vim.keymap.set('n', '<C-k>', '<cmd>TmuxNavigateUp<cr>',    { desc = 'Navigate up' })
vim.keymap.set('n', '<C-l>', '<cmd>TmuxNavigateRight<cr>', { desc = 'Navigate right' })

-- 相対パスをコピー
vim.keymap.set('n', '<leader>yr', function()
  local path = vim.fn.expand('%')
  
  -- oil://のプレフィックスを除去して相対パスに変換
  if path:match('^oil://') then
    path = path:gsub('^oil://', '')
    path = vim.fn.fnamemodify(path, ':.')
  end
  
  vim.fn.setreg('+', path)
  print('Copied relative path: ' .. path)
end, { desc = 'Copy relative path' })


