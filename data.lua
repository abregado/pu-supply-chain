require("util")
data_import = require("data-import")
require('constants')

require('raw-items')
require('items')
require('recipes')
require('production-structures')

--create consumable items (modules with increasing speed bonus)

--generate core module (void roboport)
local core_ent = util.table.deepcopy(data.raw['container']['steel-chest'])
core_ent.name = 'cm'
core_ent.icon = "__pu-supply-chain__/graphics/icons/cm.png"
core_ent.minable.result = nil
core_ent.minable.results = {{"lse",4},{"tru",8},{"psl",12},{"lde",4},{"lta",4},{"mcg",100}}
core_ent.picture = {
  filename = "__pu-supply-chain__/graphics/entity/cm.png",
  width = 96,
  height = 96,
}
core_ent.collision_box = {{-1.5, -1.5}, {1.5, 1.5}}
core_ent.selection_box = {{-1.5, -1.5}, {1.5, 1.5}}

local core_item = util.table.deepcopy(data.raw["item"]["fast-inserter"])
core_item.name = "cm"
core_item.place_result = "cm"
core_item.icon = "__pu-supply-chain__/graphics/icons/cm.png"
core_item.icon_size = 64
core_item.subgroup = "core"

local core_recipe = {
  type = "recipe",
  name = "cm",
  ingredients = {{"lse",4},{"tru",8},{"psl",12},{"lde",4},{"lta",4},{"mcg",100}},
  energy = 0.1,
  result = "cm",
}

--{name="cm",cost={{"lse",4},{"tru",8},{"psl",12},{"lde",4},{"lta",4},{"mcg",100},},staff={0,25,15,0,0,}},

--generate storage (logistic storage chest)
local storage_ent = util.table.deepcopy(data.raw['container']['steel-chest'])
storage_ent.name = 'sto'
storage_ent.icon = "__pu-supply-chain__/graphics/icons/sto.png"
storage_ent.minable.result = nil
storage_ent.minable.results = {{"bbh",6},{"bse",2},{"bde",6},{"mcg",60}}
storage_ent.picture = {
  filename = "__pu-supply-chain__/graphics/entity/sto.png",
  width = 96,
  height = 96,
}
storage_ent.collision_box = {{-1.5, -1.5}, {1.5, 1.5}}
storage_ent.selection_box = {{-1.5, -1.5}, {1.5, 1.5}}


local storage_item = util.table.deepcopy(data.raw["item"]["fast-inserter"])
storage_item.name = "sto"
storage_item.place_result = "sto"
storage_item.icon = "__pu-supply-chain__/graphics/icons/sto.png"
storage_item.icon_size = 64
storage_item.subgroup = "core"

local storage_recipe = {
  type = "recipe",
  name = "sto",
  ingredients = {{"bbh",6},{"bse",2},{"bde",6},{"mcg",60}},
  energy = 0.1,
  result = "sto",
}

--generate void energy inserter and belt
local inserter_ent = util.table.deepcopy(data.raw['inserter']['fast-inserter'])
inserter_ent.name = "pu-inserter"
inserter_ent.icon = "__pu-supply-chain__/graphics/icons/generic-icon.png"
inserter_ent.minable.result = nil
inserter_ent.energy_source = {
  type = "void"
}

local inserter_item = util.table.deepcopy(data.raw["item"]["fast-inserter"])
inserter_item.name = "pu-inserter"
inserter_item.place_result = "pu-inserter"
inserter_item.subgroup = "core"

--local inserter_recipe = {
--  type = "recipe",
--  name = "pu-inserter",
--  ingredients = {{'mcg',5}},
--  energy = 0.1,
--  result = "pu-inserter",
--}

local belt_ent = util.table.deepcopy(data.raw['transport-belt']['transport-belt'])
belt_ent.name = "pu-transport-belt"
belt_ent.minable.result = nil

