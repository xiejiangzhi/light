local Light = require 'light'
local private = {}

local light_world = Light.World.new({
  env_light = { 0.3, 0.3, 0.3, 1 },
  alpha_through = 0.5,
})

local lg = love.graphics

local light
local mx, my = 0, 0
local ox, oy, scale = 500, 100, 0.5

function love.load()
  light_world:setTranslate(ox, oy, scale)
  light = light_world:add(200, 200, 500, 1, 0.1, 0.1, 1, { source_radius = 10 })
  light.source_radius = 35
end

function love.update(dt)
  mx, my = love.mouse.getPosition()
  light.x = mx / scale - ox
  light.y = my / scale - oy
  light:setSize(300 + math.sin(love.timer.getTime() / 2) * 200)
end

function love.draw()
  light_world:begin()

  lg.setColor(0.3, 0.3, 0.3)
  lg.rectangle('fill', 0, 0, 500, 400)
  lg.setColor(1, 1, 1, 1)
  lg.rectangle('fill', 500, 0, 500, 400)


  lg.print('FPS: '..love.timer.getFPS(), 10, 10)
  lg.print('mouse: '..mx..','..my..' light: '..light.x..','..light.y, 10, 50)

  light_world:track()
  private.translate()

  for i = 1, 10 do
    lg.circle('fill', 100 + i * 70, 300, 10)
    lg.circle('fill', 100 + i * 70, 300 + i * 50, 30)
  end
  lg.setColor(1, 0, 0, 0.5)
  lg.circle('fill', 300, 700, 100)
  lg.setColor(0, 1, 0, 1)
  lg.circle('fill', 900, 300, 100)
  light_world:stop()
  lg.setColor(0, 0, 1, 1)
  lg.circle('fill', 900, 700, 100)
  light_world:track()
  lg.setColor(1, 0, 0, 1)
  lg.circle('fill', 1000, 500, 100)
  lg.setColor(1, 1, 1, 1)

  lg.print("Hello Light", 1200, 800, 5, 10, 10)

  private.reset()

  light_world:finish()

  -- lg.rectangle('line', 150, 150, 100, 100)
  private.translate()
  -- lg.rectangle('line', 150, 150, 100, 100)
  lg.rectangle('line', light.x - light.radius, light.y - light.radius, light.size, light.size)
  private.reset()
end

function love.mousepressed(x, y, btn)
  if btn == 1 then
    light = light_world:add(x / scale - ox, y / scale - oy, 500, love.random_color())
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
  local r = love.math.random()

  if r < 0.25 then
    return 1, 0.1, 0.1, 1
  elseif r < 0.5 then
    return 0.1, 1, 0.1, 1
  elseif r < 0.75 then
    return 0.1, 0.1, 1, 1
  else
    return 1, 1, 1, 1
  end
end

function private.translate()
  lg.push()
  lg.scale(scale)
  lg.translate(ox, oy)
  lg.rotate(0.5)
end

function private.reset()
  lg.pop()
end

