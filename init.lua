-- settings
vim.g.mapleader = ' '

vim.opt.fileencoding = "utf-8"
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.autoread = true
vim.opt.hidden = true
vim.opt.showcmd = true
vim.opt.clipboard = "unnamedplus"  -- clipboard のリセットと再設定
vim.opt.laststatus = 0

-- visual settings
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.smartindent = true
vim.opt.showmatch = true
vim.cmd("syntax enable")
vim.opt.background = "dark"
vim.cmd("colorscheme slate")

-- normal mode mappings
vim.keymap.set("n", "j", "gj", { noremap = true })
vim.keymap.set("n", "k", "gk", { noremap = true })
vim.keymap.set("n", "<C-h>", "gT")
vim.keymap.set("n", "<C-l>", "gt")

for i = 0, 9 do
  local file = 'in' .. i
  vim.keymap.set('n', '<Leader>' .. i, function()
    local found = false
    local tab_count = vim.fn.tabpagenr('$')

    for tab = 1, tab_count do
      local buflist = vim.fn.tabpagebuflist(tab)
      for _, bufnr in ipairs(buflist) do
        local name = vim.fn.bufname(bufnr)
        if name:match(file .. '$') then
          vim.cmd(tab .. 'tabnext')
          found = true
          break
        end
      end
      if found then break end
    end

    if not found then
      vim.cmd('tabnew ' .. file)
    end
  end, { desc = 'Open or switch to tab for ' .. file })
end

vim.keymap.set('n', '<C-w>', '<Cmd>:wq<CR>', { desc = 'Close current tab' })

-- tab settings
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2

-- search settings
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.wrapscan = true
vim.opt.hlsearch = true

-- 検索ハイライト解除のマッピング
vim.keymap.set("n", "<Esc><Esc>", ":nohlsearch<CR><Esc>:noh<CR><Esc>", { silent = true })

-- shortcut mappings (insert mode)
vim.keymap.set("i", "<>", "<><Left>", { noremap = true })
vim.keymap.set("i", "()", "()<Left>", { noremap = true })
vim.keymap.set("i", "{}", "{}<Left>", { noremap = true })
vim.keymap.set("i", "[]", "[]<Left>", { noremap = true })
vim.keymap.set("i", "\"", "\"\"<Left>", { noremap = true })
vim.keymap.set("i", "'", "''<Left>", { noremap = true })

-- window 間移動のマッピング (normal mode)
vim.keymap.set("n", ">>", "<C-w>l", { noremap = true })
vim.keymap.set("n", "<<", "<C-w>h", { noremap = true })

-- setting lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{
		"neoclide/coc.nvim",
		branch = "release",
		build = "npm install",
	}
})

-- coc.nvim settings
local keyset = vim.keymap.set
-- Autocomplete
function _G.check_back_space()
    local col = vim.fn.col('.') - 1
    return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

