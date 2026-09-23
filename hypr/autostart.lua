-- Extra autostart processes.

-- Note: vicinae runs from its own systemd user unit (vicinae.service, bound to
-- graphical-session.target), so it is NOT started here:
--   systemctl --user enable --now vicinae.service
--
-- Note: swaync is not started either. This machine's Omarchy uses herdr
-- (quickshell) for the bar AND notifications, and herdr already owns the
-- org.freedesktop.Notifications DBus name, so swaync cannot acquire it.

-- Login app layout, one app per workspace. Native hl.exec_cmd: hyprctl dispatch
-- exec stopped parsing on Hyprland 0.56, and hyprland.start fires when the
-- compositor is ready, so no wait loop or shell wrapper is needed.

-- T3 Code ships as an AppImage; its desktop entry wraps it with
-- APPIMAGE_EXTRACT_AND_RUN=1 because this box has no libfuse.so.2.
local t3code = (os.getenv("HOME") or "") .. "/.local/share/applications/t3code.desktop"

local layout = {
  { ws = "1 silent", cmd = "ghostty" },
  { ws = "2 silent", cmd = "/opt/zen-browser-bin/zen-bin" },
  { ws = "3 silent", cmd = "obsidian" },
  { ws = "4 silent", cmd = t3code },
  { ws = "5 silent", cmd = "spotify" },
  { ws = "6 silent", cmd = "slack" },
}

hl.on("hyprland.start", function()
  for _, app in ipairs(layout) do
    if o.cmd_present(app.cmd) then
      hl.exec_cmd(o.launch(app.cmd), { workspace = app.ws })
    else
      print("[autostart] skip workspace " .. app.ws .. ": '" .. app.cmd .. "' is not installed")
    end
  end
end)
