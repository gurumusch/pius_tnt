local registered_nodes = minetest.registered_nodes
local get_node_or_nil = minetest.get_node_or_nil
local get_node = minetest.get_node
local serialize = minetest.serialize
local deserialize = minetest.deserialize
local add_item = minetest.add_item
local boom = tnt.boom
local quick_flow = tnt.quick_flow
local new = vector.new
local water_nodes = {}

minetest.register_on_mods_loaded(function() 
	for name, def in pairs(minetest.registered_nodes) do
		if def.liquidtype ~= "none" then
			water_nodes[name] = true
		end
	end
end)

minetest.register_entity("tnt_revamped:empty_tnt_entity", {
	name = "empty_tnt_entity",
	timer = 0,
	time = 0,
	def = {},
	drops = {},
	selectionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
	physical = true,
	collide_with_objects = false,
	static_save = false,
	owner = "",
	on_step = function(self, dtime)
		self.time = self.time - dtime
		local object = self.object
		local pos = object:get_pos()
		local v = object:get_velocity()
		local flow = self.flow

		-- water flowing
		if flow then
			local node = get_node_or_nil(pos)
			local def_ = node and registered_nodes[node.name]
			
			if def_ and def_.liquidtype == "flowing" then
				local vec = quick_flow(pos, node)
				object:set_velocity({x = vec.x, y = v.y, z = vec.z})
			else
				self.timer = self.timer + dtime
			end
		else
			self.timer = self.timer + dtime
		end

		if self.timer >= 0.2 then
			local node = get_node({x = pos.x, y = pos.y - 0.667, z = pos.z})
			local node_name = node.name
			local r_node = registered_nodes[node_name]
			if r_node.walkable then
				object:set_velocity({x = 0, y = 0, z = 0})
			elseif not flow and r_node.liquidtype then
				self.flow = true
			end

			self.timer = 0
		end
		
		if self.time <= 0 then
			if water_nodes[get_node(pos).name] then
				boom(pos, self.def, self.owner, true)
			else
				boom(pos, self.def, self.owner, false)
			end
			if self.drops then
				local drops = self.drops
				local drop_pos = new(pos)
				for _, item in pairs(drops) do
					local count = item.count or 1
					local dropitem = ItemStack(item.name)
					dropitem:set_count(count)
					local obj = add_item(drop_pos, dropitem)
					if obj then
						obj:get_luaentity().collect = true
						obj:set_acceleration({x = 0, y = -10, z = 0})
						obj:set_velocity({x = random(-3, 3),
								y = random(0, 10),
								z = random(-3, 3)})
					end
				end
			end
			object:remove()
		end
	end,
	on_blast = function(pos, intensity, blaster)
		return
	end,
	get_staticdata = function(self)
		return serialize({timer = self.timer, time = self.time, flow = self.flow, owner = self.owner, def = self.def, drops = self.drops})
	end,
	on_activate = function(self, staticdata)
		self.object:set_armor_groups({immortal = 1})
		local ds = deserialize(staticdata)
		if ds then
			self.timer = ds.timer
			self.time = ds.time
			self.owner = ds.owner
			self.flow = ds.flow
			self.def = ds.def
			self.drops = ds.drops
		end
	end,
})
