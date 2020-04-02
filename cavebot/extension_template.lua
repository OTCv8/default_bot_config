-- example cavebot extension (remember to add this file to ../cavebot.lua)
CaveBot.Extensions.Example = {}

local ui

-- first function called, here you should setup your UI
CaveBot.Extensions.Example.setup = function()
  ui = UI.createWidget('BotTextEdit')
  ui:setText("Hello")
  ui.onTextChange = function()
    CaveBot.save() -- save new config
  end
end

-- called when cavebot config changes, configData is a table but it can be nil
CaveBot.Extensions.Example.onConfigChange = function(configName, isEnabled, configData)
  if not configData then return end
  if configData["text"] then
    ui:setText(configData["text"])
  end
end

-- called when cavebot is saving config (so when CaveBot.save() is called), should return table or nil
CaveBot.Extensions.Example.onSave = function()
  return {text=ui:getText()}
end

-- bellow add you custom functions
-- this function can be used in cavebot function waypoint as: return Example.run(retries, prev)
-- there are 2 useful parameters - retries (number) and prev (true/false), check actions.lua to learn more
CaveBot.Extensions.Example.run = function(retries, prev)
  -- it will say text 10 times with some delay and then continue
  if retries > 10 then
    return true
  end
  say(ui:getText() .. " x" .. retries)
  delay(100 + retries * 100)
  return "retry"
end
