require('resource-autoplace')

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
local resource_categories = {}
resource_categories['gas'] = {'amm','ar','f','h','he','he3','n','ne','o'}
resource_categories['liquid'] = {'h2o','bts','les'}
resource_categories['solid'] = {'alo','auo','ber','cli','cuo','feo','gal','hal','lst','mag','mg','s','sio','tai','tio','ts','zir'}

for cat_name, cat_items in pairs(resource_categories) do
  data:extend({
    {
      type = "resource-category",
      name = cat_name
    },
  })
end

local raw_patch = function(res_cat_name,item_name)
  data:extend({
    {
      type = "autoplace-control",
      name = item_name,
      richness = true,
      order = item_name,
      category = "resource"
    },
    {
      type = "noise-layer",
      name = item_name
    },
  })
  local starting_area_resource = false
  local rarity = 1
  local density = 3
  local max_size = 10
  if item_name == 'h2o' or
    item_name == 'h' or
    item_name == 'lst' or
    item_name == 'sio' or
    item_name == 'feo' or
    item_name == 'o' then
    starting_area_resource = true
    rarity = 0.25
    max_size = 20
    density = 15
  end

  local deposit_entity = util.table.deepcopy(data.raw["resource"]["iron-ore"])
  deposit_entity.stage_counts = {1}
  deposit_entity.stages = {
    sheet = {
      filename = "__pu-supply-chain__/graphics/icons/"..item_name..".png",
      priority = "extra-high",
      width = 64,
      height = 64,
      frame_count = 1,
      variation_count = 1,
    }
  }
  deposit_entity.randomize_visual_position = false
  deposit_entity.autoplace = resource_autoplace.resource_autoplace_settings({
    name = item_name,
    order = item_name,
    base_density = 1,
    base_spots_per_km2 = rarity,
    has_starting_area_placement = starting_area_resource,
    random_spot_size_minimum = 8,
    random_spot_size_maximum = max_size,
    regular_blob_amplitude_multiplier = 1,
    richness_post_multiplier = 0.8,
    additional_richness = 300000,
    regular_rq_factor_multiplier = 0.1,
    candidate_spot_count = 22
  })
  deposit_entity.category = res_cat_name
  deposit_entity.minable.result = item_name
  deposit_entity.map_generator_bounding_box = {{-2.5, -2.5}, {2.5, 2.5}}
  deposit_entity.collision_box = {{-1, -1}, {1, 1}}
  deposit_entity.selection_box = {{-1, -1}, {1, 1}}
  deposit_entity.icon = "__pu-supply-chain__/graphics/icons/"..item_name..".png"
  deposit_entity.icon_size = 64
  deposit_entity.name = item_name

  --local ore_item =  {
  --  type = "item",
  --  name = res_data.name,
  --  icon = "__pu-supply-chain__/graphics/icons/generic-icon.png",
  --  icon_size = 64,
  --  subgroup = "raw-"..res_data.category,
  --  order = "e["..res_data.name.."]",
  --  stack_size = math.ceil(largest_recipe_stack/res_data.size)
  --}
  data:extend({deposit_entity})
end

for res_cat_name, res_data in pairs(resource_categories) do
  for _, item_name in pairs(res_data) do
    raw_patch(res_cat_name,item_name)
  end
end

--generate mining structures
local mining_structures = {
  {name="rig",cost={{"bse",12},{"mcg",40},},staff={30,0,0,0,0,},category='liquid'},
  {name="ext",cost={{"bse",16},{"mcg",100},},staff={60,0,0,0,0,},category='solid'},
  {name="col",cost={{"bse",16},{"mcg",60},},staff={50,0,0,0,0,},category='gas'},
}

local generate_mining_structure = function(miner_data)
  local miner_ent = util.table.deepcopy(data.raw["mining-drill"]["electric-mining-drill"])
  miner_ent.name = miner_data.name
  miner_ent.resource_categories = {miner_data.category}
  --miner_ent.animations = {
  --  frame_count = 1,
  --  filename = "__pu-supply-chain__/graphics/entity/generic-three-by-three.png",
  --  width = 96,
  --  height = 96,
  --}
  miner_ent.minable.results = miner_data.cost
  miner_ent.icon = "__pu-supply-chain__/graphics/icons/"..miner_data.name..".png"
  miner_ent.icon_size = 64
  miner_ent.mining_speed = 4
  miner_ent.minable.result = nil
  miner_ent.energy_source = {
    type = "void"
  }
  miner_ent.allowed_effects = {'speed'}
  miner_ent.module_specification = {module_slots= 1}
  miner_ent.resource_searching_radius = 1.49

  local miner_item = util.table.deepcopy(data.raw["item"]["stone-furnace"])
  miner_item.name = miner_data.name
  miner_item.place_result = miner_data.name
  miner_item.icon = "__pu-supply-chain__/graphics/icons/"..miner_data.name..".png"
  miner_item.icon_size = 64
  miner_item.subgroup = "pioneer"

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