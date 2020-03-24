local math2d = require("math2d")
local data_import = require('__pu-supply-chain__.data-import')
local constants = require('__pu-supply-chain__.constants')


local base_costs = {}
base_costs[1] = {
  {{'dw',4}},
  {{'rat',4}},
  {{'ove',0.5}},
  {{'cof',0.5}},
  {{'pwo',0.2}},

}
base_costs[2] = {
  {{'dw',5}},
  {{'rat',6},{'exo',0.5}},
  {{'pt',0.5}},
  {{'kom',1}},
  {{'rep',0.2}},
}
base_costs[3] = {
  {{'dw',7.5}},
  {{'hms',0.5},{'rat',7}},
  {{'med',0.5},{'scn',0.5}},
  {{'ale',1}},
  {{'sc',0.1}},
}
base_costs[4] = {
  {{'dw',10}},
  {{'fim',7},{'med',0.5},},
  {{'hss',0.1},{'pda',0.1}},
  {{'gin',1}},
  {{'vg',0.2}},
}
base_costs[5] = {
  {{'dw',10}},
  {{'med',0.5},{'mea',7}},
  {{'lc',0.2},{'ws',0.1}},
  {{'win',1}},
  {{'nst',0.1}},
}

local work_state_modules = {
    'module-1',
    'module-2',
    'module-3',
    'module-4',
    'module-5',
}

local create_maint_gui = function(player)
  --TODO: show what is needed for next level
    local frame = player.gui.left.add({
        type = 'frame',
        direction = 'vertical',
        name = 'maint_gui',
        caption = {'maint-gui.heading'}
    })
    frame.add({
        type = 'label',
        caption = {"maint-gui.population",0,0,0,0,0},
        name = 'population'
    })
    frame.add({
        type = 'label',
        caption = {"maint-gui.hapiness",0},
        name = 'happiness'
    })
    frame.add({
        type = 'table',
        name = 'costs_table',
        column_count = 4
    })
end

local add_cost_headers = function(gui)
    gui.add({
        type = "label",
        caption = "",
        name = "cost_icon_header"
    })
    gui.add({
        type = "label",
        caption = {"maint-gui.item-name-header"},
        name = "cost_item_header"
    })
    gui.add({
        type = "label",
        caption = {"maint-gui.item-cost-header"},
        name = "cost_quant_header"
    })
    gui.add({
        type = "label",
        caption = {"maint-gui.storage-header"},
        name = "cost_stored_header"
    })
end

local update_maint_gui = function(player,colony)
    if not player.gui.left.maint_gui then
        create_maint_gui(player)
    end
    local pop_label = player.gui.left.maint_gui.population
    local hap_label = player.gui.left.maint_gui.happiness
    local cost_table = player.gui.left.maint_gui.costs_table
    cost_table.clear()
    add_cost_headers(cost_table)
    if colony.costs == nil then colony.costs = {0,0,0,0,0} end
  --TODO: display needs broken up by level
    for name, cost in pairs(colony.costs) do
        if cost > 0 then
            cost_table.add({
                type = 'label',
                caption = "[item="..name.."]"
            })
            cost_table.add({
                type = 'label',
                caption = {"item-name."..name}
            })
            cost_table.add({
                type = 'label',
                caption = tostring(cost)
            })
            cost_table.add({
                type = 'label',
                caption = colony.core.get_inventory(defines.inventory.chest).get_item_count(name)
            })
        end
    end
    pop_label.caption = {"maint-gui.population",colony.population[1],colony.population[2],colony.population[3],colony.population[4],colony.population[5]}
    hap_label.caption = {"maint-gui.happiness",colony.work_state}
end

local safe_remove = function(inventory,stack)
    if stack.count > 0 then
        inventory.remove(stack)
    end
end

local pay_costs = function(colony)
  local inventory = colony.core.get_inventory(defines.inventory.chest)
  local production_stats = colony.force.item_production_statistics
  for name, count in pairs(colony.costs) do
    inventory.remove({name=name,count=count})
    production_stats.on_flow(name,count*-1)
  end
end

local apply_work_state = function(colony)
  for _, structure in pairs(colony.structures) do
    local mod_inv = structure.get_module_inventory()
    if mod_inv then
      mod_inv.clear()
    end
    if colony.work_state > 0 then
      if mod_inv then
        mod_inv.insert(work_state_modules[colony.work_state])
      end
    else
      structure.active = false
      structure.order_deconstruction(colony.force)
    end
  end
  pay_costs(colony)
end

