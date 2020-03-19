
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

--generate mining structures
local structures = {
  {name="rig",cost={{"bse",12},{"mcg",40},},staff={30,0,0,0,0,}},
  {name="ext",cost={{"bse",16},{"mcg",100},},staff={60,0,0,0,0,}},
  {name="col",cost={{"bse",16},{"mcg",60},},staff={50,0,0,0,0,}},
}

local generate_production_structure = function(structure_data)
  local tier = "pioneer"

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
  if not structure_data.skip then
    generate_production_structure(structure_data)
  end
end