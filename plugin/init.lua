local wezterm = require("wezterm")
local path = ""

wezterm.log_info(wezterm.plugin.list())
for _, plugin in ipairs(wezterm.plugin.list()) do
	if plugin.url == "https://github.com/MLFlexer/smart_workspace_switcher.wezterm" then
		path = plugin.plugin_dir
	end
end

wezterm.on("smart_workspace_switcher", function(window, pane)
	if path == "" then
		wezterm.log_error("path is empty")
		return
	end
	local current_tab_id = pane:tab():tab_id()
	local cmd = path
		.. "/script/workspace_switcher.sh "
		.. "; wezterm cli activate-tab --tab-id "
		.. current_tab_id
		.. " ; exit\n"
	local tab, tab_pane, tab_window = window:mux_window():spawn_tab({})
	tab_pane:send_text(cmd)
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
