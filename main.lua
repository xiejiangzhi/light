local Light = require 'light'
local private = {}

local light_world = Light.new({env_color = { 0.5, 0.5, 0.5 }})

local lg = love.graphics

local light
local ox, oy = 0, 0
local scale = 0.5

function love.load()
  love.resize(lg.getDimensions())
  light = light_world:add(200, 200, 200, 1, 0, 0, 1)
  light_world:setTranslate(ox, oy, scale)
end

function love.update(dt)
  light.x, light.y = love.mouse.getPosition()
  light.x = (light.x - ox) / scale
  light.y = (light.y - oy) / scale
end

function love.draw()
  light_world:begin()
  private.translate()

  for i = 1, 10 do
    lg.circle('fill', 100 + i * 70, 300, 10)
  end
  private.reset()

  light_world:finish()

  lg.rectangle('line', 150, 150, 100, 100)
  private.translate()
  lg.rectangle('line', 150, 150, 100, 100)
  lg.rectangle('line', light.x - light.radius, light.y - light.radius, light.size, light.size)
  private.reset()
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

function private.translate()
  lg.push()
  lg.translate(ox, oy)
  lg.scale(scale)
  lg.rotate(0.5)
end

function private.reset()
  lg.pop()
end

