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

  local addCheckBox = function(id, title, value, defaultValue)
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
  addCheckBox("follow", "Follow", true)
  addCheckBox("attack", "Attack", true)

end
