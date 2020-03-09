local on_game_created_from_scenario = function()
  for tech_name, tech_lua in pairs(game.forces.player.technologies) do
    tech_lua.enabled = false
  end

  for recipe_name, recipe_lua in pairs(game.forces.player.recipes) do
    if recipe_lua.prototype.group.name == 'production' or
      recipe_lua.prototype.group.name == 'combat' or
      recipe_lua.prototype.group.name == 'logistics' or
      recipe_lua.prototype.subgroup.name == 'settler' or
      recipe_lua.prototype.subgroup.name == 'technician' or
      recipe_lua.prototype.subgroup.name == 'engineer' or
      recipe_lua.prototype.subgroup.name == 'scientist' or
      recipe_lua.prototype.group.name == 'intermediate-products' then
      recipe_lua.enabled = false
    end
  end
end

local on_player_created = function(event)
  local player = game.players[event.player_index]
  player.get_main_inventory().clear()
  player.insert('mcg')
  player.insert('mcg')
  player.insert('bse')
  player.insert('bse')
  player.insert('bbh')
  player.insert('bta')
  player.insert('bde')
end


script.on_event(defines.events.on_game_created_from_scenario, on_game_created_from_scenario)
script.on_event(defines.events.on_player_created, on_player_created)