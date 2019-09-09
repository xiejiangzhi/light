-- https://github.com/mattdesl/lwjgl-basics/wiki/2D-Pixel-Perfect-Shadows

local M = {}
M.__index = M
local private = {}

local lg = love.graphics


local canvas_size = 512

local shadow_area_canvas = love.graphics.newCanvas(canvas_size, canvas_size)

function M.new(opts)
  local obj = setmetatable({}, M)

  obj.env_color = { 0, 0, 0, 0 }

  -- coord translate
  obj.x = 0
  obj.y = 0
  obj.scale = 1
  obj.w, obj.h = lg.getDimensions()

  obj.scene_canvas = lg.newCanvas(obj.w, obj.h)
  obj.light_buffer = lg.newCanvas(obj.w, obj.h)

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
    r = r, g = g, b = b, a = a or 1,
    scale = canvas_size / size,
		shadow_map_canvas = love.graphics.newCanvas(canvas_size, 1),
		full_canvas = love.graphics.newCanvas(size, size),
	}
  self.lights[#self.lights + 1] = light

  return light
end

function M:setEnvColor(r, g, b, a)
  self.env_color = { r, g, b, a }
end

function M:begin()
  lg.setCanvas(self.scene_canvas)
  lg.clear()
end

function M:finish()
  lg.setCanvas()

  private.reset_light_buffer(self.light_buffer)

  local sx, sy
	for i, light in ipairs(self.lights) do
    private.cutLightArea(self.scene_canvas, light, self.x, self.y, self.scale)
    private.generateShadowMap(light)
    private.generateLight(light, self.scale)
    sx = light.x - light.radius
    sy = light.y - light.radius + light.size

    private.drawto(self.light_buffer, nil, function()
      lg.setBlendMode("add")
      lg.scale(self.scale)
      lg.translate(self.x, self.y)
      lg.draw(light.full_canvas, sx, sy, 0, 1, -1)
      lg.setBlendMode("alpha")
    end)
  end

  M.draw_light_shader:send('bg_tex', self.scene_canvas)
  M.draw_light_shader:send('env_color', self.env_color)
  private.drawto(nil, M.draw_light_shader, function()
    lg.draw(self.light_buffer)
  end)
end

function M:resize(w, h)
  assert(w > 0 and h > 0, "Invalid w or h, cannot <= 0")

  self.w, self.h = w, h
  self.scene_canvas = lg.newCanvas(w, h)
  self.light_buffer = lg.newCanvas(w, h)
end

function M:setTranslate(x, y, scale)
  self.x, self.y = x, y
  if scale then self.scale = scale end
end

-- Clear all lights.
function M:clear()
	self.lights = {}
end


-----------------------------

function private.cutLightArea(scene_canvas, light, ox, oy, scale)
  local sx, sy = (light.x - light.radius + ox) * scale, (light.y - light.radius + oy) * scale
  scale = canvas_size / (light.size * scale)

  -- lg.print(''..sx..','..sy..', scale: '..light.scale..' -> '..scale, 10, 10)

  private.drawto(shadow_area_canvas, nil, function()
    lg.clear()
    lg.push()
    lg.scale(scale)
    lg.translate(-sx, -sy)
    lg.draw(scene_canvas)
    lg.pop()
  end)

  -- lg.draw(shadow_area_canvas)
  -- lg.rectangle('line', 0, 0, shadow_area_canvas:getDimensions())
  -- lg.rectangle('line', light.x - light.radius, light.y - light.radius, light.size, light.size)
end

function private.generateShadowMap(light)
  private.drawto(light.shadow_map_canvas, M.shadow_map_shader, function()
    lg.clear()
    M.shadow_map_shader:send("resolution", { light.size, light.size });
    lg.draw(shadow_area_canvas)
  end)
end

function private.generateLight(light, scale)
  M.render_light_shader:send('scene_tex', shadow_area_canvas)
  private.drawto(light.full_canvas, M.render_light_shader, function()
    lg.clear()
    M.render_light_shader:send("resolution", { light.size, light.size });
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

function private.reset_light_buffer(canvas, env_color)
  lg.setCanvas(canvas)
  lg.clear()
  if env_color then
    lg.setColor(unpack(env_color))
    lg.rectangle('fill', 0, 0, canvas:getDimensions())
    lg.setColor(1, 1, 1, 1)
  end
  lg.setCanvas()
end

function private.reset_buffer_canvas()
end

return M
