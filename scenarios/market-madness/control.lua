local handler = require("__base__.lualib.event_handler")
local free_builder = require('free-builder')
local land = require('planetary_real_estate')
local market = require('passive_market')
local maint = require('maint')
local data_import = require('__pu-supply-chain__.data-import')
local math2d = require('math2d')

local make_planet_force = function(name,resource_list)
  local planet_force = game.forces[name] or game.create_force(name)

  for recipe_name, recipe_lua in pairs(planet_force.recipes) do
    if recipe_lua.prototype.group.name == 'production' or
      recipe_lua.prototype.group.name == 'combat' or
      recipe_lua.prototype.group.name == 'logistics' or
--[[      recipe_lua.prototype.subgroup.name == 'settler' or
      recipe_lua.prototype.subgroup.name == 'technician' or
      recipe_lua.prototype.subgroup.name == 'engineer' or
      recipe_lua.prototype.subgroup.name == 'scientist' or]]
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
  free_builder.add_free_item('sto',10)
  free_builder.add_free_item('bmp',10)
  free_builder.add_free_item('col',10)
  free_builder.add_free_item('ext',10)
  free_builder.add_free_item('fp',10)
  free_builder.add_free_item('frm',10)
  free_builder.add_free_item('inc',10)
  free_builder.add_free_item('pp1',10)
  free_builder.add_free_item('rig',10)
  free_builder.add_free_item('sme',10)
  free_builder.add_free_item('wel',10)
  free_builder.add_free_item('chp',10)
  free_builder.add_free_item('clf',10)
  free_builder.add_free_item('fmt',10)
  free_builder.add_free_item('fs',10)
  free_builder.add_free_item('gf',10)
  free_builder.add_free_item('hyf',10)
  free_builder.add_free_item('pol',10)
  free_builder.add_free_item('pp2',10)
  free_builder.add_free_item('ppf',10)
  free_builder.add_free_item('wpl',10)
  free_builder.add_free_item('clr',10)
  free_builder.add_free_item('elp',10)
  free_builder.add_free_item('ivp',10)
  free_builder.add_free_item('lbo',10)
  free_builder.add_free_item('lm',10)
  free_builder.add_free_item('mca',10)
  free_builder.add_free_item('orc',10)
  free_builder.add_free_item('pp3',10)
  free_builder.add_free_item('sca',10)
  free_builder.add_free_item('tnp',10)
  free_builder.add_free_item('aml',10)
  free_builder.add_free_item('apf',10)
  free_builder.add_free_item('asm',10)
  free_builder.add_free_item('pp4',10)
  free_builder.add_free_item('sd',10)
  free_builder.add_free_item('eep',10)
  free_builder.add_free_item('sl',10)
  market.on_load('imp','exp')
  land.on_load()
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
  land.add_plot('abregado-rae',{x=0,y=0})
  land.add_plot('abregado-rae',{x=512,y=0})
  land.add_plot('abregado-rae',{x=512,y=512})
  land.add_plot('abregado-rae',{x=-512,y=0})
  land.add_plot('abregado-rae',{x=-512,y=512})
  land.add_plot('abregado-rae',{x=0,y=512})
  land.add_plot('abregado-rae',{x=-512,y=0})
  land.add_plot('abregado-rae',{x=0,y=-512})

  market.add_npc_supplier('dw',30,75, true)
  market.add_npc_supplier('rat',30,102, true)
end

local on_player_created = function(event)
  local player = game.players[event.player_index]
  free_builder.set_player_state(player)
  land.on_player_created(event)
  market.init_player(player)
  player.set_quick_bar_slot(1,'pu-transport-belt')
  player.set_quick_bar_slot(2,'pu-underground-belt')
  player.set_quick_bar_slot(3,'pu-splitter')
  player.set_quick_bar_slot(4,'loader')
  player.set_quick_bar_slot(5,'pu-inserter')
  player.set_quick_bar_slot(6,'pu-filter-inserter')
  player.set_quick_bar_slot(7,'green-wire')
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

  market.add_sell_order('mcg',500)
  market.add_sell_order('bbh',30)
  market.add_sell_order('bde',30)
  market.add_sell_order('bse',100)
  market.add_sell_order('bta',30)
  market.add_sell_order('rat',200)
  market.add_sell_order('dw',200)
