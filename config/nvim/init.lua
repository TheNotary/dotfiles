--[[
Cheat Sheet:

Space - e   -> Toggle Tree View
^o          -> Go to previously opened location
mf          -> Create a bookmark at the current location, useful for navigating your todo list (m = mark, f = focus)
'f          -> Go to bookmark `f`,
.           -> Repeat command

]]

vim.pack.add({
  'https://github.com/nvim-tree/nvim-tree.lua',
--  'https://github.com/nvim-mini/mini.nvim',
--  'https://github.com/nvim-treesitter/nvim-treesitter',
})


-- Space as leader
vim.g.mapleader = " "


vim.opt.expandtab = true -- Use spaces instead of actual tab characters
vim.opt.shiftwidth = 2   -- >> and << indent by 2 spaces
vim.opt.softtabstop = 2  -- <Tab>/<BS> behave like 2 spaces
vim.opt.tabstop = 2      -- Display existing literal tabs as 2 columns


-- Visually render literal tab characters
  vim.opt.list = true
  vim.opt.listchars = {
  tab = "» ",
}


-- Space + e toggles nvim-tree
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", {
  desc = "Toggle file explorer",
})




vim.opt.mouse = ""

vim.g.markdown_fenced_languages = {
  "bash",
  "sh=bash",
  "python",
  "lua",
  "json",
  "yaml",
}

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
require("nvim-tree").setup()

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