-- Use Tab for trigger completion with characters ahead and navigate
-- NOTE: There's always a completion item selected by default, you may want to enable
-- no select by setting `"suggest.noselect": true` in your configuration file
-- NOTE: Use command ':verbose imap <tab>' to make sure Tab is not mapped by
-- other plugins before putting this into your config
local opts = {silent = true, noremap = true, expr = true, replace_keycodes = false}
keyset("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)

-- Make <CR> to accept selected completion item or notify coc.nvim to format
-- <C-g>u breaks current undo, please make your own choice
keyset("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)

-- Use <c-j> to trigger snippets
keyset("i", "<c-j>", "<Plug>(coc-snippets-expand-jump)")
-- Use <c-space> to trigger completion
keyset("i", "<c-space>", "coc#refresh()", {silent = true, expr = true})

-- Use `[g` and `]g` to navigate diagnostics
-- Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
keyset("n", "[g", "<Plug>(coc-diagnostic-prev)", {silent = true})
keyset("n", "]g", "<Plug>(coc-diagnostic-next)", {silent = true})

-- GoTo code navigation
keyset("n", "gd", "<Plug>(coc-definition)", {silent = true})
keyset("n", "gy", "<Plug>(coc-type-definition)", {silent = true})
keyset("n", "gi", "<Plug>(coc-implementation)", {silent = true})
keyset("n", "gr", "<Plug>(coc-references)", {silent = true})


-- Use K to show documentation in preview window
function _G.show_docs()
    local cw = vim.fn.expand('<cword>')
    if vim.fn.index({'vim', 'help'}, vim.bo.filetype) >= 0 then
        vim.api.nvim_command('h ' .. cw)
    elseif vim.api.nvim_eval('coc#rpc#ready()') then
        vim.fn.CocActionAsync('doHover')
    else
        vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
    end
end
keyset("n", "K", '<CMD>lua _G.show_docs()<CR>', {silent = true})


-- Highlight the symbol and its references on a CursorHold event(cursor is idle)
vim.api.nvim_create_augroup("CocGroup", {})
vim.api.nvim_create_autocmd("CursorHold", {
    group = "CocGroup",
    command = "silent call CocActionAsync('highlight')",
    desc = "Highlight symbol under cursor on CursorHold"
})


-- Symbol renaming
keyset("n", "<leader>rn", "<Plug>(coc-rename)", {silent = true})


-- Formatting selected code
keyset("x", "<leader>f", "<Plug>(coc-format-selected)", {silent = true})
keyset("n", "<leader>f", "<Plug>(coc-format-selected)", {silent = true})


-- Setup formatexpr specified filetype(s)
vim.api.nvim_create_autocmd("FileType", {
    group = "CocGroup",
    pattern = "typescript,json",
    command = "setl formatexpr=CocAction('formatSelected')",
    desc = "Setup formatexpr specified filetype(s)."
})

-- Apply codeAction to the selected region
-- Example: `<leader>aap` for current paragraph
local opts = {silent = true, nowait = true}
keyset("x", "<leader>a", "<Plug>(coc-codeaction-selected)", opts)
keyset("n", "<leader>a", "<Plug>(coc-codeaction-selected)", opts)

-- Remap keys for apply code actions at the cursor position.
keyset("n", "<leader>ac", "<Plug>(coc-codeaction-cursor)", opts)
-- Remap keys for apply source code actions for current file.
keyset("n", "<leader>as", "<Plug>(coc-codeaction-source)", opts)
-- Apply the most preferred quickfix action on the current line.
keyset("n", "<leader>qf", "<Plug>(coc-fix-current)", opts)

-- Remap keys for apply refactor code actions.
keyset("n", "<leader>re", "<Plug>(coc-codeaction-refactor)", { silent = true })
keyset("x", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", { silent = true })
keyset("n", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", { silent = true })

-- Run the Code Lens actions on the current line
keyset("n", "<leader>cl", "<Plug>(coc-codelens-action)", opts)


-- Map function and class text objects
-- NOTE: Requires 'textDocument.documentSymbol' support from the language server
keyset("x", "if", "<Plug>(coc-funcobj-i)", opts)
keyset("o", "if", "<Plug>(coc-funcobj-i)", opts)
keyset("x", "af", "<Plug>(coc-funcobj-a)", opts)
keyset("o", "af", "<Plug>(coc-funcobj-a)", opts)
keyset("x", "ic", "<Plug>(coc-classobj-i)", opts)
keyset("o", "ic", "<Plug>(coc-classobj-i)", opts)
keyset("x", "ac", "<Plug>(coc-classobj-a)", opts)
keyset("o", "ac", "<Plug>(coc-classobj-a)", opts)


-- Remap <C-f> and <C-b> to scroll float windows/popups
---@diagnostic disable-next-line: redefined-local
local opts = {silent = true, nowait = true, expr = true}
keyset("n", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
keyset("n", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)
keyset("i", "<C-f>",
       'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"', opts)
keyset("i", "<C-b>",
       'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"', opts)
keyset("v", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
keyset("v", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)


-- Use CTRL-S for selections ranges
-- Requires 'textDocument/selectionRange' support of language server
keyset("n", "<C-s>", "<Plug>(coc-range-select)", {silent = true})
keyset("x", "<C-s>", "<Plug>(coc-range-select)", {silent = true})


-- Add `:Format` command to format current buffer
vim.api.nvim_create_user_command("Format", "call CocAction('format')", {})

-- " Add `:Fold` command to fold current buffer
vim.api.nvim_create_user_command("Fold", "call CocAction('fold', <f-args>)", {nargs = '?'})

-- Add `:OR` command for organize imports of the current buffer
vim.api.nvim_create_user_command("OR", "call CocActionAsync('runCommand', 'editor.action.organizeImport')", {})

-- Add (Neo)Vim's native statusline support
-- NOTE: Please see `:h coc-status` for integrations with external plugins that
-- provide custom statusline: lightline.vim, vim-airline
vim.opt.statusline:prepend("%{coc#status()}%{get(b:,'coc_current_function','')}")

-- Mappings for CoCList
-- code actions and coc stuff
---@diagnostic disable-next-line: redefined-local
local opts = {silent = true, nowait = true}
-- Show all diagnostics
keyset("n", "<space>a", ":<C-u>CocList diagnostics<cr>", opts)
-- Manage extensions
keyset("n", "<space>e", ":<C-u>CocList extensions<cr>", opts)
-- Show commands
keyset("n", "<space>c", ":<C-u>CocList commands<cr>", opts)
-- Find symbol of current document
keyset("n", "<space>o", ":<C-u>CocList outline<cr>", opts)
-- Search workspace symbols
keyset("n", "<space>s", ":<C-u>CocList -I symbols<cr>", opts)
-- Do default action for next item
keyset("n", "<space>j", ":<C-u>CocNext<cr>", opts)
-- Do default action for previous item
keyset("n", "<space>k", ":<C-u>CocPrev<cr>", opts)
-- Resume latest coc list
keyset("n", "<space>p", ":<C-u>CocListResume<cr>", opts)

-- color settings (ハイライトの設定)
vim.cmd("hi Normal ctermbg=none")
vim.cmd("hi NonText ctermbg=none")
vim.cmd("hi LineNr ctermbg=none")
vim.cmd("hi Folded ctermbg=none")
vim.cmd("hi EndOfBuffer ctermbg=none")
vim.cmd("hi CursorLine ctermbg=none")
vim.cmd("hi CursorLineNr ctermbg=none")
vim.cmd("hi SignColumn ctermbg=none")

-- toggle comment out
local function toggle_comment()
  local mode = vim.fn.mode()
  if mode == 'n' then
    -- ノーマルモードの処理
    local line = vim.api.nvim_get_current_line()
    if line:match('^%s*//') then
      local new_line = line:gsub('(%s*)// ?', '%1', 1)
      vim.api.nvim_set_current_line(new_line)
    else
      local new_line = line:gsub('^(%s*)', '%1// ', 1)
      vim.api.nvim_set_current_line(new_line)
    end
  elseif mode == 'V' then
    -- ビジュアルラインモードの処理
    local start_line = vim.fn.line('v')
    local end_line = vim.fn.line('.')
    if start_line > end_line then
      start_line, end_line = end_line, start_line
    end

    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

    -- 各行のコメント有無を調べる
    local has_comment = false
    local no_comment = false
    for _, line in ipairs(lines) do
      if line:match('^%s*//') then
        has_comment = true
      else
        no_comment = true
      end
    end

    local action
    if has_comment and no_comment then
      -- 混在 → 強制的にコメントアウト
      action = 'add'
    elseif has_comment and not no_comment then
      -- 全部コメントあり → 解除
      action = 'remove'
    else
      -- 全部コメントなし → 追加
      action = 'add'
    end

    for i, line in ipairs(lines) do
      if action == 'add' then
        lines[i] = line:gsub('^(%s*)', '%1// ', 1)
      elseif action == 'remove' then
        lines[i] = line:gsub('(%s*)// ?', '%1', 1)
      end
    end

    vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, lines)
  end
end

vim.keymap.set({'n', 'v'}, '<C-_>', toggle_comment, { desc = '行頭に//をトグルする' })

