-- allows to test/edit bot lua scripts ingame, you can have multiple scripts like this, just change storage.ingame_lua
local tab = getTab("Main")

addButton("luaEditor", "Lua editor", function(newText)
  UI.MultilineEditor(storage.ingame_lua, {title="Lua editor"}, function(text)
    storage.ingame_lua = text
    reload()
  end)
end, tab)

if type(storage.ingame_lua) == "string" then
  local status, result = pcall(function()
    assert(load(storage.ingame_lua, ""))()
  end)
  if not status then 
    error("Ingame edior error:\n" .. result)
  end
end
