Light & Shadow
==============

A simple dynamic light shadow library for LOVE2D 11.2.

It's easy to use, don't need to create body for shadow, directly generate shadow from canvas/image according alpha.
So it's not fast, and don't support 3D shadow.
If you want a fast and 3D light shadow library, [Light World](https://github.com/xiejiangzhi/light_world.lua) and [Shadow](https://github.com/matiasah/shadows) is better choice.


## Example

![Example Image](./example.png)


##Usage

```
local Lib = require 'light'
local light_world = Lib.World.new()
local light

local lg = love.grpahics

function love.load()
  light = light_world:add(200, 200, 200, 1, 0, 0)
end

function love.update(dt)
  light.x, light.y = love.mouse.getPosition()
end

function love.draw()
  -- reset light world
  light_world:begin()

  for i = 1, 10 do
    lg.circle('fill', 100 + i * 70, 300, 10)
  end

  -- track shadow objects
  light_world:track_obj()
  for i = 1, 10 do
    lg.circle('fill', 100 + i * 70, 300 + i * 50, 30)
  end
  -- draw background
  light_world:track_bg()

  for i = 1, 10 do
    lg.circle('fill', 100 + i * 70, 500 + i * 50, 30)
  end

  -- draw scene, light and shadow
  light_world:finish()

  lg.print('mouse: '..mx..','..my..' light: '..light.x..','..light.y, 50, 50)
end
```


## Functions

### World

* `World.new({ env_light = { 0.5, 0.4, 0.5, 0.5 }, alpha_through = 0.3 })` if a object alpha less than `alpha_through`, we will not generate shadow for it
* `World:begin()` reset light world and start track background pixels.
* `World:track_obj()` switch to draw object mode, pixels is affected by light and has shadow.
* `World:track_light_objs()` switch to draw object mode, pixels is always light and has shadow.
* `World:track_bg()` switch to draw background mode, new pixels is affected by light.
* `World:track_light_bg()` switch to draw background mode, the pixels always is light and it has no shadow
* `World:finish()` draw bg, objects, light and shadow to screen.
* `World:add(x, y, radius, r, g, b, a)` add a light to world, return `light`
* `World:remove(light)` remove the light from world
* `World:clear()` remove all lights
* `World:setEnvLight(r, g, b, a)`
* `World:resize(w, h)` you must call it after change window size
* `World:setTranslate(x, y, scale)` you must call it if your applied `love.graphics.translate` or `love.graphics.scale`
* `World.env_tex=[canvas/image]`
* `World.pause=true` Stop light and shadow feature.


### Light

* `Light:setSize(radius)` resize the light


## Tips

* If the `env_light` is `1, 1, 1, 1`, no light and shadow can be draw. In an overly bright environment you will not see light and shadow
* If the background alpha is too little, we will not see the light because no object can reflect this light into your eyes
* When you have a lot of light, it will very slow. the light size and quantity will affect performance. (I will try to make it faster)


## TODO

* Fix shadow for `source_radius` argument.
* Support shadow for semitransparent objects.(shadow map able to save four floats.)
* Optimize according to [here](https://github.com/mattdesl/lwjgl-basics/wiki/2D-Pixel-Perfect-Shadows#optimizations)
