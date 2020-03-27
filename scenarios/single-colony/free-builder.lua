local data_import = require('__pu-supply-chain__.data-import')

local free_builder = {}

local structure_list = {}

free_builder.add_free_item =function(item_name,item_cost)
  global.free_builder_data.free_items[item_name] = {name = item_name,cost = item_cost}
end

free_builder.on_load = function ()
  global.free_builder_data = {
    players = {},
    free_items = {},
    value = 0
  }
  for _, item_data in pairs(structure_list) do
    global.free_builder_data.free_items[item_data[1]] = {name = item_data[1],cost = item_data[2]}
  end
end

free_builder.set_player_state = function(player,state)
  if not global.free_builder_data.players[player.name] then
    global.free_builder_data.players[player.name] = {
      player_data = player
    }
  end

  local old_character = player.character
  player.character = nil
  old_character.destroy()


  if state then
    free_builder.set_player_active(player)
  else
    free_builder.set_player_inactive(player)
  end
end

free_builder.set_player_inactive = function(player)
  player.set_controller({type = defines.controllers.ghost})
end

free_builder.remove_free_items = function(player)
  for name, _ in pairs(global.free_builder_data.free_items) do
    local inv = player.get_main_inventory()
    if inv.get_item_count(name) > 0 then
      inv.remove({name=name,count=1})
    end
  end
end

free_builder.add_free_items = function(player)
  free_builder.remove_free_items(player)
  
  for _, name in pairs(global.free_builder_data.free_items) do
    player.insert({name=name.name,count=1})
  end
end

free_builder.set_player_active = function(player)
  player.print({'free-builder.welcome-message'})
  player.set_controller({type = defines.controllers.god})
  free_builder.add_free_items(player)
end

free_builder.get_value = function()
  return global.free_builder_data.value
end

local on_built_entity = function(event)
  local player = game.players[event.player_index]
  if global.free_builder_data.players[player.name] then
    if global.free_builder_data.free_items[event.created_entity.name] and player.cursor_stack.valid_for_read == false then
      player.insert(event.stack)
      local recipe = player.force.recipes[event.created_entity.name]
      if recipe then
        --add buy orders for these items
        for _, ingredient in pairs(recipe.ingredients) do
          market.add_buy_order(ingredient.name,ingredient.amount,nil,nil,false)
        end
      end
    end
    free_builder.add_free_items(player)
  end
end

local on_player_dropped_item = function(event)
  local player = game.players[event.player_index]
  if global.free_builder_data.players[player.name] then
    if global.free_builder_data.free_items[event.entity.stack.name] then
      player.insert(event.entity.stack)
    end
  end
  event.entity.destroy()
end

local on_player_mined_item = function(event)
  --local player = game.players[event.player_index]
  --if global.free_builder_data.players[player.name] then
  --  if global.free_builder_data.free_items[event.item_stack.name] then
  --    game.players[event.player_index].remove_item(event.item_stack)
  --  end
  --end
end

local on_picked_up_item = function(event)
  --local player = game.players[event.player_index]
  --if global.free_builder_data.players[player.name] then
  --  if global.free_builder_data.free_items[event.item_stack.name] then
  --    game.players[event.player_index].remove_item(event.item_stack)
  --  end
  --end
end

--local on_player_mined_entity = function(event)
--  local player = game.players[event.player_index]
--  if global.free_builder_data.players[player.name] then
--    if global.free_builder_data.free_items[event.entity.name] then
--      if not player.force.recipes[event.entity.name] then
--        --TODO: only take the mining result from the item
--        --event.buffer.clear()
--
--      end
--    end
--  end
--end

local on_player_changed_position = function(event)
  local player = game.players[event.player_index]
  if global.free_builder_data.players[player.name] and global.free_builder_data.players[player.name].view_box then
    local box = global.free_builder_data.players[player.name].view_box
    if player.position.x > box.right_bottom.x then player.teleport({x=box.right_bottom.x,y=player.position.y}) end
    if player.position.x < box.left_top.x then player.teleport({x=box.left_top.x,y=player.position.y}) end
    if player.position.y > box.right_bottom.y then player.teleport({x=player.position.x,y=box.right_bottom.y}) end
    if player.position.y < box.left_top.y then player.teleport({x=player.position.x,y=box.left_top.y}) end
  end
end

free_builder.set_player_build_area = function(player,bounding_box)
  if global.free_builder_data.players[player.name] then
    global.free_builder_data.players[player.name].view_box = bounding_box
  end
end

free_builder.on_player_mined_entity = on_player_mined_entity
free_builder.on_picked_up_item = on_picked_up_item
free_builder.on_player_mined_item = on_player_mined_item
free_builder.on_player_dropped_item = on_player_dropped_item
free_builder.on_built_entity = on_built_entity
free_builder.on_player_changed_position = on_player_changed_position

return free_builder