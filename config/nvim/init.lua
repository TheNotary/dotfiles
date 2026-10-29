--[[
Cheat Sheet:

  -- Plugin: Nvim Tree --
Space - e   -> Toggle Tree View
g?          -> Toggle Tree View hotkeys
enter       -> Open file from tree view
tab         -> Open file from tree view without focusing

  -- Plugin: telescope --
  

  -- Pane Navigation --
^w - Dir    -> Change focus to pane in specified direction
^w - w      -> Cycle through panes

  -- Find / Replace --
:v/error/d  -> Delete all lines that don't container 'error' (for light weight log grepping)

  -- Misc. Amazing --
^o          -> Go to previous location... survives restarts
mf          -> Create a bookmark at the current location, useful for navigating your todo list (m = mark, f = focus)
'f          -> Go to bookmark `f`,
.           -> Repeat command

]]

vim.pack.add({
  'https://github.com/nvim-tree/nvim-tree.lua',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/lewis6991/gitsigns.nvim',
--  'https://github.com/nvim-mini/mini.nvim',
})


-- Space as leader
vim.g.mapleader = " "

-- tab / shift + tab in normal mode switches active panes
vim.keymap.set("n", "<Tab>", "<C-w>w", {
    desc = "Next window",
})

vim.keymap.set("n", "<CR>", "<C-w>w", {
    desc = "Next window",
})




vim.opt.expandtab = true -- Use spaces instead of actual tab characters
vim.opt.shiftwidth = 2   -- >> and << indent by 2 spaces
vim.opt.softtabstop = 2  -- <Tab>/<BS> behave like 2 spaces
vim.opt.tabstop = 2      -- Display existing literal tabs as 2 columns


-- Visually render literal tab characters
vim.opt.list = true
vim.opt.listchars = {
  tab = "» ",
}


-- Define Ffs for grepping the current file for matches





vim.opt.mouse = ""


vim.cmd.colorscheme("slate")

--[[
  block comment
]]

-- vim.api.nvim_set_hl(0, "StatusLine",   { bg = "NONE" }) -- This actually just breaks coloring on the status line...

--
-- BEGIN: Setup nvim-tree
--

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

-- empty setup using defaults
-- require("nvim-tree").setup()


--------------
-- gitsigns --
--------------

local last_move = nil

local function repeatable(action, opposite, repeat_key)
  return function()
    last_move = { next = action, prev = opposite }
    vim.fn['repeat#set'](vim.keycode(repeat_key))
    action()
  end
end


require('gitsigns').setup{
  on_attach = function(bufnr)
    local gitsigns = require('gitsigns')

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    local next_hunk = repeatable(function()
      if vim.wo.diff then
        vim.cmd.normal({']c', bang = true})
      else
        gitsigns.nav_hunk('next')
      end
    end, function()
      if vim.wo.diff then
        vim.cmd.normal({'[c', bang = true})
      else
        gitsigns.nav_hunk('prev')
      end
    end, ']c')

    local prev_hunk = repeatable(function()
      if vim.wo.diff then
        vim.cmd.normal({'[c', bang = true})
      else
        gitsigns.nav_hunk('prev')
      end
    end, function()
      if vim.wo.diff then
        vim.cmd.normal({']c', bang = true})
      else
        gitsigns.nav_hunk('next')
      end
    end, '[c')

    map('n', ']c', next_hunk)
    map('n', '[c', prev_hunk)
    map('n', ';', function()
      if last_move then
        last_move.next()
      end
    end)
    map('n', ',', function()
      if last_move then
        last_move.prev()
      end
    end)

    -- Actions
    map('n', '<leader>hs', gitsigns.stage_hunk)
    map('n', '<leader>hr', gitsigns.reset_hunk)

    map('v', '<leader>hs', function()
      gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end)

    map('v', '<leader>hr', function()
      gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end)

    map('n', '<leader>hS', gitsigns.stage_buffer)
    map('n', '<leader>hR', gitsigns.reset_buffer)
    map('n', '<leader>hp', gitsigns.preview_hunk)
    map('n', '<leader>hi', gitsigns.preview_hunk_inline)

    map('n', '<leader>hb', function()
      gitsigns.blame_line({ full = true })
    end)

    map('n', '<leader>hd', gitsigns.diffthis)

    map('n', '<leader>hD', function()
      gitsigns.diffthis('~')
    end)

    map('n', '<leader>hQ', function() gitsigns.setqflist('all') end)
    map('n', '<leader>hq', gitsigns.setqflist)

    -- Toggles
    map('n', '<leader>tb', gitsigns.toggle_current_line_blame)
    map('n', '<leader>tw', gitsigns.toggle_word_diff)

    -- Text object
    map({'o', 'x'}, 'ih', gitsigns.select_hunk)
  end
}


---------------
-- nvim-tree --
---------------

-- Space + e toggles nvim-tree
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", {
  desc = "Toggle file explorer",
})

