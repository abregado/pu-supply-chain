require("util")
require("data-import")
time_multiplier = 10000
largest_recipe_stack = 100

require('raw-items')
require('items')
require('recipes')
require('production-structures')

--create consumable items (modules with increasing speed bonus)
--create consumable module factory

--generate core module (void roboport)
--generate storage (logistic storage chest)

--generate void energy inserter and belt
local inserter_ent = util.table.deepcopy(data.raw['inserter']['filter-inserter'])
inserter_ent.name = "pu-inserter"
inserter_ent.icon = "__pu-supply-chain__/graphics/icons/generic-icon.png"
inserter_ent.minable.result = "pu-inserter"
inserter_ent.energy_source = {
  type = "void"
}

local inserter_item = util.table.deepcopy(data.raw["item"]["filter-inserter"])
inserter_item.name = "pu-inserter"
inserter_item.place_result = "pu-inserter"
inserter_item.subgroup = "core"

local inserter_recipe = {
  type = "recipe",
  name = "pu-inserter",
  ingredients = {{'mcg',10}},
  result = "pu-inserter",
}

local belt_ent = util.table.deepcopy(data.raw['transport-belt']['transport-belt'])
belt_ent.name = "pu-transport-belt"
belt_ent.minable.result = "pu-transport-belt"

local belt_item = util.table.deepcopy(data.raw["item"]["transport-belt"])
belt_item.name = "pu-transport-belt"
belt_item.place_result = "pu-transport-belt"
belt_item.subgroup = "core"

local belt_recipe = {
  type = "recipe",
  name = "pu-transport-belt",
  ingredients = {{'mcg',5}},
  result = "pu-transport-belt",
}

local underground_belt_ent = util.table.deepcopy(data.raw['underground-belt']['underground-belt'])
underground_belt_ent.name = "pu-underground-belt"
underground_belt_ent.minable.result = "pu-underground-belt"

local underground_belt_item = util.table.deepcopy(data.raw["item"]["underground-belt"])
underground_belt_item.name = "pu-underground-belt"
underground_belt_item.place_result = "pu-underground-belt"
underground_belt_item.subgroup = "core"

local underground_belt_recipe = {
  type = "recipe",
  name = "pu-underground-belt",
  ingredients = {{'mcg',50}},
  result = "pu-underground-belt",
}

local splitter_ent = util.table.deepcopy(data.raw['splitter']['splitter'])
splitter_ent.name = "pu-splitter"
splitter_ent.minable.result = "pu-splitter"

local splitter_item = util.table.deepcopy(data.raw["item"]["splitter"])
splitter_item.name = "pu-splitter"
splitter_item.place_result = "pu-splitter"
splitter_item.subgroup = "core"

local splitter_recipe = {
  type = "recipe",
  name = "pu-splitter",
  ingredients = {{'mcg',50}},
  result = "pu-splitter",
}

data:extend({belt_ent,belt_item,belt_recipe,underground_belt_ent,underground_belt_item,underground_belt_recipe})
data:extend({inserter_ent,inserter_item,inserter_recipe,splitter_ent,splitter_item,splitter_recipe})
