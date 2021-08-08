local api = vim.api

local M = {}

local function get_color_from_hl(hl_name, fallback)
  local id = vim.api.nvim_get_hl_id_by_name(hl_name)
  if not id then return fallback end

  local foreground = vim.fn.synIDattr(id, "fg")
  if not foreground or foreground == "" then return fallback end

  return foreground
end

local function get_colors()
  return {
    red      = vim.g.terminal_color_1  or get_color_from_hl('Keyword', 'Red'),
    green    = vim.g.terminal_color_2  or get_color_from_hl('Character', 'Green'),
    yellow   = vim.g.terminal_color_3  or get_color_from_hl('PreProc', 'Yellow'),
    blue     = vim.g.terminal_color_4  or get_color_from_hl('Include', 'Blue'),
    purple   = vim.g.terminal_color_5  or get_color_from_hl('Define', 'Purple'),
    cyan     = vim.g.terminal_color_6  or get_color_from_hl('Conditional', 'Cyan'),
    dark_red = vim.g.terminal_color_9  or get_color_from_hl('Keyword', 'DarkRed'),
    orange   = vim.g.terminal_color_11 or get_color_from_hl('Number', 'Orange'),
  }
end

local function get_hl_groups()
  local colors = get_colors()

  return {
    SidebarNvimSectionTitle = { fg = colors.purple },
  }
end

local function get_links()
  return {
    SidebarNvimSectionSeperator = 'Comment',
    SidebarNvimSectionKeyword = 'Keyword',
  }
end

function M.def_hl_group(group, gui, fg, bg)
  gui = gui and ' gui='..gui or ''
  fg = fg and ' guifg='..fg or ''
  bg = bg and ' guibg='..bg or ''

  api.nvim_command('hi def '..group..gui..fg..bg)
end

function M.def_hl_link(group, link_to)
  api.nvim_command('hi def link '..group..' '..link_to)
end

function M.setup()
  local higlight_groups = get_hl_groups()
  for k, d in pairs(higlight_groups) do
    M.def_hl_group(k, d.gui, d.fg, d.bg)
  end

  local links = get_links()
  for k, d in pairs(links) do
    M.def_hl_link(k, d)
  end
end

return M
