require("util")
--constants
--time multiplier
local time_multiplier = 100
local largest_recipe_stack = 100


--create item cat for raw
data:extend({{
    type = "item-group",
    name = "raw",
    order = "a",
    icon = "__pu-supply-chain__/graphics/icons/generic-icon.png",
    icon_size = 64
  },
  {
    type = "item-subgroup",
    name = "raw-main",
    group = "raw",
    order = "a",
  }
})

--generate resource categories
local resource_categories = {'solid','liquid','gas'}

for _, cat in pairs(resource_categories) do
  data:extend({
    {
      type = "resource-category",
      name = cat
    },
    {
      type = "item-subgroup",
      name = "raw-"..cat,
      group = "raw",
      order = "a["..cat.."]",
    }
  })
end

--generate deposit entities for raw resources
local raw_resources = {
  --{name='sio',category='solid',size=1.79},
  --{name='feo',category='solid',size=5.9},
  --{name='h',category='gas',size=1},
  --{name='lst',category='solid',size=2.73},
  {name='h20',category='liquid',size=1},
}

local raw_resource_and_patch = function(res_data)
  local deposit_entity = util.table.deepcopy(data.raw["resource"]["iron-ore"])
  deposit_entity.stage_counts = {1}
  deposit_entity.stages = {
    sheet = {
      filename = "__pu-supply-chain__/graphics/entity/generic-single-tile.png",
      priority = "extra-high",
      width = 32,
      height = 32,
      frame_count = 1,
      variation_count = 1,
    }
  }
  deposit_entity.category = res_data.category
  deposit_entity.minable.result = res_data.name
  deposit_entity.map_generator_bounding_box = {{-2.5, -2.5}, {2.5, 2.5}}
  deposit_entity.icon = "__pu-supply-chain__/graphics/icons/generic-icon.png"
  deposit_entity.name = res_data.name

  local ore_item =  {
    type = "item",
    name = res_data.name,
    icon = "__pu-supply-chain__/graphics/icons/generic-icon.png",
    icon_size = 64,
    subgroup = "raw-"..res_data.category,
    order = "e["..res_data.name.."]",
    stack_size = math.ceil(largest_recipe_stack/res_data.size)
  }
  data:extend({ore_item,deposit_entity})
end

for _, res_data in pairs(raw_resources) do
  raw_resource_and_patch(res_data)
end

--generate mining structures
local mining_structures = {
  {name='rig',category='liquid',staff={30,0,0},cost={{'copper-ore',12},{'stone',40}}},
  {name='ext',category='solid',staff={60,0,0},cost={{'copper-ore',16},{'stone',100}}},
  {name='col',category='gas',staff={50,0,0},cost={{'copper-ore',12},{'stone',60}}},
}

local generate_mining_structure = function(miner_data)
  local miner_ent = util.table.deepcopy(data.raw["mining-drill"]["electric-mining-drill"])
  miner_ent.name = miner_data.name
  miner_ent.resource_categories = {miner_data.category}
  miner_ent.animations = {
    frame_count = 1,
    filename = "__pu-supply-chain__/graphics/entity/generic-three-by-three.png",
    width = 96,
    height = 96,
  }
  miner_ent.minable.results = miner_data.cost
  miner_ent.minable.result = nil
  miner_ent.energy_source = {
    type = "void"
  }

  local miner_item = util.table.deepcopy(data.raw["item"]["stone-furnace"])
  miner_item.name = miner_data.name
  miner_item.place_result = miner_data.name
  miner_item.icon = "__pu-supply-chain__/graphics/icons/generic-icon.png"
  miner_item.subgroup = "raw-main"

  local miner_recipe = {
    type = "recipe",
    name = miner_data.name,
    ingredients = miner_data.cost,
    result = miner_data.name
  }

  data:extend({miner_item,miner_ent,miner_recipe})
end

for _, miner_data in pairs(mining_structures) do
  generate_mining_structure(miner_data)
