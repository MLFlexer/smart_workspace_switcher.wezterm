local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

local is_windows = string.find(wezterm.target_triple, "windows") ~= nil

---@alias action_callback any
---@alias MuxWindow any
---@alias Pane any

---@alias workspace_ids table<string, boolean>
---@alias choice_opts {extra_args?: string, workspace_ids?: workspace_ids}
---@alias InputSelector_choices { id: string, label: string }[]

---@class public_module
---@field zoxide_path string
---@field choices {get_zoxide_elements: (fun(choices: InputSelector_choices, opts: choice_opts?): InputSelector_choices), get_workspace_elements: (fun(choices: InputSelector_choices): (InputSelector_choices, workspace_ids))}
---@field workspace_formatter fun(label: string): string
local pub = {
	zoxide_path = "zoxide",
	choices = {},
	workspace_formatter = function(label)
		return wezterm.format({
			{ Text = "󱂬 : " .. label },
		})
	end,
}

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

---@param choice_table InputSelector_choices
---@return InputSelector_choices, workspace_ids
function pub.choices.get_workspace_elements(choice_table)
	local workspace_ids = {}
	for _, workspace in ipairs(mux.get_workspace_names()) do
		table.insert(choice_table, {
			id = workspace,
			label = pub.workspace_formatter(workspace),
		})
		workspace_ids[workspace] = true
	end
	return choice_table, workspace_ids
end

---@param choice_table InputSelector_choices
---@param opts? choice_opts
---@return InputSelector_choices
function pub.choices.get_zoxide_elements(choice_table, opts)
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

---Returns choices for the InputSelector
---@param opts? choice_opts
---@return InputSelector_choices
function pub.get_choices(opts)
	if opts == nil then
		opts = { extra_args = "" }
	end
	---@type InputSelector_choices
	local choices = {}
	choices, opts.workspace_ids = pub.choices.get_workspace_elements(choices)
	choices = pub.choices.get_zoxide_elements(choices, opts)
	return choices
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

---Check if the workspace exists
---@param workspace string
---@return boolean
local function workspace_exists(workspace)
	for _, workspace_name in ipairs(mux.get_workspace_names()) do
		if workspace == workspace_name then
			return true
		end
	end
	return false
end

---InputSelector callback when zoxide supplied element is chosen
---@param window MuxWindow
---@param pane Pane
---@param path string
---@param label_path string
local function zoxide_chosen(window, pane, path, label_path)
	window:perform_action(
		act.SwitchToWorkspace({
			name = label_path,
			spawn = {
				label = "Workspace: " .. label_path,
				cwd = path,
			},
		}),
		pane
	)
	wezterm.emit(
		"smart_workspace_switcher.workspace_switcher.created",
		get_current_mux_window(label_path),
		path,
		label_path
	)
	-- increment zoxide path score
	run_child_process(pub.zoxide_path .. " add " .. path)
end

---InputSelector callback when workspace element is chosen
---@param window MuxWindow
---@param pane Pane
---@param workspace string
---@param label_workspace string
local function workspace_chosen(window, pane, workspace, label_workspace)
	window:perform_action(
		act.SwitchToWorkspace({
			name = workspace,
		}),
		pane
	)
	wezterm.emit(
		"smart_workspace_switcher.workspace_switcher.chosen",
		get_current_mux_window(workspace),
		workspace,
		label_workspace
	)
end

---@param opts? choice_opts
---@return action_callback
function pub.switch_workspace(opts)
	return wezterm.action_callback(function(window, pane)
		wezterm.emit("smart_workspace_switcher.workspace_switcher.start", window, pane)
		local choices = pub.get_choices(opts)

		window:perform_action(
			act.InputSelector({
				action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
					if id and label then
						wezterm.emit("smart_workspace_switcher.workspace_switcher.selected", window, id, label)

						if workspace_exists(id) then
							-- workspace is choosen
							workspace_chosen(inner_window, inner_pane, id, label)
						else
							-- path is choosen
							zoxide_chosen(inner_window, inner_pane, id, label)
						end
					else
						wezterm.emit("smart_workspace_switcher.workspace_switcher.canceled", window, pane)
					end
				end),
				title = "Choose Workspace",
				description = "Select a workspace and press Enter = accept, Esc = cancel, / = filter",
				fuzzy_description = "Workspace to switch: ",
				choices = choices,
				fuzzy = true,
			}),
			pane
		)
	end)
end

---sets default keybind to ALT-s
---@param config table
function pub.apply_to_config(config)
	if config then
		if not config.keys then
			config.keys = {}
		end
	else
		config = { keys = {} }
	end
	table.insert(config.keys, {
		key = "s",
		mods = "ALT",
		action = pub.switch_workspace(),
	})
end

return pub
