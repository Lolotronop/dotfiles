local wezterm = require("wezterm")

local config = wezterm.config_builder()
config.color_scheme = "GruvboxDarkHard"
config.font = wezterm.font("IosevkaTerm Nerd Font")
config.max_fps = 170

config.colors = {
	tab_bar = {
		background = "#090909",
		active_tab = {
			bg_color = "#090909",
			fg_color = "#d5c4a1",
			intensity = "Bold",
		},
		inactive_tab = {
			bg_color = "#1d2021",
			fg_color = "#bdae93",
			intensity = "Normal",
		},
	},
	background = "#000000",
}
config.window_background_opacity = 0.8

config.inactive_pane_hsb = {
	saturation = 1,
	brightness = 0.9,
}

-- config.default_prog = { "tmux", "new", "-As0" }
-- config.default_prog = { "wsl", "-d", "Ubuntu", "--", "tmux", "new", "-As0" }
-- config.default_prog = { "wsl", "-d", "archlinux", "--", "/home/lolotronop/.nix-profile/bin/fish" }
config.default_prog = { "nu.exe" }
config.font_size = 14
config.enable_tab_bar = false
-- config.window_decorations = "NONE"
config.hide_mouse_cursor_when_typing = false
config.window_padding = {
	left = 1,
	right = 1,
	top = 22,
	bottom = 0,
}
-- config.window_content_alignment = {
-- 	horizontal = "Center",
-- 	vertical = "Bottom",
-- }

local function enable_tmux(window, pane)
	config.leader = { key = "b", mods = "CTRL" }

	config.enable_tab_bar = true
	config.use_fancy_tab_bar = false
	config.tab_bar_at_bottom = true
	config.tab_max_width = 64

	require("plugins.wez-tmux.plugin").apply_to_config(config, {
		-- tab_and_split_indices_are_zero_based = true
	})
	window:set_config_overrides(config)
end

wezterm.on("my-enable-tmux", enable_tmux)

config.keys = {
	{
		key = "T",
		mods = "CTRL|SHIFT",
		action = wezterm.action.EmitEvent("my-enable-tmux"),
	},
}

local mux = wezterm.mux

wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():set_position(1090, 0)
	window:gui_window():maximize()
end)

return config
