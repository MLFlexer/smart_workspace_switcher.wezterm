local wezterm = require("wezterm")
local workspace_switcher = require("workspace_switcher")
local function apply_to_config(config, key, mods, formatter)
	if key == nil then
		key = "s"
	end
	if mods == nil then
		mods = "s"
	end
	if formatter == nil then
		formatter = function(label)
			return wezterm.format({
				{ Text = "󱂬: " .. label },
			})
		end
	end
	table.insert(config.keys, {
		key = key,
		mods = mods,
		action = workspace_switcher.workspace_switcher(formatter),
	})
end

return { apply_to_config = apply_to_config }
