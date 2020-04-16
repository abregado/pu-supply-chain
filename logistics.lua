--generate core module (void roboport)
local core_ent = util.table.deepcopy(data.raw['container']['dummy-container'])
core_ent.name = 'cm'
core_ent.icon = "__pu-supply-chain__/graphics/icons/cm.png"
core_ent.icon_size = 64
core_ent.minable = {results = {{"lse",4},{"tru",8},{"psl",12},{"lde",4},{"lta",4},{"mcg",100}},mining_time=1}
core_ent.picture = {
  filename = "__pu-supply-chain__/graphics/entity/cm.png",
  width = 96,
  height = 96,
}
core_ent.collision_box = {{-1.5, -1.5}, {1.5, 1.5}}
core_ent.selection_box = {{-1.5, -1.5}, {1.5, 1.5}}
core_ent.inventory_size = 49

local core_item = util.table.deepcopy(data.raw["item"]["dummy-item"])
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

--generate storage (logistic storage chest)
local storage_ent = util.table.deepcopy(data.raw['container']['dummy-container'])
storage_ent.name = 'sto'
storage_ent.icon = "__pu-supply-chain__/graphics/icons/sto.png"
storage_ent.icon_size = 64
storage_ent.minable = {results = {{"bbh",6},{"bse",2},{"bde",6},{"mcg",60}},mining_time=1}
storage_ent.picture = {
  filename = "__pu-supply-chain__/graphics/entity/sto.png",
  width = 96,
  height = 96,
}
storage_ent.collision_box = {{-1.5, -1.5}, {1.5, 1.5}}
storage_ent.selection_box = {{-1.5, -1.5}, {1.5, 1.5}}
storage_ent.inventory_size = 49


local storage_item = util.table.deepcopy(data.raw["item"]["dummy-item"])
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

--generate import (logistic import chest)
local import_ent = util.table.deepcopy(data.raw['logistic-container']['dummy-logistic-container'])
import_ent.name = 'imp'
import_ent.icon = "__pu-supply-chain__/graphics/icons/imp.png"
import_ent.logistic_mode = "requester"
import_ent.icon_size = 64
import_ent.picture = {
  filename = "__pu-supply-chain__/graphics/entity/imp.png",
  width = 96,
  height = 96,
}
import_ent.collision_box = {{-1.5, -1.5}, {1.5, 1.5}}
import_ent.selection_box = {{-1.5, -1.5}, {1.5, 1.5}}
import_ent.animation = nil
import_ent.render_not_in_network_icon = false
import_ent.inventory_size = 40
import_ent.logistic_slots_count = 10

local import_item = util.table.deepcopy(data.raw["item"]["dummy-item"])
import_item.name = "imp"
import_item.place_result = "imp"
import_item.icon = "__pu-supply-chain__/graphics/icons/imp.png"
import_item.icon_size = 64
import_item.subgroup = "core"

--generate export (logistic export chest)
local export_ent = util.table.deepcopy(data.raw['logistic-container']['dummy-logistic-container'])
export_ent.name = 'exp'
export_ent.icon = "__pu-supply-chain__/graphics/icons/exp.png"
export_ent.logistic_mode = "storage"
export_ent.icon_size = 64
export_ent.picture = {
  filename = "__pu-supply-chain__/graphics/entity/exp.png",
  width = 96,
  height = 96,
}
export_ent.collision_box = {{-1.5, -1.5}, {1.5, 1.5}}
export_ent.selection_box = {{-1.5, -1.5}, {1.5, 1.5}}
export_ent.animation = nil
export_ent.render_not_in_network_icon = false
export_ent.inventory_size = 40

local export_item = util.table.deepcopy(data.raw["item"]["dummy-item"])
export_item.name = "exp"
export_item.place_result = "exp"
export_item.icon = "__pu-supply-chain__/graphics/icons/exp.png"
export_item.icon_size = 64
export_item.subgroup = "core"

--generate void energy inserter and belt
local inserter_ent = util.table.deepcopy(data.raw['inserter']['dummy-inserter'])
inserter_ent.name = "pu-inserter"
inserter_ent.icon = "__pu-supply-chain__/graphics/icons/generic-icon.png"
inserter_ent.icon_size = 64
inserter_ent.energy_source = {
  type = "void"
}

local inserter_item = util.table.deepcopy(data.raw["item"]["dummy-item"])
inserter_item.name = "pu-inserter"
inserter_item.place_result = "pu-inserter"
inserter_item.subgroup = "core"
inserter_item.icon = "__pu-supply-chain__/graphics/icons/generic-icon.png"
inserter_item.icon_size = 64

--generate void energy inserter and belt
local filter_ent = util.table.deepcopy(data.raw['inserter']['dummy-inserter'])
filter_ent.name = "pu-filter-inserter"
filter_ent.icon = "__pu-supply-chain__/graphics/icons/generic-icon.png"
filter_ent.icon_size = 64
filter_ent.energy_source = {
  type = "void"
}

local filter_item = util.table.deepcopy(data.raw["item"]["dummy-item"])
filter_item.name = "pu-filter-inserter"
filter_item.place_result = "pu-filter-inserter"
filter_item.subgroup = "core"
filter_item.icon = "__pu-supply-chain__/graphics/icons/generic-icon.png"
filter_item.icon_size = 64

local belt_ent = util.table.deepcopy(data.raw['transport-belt']['dummy-transport-belt'])
belt_ent.name = "pu-transport-belt"
belt_ent.icon = "__pu-supply-chain__/graphics/icons/generic-icon.png"
belt_ent.icon_size = 64

