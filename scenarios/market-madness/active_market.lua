local data_import = require('__pu-supply-chain__.data-import')

local add_order_headers = function(order_gui)
  local name = order_gui.add({
    type = 'label',
    name = 'item_header',
    caption = 'Commodity'
  })
  name.style.width = 150
  local buy = order_gui.add({
    type = 'label',
    name = 'buy_header',
    caption = 'Buy'
  })
  buy.style.width = 70
  local sell = order_gui.add({
    type = 'label',
    name = 'sell_header',
    caption = 'Sell'
  })
  sell.style.width = 70
  local stocks = order_gui.add({
    type = 'label',
    name = 'stock_header',
    caption = 'Stock'
  })
  sell.style.width = 70
end

local create_wallet_gui = function(player)
  local frame = player.gui.left.add({
    type = 'frame',
    name = 'wallet_frame',
    direction = 'vertical',
    caption = 'Wallet'
  })
  frame.add({
    type = 'label',
    caption = 'Cash: 0$',
    name = 'money'
  })
  frame.add({
    type = 'label',
    caption = 'Time until next market update: 0s',
    name = 'time'
  })
end

local add_price_headers = function(listing_gui)
  local icon = listing_gui.add({
    type = 'label',
    name = 'icon_header',
    caption = 'Icon'
  })
  icon.style.width = 36
  local name = listing_gui.add({
    type = 'label',
    name = 'name_header',
    caption = 'Item name'
  })
  name.style.width = 220
  local ask = listing_gui.add({
    type = 'label',
    name = 'ask_header',
    caption = 'Ask Price'
  })
  ask.style.width = 70
  local bid = listing_gui.add({
    type = 'label',
    name = 'bid_header',
    caption = 'Bid Price'
  })
  bid.style.width = 70
  local stocks = listing_gui.add({
    type = 'label',
    name = 'stock_header',
    caption = 'Supply'
  })
  stocks.style.width = 70
end

local create_price_gui = function(player)
  local frame = player.gui.center.add({
    type = 'frame',
    name = 'market_listing',
    direction = 'vertical',
    caption = 'Market Prices'
  })
  local price_list = frame.add({
    type = 'table',
    name = 'prices',
    column_count = 5
  })
end

local add_price_row = function(list_table,name)
  list_table.add({
    type = 'label',
    caption = '[item='..name..']'
  })
  list_table.add({
    type = 'label',
    caption = game.item_prototypes[name].localised_name,
  })
  if global.market_data.sell_orders_by_product[name] and #global.market_data.sell_orders_by_product[name] > 0 then
    list_table.add({
      type = 'label',
      caption = global.market_data.sell_orders_by_product[name][1].price,
    })
  else
    list_table.add({
      type = 'label',
      caption = '-',
    })
  end
  if global.market_data.buy_orders_by_product[name] and #global.market_data.buy_orders_by_product[name] > 0 then
    list_table.add({
      type = 'label',
      caption = global.market_data.buy_orders_by_product[name][1].price,
    })
  else
    list_table.add({
      type = 'label',
      caption = "-",
    })
  end
  if global.market_data.sell_orders_by_product[name] and #global.market_data.sell_orders_by_product[name] > 0 then
    list_table.add({
      type = 'label',
      caption = global.market_data.sell_orders_by_product[name][1].count,
    })
  else
    list_table.add({
      type = 'label',
      caption = 0,
    })
  end
end

