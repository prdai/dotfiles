local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- General Options
config.check_for_updates = true
config.term = "xterm-256color"
config.use_ime = true

config.window_padding = { left = 2, right = 2, top = 0, bottom = 0 }
config.inactive_pane_hsb = { saturation = 0.9, brightness = 0.7 }
config.initial_rows = 30
config.initial_cols = 130
config.scrollback_lines = 3500
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.use_fancy_tab_bar = false
config.show_tab_index_in_tab_bar = true
config.show_new_tab_button_in_tab_bar = false
config.automatically_reload_config = true
config.default_cursor_style = "BlinkingBlock"

-- Appearance
config.font = wezterm.font("JetBrains Mono")
config.font_size = 12.0
config.window_background_opacity = 0.5
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"

local COLORS = {
	background = "#1e1e2e",
	foreground = "#c0caf5",
	pastel_green = "#80ef80",
	inactive_gray = "#909090",
	hover_gray = "#aaaaaa",
}

config.colors = {
	background = COLORS.background,
	foreground = COLORS.foreground,
	tab_bar = {
		background = COLORS.background,
		active_tab = { bg_color = "#2e2e4e", fg_color = COLORS.pastel_green },
		inactive_tab = {
			bg_color = COLORS.background,
			fg_color = COLORS.inactive_gray,
		},
		inactive_tab_hover = {
			bg_color = COLORS.background,
			fg_color = COLORS.hover_gray,
		},
		new_tab = { bg_color = COLORS.background, fg_color = COLORS.foreground },
		new_tab_hover = { bg_color = "#3e3e6e", fg_color = COLORS.foreground },
	},
}

