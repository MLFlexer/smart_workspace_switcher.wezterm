# smart_workspace_switcher.wezterm

A smart Wezterm workspace switcher inspired by [joshmedeski/t-smart-tmux-session-manager](https://github.com/joshmedeski/t-smart-tmux-session-manager)

## Usage

💨 Level up your workflow by switching between workspaces ⚡ ***BLAZINGLY FAST*** ⚡ with 1️⃣ keypress, the power of fuzzy finding and zoxide! 💨

![Demo gif](https://github.com/MLFlexer/smart_workspace_switcher.wezterm/assets/75012728/a4f82fcf-5304-4891-a1e2-346767678dc6)

## Dependencies

* zoxide

### Setup

1. require the plugin:

    ```lua
    local wezterm = require("wezterm")
    local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
    ```

2. Optionally set the path to Zoxide:

    ```lua
    workspace_switcher.set_zoxide_path("/custom/path/zoxide)
    ```

3. Add a keybinding and formatter for Workspace labels:

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
