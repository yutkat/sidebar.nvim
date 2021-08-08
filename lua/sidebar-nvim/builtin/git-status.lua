local utils = require("sidebar-nvim.utils")
local luv = vim.loop

local status = "<no changes>"
local hl = {}

local status_tmp = ""
local hl_tmp = {}

local function build_hl()
  hl_tmp = {}

  for i, _ in ipairs(vim.split(status, '\n')) do
    table.insert(hl_tmp, { 'SidebarNvimSectionKeyword', i, 0, 3 })
  end

  hl = hl_tmp
end

local function async_update()
  local stdout = luv.new_pipe(false)
  local stderr = luv.new_pipe(false)

  local handle, pid
  handle, _  = luv.spawn("git", {
    args = {"status", "--porcelain"},
    stdio = {nil, stdout, stderr},
    cwd = luv.cwd(),
  }, function(code, signal)

    if status_tmp == "" then
      status = "<no changes>"
      hl = {}
    else
      status = status_tmp
      build_hl()
    end


    luv.read_stop(stdout)
    luv.read_stop(stderr)
    luv.close(handle)
  end)

  status_tmp = ""

  luv.read_start(stdout, function(err, data)
    if data == nil then return end
    status_tmp = status_tmp .. data
  end)

  luv.read_start(stderr, function(err, data)
    if data == nil then return end
    vim.schedule_wrap(function()
      utils.echo_warning(data)
    end)
  end)

end

return {
  title = "Git Status",
  icon = "📄",
  draw = function()
    async_update()
    return {
      lines = status,
      hl = hl,
    }
  end,
}
