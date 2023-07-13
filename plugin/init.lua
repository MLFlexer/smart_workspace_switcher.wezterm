local wezterm = require("wezterm")

wezterm.on("smart_workspace_switcher", function(window, pane)
	local mux_window = window:mux_window()
	local tab, tab_pane, tab_window = mux_window:spawn_tab({ args = { "../script/ws.sh" } })
end)
