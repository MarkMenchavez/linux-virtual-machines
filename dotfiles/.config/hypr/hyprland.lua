-- Refer to the wiki for more information.

-- https://wiki.hypr.land/Configuring/Start/

require("monitors")
require("autostart")
require("environment-variables")
require("permissions")
require("look-and-feel")
require("input")
require("layouts")
require("miscellaneous")
require("rules")
require("multimedia-keybinds")
require("window-keybinds")

-- Set programs that you use

--local terminal      = "kitty"
local terminal        = "footclient"

local browser         = "brave"
local browser_private = "brave --incognito"

local ide             = "code"
local fileManager =   "dolphin"

--local menu          = "hyprlauncher"
local menu            = "fuzzel"
local wallpaper       = "waypaper --random"

local volume_up       = "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
local volume_down     = "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-"

local mainMod         = "SUPER" -- Sets "Windows" key as main modifier
local secondMod       = "SUPER + SHIFT"

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more

hl.bind(mainMod   .. " + Return", hl.dsp.exec_cmd(terminal))

hl.bind(mainMod   .. " + I",      hl.dsp.exec_cmd(ide))

hl.bind(mainMod   .. " + B",      hl.dsp.exec_cmd(browser))
hl.bind(secondMod .. " + B",      hl.dsp.exec_cmd(browser_private))

hl.bind(mainMod   .. " + Q",      hl.dsp.window.close())

hl.bind(mainMod   .. " + W",      hl.dsp.exec_cmd(wallpaper))

hl.bind(mainMod   .. " + M",      hl.dsp.exec_cmd(volume_up), { repeating = true, locked = true })
hl.bind(mainMod   .. " + N",      hl.dsp.exec_cmd(volume_down), { repeating = true, locked = true })

--hl.bind(secondMod .. " + X",    hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(secondMod .. " + X",      hl.dsp.exit())

hl.bind(mainMod   .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod   .. " + R",      hl.dsp.exec_cmd(menu))

