local wezterm = require("wezterm")
local path = ""

for _, plugin in ipairs(wezterm.plugin.list()) do
	if plugin.url == "https://github.com/MLFlexer/smart_workspace_switcher.wezterm" then
		path = plugin.plugin_dir .. "/script/workspace_switcher.sh"
	end
end

wezterm.on("smart_workspace_switcher", function(window, pane)
	if path == "" then
		wezterm.log_error("workspace_switcher.sh not found")
		return
	end
	local current_tab_id = pane:tab():tab_id()
	local tab, _, _ = window:mux_window():spawn_tab({ args = { path, "--tab-id", tostring(current_tab_id) } })
	tab:set_title(wezterm.nerdfonts.md_dock_window .. " Workspace Switcher")
end)

local M = {}

M.apply_to_config = function(c, opts)
	-- make the opts arg optional
	if not opts then
		opts = {}
	end
end

return M
