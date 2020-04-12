TargetBot.Creature.edit = function(config, callback) -- callback = function(newConfig)
  config = config or {}

  local editor = UI.createWindow('TargetBotCreatureEditorWindow')
  local values = {} -- (key, function returning value of key)

  editor.name:setText(config.name or "")
  table.insert(values, {"name", function() return editor.name:getText() end})

  local addScrollBar = function(id, title, min, max, defaultValue)
    local widget = UI.createWidget('TargetBotCreatureEditorScrollBar', editor.left)
    widget.scroll.onValueChange = function(scroll, value)
      widget.text:setText(title .. ": " .. value)
    end
    widget.scroll:setRange(min, max)
    widget.scroll:setValue(config[id] or defaultValue)
    widget.scroll.onValueChange(widget.scroll, widget.scroll:getValue())
    table.insert(values, {id, function() return widget.scroll:getValue() end})
  end

  local addTextEdit = function(id, title, defaultValue)
    local widget = UI.createWidget('TargetBotCreatureEditorTextEdit', editor.right)
    widget.text:setText(title)
    widget.textEdit:setText(config[id] or defaultValue or "")
    table.insert(values, {id, function() return widget.textEdit:getText() end})
  end

  local addCheckBox = function(id, title, defaultValue)
    local widget = UI.createWidget('TargetBotCreatureEditorCheckBox', editor.right)
    widget.onClick = function()
      widget:setOn(not widget:isOn())
    end
    widget:setText(title)
    if config[id] == nil then
      widget:setOn(defaultValue)
    else
      widget:setOn(config[id])
    end
    table.insert(values, {id, function() return widget:isOn() end})
  end

  editor.cancel.onClick = function()
    editor:destroy()
  end
  editor.onEscape = editor.cancel.onClick

  editor.ok.onClick = function()
    local newConfig = {}
    for _, value in ipairs(values) do
      newConfig[value[1]] = value[2]()
    end
    newConfig.regex = "^" .. newConfig.name:trim():lower():gsub("%*", ".*"):gsub("%?", ".?") .. "$"

    editor:destroy()
    callback(newConfig)
  end

  -- values
  addScrollBar("priority", "Priority", 0, 10, 1)
  addScrollBar("danger", "Danger", 0, 10, 1)
  addScrollBar("maxDistance", "Max distance", 1, 10, 1)
  addScrollBar("keepDistanceRange", "Keep distance", 1, 5, 1)
  addScrollBar("lureCount", "Lure", 0, 5, 1)

  addScrollBar("minMana", "Minimum mana", 0, 3000, 100)
  addScrollBar("attackSpellDelay", "Attack spell delay", 200, 5000, 2500)
  addScrollBar("groupAttackRadius", "Radius of group attack spell", 1, 7, 1)
  addScrollBar("groupAttackTargets", "Min. targets for group attack", 1, 5, 1)

  addCheckBox("chase", "Chase", true)
  addCheckBox("keepDistance", "Keep Distance", true)
  addCheckBox("lure", "Lure", true)
--  addCheckBox("avoidAttacks", "Avoid attacks", true)
  addCheckBox("useSpellAttack", "Use attack spell", true)
  addCheckBox("useGroupAttack", "Use group attack spell", true)
  addCheckBox("groupAttackIgnorePlayers", "Ignore players in group attack", true)

  addTextEdit("attackSpell", "Attack spell", "")
  addTextEdit("groupAttackSpell", "Group attack spell", "")

end
