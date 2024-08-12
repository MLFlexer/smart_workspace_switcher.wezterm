# smart_workspace_switcher.wezterm

A smart Wezterm workspace switcher inspired by [t-smart-tmux-session-manager](https://github.com/joshmedeski/t-smart-tmux-session-manager) and its successor [sesh](https://github.com/joshmedeski/sesh)

## Usage

💨 Level up your workflow by switching between workspaces ⚡ ***BLAZINGLY FAST*** ⚡ with 1️⃣ keypress, the power of fuzzy finding and zoxide! 💨

![Demo gif](https://github.com/MLFlexer/smart_workspace_switcher.wezterm/assets/75012728/a4f82fcf-5304-4891-a1e2-346767678dc6)

## Dependencies

* zoxide

### Setup

1. Require the plugin:

    ```lua
    local wezterm = require("wezterm")
    local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
    ```

2. Apply the default keybinding to the config:

    ```lua
    workspace_switcher.apply_to_config(config)
    ```

Or create your own keybinding, see [Configuration - Keybinding](#Keybinding).

### Configuration:
#### Keybinding
To add a custom keybinding:

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

#### Changing the Default Workspace Name
You can set a default workspace name:

```lua
config.default_workspace = "~"
```

#### Additional Filtering

You can include `extra_args` in the call to `switch_workspace` to filter the results of the zoxide query further. The `extra_args` is just a string concatenated to the command like so: `zoxide query -l <extra_args>`. For example, to select projects from a predefined list in `~/.projects`, call the plugin like this:

  ```lua
  workspace_switcher.switch_workspace({ extra_args = " | rg -Fxf ~/.projects" })
  ```

#### Updating the Right Status with the Path

To add the selected path to the right status bar, use the `smart_workspace_switcher.workspace_switcher.chosen` event emitted when choosing a workspace:

  ```lua
  wezterm.on("smart_workspace_switcher.workspace_switcher.chosen", function(window, workspace)
    local base_path = string.gsub(workspace, "(.*[/\\])(.*)", "%2")
    window:set_right_status(wezterm.format({
      { Foreground = { Color = "green" } },
      { Text = base_path .. "  " },
    }))
  end)

  wezterm.on("smart_workspace_switcher.workspace_switcher.created", function(window, workspace)
    local base_path = string.gsub(workspace, "(.*[/\\])(.*)", "%2")
    window:set_right_status(wezterm.format({
      { Foreground = { Color = "green" } },
      { Text = base_path .. "  " },
    }))
  end)
  ```

#### Events

The following events are available and can be used to trigger custom behavior:

* `smart_workspace_switcher.workspace_switcher.start` - Triggered when the fuzzy finder starts.
* `smart_workspace_switcher.workspace_switcher.selected` - Triggered when an element is selected.
* `smart_workspace_switcher.workspace_switcher.created` - Triggered after creating and switching to a new workspace.
* `smart_workspace_switcher.workspace_switcher.chosen` - Triggered after switching to a workspace.

Example usage:

  ```lua
  wezterm.on("smart_workspace_switcher.workspace_switcher.chosen", function(window, workspace)
    wezterm.log_info("THIS IS EMITTED FROM THE CALLBACK")
  end)
  ```

#### Workspace Formatter

Set a custom workspace formatter using the following example. For more information, see the [Wezterm formatting docs](https://wezfurlong.org/wezterm/config/lua/wezterm/format.html):

  ```lua
  workspace_switcher.workspace_formatter = function(label)
    return wezterm.format({
      { Attribute = { Italic = true } },
      { Foreground = { Color = "green" } },
      { Background = { Color = "black" } },
      { Text = "󱂬: " .. label },
    })
  end
  ```

#### Zoxide Path

To define a custom path to `zoxide`:

  ```lua
  workspace_switcher.zoxide_path = "/path/to/zoxide"
  ```
