local math2d = require("math2d")

local base_costs = {}
base_costs[1] = {
    {'ove',0.5},
    {'rat',4},
    {'dw',4}
}
base_costs[2] = {
    {'rat',6},
    {'dw',5},
    {'pt',0.5},
    {'exo',0.5}
}
base_costs[3] = {
    {'rat',7},
    {'dw',7.5},
    {'med',0.5},
    {'hms',0.5},
    {'scn',0.5}
}
base_costs[4] = {
    {'dw',10},
    {'med',0.5},
    {'fim',7},
    {'hss',0.1},
    {'pda',0.1}
}
base_costs[5] = {
    {'dw',10},
    {'med',0.5},
    {'mea',7},
    {'lc',0.2},
    {'ws',0.1},
}

local work_state_modules = {
    'module-1',
    'module-2',
    'module-3',
    'module-4',
    'module-5',
}

local update_maint_gui = function(player)

end

local safe_remove = function(inventory,stack)
    if stack.count > 0 then
        inventory.remove(stack)
    end
end

local apply_work_state = function(colony)
    for _, structure in pairs(colony.structures) do
        local mod_inv = structure.get_module_inventory()
        mod_inv.clear()
        mod_inv.insert(work_state_modules[colony.work_state])
    end
    local inventory = colony.core.get_inventory(defines.inventory.chest)
    local production_stats = game.forces.player.item_pro
    for name, cost in pairs(colony.costs) do
        if colony.work_state > 1 then
            local half_cost = math.floor(cost/2)
            safe_remove(inventory,{name=name,count=half_cost})
        elseif colony.work_state > 2 then
            safe_remove(inventory,{name=name,count=cost})
        end
    end
end

local new_colony = function(core_module)
    table.insert(global.maint.colonies,{
    core = core_module,
    position = core_module.position,
    structures = {},
    population = {0,0,0,0,0},
    work_state = 0,
    })
    game.print("new colony created")
end

local calc_colony_work_state = function(colony)
    local costs = colony.costs
    local modifier = 3
    local inventory = colony.core.get_inventory(defines.inventory.chest)
    for name, cost in pairs(costs) do
        local half_cost = math.floor(cost/2)
        if half_cost > 0 and inventory.get_item_count(name) < half_cost then
            modifier = math.min(modifier,1)
        elseif cost > 0 and inventory.get_item_count(name) < cost then
            modifier = math.min(modifier,2)
        end
    end
    return modifier
end

local calc_colony_needs = function(colony)
    local workers = colony.population
    local costs = {}
    for index, pop in pairs(workers) do
        for _, item in pairs(base_costs[index]) do
            local cost = math.floor(item[2]/100*pop)
            if costs[item[1]] then
                costs[item[1]] = costs[item[1]] + cost
            else
                costs[item[1]] = cost
            end
        end
    end
    return costs
end

local calc_colony_population = function(colony)
    local total_workers = {0,0,0,0,0}
    for _, structure in pairs(colony.structures) do
        local workers = data_import.structures[structure.name].staff
        for index, population in pairs(workers) do
            total_workers[index] = total_workers[index] + population
        end
    end
    return total_workers
end

local do_update = function()
    for _, colony in pairs(global.maint.colonies) do
        colony.population = calc_colony_population(colony)
        colony.costs = calc_colony_needs(colony)
        colony.work_state = calc_colony_work_state(colony)
        apply_work_state(colony)
        game.print(serpent.line(colony.population).." state:"..colony.work_state)

    end
end

local find_closest_colony = function(position)
    local closest_dist = 99999
    local closest_col = nil
    for _, colony in pairs(global.maint.colonies) do
        if math2d.position.distance(position,colony.position) < closest_dist then
            closest_col = colony
        end
    end
    return closest_col
end

local maint = {}

maint.add_entity = function(entity)
    if entity.name == 'cm' then
        new_colony(entity)
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
        local colony = find_closest_colony(entity.position)
        if colony then
            table.insert(colony.structures, entity)
            game.print("added structure to colony")
            return true
        end
        return false
    end
    return true
end

maint.remove_entity = function(entity)
    for _, colony in pairs(global.maint.colonies) do
        for index, structure in pairs(colony.structures) do
            if structure.name == entity.name and structure.position.x == entity.position.x and structure.position.y == entity.position.y then
                table.remove(colony.structures,index)
                game.print("removed structure from colony")
                return true
            end
        end
    end
    return false
end

maint.update = function(tick)
    if tick > global.maint.next_update then
        do_update()
        global.maint.next_update = tick + global.maint.update_length
    end
end

maint.on_load = function()
    global.maint = {
        next_update = 0,
        update_length = 500,
        colonies = {}
    }
end

return maint