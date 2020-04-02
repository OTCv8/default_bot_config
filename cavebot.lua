-- Cavebot by otclient@otclient.ovh
-- visit http://bot.otclient.ovh/

local cavebotTab = "Cave"
local targetingAndLootingTab = "Target"

setDefaultTab(cavebotTab)
CaveBot = {} -- global namespace
CaveBot.Extensions = {}
importStyle("/cavebot/cavebot.otui")
importStyle("/cavebot/editor.otui")
importStyle("/cavebot/supply.otui")
dofile("/cavebot/actions.lua")
dofile("/cavebot/editor.lua")
dofile("/cavebot/example_functions.lua")
dofile("/cavebot/recorder.lua")
-- in this section you can add extensions, check extension_template.lua
-- dofile("/cavebot/extension_template.lua")
dofile("/cavebot/depositer.lua")
dofile("/cavebot/supply.lua")
-- main cavebot file, must be last
dofile("/cavebot/cavebot.lua")

setDefaultTab(targetingAndLootingTab)
TargeBot = {} -- global namespace
dofile("/targetbot/target.lua")