local new_colony = function(core_module)
    table.insert(global.maint_data.colonies,{
    core = core_module,
    surface = core_module.surface.name,
    position = core_module.position,
    structures = {},
    force = core_module.force,
    population = {0,0,0,0,0},
    work_state = 0,
    })
    game.print({'msg.new-colony-created'})
end

local can_pay_costs = function(colony,cost_list)
  --if #cost_list == 0 then return false end
  local inventory = colony.core.get_inventory(defines.inventory.chest)
  for name, count in pairs(cost_list) do
    if count > 0 and inventory.get_item_count(name) < count then
      --print("dont have enough "..name.." "..tonumber(inventory.get_item_count(name)).."/"..count)
      return false
    end
  end
  return true
end

local calc_level_needs = function(population,level)
  local workers = population
  assert(population ~= nil and type(population) == 'table' and #population == 5,"tried to use incorrect population object")
  local costs = {}
  for index, pop in pairs(workers) do
    for l = 1, level do
      for _, item in pairs(base_costs[index][l]) do
        local cost = math.floor(item[2]/100*pop)
        if cost > 0 and costs[item[1]] then
          costs[item[1]] = costs[item[1]] + cost
        elseif cost > 0 then
          costs[item[1]] = cost
        end
      end
    end
  end
  print("checked costs at level "..level..": "..serpent.line(costs))
  return costs
end

local len = function(list)
  local count = 0
  for _, _ in pairs(list) do
    count = count + 1
  end
  return count
end

local calc_colony_work_state = function(colony)
  colony.costs = {}
  colony.work_state = 0
  for l = 5, 1, -1 do
    local level_costs = calc_level_needs(colony.population,l)

    if len(level_costs) > 0 and can_pay_costs(colony,level_costs) == true then
      print("can pay costs at level "..l)
      colony.costs = level_costs
      colony.work_state = l
      return
    end
  end
  --print("cant pay level 1 costs")
end

local calc_colony_population = function(colony)
    local total_workers = {0,0,0,0,0}
    for _, structure in pairs(colony.structures) do
      if structure.to_be_deconstructed(structure.force) == true then
        structure.active = false
      else
        structure.active = true
          local workers = data_import.structures[structure.name].staff
        for index, population in pairs(workers) do
          total_workers[index] = total_workers[index] + population
        end
      end
    end
    colony.population = total_workers
end

local find_closest_colony = function(surface,position)
    local closest_dist = 99999
    local closest_col = nil
    for _, colony in pairs(global.maint_data.colonies) do
        if colony.surface == surface and math2d.position.distance(position,colony.position) < closest_dist then
            closest_dist = math2d.position.distance(position,colony.position)
            closest_col = colony
        end
    end
    return closest_col
end

local update_player_maint_guis = function()
    for _, player in pairs(game.players) do
        local colony = find_closest_colony(player.surface.name,player.position)
        if colony then
            update_maint_gui(player,colony)
        end
    end
end

local do_update = function()
    for _, colony in pairs(global.maint_data.colonies) do
      calc_colony_population(colony)
      --print(serpent.line(colony.population))
      calc_colony_work_state(colony)
      --print(serpent.line(colony.costs))
      apply_work_state(colony)
    end
    update_player_maint_guis()
end

local maint = {}

maint.nearest_colony = function(surface,position)
  return find_closest_colony(surface,position)
end

maint.add_entity = function(entity)
    if entity.name == 'cm' then
        new_colony(entity)
        entity.destructible = false
        return true
    end
    local trackable_type = false
    for name, data in pairs(data_import.structures) do
        if entity.name == name then
            trackable_type = true
            break
        end
    end
    if trackable_type then
        local colony = find_closest_colony(entity.surface.name,entity.position)
        if colony then
            table.insert(colony.structures, entity)
            game.print({'msg.added-structure'})
            entity.active = false
            return true
        end
        return false
    end
    return true
end

maint.remove_entity = function(entity)
  for _, colony in pairs(global.maint_data.colonies) do
    for index, structure in pairs(colony.structures) do
      if structure.name == entity.name and structure.position.x == entity.position.x and structure.position.y == entity.position.y then
        table.remove(colony.structures,index)
        game.print({'msg.removed-structure'})
        return true
      end
    end
  end
  return false
end

maint.update = function(tick)
    if tick > global.maint_data.next_update then
        do_update()
        global.maint_data.next_update = tick + global.maint_data.update_length
        return true
    elseif tick % 60 == 0 then
        update_player_maint_guis()
    end
    return false
end

maint.on_load = function()
    global.maint_data = {
        next_update = 0,
        update_length = 520*constants.time_multiplier,
        colonies = {}
    }
end

return maint