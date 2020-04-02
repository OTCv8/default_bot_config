-- auto recording for cavebot
CaveBot.Recorder = {}

local isEnabled = nil
local lastPos = nil

local function setup()
  local function addPosition(pos)
    CaveBot.addAction("goto", pos.x .. "," .. pos.y .. "," .. pos.z, true)
    lastPos = pos
  end

  onPlayerPositionChange(function(newPos, oldPos)
    if CaveBot.isOn() or not isEnabled then return end    
    if not lastPos then
      -- first step
      return addPosition(oldPos)
    elseif newPos.z ~= oldPos.z or math.abs(oldPos.x - newPos.x) > 1 or math.abs(oldPos.y - newPos.y) > 1 then
      -- stairs/teleport
      return addPosition(oldPos)
    elseif math.max(math.abs(lastPos.x - newPos.x), math.abs(lastPos.y - newPos.y)) > 5 then
      -- 5 steps from last pos
      return addPosition(newPos)
    end
  end)
  
  onUse(function(pos, itemId, stackPos, subType)
    if CaveBot.isOn() or not isEnabled then return end
    if pos.x == 0xFFFF then 
      CaveBot.addAction("use", itemId, true)
    else
      CaveBot.addAction("use", pos.x .. "," .. pos.y .. "," .. pos.z, true)
    end
  end)
  
  onUseWith(function(pos, itemId, target, subType)
    if CaveBot.isOn() or not isEnabled then return end
    if not target:isItem() then return end
    local targetPos = target:getPosition()
    if targetPos.x == 0xFFFF then return end
    CaveBot.addAction("usewith", itemId .. "," .. pos.x .. "," .. pos.y .. "," .. pos.z, true)
  end)
end

CaveBot.Recorder.enable = function()
  CaveBot.setOff()
  if isEnabled == nil then
    setup()
  end
  isEnabled = true
  lastPos = nil
end

CaveBot.Recorder.disable = function()
  if isEnabled == true then
    isEnabled = false
  end
  CaveBot.save()
end