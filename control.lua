data_import = require('data-import')
local maint = require('maint')
require('constants')

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

  game.forces.player.inserter_stack_size_bonus = 9
  maint.on_init()
end

local on_configuration_changed = function(event)
  global.created_items = global.created_items or created_items()
  global.respawn_items = global.respawn_items or respawn_items()
end

on_init = function()
end


local on_player_created = function(event)
  local player = game.players[event.player_index]
  local old_char = player.character
  player.character = nil
  old_char.destroy()
  player.get_main_inventory().clear()
  local starting_items = {{'dw',1000},{"lse",4},{"tru",8},{"psl",12},{"lde",4},{"lta",4},{"mcg",1000},{'bse',100},{'bta',20,},{'bbh',30},{'bde',50}}
  for _, stack in pairs(starting_items) do
    player.insert({name=stack[1],count=stack[2]})
  end
  player.insert('pu-inserter')
  player.insert('pu-transport-belt')
  player.insert('pu-splitter')
  player.insert('pu-underground-belt')
end

local on_built_entity = function(event)
  --TODO: If there is no CM in range then you cant build
  maint.add_entity(event.created_entity)

  if event.created_entity.name == 'pu-inserter' or
  event.created_entity.name == 'pu-transport-belt' or
  event.created_entity.name == 'pu-splitter' or
  event.created_entity.name == 'pu-underground-belt' then
    game.players[event.player_index].insert(event.stack)
  end

end

local on_player_mined_entity = function(event)
  maint.remove_entity(event.entity)
end

local on_tick = function(event)
  maint.update(event.tick)
end

script.on_event(defines.events.on_game_created_from_scenario, on_game_created_from_scenario)
script.on_event(defines.events.on_player_created, on_player_created)
script.on_event(defines.events.on_built_entity, on_built_entity)
script.on_event(defines.events.on_player_mined_entity, on_player_mined_entity)
script.on_event(defines.events.on_tick, on_tick)

