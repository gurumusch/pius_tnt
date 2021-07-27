if not tnt then
	tnt = {}
end

local modpath = minetest.get_modpath("pius_tnt")
local format = string.format

dofile(format("%s/effects.lua", modpath))
dofile(format("%s/waterflow.lua", modpath))
dofile(format("%s/functions.lua", modpath))
dofile(format("%s/entity.lua", modpath))
dofile(format("%s/overrides.lua", modpath))

modpath = nil
format = nil
