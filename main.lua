local Light = require 'light'

local lg = love.graphics

local light

function love.load()
  love.resize()
  light = Light.add(200, 200, 500, 1, 0, 0, 0.5)
end

function love.update(dt)
  light.x, light.y = love.mouse.getPosition()
end

function love.draw()
  Light.begin()

  for i = 1, 10 do
    lg.circle('fill', 100 + i * 70, 300, 10)
  end

  Light.finish()

  -- lg.push()
  -- lg.rectangle('line', 100, 100, 200, 200)
  -- lg.translate(-100, -100)
  -- lg.setColor(1, 0, 0)
  -- lg.rectangle('line', 100, 100, 200, 200)
  -- lg.scale(0.1)
  -- lg.setColor(0, 0, 1)
  -- lg.rectangle('line', 100, 100, 200, 200)
  -- lg.setColor(1, 1, 1)
  -- lg.pop()
end

function love.resize(w, h)
  Light.resize(w, h)
end

