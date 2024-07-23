local wezterm = require("wezterm")
local act = wezterm.action

---@alias action_callback any

---@type string
local zoxide_path = "zoxide"

---@param label string
---@return string
local workspace_formatter = function(label)
	return wezterm.format({
		{ Text = "󱂬 : " .. label },
	})
end

---@param cmd string
---@return string
local run_child_process = function(cmd)
	local is_windows = string.find(wezterm.target_triple, "windows") ~= nil
	local success, stdout, stderr
	if is_windows then
		success, stdout, stderr = wezterm.run_child_process({ "cmd", "/c", cmd })
	else
		success, stdout, stderr = wezterm.run_child_process({ os.getenv("SHELL"), "-c", cmd })
	end

	if not success then
		wezterm.log_error("Child process '" .. cmd .. "' failed with stderr: '" .. stderr .. "'")
	end
	return stdout
end

---@param extra_args? string
---@return { id: string, label: string }[]
local function get_zoxide_workspaces(extra_args)
	if extra_args == nil then
		extra_args = ""
	end
	local stdout = run_child_process(zoxide_path .. " query -l " .. extra_args)

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

---@param extra_args? string
---@return action_callback
local function workspace_switcher(extra_args)
	return wezterm.action_callback(function(window, pane)
		wezterm.emit("smart_workspace_switcher.workspace_switcher.start", window)
		local workspaces = get_zoxide_workspaces(extra_args)

		window:perform_action(
			act.InputSelector({
				action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
					if id and label then
						wezterm.emit("smart_workspace_switcher.workspace_switcher.selected", window, id, label)
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
							for _, mux_win in ipairs(wezterm.mux.all_windows()) do
								if mux_win:get_workspace() == label then
									wezterm.emit(
										"smart_workspace_switcher.workspace_switcher.created",
										mux_win,
										id,
										label
									)
								end
							end
							-- increment path score
							run_child_process(zoxide_path .. " add " .. fullPath)
						else
							-- if workspace is choosen
							inner_window:perform_action(
								act.SwitchToWorkspace({
									name = id,
								}),
								inner_pane
							)
							for _, mux_win in ipairs(wezterm.mux.all_windows()) do
								if mux_win:get_workspace() == label then
									wezterm.emit(
										"smart_workspace_switcher.workspace_switcher.chosen",
										mux_win,
										id,
										label
									)
								end
							end
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

---sets a default keybind to ALT-s
---@param config table
local function apply_to_config(config)
	table.insert(config.keys, {
		key = "s",
		mods = "ALT",
		action = workspace_switcher(),
	})
end

---@param path string
local function set_zoxide_path(path)
	zoxide_path = path
end

---@param formatter fun(label: string): string
local function set_workspace_formatter(formatter)
	workspace_formatter = formatter
end

return {
	apply_to_config = apply_to_config,
	set_zoxide_path = set_zoxide_path,
	set_workspace_formatter = set_workspace_formatter,
	switch_workspace = workspace_switcher,
}
