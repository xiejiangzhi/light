local Light = require 'light'

local light_world = Light.new({env_color = { 0.5, 0.5, 0.5 }})

local lg = love.graphics

local light

function love.load()
  love.resize(lg.getDimensions())
  light = light_world:add(200, 200, 1000, 1, 0, 0, 0.5)
end

function love.update(dt)
  light.x, light.y = love.mouse.getPosition()
end

function love.draw()
  light_world:begin()

  for i = 1, 10 do
    lg.circle('fill', 100 + i * 70, 300, 10)
  end

  light_world:finish()
end

function love.mousepressed(x, y)
  light_world:add(x, y, 300, love.random_color())
end

function love.resize(w, h)
  if w > 0 and h > 0 then
    light_world:resize(w, h)
  end
end

function love.random_color()
  return 0.5 + love.math.random() / 2,
    0.5 + love.math.random() / 2,
    0.5 + love.math.random() / 2,
    0.5
end

