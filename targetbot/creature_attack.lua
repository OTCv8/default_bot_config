local lastWalk = 0

onPlayerPositionChange(function()
  lastWalk = now
end)

local function walkTo(path)
  if lastWalk + 250 < now then
    autoWalk(path)
    lastWalk = now
  end
end

TargetBot.Creature.attack = function(params, targets, isLooting) -- params {config, creature, danger, priority}
  if player:isWalking() then
    lastWalk = now
  end

  local config = params.config
  local creature = params.creature
  
  if g_game.getAttackingCreature() ~= creature then
    g_game.attack(creature)
  end

  if not isLooting then
    local luring = false
    if config.lure and not (config.chase and creature:getHealthPercent() < 30) then
      local monsters = 0
      if targets < config.lureCount then
        local path = findPath(player:getPosition(), creature:getPosition(), 10, {marginMin=5, marginMax=6, ignoreNonPathable=true})
        if path then
          walkTo(path)
          luring = true
        end
      end
    end

    local currentDistance = findPath(player:getPosition(), creature:getPosition(), 10, {ignoreCreatures=true, ignoreNonPathable=true, ignoreCost=true})
    if not luring and config.chase and (creature:getHealthPercent() < 30 or not config.keepDistance) then
      if #currentDistance > 1 then
        local newPath = findPath(player:getPosition(), creature:getPosition(), 10, 
          {ignoreNonPathable=true, precision=1})
        if newPath then
          walkTo(newPath)
        end
      end
    elseif not luring and config.keepDistance and config.keepDistanceRange then
      if #currentDistance ~= config.keepDistanceRange and #currentDistance ~= config.keepDistanceRange + 1 then
        local newPath = findPath(player:getPosition(), creature:getPosition(), 10, 
          {ignoreNonPathable=true, marginMin=config.keepDistanceRange, marginMax=config.keepDistanceRange + 1})
        if newPath then
          walkTo(newPath)
        end
      end
    end
  end

  local attacked = false
  if config.useGroupAttack and config.groupAttackSpell:len() > 1 and mana() > config.minMana then
    local creatures = g_map.getSpectatorsInRange(player:getPosition(), false, config.groupAttackRadius, config.groupAttackRadius) -- 14x14 area
    local playersAround = false
    local monsters = 0
    for _, creature in ipairs(creatures) do
      if not creature:isLocalPlayer() and creature:isPlayer() then
        playersAround = true
      elseif creature:isMonster() then
        monsters = monsters + 1
      end
    end
    if monsters >= config.groupAttackTargets and (not playersAround or config.groupAttackIgnorePlayers) then
      TargetBot.sayAttackSpell(config.groupAttackSpell, config.attackSpellDelay or 2500)
    end
  end
  if not attacked and config.useSpellAttack and config.attackSpell:len() > 1 and mana() > config.minMana then
    TargetBot.sayAttackSpell(config.attackSpell, config.attackSpellDelay)
  end
end