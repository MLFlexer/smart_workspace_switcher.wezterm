# smart_workspace_switcher.wezterm
A smart wezterm workspace switcher inspired by [joshmedeski/t-smart-tmux-session-manager](https://github.com/joshmedeski/t-smart-tmux-session-manager)
## Usage
💨 Level up your workflow by switching between workspaces ⚡ ***BLAZINGLY FAST*** ⚡ with 1️⃣ keypress, the power of fuzzy finding and zoxide! 💨

[Demo video](https://youtu.be/AhmSPRC6Uc4)

## Dependencies
* fzf
* zoxide
* fd (optional)

## Installation
⚠️ If you are not on the nightly version of wezterm, then you must manually install the plugin, as it requires [4017](https://github.com/wez/wezterm/pull/4017) to install with `wezterm.plugin.require()`. Manually install by following the steps below:

### Manuall Install

1. Make sure you have the dependiencies installed.
2. Copy the shell script somewhere to your wezterm config. (Mine is in ~/.config/wezterm/scripts/)
3. Add the following to your wezterm config:
```lua
-- Update the path variable with the real path of the script:
local path = "PATH_TO_SCRIPT/workspace_switcher.sh"

wezterm.on("smart_workspace_switcher", function(window, pane)
	if path == "" then
		wezterm.log_error("workspace_switcher.sh not found")
		return
	end
	local current_tab_id = pane:tab():tab_id()
	local tab, _, _ = window:mux_window():spawn_tab({ args = { path, "--tab-id", tostring(current_tab_id) } })
	tab:set_title("Workspace Switcher")
end)

```
4. Follow steps in setup section.
### Automated Install
1. Add the following to your wezterm config:
```lua
wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
```

2. Follow steps in setup section.

### Setup
1. Add the following to your wezterm config if you do not already have an event handler for `"user-var-changed"`, otherwise update it acoordingly:
```lua
wezterm.on("user-var-changed", function(window, pane, name, value)
	if name == "workspace_switch" then
		local workspace_name = string.match(value, ".+/(.+)$")
		window:perform_action(
			act.SwitchToWorkspace({
				name = workspace_name,
				spawn = { cwd = value },
			}),
			pane
		)
		window:set_right_status(window:active_workspace())
	elseif name == "workspace_switch_session_name" then
		window:perform_action(
			act.SwitchToWorkspace({
				name = value,
			}),
			pane
		)
		window:set_right_status(window:active_workspace())
	end
end)
```

2. Add a keybinding:
```lua
wezterm.config.keys = {
	{
		key = "b", -- Whatever key you might like
		mods = "CTRL|SHIFT", -- Whatever mods you like
		action = act.EmitEvent("smart_workspace_switcher"),
	},
  -- ... other keybindings you may have
}
```

4. **Optionally** alias the shell script:
```shell
alias ws="/YOUR/PATH/TO/THE/SCRIPT/script/workspace_switcher.sh"
```