end

--create generic item
--generate items from list
local item_list = {
  {name='nut',size=1,category='agri'},
  {name='bea',size=1,category='agri'},
}

local new_basic_item = function(item_data)
  local new_basic_item =   {
    type = "item",
    name = item_data.name,
    icon = "__pu-supply-chain__/graphics/icons/generic-icon.png",
    icon_size = 64, icon_mipmaps = 4,
    subgroup = "intermediate-product",
    order = "e["..item_data.name.."]",
    stack_size = math.ceil(largest_recipe_stack/item_data.size)
  }
  data:extend({new_basic_item})
end

for _, item_data in pairs(item_list) do
  new_basic_item(item_data)
end

--generate recipes
local sample_recipe_group = {
  ['frm'] = {
    {name='nut-1',products={{'nut',12}},ingredients={{'h20',1}},time=24+12},
    {name='bea-1',products={{'bea',2}},ingredients={{'h20',1}},time=6},
  }
}

local set_up_crafting_category = function(recipe_category)
  --create crafting category
  data:extend({
    {
      type = "recipe-category",
      name = recipe_category
    },
  })
  --create item category
  data:extend({{
      type = "item-group",
      name = recipe_category,
      order = "a",
      icon = "__pu-supply-chain__/graphics/icons/generic-icon.png",
      icon_size = 64
    },
    {
      type = "item-subgroup",
      name = recipe_category.."-main",
      group = recipe_category,
      order = "a",
    }
  })
end

local generate_recipe_group = function (group_name,group_data)
  set_up_crafting_category(group_name)
  for _, recipe_data in pairs(group_data) do
    local new_recipe = {
      type = "recipe",
      name = group_name.."-"..recipe_data.name,
      energy_required = recipe_data.time/time_multiplier,
      category = group_name,
      ingredients = recipe_data.ingredients,
      group = group_name,
      subgroup = group_name.."-main",
      results = recipe_data.products,
      always_show_made_in = true,
      --main_product = "",
      --localised_name = {"string"},
      enabled = true
    }
    data:extend({new_recipe})
  end
end

for group_name, group_data in pairs(sample_recipe_group) do
  generate_recipe_group(group_name,group_data)
end

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
    name = "pu-structures-main",
    group = "pu-structures",
    order = "a",
  }
})

--generate production structures (generic assembling machine, with their own crafting category)
local structures = {
  {name='frm',staff={50,0,0},cost={{'copper-ore',4},{'iron-ore',4},{'stone',120}}},
}

local generate_production_structure = function(structure_data)
  local structure_ent = util.table.deepcopy(data.raw['assembling-machine']['assembling-machine-1'])
  structure_ent.name = structure_data.name
  structure_ent.resource_categories = {structure_data.category}
  structure_ent.animations = {
    frame_count = 1,
    filename = "__pu-supply-chain__/graphics/entity/generic-three-by-three.png",
    width = 96,
    height = 96,
  }
  structure_ent.crafting_categories = {structure_data.name}
  structure_ent.minable.results = structure_data.cost
  structure_ent.minable.result = nil
  structure_ent.energy_source = {
    type = "void"
  }

  local structure_item = util.table.deepcopy(data.raw["item"]["stone-furnace"])
  structure_item.name = structure_data.name
  structure_item.place_result = structure_data.name
  structure_item.icon = "__pu-supply-chain__/graphics/icons/generic-icon.png"
  structure_item.subgroup = "pu-structures-main"

  local structure_recipe = {
    type = "recipe",
    name = structure_data.name,
    ingredients = structure_data.cost,
    result = structure_data.name
  }

  data:extend({structure_ent,structure_item,structure_recipe})
end

for _, structure_data in pairs(structures) do
  generate_production_structure(structure_data)
end

--create consumable items (modules with increasing speed bonus)
--create consumable module factory

--generate core module (void roboport)
--generate storage (logistic storage chest)

--generate void energy inserter and belt