local belt_item = util.table.deepcopy(data.raw["item"]["transport-belt"])
belt_item.name = "pu-transport-belt"
belt_item.place_result = "pu-transport-belt"
belt_item.subgroup = "core"

--local belt_recipe = {
--  type = "recipe",
--  name = "pu-transport-belt",
--  ingredients = {{'mcg',1}},
--  energy = 0.1,
--  result = "pu-transport-belt",
--}

local underground_belt_ent = util.table.deepcopy(data.raw['underground-belt']['underground-belt'])
underground_belt_ent.name = "pu-underground-belt"
underground_belt_ent.minable.result = nil

local underground_belt_item = util.table.deepcopy(data.raw["item"]["underground-belt"])
underground_belt_item.name = "pu-underground-belt"
underground_belt_item.place_result = "pu-underground-belt"
underground_belt_item.subgroup = "core"

--local underground_belt_recipe = {
--  type = "recipe",
--  name = "pu-underground-belt",
--  ingredients = {{'mcg',10}},
--  energy = 0.1,
--  result = "pu-underground-belt",
--}

local splitter_ent = util.table.deepcopy(data.raw['splitter']['splitter'])
splitter_ent.name = "pu-splitter"
splitter_ent.minable.result = nil

local splitter_item = util.table.deepcopy(data.raw["item"]["splitter"])
splitter_item.name = "pu-splitter"
splitter_item.place_result = "pu-splitter"
splitter_item.subgroup = "core"

--local splitter_recipe = {
--  type = "recipe",
--  name = "pu-splitter",
--  ingredients = {{'mcg',10}},
--  result = "pu-splitter",
--  energy = 0.1,
--}

local morale_module_1 = {
  type = "module",
  name = "module-1",
  localised_description = {"item-description.module-1"},
  icon = "__base__/graphics/icons/speed-module.png",
  icon_size = 64,
  subgroup = "module",
  category = "speed",
  tier = 1,
  order = "a[speed]-a[speed-module-1]",
  stack_size = 1,
  effect = { speed = {bonus = -0.80}}
}
local morale_module_2 = {
  type = "module",
  name = "module-2",
  localised_description = {"item-description.module-2"},
  icon = "__base__/graphics/icons/speed-module-2.png",
  icon_size = 64,
  subgroup = "module",
  category = "speed",
  tier = 1,
  order = "a[speed]-a[speed-module-1]",
  stack_size = 1,
  effect = { speed = {bonus = -0.48}}
}
local morale_module_3 = {
  type = "module",
  name = "module-3",
  localised_description = {"item-description.module-3"},
  icon = "__base__/graphics/icons/speed-module-3.png",
  icon_size = 64,
  subgroup = "module",
  category = "speed",
  tier = 1,
  order = "a[speed]-a[speed-module-1]",
  stack_size = 1,
  effect = { speed = {bonus = -0.17}}
}
local morale_module_4 = {
  type = "module",
  name = "module-4",
  localised_description = {"item-description.module-3"},
  icon = "__base__/graphics/icons/speed-module.png",
  icon_size = 64,
  subgroup = "module",
  category = "speed",
  tier = 1,
  order = "a[speed]-a[speed-module-1]",
  stack_size = 1,
  effect = { speed = {bonus = -0.03}}
}
local morale_module_5 = {
  type = "module",
  name = "module-5",
  localised_description = {"item-description.module-5"},
  icon = "__base__/graphics/icons/speed-module.png",
  icon_size = 64,
  subgroup = "module",
  category = "speed",
  tier = 1,
  order = "a[speed]-a[speed-module-1]",
  stack_size = 1,
  effect = { speed = {bonus = -0.0}}
}


data:extend({belt_ent,belt_item,underground_belt_ent,underground_belt_item})
data:extend({inserter_ent,inserter_item,splitter_ent,splitter_item})
data:extend({core_ent,core_item,storage_ent,storage_item})
data:extend({storage_recipe,core_recipe})
data:extend({morale_module_1,morale_module_2,morale_module_3,morale_module_4,morale_module_5})