end

local on_tick = function(event)
  local updated = maint.update(event.tick)
  if updated then
    market.update()
  elseif event.tick % 60 == 0 then
    market.update_wallets(math.floor((global.maint_data.next_update-event.tick)/60))
  end
end

local on_gui_click = function(event)
  local player = game.players[event.player_index]
  if event.element.valid then
    if event.element.name == 'buy_land' then
      local plot_data = global.land_data.plots[global.land_data.players[player.name].current_land]
      if plot_data then
        market.add_market_area(player,plot_data.surface,{
          left_top = {
            x = plot_data.position.x - 32,
            y = plot_data.position.y - 32,
          },
          right_bottom = {
            x = plot_data.position.x + 32,
            y = plot_data.position.y + 32,
          }
        })
        plot_data.owner = player.name
        market.buy(player,plot_data.price,1)
        land.update_player(player)
        land.goto_land(player,plot_data.index)
        player.insert({name='cm',count=1})
        --player.insert({name='mcg',count=100})
        --player.insert({name='tru',count=8})
        --player.insert({name='psl',count=12})
        --player.insert({name='lde',count=4})
        --player.insert({name='lse',count=4})
        --player.insert({name='lta',count=4})
      end
    elseif event.element.name =='refresh_market' then
      
    end
  end
  market.on_gui_click(event)
  land.on_gui_click(event)
end

local on_player_joined_game = function(event)
  --TODO: destroy their maint gui if they have one
  local player = game.players[event.player_index]
  player.teleport({0,0},'nauvis')
end

local on_player_changed_land = function(event)
  local player = game.players[event.player_index]
  local player_land = global.land_data.plots[event.land_index]
  if player_land.owner == player.name then
    free_builder.set_player_build_area(player,player_land.view_box)
    free_builder.set_player_active(player)
    player.force = player_land.force
    land.retrieve_player_storage(player,player_land)
  else
    free_builder.set_player_build_area(player,nil)
    free_builder.set_player_inactive(player)
  end
  player.teleport(player_land.position,player_land.surface)
end

local on_player_mined_entity = function(event)
  local player = game.players[event.player_index]
  event.buffer.remove('item-1')
  event.buffer.remove('module-2')
  event.buffer.remove('module-3')
  event.buffer.remove('module-4')
  event.buffer.remove('module-5')

  maint.remove_entity(event.entity)
  market.on_player_mined_entity(event)
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
  elseif math2d.position.distance(near_colony.position,event.created_entity.position) > 100 and event.created_entity.name ~= 'cm' then
    deny_building(event,{"msg.too-far-from-colony"})
    return false
  else
    maint.add_entity(event.created_entity)
  end

  market.on_built_entity(event)
  free_builder.on_built_entity(event)
end

main_events = {
  [defines.events.on_game_created_from_scenario] = on_game_created_from_scenario,
  [defines.events.on_player_created] = on_player_created,
  [defines.events.on_player_joined_game] = on_player_joined_game,
  [defines.events.on_tick] = on_tick,
  [defines.events.on_gui_click] = on_gui_click,
  [defines.events.on_gui_confirmed] = market.on_gui_confirmed,
  [defines.events.on_gui_checked_state_changed] = market.on_gui_checked_state_changed,
  [defines.events.on_player_mined_entity] = on_player_mined_entity,
  [defines.events.on_player_mined_item] = free_builder.on_player_mined_item,
  [defines.events.on_picked_up_item] = free_builder.on_picked_up_item,
  [defines.events.on_player_dropped_item] = free_builder.on_player_dropped_item,
  [defines.events.on_built_entity] = on_built_entity,
  [defines.events.on_player_changed_position] = free_builder.on_player_changed_position,
}

handler.setup_event_handling({main_events})

script.on_event(land.script_events.on_player_changed_land,on_player_changed_land)