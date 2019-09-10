local Lib = require 'light'
local light_world = Lib.World.new()
local light1, light2, light3, light4

local lg = love.graphics

function love.load()
  light1 = light_world:add(200, 200, 200, 1, 1, 1)
  light2 = light_world:add(200, 200, 200, 0, 1, 0)
  light3 = light_world:add(200, 200, 200, 0, 0, 1)
  light4 = light_world:add(200, 200, 200, 1, 0, 0)
end

function love.update(dt)
  local mx, my = love.mouse.getPosition()
  light1.x, light1.y = mx, my

  light2.x, light2.y = mx - 100, my + 100
  light3.x, light3.y = mx + 100, my + 100
  light4.x, light4.y = mx, my - 150
end

function love.draw()
  -- reset light world
  light_world:begin()

  lg.print('FPS: '..love.timer.getFPS(), 10, 10)

  lg.setColor(0.7, 0.7, 0.7)
  lg.rectangle('fill', 0, 0, 400, 400)
  lg.setColor(0.3, 0.3, 0.3)
  lg.rectangle('fill', 400, 0, 400, 400)
  lg.setColor(1, 1, 1)

  for i = 1, 10 do
    lg.circle('fill', 100 + i * 70, 300, 10)
  end

  -- draw shadow for those objects
  light_world:track()
  for i = 1, 10 do
    lg.circle('fill', 100 + i * 70, 300 + i * 50, 30)
  end
  -- stop track, new object is background
  light_world:stop()

  for i = 1, 10 do
    lg.circle('fill', 100 + i * 70, 500 + i * 50, 30)
  end

  -- draw scene, light and shadow
  light_world:finish()

end
