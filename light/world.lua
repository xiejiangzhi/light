-- https://github.com/mattdesl/lwjgl-basics/wiki/2D-Pixel-Perfect-Shadows

local M = {}
M.__index = M
local private = {}

local lg = love.graphics

local Light

local shadow_map_size
local shadow_area_canvas, shadow_map_canvas
local shadow_map_shader, render_light_shader, draw_light_shader

function M.init(sub_libs, conf)
  Light = sub_libs.Light
  local lib_path = conf.lib_path

  shadow_map_size = conf.shadow_map_size
  shadow_area_canvas = lg.newCanvas(shadow_map_size, shadow_map_size)
  shadow_map_canvas = lg.newCanvas(shadow_map_size, 1)

  local glsl_path = lib_path:gsub('%.', '/')
  shadow_map_shader = lg.newShader(glsl_path..'/shadow_map.glsl')
  render_light_shader = lg.newShader(glsl_path..'/render_light.glsl')
  draw_light_shader = lg.newShader(glsl_path..'/draw_light.glsl')
end

function M.new(opts)
  local obj = setmetatable({}, M)

  obj.env_tex = nil
  obj.env_light = { 0.5, 0.5, 0.5, 0.5 }

  -- coord translate
  obj.x = 0
  obj.y = 0
  obj.scale = 1
  obj.w, obj.h = lg.getDimensions()
  obj.alpha_through = 0.3

  obj:resize(obj.w, obj.h)

  for k, v in pairs(opts or {}) do
    if obj[k] ~= nil then
      obj[k] = v
    else
      error("Invalid key "..k)
    end
  end

  obj.lights = {}
  obj.pause = nil

  return obj
end

function M:add(...)
  local light = Light.new(...)
  local idx = #self.lights + 1
  self.lights[idx] = light
  light.idx = idx
  return light
end

function M:remove(light)
  if self.lights[light.idx] == light then
    table.remove(self.lights, light.idx)
  end
end

function M:setEnvLight(r, g, b, a)
  self.env_light = { r, g, b, a }
end

function M:begin()
  if self.pause then return end
  self.last_canvas = lg.getCanvas()
  lg.setCanvas(self.object_canvas)
  lg.clear()

  lg.setCanvas(self.light_obj_canvas)
  lg.clear()

  lg.setCanvas(self.light_bg_canvas)
  lg.clear()

  lg.setCanvas(self.scene_canvas)
  lg.clear()
end

function M:track_obj()
  if self.pause then return end
  lg.setCanvas(self.object_canvas)
end

function M:track_bg()
  if self.pause then return end
  lg.setCanvas(self.scene_canvas)
end

function M:track_light_objs()
  if self.pause then return end
  lg.setCanvas(self.light_obj_canvas)
end

function M:track_light_bg()
  if self.pause then return end
  lg.setCanvas(self.light_bg_canvas)
end

function M:finish()
  if self.pause then return end
  lg.setBlendMode('alpha')
  lg.setCanvas(self.object_canvas)
  lg.draw(self.light_obj_canvas)
  lg.setCanvas(self.last_canvas)

  private.reset_light_buffer(self.light_buffer, self)

  local sx, sy
	for i, light in ipairs(self.lights) do
    private.cutLightArea(self.object_canvas, light, self.x, self.y, self.scale)
    private.generateShadowMap(light, self.alpha_through)
    private.generateLight(light, self.scale, self.alpha_through)
    sx = light.x - light.radius
    sy = light.y - light.radius + light.size

    private.drawto(self.light_buffer, nil, function()
      lg.setBlendMode("add")
      lg.scale(self.scale)
      lg.translate(self.x, self.y)
      lg.draw(light.render_canvas, sx, sy, 0, 1, -1)
      lg.setBlendMode("alpha")
    end)
  end

  draw_light_shader:send('bg_tex', self.scene_canvas)
  draw_light_shader:send('light_bg_tex', self.light_bg_canvas)
  draw_light_shader:send('obj_tex', self.object_canvas)
  draw_light_shader:send('light_obj_tex', self.light_obj_canvas)
  draw_light_shader:send('alpha_through', self.alpha_through)
  private.drawto(nil, draw_light_shader, function()
    lg.setBlendMode("alpha", "premultiplied")
    lg.draw(self.light_buffer)
    lg.setBlendMode("alpha", "alphamultiply")
  end)
end

function M:resize(w, h)
  assert(w > 0 and h > 0, "Invalid w or h, cannot <= 0")

  self.w, self.h = w, h
  self.scene_canvas = lg.newCanvas(w, h)
  self.object_canvas = lg.newCanvas(w, h)
  self.light_buffer = lg.newCanvas(w, h)

  self.light_obj_canvas = lg.newCanvas(w, h)
  self.light_bg_canvas = lg.newCanvas(w, h)
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

function private.cutLightArea(canvas, light, ox, oy, scale)
  local sx, sy = (light.x - light.radius + ox) * scale, (light.y - light.radius + oy) * scale
  scale = shadow_map_size / (light.size * scale)

  -- lg.print(''..sx..','..sy..', scale: '..light.scale..' -> '..scale, 10, 10)

  private.drawto(shadow_area_canvas, nil, function()
    lg.clear()
    lg.push()
    lg.scale(scale)
    lg.translate(-sx, -sy)
    lg.draw(canvas)
    lg.pop()
  end)

  -- lg.draw(shadow_area_canvas)
  -- lg.rectangle('line', 0, 0, shadow_area_canvas:getDimensions())
  -- lg.rectangle('line', light.x - light.radius, light.y - light.radius, light.size, light.size)
end

function private.generateShadowMap(light, alpha_through)
  private.drawto(shadow_map_canvas, shadow_map_shader, function()
    lg.clear()
    shadow_map_shader:send("resolution", { light.size, light.size });
    shadow_map_shader:send("alpha_through", alpha_through);
    shadow_map_shader:send("source_radius", light.source_radius / light.radius);
    lg.draw(shadow_area_canvas)
  end)
end

function private.generateLight(light, scale, alpha_through)
  render_light_shader:send('obj_tex', shadow_area_canvas)
  render_light_shader:send("resolution", { light.size, light.size });
  render_light_shader:send("alpha_through", alpha_through);
  render_light_shader:send("source_radius", light.source_radius / light.radius);
  private.drawto(light.render_canvas, render_light_shader, function()
    lg.clear()
    lg.setColor(light.r, light.g, light.b, light.a)
    lg.draw(shadow_map_canvas, 0, 0, 0, 1 / light.scale, light.size)
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

function private.reset_light_buffer(canvas, world)
  lg.setCanvas(canvas)
  lg.clear()

  local r, g, b, a = lg.getColor()
  if world.env_light then
    lg.setColor(unpack(world.env_light))
  end

  if world.env_tex then
    local cw, ch = canvas:getDimensions()
    local tw, th = world.env_tex:getDimensions()
    lg.draw(world.env_tex, 0, 0, 0, cw / tw, ch / th)
  else
    lg.rectangle('fill', 0, 0, canvas:getDimensions())
  end

  lg.setColor(r, g, b, a)
  lg.setCanvas()
end

function private.reset_buffer_canvas()
end

return M
