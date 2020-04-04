TargetBot.Looting = {}

local ui

TargetBot.Looting.setup = function()
  ui = UI.createWidget("TargetBotLootingPanel")
  UI.Container(TargetBot.Looting.onItemsUpdate, true, nil, ui.items)
  UI.Container(TargetBot.Looting.onContainersUpdate, true, nil, ui.containers)
  
end

TargetBot.Looting.onItemsUpdate = function()

end

TargetBot.Looting.onContainerUpdate = function()

end

TargetBot.Looting.update = function(data)
  info("update looting")
end

TargetBot.Looting.save = function(data)
  -- add items to data
end