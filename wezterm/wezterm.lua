-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

config.inactive_pane_hsb = {
	saturation = 0.9,
	brightness = 0.2,
}

config.font_size = 11.0

config.color_scheme = "Tokyo Night"
config.window_background_opacity = 0.95

config.default_prog = { "nu" }

wezterm.on("gui-startup", function(cmd)
	local _, main_pane, window = wezterm.mux.spawn_window(cmd or {})

	window:gui_window():maximize()
	wezterm.sleep_ms(1)

	local right_pane = main_pane:split({ direction = "Right", size = 0.33 })

	main_pane:activate()
end)

-- and finally, return the configuration to wezterm
return config
