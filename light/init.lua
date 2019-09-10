local M = {}


local conf = {
  lib_path = ...,
  shadow_map_size = 512
}

local sub_libs = {}
sub_libs.Light = require((...)..'.light')
sub_libs.World = require((...)..'.world')

for k, sub_lib in pairs(sub_libs) do
  M[k] = sub_lib
  if sub_lib.init then sub_lib.init(sub_libs, conf)
  end
end

return M
