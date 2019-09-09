local Light = require((...)..'.light')

local path = (...):gsub('%.', '/')
Light.shadow_map_shader = love.graphics.newShader(path..'/shadow_map.glsl')
Light.render_light_shader = love.graphics.newShader(path..'/render_light.glsl')
Light.draw_light_shader = love.graphics.newShader(path..'/draw_light.glsl')

return Light