-- Keys / leader
config.default_prog = { "/bin/zsh" }
config.disable_default_key_bindings = true
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = { -- Enter CopyMode
	{
		key = "[",
		mods = "LEADER",
		action = act.ActivateCopyMode,
	},
	{ key = "Enter", mods = "SHIFT", action = wezterm.action({ SendString = "\x1b\r" }) },
	-- Tab management
	{
		key = "t",
		mods = "LEADER",
		action = act.SpawnTab("CurrentPaneDomain"),
	},
	{
		key = "w",
		mods = "LEADER",
		action = act.CloseCurrentTab({ confirm = true }),
	},

	-- Direct tab switching with Ctrl+1...9
	{ key = "1", mods = "CTRL", action = act.ActivateTab(0) },
	{ key = "2", mods = "CTRL", action = act.ActivateTab(1) },
	{ key = "3", mods = "CTRL", action = act.ActivateTab(2) },
	{ key = "4", mods = "CTRL", action = act.ActivateTab(3) },
	{ key = "5", mods = "CTRL", action = act.ActivateTab(4) },
	{ key = "6", mods = "CTRL", action = act.ActivateTab(5) },
	{ key = "7", mods = "CTRL", action = act.ActivateTab(6) },
	{ key = "8", mods = "CTRL", action = act.ActivateTab(7) },
	{ key = "9", mods = "CTRL", action = act.ActivateTab(8) },

	-- Pane splits
	{
		key = "\\",
		mods = "LEADER",
		action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "-",
		mods = "LEADER",
		action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "x",
		mods = "LEADER",
		action = act.CloseCurrentPane({ confirm = true }),
	},

	-- Pane navigation (vim-style)
	{
		key = "h",
		mods = "CTRL",
		action = act.ActivatePaneDirection("Left"),
	},
	{
		key = "j",
		mods = "CTRL",
		action = act.ActivatePaneDirection("Down"),
	},
	{
		key = "k",
		mods = "CTRL",
		action = act.ActivatePaneDirection("Up"),
	},
	{
		key = "l",
		mods = "CTRL",
		action = act.ActivatePaneDirection("Right"),
	},

	-- Clipboard
	{ key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
	{ key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },

	-- Font resizing
	{ key = "=", mods = "CTRL",       action = act.IncreaseFontSize },
	{ key = "-", mods = "CTRL",       action = act.DecreaseFontSize },
	{ key = "0", mods = "CTRL",       action = act.ResetFontSize },
}

config.key_tables = {
	copy_mode = {
		{
			key = "Tab",
			mods = "NONE",
			action = act.CopyMode("MoveForwardWord"),
		},
		{
			key = "Tab",
			mods = "SHIFT",
			action = act.CopyMode("MoveBackwardWord"),
		},
		{
			key = "Enter",
			mods = "NONE",
			action = act.CopyMode("MoveToStartOfNextLine"),
		},
		{
			key = "Space",
			mods = "NONE",
			action = act.CopyMode({ SetSelectionMode = "Cell" }),
		},
		{
			key = "$",
			mods = "NONE",
			action = act.CopyMode("MoveToEndOfLineContent"),
		},
		{
			key = "$",
			mods = "SHIFT",
			action = act.CopyMode("MoveToEndOfLineContent"),
		},
		{ key = ",", mods = "NONE", action = act.CopyMode("JumpReverse") },
		{
			key = "0",
			mods = "NONE",
			action = act.CopyMode("MoveToStartOfLine"),
		},
		{ key = ";", mods = "NONE", action = act.CopyMode("JumpAgain") },
		{
			key = "F",
			mods = "NONE",
			action = act.CopyMode({ JumpBackward = { prev_char = false } }),
		},
		{
			key = "F",
			mods = "SHIFT",
			action = act.CopyMode({ JumpBackward = { prev_char = false } }),
		},
		{
			key = "G",
			mods = "NONE",
			action = act.CopyMode("MoveToScrollbackBottom"),
		},
		{
			key = "G",
			mods = "SHIFT",
			action = act.CopyMode("MoveToScrollbackBottom"),
		},
		{
			key = "H",
			mods = "NONE",
			action = act.CopyMode("MoveToViewportTop"),
		},
		{
			key = "H",
			mods = "SHIFT",
			action = act.CopyMode("MoveToViewportTop"),
		},
		{
			key = "L",
			mods = "NONE",
			action = act.CopyMode("MoveToViewportBottom"),
		},
		{
			key = "L",
			mods = "SHIFT",
			action = act.CopyMode("MoveToViewportBottom"),
		},
		{
			key = "M",
			mods = "NONE",
			action = act.CopyMode("MoveToViewportMiddle"),
		},
		{
			key = "M",
			mods = "SHIFT",
			action = act.CopyMode("MoveToViewportMiddle"),
		},
		{
			key = "O",
			mods = "NONE",
			action = act.CopyMode("MoveToSelectionOtherEndHoriz"),
		},
		{
			key = "O",
			mods = "SHIFT",
			action = act.CopyMode("MoveToSelectionOtherEndHoriz"),
		},
		{
			key = "T",
			mods = "NONE",
			action = act.CopyMode({ JumpBackward = { prev_char = true } }),
		},
		{
			key = "T",
			mods = "SHIFT",
			action = act.CopyMode({ JumpBackward = { prev_char = true } }),
		},
		{
			key = "V",
			mods = "NONE",
			action = act.CopyMode({ SetSelectionMode = "Line" }),
		},
		{
			key = "V",
			mods = "SHIFT",
			action = act.CopyMode({ SetSelectionMode = "Line" }),
		},
		{
			key = "^",
			mods = "NONE",
			action = act.CopyMode("MoveToStartOfLineContent"),
		},
		{
			key = "^",
			mods = "SHIFT",
			action = act.CopyMode("MoveToStartOfLineContent"),
		},
		{ key = "b", mods = "NONE", action = act.CopyMode("MoveBackwardWord") },
		{ key = "b", mods = "ALT",  action = act.CopyMode("MoveBackwardWord") },
		{ key = "b", mods = "CTRL", action = act.CopyMode("PageUp") },
		{
			key = "d",
			mods = "CTRL",
			action = act.CopyMode({ MoveByPage = 0.5 }),
		},
		{
			key = "e",
			mods = "NONE",
			action = act.CopyMode("MoveForwardWordEnd"),
		},
		{
			key = "f",
			mods = "NONE",
			action = act.CopyMode({ JumpForward = { prev_char = false } }),
		},
		{ key = "f", mods = "ALT",  action = act.CopyMode("MoveForwardWord") },
		{ key = "f", mods = "CTRL", action = act.CopyMode("PageDown") },
		{
			key = "g",
			mods = "NONE",
			action = act.CopyMode("MoveToScrollbackTop"),
		},
		{ key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
		{ key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
		{ key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
		{ key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },
		{
			key = "m",
			mods = "ALT",
			action = act.CopyMode("MoveToStartOfLineContent"),
		},
		{
			key = "o",
			mods = "NONE",
			action = act.CopyMode("MoveToSelectionOtherEnd"),
		},
		{
			key = "t",
			mods = "NONE",
			action = act.CopyMode({ JumpForward = { prev_char = true } }),
		},
		{
			key = "u",
			mods = "CTRL",
			action = act.CopyMode({ MoveByPage = -0.5 }),
		},
		{
			key = "v",
			mods = "NONE",
			action = act.CopyMode({ SetSelectionMode = "Cell" }),
		},
		{
			key = "v",
			mods = "CTRL",
			action = act.CopyMode({ SetSelectionMode = "Block" }),
		},
		{
			key = "w",
			mods = "NONE",
			action = act.CopyMode("MoveForwardWord"),
		},
		{ key = "PageUp",   mods = "NONE", action = act.CopyMode("PageUp") },
		{ key = "PageDown", mods = "NONE", action = act.CopyMode("PageDown") },
		{
			key = "End",
			mods = "NONE",
			action = act.CopyMode("MoveToEndOfLineContent"),
		},
		{
			key = "Home",
			mods = "NONE",
			action = act.CopyMode("MoveToStartOfLine"),
		},
		{ key = "LeftArrow", mods = "NONE", action = act.CopyMode("MoveLeft") },
		{
			key = "LeftArrow",
			mods = "ALT",
			action = act.CopyMode("MoveBackwardWord"),
		},
		{
			key = "RightArrow",
			mods = "NONE",
			action = act.CopyMode("MoveRight"),
		},
		{
			key = "RightArrow",
			mods = "ALT",
			action = act.CopyMode("MoveForwardWord"),
		},
		{ key = "UpArrow",   mods = "NONE", action = act.CopyMode("MoveUp") },
		{ key = "DownArrow", mods = "NONE", action = act.CopyMode("MoveDown") },
	},
}

return config
