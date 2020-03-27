local quest_gui = require('quest_gui')

local flying_congrats = function()
  for _, player in pairs(game.connected_players) do
    local position = player.position
    if not position.x then position.x = position[1] end
    if not position.y then position.y = position[2] end
    player.surface.create_entity{name = "tutorial-flying-text", text = {"flying-text.objective-complete"},
                                   position = {position.x, position.y - 1.5}, color = {r = 12, g = 243, b = 56}}
    
  end
end

local core_module_has_items = function(item_list)
  local core_module = global.core_module
  if core_module == nil or core_module.valid == false then
    global.core_module = game.surfaces['abregado-rae'].find_entities_filtered({name='cm'})[1] or nil
    return false
  end
  local has_items = true
  local inv = global.core_module.get_inventory(defines.inventory.chest)
  for _, item in pairs(item_list) do
    if inv.get_item_count(item.name) < item.goal then has_items = false end
    quest_gui.update_count('cm-contains-'..item.name,inv.get_item_count(item.name),item.goal)
  end
  return has_items
end

local colony_stockpiled_items = function(force_name,item_list)
  local force = game.forces[force_name]
  local result = true
  for _,item in pairs(item_list) do
    local made = force.item_production_statistics.get_input_count(item.name)
    local used = force.item_production_statistics.get_output_count(item.name)
    local count = made - used
    if count == 0 then
      result = false
      quest_gui.update_count('stockpile-'..item.name,0,item.goal)
    elseif count < item.goal then
      result = false
      quest_gui.update_count('stockpile-'..item.name,count,item.goal)
    else
      quest_gui.update_count('stockpile-'..item.name,count,item.goal)
    end
  end
  return result
end

