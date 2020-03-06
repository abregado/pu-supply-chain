local on_game_created_from_scenario = function()
  for tech_name, tech_lua in pairs(game.forces.player.technologies) do
    tech_lua.enabled = false
  end

  for recipe_name, recipe_lua in pairs(game.forces.player.recipes) do
    if recipe_lua.prototype.group.name == 'production' or
      recipe_lua.prototype.group.name == 'combat' or
      recipe_lua.prototype.group.name == 'logistics' or
      recipe_lua.prototype.group.name == 'intermediate-products' then
      recipe_lua.enabled = false
    end
  end
end

script.on_event(defines.events.on_game_created_from_scenario, on_game_created_from_scenario)