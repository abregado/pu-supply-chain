local welcome = {}

welcome.create = function(player)
  local frame = player.gui.center.add({
    type = 'frame',
    direction = 'vertical',
    name = 'welcome',
    caption = { 'welcome-screen.heading' }
  })
  frame.style.width = 420
  
  frame.add({
    type = 'sprite',
    sprite = "welcome-sprite",
    name = 'population'
  })
  
  local scroller = frame.add({
    type = 'scroll-pane',
    name = 'scrolling-text',
    direction = "vertical"
  })
  scroller.style.height = 400
  
  for h=1,7 do
    local text = scroller.add({
      type='label',
      caption = {"",{"welcome-screen.text-"..h},"\n"},
    })
    text.style.single_line = false
    text.style.width = 380
  end
  
  frame.add({
    type = 'button',
    name = 'begin_game',
    style = 'confirm_button',
    caption = {"welcome-screen.confirm"}
  })
  
end

welcome.on_click = function(event)
  if event.element and event.element.valid and event.element.name == 'begin_game' then
    event.element.parent.destroy()
    return true
  end
  return false
end

return welcome
