local wezterm = require("wezterm")
local act = wezterm.action

local function get_zoxide_workspaces(workspace_formatter)
	local handle = io.popen('zoxide query -l | sed -e "s|^' .. wezterm.home_dir .. '/|~/|"')
	local output = handle:read("*a")
	handle:close()

	local workspace_table = {}
	for _, workspace in ipairs(wezterm.mux.get_workspace_names()) do
		table.insert(workspace_table, {
			id = workspace,
			label = workspace_formatter(workspace),
		})
	end
	for _, path in ipairs(wezterm.split_by_newlines(output)) do
		table.insert(workspace_table, {
			id = path,
			label = path,
		})
	end
	return workspace_table
end

local function workspace_switcher(workspace_formatter)
	return wezterm.action_callback(function(window, pane)
		local workspaces = get_zoxide_workspaces(workspace_formatter)

		window:perform_action(
			act.InputSelector({
				action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
					if not id and not label then -- do nothing
					else
						local fullPath = string.gsub(label, "^~", wezterm.home_dir)
						if fullPath:sub(1, 1) == "/" then
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
							window:set_right_status(window:active_workspace())
							-- increment path score
							wezterm.run_child_process({
								"zoxide",
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
							window:set_right_status(window:active_workspace())
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

return { workspace_switcher = workspace_switcher }
