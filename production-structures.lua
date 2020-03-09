--create item cat for structures
data:extend({{
    type = "item-group",
    name = "pu-structures",
    order = "a",
    icon = "__pu-supply-chain__/graphics/icons/generic-icon.png",
    icon_size = 64
  },
  {
    type = "item-subgroup",
    name = "core",
    group = "pu-structures",
    order = "a",
  },
  {
    type = "item-subgroup",
    name = "pioneer",
    group = "pu-structures",
    order = "b",
  },
  {
    type = "item-subgroup",
    name = "settler",
    group = "pu-structures",
    order = "c",
  },
  {
    type = "item-subgroup",
    name = "technician",
    group = "pu-structures",
    order = "d",
  },
  {
    type = "item-subgroup",
    name = "engineer",
    group = "pu-structures",
    order = "e",
  },
  {
    type = "item-subgroup",
    name = "scientist",
    group = "pu-structures",
    order = "f",
  }

})

--generate production structures (generic assembling machine, with their own crafting category)
local structures = data_import.structures

local generate_production_structure = function(structure_data)
  local tier = "core"
  if structure_data.staff[5] > 0 then tier = "scientist"
  elseif structure_data.staff[4] > 0 then tier = "engineer"
  elseif structure_data.staff[3] > 0 then tier = "technician"
  elseif structure_data.staff[2] > 0 then tier = "settler"
  elseif structure_data.staff[1] > 0 then tier = "pioneer" end

  local structure_ent = util.table.deepcopy(data.raw['assembling-machine']['assembling-machine-1'])
  structure_ent.name = structure_data.name
  structure_ent.resource_categories = {structure_data.category}
  structure_ent.icon = "__pu-supply-chain__/graphics/icons/"..structure_data.name..".png"
  structure_ent.icon_size = 64
  structure_ent.animation = {
    frame_count = 1,
    filename = "__pu-supply-chain__/graphics/entity/"..structure_data.name..".png",
    width = 96,
    height = 96,
  }
  structure_ent.crafting_categories = {structure_data.name}
  structure_ent.minable.results = structure_data.cost
  structure_ent.minable.result = nil
  structure_ent.energy_source = {
    type = "void"
  }
  structure_ent.allowed_effects = {'speed'}
  structure_ent.module_specification = {module_slots= 1}

  local structure_item = util.table.deepcopy(data.raw["item"]["stone-furnace"])
  structure_item.name = structure_data.name
  structure_item.place_result = structure_data.name
  structure_item.icon = "__pu-supply-chain__/graphics/icons/"..structure_data.name..".png"
  structure_item.icon_size = 64
  structure_item.subgroup = tier

  local structure_recipe = {
    type = "recipe",
    name = structure_data.name,
    ingredients = structure_data.cost,
    result = structure_data.name,
  }

  data:extend({structure_ent,structure_item,structure_recipe})
end

for _, structure_data in pairs(structures) do
  generate_production_structure(structure_data)
end