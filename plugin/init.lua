local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

---@class module
---@field zoxide_path string
local pub = {
	zoxide_path = "zoxide",
}

local is_windows = string.find(wezterm.target_triple, "windows") ~= nil

-- TODO: fix these
---@alias action_callback any
---@alias MuxWindow any

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
	local process_args = { os.getenv("SHELL"), "-c", cmd }
	if is_windows then
		process_args = { "cmd", "/c", cmd }
	end
	local success, stdout, stderr = wezterm.run_child_process(process_args)

	if not success then
		wezterm.log_error("Child process '" .. cmd .. "' failed with stderr: '" .. stderr .. "'")
	end
	return stdout
end

---@alias InputSelector_choices { id: string, label: string }[]
---@alias workspace_ids table<string, boolean>

---@param choice_table InputSelector_choices
---@return InputSelector_choices
---@return workspace_ids
local function get_workspace_elements(choice_table)
	local workspace_ids = {}
	for _, workspace in ipairs(mux.get_workspace_names()) do
		table.insert(choice_table, {
			id = workspace,
			label = workspace_formatter(workspace),
		})
		workspace_ids[workspace] = true
	end
	return choice_table, workspace_ids
end

---@param choice_table InputSelector_choices
---@param opts? {extra_args: string?, workspace_ids: workspace_ids}
---@return InputSelector_choices
local function get_zoxide_elements(choice_table, opts)
	if opts == nil then
		opts = { extra_args = "", workspace_ids = {} }
	end

	local stdout = run_child_process(pub.zoxide_path .. " query -l " .. (opts.extra_args or ""))

	for _, path in ipairs(wezterm.split_by_newlines(stdout)) do
		local updated_path = string.gsub(path, wezterm.home_dir, "~")
		if not opts.workspace_ids[updated_path] then
			table.insert(choice_table, {
				id = path,
				label = updated_path,
			})
		end
	end
	return choice_table
end

---@param workspace string
---@return MuxWindow
local function get_current_mux_window(workspace)
	for _, mux_win in ipairs(mux.all_windows()) do
		if mux_win:get_workspace() == workspace then
			return mux_win
		end
	end
	error("Could not find a workspace with the name: " .. workspace)
end

---@generic T
---@param array T[]
---@param element T
---@return boolean
local function array_contains(array, element)
	for _, value in ipairs(array) do
		if element == value then
			return true
		end
	end
	return false
end

---@param extra_args? string
---@return action_callback
function pub.switch_workspace(extra_args)
	return wezterm.action_callback(function(window, pane)
		wezterm.emit("smart_workspace_switcher.workspace_switcher.start", window)
		local opts = { extra_args = extra_args } -- TODO: could be input instead
		local choices = {}
		choices, opts.workspace_ids = get_workspace_elements(choices)
		choices = get_zoxide_elements(choices, opts)

		window:perform_action(
			act.InputSelector({
				action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
					if id and label then
						wezterm.emit("smart_workspace_switcher.workspace_switcher.selected", window, id, label)
						if array_contains(mux.get_workspace_names(), label) then
							-- if workspace is choosen
							inner_window:perform_action(
								act.SwitchToWorkspace({
									name = id,
								}),
								inner_pane
							)
							wezterm.emit(
								"smart_workspace_switcher.workspace_switcher.chosen",
								get_current_mux_window(id),
								id,
								label
							)
						else
							-- local original_path = string.gsub(label, "^~", wezterm.home_dir) -- TODO: swithced original_path to id
							-- if path is choosen
							inner_window:perform_action(
								act.SwitchToWorkspace({
									name = label,
									spawn = {
										label = "Workspace: " .. label,
										cwd = id,
									},
								}),
								inner_pane
							)
							wezterm.emit(
								"smart_workspace_switcher.workspace_switcher.created",
								get_current_mux_window(label),
								id,
								label
							)
							-- increment path score
							run_child_process(pub.zoxide_path .. " add " .. id)
						end
					end
				end),
				title = "Choose Workspace",
				choices = choices,
				fuzzy = true,
			}),
			pane
		)
	end)
end

---sets a default keybind to ALT-s
---@param config table
function pub.apply_to_config(config)
	table.insert(config.keys, {
		key = "s",
		mods = "ALT",
		action = pub.switch_workspace(),
	})
end

---@param formatter fun(label: string): string
function pub.set_workspace_formatter(formatter)
	workspace_formatter = formatter
end

return pub
