Light & Shadow
==============



##Usage

```
local Light = require 'light'
local light_world = Light.new({env_color = { 0.5, 0.5, 0.5 }})

function love.load()
  -- init window size, also should call it after resize window
  love.resize(lg.getDimensions())

  -- create a light (x, y, radius, r, g, b, a)
  light = light_world:add(200, 200, 200, 1, 0, 0, 1)

  -- set translate if you called translate or scale between `light_world:begin()` and `light_world:finish()`
  light_world:setTranslate(ox, oy, scale)
end

function love.update(dt)
  -- you can cahgne x, y, r, g, b, a any time
  mx, my = love.mouse.getPosition()
  light.x = mx / scale - ox
  light.y = my / scale - oy
end

function love.draw()
  -- call `begin` before you draw something that need shadow
  light_world:begin()

  private.translate()

  for i = 1, 10 do
    lg.circle('fill', 100 + i * 70, 300, 10)
    lg.circle('fill', 100 + i * 70, 300 + i * 50, 30)
  end
  private.reset()

  -- call `finish` after you finish the draw.
  -- draw light and shadow for your scene items that alpha > 0 
  light_world:finish()

  lg.print('mouse: '..mx..','..my..' light: '..light.x..','..light.y, 50, 50)
end

function love.mousepressed(x, y, btn)
  if btn == 1 then
    light_world:add(x / scale - ox, y / scale - oy, 300, love.random_color())
  elseif btn == 2 then
    -- clear all light
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
end

function private.reset()
  lg.pop()
end
```


