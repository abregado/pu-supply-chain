require("util")
data_import = require("data-import")
require('constants')
require('raw-items')
require('items')
require('recipes')
require('production-structures')
require('logistics')
require('sprites')
require('campaign_styles')
require('campaign_sounds')
require('campaign_sprites')

data:extend({
  {
    type = "tile",
    name = "grey-1",
    order = "a",
    collision_mask = {"ground-tile"},
    layer = 1,
    variants =
    {
      main =
      {
        {
          picture = "__pu-supply-chain__/graphics/tiles/grey-1.png",
          count = 1,
          size = 1
        }
      },
      empty_transitions = true
    },
    map_color={r=49, g=49, b=49},
    pollution_absorption_per_second = 0
  },
  {
    type = "tile",
    name = "grey-2",
    order = "b",
    collision_mask = {"ground-tile"},
    layer = 2,
    variants =
    {
      main =
      {
        {
          picture = "__pu-supply-chain__/graphics/tiles/grey-2.png",
          count = 1,
          size = 1
        }
      },
      empty_transitions = true
    },
    map_color={r=0, g=0, b=0},
    pollution_absorption_per_second = 0
  },
  {
    type = "flying-text",
    name = "tutorial-flying-text",
    flags = {"not-on-map", "placeable-off-grid"},
    time_to_live = 120,
    speed = 0.02,
    text_alignment = "center"
  },
})
