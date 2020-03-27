local data_import = require('__pu-supply-chain__.data-import')

local count_supply = function(name)
  local count = 0
  if global.market_data.sell_orders_by_product[name] then
    for _, order in pairs(global.market_data.sell_orders_by_product[name]) do
      count = count + order.count
    end
  end
  return count
end

local count_demand = function(name)
  local count = 0
  if global.market_data.buy_orders_by_product[name] then
    for _, order in pairs(global.market_data.buy_orders_by_product[name]) do
      count = count + order.count
    end
  end
  return count
end

local in_supply = function (name)
  return count_demand(name) < count_supply(name)
end

local create_wallet_gui = function(player)
  local frame = player.gui.left.add({
    type = 'frame',
    name = 'wallet_frame',
    direction = 'vertical',
    caption = {"wallet-gui.heading"}
  })
  frame.add({
    type = 'label',
    caption = {"wallet-gui.balance",0},
    name = 'money'
  })
  frame.add({
    type = 'label',
    caption = {"wallet-gui.market-update",0},
    name = 'time'
  })
  frame.add({
    type = 'button',
    name = 'open_prices',
    caption = {"wallet-gui.open-prices"}
  })
end

local add_price_headers = function(listing_gui)
  local icon = listing_gui.add({
    type = 'label',
    name = 'icon_header',
    caption = ' '
  })
  icon.style.width = 36
  local name = listing_gui.add({
    type = 'label',
    name = 'name_header',
    caption = {"","[font=default-semibold]",{'price-gui.item-name'},"[/font]"}
  })
  name.style.width = 220
  local price = listing_gui.add({
    type = 'label',
    name = 'price_header',
    caption = {"","[font=default-semibold]",{'price-gui.price'},"[/font]"}
  })
  price.style.width = 70
  local demand_count = listing_gui.add({
  type = 'label',
  name = 'dcount_header',
  caption = {"","[font=default-semibold]",{'price-gui.demand'},"[/font]"}
  })
  demand_count.style.width = 70
  local supply_count = listing_gui.add({
  type = 'label',
  name = 'scount_header',
  caption = {"","[font=default-semibold]",{"price-gui.supply"},"[/font]"}
  })
  supply_count.style.width = 70
  local in_supply = listing_gui.add({
    type = 'label',
    name = 'supply_header',
    caption = {"","[font=default-semibold]",{"price-gui.in-supply"},"[/font]"}
  })
  in_supply.style.width = 70
end

local create_price_gui = function(player)
  local frame = player.gui.center.add({
    type = 'frame',
    name = 'market_listing',
    direction = 'vertical',
    caption = {'price-gui.heading'}
  })
  local price_list = frame.add({
    type = 'table',
    name = 'prices',
    column_count = 6
  })
end

local add_icon_label = function(parent,caption,name)
  local new_element = parent.add({
    type = 'label',
    caption = '[item='..caption..']'
  })
  if name then new_element.name = name end
  return new_element
end

local add_text_label = function(parent,caption,name)
  local new_element = parent.add({
    type = 'label',
    caption = caption
  })
  if name then new_element.name = name end
  return new_element
end

local add_check_box = function(parent,state,name)
  local check = parent.add({
    type = 'checkbox',
    name = name,
    state = state or false
  })
end

local add_price_row = function(list_table,name,player)
  --icon, name, price, price_direction, buy check, sell check,
  list_table.add({
    type = 'label',
    caption = '[item='..name..']'
  })
  add_text_label(list_table,game.item_prototypes[name].localised_name)
  add_text_label(list_table,"-")
  local direction = {"price-gui.no"}
  if in_supply(name) then
    direction = {"price-gui.yes"}
  end
  add_text_label(list_table,count_demand(name))
  add_text_label(list_table,count_supply(name))
  add_text_label(list_table,direction)
end

local update_price_gui = function(player)
  if not player.gui.center.market_listing then
    create_price_gui(player)
  end
  local gui = player.gui.center.market_listing
  gui.prices.clear()
  add_price_headers(gui.prices)
  for _, material in pairs(data_import.materials) do
    if #global.market_data.buy_orders_by_product[material.name] > 0 or #global.market_data.sell_orders_by_product[material.name] > 0 then
      add_price_row(gui.prices,material.name,player)
    end
  end
end

local update_wallet_gui = function(player,second_till_next_update)
  if global.market_data.player_wallets[player.name] and not player.gui.left.wallet_frame then
    create_wallet_gui(player)
  end
  if global.market_data.player_wallets[player.name] then
    player.gui.left.wallet_frame.money.caption = {"wallet-gui.balance",tostring(global.market_data.player_wallets[player.name])}
    player.gui.left.wallet_frame.time.caption = {"wallet-gui.market-update",tostring(second_till_next_update)}
  end
end

local update_wallets = function(second_till_next_update)
  for _, player in pairs(game.players) do
    update_wallet_gui(player,second_till_next_update)
  end
end