local update_price_gui = function(player)
  if not player.gui.center.market_listing then
    create_price_gui(player)
  end
  local gui = player.gui.center.market_listing
  gui.prices.clear()
  add_price_headers(gui.prices)
  for _, material in pairs(data_import.materials) do
    if (global.market_data.buy_orders_by_product[material.name] and #global.market_data.buy_orders_by_product[material.name] > 0) or
            (global.market_data.sell_orders_by_product[material.name] and #global.market_data.sell_orders_by_product[material.name] >0) then
      add_price_row(gui.prices,material.name)
    end
  end
end

local update_wallet_gui = function(player,second_till_next_update)
  if not player.gui.left.wallet_frame then
    create_wallet_gui(player)
  end
  player.gui.left.wallet_frame.money.caption = 'Cash: $'..tostring(global.market_data.player_wallets[player.name])
  player.gui.left.wallet_frame.time.caption = 'Time until next market update: : '..tostring(second_till_next_update)..' seconds'
end

local update_wallets = function(second_till_next_update)
  for _, player in pairs(game.players) do
    update_wallet_gui(player,second_till_next_update)
  end
end

local create_market_gui = function(player)
  local frame = player.gui.left.add({
    type = 'frame',
    name = 'market_frame',
    direction = 'vertical',
    caption = 'Local Market Settings'
  })
  local order_gui = frame.add({
    type = 'table',
    name = 'market_orders',
    column_count = 4,
    draw_vertical_lines = true,
  })
  add_order_headers(order_gui)
  frame.add({
    type = 'button',
    name = 'refresh_market',
    caption = "Refresh"
  })
  frame.add({
    type = 'button',
    name = 'open_prices',
    caption = "Open Prices"
  })
end

local refresh_market_gui = function(player)
  if not player.gui.left.market_frame then
    create_market_gui(player)
  end
  local market_orders = player.gui.left.market_frame.market_orders
  market_orders.clear()
  add_order_headers(market_orders)
  local item_names = {}
  for _, market_area in pairs(global.market_data.player_areas) do
    if market_area.name == player.name then
      local surface = market_area.surface
      local area = market_area.area

      --tally items
      local providers = surface.find_entities_filtered({
        name = global.market_data.export_ent,
        area = area,
      })
      for _, provider in pairs(providers) do
        local contents = provider.get_inventory(defines.inventory.chest).get_contents()
        for item_name, count in pairs(contents) do
          if item_names[item_name] then
            item_names[item_name] = item_names[item_name] + count
          else
            item_names[item_name] = count
          end
        end
      end
      local requesters = surface.find_entities_filtered({
        name = global.market_data.import_ent,
        area = area,
      })
      for _, requester in pairs(requesters) do
        local slots = requester.request_slot_count
        for slot=1, slots do
          local requested_stack = requester.get_request_slot(slot)
          if requested_stack then
            if item_names[requested_stack.name] then
              item_names[requested_stack.name] = item_names[requested_stack.name] + requester.get_inventory(defines.inventory.chest).get_item_count(requested_stack.name)
            else
              item_names[requested_stack.name] = 0
            end
          end
        end
      end
    end
  end

  for item_name, stock in pairs(item_names) do
    market_orders.add({
      type = 'label',
      name = item_name..'-name',
      caption = item_name,
    })
    local saved_prices = global.market_data.player_prices[player.name][item_name] or {}
    if saved_prices.buy_active then
      local buy = market_orders.add({
        type = 'textfield',
        name = 'buyprice_'..item_name,
        numeric = true,
        allow_negative = false,
        allow_decimal = true,
        text = saved_prices.buy,
      })
      buy.style.width = 70
    else
      local buy = market_orders.add({
        type = 'checkbox',
        name = 'buycheck_'..item_name,
        state = false
      })
      buy.style.width = 70
    end

    if saved_prices.sell_active then
      local sell = market_orders.add({
        type = 'textfield',
        name = 'sellprice_'..item_name,
        numeric = true,
        allow_negative = false,
        allow_decimal = true,
        text = saved_prices.sell
      })
      sell.style.width = 70
    else
      local sell = market_orders.add({
        type = 'checkbox',
        name = 'sellcheck_'..item_name,
        state = false
      })
      sell.style.width = 70
    end

    market_orders.add({
      type = 'label',
      name = item_name..'-stock',
      caption = stock,
    })
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

local tally_sell_orders = function()
  global.market_data.sell_orders_by_product = {}

  for _, player_area in pairs(global.market_data.player_areas) do
    local name = player_area.name
    local area = player_area.area
    local surface = player_area.surface
    local providers = surface.find_entities_filtered({
    name = global.market_data.export_ent,
    area = area,
    })

    for _, provider in pairs(providers) do
      print(provider.name)
      local contents = provider.get_inventory(defines.inventory.chest).get_contents()
      for item_name, count in pairs(contents) do
        if global.market_data.player_prices[name][item_name] and global.market_data.player_prices[name][item_name].sell then
          print(item_name.."sold at: "..global.market_data.player_prices[name][item_name].sell)
          if not global.market_data.sell_orders_by_product[item_name] then
            global.market_data.sell_orders_by_product[item_name] = {}
          end
          table.insert(global.market_data.sell_orders_by_product[item_name],{
            count = count,
            location = provider,
            price = tonumber(global.market_data.player_prices[name][item_name].sell),
            player = name
          })
        end
      end
    end
  end

  --add market makers
  for _, raw_data in pairs(global.market_data.npc_supply) do
    if not global.market_data.sell_orders_by_product[raw_data.name] then
      global.market_data.sell_orders_by_product[raw_data.name] = {}
    end
    table.insert(global.market_data.sell_orders_by_product[raw_data.name],{count = raw_data.count or 100, price = raw_data.price, location = nil, player = nil})
  end

  for item_name, orders in pairs(global.market_data.sell_orders_by_product) do
    --print(item_name..": "..serpent.line(orders))
    table.sort(orders,function(a,b) return a.price < b.price end)
  end
end


local tally_buy_orders = function()
  global.market_data.buy_orders_by_product = {}

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
          if global.market_data.player_prices[name][item_name] and global.market_data.player_prices[name][item_name].buy then
            if not global.market_data.buy_orders_by_product[item_name] then
              global.market_data.buy_orders_by_product[item_name] = {}
            end
            table.insert(global.market_data.buy_orders_by_product[item_name],{
              count = requested_stack.count,
              location = requester,
              price = tonumber(global.market_data.player_prices[name][item_name].buy),
              player = name
            })
          end
        end
      end
    end
  end

  --add market makers
  for _, raw_data in pairs(global.market_data.npc_demand) do
    if not global.market_data.buy_orders_by_product[raw_data.name] then
      global.market_data.buy_orders_by_product[raw_data.name] = {}
    end
    table.insert(global.market_data.buy_orders_by_product[raw_data.name],{count = raw_data.count or 10, price = raw_data.price, location = nil, player = nil})
    table.insert(global.market_data.buy_orders_by_product[raw_data.name],{count = (raw_data.count and raw_data.count * 10) or 100, price = raw_data.price/2, location = nil, player = nil})
    table.insert(global.market_data.buy_orders_by_product[raw_data.name],{count = (raw_data.count and raw_data.count * 40) or 400, price = raw_data.price/4, location = nil, player = nil})
  end

  for item_name, orders in pairs(global.market_data.buy_orders_by_product) do
    table.sort(orders,function(a,b) return a.price > b.price end)
  end
end

local transfer = function(item_name,from,to)
  local transferred = 0
  if not from.location then
    --fake supplier
    transferred = math.min(from.count,to.count)
    --from.count = from.count - transferred
  else
    --real supplier
    transferred = from.location.get_inventory(defines.inventory.chest).remove({name=item_name,count=to.count})
    --from.count = from.count - transferred
  end

  if not to.location then
    --fake demander
  else
    to.location.get_inventory(defines.inventory.chest).insert({name=item_name,count=transferred})
    --to.count = to.count - transferred
  end

  return transferred
end

local player_buy = function(player,price,count)
  if type(player) == 'string' then player = game.players[player] end
  if player then
    global.market_data.player_wallets[player.name] = global.market_data.player_wallets[player.name] - (price*count)
    --game.print(game.tick..':transaction: '..tostring(price*count*-1))
    update_wallet_gui(game.players[player.name])
  end
end

local player_sell = function(player,price,count)
  if type(player) == 'string' then player = game.players[player] end
  if player then
    global.market_data.player_wallets[player.name] = global.market_data.player_wallets[player.name] + (price*count)
    --game.print(game.tick..':transaction: '..tostring(price*count))
    update_wallet_gui(game.players[player.name])
  end
end

local process_sales = function()
  for item_name, buy_orders in pairs(global.market_data.buy_orders_by_product) do
    if global.market_data.sell_orders_by_product[item_name] and #global.market_data.sell_orders_by_product[item_name] > 0 then
      for _, buy_order in pairs(buy_orders) do
        local sell_orders = global.market_data.sell_orders_by_product[item_name] or {}
        while #sell_orders > 0 and buy_order.price >= sell_orders[1].price and buy_order.count > 0 do
          local sold_amount = transfer(item_name,sell_orders[1],buy_order)
          player_buy(buy_order.player,sell_orders[1].price,sold_amount)
          player_sell(sell_orders[1].player,sell_orders[1].price,sold_amount)
          buy_order.count = buy_order.count - sold_amount
          sell_orders[1].count = sell_orders[1].count - sold_amount
          --game.print("matched sale for "..item_name.." buy count="..buy_order.count..", sell count="..sell_orders[1].count)
          if sell_orders[1].count == 0 then table.remove(sell_orders,1) end
        end
      end
    end
  end
end

local add_npc_supplier = function(item_name,count,price)
  table.insert(global.market_data.npc_supply,{
    name = item_name,
    count = count,
    price = price
  })
end

local add_npc_customer = function(item_name,count,price)
  table.insert(global.market_data.npc_demand,{
    name = item_name,
    count = count,
    price = price
  })
end

local on_gui_click = function(event)
  local player = game.players[event.player_index]
  if event.element.valid and event.element.name == 'refresh_market' then
    refresh_market_gui(player)
  elseif event.element.valid and event.element.name == 'open_prices' and player.gui.center.market_listing == nil then
    update_price_gui(player)
    event.element.caption = "Close Prices"
  elseif event.element.valid and event.element.name == 'open_prices' and player.gui.center.market_listing then
    player.gui.center.market_listing.destroy()
    event.element.caption = "Open Prices"
  end
end

local on_gui_checked_state_changed = function(event)
  if event.element.valid then
    local player = game.players[event.player_index]
    local splits = {}
    for word in string.gmatch(event.element.name,"([^_]+)") do
      table.insert(splits,word)
    end
    if splits[1] == 'buycheck' then
      if global.market_data.player_prices[player.name][splits[2]] then
        global.market_data.player_prices[player.name][splits[2]].buy_active = true
      else
        global.market_data.player_prices[player.name][splits[2]] = {
          buy = 0,
          sell = 0,
          buy_active = true,
          sell_active = false,
        }
      end
      refresh_market_gui(player)
    elseif splits[1] == 'sellcheck' then
      if global.market_data.player_prices[player.name][splits[2]] then
        global.market_data.player_prices[player.name][splits[2]].sell_active = true
      else
        global.market_data.player_prices[player.name][splits[2]] = {
          buy = 0,
          sell = 0,
          buy_active = false,
          sell_active = true,
        }
      end
      refresh_market_gui(player)
    end
  end
end

local on_gui_confirmed = function(event)
  if event.element.valid then
    local player = game.players[event.player_index]
    local splits = {}
    for word in string.gmatch(event.element.name,"([^_]+)") do
      table.insert(splits,word)
    end
    if splits[1] == 'buyprice' then
      if event.element.text ~= "" and tonumber(event.element.text) > 0 then
        global.market_data.player_prices[player.name][splits[2]].buy = tonumber(event.element.text)
        player.print("Updated buy price for "..splits[2].." to "..event.element.text)
      else
        global.market_data.player_prices[player.name][splits[2]].buy_active = false
        player.print("Stopped buying "..splits[2])
      end
      refresh_market_gui(player)
    elseif splits[1] == 'sellprice' then
      if event.element.text ~= "" and tonumber(event.element.text) > 0 then
        global.market_data.player_prices[player.name][splits[2]].sell = tonumber(event.element.text)
        player.print("Updated sell price for "..splits[2].." to "..event.element.text)
      else
        global.market_data.player_prices[player.name][splits[2]].sell_active = false
        player.print("Stopped selling "..splits[2])
      end
      refresh_market_gui(player)
    end

  end
end

local market = {}

market.add_market_area = function(player,surface,area)
  table.insert(global.market_data.player_areas,{name=player.name,surface=surface,area=area})
end

market.buy = player_buy
market.sell = player_sell
market.update_wallets = update_wallets
market.on_gui_confirmed = on_gui_confirmed
market.on_gui_checked_state_changed = on_gui_checked_state_changed
market.on_gui_click = on_gui_click
market.on_player_mined_entity = on_player_mined_entity
market.on_built_entity = on_built_entity

market.init_player = function(player)
  global.market_data.player_prices[player.name] = {}
  global.market_data.player_wallets[player.name] = 300000
  update_wallet_gui(player)
  create_market_gui(player)
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
    player_prices = {},
    player_wallets ={},
    player_areas={},
    import_ent = import_ent,
    export_ent = export_ent,
    npc_supply = {},
    npc_demand = {},
  }
end

market.add_npc_customer = add_npc_customer
market.add_npc_supplier = add_npc_supplier

return market