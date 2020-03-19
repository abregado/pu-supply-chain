
--local maint = require('maint')
--require('constants')
--local math2d = require('math2d')





--local on_player_created = function(event)
--  local player = game.players[event.player_index]
--  if player.character then
--    local old_char = player.character
--    player.character = nil
--    old_char.destroy()
--    player.get_main_inventory().clear()
--  end
--  local starting_items = {{'dw',1000},{"lse",4},{"tru",8},{"psl",12},{"lde",4},{"lta",4},{"mcg",1000},{'bse',100},{'bta',20,},{'bbh',30},{'bde',50}}
--  for _, stack in pairs(starting_items) do
--    player.insert({name=stack[1],count=stack[2]})
--  end
--  player.insert('pu-inserter')
--  player.insert('pu-transport-belt')
--  player.insert('pu-splitter')
--  player.insert('pu-underground-belt')
--end

