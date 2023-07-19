local wezterm = require("wezterm")
local path = ""

for plugin in wezterm.plugins.list() do
	if plugin.url == "https://github.com/MLFlexer/smart_workspace_switcher.wezterm" then
		path = plugin.plugin_dir
	end
end

wezterm.on("smart_workspace_switcher", function(window, pane)
	local mux_window = window:mux_window()
	local tab, tab_pane, tab_window = mux_window:spawn_tab({ args = { path .. "/script/workspace_switcher.sh" } })
end)

local M = {}

M.apply_to_config = function(c, opts)
	-- make the opts arg optional
	if not opts then
		opts = {}
	end
end

return M
