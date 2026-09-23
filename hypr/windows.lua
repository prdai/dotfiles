-- Persistent app-to-workspace assignment.
--
-- Ported from the [[on-window-detected]] rules in aerospace/aerospace.toml, so
-- an app lands on the same workspace on both machines however it is launched.
-- hypr/autostart.lua only places apps at login; these rules
-- also cover apps opened later by hand.
--
-- Workspace numbers follow the layout in hypr/autostart.lua. Note this
-- differs from aerospace.toml, which puts Spotify on 7 (with Cron on 8 and
-- WhatsApp on 9); the Linux box uses 5 and 6 for Spotify and Slack.
--
-- Class names come from each app's StartupWMClass / hyprctl clients.

o.window("com.mitchellh.ghostty", { workspace = "1" })
o.window("^zen$",                 { workspace = "2" })
o.window("md.obsidian.Obsidian",  { workspace = "3" })
o.window("com.t3tools.T3Code",    { workspace = "4" })
o.window("^Spotify$",             { workspace = "5" })
o.window("^slack$",               { workspace = "6" })