require("nvim-tree").setup({
  view = {
    adaptive_size = true, -- Auto-resize to fit file/folder names
    side = "left",        -- Position of the tree
  },
   actions = {
    open_file = {
      resize_window = true, -- Resize tree after opening a file
    },
  },
  filters = {
    exclude = { "logs" },
  },
})


----------------
-- treesitter --
----------------

require('nvim-treesitter').setup {
  -- Directory to install parsers and queries to (prepended to `runtimepath` to have priority)
  install_dir = vim.fn.stdpath('data') .. '/site'
}

require('nvim-treesitter').install { 
  'rust', 
  'javascript', 
  'zig',
  'yaml',
  'bash',
  'ruby',
  'typescript',
}


---------------
-- telescope --
---------------

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

-- END Setup nvim-tree


--
-- BEGIN: Custom Status Line configs, https://nuxsh.is-a.dev/blog/custom-nvim-statusline.html, kindly shared by nuxsh.
--

local modes = {
  ["n"] = "NORMAL",
  ["no"] = "NORMAL",
  ["v"] = "VISUAL",
  ["V"] = "VISUAL LINE",
  [""] = "VISUAL BLOCK",
  ["s"] = "SELECT",
  ["S"] = "SELECT LINE",
  [""] = "SELECT BLOCK",
  ["i"] = "INSERT",
  ["ic"] = "INSERT",
  ["R"] = "REPLACE",
  ["Rv"] = "VISUAL REPLACE",
  ["c"] = "COMMAND",
  ["cv"] = "VIM EX",
  ["ce"] = "EX",
  ["r"] = "PROMPT",
  ["rm"] = "MOAR",
  ["r?"] = "CONFIRM",
  ["!"] = "SHELL",
  ["t"] = "TERMINAL",
}

local function update_mode_colors()
  local current_mode = vim.api.nvim_get_mode().mode
  local mode_color = "%#StatusLineAccent#"
  if current_mode == "n" then
      mode_color = "%#StatuslineAccent#"
  elseif current_mode == "i" or current_mode == "ic" then
      mode_color = "%#StatuslineInsertAccent#"
  elseif current_mode == "v" or current_mode == "V" or current_mode == "" then
      mode_color = "%#StatuslineVisualAccent#"
  elseif current_mode == "R" then
      mode_color = "%#StatuslineReplaceAccent#"
  elseif current_mode == "c" then
      mode_color = "%#StatuslineCmdLineAccent#"
  elseif current_mode == "t" then
      mode_color = "%#StatuslineTerminalAccent#"
  end
  return mode_color
end

local function mode()
  local current_mode = vim.api.nvim_get_mode().mode
  return string.format(" %s ", modes[current_mode]):upper()
end


local function filepath()
  local fpath = vim.fn.fnamemodify(vim.fn.expand "%", ":~:.:h")
  if fpath == "" or fpath == "." then
      return " "
  end

  return string.format(" %%<%s/", fpath)
end

local function filename()
  local fname = vim.fn.expand "%:t"
  if fname == "" then
      return ""
  end
  return fname .. " "
end

local function lsp()
  local count = {}
  local levels = {
    errors = "Error",
    warnings = "Warn",
    info = "Info",
    hints = "Hint",
  }

  for k, level in pairs(levels) do
    count[k] = vim.tbl_count(vim.diagnostic.get(0, { severity = level }))
  end

  local errors = ""
  local warnings = ""
  local hints = ""
  local info = ""

  if count["errors"] ~= 0 then
    errors = " %#LspDiagnosticsSignError# " .. count["errors"]
  end
  if count["warnings"] ~= 0 then
    warnings = " %#LspDiagnosticsSignWarning# " .. count["warnings"]
  end
  if count["hints"] ~= 0 then
    hints = " %#LspDiagnosticsSignHint# " .. count["hints"]
  end
  if count["info"] ~= 0 then
    info = " %#LspDiagnosticsSignInformation# " .. count["info"]
  end

  return errors .. warnings .. hints .. info .. "%#Normal#"
end

local function filetype()
  return string.format(" %s ", vim.bo.filetype):upper()
end

local function lineinfo()
  if vim.bo.filetype == "alpha" then
    return ""
  end
  return " %P %l:%c "
end


Statusline = {}

Statusline.active = function()
  return table.concat {
    "%#Statusline#",
    update_mode_colors(),
    mode(),
    "%#Normal# ",
    filepath(),
    filename(),
    "%#Normal#",
    lsp(),
    "%=%#StatusLineExtra#",
    filetype(),
    lineinfo(),
  }
end

function Statusline.inactive()
  return " %F"
end

function Statusline.short()
  return "%#StatusLineNC#   NvimTree"
end


vim.api.nvim_exec([[
  augroup Statusline
  au!
  au WinEnter,BufEnter * setlocal statusline=%!v:lua.Statusline.active()
  au WinLeave,BufLeave * setlocal statusline=%!v:lua.Statusline.inactive()
  au WinEnter,BufEnter,FileType NvimTree setlocal statusline=%!v:lua.Statusline.short()
  augroup END
]], false)

