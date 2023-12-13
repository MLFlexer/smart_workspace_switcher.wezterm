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

2. Apply default keybinding to config:

    ```lua
    workspace_switcher.apply_to_config(config)
    ```

Or make your own keybinding, see [Configuration - Keybinding](#Keybinding)


### Configuration:
#### Keybinding
Add custom keybinding

  ```lua
  config.keys = {
    -- ...
    -- your other keybindings
    {
    key = "s",
    mods = "ALT",
    action = workspace_switcher.switch_workspace(),
    }
  }
  ```
#### Update right-status with the path
Adding the path as a part of the right-status can be done via. [update-right-status](https://wezfurlong.org/wezterm/config/lua/window-events/update-right-status.html) event

  ```lua
  local function base_path_name(str)
    return string.gsub(str, "(.*[/\\])(.*)", "%2")
  end

  local function update_right_status(window)
    local title = base_path_name(window:active_workspace())
    window:set_right_status(wezterm.format({
      { Foreground = { Color = "green" } },
      { Text = title .. "  " },
    }))
  end

  wezterm.on("update-right-status", function(window, _)
    update_right_status(window)
  end)
  ```
#### Workspace formatter
Set a custom workspace formatter, see [Wezterm formatting docs](https://wezfurlong.org/wezterm/config/lua/wezterm/format.html)

  ```lua
  workspace_switcher.set_workspace_formatter(function(label)
    return wezterm.format({
      { Attribute = { Italic = true } },
      { Foreground = { Color = "green" } },
      { Background = { Color = "black" } },
      { Text = "󱂬: " .. label },
    })
  end)
  ```
#### Zoxide path
Define path to zoxide:

  ```lua
  workspace_switcher.set_zoxide_path("/path/to/zoxide)
  ```
