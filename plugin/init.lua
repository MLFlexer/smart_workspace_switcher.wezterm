local wezterm = require("wezterm")

wezterm.on("smart_workspace_switcher", function(window, pane)
	local mux_window = window:mux_window()
	local tab, tab_pane, tab_window = mux_window:spawn_tab({ args = { "ls | fzf" } })
	wezterm.log_info(wezterm.executable_dir)
end)

local M = {}

M.apply_to_config = function(c, opts)
	-- make the opts arg optional
	if not opts then
		opts = {}
	end
end

return M
