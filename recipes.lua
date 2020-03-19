local set_up_crafting_category = function(recipe_category)
  --create crafting category
  data:extend({
    {
      type = "recipe-category",
      name = recipe_category
    },
  })
end

local generate_item_group = function(group_name)
  data:extend({
    {
      type = "item-subgroup",
      name = group_name,
      group = "products",
      order = group_name
    }
  })
end

local find_item_category = function(item_name)
  for _, item_data in pairs(data_import.materials) do
    if item_name == item_data.name then
      return item_data.category
    end
  end
end

local generate_recipe = function (recipe_data)
  local item_category = find_item_category(recipe_data.results[1][1])
  local new_recipe = {
    type = "recipe",
    name = recipe_data.name,
    --icon = "__pu-supply-chain__/graphics/icons/generic-icon.png",
    --icon_size = 64, icon_mipmaps = 4,
    energy_required = recipe_data.time/10000*time_multiplier,
    category = recipe_data.category,
    ingredients = recipe_data.ingredients,
    group = "products",
    subgroup = item_category,
    results = recipe_data.results,
    always_show_made_in = true,
    main_product = recipe_data.results[1][1],
    --localised_name = {"string"},
    enabled = true
  }
  data:extend({new_recipe})
end

for _, structure_data in pairs(data_import.structures) do
  set_up_crafting_category(structure_data.name)
  generate_item_group(structure_data.name)
end

for _, recipe_data in pairs(data_import.recipes) do
  generate_recipe(recipe_data)
end

for _, ext_product_name in pairs(data_import.raw_recipes['ext']) do
  for quality=1,5 do
    local quality_recipe_data = {
      name=ext_product_name.."-"..quality,
      category='ext',
      time=86400,
      ingredients={},
      results={
        {ext_product_name,70/5*quality}
      }
    }
    generate_recipe(quality_recipe_data)
  end
end

for _, rig_product_name in pairs(data_import.raw_recipes['rig']) do
  for quality=1,5 do
    local quality_recipe_data = {
      name=rig_product_name.."-"..quality,
      category='rig',
      time=86400,
      ingredients={},
      results={
        {rig_product_name,70/5*quality}
      }
    }
    generate_recipe(quality_recipe_data)
  end
end

for _, col_product_name in pairs(data_import.raw_recipes['col']) do
  for quality=1,5 do
    local quality_recipe_data = {
      name=col_product_name.."-"..quality,
      category='col',
      time=86400,
      ingredients={},
      results={
        {col_product_name,70/5*quality}
      }
    }
    generate_recipe(quality_recipe_data)
  end
end