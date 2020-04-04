local targetbotMacro = nil
local config = nil
local lastAction = 0

-- ui
local configWidget = UI.Config()
local ui = UI.createWidget("TargetBotPanel")

ui.list = ui.listPanel.list -- shortcut
TargetBot.targetList = ui.list
TargetBot.Looting.setup()

ui.status.left:setText("Status:")
ui.status.right:setText("Off")
ui.target.left:setText("Target:")
ui.target.right:setText("-")
ui.config.left:setText("Config:")
ui.config.right:setText("-")
ui.danger.left:setText("Danger:")
ui.danger.right:setText("0")

-- main loop, controlled by config
targetbotMacro = macro(100, function()
  local pos = player:getPosition()
  local creatures = g_map.getSpectatorsInRange(pos, false, 7, 7) -- 7x7 area
  local highestPriority = 0
  local dangerLevel = 0
  local targets = 0
  local highestPriorityParams = nil
  for i, creature in ipairs(creatures) do
    local path = findPath(player:getPosition(), creature:getPosition(), 10, {ignoreLastCreature=true, ignoreNonPathable=true})
    if not creature:isLocalPlayer() and path then
      local params = TargetBot.Creature.calculateParams(creature) -- return {craeture, config, danger, priority}
      dangerLevel = dangerLevel + params.danger
      if params.priority > 0 then
        targets = targets + 1
        if params.priority > highestPriority then
          highestPriority = params.priority
          highestPriorityParams = params
        end
        creature:setText(params.config.name .. "\n" .. params.priority .. " | " .. params.danger)
      end
    end
  end

  ui.danger.right:setText(dangerLevel)
  if highestPriorityParams then
    ui.target.right:setText(highestPriorityParams.creature:getName())
    ui.config.right:setText(highestPriorityParams.config.name)
    lastAction = now
    TargetBot.Creature.attack(highestPriorityParams)
  else
    ui.target.right:setText("-")
    ui.config.right:setText("-")
  end
end)

-- config, its callback is called immediately, data can be nil
config = Config.setup("targetbot_configs", configWidget, "json", function(name, enabled, data)
  if not data then
    ui.status.right:setText("Off")
    return targetbotMacro.setOff() 
  end
  TargetBot.Creature.resetConfigs()
  for _, value in ipairs(data["targeting"] or {}) do
    TargetBot.Creature.addConfig(value)
  end
  TargetBot.Looting.update(data["looting"] or {})

  -- add configs
  if enabled then
    ui.status.right:setText("On")
  else
    ui.status.right:setText("Off")
  end

  targetbotMacro.setOn(enabled)
  targetbotMacro.delay = nil
end)

-- setup ui
ui.editor.buttons.add.onClick = function()
  TargetBot.Creature.edit(nil, function(newConfig)
    TargetBot.Creature.addConfig(newConfig, true)
    TargetBot.save()
  end)
end

ui.editor.buttons.edit.onClick = function()
  local entry = ui.list:getFocusedChild()
  if not entry then return end
  TargetBot.Creature.edit(entry.value, function(newConfig)
    entry:setText(newConfig.name)
    entry.value = newConfig
    TargetBot.Creature.resetConfigsCache()
    TargetBot.save()
  end)
end

ui.editor.buttons.remove.onClick = function()
  local entry = ui.list:getFocusedChild()
  if not entry then return end
  entry:destroy()
  TargetBot.Creature.resetConfigsCache()
  TargetBot.save()
end

-- public function, you can use them in your scripts
TargetBot.isActive = function() -- return true if attacking or looting takes place
  return lastAction + 200 > now
end

TargetBot.setStatus = function(text)
  return ui.status.right:setText(text)
end

TargetBot.isOn = function()
  return config.isOn()
end

TargetBot.isOff = function()
  return config.isOff()
end

TargetBot.setOn = function(val)
  if val == false then  
    return TargetBot.setOff(true)
  end
  config.setOn()
end

TargetBot.setOff = function(val)
  if val == false then  
    return TargetBot.setOn(true)
  end
  config.setOff()
end

TargetBot.delay = function(value)
  targetbotMacro.delay = now + value
end

TargetBot.save = function()
  local data = {targeting={}, looting={}}
  for _, entry in ipairs(ui.list:getChildren()) do
    table.insert(data.targeting, entry.value)
  end
  TargetBot.Looting.save(data.looting)
  config.save(data)
end
