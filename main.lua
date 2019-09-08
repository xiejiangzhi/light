local Light = require 'light'
local private = {}

local light_world = Light.new({env_color = { 0.5, 0.5, 0.5 }})

local lg = love.graphics

local light
local mx, my = 0, 0
local ox, oy, scale = 100, 200, 0.5

function love.load()
  love.resize(lg.getDimensions())
  light = light_world:add(200, 200, 300, 1, 0, 0, 0.5)
  light_world:setTranslate(ox, oy, scale)
end

function love.update(dt)
  mx, my = love.mouse.getPosition()
  light.x = mx / scale - ox
  light.y = my / scale - oy
end

function love.draw()
  light_world:begin()
  private.translate()

  for i = 1, 10 do
    lg.circle('fill', 100 + i * 70, 300, 10)
    lg.circle('fill', 100 + i * 70, 300 + i * 50, 30)
  end
  lg.setColor(1, 1, 0, 0.5)
  lg.circle('fill', 300, 700, 100)
  lg.setColor(1, 1, 1, 1)

  private.reset()

  light_world:finish()

  -- lg.rectangle('line', 150, 150, 100, 100)
  private.translate()
  -- lg.rectangle('line', 150, 150, 100, 100)
  lg.rectangle('line', light.x - light.radius, light.y - light.radius, light.size, light.size)
  private.reset()
  lg.print('mouse: '..mx..','..my..' light: '..light.x..','..light.y, 50, 50)
end

function love.mousepressed(x, y, btn)
  if btn == 1 then
    light_world:add(x / scale - ox, y / scale - oy, 300, love.random_color())
  elseif btn == 2 then
    light_world:clear()
  end
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
  lg.scale(scale)
  lg.translate(ox, oy)
  -- lg.rotate(0.5)
end

function private.reset()
  lg.pop()
end

