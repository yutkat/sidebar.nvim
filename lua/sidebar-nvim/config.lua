local M = {}

M.disable_default_keybindings = 0
M.bindings = nil
M.side = "left"
M.initial_width = 35

M.update_interval = 1000

M.sections = {"datetime", "git-status", "lsp-diagnostics", "containers"}

M.section_separator = "-----"

M.docker = {use_podman = false, attach_shell = "/bin/sh", show_all = true}

return M