local add_sell_order = function(name,count,location,player_name,delete_if_not_filled)
  if delete_if_not_filled == nil then local delete_if_not_filled = false end
  if global.market_data.sell_orders_by_product[name] then
    table.insert(global.market_data.sell_orders_by_product[name],{
      count = count,
      location = location,
      player = player_name,
      delete_if_not_filled = delete_if_not_filled,
    })
    return true
  end
  return false
end

local tally_sell_orders = function()
   --remove temporary orders from the last cycle
  for item_name, sell_orders in pairs(global.market_data.sell_orders_by_product) do
    local to_be_deleted = {}
    for index, order in pairs(sell_orders) do
      if order.delete_if_not_filled == true or order.count == 0 then
        table.insert(to_be_deleted,index) 
      end
    end
    table.sort(to_be_deleted,function(a,b) return a > b end)
    for _, index in pairs(to_be_deleted) do
      local order = global.market_data.sell_orders_by_product[item_name][index]
      table.remove(global.market_data.sell_orders_by_product[item_name], index)
    end
  end

  for _, player_area in pairs(global.market_data.player_areas) do
    local name = player_area.name
    local area = player_area.area
    local surface = player_area.surface
    local providers = surface.find_entities_filtered({
    name = global.market_data.export_ent,
    area = area,
    })

    for _, provider in pairs(providers) do
      local contents = provider.get_inventory(defines.inventory.chest).get_contents()
      for item_name, count in pairs(contents) do
        if global.market_data.sell_orders_by_product[item_name] then
          add_sell_order(item_name,count,provider,name,true)
        end
      end
    end
  end

  --add market makers
  for _, raw_data in pairs(global.market_data.npc_supply) do
    if global.market_data.sell_orders_by_product[raw_data.name] then
      table.insert(global.market_data.sell_orders_by_product[raw_data.name],{
        count = raw_data.count or 100,
        location = nil,
        player = nil,
        delete_if_not_filled = raw_data.delete_if_not_filled,
      })
    end
  end

  for item_name, orders in pairs(global.market_data.sell_orders_by_product) do
    table.sort(orders,function(a,b) return a.count < b.count end)
  end
end

local add_buy_order = function(name,count,location,player_name,delete_if_not_filled)
  if delete_if_not_filled == nil then local delete_if_not_filled = false end
  if global.market_data.buy_orders_by_product[name] then
    table.insert(global.market_data.buy_orders_by_product[name],{
      count = count,
      location = location,
      player = player_name,
      delete_if_not_filled = delete_if_not_filled,
    })
    return true
  end
  return false
end

local tally_buy_orders = function()
  --remove temporary orders from the last cycle
  for item_name, buy_orders in pairs(global.market_data.buy_orders_by_product) do
    local to_be_deleted = {}
    for index, order in pairs(buy_orders) do
      if order.delete_if_not_filled == true or order.count == 0 then
        table.insert(to_be_deleted,index) 
      end
    end
    table.sort(to_be_deleted,function(a,b) return a > b end)
    for _, index in pairs(to_be_deleted) do
      local order = global.market_data.buy_orders_by_product[item_name][index]
      table.remove(global.market_data.buy_orders_by_product[item_name], index)
    end
  end

  for _, player_area in pairs(global.market_data.player_areas) do
    local name = player_area.name
    local area = player_area.area
    local surface = player_area.surface

    local requesters = surface.find_entities_filtered({
      name = global.market_data.import_ent,
      area = area,
    })

    for _, requester in pairs(requesters) do
      local slots = requester.request_slot_count
      for slot=1, slots do
        local requested_stack = requester.get_request_slot(slot)
        if requested_stack and requester.get_inventory(defines.inventory.chest).get_item_count(requested_stack.name) == 0 then
          local item_name = requested_stack.name
          add_buy_order(item_name,requested_stack.count,requester,name,true)
        end
      end
    end
  end

  --add market makers
  for _, raw_data in pairs(global.market_data.npc_demand) do
    if global.market_data.buy_orders_by_product[raw_data.name] then
      table.insert(global.market_data.buy_orders_by_product[raw_data.name],{
        count = raw_data.count or 10,
        location = nil,
        player = nil,
        delete_if_not_filled = raw_data.delete_if_not_filled
      })
    end
  end

  for item_name, orders in pairs(global.market_data.buy_orders_by_product) do
    table.sort(orders,function(a,b) return a.count < b.count end)
  end
end

local transfer = function(item_name,from,to)
  local transferred = 0
  if from.location == nil then
    --fake supplier
    transferred = math.min(from.count,to.count)
    --from.count = from.count - transferred
  else
    --real supplier
    transferred = from.location.get_inventory(defines.inventory.chest).remove({name=item_name,count=to.count})
    --from.count = from.count - transferred
  end

  if to.location == nil then
    --fake demander
  elseif transferred > 0 then
    to.location.get_inventory(defines.inventory.chest).insert({name=item_name,count=transferred})
    --to.count = to.count - transferred
  end

  return transferred
end