local story_table = {
  {
    name = 'wait-for-players',
    condition = function()
      return global.story_started
    end
  },
  {
    name = 'setup-colony',
    init = function()
      local quest_layout =
      {
        {
          item_name = 'build-cm',
        },
        {
          item_name = 'cm-contains-dw',
          icons = {'item/dw'},
          goal = 100,
        },
        {
          item_name = 'cm-contains-rat',
          icons = {'item/rat'},
          goal = 100,
        }
      }
      quest_gui.set('setup-colony', quest_layout, game.forces['montem'])
      quest_gui.visible(true)
      
      quest_gui.add_hint({'hints.no-building-until-core-module'})
      quest_gui.add_hint({'hints.consumables-taken-from-core-module'})
    end,
    condition = function()
      local cm_exists = global.core_module and global.core_module.valid
      if cm_exists then
        quest_gui.update_state('build-cm',"success")
      end
      local items_in = core_module_has_items({
        {name='dw',goal=100},
        {name='rat',goal=100},
      })
      return (cm_exists and items_in) or global.skip
    end,
    action = function()
      global.skip = false
      flying_congrats()
    end
  },
  {
    name = 'stockpile-basics',
    init = function()
      local quest_layout =
      {
        {
          item_name = 'stockpile-dw',
          icons = {'item/dw'},
          goal = 600,
        },
        {
          item_name = 'stockpile-rat',
          icons = {'item/rat'},
          goal = 600,
        },
      }
      quest_gui.set('stockpile-basics', quest_layout)
      quest_gui.visible(true)
      
      quest_gui.add_hint({'hints.structures-disabled-until-upkeep'})
      quest_gui.add_hint({'hints.removing-structures-refunds'})
      quest_gui.add_hint({'hints.logistics-are-free'})
    end,
    condition = function()
      return colony_stockpiled_items('montem',{
        {name='dw',goal=600},
        {name='rat',goal=600},
      }) or global.skip
    end,
    action = function()
      global.skip = false
      flying_congrats()
    end
  },
  {
    name = 'stockpile-construction',
    init = function()
      local quest_layout =
      {
        {
          item_name = 'stockpile-bbh',
          icons = {'item/bbh'},
          goal = 60,
        },
        {
          item_name = 'stockpile-bse',
          icons = {'item/bse'},
          goal = 100,
        },
        {
          item_name = 'stockpile-bta',
          icons = {'item/bta'},
          goal = 10,
        },
        {
          item_name = 'stockpile-bde',
          icons = {'item/bde'},
          goal = 20,
        },
        {
          item_name = 'stockpile-mcg',
          icons = {'item/mcg'},
          goal = 1500,
        },
      }
      quest_gui.set('stockpile-construction', quest_layout)
      quest_gui.visible(true)
      
      quest_gui.add_hint({'hints.disabled-buildings'})
      quest_gui.add_hint({'hints.deconstruction-planner'})
      quest_gui.add_hint({'hints.use-the-same-structure'})
    end,
    condition = function()
      return colony_stockpiled_items('montem',{
        {name='bbh',goal=60},
        {name='bse',goal=100},
        {name='bta',goal=10},
        {name='bde',goal=20},
        {name='mcg',goal=1500},
      }) or global.skip
    end,
    action = function()
      global.skip = false
      flying_congrats()
    end
  },
  {
    name = 'stockpile-settler-equipment',
    init = function()
      local quest_layout =
      {
        {
          item_name = 'stockpile-tru',
          icons = {'item/tru'},
          goal = 40,
        },
        {
          item_name = 'stockpile-exo',
          icons = {'item/exo'},
          goal = 10,
        },
        {
          item_name = 'stockpile-pt',
          icons = {'item/pt'},
          goal = 10,
        },
      }
      quest_gui.set('stockpile-settler-equipment', quest_layout)
      quest_gui.visible(true)
      
      quest_gui.add_hint({'hints.higher-tier-colonist-needs'})
    end,
    condition = function()
      return colony_stockpiled_items('montem',{
        {name='tru',goal=40},
        {name='exo',goal=10},
        {name='pt',goal=10},
      }) or global.skip
    end,
    action = function()
      global.skip = false
      flying_congrats()
    end
  },
  {
    name = 'build-spacedock',
    init = function()
      local quest_layout =
      {
        {
          item_name = 'stockpile-ng',
          icons = {'item/ng'},
          goal = 100,
        },
        {
          item_name = 'stockpile-bgc',
          icons = {'item/bgc'},
          goal = 400,
        },
        {
          item_name = 'stockpile-dcl',
          icons = {'item/dcl'},
          goal = 50,
        },
        {
          item_name = 'stockpile-dcm',
          icons = {'item/dcm'},
          goal = 100,
        },
        {
          item_name = 'stockpile-sf',
          icons = {'item/sf'},
          goal = 1500,
        },
      }
      quest_gui.set('build-spacedock', quest_layout)
      quest_gui.visible(true)
      
    end,
    condition = function()
      return colony_stockpiled_items('montem',{
        {name='ng',goal=100},
        {name='bgc',goal=400},
        {name='dcl',goal=50},
        {name='dcm',goal=100},
        {name='sf',goal=1500},
      }) or global.skip
    end,
    action = function()
      global.skip = false
      flying_congrats()
    end
  },
  {
    name = 'build-ftl-ship',
    init = function()
      local quest_layout =
      {
        {
          item_name = 'stockpile-nv1',
          icons = {'item/nv1'},
          goal = 3,
        },
        {
          item_name = 'stockpile-nv2',
          icons = {'item/nv2'},
          goal = 1,
        },
        {
          item_name = 'stockpile-cc',
          icons = {'item/cc'},
          goal = 30,
        },
        {
          item_name = 'stockpile-cru',
          icons = {'item/cru'},
          goal = 100,
        },
        {
          item_name = 'stockpile-ffc',
          icons = {'item/ffc'},
          goal = 40,
        },
        {
          item_name = 'stockpile-lis',
          icons = {'item/lis'},
          goal = 100,
        },
        {
          item_name = 'stockpile-tac',
          icons = {'item/tac'},
          goal = 50,
        },
        {
          item_name = 'stockpile-wr',
          icons = {'item/wr'},
          goal = 50,
        },
        {
          item_name = 'stockpile-sf',
          icons = {'item/sf'},
          goal = 1500,
        },
        {
          item_name = 'stockpile-ff',
          icons = {'item/ff'},
          goal = 1500,
        },
      }
      quest_gui.set('build-ftl-ship', quest_layout)
      quest_gui.visible(true)
    end,
    condition = function()
      return colony_stockpiled_items('montem',{
        {name='nv1',goal=3},
        {name='nv2',goal=1},
        {name='cc',goal=30},
        {name='cru',goal=100},
        {name='ffc',goal=40},
        {name='lis',goal=100},
        {name='tac',goal=50},
        {name='wr',goal=50},
        {name='sf',goal=1500},
        {name='ff',goal=1500},
      }) or global.skip
    end,
    action = function()
      global.skip = false
      game.set_game_state({game_finished=true,player_won=true,can_continue=true})
    end
  },
}

return story_table