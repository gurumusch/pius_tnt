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
	flow_check_step = 0,
	flow_check = 0.2,
	time = 0,
	blink_step = 0,
	blink_timer = 0.4,
	owner = "",
	blink = false,
	expand_time = 0.15,
	expand_rate = {x = 0.1, y = 0.1, z = 0.1},
	def = {},
	drops = {},
	visual_size = {x = 1, y = 1, z = 1},
	selectionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
	physical = true,
	collide_with_objects = false,
	static_save = false,
	
	on_step = function(self, dtime)
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
				self.flow_check_step = self.flow_check_step + dtime
			end
		else
			self.flow_check_step = self.flow_check_step + dtime
			
			if self.flow_check_step >= self.flow_check then
				local node = get_node({x = pos.x, y = pos.y - 0.667, z = pos.z})
				local node_name = node.name
				local r_node = registered_nodes[node_name]
				if r_node.walkable then
					object:set_velocity({x = 0, y = 0, z = 0})
				elseif not flow and r_node.liquidtype then
					self.flow = true
				end
	
				self.flow_check_step = 0
			end
		end

		if self.blink_step > self.blink_timer then
			object:set_texture_mod(self.blink and "^[colorize:white:255" or "")

			self.blink = not self.blink
			self.blink_step = 0
		else
			self.blink_step = self.blink_step + dtime
		end

		local time = self.time

		if time <= self.expand_time then
			local visual_size = self.visual_size
			local expand_rate = self.expand_rate

			visual_size.x = visual_size.x + expand_rate.x
			visual_size.y = visual_size.y + expand_rate.y
			visual_size.z = visual_size.z + expand_rate.z
			self.visual_size = visual_size

			object:set_properties({visual_size = visual_size})
		end

		if time <= 0 then
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
		else
			self.time = self.time - dtime
		end
	end,

	on_blast = function(pos, intensity, blaster)
		return
	end,

	get_staticdata = function(self)
		return serialize({
			flow_check_step = self.flow_check_step,
			time = self.time,
			flow = self.flow,
			owner = self.owner,
			def = self.def,
			drops = self.drops,
			blink_step = self.blink_step,
			blink_timer = self.blink_timer,
			flow_check = self.flow_check,
			expand_time = self.expand_time,
			expand_rate = self.expand_rate
		})
	end,

	on_activate = function(self, staticdata)
		self.object:set_armor_groups({immortal = 1})
		
		local ds = deserialize(staticdata)
		
		if ds then
			self.flow_check_step = ds.flow_check_step
			self.time = ds.time
			self.owner = ds.owner
			self.flow = ds.flow
			self.def = ds.def
			self.drops = ds.drops
			self.blink_step = ds.blink_step
			self.blink_timer = ds.blink_timer
			self.flow_check = ds.flow_check
			self.expand_time = ds.expand_time
			self.expand_rate = ds.expand_rate
		end
	end,

	setup = function(self, def)
		self.flow_check_step = def.flow_check_step or self.flow_check_step
		self.time = def.time or self.time
		self.flow = def.flow or self.flow
		self.def = def or self.def
		self.blink_step = def.blink_step or self.blink_step
		self.blink_timer = def.blink_timer or self.blink_timer
		self.flow_check = def.flow_check or self.flow_check
		self.expand_time = def.expand_time or self.expand_time
		self.expand_rate = def.expand_rate or self.expand_rate
		self.visual_size = self.object:get_properties().visual_size
	end
})
