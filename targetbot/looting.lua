TargetBot.Looting = {}
TargetBot.Looting.list = {} -- list of containers to loot

local ui
local items = {}
local containers = {}

TargetBot.Looting.setup = function()
  ui = UI.createWidget("TargetBotLootingPanel")
  UI.Container(TargetBot.Looting.onItemsUpdate, true, nil, ui.items)
  UI.Container(TargetBot.Looting.onContainersUpdate, true, nil, ui.containers) 
  ui.maxDangerPanel.value.onTextChange = function()
    local value = tonumber(ui.maxDangerPanel.value:getText())
    if not value then
      tonumber(ui.maxDangerPanel.value:setText(0))
    end
  end
end

TargetBot.Looting.onItemsUpdate = function()
  items = ui.items:getItems()
  TargetBot.save()
end

TargetBot.Looting.onContainersUpdate = function()
  containers = ui.containers:getItems()
  TargetBot.save()
end

TargetBot.Looting.update = function(data)
  TargetBot.Looting.list = {}
  ui.items:setItems(data['items'] or {})
  ui.containers:setItems(data['containers'] or {})
  ui.maxDangerPanel.value:setText(data['maxDanger'] or 10)
  items = ui.items:getItems()
  containers = ui.containers:getItems()
end

TargetBot.Looting.save = function(data)
  data['items'] = ui.items:getItems()
  data['containers'] = ui.containers:getItems()
  data['maxDanger'] = tonumber(ui.maxDangerPanel.value:getText())
end

TargetBot.Looting.process = function(dangerLevel)
  if not items[1] or not containers[1] then 
    return false 
  end
  if dangerLevel > tonumber(ui.maxDangerPanel.value:getText()) then
    return false
  end
  return TargetBot.Looting.list[1] ~= nil
end

onCreatureDisappear(function(creature)
  if not TargetBot.isOn() then return end
  if not creature:isMonster() then return end
  local pos = player:getPosition()
  local mpos = creature:getPosition()
  local name = creature:getName()
  if pos.z ~= mpos.z or math.max(math.abs(pos.x-mpos.x), math.abs(pos.y-mpos.y)) > 6 then return end
  schedule(20, function() -- check in 20ms if there's container (dead body) on that tile
    local tile = g_map.getTile(mpos)
    if not tile then return end
    local container = tile:getTopUseThing()
    if not container then return end
    if not findPath(player:getPosition(), mpos, 6, {ignoreNonPathable=true, ignoreCreatures=true, ignoreCost=true}) then return end
    table.insert(TargetBot.Looting.list, {pos=mpos, creature=name, container=container:getId(), added=now})
    container:setMarked('#000088')
  end)
end)