local belt_item = util.table.deepcopy(data.raw["item"]["dummy-item"])
belt_item.name = "pu-transport-belt"
belt_item.place_result = "pu-transport-belt"
belt_item.subgroup = "core"
belt_item.icon = "__pu-supply-chain__/graphics/icons/generic-icon.png"
belt_item.icon_size = 64

local underground_belt_ent = util.table.deepcopy(data.raw['underground-belt']['dummy-underground-belt'])
underground_belt_ent.name = "pu-underground-belt"
underground_belt_ent.icon = "__pu-supply-chain__/graphics/icons/generic-icon.png"
underground_belt_ent.icon_size = 64

local underground_belt_item = util.table.deepcopy(data.raw["item"]["dummy-item"])
underground_belt_item.name = "pu-underground-belt"
underground_belt_item.place_result = "pu-underground-belt"
underground_belt_item.subgroup = "core"
underground_belt_item.icon = "__pu-supply-chain__/graphics/icons/generic-icon.png"
underground_belt_item.icon_size = 64

local splitter_ent = util.table.deepcopy(data.raw['splitter']['dummy-splitter'])
splitter_ent.name = "pu-splitter"
splitter_ent.icon = "__pu-supply-chain__/graphics/icons/generic-icon.png"
splitter_ent.icon_size = 64

local splitter_item = util.table.deepcopy(data.raw["item"]["dummy-item"])
splitter_item.name = "pu-splitter"
splitter_item.place_result = "pu-splitter"
splitter_item.subgroup = "core"
splitter_item.icon = "__pu-supply-chain__/graphics/icons/generic-icon.png"
splitter_item.icon_size = 64

--generate void energy inserter and belt
local loader_ent = util.table.deepcopy(data.raw['loader-1x1']['dummy-loader-1x1'])
loader_ent.name = "pu-loader"
loader_ent.icon = "__pu-supply-chain__/graphics/icons/generic-icon.png"
loader_ent.icon_size = 64

local loader_item = util.table.deepcopy(data.raw["item"]["dummy-item"])
loader_item.name = "pu-loader"
loader_item.place_result = "pu-loader"
loader_item.subgroup = "core"
loader_item.icon = "__pu-supply-chain__/graphics/icons/generic-icon.png"
loader_item.icon_size = 64

local wire_item = {
    type = "item",
    name = "pu-wire",
    icon = "__pu-supply-chain__/graphics/icons/generic-icon.png",
    icon_size = 64, icon_mipmaps = 4,
    subgroup = "core",
    order = "b[wires]-b[green-wire]",
    stack_size = 200,
    wire_count = 100
  }

local decon_planner =   {
    type = "deconstruction-item",
    name = "labor-planner",
    icon = "__pu-supply-chain__/graphics/icons/generic-icon.png",
    icon_size = 64, icon_mipmaps = 4,
    subgroup = "core",
    order = "c[automated-construction]-b[deconstruction-planner]",
    stack_size = 1,
    entity_filter_count = 30,
    tile_filter_count = 30,
    selection_color = {1, 0, 0},
    alt_selection_color = {0, 0, 1},
    selection_mode = {"deconstruct"},
    alt_selection_mode = {"cancel-deconstruct"},
    selection_cursor_box_type = "not-allowed",
    alt_selection_cursor_box_type = "not-allowed",
  },

data:extend(
{
  {
    type = "module-category",
    name = "morale"
  },
}
)

local morale_module_1 = {
  type = "module",
  name = "module-1",
  localised_description = {"item-description.module-1"},
  icon = "__pu-supply-chain__/graphics/icons/morale-1.png",
  icon_size = 128,
  subgroup = "core",
  category = "morale",
  tier = 1,
  order = "a[speed]-a[speed-module-1]",
  stack_size = 1,
  effect = { speed = {bonus = -0.80}}
}
local morale_module_2 = {
  type = "module",
  name = "module-2",
  localised_description = {"item-description.module-2"},
  icon = "__pu-supply-chain__/graphics/icons/morale-2.png",
  icon_size = 128,
  subgroup = "core",
  category = "morale",
  tier = 1,
  order = "a[speed]-a[speed-module-1]",
  stack_size = 1,
  effect = { speed = {bonus = -0.48}}
}
local morale_module_3 = {
  type = "module",
  name = "module-3",
  localised_description = {"item-description.module-3"},
  icon = "__pu-supply-chain__/graphics/icons/morale-3.png",
  icon_size = 128,
  subgroup = "core",
  category = "morale",
  tier = 1,
  order = "a[speed]-a[speed-module-1]",
  stack_size = 1,
  effect = { speed = {bonus = -0.17}}
}
local morale_module_4 = {
  type = "module",
  name = "module-4",
  localised_description = {"item-description.module-4"},
  icon = "__pu-supply-chain__/graphics/icons/morale-4.png",
  icon_size = 128,
  subgroup = "core",
  category = "morale",
  tier = 1,
  order = "a[speed]-a[speed-module-1]",
  stack_size = 1,
  effect = { speed = {bonus = -0.03}}
}
local morale_module_5 = {
  type = "module",
  name = "module-5",
  localised_description = {"item-description.module-5"},
  icon = "__pu-supply-chain__/graphics/icons/morale-5.png",
  icon_size = 128,
  subgroup = "core",
  category = "morale",
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
data:extend({import_ent,import_item})
data:extend({export_ent,export_item})
data:extend({filter_ent,filter_item})
data:extend({loader_ent,loader_item})
data:extend({wire_item,decon_planner})