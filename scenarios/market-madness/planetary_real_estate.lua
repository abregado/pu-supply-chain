local free_builder = require('free-builder')

local land = {}
land.script_events = {
  on_player_changed_land = script.generate_event_name()
}

local create_land_gui = function(player)
  local frame = player.gui.left.add({
    type = 'frame',
    name = 'land_frame',
    direction = 'vertical',
    caption = 'Your colonies'
  })
  local controls = frame.add({
    type = 'table',
    name = 'land_controls',
    column_count = 3,
  })
  controls.add({
    type = 'button',
    name = 'previous_land',
    caption = "<"
  })
  controls.add({
    type = 'label',
    name = 'current_land_name',
    caption = "no land"
  })
  controls.add({
    type = 'button',
    name = 'next_land',
    caption = ">"
  })
end

local update_land_gui = function(player)
  if not player.gui.left.land_frame then
    create_land_gui(player)
  end
  if player.gui.left.land_frame.owner_label then player.gui.left.land_frame.owner_label.destroy() end
  if player.gui.left.land_frame.buy_land then player.gui.left.land_frame.buy_land.destroy() end
  local prev = player.gui.left.land_frame.land_controls.previous_land
  local next = player.gui.left.land_frame.land_controls.next_land
  local current = player.gui.left.land_frame.land_controls.current_land_name
  local current_player_land = global.land_data.players[player.name].current_land
  local current_land_data = global.land_data.plots[current_player_land] or nil
  if current_land_data then
    current.caption = current_land_data.name
  else
    current.caption = 'No land selected'
  end
  if global.land_data.plots[current_player_land+1] then
    next.enabled = true
  else
    next.enabled = false
  end
  if global.land_data.plots[current_player_land-1] then
    prev.enabled = true
  else
    prev.enabled = false
  end
  if current_land_data and current_land_data.owner then
    player.gui.left.land_frame.add({
      type = 'label',
      caption = 'owner: '..current_land_data.owner,
      name = 'owner_label'
    })
  elseif current_player_land > 0 then
    player.gui.left.land_frame.add({
      type = 'button',
      caption = 'Buy: '..current_land_data.price,
      name = 'buy_land'
    })
  end
end

local new_plot = function(surface,position)
  local size = 32
  local plot = {
    name = surface.name..'-'..tostring(position.x)..'-'..tostring(position.y),
    index = #global.land_data.plots+1,
    surface = surface,
    position = position,
    force = 'montem',
    initialized = false,
    view_box = {
      left_top = {
        x = position.x - (size/2),
        y = position.y - (size/2),
      },
      right_bottom = {
        x = position.x + (size/2),
        y = position.y + (size/2),
      },
    },
    price = 10000,
    player_storage = {},
  }
  table.insert(global.land_data.plots,plot)
  surface.request_to_generate_chunks(position,1)
end

local store_player_items = function(player,plot)
  local inv = player.get_main_inventory()
  if inv then
    for name,count in pairs(inv.get_contents()) do
      table.insert(plot.player_storage,{name=name,count=count})
    end
    inv.clear()
  end
end

local retrieve_player_storage = function(player,plot)
  for _, stack in pairs(plot.player_storage) do
    player.insert(stack)
  end
  plot.player_storage = {}
end

local init_plot = function(plot)
  local surface = plot.surface
  local position = plot.position
  local tiles = {}
  for x = plot.view_box.left_top.x, plot.view_box.right_bottom.x do
    for y = plot.view_box.left_top.y, plot.view_box.right_bottom.y do
      local tile_type = 'lab-dark-1'
      if (x+y)%2 == 0 then tile_type = 'lab-dark-2' end
      table.insert(tiles,{name=tile_type,position={x=x,y=y}})
    end
  end
  plot.surface.set_tiles(tiles)
  local buy = surface.create_entity({
    name = 'imp',
    position = {
      x = position.x - 15,
      y = position.y
    },
    force = plot.force
  })
  local sell = surface.create_entity({
    name = 'exp',
    position = {
      x = position.x + 15,
      y = position.y
    },
    force = plot.force
  })
  buy.minable = false
  sell.minable = false
  buy.destructible = false
  sell.destructible = false
  plot.initialized = true
end

local goto_land = function(player,land_index)
  if global.land_data.plots[land_index] then
    local current_land = global.land_data.plots[global.land_data.players[player.name].current_land]
    if player.get_main_inventory() then
      free_builder.remove_free_items(player)
    end
    store_player_items(player,current_land)
    local plot_data = global.land_data.plots[land_index]
    player.teleport(plot_data.position,plot_data.surface)
    global.land_data.players[player.name].current_land = land_index
    update_land_gui(player)
    if plot_data.initialized == false then
      init_plot(plot_data)
    end
    script.raise_event(land.script_events.on_player_changed_land,{
      player_index = player.index,
      land_index = land_index,
    })
  end
end

local on_gui_click = function(event)
  local player = game.players[event.player_index]
  if event.element.valid then
    if event.element.name == 'next_land' then
      if global.land_data.plots[global.land_data.players[player.name].current_land+1] then
        goto_land(player,global.land_data.players[player.name].current_land+1)
      end
    elseif event.element.name == 'previous_land' then
      if global.land_data.plots[global.land_data.players[player.name].current_land-1] then
        goto_land(player,global.land_data.players[player.name].current_land-1)
      end
    end
  end
end

local on_player_created = function(event)
  local player = game.players[event.player_index]
  global.land_data.players[player.name] = {
    current_land = 0
  }
  update_land_gui(player)
end

land.update_player = update_land_gui

land.add_plot = function(surface_name,position)
  local surface = game.surfaces[surface_name] or game.create_surface(surface_name)
  new_plot(surface,position)
end

land.on_load = function()
  global.land_data = {
    plots = {},
    players = {}
  }
end

land.on_gui_click = on_gui_click
land.on_player_created = on_player_created
land.goto_land = goto_land
land.retrieve_player_storage = retrieve_player_storage

return land