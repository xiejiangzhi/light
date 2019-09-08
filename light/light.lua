-- https://github.com/mattdesl/lwjgl-basics/wiki/2D-Pixel-Perfect-Shadows

local M = {}
local private = {}

local lg = love.graphics

local scene_canvas
local lights = {}

local canvas_size = 256
local hcanvas_size = canvas_size / 2

function M.resize(w, h)
  scene_canvas = lg.newCanvas(w, h)
end

function M.add(x, y, radius, r, g, b, a)
  local size = radius * 2
	local light = {
    x = x, y = y,
    radius = radius, size = size,
    r = r, g = g, b = b, a = a,
    scale = canvas_size / size,
		shadow_map_canvas = love.graphics.newCanvas(canvas_size, 1),
		full_canvas = love.graphics.newCanvas(canvas_size, canvas_size),
	}
  lights[#lights + 1] = light

  return light
end

-- Clear all lights.
function M.clear()
	lights = {}
end

function M.begin()
  lg.setCanvas(scene_canvas)
end

function M.finish()
  lg.setCanvas()

  lg.draw(scene_canvas)

	for i, light in ipairs(lights) do
    private.generateShadowMap(light)
    private.generateLight(light)

    lg.setBlendMode("add")
    lg.draw(
      light.full_canvas, light.x, light.y, 0,
      1 / light.scale, -1 / light.scale, hcanvas_size, hcanvas_size
    )
    lg.setBlendMode("alpha")
  end
end

-----------------------------

function private.generateShadowMap(light)
  local sx, sy = light.x - light.radius, light.y - light.radius

  private.drawto(light.full_canvas, nil, function()
    lg.push()
    lg.scale(light.scale)
    lg.translate(-sx, -sy)
    lg.draw(scene_canvas, 0, 0)
    lg.pop()
  end)

  private.drawto(light.shadow_map_canvas, M.shadow_map_shader, function()
    M.shadow_map_shader:send("resolution", { light.size, light.size });
    lg.draw(light.full_canvas)
  end)
end

function private.generateLight(light)
  private.drawto(light.full_canvas, M.render_light_shader, function()
    M.render_light_shader:send("resolution", { canvas_size, canvas_size });
    lg.setColor(light.r, light.g, light.b, light.a)
    lg.draw(light.shadow_map_canvas, 0, 0, 0, 1, canvas_size)
    lg.setColor(1, 1, 1, 1)
  end)
end

function private.drawto(canvas, shader, fn, fn_args)
  lg.push()
  lg.origin()
  lg.setCanvas(canvas)
  lg.setShader(shader)
  lg.clear()

  fn()

  lg.setShader()
  lg.setCanvas()
  lg.pop()
end

return M
