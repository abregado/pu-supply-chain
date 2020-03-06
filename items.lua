  data:extend({
    {
      type = "item-group",
      name = "products",
      order = "z",
      icon = "__pu-supply-chain__/graphics/icons/generic-icon.png",
      icon_size = 64
    },
  })

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

local new_basic_item = function(item_data)
  local new_basic_item =   {
    type = "item",
    name = item_data.name,
    icon = "__pu-supply-chain__/graphics/icons/"..item_data.category..".png",
    icon_size = 64, icon_mipmaps = 4,
    subgroup = item_data.category,
    order = "e["..item_data.name.."]",
    stack_size = math.ceil(largest_recipe_stack/item_data.size)
  }
  data:extend({new_basic_item})
end

for _, item_group_name in pairs(data_import.item_groups) do
  generate_item_group(item_group_name)
end

for _, item_data in pairs(data_import.materials) do
  new_basic_item(item_data)
end