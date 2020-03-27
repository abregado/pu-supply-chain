local handler = require("event_handler")
local free_builder = require('free-builder')
local maint = require('maint')
local data_import = require('__pu-supply-chain__.data-import')
local math2d = require('math2d')
local welcome = require('welcome_screen')

local new_plot = function(surface,position)
  if type(surface) == 'string' then surface = game.surfaces[surface] end
  local size = 256
  local view_box = {
      left_top = {
        x = position.x - (size/2),
        y = position.y - (size/2),
      },
      right_bottom = {
        x = position.x + (size/2),
        y = position.y + (size/2),
      },
    }
  surface.request_to_generate_chunks({0,0},size/32)
  return view_box
end

local init_plot = function(surface,view_box)
  if type(surface) == 'string' then surface = game.surfaces[surface] end
  local tiles = {}
  for x = view_box.left_top.x, view_box.right_bottom.x do
    for y = view_box.left_top.y, view_box.right_bottom.y do
      local tile_type = 'lab-dark-1'
      if (x+y)%2 == 0 then tile_type = 'lab-dark-2' end
      table.insert(tiles,{name=tile_type,position={x=x,y=y}})
    end
  end
  surface.set_tiles(tiles)
end

local make_planet_force = function(name,resource_list)
  local planet_force = game.forces[name] or game.create_force(name)

  for recipe_name, recipe_lua in pairs(planet_force.recipes) do
    if recipe_lua.prototype.group.name == 'production' or
      recipe_lua.prototype.group.name == 'combat' or
      recipe_lua.prototype.group.name == 'logistics' or
      recipe_lua.prototype.group.name == 'intermediate-products' then
      recipe_lua.enabled = false
    end
  end

  for resource_name, resource_quality in pairs(resource_list) do
    for quality=1,5 do
      local recipe = planet_force.recipes[resource_name.."-"..quality]
      recipe.enabled =(resource_quality == quality)
    end
  end

  for tech_name, tech_lua in pairs(planet_force.technologies) do
    tech_lua.enabled = false
  end

  planet_force.inserter_stack_size_bonus = 9
end

local on_game_created_from_scenario = function()
  free_builder.on_load()
  free_builder.add_free_item('pu-transport-belt',10)
  free_builder.add_free_item('pu-splitter',10)
  free_builder.add_free_item('pu-underground-belt',10)
  free_builder.add_free_item('pu-inserter',10)
  free_builder.add_free_item('pu-filter-inserter',10)
  free_builder.add_free_item('loader',10)
  free_builder.add_free_item('deconstruction-planner',10)
  free_builder.add_free_item('green-wire',10)
  maint.on_load()
  make_planet_force('montem',data_import.planets['montem'])

  global.next_update = 0

  game.create_surface('abregado-rae',{
    seed=555,
    water='none',
    starting_area='none',
    property_expression_names={
      moisture=0,
      elevation=100,
    },
    autoplace_controls={
      ['iron-ore'] = {size='none'},
      ['copper-ore'] = {size='none'},
      ['stone'] = {size='none'},
      ['coal'] = {size='none'},
      ['enemy-base'] = {size='none'},
    },
    width=1,
    height=1
  })
  global.play_area = new_plot('abregado-rae',{x=0,y=0})
  global.play_area_initialized = false
end

local on_player_changed_surface = function(event)
  if global.play_area_initialized == false then
    init_plot('abregado-rae',global.play_area)
    global.play_area_initialized = true
  end
end

