# smart_workspace_switcher.wezterm
A smart Wezterm workspace switcher inspired by [joshmedeski/t-smart-tmux-session-manager](https://github.com/joshmedeski/t-smart-tmux-session-manager)
## Usage
💨 Level up your workflow by switching between workspaces ⚡ ***BLAZINGLY FAST*** ⚡ with 1️⃣ keypress, the power of fuzzy finding and zoxide! 💨

[Demo video](https://youtu.be/AhmSPRC6Uc4)

## Dependencies
* zoxide

### Setup
1. require the plugin:
```lua
local wezterm = require("wezterm")
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
```

2. Add a keybinding and formatter for Workspace labels:
```lua
workspace_switcher.apply_to_config(config, "b", "ALT", function(label)
  return wezterm.format({
    -- { Attribute = { Italic = true } },
    -- { Foreground = { Color = "green" } },
    -- { Background = { Color = "black" } },
    { Text = "󱂬: " .. label },
  })
end)
```
