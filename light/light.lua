-- https://github.com/mattdesl/lwjgl-basics/wiki/2D-Pixel-Perfect-Shadows

local M = {}
M.__index = M
local private = {}

local lg = love.graphics

local scene_canvas, light_buffer

local canvas_size = 512

local shadow_area_canvas = love.graphics.newCanvas(canvas_size, canvas_size)

function M.new(opts)
  local obj = setmetatable({}, M)

  obj.env_color = { 0, 0, 0 }

  for k, v in pairs(opts or {}) do
    if obj[k] ~= nil then
      obj[k] = v
    else
      error("Invalid key "..k)
    end
  end

  obj.lights = {}

  return obj
end

function M:add(x, y, radius, r, g, b, a)
  local size = radius * 2
	local light = {
    x = x, y = y,
    radius = radius, size = size,
    r = r, g = g, b = b, a = a,
    scale = canvas_size / size,
		shadow_map_canvas = love.graphics.newCanvas(canvas_size, 1),
		full_canvas = love.graphics.newCanvas(size, size),
	}
  self.lights[#self.lights + 1] = light

  return light
end

function M:setEnvColor(r, g, b)
  self.env_color = { r, g, b }
end

function M:begin()
  lg.setCanvas(scene_canvas)
end

function M:finish()
  lg.setCanvas()

  lg.draw(scene_canvas)
  lg.setCanvas(light_buffer)
  lg.clear()
  lg.setColor(unpack(self.env_color))
  lg.rectangle('fill', 0, 0, self.w, self.h)
  lg.setColor(1, 1, 1)
  lg.setCanvas()

	for i, light in ipairs(self.lights) do
    private.generateShadowMap(light)
    private.generateLight(light)

    private.drawto(light_buffer, nil, function()
      lg.setBlendMode("add")
      lg.draw(light.full_canvas, light.x - light.radius, light.y - light.radius + light.size, 0, 1, -1)
      lg.setBlendMode("alpha")
    end)
  end

  private.drawto(nil, nil, function()
    lg.setBlendMode("add")
    lg.draw(light_buffer)
    lg.setBlendMode("alpha")
  end)
end

function M:resize(w, h)
  assert(w > 0 and h > 0, "Invalid w or h, cannot <= 0")

  self.w, self.h = w, h
  scene_canvas = lg.newCanvas(w, h)
  light_buffer = lg.newCanvas(w, h)
end


-- Clear all lights.
function M:clear()
	self.lights = {}
end


-----------------------------

function private.generateShadowMap(light)
  local sx, sy = light.x - light.radius, light.y - light.radius

  private.drawto(shadow_area_canvas, nil, function()
    lg.clear()
    lg.push()
    lg.scale(light.scale)
    lg.translate(-sx, -sy)
    lg.draw(scene_canvas, 0, 0)
    lg.pop()
  end)

  private.drawto(light.shadow_map_canvas, M.shadow_map_shader, function()
    lg.clear()
    M.shadow_map_shader:send("resolution", { light.size, light.size });
    lg.draw(shadow_area_canvas)
  end)
end

function private.generateLight(light)
  private.drawto(light.full_canvas, M.render_light_shader, function()
    lg.clear()
    M.render_light_shader:send("resolution", { light.size, light.size });
    -- M.render_light_shader:send("shadow_color", { 1, 1, 1, 0.5 });
    lg.setColor(light.r, light.g, light.b, light.a)
    lg.draw(light.shadow_map_canvas, 0, 0, 0, 1 / light.scale, light.size)
    lg.setColor(1, 1, 1, 1)
  end)
end

function private.drawto(canvas, shader, fn, fn_args)
  lg.push()
  lg.origin()
  lg.setCanvas(canvas)
  lg.setShader(shader)

  fn()

  lg.setShader()
  lg.setCanvas()
  lg.pop()
end

return M