local on_player_created = function(event)
  local player = game.players[event.player_index]
  free_builder.set_player_state(player)
  player.set_quick_bar_slot(1,'pu-transport-belt')
  player.set_quick_bar_slot(2,'pu-underground-belt')
  player.set_quick_bar_slot(3,'pu-splitter')
  player.set_quick_bar_slot(4,'pu-loader')
  player.set_quick_bar_slot(5,'pu-inserter')
  player.set_quick_bar_slot(6,'pu-filter-inserter')
  player.set_quick_bar_slot(7,'pu-wire')
  player.set_quick_bar_slot(8,'cm')
  player.set_quick_bar_slot(9,'sto')
  player.set_quick_bar_slot(10,'deconstruction-planner')
  player.set_quick_bar_slot(11,'col')
  player.set_quick_bar_slot(12,'ext')
  player.set_quick_bar_slot(13,'rig')
  player.set_quick_bar_slot(14,'frm')
  player.set_quick_bar_slot(15,'fp')
  player.set_quick_bar_slot(16,'inc')
  player.set_quick_bar_slot(17,'sme')
  player.set_quick_bar_slot(18,'bmp')
  player.set_quick_bar_slot(19,'pp1')
  player.set_quick_bar_slot(20,'wel')
  player.set_quick_bar_slot(21,'chp')
  player.set_quick_bar_slot(22,'clf')
  player.set_quick_bar_slot(23,'fmt')
  player.set_quick_bar_slot(24,'fs')
  player.set_quick_bar_slot(25,'gf')
  player.set_quick_bar_slot(26,'hyf')
  player.set_quick_bar_slot(27,'pol')
  player.set_quick_bar_slot(28,'pp2')
  player.set_quick_bar_slot(29,'ppf')
  player.set_quick_bar_slot(30,'wpl')
  
  welcome.create(player)
end

local on_player_confirm = function(player_index)
  local player = game.players[player_index]
  player.teleport({0,0},'abregado-rae')
  free_builder.set_player_active(player)
end

local on_tick = function(event)
  maint.update(event.tick)
end

local on_gui_click = function(event)
  --if global.play_area_initialized then
    if welcome.on_click(event) == true then
      on_player_confirm(event.player_index)
    end
  --end
end

local on_player_mined_entity = function(event)
  local player = game.players[event.player_index]
  event.buffer.remove('module-1')
  event.buffer.remove('module-2')
  event.buffer.remove('module-3')
  event.buffer.remove('module-4')
  event.buffer.remove('module-5')

  maint.remove_entity(event.entity)
  --free_builder.on_player_mined_entity(event)

  player.get_main_inventory().remove({name='module-1',count=1})
  player.get_main_inventory().remove({name='module-2',count=1})
  player.get_main_inventory().remove({name='module-3',count=1})
  player.get_main_inventory().remove({name='module-4',count=1})
  player.get_main_inventory().remove({name='module-5',count=1})
end

local deny_building = function(event,message)
  local player = game.players[event.player_index]
  player.insert(event.stack)
  player.surface.create_entity{
    name = "tutorial-flying-text",
    text = message,
    position = {
      event.created_entity.position.x,
      event.created_entity.position.y - 1.5
    },
    color = {r = 1, g = 0.2, b = 0}}
  event.created_entity.destroy()
end

local on_built_entity = function(event)
  local near_colony = maint.nearest_colony(event.created_entity.surface.name,event.created_entity.position)
  if event.created_entity.name == 'cm' then
    maint.add_entity(event.created_entity)
    return true
  end
  if not near_colony then
    deny_building(event,{"msg.build-core-module"})
    return false
  elseif math2d.position.distance(near_colony.position,event.created_entity.position) > 100000 and event.created_entity.name ~= 'cm' then
    deny_building(event,{"msg.too-far-from-colony"})
    return false
  else
    maint.add_entity(event.created_entity)
  end

  free_builder.on_built_entity(event)
end

main_events = {
  [defines.events.on_game_created_from_scenario] = on_game_created_from_scenario,
  [defines.events.on_player_created] = on_player_created,
  [defines.events.on_player_changed_surface] = on_player_changed_surface,
  [defines.events.on_tick] = on_tick,
  [defines.events.on_gui_click] = on_gui_click,
  [defines.events.on_player_mined_entity] = on_player_mined_entity,
  [defines.events.on_player_mined_item] = free_builder.on_player_mined_item,
  [defines.events.on_picked_up_item] = free_builder.on_picked_up_item,
  [defines.events.on_player_dropped_item] = free_builder.on_player_dropped_item,
  [defines.events.on_built_entity] = on_built_entity,
  [defines.events.on_player_changed_position] = free_builder.on_player_changed_position,
}

handler.setup_event_handling({main_events})