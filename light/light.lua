local M = {}
M.__index = M

local lg = love.graphics

local lib_conf

function M.init(sub_libs, conf)
  lib_conf = conf
end

-- opts.source_radius: the source of the light
function M.new(x, y, radius, r, g, b, a, opts)
	local light = setmetatable({
    x = x, y = y,
    radius = radius,
    r = r, g = g, b = b, a = a or 1,
    source_radius = 0
	}, M)

  if opts then
    for k, v in pairs(opts) do light[k] = v end
  end

  local size = radius * 2
  light.size = size
  light.scale = lib_conf.shadow_map_size / size

	light.render_canvas = lg.newCanvas(size, size)

  return light
end

function M:setSize(radius)
  self.radius = radius
  self.size = radius * 2
  self.scale = lib_conf.shadow_map_size / self.size
	self.render_canvas = lg.newCanvas(self.size, self.size)
end

return M
