local wezterm = require("wezterm")
local act = wezterm.action
local zoxide_path = "zoxide"
local workspace_formatter = function(label)
	return wezterm.format({
		{ Text = "󱂬: " .. label },
	})
end

local function get_zoxide_workspaces()
	local _, stdout, _ = wezterm.run_child_process({ zoxide_path, "query", "-l" })

	local workspace_table = {}
	for _, workspace in ipairs(wezterm.mux.get_workspace_names()) do
		table.insert(workspace_table, {
			id = workspace,
			label = workspace_formatter(workspace),
		})
	end
	for _, path in ipairs(wezterm.split_by_newlines(stdout)) do
		local updated_path = string.gsub(path, wezterm.home_dir, "~")
		table.insert(workspace_table, {
			id = path,
			label = updated_path,
		})
	end
	return workspace_table
end

local function workspace_switcher()
	return wezterm.action_callback(function(window, pane)
		local workspaces = get_zoxide_workspaces()

		window:perform_action(
			act.InputSelector({
				action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
					if not id and not label then -- do nothing
					else
						local fullPath = string.gsub(label, "^~", wezterm.home_dir)
						if fullPath:sub(1, 1) == "/" or fullPath:sub(3, 3) == "\\" then
							-- if path is choosen
							inner_window:perform_action(
								act.SwitchToWorkspace({
									name = label,
									spawn = {
										label = "Workspace: " .. label,
										cwd = fullPath,
									},
								}),
								inner_pane
							)
							window:set_right_status(window:active_workspace() .. "  ")
							-- increment path score
							wezterm.run_child_process({
								zoxide_path,
								"add",
								fullPath,
							})
						else
							-- if workspace is choosen
							inner_window:perform_action(
								act.SwitchToWorkspace({
									name = id,
								}),
								inner_pane
							)
							window:set_right_status(window:active_workspace() .. "  ")
						end
					end
				end),
				title = "Choose Workspace",
				choices = workspaces,
				fuzzy = true,
			}),
			pane
		)
	end)
end

-- sets a default keybind to ALT-s
local function apply_to_config(config)
	table.insert(config.keys, {
		key = "s",
		mods = "ALT",
		action = workspace_switcher(),
	})
end

local function set_zoxide_path(path)
	zoxide_path = path
end

local function set_workspace_formatter(formatter)
	workspace_formatter = formatter
end

return {
	apply_to_config = apply_to_config,
	set_zoxide_path = set_zoxide_path,
	set_workspace_formatter = set_workspace_formatter,
	switch_workspace = workspace_switcher,
}