local process_sales = function()
  for item_name, buy_orders in pairs(global.market_data.buy_orders_by_product) do
    local supply = count_supply(item_name)
    local demand = count_demand(item_name)
    --if supply > 0 or demand > 0 then
    --  print(item_name.." supply: "..supply..", demand: "..demand)
    --end

    local sell_orders = global.market_data.sell_orders_by_product[item_name] or {}
    if supply >= demand then
      --fill all buy_orders
      for _, order in pairs(buy_orders) do
        while order.count > 0 do
          local sold_amount = transfer(item_name,sell_orders[1],order)
          sell_orders[1].count = sell_orders[1].count - sold_amount
          order.count = order.count - sold_amount
          if sell_orders[1].count == 0 then table.insert(sell_orders,table.remove(sell_orders,1)) end
        end
      end
    else
      --fill all sell_orders
      for _, order in pairs(sell_orders) do
        while order.count > 0 do
          local sold_amount = transfer(item_name,order,buy_orders[1])
          order.count = order.count - sold_amount
          buy_orders[1].count = buy_orders[1].count - sold_amount
          if buy_orders[1].count == 0 then table.remove(buy_orders,1) end
        end
      end
    end
  end
end

local add_npc_supplier = function(item_name,count,price,cycle_fixed)
  if cycle_fixed == nil then local cycle_fixed = true end
  table.insert(global.market_data.npc_supply,{
    name = item_name,
    count = count,
    price = price,
    delete_if_not_filled = cycle_fixed
  })
end

local add_npc_customer = function(item_name,count,price,cycle_fixed)
  if cycle_fixed == nil then local cycle_fixed = true end
  table.insert(global.market_data.npc_demand,{
    name = item_name,
    count = count,
    price = price,
    delete_if_not_filled = cycle_fixed
  })
end

local on_gui_click = function(event)
  local player = game.players[event.player_index]
  if event.element.valid and event.element.name == 'open_prices' and player.gui.center.market_listing == nil then
    update_price_gui(player)
    event.element.caption = {"wallet-gui.close-prices"}
  elseif event.element.valid and event.element.name == 'open_prices' and player.gui.center.market_listing then
    player.gui.center.market_listing.destroy()
    event.element.caption = {"wallet-gui.open-prices"}
  end
end

local on_built_entity = function(event)
  if event.created_entity.name == global.market_data.export_ent then
    table.insert(global.market_data.providers,event.created_entity)
  elseif event.created_entity.name == global.market_data.import_ent then
    table.insert(global.market_data.requesters,event.created_entity)
  end
end

local on_player_mined_entity = function(event)
  if event.entity.name == global.market_data.export_ent then
    for index, provider in pairs(global.market_data.providers) do
      if provider == event.entity then
        table.remove(global.market_data.providers,index)
        break
      end
    end
  elseif event.entity.name == global.market_data.import_ent then
    for index, requester in pairs(global.market_data.requesters) do
      if requester == event.entity then
        table.remove(global.market_data.requesters,index)
        break
      end
    end
  end
end

local player_buy = function(player,price,count)
  if type(player) == 'string' then player = game.players[player] end
  if player then
    global.market_data.player_wallets[player.name] = global.market_data.player_wallets[player.name] - (price*count)
    update_wallet_gui(game.players[player.name])
  end
end

local player_sell = function(player,price,count)
  if type(player) == 'string' then player = game.players[player] end
  if player then
    global.market_data.player_wallets[player.name] = global.market_data.player_wallets[player.name] + (price*count)
    update_wallet_gui(game.players[player.name])
  end
end

local on_gui_checked_state_changed = function(event)

end

local on_gui_confirmed = function(event)

end

local market = {}

market.add_market_area = function(player,surface,area)
  table.insert(global.market_data.player_areas,{name=player.name,surface=surface,area=area})
end

market.buy = player_buy
market.sell = player_sell
market.add_sell_order = add_sell_order
market.add_buy_order = add_buy_order
market.update_wallets = update_wallets
market.on_gui_confirmed = on_gui_confirmed
market.on_gui_checked_state_changed = on_gui_checked_state_changed
market.on_gui_click = on_gui_click
market.on_player_mined_entity = on_player_mined_entity
market.on_built_entity = on_built_entity

market.init_player = function(player)
  global.market_data.player_wallets[player.name] = 300000
  update_wallet_gui(player)
end

market.update = function()
  tally_sell_orders()
  tally_buy_orders()
  process_sales()
end

market.on_load = function(import_ent,export_ent)
  global.market_data = {
    requesters = {},
    providers = {},
    sell_orders_by_product = {},
    buy_orders_by_product = {},
    player_wallets ={},
    player_areas={},
    import_ent = import_ent,
    export_ent = export_ent,
    npc_supply = {},
    npc_demand = {},
  }

  for _, item in pairs(data_import.materials) do
    global.market_data.sell_orders_by_product[item.name] = {}
    global.market_data.buy_orders_by_product[item.name] = {}
  end
end

market.add_npc_customer = add_npc_customer
market.add_npc_supplier = add_npc_supplier
market.in_supply = in_supply

return market