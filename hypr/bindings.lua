-- Personal keybinding overrides, layered on top of Omarchy's defaults.
-- See current bindings: omarchy menu keybindings --print

-- Launcher: replace Omarchy's default SUPER+SPACE menu with vicinae.
hl.unbind("SUPER + SPACE")
o.bind("SUPER + SPACE", "Vicinae launcher", "vicinae toggle")

-- Omarchy's root menu (system, power/shutdown, themes, etc.) normally lives on
-- SUPER+SPACE. Vicinae took that key, so move the menu to SUPER+ALT+SPACE
-- (which Omarchy defaults to the narrower "Apps menu").
hl.unbind("SUPER + ALT + SPACE")
o.bind("SUPER + ALT + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Notification center. This machine's Omarchy uses herdr (quickshell) for
-- notifications, not swaync, so this opens herdr's notification history.
o.bind("SUPER + N", "Notification center", "omarchy-shell notifications showHistory")

-- Window/workspace switching, mirroring the aerospace setup on macOS:
--   alt-tab       = workspace-back-and-forth
--   alt-shift-tab = focus --boundaries-action wrap-around-the-workspace dfs-next
-- Omarchy defaults these to next/previous workspace, so unbind first.
hl.unbind("SUPER + TAB")
hl.unbind("SUPER + SHIFT + TAB")
o.bind("SUPER + TAB", "Back and forth workspace", hl.dsp.focus({ workspace = "previous" }))
o.bind("SUPER + SHIFT + TAB", "Focus next window", hl.dsp.window.cycle_next())

-- Logitech MX Keys.
-- Omarchy binds SUPER+SHIFT+S to the Google Maps web app; reclaim it for screenshots.
hl.unbind("SUPER + SHIFT + S")
o.bind("SUPER + SHIFT + S", "Screenshot", "omarchy-capture-screenshot")
o.bind("SUPER + H", "Dictation", "voxtype record toggle")
o.bind("SUPER + PERIOD", "Emoji picker", "omarchy-shell shell toggle omarchy.emojis")

-- Typora instead of Omarchy's Omawrite.
hl.unbind("SUPER + SHIFT + W")
o.bind("SUPER + SHIFT + W", "Typora", { launch = "typora --enable-wayland-ime" })

-- Yazi instead of Nautilus for the file manager. Re-pressing the key focuses
-- the existing window.
hl.unbind("SUPER + SHIFT + F")
o.bind("SUPER + SHIFT + F", "File manager", { tui = "yazi", focus = true })
