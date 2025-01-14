local lib = require('sidebar-nvim.lib')
local colors = require('sidebar-nvim.colors')
local renderer = require('sidebar-nvim.renderer')
local view = require('sidebar-nvim.view')
local updater = require('sidebar-nvim.updater')
local config = require("sidebar-nvim.config")
local bindings = require("sidebar-nvim.bindings")

local api = vim.api

local M = {open_on_start = false}

function M.setup(opts)
    opts = opts or {}

    for key, value in pairs(opts) do
        if key == 'open' then
            M.open_on_start = value
        else
            config[key] = value
        end
    end
end

function M._vim_leave() lib.destroy() end

function M._vim_enter()
    view._wipe_rogue_buffer()

    colors.setup()
    bindings.setup()
    view.setup()

    updater.setup()
    lib.setup()

    if M.open_on_start then M._internal_open() end
end

function M.toggle()
    if view.win_open() then
        view.close()
    else
        lib.open()
    end
end

function M.close()
    if view.win_open() then
        view.close()
        return true
    end
end

function M._internal_open(opts) if not view.win_open() then lib.open(opts) end end

function M.open() M._internal_open() end

function M._on_tab_change()
    vim.schedule(function()
        if not view.win_open() and view.win_open({any_tabpage = true}) then view.open({focus = false}) end
    end)
end

function M.on_keypress(key) lib.on_keypress(key) end

function M.update() lib.update() end

function M.resize(size)
    view.View.width = size
    view.resize()
end

function M._on_win_leave()
    vim.defer_fn(function()
        if not view.win_open() then return end

        local windows = api.nvim_list_wins()
        local curtab = api.nvim_get_current_tabpage()
        local wins_in_tabpage = vim.tbl_filter(function(w) return api.nvim_win_get_tabpage(w) == curtab end, windows)
        if #windows == 1 then
            api.nvim_command(':silent qa!')
        elseif #wins_in_tabpage == 1 then
            api.nvim_command(':tabclose')
        end
    end, 50)
end

function M.reset_highlight()
    colors.setup()
    renderer.render_hl(view.View.bufnr)
end

function M._on_cursor_move(direction) lib.on_cursor_move(direction) end

return M
