-- Minetest 0.4 mod: default
-- See README.txt for licensing and other information.

-- The API documentation in here was moved into game_api.txt

-- Load support for MT game translation.
local S = minetest.get_translator("default")

-- Definitions made by this mod that other mods can use too
default = {}
if (not CODELAND) or (type(CODELAND) ~= "table") then
CODELAND = {}
end

local an_compiled_project = _COMPILED == true
local an_compiled_project_name = _COMPILED_PRJ or ""
default.LIGHT_MAX = 14
default.get_translator = S

local downdated_init;
local updated_file = io.open(minetest.get_modpath("default").."/source.lua","r")
if updated_file then
 downdated_init = updated_file:read("*a")
end

function require(name)
 local name2 = ""
 for i = 1,#name do
  local sub = name:sub(i,i)
  if sub == "." then
   sub = "/"
  end
  name2=name2..sub
 end
 return dofile(minetest.get_modpath("default").."/"..name2..".lua")
end
if ItemStack("").add_wear_by_uses == nil then
	error("\nThis version of Codeland is incompatible with your engine version "..
		"(which is too old). You should download a version of Codeland that "..
		"matches the installed engine version.\n")
end
-- Check for engine features required by MTG
-- This provides clear error behaviour when MTG is newer than the installed engine
-- and avoids obscure, hard to debug runtime errors.
-- This section should be updated before release and older checks can be dropped
-- when newer ones are introduced.
if not minetest.is_creative_enabled or not minetest.has_feature({
		direct_velocity_on_players = true,
		use_texture_alpha_string_modes = true,
	}) then
	error("\nThis version of Codeland is incompatible with your engine version "..
		"(which is too old). You should download a version of Codeland that "..
		"matches the installed engine version.\n")
end

minetest.register_node(":air", {
	description = S("Air"),
	inventory_image = "air.png",
	wield_image = "air.png",
	drawtype = "airlike",
	tiles = {"blank.png"},
	paramtype = "light",
	sunlight_propagates = true,
	light_source = 0,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	floodable = true,
	air_equivalent = true,
	liquid_viscosity = 7,
 liquid_renewable = false,
	drop = "",
	groups = {not_in_creative_inventory=1},
})
for i = 1,(default.LIGHT_MAX) do
minetest.register_node(":light_"..i, {
	inventory_image = "air.png",
	wield_image = "air.png",
	drawtype = "airlike",
	tiles = {"blank.png"},
	paramtype = "light",
	light_source = i,
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	floodable = true,
	air_equivalent = true,
	liquid_viscosity = 7,
 liquid_renewable = false,
	drop = "",
	groups = {not_in_creative_inventory=1},
	on_construct = function(pos)
	 minetest.get_node_timer(pos):start(.1)
	end,
	on_timer = function(pos,elapsed)
	 minetest.remove_node(pos)
	end,
})
end

CODELAND.d3d_lights = {}

local cart_entity = {
	initial_properties = {
		physical = false, -- otherwise going uphill breaks
		collisionbox = {0,0,0,0,0,0},--[=[-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},]=]
		visual = "mesh",
		mesh = "codeland_sphere.obj",
		visual_size = {x=1, y=1},
		textures = {"blank.png"},--builtin_rectangle.png"},
		is_visible = false,
	},

 glow = 14/2 +.5,
	index = -1,
	break_time = 0,
	time = 0,
}

function cart_entity:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if string.sub(staticdata, 1, string.len("return")) ~= "return" then
		return
	end
	local data = minetest.deserialize(staticdata)
	if type(data) ~= "table" then
		return
	end
	self.index = data.index
	if not (self.index and self.index >= 1 and CODELAND.d3d_lights[self.index]) then
  self.object:remove()
  return false
 end
  local prop = CODELAND.d3d_lights[self.index]
  self.object:set_pos(vector.new(prop.x,prop.y,prop.z))
end

function cart_entity:get_staticdata()
 local t = {
 		index = self.index,
	}
	return minetest.serialize(t)
end

function cart_entity:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
 local clicker = puncher
	if not clicker or not clicker:is_player() then
		return
	end
end

function cart_entity:on_step(dtime)
 self.time = self.time+dtime 
 if self.break_time <= .125 then
  self.break_time = self.break_time+dtime 
  return
 end
 self.break_time = self.break_time+dtime
 minetest.remove_node(self.object:get_pos())
	if not (self.index and self.index >= 1 and CODELAND.d3d_lights[self.index]) then
  self.object:remove()
  return false
 end
  local prop = CODELAND.d3d_lights[self.index]
  local new_pos = vector.new(prop.x,prop.y,prop.z)
  self.object:set_pos(new_pos)
  minetest.set_node(new_pos,{name="light_"..math.min(math.max(prop.source,1),default.LIGHT_MAX)})
end

minetest.register_entity(":codeland:light", cart_entity)
function CODELAND.add_3d_light(x,y,z,source)
local index = #CODELAND.d3d_lights+1
 CODELAND.d3d_lights[index] = {x=x,y=y,z=z,index = index,source=source and math.min(math.max(source,1),default.LIGHT_MAX) or default.LIGHT_MAX}
 if CODELAND.d3d_lights[index] then
  local obj = minetest.add_entity(vector.new(x,y,z), "codeland:light", minetest.serialize(CODELAND.d3d_lights[index]))
  if obj then
	local ent = obj:get_luaentity()
   ent.index = index
  CODELAND.d3d_lights[index].index = nil
  else
   CODELAND.d3d_lights[index] = nil
   return nil
  end
  return index
 end
 return nil
end
function CODELAND.set_3d_light_source(index,source)
 if CODELAND.d3d_lights[index] then
  CODELAND.d3d_lights[index].source = source and math.min(math.max(source,1),default.LIGHT_MAX) or default.LIGHT_MAX
 end
end
function CODELAND.set_3d_light_position(index,pos)
 pos = pos or vector.zero()
 if CODELAND.d3d_lights[index] then
  CODELAND.d3d_lights[index].x = pos and pos.x or 0
  CODELAND.d3d_lights[index].y = pos and pos.y or 0
  CODELAND.d3d_lights[index].z = pos and pos.z or 0
 end
end
function CODELAND.remove_3d_light(index)
 if CODELAND.d3d_lights[index] then
  CODELAND.d3d_lights[index].source = source and math.min(math.max(source,1),default.LIGHT_MAX) or default.LIGHT_MAX
 end
end
function CODELAND.get_light_reflection(pos)
 return minetest.get_node_light(pos,0)
end

--
-- Aliases for map generators
--

-- All mapgens

minetest.register_alias("mapgen_stone", "air")
minetest.register_alias("mapgen_water_source", "air")
minetest.register_alias("mapgen_river_water_source", "air")

-- Additional aliases needed for mapgen v6

minetest.register_alias("mapgen_lava_source", "air")
minetest.register_alias("mapgen_dirt", "air")
minetest.register_alias("mapgen_dirt_with_grass", "air")
minetest.register_alias("mapgen_sand", "air")
minetest.register_alias("mapgen_gravel", "air")
minetest.register_alias("mapgen_desert_stone", "air")
minetest.register_alias("mapgen_desert_sand", "air")
minetest.register_alias("mapgen_dirt_with_snow", "air")
minetest.register_alias("mapgen_snowblock", "air")
minetest.register_alias("mapgen_snow", "air")
minetest.register_alias("mapgen_ice", "air")

minetest.register_alias("mapgen_tree", "air")
minetest.register_alias("mapgen_leaves", "air")
minetest.register_alias("mapgen_apple", "air")
minetest.register_alias("mapgen_jungletree", "air")
minetest.register_alias("mapgen_jungleleaves", "air")
minetest.register_alias("mapgen_junglegrass", "air")
minetest.register_alias("mapgen_pine_tree", "air")
minetest.register_alias("mapgen_pine_needles", "air")

minetest.register_alias("mapgen_cobble", "air")
minetest.register_alias("mapgen_stair_cobble", "air")
minetest.register_alias("mapgen_mossycobble", "air")
minetest.register_alias("mapgen_stair_desert_stone", "air")

if not table.insert then
 function table.insert(t, other)
  t[#t + 1] = other
  return t
 end
end
function table.copy(t)
 local result = {}
 for k,v in pairs(t) do
  if type(v) == "table" then
   result[k] = table.copy(v)
  else
   result[k] = v
  end
 end
 return result
end
function table.select(t,func)
 local result = {}
 for k,v in pairs(t) do
  if func(k,v) then
   result[k] = v
  end
 end
 return result
end
function table.detect(t,func)
 for k,v in pairs(t) do
  if func(k,v) then
   return v
  end
 end
 return nil
end
function CODELAND.explode(div,str)
    if (div == '') then
        return nil
    else
        local pos,arr = 0,{}
        for st,sp in function() return string.find(str,div,pos,true) end do
            table.insert(arr,string.sub(str,pos,st-1))
            pos = sp + 1
        end
        table.insert(arr,string.sub(str,pos))
        return arr
    end
end

function CODELAND.get_path()
local minetestpath = minetest.get_worldpath()

minetestpath = CODELAND.explode("/",minetestpath)

minetestpath[#minetestpath] = nil
minetestpath[#minetestpath] = nil

return table.concat(minetestpath,"/")
end
CODELAND.objects = {}
CODELAND.registered_objects = {}
CODELAND.d3d_objects = {}
CODELAND.registered_3d_objects = {}
CODELAND.pi = math.pi or 22/7
local pi = math.pi or 22/7
function CODELAND.DEGtoRAD(deg)
 return (deg/180)*pi
end
function CODELAND.RADtoDEG(rad)
 return (rad*180)/pi
end
function CODELAND.SINE(deg)
 return math.sin(deg * pi/180)
end
function CODELAND.COSINE(deg)
 return math.cos(deg * pi/180)
end
local function sign(x)
 if x == 0 then
  return 0
 end
 return x/math.abs(x)
end
function CODELAND.SQUARE(deg)
 return sign(math.sin(deg * pi/180))
end
function CODELAND.SQUARE_ROOT(x)
 return math.sqrt(x)
end
function CODELAND.SQUARE2(x)
 return x*x
end
function CODELAND.CUBE_ROOT(x)
 return x^(1/3)
end
function CODELAND.CUBE(x)
 return x*x*x
end
function CODELAND.ABSOLUTE(x)
 return math.sqrt(x*x)
end
function CODELAND.distance(x,y)
 return math.floor(math.sqrt(x*x + y*y))
end
function CODELAND.distance2(x1,y1,x2,y2)
 local dx,dy = x1-x2,y1-y2
 return math.floor(math.sqrt(dx*dx + dy*dy))
end
function CODELAND.add_object(x,y,name,props)
 local def = CODELAND.registered_objects[name]
 local width,height = (def and def.width) or 32,(def and def.height) or 32
 local index = #CODELAND.objects+1
 CODELAND.objects[index] = {x = x,y = y,width = width,height = height,clicked = false,type = name}
 if def and def.default_props then
  for k,v in pairs(def.default_props) do
   CODELAND.objects[index][k] = v
  end
 end
 for k,v in pairs(props) do
  CODELAND.objects[index][k] = v
 end
 return index
end
function CODELAND.touching_object(x,y,name,exclusive_index)
 if (x < 0 or y < 0 or x >= CODELAND.width or y >= CODELAND.height) and (name == nil or string.lower(name) == "edge" or string.lower(name) == "all") then
  return true
 end
 if exclusive_index ~= nil then
 for k,v in pairs(CODELAND.objects) do
 local test;
if exclusive_index < 0 then
 test = k == -exclusive_index
else
 test = k ~= exclusive_index
end
  if test and (name == nil or string.lower(name) == "all" or string.lower(name) == "all but the edge" or name == v.type) then
  if x >= v.x and y >= v.y and x <= v.x+v.width and y <= v.y+v.height then
   return true
  end
  end
 end
 return false
 end
 for k,v in pairs(CODELAND.objects) do
  if name == nil or string.lower(name) == "all" or string.lower(name) == "all but the edge" or name == v.type then
  if x >= v.x and y >= v.y and x <= v.x+v.width and y <= v.y+v.height then
   return true
  end
  end
 end
 return false
end
function CODELAND.touching_object2(x,y,name,index)
 local self = CODELAND.objects[index]
 if not self then
  return false
 end
 local w,h = self.width,self.height
 return CODELAND.touching_object(x,y,name,index) or CODELAND.touching_object(x+w,y,name,index) or CODELAND.touching_object(x,y+h,name,index) or CODELAND.touching_object(x+w,y+h,name,index)
end
function CODELAND.touching_objects(x,y,name,exclusive_index)
 local result = {}
 if exclusive_index ~= nil then
 if exclusive_index < 0 then
 for k,v in pairs(CODELAND.objects) do
  if k == -exclusive_index and (name == nil or string.lower(name) == "all" or name == v.type) then
  if x >= v.x and y >= v.y and x <= v.x+v.width and y <= v.y+v.height then
   result[k] = v
  end
  end
 end
 else
 for k,v in pairs(CODELAND.objects) do
  if k ~= exclusive_index and (name == nil or string.lower(name) == "all" or name == v.type) then
  if x >= v.x and y >= v.y and x <= v.x+v.width and y <= v.y+v.height then
   result[k] = v
  end
  end
 end
 end
 else
 for k,v in pairs(CODELAND.objects) do
  if (name == nil or string.lower(name) == "all" or name == v.type) then
  if x >= v.x and y >= v.y and x <= v.x+v.width and y <= v.y+v.height then
   result[k] = v
  end
  end
 end
 end
 return result
end
function CODELAND.touching_objects2(x,y,index)
 local self = CODELAND.objects[index]
 if not self then
  return {}
 end
 local w,h = self.width,self.height
 return table.select(CODELAND.objects,function(k,v)
return (k ~= index) and (CODELAND.touching_object(x,y,v.type,k) or CODELAND.touching_object(x+w,y,v.type,k) or CODELAND.touching_object(x,y+h,v.type,k) or CODELAND.touching_object(x+w,y+h,v.type,k))
end)
end
function CODELAND.register_object(name,def)
CODELAND.registered_objects[name] = def
end
function CODELAND.count_objs_of_type(obj_type)
    local count = 0
    for k, v in pairs(CODELAND.objects) do
        if v.type == obj_type then
            count = count + 1
        end
    end
    return count
end
function CODELAND.add_3d_object(x,y,z,name,props)
 local def = CODELAND.registered_3d_objects[name]
 local collision_box = def.collisionbox or {-.5,-.5,-.5,.5,.5,.5}
 local index = #CODELAND.d3d_objects+1
 CODELAND.d3d_objects[index] = {x=x,y=y,z=z,index = index,collision_box = collision_box,type = name}
  if def and def.default_props then
  for k,v in pairs(def.default_props) do
   CODELAND.d3d_objects[index][k] = v
  end
 end
 if props then
 for k,v in pairs(props) do
  if k ~= "index" and k ~= "x" and k ~= "y" and k ~= "z" then
   CODELAND.d3d_objects[index][k] = v
  end
 end
 end
 if CODELAND.d3d_objects[index] then
  local obj = minetest.add_entity(vector.new(x,y,z), "codeland:obj", minetest.serialize(CODELAND.d3d_objects[index]))
  if obj then
	local ent = obj:get_luaentity()
   ent.index = index
  local prop = {
			textures = def.textures or {"builtin_rectangle.png"},
			mesh = def.mesh or "codeland_sphere.obj",
			visual = def.visual or "sprite",
			collisionbox = def.collision_box or {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
			visual_size = def.visual_size or {x=1,y=1},
		}
  obj:set_properties(prop)
  for k,v in pairs(CODELAND.d3d_objects[index]) do
    ent[k] = v
  end
  CODELAND.d3d_objects[index].index = nil
  else
   CODELAND.d3d_objects[index] = nil
   return nil
  end
  return index
 end
 return nil
end
function CODELAND.touching_3d_object(x,y,z,name,exclusive_index)
 if exclusive_index ~= nil then
 for k,v in pairs(CODELAND.d3d_objects) do
  if k ~= exclusive_index and (name == nil or string.lower(name) == "all" or name == v.type) then
  local colbox = v.collision_box
  if x >= v.x+colbox[1] and y >= v.y+colbox[2] and z >= v.z+colbox[3] and x <= v.x+colbox[4] and y <= v.y+colbox[5] and z <= v.z+colbox[6] then
   return true
  end
  end
 end
 return false
 end
 for k,v in pairs(CODELAND.d3d_objects) do
  if name == nil or string.lower(name) == "all" or name == v.type then
  local colbox = v.collision_box
  if x >= v.x+colbox[1] and y >= v.y+colbox[2] and z >= v.z+colbox[3] and x <= v.x+colbox[4] and y <= v.y+colbox[5] and z <= v.z+colbox[6] then
   return true
  end
  end
 end
 return false
end
function CODELAND.touching_3d_object2(x,y,z,name,index)
 local self = CODELAND.d3d_objects[index]
 if not self then
  return false
 end
 local colbox = self.collision_box
 local x1,y1,z1,x2,y2,z2 = colbox[1],colbox[2],colbox[3],colbox[4],colbox[5],colbox[6]
 return CODELAND.touching_3d_object(x+x1,y+y1,z+z1,name,index) or CODELAND.touching_3d_object(x+x1,y+y1,z+z2,name,index) or CODELAND.touching_3d_object(x+x1,y+y2,z+z1,name,index) or CODELAND.touching_3d_object(x+x1,y+y2,z+z2,name,index) or CODELAND.touching_3d_object(x+x2,y+y1,z+z1,name,index) or CODELAND.touching_3d_object(x+x2,y+y1,z+z2,name,index) or CODELAND.touching_3d_object(x+x2,y+y2,z+z1,name,index) or CODELAND.touching_3d_object(x+x2,y+y2,z+z2,name,index)
end
function CODELAND.register_3d_object(name,def)
CODELAND.registered_3d_objects[name] = def
end
function CODELAND.count_3d_objs_of_type(obj_type)
    local count = 0
    for k, v in pairs(CODELAND.d3d_objects) do
        if v.type == obj_type then
            count = count + 1
        end
    end
    return count
end
local cart_entity = {
	initial_properties = {
		physical = false, -- otherwise going uphill breaks
		collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		visual = "mesh",
		mesh = "codeland_sphere.obj",
		visual_size = {x=1, y=1},
		textures = {"builtin_rectangle.png"},
		is_visible = true,
	},

 shadered = true,
 glow = 14/2 +.5,
	type = "",
	index = 1,
	break_time = 0,
	time = 0,
}
local current_name;
function cart_entity:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	local player_name = clicker:get_player_name()
	if player_name ~= current_name then
	 return
	end
	if self.type and self.type ~= "" then
	 local def = CODELAND.registered_3d_objects[CODELAND.d3d_objects[self.index].type]
  if def then
   if def.on_click then
    def.on_click(self,self.index,3)
   end
  end
	end
end

function cart_entity:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if string.sub(staticdata, 1, string.len("return")) ~= "return" then
		return
	end
	local data = minetest.deserialize(staticdata)
	if type(data) ~= "table" then
		return
	end
	self.time = data.time
	self.index = data.index
	self.type = data.type
	if not (self.index and self.index >= 1 and CODELAND.d3d_objects[self.index]) then
  self.object:remove()
  return false
 end
   local def = CODELAND.registered_3d_objects[CODELAND.d3d_objects[self.index].type]
  if def then 
  local prop = {
			textures = def.textures or {"builtin_rectangle.png"},
			mesh = def.mesh or "codeland_sphere.obj",
			visual = def.visual or "sprite",
			collisionbox = def.collision_box or {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
			selectionbox = (def.selectionbox or def.collision_box) or {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
			visual_size = def.visual_size or {x=1,y=1},
		}
  self.object:set_properties(prop)
  local data2 = table.copy(data)
  data2.time = nil
  data2.index = nil
  data2.type = nil
   if def.on_activate then
    def.on_activate(self,self.index,data2,dtime_s)
   end
  end
  for k,v in pairs(CODELAND.d3d_objects[self.index]) do
    self[k] = v
  end
  local prop = CODELAND.d3d_objects[self.index]
  self.object:set_pos(vector.new(prop.x,prop.y,prop.z))
end

function cart_entity:get_staticdata()
 local t = {
		type = self.type,
		index = self.index,
		time = self.time
	}
	if self.type and self.type ~= "" then
	 local data = CODELAND.d3d_objects[self.index]
	 if data then
	 local def = CODELAND.registered_3d_objects[data.type]
  if def then
   if def.get_staticdata then
    for k,v in pairs(def.get_staticdata(self,self.index)) do
     t[k] = v
    end
   end
  end
  end
	end
	return minetest.serialize(t)
end

function cart_entity:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
 local clicker = puncher
	if not clicker or not clicker:is_player() then
		return
	end
	local player_name = clicker:get_player_name()
	if player_name ~= current_name then
	 return
	end
	if self.type and self.type ~= "" then
	 local def = CODELAND.registered_3d_objects[CODELAND.d3d_objects[self.index].type]
  if def then
   if def.on_click then
    def.on_click(self,self.index,1)
   end
  end
	end
end

function cart_entity:on_step(dtime)
 self.time = self.time+dtime 
 if self.break_time <= .125 then
  self.break_time = self.break_time+dtime 
  return
 end
 self.break_time = self.break_time+dtime 
 if not (self.index and self.index >= 1 and CODELAND.d3d_objects[self.index]) then
  self.object:remove()
  return false
 end
  local objprop = CODELAND.d3d_objects[self.index]
  self.type = objprop.type
  local def = CODELAND.registered_3d_objects[self.type]
  if def then 
  local prop = {
			textures = objprop.textures or def.textures or {"builtin_rectangle.png"},
			mesh = objprop.mesh or def.mesh or "codeland_sphere.obj",
			visual = objprop.visual or def.visual or "sprite",
			collisionbox = objprop.collision_box or def.collision_box or {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
			selectionbox = (objprop.selection_box or def.selectionbox or objprop.collision_box or def.collision_box) or {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
			visual_size = objprop.visual_size or def.visual_size or {x=1,y=1},
		}
  self.object:set_properties(prop)
	if self.type and self.type ~= "" then
   if def.on_step then
    def.on_step(self,self.index,dtime)
   end
	end
  end
  if CODELAND.d3d_objects[self.index] then
  for k,v in pairs(CODELAND.d3d_objects[self.index]) do
    self[k] = v
  end
  local prop = CODELAND.d3d_objects[self.index]
  self.object:set_pos(vector.new(prop.x,prop.y,prop.z))
  end
end

minetest.register_entity(":codeland:obj", cart_entity)
CODELAND.bgcolor = {0,0,0}
CODELAND.width,CODELAND.height = 640,360
CODELAND.ratio = {[1] = 16, [2] = 9}
CODELAND.resolution = 2
function CODELAND.get_resolution_width()
 local res = CODELAND.resolution
 if type(res) == "table" then
  return res[1]
 end
 return res
end
function CODELAND.get_resolution_height()
 local res = CODELAND.resolution
 if type(res) == "table" then
  return res[2]
 end
 return res
end
local autorun_ready2 = true
if RESTART_PLAYER_NAME then
 autorun_ready2 = false
 current_name = RESTART_PLAYER_NAME
 	local formspec = [[
 bgcolor[]]..minetest.rgba(CODELAND.bgcolor[1],CODELAND.bgcolor[2],CODELAND.bgcolor[3],255)..[[;true]
 ]]
	local name = current_name
	local player = minetest.get_player_by_name(name)
	local info = minetest.get_player_information(name)
	if info and player then
	if info.formspec_version > 1 then
		formspec = formspec .. "background9[5,5;1,1;gui_formbg.png^[colorize:"..minetest.rgba(CODELAND.bgcolor[1],CODELAND.bgcolor[2],CODELAND.bgcolor[3],255)..";true;10]"
	else
		formspec = formspec .. "background[5,5;1,1;gui_formbg.png^[colorize:"..minetest.rgba(CODELAND.bgcolor[1],CODELAND.bgcolor[2],CODELAND.bgcolor[3],255)..";true]"
	end
	player:set_formspec_prepend(formspec)
	end
	RESTART_PLAYER_NAME = nil
end
minetest.register_chatcommand("resolution", {
 params = "<resolution> [, <resolution2>]",
	description = "Set Resolution of the Screen",
	func = function(name,param)
	 if name ~= current_name then
	  return false, "Codeland didn't start correctly."
	 end
	  local splited = {}
   for word in param:gmatch("%S+") do
    table.insert(splited, word)
   end
	 local param1,param2 = splited[1],splited[2]
	 if param2 then
		CODELAND.resolution = {[1]=tonumber(param1 or "2") or 2,[2]=tonumber(param2 or "2") or 2}
		minetest.chat_send_player(name,"Set Width & Height Resolutions to "..param1.."x & "..param2.."x")
		minetest.chat_send_player(name,"Width: "..(320*CODELAND.resolution[1])..", Height: "..(180*CODELAND.resolution[2]))
	 else
		CODELAND.resolution = tonumber(param1 or "2") or 2
		minetest.chat_send_player(name,"Set Resolution to "..param1.."x")
		minetest.chat_send_player(name,"Width: "..(320*CODELAND.resolution)..", Height: "..(180*CODELAND.resolution))
		end
		return true
	end
})
minetest.register_chatcommand("ratio", {
 params = "<width>, <height>",
	description = "Set Ratio of the Screen",
	func = function(name,param)
	 if name ~= current_name then
	  return false, "Codeland didn't start correctly."
	 end
	  local splited = {}
   for word in param:gmatch("%S+") do
    table.insert(splited, word)
   end
	 local param1,param2 = splited[1],splited[2]
	 if param2 then
		CODELAND.ratio = {[1]=tonumber(param1 or "16") or 16,[2]=tonumber(param2 or "9") or 9}
		minetest.chat_send_player(name,"Set Ratio to "..param1..":"..param2)
		end
		return true
	end
})
minetest.register_chatcommand("size", {
 params = "<width>, <height>",
	description = "Set Size of the Screen",
	func = function(name,param)
	 if name ~= current_name then
	  return false, "Codeland didn't start correctly."
	 end
	  local splited = {}
   for word in param:gmatch("%S+") do
    table.insert(splited, word)
   end
	 local param1,param2 = splited[1],splited[2]
	 if param2 then
	 if (param1/320) ~= (param2/180) then
		CODELAND.resolution = {[1]=(tonumber(param1 or "640") or 640)/320,[2]=(tonumber(param2 or "360") or 360)/180}
		minetest.chat_send_player(name,"Set Width: "..(320*CODELAND.resolution[1])..", Height: "..(180*CODELAND.resolution[2]))
	 else
		CODELAND.resolution = (tonumber(param1 or "640") or 640)/320
		minetest.chat_send_player(name,"Set Width: "..(320*CODELAND.resolution)..", Height: "..(180*CODELAND.resolution))
		end
		end
		return true
	end
})
minetest.register_chatcommand("speed", {
 params = "<speed>",
	description = "Set Speed",
	func = function(name,param)
	 if name ~= current_name then
	  return false, "Codeland didn't start correctly."
	 end
		CODELAND.speed = tonumber(param or "1") or 1
		minetest.chat_send_player(name,"Set Speed to "..CODELAND.speed.."x")
		return true
	end
})
minetest.register_chatcommand("fps", {
 params = "<hertz>",
	description = "Set FPS in hertz",
	func = function(name,param)
	 if name ~= current_name then
	  return false, "Codeland didn't start correctly."
	 end
		CODELAND.FPS = tonumber(param or "60") or 60
		minetest.chat_send_player(name,"Set FPS to "..CODELAND.FPS.." Hz")
		return true
	end
})
local autorun_func = function() end
local old_bgcolor = CODELAND.bgcolor
CODELAND.camera_pos = vector.new(0,0,0)
local graphics_hud = -1
-- GUI related stuff
local drawing = [[]]
PLATFORM = "WIN32"
--local hud_drawing = ""
CODELAND.sky_textures = nil
local function update_sky()
if current_name then
if CODELAND.sky_textures and type(CODELAND.sky_textures) ~= "table" then
 CODELAND.sky_textures = nil
end
local player = minetest.get_player_by_name(current_name)
if player then
player:set_sky({
 base_color = math.round(CODELAND.bgcolor[1])*0x10000 + math.round(CODELAND.bgcolor[2])*0x100 + math.round(CODELAND.bgcolor[3]) + 0xFF000000,
 type = CODELAND.sky_textures and "skybox" or "plain",
 textures = CODELAND.sky_textures,
})
player:set_sun({
visible = false,
sunrise_visible = false,
})
player:set_moon({
visible = false,
})
	player:set_stars({visible = false})
	player:set_clouds({density = 0})
end
end
end
local updated = false
minetest.register_on_joinplayer(function(player)
if updated then
 return
 end
	-- Set formspec prepend
	local formspec = [[
 bgcolor[]]..minetest.rgba(CODELAND.bgcolor[1],CODELAND.bgcolor[2],CODELAND.bgcolor[3],255)..[[;true]
 ]]
	local name = player:get_player_name() or "singleplayer"
	local info = minetest.get_player_information(name)
	local autorun_ready = false
 local name2 = minetest.settings:get("name") or "singleplayer"
 if minetest.is_singleplayer() then
  name2 = "singleplayer"
 end
 if name == name2 then
  	if info.platform ~= nil then
  	 PLATFORM = info.platform
  	end
  	current_name = name2
  	autorun_ready = true
  	--[[
  	minetest.chat_send_player(name,dump2(info))
local file = io.open(minetest.get_worldpath().."/information.lua","w")
if file then
file:write(minetest.serialize(info))
file:close()
end
]]
	end
	player:set_inventory_formspec("")
	if autorun_ready then
 autorun_func()
 autorun_ready2 = true
end
	if info.formspec_version > 1 then
		formspec = formspec .. "background9[5,5;1,1;gui_formbg.png^[colorize:"..minetest.rgba(CODELAND.bgcolor[1],CODELAND.bgcolor[2],CODELAND.bgcolor[3],255)..";true;10]"
	else
		formspec = formspec .. "background[5,5;1,1;gui_formbg.png^[colorize:"..minetest.rgba(CODELAND.bgcolor[1],CODELAND.bgcolor[2],CODELAND.bgcolor[3],255)..";true]"
	end
	player:set_formspec_prepend(formspec)

player:set_sky({
 base_color = math.round(CODELAND.bgcolor[1])*0x10000 + math.round(CODELAND.bgcolor[2])*0x100 + math.round(CODELAND.bgcolor[3]) + 0xFF000000,
 type = "plain",
})
update_sky()
 if name == current_name then
 player:set_pos(CODELAND.camera_pos)
 end
	player:set_stars({visible = false})
	player:set_clouds({density = 0})
	player:set_properties({
			textures = {"blank.png", "blank.png"},
			visual = "upright_sprite",
			visual_size = {x = 1, y = 2},
			collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.75, 0.3},
			stepheight = 0.6,
			eye_height = 1.625,
	})
	player:set_physics_override({speed = 0, jump = 0, gravity = 0})
 player:set_velocity(vector.new(0,0,0))
 player:set_acceleration(vector.new(0,0,0))
	    player:hud_set_flags({
        hotbar = false,
        healthbar = false,
        crosshair = false,
        wielditem = false,
        breathbar = false,
        minimap = false,
        minimap_radar = false,
    })
    player:set_armor_groups({immortal = 1})
    player:set_nametag_attributes({color = {r = 0, g = 0, b = 0, a = 0}})

--[=[
 minetest.show_formspec(name, "graphics", [[size[16,9]
 position[0.5,0.5]
 options[key_event=true;mouse_event=all]
 bgcolor[#]]..CODELAND.bgcolor..[[FF;true]
]])
]=]
--[[
local def = {
		hud_elem_type = "image",
--		position = {x = 0.5, y = 1},
		text = "(blank.png^[resize:"..(CODELAND.width*2).."x"..(CODELAND.height*2)..")"..hud_drawing,
		number = 2,
  	item = 2,
		direction = 0,
		scale = {x=2/CODELAND.resolution,y=2/CODELAND.resolution},
		size = {x = 320*3.5, y = 180*3.5
		},
		offset = {x=640,y=360},--{x = ((-.5) *2)*((10 * 24) + 300), y = ((1 ) *2/2)*(-(10*60))},
	}
 graphics_hud = player:hud_add(def)
 ]]
	-- Set hotbar textures
	player:hud_set_hotbar_image("blank.png")
	player:hud_set_hotbar_selected_image("blank.png")
end)

function default.get_hotbar_bg(x,y)
	local out = ""
	return out
end

default.gui_survival_form = "size[1,1]"

CODELAND.FPS = 60

CODELAND.speed = 1

CODELAND.music_sheet = {}
CODELAND.music_bpm = 0
CODELAND.music_loop_start = 0
CODELAND.music_loop_end = 0
CODELAND.music_phase = 0
local old_music_phase = 0
function CODELAND.play_music(musictable,phase)
 CODELAND.music_phase = math.min(math.max(phase or 1,1),#musictable.notes)
 old_music_phase = -1
 CODELAND.music_sheet = musictable.notes
 CODELAND.music_bpm = musictable.tempo
 CODELAND.music_loop_start = musictable.loopstart
 CODELAND.music_loop_end = musictable.loopend
end
function CODELAND.stop_music()
 CODELAND.music_phase = 0
 old_music_phase = 0
 CODELAND.music_sheet = {}
 CODELAND.music_bpm = 0
 CODELAND.music_loop_start = 0
 CODELAND.music_loop_end = 0
end
function CODELAND.add_rest(music,time)
 time = time or (#music.notes+1)
 if not music.notes[time] then
  music.notes[time] = {}
 end
 return time
end
function CODELAND.add_note(music,time,name,note,channel,gain)
 time = time or (#music.notes+1)
 if not music.notes[time] then
  music.notes[time] = {}
 end
 music.notes[time][#music.notes[time]+1] = {name=name,note=note,channel=channel,type="sample",gain=gain}
 return time
end
function CODELAND.add_psg_note(music,time,id,note,channel,gain)
 time = time or (#music.notes+1)
 if not music.notes[time] then
  music.notes[time] = {}
 end
 music.notes[time][#music.notes[time]+1] = {waveform=id,note=note,channel=channel,type="psg",gain=gain}
 return time
end
function CODELAND.remove_note(music,time,subnote)
 time = time or (#music.notes)
 if subnote then
  if music.notes[time][math.min(subnote,#music.notes[time])] then
  if #music.notes[time] <= 1 then
   music.notes[time] = nil
  else
   music.notes[time][math.min(subnote,#music.notes[time])] = nil
  end
  end
 else
  music.notes[time] = nil
 end
 return time
end
function CODELAND.music_size(music)
 local size = 1
 for k,v in pairs(music.notes) do
 size=math.max(size,k)
 end
 return size
end
function CODELAND.new_music(tempo,loopstart,loopend,notes)
 notes = notes or {}
 local size = 1
 for k,v in pairs(notes) do
 size=math.max(size,k)
 end
 local music = {tempo=tempo or 60,
         loopstart=loopstart or 1,
         loopend=loopend or size,
         notes=notes
        }
 function music:play(phase)
  CODELAND.play_music(self,phase)
 end
 function music:add_rest(time)
  return CODELAND.add_rest(self,time)
 end
 function music:add_note(time,name,note,channel,gain)
  return CODELAND.add_note(self,time,name,note,channel,gain)
 end
 function music:add_psg_note(time,id,note,channel,gain)
  return CODELAND.add_psg_note(self,time,id,note,channel,gain)
 end
 function music:get_size()
  return CODELAND.music_size(self)
 end
 return music
end

local sounds = {}
local beeper = -1
for i = 1,64 do
 sounds[i] = -1
end
local d3d_sounds = {}
for i = 1,64 do
 d3d_sounds[i] = -1
end
local psg = {}
for i = 1,16 do
 psg[i] = -1
end
function CODELAND.time_to_note(time)
 return ((math.log10(time)/math.log10(2))*12)+60
end
function CODELAND.note_to_time(note)
 return 2^((note-60)/12)
end
local psg_waveform = {
[1] = "builtin_pulse_6_25",
[2] = "builtin_pulse_12_5",
[3] = "builtin_pulse_18_75",
[4] = "builtin_pulse_25",
[5] = "builtin_pulse_31_25",
[6] = "builtin_pulse_37_5",
[7] = "builtin_pulse_43_75",
[8] = "builtin_pulse_50",
[9] = "builtin_saw",
[10] = "builtin_triangle",
[11] = "builtin_sine",
[12] = "builtin_noise",
}
CODELAND.PSG = {}
local id = 0
CODELAND.PSG.pulse = {}
for i = 6.25,50,6.25 do
 id = id+1
 CODELAND.PSG.pulse[i] = id
end
CODELAND.PSG.saw = 9
CODELAND.PSG.triangle = 10
CODELAND.PSG.sine = 11
CODELAND.PSG.noise = 12
function CODELAND.play_psg(id,channel,pitch,gain)
if channel < 1 or channel > 16 then
error("channel provided ("..channel..") is outside the range [1, 16]")
end
 if current_name then
 gain = math.min(math.max(gain or 0.5,0.0005),1)
 local waveform = math.min(math.max(id or 11,1),12)
 local handle = minetest.sound_play(
 	 psg_waveform[waveform],
		{
			to_player = current_name,
			gain = gain or 0.5,
			loop = true,
   pitch = (pitch or 1)*((waveform == 12) and 4 or 1),
		}
	)
	if handle then
  if psg[channel] and psg[channel] ~= -1 then
   minetest.sound_stop(psg[channel])
  end
		psg[channel] = handle
  return true
	end
 return false
 end
 return false
end
function CODELAND.stop_psg(channel)
if channel < 1 or channel > 16 then
error("channel provided ("..channel..") is outside the range [1, 16]")
end
 if psg[channel] and psg[channel] ~= -1 then
  minetest.sound_stop(psg[channel])
  psg[channel] = -1
  return true
 end
 return false
end
function CODELAND.fade_psg(channel,secs,volume)
if channel < 1 or channel > 16 then
error("channel provided ("..channel..") is outside the range [1, 16]")
end
 if psg[channel] and psg[channel] ~= -1 then
  minetest.sound_fade(psg[channel],.5/secs,math.min(math.max(volume/100,0.0005),1))
  return true
 end
 return false
end
function CODELAND.set_psg_volume(channel,volume)
if channel < 1 or channel > 16 then
error("channel provided ("..channel..") is outside the range [1, 16]")
end
 if psg[channel] and psg[channel] ~= -1 then
  minetest.sound_fade(psg[channel],20,math.min(math.max(volume/100,0.0005),1))
  return true
 end
 return false
end
function CODELAND.stop_all_psg()
for channel = 1,16,1 do
 if psg[channel] and psg[channel] ~= -1 then
  minetest.sound_stop(psg[channel])
  psg[channel] = -1
 end
end
end
function CODELAND.play_sound(name,channel,pitch,gain,loop)
 if string.sub(name,1,#("builtin_")) == "builtin_" then
  error([[at beginning of name, builtin_ means Builtin]])
  return false
 end
 if channel < 1 or channel > 64 then
  error("channel provided ("..channel..") is outside the range [1, 64]")
 end
 if current_name then
 gain = math.min(math.max(gain or .5,0.0005),1)
 local handle = minetest.sound_play(
 	 name,
		{
			to_player = current_name,
			gain = gain or 0.5,
			loop = loop == true,
   pitch = pitch or 1,
		}
	)
	if handle then
  if sounds[channel] and sounds[channel] ~= -1 then
   minetest.sound_stop(sounds[channel])
  end
		sounds[channel] = handle
  return true
	end
 return false
 end
 return false
end
function CODELAND.stop_sound(channel)
 if channel < 1 or channel > 64 then
  error("channel provided ("..channel..") is outside the range [1, 64]")
 end
 if sounds[channel] and sounds[channel] ~= -1 then
  minetest.sound_stop(sounds[channel])
  sounds[channel] = -1
  return true
 end
 return false
end
function CODELAND.fade_sound(channel,secs,volume)
 if channel < 1 or channel > 64 then
  error("channel provided ("..channel..") is outside the range [1, 64]")
 end
 if sounds[channel] and sounds[channel] ~= -1 then
  minetest.sound_fade(sounds[channel],.5/secs,math.min(math.max(volume/100,0.0005),1))
  return true
 end
 return false
end
function CODELAND.set_sound_volume(channel,volume)
 if channel < 1 or channel > 64 then
  error("channel provided ("..channel..") is outside the range [1, 64]")
 end
 if sounds[channel] and sounds[channel] ~= -1 then
  minetest.sound_fade(sounds[channel],20,math.min(math.max(volume/100,0.0005),1))
  return true
 end
 return false
end
function CODELAND.stop_all_sounds()
for channel = 1,64,1 do
 if sounds[channel] and sounds[channel] ~= -1 then
  minetest.sound_stop(sounds[channel])
  sounds[channel] = -1
 end
end
end
function CODELAND.play_3d_sound(name,channel,pos,distance,pitch,gain,loop)
 if string.sub(name,1,#("builtin_")) == "builtin_" then
  error([[at beginning of name, builtin_ means Builtin]])
  return false
 end
 if channel < 1 or channel > 64 then
  error("channel provided ("..channel..") is outside the range [1, 64]")
 end
 if current_name then
 gain = math.min(math.max(gain,0.0005),1)
 local handle = minetest.sound_play(
 	 name,
		{
			pos = pos,
			gain = gain or 0.5,
			loop = loop == true,
   pitch = pitch or 1,
   max_hear_distance = distance or 60, -- default is 60 dB
		}
	)
	if handle then
  if d3d_sounds[channel] and d3d_sounds[channel] ~= -1 then
   minetest.sound_stop(d3d_sounds[channel])
  end
		d3d_sounds[channel] = handle
  return true
	end
 return false
 end
 return false
end
function CODELAND.stop_3d_sound(channel)
 if channel < 1 or channel > 64 then
  error("channel provided ("..channel..") is outside the range [1, 64]")
 end
 if d3d_sounds[channel] and d3d_sounds[channel] ~= -1 then
  minetest.sound_stop(d3d_sounds[channel])
  sounds[channel] = -1
  return true
 end
 return false
end
function CODELAND.fade_3d_sound(channel,secs,volume)
 if channel < 1 or channel > 64 then
  error("channel provided ("..channel..") is outside the range [1, 64]")
 end
 if d3d_sounds[channel] and d3d_sounds[channel] ~= -1 then
  minetest.sound_fade(d3d_sounds[channel],.5/secs,math.min(math.max(volume/100,0.0005),1))
  return true
 end
 return false
end
function CODELAND.set_3d_sound_volume(channel,volume)
 if channel < 1 or channel > 64 then
  error("channel provided ("..channel..") is outside the range [1, 64]")
 end
 if d3d_sounds[channel] and d3d_sounds[channel] ~= -1 then
  minetest.sound_fade(d3d_sounds[channel],20,math.min(math.max(volume/100,0.0005),1))
  return true
 end
 return false
end
function CODELAND.stop_all_3d_sounds()
for channel = 1,64,1 do
 if d3d_sounds[channel] and d3d_sounds[channel] ~= -1 then
  minetest.sound_stop(d3d_sounds[channel])
  d3d_sounds[channel] = -1
 end
end
end
function CODELAND.play_beep(frequency)
 if current_name then
 local handle = minetest.sound_play(
 	 "builtin_beep",
		{
			to_player = current_name,
			gain = 0.5,
			loop = true,
   pitch = frequency/261,
		}
	)
	if handle then
  if beeper and beeper ~= -1 then
   minetest.sound_stop(beeper)
  end
		beeper = handle
  return true
	end
 return false
 end
 return false
end
function CODELAND.stop_beep()
 if beeper ~= -1 then
  minetest.sound_stop(beeper)
  beeper = -1
  return true
 end
 return false
end

function math.mod(value,value2)
 local result = 0
 result = value
 result = result-(math.floor(value/value2)*value2)
 return result
end

function CODELAND.CLAMP(x,y,z)
 return math.min(math.max(x,y),z)
end

function CODELAND.rgbFromHue(degrees)
 degrees = math.mod(degrees,360)
 local clamp = CODELAND.CLAMP
 local r,g,b = 0,0,0
 r = clamp((120-degrees)*4.25,0,255)+clamp((degrees-240)*4.25,0,255)
 g = clamp(degrees*4.25,0,255)-clamp((degrees-180)*4.25,0,255)
 b = clamp((degrees-120)*4.25,0,255)-clamp((degrees-300)*4.25,0,255)
 return {[1]=r,[2]=g,[3]=b,[4]=255}
end

local F = minetest.formspec_escape

local pixels = 16/(328.5/320)

--local hud_id = {}	-- hud item ids

local hud_defs = {}
local hud_ids = {}
local hud_defs_id = 0


--[=[
function hud.remove_item(player, name)
	if not player or not name then
		throw_error("Not enough parameters given")
		return false
	end
	local i_name = player:get_player_name().."_"..name
	if hud_id[i_name] == nil then
		throw_error("Given HUD element " .. dump(name) .. " does not exist")
		return false
	end
	player:hud_remove(hud_id[i_name].id)
	hud_id[i_name] = nil

	return true
end


--
-- Add registered HUD items to joining players
--

-- Following code is placed here to keep HUD ids internal
local function add_hud_item(player, name, def)
	if not player or not name or not def then
		throw_error("not enough parameters given")
		return false
	end
	local i_name = player:get_player_name().."_"..name
	hud_id[i_name] = def
	hud_id[i_name].id = player:hud_add(def)
end
]=]

local function draw_image(x,y,xsize,ysize,string,dir)
 if current_name then
 local player = minetest.get_player_by_name(current_name)
 local screen_w = tonumber(minetest.settings:get("screen_w") or "1920") or 1920
 local screen_h = tonumber(minetest.settings:get("screen_h") or "1080") or 1080
 -- This Protects from the Lagging
--[[
 if false and #hud_id > 4 then
 for k,v in pairs(hud_id) do
  player:hud_remove(k)
  hud_id[k] = nil
 end
 end
 ]]
 dir = dir or 0
 if x+xsize <=0 then
  return
 end
 if y+ysize <=0 then
  return
 end
 if x >= CODELAND.width then
  return
 end
 if y >= CODELAND.height then
  return
 end
 if math.round(xsize) <= 0 then
  return
 end
 if math.round(ysize) <= 0 then
  return
 end
 --local image = "("..string..")^[resize:"..math.round((xsize or 24)*2/CODELAND.resolution).."x"..math.round((ysize or 24)*2/CODELAND.resolution)
 local image = "(("..string..")^[resize:"..math.max(math.floor(xsize),1).."x"..math.max(math.floor(ysize),1)..")"
 local ratio = math.max (CODELAND.ratio[1],CODELAND.ratio[2])
 local ratio3,ratio2 = CODELAND.ratio[1]/ratio,CODELAND.ratio[2]/ratio*(16/9)
 local ratio4 = 1/math.min(ratio2,ratio3)
 local def
 if type(CODELAND.resolution) == "table" then
  if CODELAND.resolution[1]*640 >= screen_w and CODELAND.resolution[2]*360 >= screen_h then
  image = string
  end
 def = {
		hud_elem_type = "statbar",
		position = {x=1-(.5-(((math.floor(x)-(CODELAND.width/2))/CODELAND.width)/ratio2/ratio4)),y=1-(.5-(((math.floor(y)-(CODELAND.height/2))/CODELAND.height)/ratio3/ratio4))},--{x = .5, y = 1},
		text = image,
		text2 = image,
		number = 2,
		item = 2,
		direction = dir,
		scale = {x=1,y=1},
		size = {x = math.max(((xsize and math.max(math.floor(xsize),1) or 24)/CODELAND.resolution[1])*3.355/ratio2/ratio4,1), y = math.max(((ysize and math.max(math.floor(ysize),1) or 24)/CODELAND.resolution[2])*3.355/ratio3/ratio4,1)},
		offset = {x=0,y=0},--{x = ((((math.floor(x)/ratio2/ratio4+ (CODELAND.width/2*(1-(1/ratio2/ratio4))) )/CODELAND.width) -.5) *2)*((10 * 24) + 300), y = ((1 - ((math.floor(y)/ratio3/ratio4 + (CODELAND.height/2*(1-(1/ratio3/ratio4))) )/CODELAND.height)) *2/2)*(-(10*60))},
		z_index = 2,
	}
	else
	 if CODELAND.resolution*640 >= screen_w and CODELAND.resolution*360 >= screen_h then
  image = string
  end
	def = {
		hud_elem_type = "statbar",
		position = {x=1-(.5-(((math.floor(x)-(CODELAND.width/2))/CODELAND.width)/ratio2/ratio4)),y=1-(.5-(((math.floor(y)-(CODELAND.height/2))/CODELAND.height)/ratio3/ratio4))},--{x = .5, y = 1},
		text = image,
		text2 = image,
		number = 2,
		item = 2,
		direction = dir,
		scale = {x=1,y=1},
		size = {x = math.max(((xsize and math.max(math.floor(xsize),1) or 24)/CODELAND.resolution)*3.355/ratio2/ratio4,1), y = math.max(((ysize and math.max(math.floor(ysize),1) or 24)/CODELAND.resolution)*3.355/ratio3/ratio4,1)},
		offset = {x=0,y=0},--{x = ((((math.floor(x)/ratio2/ratio4+ (CODELAND.width/2*(1-(1/ratio2/ratio4))) )/CODELAND.width) -.5) *2)*((10 * 24) + 300), y = ((1 - ((math.floor(y)/ratio3/ratio4 + (CODELAND.height/2*(1-(1/ratio3/ratio4))) )/CODELAND.height)) *2/2)*(-(10*60))},
		z_index = 2,
	}
	end
 --hud_id[player:hud_add(def)] = true
 
 hud_defs_id = hud_defs_id+1
 hud_defs[hud_defs_id] = def
 
--	hud_drawing = hud_drawing.."^([combine:"..(CODELAND.width*2).."x"..(CODELAND.height*2)..":0,0=blank.png:"..math.floor(x)..","..math.floor(y).."=("..string.."))"
 end
end

function CODELAND.draw_rectangle(x,y,xsize,ysize,dir,hexcolor)
local hex = "#FFFFFF"
if type(hexcolor) == "table" then
 local rgba = hexcolor
 hex = minetest.rgba(rgba[1] or 255,rgba[2] or 255,rgba[3] or 255,rgba[4] or 255)
elseif type(hexcolor) == "string" then
 hex = hexcolor
 if hex:sub(1,1) ~= "#" then
  hex = "#"..hex
 end
elseif type(hexcolor) == "number" then
 hex = minetest.rgba(math.mod(math.floor(math.round(hexcolor)/0x10000),256),math.mod(math.floor(math.round(hexcolor)/0x100),256),math.mod(math.round(hexcolor),256),math.mod(math.floor(math.round(hexcolor)/0x1000000),256))
end
draw_image(x,y,xsize,ysize,"builtin_rectangle.png^[multiply:"..hex,dir)
 if type(CODELAND.resolution) == "table" then
 x = (x*.8)/(pixels*CODELAND.resolution[1]) -.36
 y = (y*.85)/(pixels*CODELAND.resolution[2]) -.38
 xsize = xsize/(pixels*CODELAND.resolution[1])
 ysize = ysize/(pixels*CODELAND.resolution[2])
 else
 x = (x*.8)/(pixels*CODELAND.resolution) -.36
 y = (y*.85)/(pixels*CODELAND.resolution) -.38
 xsize = xsize/(pixels*CODELAND.resolution)
 ysize = ysize/(pixels*CODELAND.resolution)
 end
 drawing = drawing..[[
]].."image["..x..","..y..";"..xsize..","..ysize..";builtin_rectangle.png^[multiply:"..hex.."]"
end
function CODELAND.draw_circle(x,y,radius,dir,hexcolor,fixed)
local hex = "#FFFFFF"
if type(hexcolor) == "table" then
 local rgba = hexcolor
 hex = minetest.rgba(rgba[1] or 255,rgba[2] or 255,rgba[3] or 255,rgba[4] or 255)
elseif type(hexcolor) == "string" then
 hex = hexcolor
 if hex:sub(1,1) ~= "#" then
  hex = "#"..hex
 end
elseif type(hexcolor) == "number" then
 hex = minetest.rgba(math.mod(math.floor(math.round(hexcolor)/0x10000),256),math.mod(math.floor(math.round(hexcolor)/0x100),256),math.mod(math.round(hexcolor),256),math.mod(math.floor(math.round(hexcolor)/0x1000000),256))
end
 if fixed then
  x = x-(radius/2)
  y = y-(radius/2)
 end
 draw_image(x,y,radius,radius,"builtin_circle.png^[multiply:"..hex,dir)
 local xsize,ysize = radius,radius
 if type(CODELAND.resolution) == "table" then
 x = (x*.8)/(pixels*CODELAND.resolution[1]) -.36
 y = (y*.85)/(pixels*CODELAND.resolution[2]) -.38
 xsize = xsize/(pixels*CODELAND.resolution[1])
 ysize = ysize/(pixels*CODELAND.resolution[2])
 else
 x = (x*.8)/(pixels*CODELAND.resolution) -.36
 y = (y*.85)/(pixels*CODELAND.resolution) -.38
 xsize = xsize/(pixels*CODELAND.resolution)
 ysize = ysize/(pixels*CODELAND.resolution)
 end
 drawing = drawing..[[
]].."image["..x..","..y..";"..xsize..","..ysize..";builtin_circle.png^[multiply:"..hex.."]"
end
function CODELAND.draw_ellipse(x,y,xsize,ysize,dir,hexcolor)
local hex = "#FFFFFF"
if type(hexcolor) == "table" then
 local rgba = hexcolor
 hex = minetest.rgba(rgba[1] or 255,rgba[2] or 255,rgba[3] or 255,rgba[4] or 255)
elseif type(hexcolor) == "string" then
 hex = hexcolor
 if hex:sub(1,1) ~= "#" then
  hex = "#"..hex
 end
elseif type(hexcolor) == "number" then
 hex = minetest.rgba(math.mod(math.floor(math.round(hexcolor)/0x10000),256),math.mod(math.floor(math.round(hexcolor)/0x100),256),math.mod(math.round(hexcolor),256),math.mod(math.floor(math.round(hexcolor)/0x1000000),256))
end
 draw_image(x,y,xsize,ysize,"builtin_circle.png^[multiply:"..hex,dir)
 if type(CODELAND.resolution) == "table" then
 x = (x*.8)/(pixels*CODELAND.resolution[1]) -.36
 y = (y*.85)/(pixels*CODELAND.resolution[2]) -.38
 xsize = xsize/(pixels*CODELAND.resolution[1])
 ysize = ysize/(pixels*CODELAND.resolution[2])
 else
 x = (x*.8)/(pixels*CODELAND.resolution) -.36
 y = (y*.85)/(pixels*CODELAND.resolution) -.38
 xsize = xsize/(pixels*CODELAND.resolution)
 ysize = ysize/(pixels*CODELAND.resolution)
 end
 drawing = drawing..[[
]].."image["..x..","..y..";"..xsize..","..ysize..";builtin_circle.png^[multiply:"..hex.."]"
end
function CODELAND.draw_line(x,y,x2,y2,hexcolor)
 local xsize,ysize = x2-x,y2-y
local hex = "#FFFFFF"
if type(hexcolor) == "table" then
 local rgba = hexcolor
 hex = minetest.rgba(rgba[1] or 255,rgba[2] or 255,rgba[3] or 255,rgba[4] or 255)
elseif type(hexcolor) == "string" then
 hex = hexcolor
 if hex:sub(1,1) ~= "#" then
  hex = "#"..hex
 end
elseif type(hexcolor) == "number" then
 hex = minetest.rgba(math.mod(math.floor(math.round(hexcolor)/0x10000),256),math.mod(math.floor(math.round(hexcolor)/0x100),256),math.mod(math.round(hexcolor),256),math.mod(math.floor(math.round(hexcolor)/0x1000000),256))
end
 local xflip,yflip = xsize < 0,ysize < 0
 local flip_string = ""
 if xflip then
  flip_string = flip_string.."^[transformFX"
 end
 if yflip then
  flip_string = flip_string.."^[transformFY"
 end
 x = x+math.min(xsize,0)
 y = y+math.min(ysize,0)
 xsize = math.abs(xsize)
 ysize = math.abs(ysize)
 draw_image(x,y,xsize,ysize,"builtin_line.png^[multiply:"..hex..flip_string,0)
 if type(CODELAND.resolution) == "table" then
 x = (x*.8)/(pixels*CODELAND.resolution[1]) -.36
 y = (y*.85)/(pixels*CODELAND.resolution[2]) -.38
 xsize = xsize/(pixels*CODELAND.resolution[1])
 ysize = ysize/(pixels*CODELAND.resolution[2])
 else
 x = (x*.8)/(pixels*CODELAND.resolution) -.36
 y = (y*.85)/(pixels*CODELAND.resolution) -.38
 xsize = xsize/(pixels*CODELAND.resolution)
 ysize = ysize/(pixels*CODELAND.resolution)
 end
 drawing = drawing..[[
]].."image["..x..","..y..";"..xsize..","..ysize..";builtin_line.png^[multiply:"..hex..flip_string.."]"
end
function CODELAND.draw_line_relative(x,y,xsize,ysize,hexcolor)
local hex = "#FFFFFF"
if type(hexcolor) == "table" then
 local rgba = hexcolor
 hex = minetest.rgba(rgba[1] or 255,rgba[2] or 255,rgba[3] or 255,rgba[4] or 255)
elseif type(hexcolor) == "string" then
 hex = hexcolor
 if hex:sub(1,1) ~= "#" then
  hex = "#"..hex
 end
elseif type(hexcolor) == "number" then
 hex = minetest.rgba(math.mod(math.floor(math.round(hexcolor)/0x10000),256),math.mod(math.floor(math.round(hexcolor)/0x100),256),math.mod(math.round(hexcolor),256),math.mod(math.floor(math.round(hexcolor)/0x1000000),256))
end
 local xflip,yflip = xsize < 0,ysize < 0
 local flip_string = ""
 if xflip then
  flip_string = flip_string.."^[transformFX"
 end
 if yflip then
  flip_string = flip_string.."^[transformFY"
 end
 x = x+math.min(xsize,0)
 y = y+math.min(ysize,0)
 xsize = math.abs(xsize)
 ysize = math.abs(ysize)
 draw_image(x,y,xsize,ysize,"builtin_line.png^[multiply:"..hex..flip_string,0)
 if type(CODELAND.resolution) == "table" then
 x = (x*.8)/(pixels*CODELAND.resolution[1]) -.36
 y = (y*.85)/(pixels*CODELAND.resolution[2]) -.38
 xsize = xsize/(pixels*CODELAND.resolution[1])
 ysize = ysize/(pixels*CODELAND.resolution[2])
 else
 x = (x*.8)/(pixels*CODELAND.resolution) -.36
 y = (y*.85)/(pixels*CODELAND.resolution) -.38
 xsize = xsize/(pixels*CODELAND.resolution)
 ysize = ysize/(pixels*CODELAND.resolution)
 end
 drawing = drawing..[[
]].."image["..x..","..y..";"..xsize..","..ysize..";builtin_line.png^[multiply:"..hex..flip_string.."]"
end
function CODELAND.draw_image(x,y,xsize,ysize,filename,dir)
 draw_image(x,y,xsize,ysize,dir,filename)
 if type(CODELAND.resolution) == "table" then
 x = (x*.8)/(pixels*CODELAND.resolution[1]) -.36
 y = (y*.85)/(pixels*CODELAND.resolution[2]) -.38
 xsize = xsize/(pixels*CODELAND.resolution[1])
 ysize = ysize/(pixels*CODELAND.resolution[2])
 else
 x = (x*.8)/(pixels*CODELAND.resolution) -.36
 y = (y*.85)/(pixels*CODELAND.resolution) -.38
 xsize = xsize/(pixels*CODELAND.resolution)
 ysize = ysize/(pixels*CODELAND.resolution)
 end
 drawing = drawing..[[
]].."image["..x..","..y..";"..xsize..","..ysize..";"..filename.."]"
end
function CODELAND.draw_text(x,y,xsize,ysize,dir,text,hc)
local hexcolor = hc
local hex = "#FFFFFF"
--[[]]
if type(hexcolor) == "table" then
 local rgba = hexcolor
 hex = minetest.rgba(rgba[1] or 255,rgba[2] or 255,rgba[3] or 255,rgba[4] or 255)
elseif type(hexcolor) == "string" then
 hex = hexcolor
 if hex:sub(1,1) ~= "#" then
  hex = "#"..hex
 end
elseif type(hexcolor) == "number" then
 hex = minetest.rgba(math.mod(math.floor(math.round(hexcolor)/0x10000),256),math.mod(math.floor(math.round(hexcolor)/0x100),256),math.mod(math.round(hexcolor),256),math.mod(math.floor(math.round(hexcolor)/0x1000000),256))
end

 if current_name then
 local hex = 0xFFFFFF
if type(hexcolor) == "table" then
 local rgba = hexcolor
 hex = (math.floor(rgba[1] or 255)*0x10000)+(math.floor(rgba[2] or 255)*0x100)+math.floor(rgba[3] or 255)
elseif type(hexcolor) == "string" then
 hex = hexcolor
 hex = tonumber("0x"..hex:sub(2,7))
elseif type(hexcolor) == "number" then
 hex = hexcolor
end
 local player = minetest.get_player_by_name(current_name)
 -- This Protects from the Lagging
--[[
 if false and #hud_id > 4 then
 for k,v in pairs(hud_id) do
  player:hud_remove(k)
  hud_id[k] = nil
 end
 end
 ]]
 local ratio = math.max (CODELAND.ratio[1],CODELAND.ratio[2])
 local ratio3,ratio2 = CODELAND.ratio[1]/ratio,CODELAND.ratio[2]/ratio*(16/9)
 local ratio4 = 1/math.min(ratio2,ratio3)
 local def
 if type(CODELAND.resolution) == "table" then
 def = {
		hud_elem_type = "text",
		position = {x=1-(.5-(((math.floor(x)-(CODELAND.width/2))/CODELAND.width)/ratio2/ratio4)),y=1-(.5-(((math.floor(y)-(CODELAND.height/2))/CODELAND.height)/ratio3/ratio4))},--{x = 0.5, y = 1},
		alignment = {x=1,y=1},
		text = text,
		number = hex,
		direction = dir,
		size = {x = (xsize and math.max(math.floor(xsize),1)/12 or 1)/CODELAND.resolution[1]/ratio2/ratio4, y = (ysize and math.max(math.floor(ysize),1)/12 or 1)/CODELAND.resolution[2]/ratio3/ratio4},
		offset = {x=0,y=0},--{x = ((((math.floor(x)/ratio2/ratio4 + (CODELAND.width/2*(1-(1/ratio2/ratio4))) )/CODELAND.width) -.5) *2)*((10 * 24) + 300), y = ((1 - ((math.floor(y)/ratio3/ratio4 + (CODELAND.height/2*(1-(1/ratio3/ratio4))) )/CODELAND.height)) *2/2)*(-(10*60))},
		z_index = 2,
	}
 else
 def = {
		hud_elem_type = "text",
		position = {x=1-(.5-(((math.floor(x)-(CODELAND.width/2))/CODELAND.width)/ratio2/ratio4)),y=1-(.5-(((math.floor(y)-(CODELAND.height/2))/CODELAND.height)/ratio3/ratio4))},--{x = 0.5, y = 1},
		alignment = {x=1,y=1},
		text = text,
		number = hex,
		direction = dir,
		size = {x = (xsize and math.max(math.floor(xsize),1)/12 or 1)/CODELAND.resolution/ratio2/ratio4, y = (ysize and math.max(math.floor(ysize),1)/12 or 1)/CODELAND.resolution/ratio3/ratio4},
		offset = {x=0,y=0},--{x = ((((math.floor(x)/ratio2/ratio4 + (CODELAND.width/2*(1-(1/ratio2/ratio4))) )/CODELAND.width) -.5) *2)*((10 * 24) + 300), y = ((1 - ((math.floor(y)/ratio3/ratio4 + (CODELAND.height/2*(1-(1/ratio3/ratio4))) )/CODELAND.height)) *2/2)*(-(10*60))},
		z_index = 2,
	}
 end
 --hud_id[player:hud_add(def)] = true
 
 hud_defs_id = hud_defs_id+1
 hud_defs[hud_defs_id] = def
 
 end
--[[
player:hud_add({
				hud_elem_type = "text",
				position = pos,
				text = text,
				alignment = {x=1,y=1},
				number = text_color,
				direction = 0,
				offset = { x = offset.x + 2,  y = offset.y - 1},
				z_index = 2,
		})
]]
 if type(CODELAND.resolution) == "table" then
 x = (x*.8)/(pixels*CODELAND.resolution[1]) -.36
 y = (y*.85)/(pixels*CODELAND.resolution[2]) -.38
 xsize = xsize/(pixels*CODELAND.resolution[1])*3
 ysize = ysize/(pixels*CODELAND.resolution[2])*3
 else
 x = (x*.8)/(pixels*CODELAND.resolution) -.36
 y = (y*.85)/(pixels*CODELAND.resolution) -.38
 xsize = xsize/(pixels*CODELAND.resolution)*3
 ysize = ysize/(pixels*CODELAND.resolution)*3
 end
--[=[
 if hexcolor then
  local rgba = hexcolor
  drawing = drawing..[[
]].."label["..x..","..y..";"..minetest.colorize(minetest.rgba(rgba[1],rgba[2],rgba[3],rgba[4] or 255), F(text)).."]"
 else
  drawing = drawing..[[
]].."label["..x..","..y..";"..F(text).."]"
 end
]=]
 drawing = drawing..[[
]].."hypertext["..x..","..y..";"..xsize..","..ysize..";;"..[[<style color=]]..hex..[[>]]..F(text)..[[</style>]].."]"
end

local d3d_count = 0
local d3d_drawings_entity = {}
local d3d_drawings = {}

for k,v in pairs({[1] = "sphere", [2] = "cube", [3] = "pyramid", [4] = "cylinder", [5] = "tube", [6] = "torus"}) do
 CODELAND["draw_3d_"..v] = function(x,y,z,xsize,ysize,zsize,textures,rotation)
 xsize,ysise,zsize = xsize or 1,ysise or 1,zsize or 1
 local d3d_id = #d3d_drawings+1
d3d_drawings[d3d_id] = {prop={
textures = textures,
visual_size = {x=xsize*8,y=ysize*8,z=zsize*8},
visual = "mesh",
mesh = "codeland_"..v..".obj",
},pos=vector.new(x or 0,y or 0, z or 0)}
if not d3d_drawings_entity[d3d_id] then
  local obj = minetest.add_entity(d3d_drawings[d3d_id].pos, "codeland:3d_drawing")
  if obj then
	local ent = obj:get_luaentity()
   ent.index = d3d_id
  obj:set_properties(d3d_drawings[d3d_id].prop)
  d3d_drawings_entity[d3d_id] = ent
  else
   d3d_drawings[d3d_id] = nil
   return nil
  end
  end
 if type(CODELAND.resolution) == "table" then
 x = (x*.8)/(pixels*CODELAND.resolution[1]) -.36
 y = (y*.85)/(pixels*CODELAND.resolution[2]) -.38
 xsize = xsize/(pixels*CODELAND.resolution[1])
 ysize = ysize/(pixels*CODELAND.resolution[2])
 else
 x = (x*.8)/(pixels*CODELAND.resolution) -.36
 y = (y*.85)/(pixels*CODELAND.resolution) -.38
 xsize = xsize/(pixels*CODELAND.resolution)
 ysize = ysize/(pixels*CODELAND.resolution)
 end
--d3d_count = d3d_count+1
--[=[  drawing = drawing..[[
]].."model["..x..","..y..";"..xsize..","..ysize..";m"..d3d_count..";codeland_"..v..".obj;"..texture..";"..(rotation.x or 0)..","..(rotation.y or 0)..";false;false;0,30]"
]=]
 end
 CODELAND["draw_3d_"..v.."_color"] = function(x,y,z,xsize,ysize,zsize,hexcolor,rotation)
--d3d_count = d3d_count+1
local hex = "#FFFFFF"
if type(hexcolor) == "table" then
 local rgba = hexcolor
 hex = minetest.rgba(rgba[1] or 255,rgba[2] or 255,rgba[3] or 255,rgba[4] or 255)
elseif type(hexcolor) == "string" then
 hex = hexcolor
 if hex:sub(1,1) ~= "#" then
  hex = "#"..hex
 end
elseif type(hexcolor) == "number" then
 hex = minetest.rgba(math.mod(math.floor(math.round(hexcolor)/0x10000),256),math.mod(math.floor(math.round(hexcolor)/0x100),256),math.mod(math.round(hexcolor),256),math.mod(math.floor(math.round(hexcolor)/0x1000000),256))
end
 xsize,ysise,zsize = xsize or 1,ysise or 1,zsize or 1
 local d3d_id = #d3d_drawings+1
d3d_drawings[d3d_id] = {prop={
textures = {"gui_formbg.png^[colorize:"..hex},
visual_size = {x=xsize*8,y=ysize*8,z=zsize*8},
visual = "mesh",
mesh = "codeland_"..v..".obj",
},pos=vector.new(x or 0,y or 0, z or 0)}
if not d3d_drawings_entity[d3d_id] then
  local obj = minetest.add_entity(d3d_drawings[d3d_id].pos, "codeland:3d_drawing")
  if obj then
	local ent = obj:get_luaentity()
   ent.index = d3d_id
  obj:set_properties(d3d_drawings[d3d_id].prop)
  d3d_drawings_entity[d3d_id] = ent
  else
   d3d_drawings[d3d_id] = nil
   return nil
  end
  end
 if type(CODELAND.resolution) == "table" then
 x = (x*.8)/(pixels*CODELAND.resolution[1]) -.36
 y = (y*.85)/(pixels*CODELAND.resolution[2]) -.38
 xsize = xsize/(pixels*CODELAND.resolution[1])
 ysize = ysize/(pixels*CODELAND.resolution[2])
 else
 x = (x*.8)/(pixels*CODELAND.resolution) -.36
 y = (y*.85)/(pixels*CODELAND.resolution) -.38
 xsize = xsize/(pixels*CODELAND.resolution)
 ysize = ysize/(pixels*CODELAND.resolution)
 end
--[=[  drawing = drawing..[[
]].."model["..x..","..y..";"..xsize..","..ysize..";m"..d3d_count..";codeland_"..v..".obj;gui_formbg.png^[colorize:"..hex..";"..(rotation.x or 0)..","..(rotation.y or 0)..";false;false;0,30]"]=]
 end
end
CODELAND.draw_3d_visual = function(x,y,z,visual)
 xsize,ysise,zsize = xsize or 1,ysise or 1,zsize or 1
 local d3d_id = #d3d_drawings+1
 if visual == nil or type(visual) ~= "table" then
  visual={}
 end
 visual = {textures = visual.textures or {"builtin_rectangle.png"},visual_size = visual.size or {x=8,y=8,z=8},visual = visual.type or "mesh",mesh = visual.mesh or "codeland_sphere.obj"}
d3d_drawings[d3d_id] = {prop=visual,pos=vector.new(x or 0,y or 0, z or 0)}
if not d3d_drawings_entity[d3d_id] then
  local obj = minetest.add_entity(d3d_drawings[d3d_id].pos, "codeland:3d_drawing")
  if obj then
	local ent = obj:get_luaentity()
   ent.index = d3d_id
  obj:set_properties(d3d_drawings[d3d_id].prop)
  d3d_drawings_entity[d3d_id] = ent
  else
   d3d_drawings[d3d_id] = nil
   return nil
  end
  end
--d3d_count = d3d_count+1
end
function CODELAND.draw_3d_text(x,y,z,text,hc)
local hexcolor = hc
local hex = "#FFFFFF"
--[[]]
if type(hexcolor) == "table" then
 local rgba = hexcolor
 hex = minetest.rgba(rgba[1] or 255,rgba[2] or 255,rgba[3] or 255,rgba[4] or 255)
elseif type(hexcolor) == "string" then
 hex = hexcolor
 if hex:sub(1,1) ~= "#" then
  hex = "#"..hex
 end
elseif type(hexcolor) == "number" then
 hex = minetest.rgba(math.mod(math.floor(math.round(hexcolor)/0x10000),256),math.mod(math.floor(math.round(hexcolor)/0x100),256),math.mod(math.round(hexcolor),256),math.mod(math.floor(math.round(hexcolor)/0x1000000),256))
end

 if current_name then
 local hex = 0xFFFFFF
if type(hexcolor) == "table" then
 local rgba = hexcolor
 hex = (math.floor(rgba[1] or 255)*0x10000)+(math.floor(rgba[2] or 255)*0x100)+math.floor(rgba[3] or 255)
elseif type(hexcolor) == "string" then
 hex = hexcolor
 hex = tonumber("0x"..hex:sub(2,7))
elseif type(hexcolor) == "number" then
 hex = hexcolor
end
 local player = minetest.get_player_by_name(current_name)
 local def = {
		hud_elem_type = "waypoint",
		world_pos = vector.new(x,y,z),
		alignment = {x=1,y=1,z=1},
		name = text,
		number = hex,
		precision = 0,
		text = "",
		offset = {x=0,y=0},
		z_index = 2,
	}
 --hud_id[player:hud_add(def)] = true
 
 hud_defs_id = hud_defs_id+1
 hud_defs[hud_defs_id] = def
 
 end
end
local cart_entity = {
	initial_properties = {
		physical = false, -- otherwise going uphill breaks
		collisionbox = {0,0,0,0,0,0},
		visual = "mesh",
		mesh = "codeland_sphere.obj",
		visual_size = {x=1, y=1},
		textures = {"builtin_rectangle.png"},
		visible = true,
	},

 shadered = true,
 glow = 14/2 +.5,
	index = -1,
	break_time = 0,
	time = 0,
}

function cart_entity:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
end

function cart_entity:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if string.sub(staticdata, 1, string.len("return")) ~= "return" then
		return
	end
	local data = minetest.deserialize(staticdata)
	if type(data) ~= "table" then
		return
	end
	self.index = data.index
	if not (self.index and self.index >= 1 and d3d_drawings[self.index]) then
	d3d_drawings_entity[self.index] = nil
  self.object:remove()
  return false
 end
   local def = d3d_drawings[self.index]
  self.object:set_properties(def.prop)
  self.object:set_pos(def.pos)
end

function cart_entity:get_staticdata()
 local t = {
		index = self.index
	}
	return minetest.serialize(t)
end

function cart_entity:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
 local clicker = puncher
	if not clicker or not clicker:is_player() then
		return
	end
end

function cart_entity:on_step(dtime)
 if self.break_time <= .125 then
  self.break_time = self.break_time+dtime 
  return
 end
 self.break_time = self.break_time+dtime 
 if not (self.index and self.index >= 1 and d3d_drawings[self.index]) then
	d3d_drawings_entity[self.index] = nil
  self.object:remove()
  return false
 end
  local def = d3d_drawings[self.index]
  self.object:set_properties(def.prop)
  self.object:set_pos(def.pos)
end

minetest.register_entity(":codeland:3d_drawing", cart_entity)

function main(time,dtime)
end

CODELAND.fields = {}

-- Load files
local default_path = minetest.get_modpath("default")

local prompt_log = [[
Codeland Prompt
Copyright 2023 by Phaulo Riquelme

]] 
local running=false
local exit_to_prompt = true
local autorunner = an_compiled_project and an_compiled_project_name or tostring(minetest.settings:get("autorun") or "nil") or "nil"
local in_prompt = false
local loadname = nil;
local project_name = ""
if autorunner ~= "nil" then
local noerror,msg = pcall(minetest.get_modpath,autorunner)
if noerror and msg then
main(0,0)
in_prompt = false
running=true
exit_to_prompt = false
project_name=autorunner
loadname = msg.."/code.lua"
else
prompt_log = prompt_log..[[
<style color=#FF0000>The Project ]]..autorunner..[[ doesn't exist</style> 
]]
    CODELAND.play_beep(1275)
    minetest.after(.08,function() CODELAND.stop_beep() end)
end
else
--dofile(default_path.."/code.lua")
end
local time = 0
local timer = 0
local name;
local prompt_text = ""
local prompt_formspec = [[size[16,9]
 position[0.5,0.5]
 options[key_event=true]
 bgcolor[#000000FF;true]
 hypertext[1,1;15,8;;]]..F(prompt_log).."/]"

local function prompt_update()
prompt_formspec = [[size[16,9]
 position[0.5,0.5]
 options[key_event=true]
 bgcolor[]]..minetest.rgba(CODELAND.bgcolor[1],CODELAND.bgcolor[2],CODELAND.bgcolor[3],255)..[[;true]
]]
if current_name then
	local name = current_name --player:get_player_name()
	local info = minetest.get_player_information(name)
	if info.formspec_version > 1 then
		prompt_formspec = prompt_formspec .. "background9[5,5;1,1;gui_formbg.png^[colorize:"..minetest.rgba(CODELAND.bgcolor[1],CODELAND.bgcolor[2],CODELAND.bgcolor[3],255)..";true;10]"
	else
		prompt_formspec = prompt_formspec .. "background[5,5;1,1;gui_formbg.png^[colorize:"..minetest.rgba(CODELAND.bgcolor[1],CODELAND.bgcolor[2],CODELAND.bgcolor[3],255)..";true]"
	end
end
local lum = (255-(CODELAND.bgcolor[1]*.299 + CODELAND.bgcolor[2]*.587 + CODELAND.bgcolor[3]*.114))/255
local rgba = minetest.rgba(math.round(lum)*255,math.round(lum)*255,math.round(lum)*255)
prompt_formspec = prompt_formspec .. [[ 
 hypertext[0,0;16,9;;<style color=]]..rgba..">"..F(prompt_log)..[[/]]..F(prompt_text)..[[</style>]
 field[0,8.25;15,1;command;Type here;]]..F(prompt_text)..[[]
	button[15,8;1,1;ok;Ok]
 ]]
end

local old_keys = {}
local key_bits = {
 ["up"] = 1,
 ["down"] = 2,
 ["left"] = 3,
 ["right"] = 4,
 ["jump"] = 5,
 ["sneak"] = 6,
 ["aux1"] = 7,
 ["zoom"] = 8,
}
local mouse_x,mouse_y = 0,0
local mouse_evt = 1
local mouse_hold = 0
local mouse_left_click = false
local mouse_right_click = false
local old_mouse_left_click = false
local old_mouse_right_click = false
local old_hor,old_ver = 0,0
CODELAND.registered_mouseclicks = {}
CODELAND.registered_keypresses = {}
CODELAND.registered_steps = {}
CODELAND.registered_on_receive_fields = {}
CODELAND.override_mousex = nil
CODELAND.override_mousey = nil
CODELAND.mouse_w = nil
CODELAND.mouse_h = nil
CODELAND.mouse_tex = nil
local inv_formspec = ""
CODELAND.exit = function()
if an_compiled_project then
    core.request_shutdown("",false,0)
    return
end
if current_name then
 local player = minetest.get_player_by_name(current_name)
 while (#hud_ids > 0) do
 for k,v in pairs(hud_ids) do
  if player:hud_remove(v.idx) then
  hud_ids[k] = nil
  end
 end
 end
hud_defs_id = 0
hud_defs = {}
 end
CODELAND.objects = {}
CODELAND.registered_objects = {}
CODELAND.d3d_objects = {}
CODELAND.registered_3d_objects = {}
CODELAND.d3d_lights = {}
minetest.clear_objects({mode = "quick"})
CODELAND.registered_mouseclicks = {}
CODELAND.registered_keypresses = {}
CODELAND.registered_steps = {}
CODELAND.registered_on_receive_fields = {}
CODELAND.override_mousex = nil
CODELAND.override_mousey = nil
CODELAND.mouse_w = nil
CODELAND.mouse_h = nil
CODELAND.mouse_tex = nil
CODELAND.sky_textures = nil
update_sky()
CODELAND.stop_music()
CODELAND.stop_all_psg()
CODELAND.stop_all_sounds()
CODELAND.stop_all_3d_sounds()
CODELAND.stop_beep()
d3d_drawings_entity = {}
d3d_drawings = {}
if current_name then
 local player = minetest.get_player_by_name(current_name)
inv_formspec = ""
 player:set_inventory_formspec("")
end
function main(time,dtime)
end
time = 0
timer = 0
  in_prompt = false
  running = false
  exit_to_prompt = true
project_name=""
end
minetest.register_chatcommand("update", {
	description = "Updates Codeland",
	func = function(name,param)
	 if name ~= current_name then
	  return false, "Codeland didn't start correctly."
	 end
	 RESTART_PLAYER_NAME = current_name
	  local player = minetest.get_player_by_name(current_name)
updated = true
--[[
if hud_id and current_name then
 local player = minetest.get_player_by_name(current_name)
 for k,v in pairs(hud_id) do
  player:hud_remove(k)
  hud_id[k] = nil
 end
end
]]
 while (#hud_ids > 0) do
 for k,v in pairs(hud_ids) do
  if player:hud_remove(v.idx) then
  hud_ids[k] = nil
  end
 end
 end
hud_defs_id = 0
hud_defs = {}
drawing = [[]]
CODELAND.objects = {}
CODELAND.registered_objects = {}
CODELAND.d3d_objects = {}
CODELAND.registered_3d_objects = {}
CODELAND.d3d_lights = {}
minetest.clear_objects({mode = "quick"})
CODELAND.registered_mouseclicks = {}
CODELAND.registered_keypresses = {}
CODELAND.registered_steps = {}
CODELAND.registered_on_receive_fields = {}
CODELAND.override_mousex = nil
CODELAND.override_mousey = nil
CODELAND.mouse_w = nil
CODELAND.mouse_h = nil
CODELAND.mouse_tex = nil
CODELAND.bgcolor = {0,0,0}
CODELAND.sky_textures = nil
update_sky()
CODELAND.stop_music()
CODELAND.stop_all_psg()
CODELAND.stop_all_sounds()
CODELAND.stop_all_3d_sounds()
CODELAND.stop_beep()
sounds=nil
d3d_sounds=nil
beeper=nil
psg=nil
--CODELAND = {}
d3d_drawings_entity = {}
d3d_drawings = {}
inv_formspec = ""
player:set_inventory_formspec("")
function main(time,dtime)
end
time = 0
timer = 0
project_name = ""
exit_to_prompt = true
  in_prompt = false
  running = false
  local error,msg = pcall(dofile,minetest.get_modpath("default").."/init.lua")
  return error, error and "Codeland Updated" or "Error Updating Codeland"
	end
})
minetest.register_chatcommand("exit", {
	description = "Exit to Prompt",
	func = function(name,param)
	 if name ~= current_name then
	  return false, "Codeland didn't start correctly."
	 end
  CODELAND.exit()
  return true, an_compiled_project and "Exited to Minetest" or "Exited to Prompt"
	end
})
minetest.register_chatcommand("run", {
 params = "<filename>",
	description = "Runs Code in name",
	func = function(name,param)
	if an_compiled_project then
	 return false, "This is a Compiled Project"
	end
	 if name ~= current_name then
	  return false, "Codeland didn't start correctly."
	 end
	  local player = minetest.get_player_by_name(name)
	  local splited = {[1] = nil, [2] = param}
  	 if splited[2] then
    local noerror2,message2 = pcall(minetest.get_modpath,splited[2])
    if (not noerror2) or message2==nil then
     message2 = minetest.get_modpath("default")
     message2 = message2:sub(1,#message2-(#("default")))..splited[2]
    end
 while (#hud_ids > 0) do
 for k,v in pairs(hud_ids) do
  if player:hud_remove(v.idx) then
  hud_ids[k] = nil
  end
 end
 end
hud_defs_id = 0
hud_defs = {}
CODELAND.objects = {}
CODELAND.registered_objects = {}
CODELAND.d3d_objects = {}
CODELAND.registered_3d_objects = {}
CODELAND.d3d_lights = {}
CODELAND.registered_mouseclicks = {}
CODELAND.registered_keypresses = {}
CODELAND.registered_steps = {}
CODELAND.registered_on_receive_fields = {}
CODELAND.override_mousex = nil
CODELAND.override_mousey = nil
CODELAND.mouse_w = nil
CODELAND.mouse_h = nil
CODELAND.mouse_tex = nil
CODELAND.sky_textures = nil
update_sky()
CODELAND.stop_music()
CODELAND.stop_all_psg()
CODELAND.stop_all_sounds()
CODELAND.stop_all_3d_sounds()
CODELAND.stop_beep()
d3d_drawings_entity = {}
d3d_drawings = {}
inv_formspec = ""
player:set_inventory_formspec("")
function main(time,dtime)
end
time = 0
timer = 0
    local noerror,message = pcall(dofile,message2.."/code.lua")
    if noerror then
     running = true
     main(0,0)
     project_name = param
     	local name = current_name
      minetest.show_formspec(name, "", "")
     return true, "Running a Project"
    end
    return false,[=[Error Running a Project
 
]=]..minetest.colorize("#ff0000",message)
    end
	end    
})
minetest.register_chatcommand("restart", {
	description = "Restart and Update Current Project",
	func = function(name,param)
	 if name ~= current_name then
	  return false, "Codeland didn't start correctly."
	 end
	  local player = minetest.get_player_by_name(name)
	  local splited = {[1] = nil, [2] = project_name}
  	 if splited[2] then
    local noerror2,message2 = pcall(minetest.get_modpath,splited[2])
    if (not noerror2) or message2==nil then
     message2 = minetest.get_modpath("default")
     message2 = message2:sub(1,#message2-(#("default")))..splited[2]
    end
 while (#hud_ids > 0) do
 for k,v in pairs(hud_ids) do
  if player:hud_remove(v.idx) then
  hud_ids[k] = nil
  end
 end
 end
hud_defs_id = 0
hud_defs = {}
CODELAND.objects = {}
CODELAND.registered_objects = {}
CODELAND.d3d_objects = {}
CODELAND.registered_3d_objects = {}
CODELAND.d3d_lights = {}
CODELAND.registered_mouseclicks = {}
CODELAND.registered_keypresses = {}
CODELAND.registered_steps = {}
CODELAND.registered_on_receive_fields = {}
CODELAND.override_mousex = nil
CODELAND.override_mousey = nil
CODELAND.mouse_w = nil
CODELAND.mouse_h = nil
CODELAND.mouse_tex = nil
CODELAND.sky_textures = nil
update_sky()
CODELAND.stop_music()
CODELAND.stop_all_psg()
CODELAND.stop_all_sounds()
CODELAND.stop_all_3d_sounds()
CODELAND.stop_beep()
d3d_drawings_entity = {}
d3d_drawings = {}
inv_formspec = ""
player:set_inventory_formspec("")
function main(time,dtime)
end
time = 0
timer = 0
    local noerror,message = pcall(dofile,message2.."/code.lua")
    if noerror then
     running = true
     main(0,0)
     	local name = current_name
      minetest.show_formspec(name, "", "")
     return true,"Restarted a Project"
    end
    return false,[=[Error Restarting a Project
 
]=]..minetest.colorize("#ff0000",message)
    end
	end
})
local table_concat, string_dump, string_format, string_match, math_huge
	= table.concat, string.dump, string.format, string.match, math.huge
	local function quote(string)
	return string_format("%q", string)
end

local function dump_func(func)
	return string_format("loadstring(%q)", string_dump(func))
end
local tabletostring;
tabletostring = function(table)
 if type(table) == "table" or type(table) == "userdata" then
  local text = ""
  local count = 0
  text = "{"
  for k,v in pairs((type(table) == "userdata") and getmetable(table) or table) do
   if count > 0 then
    text = text..", "
   end
   if false then-- type(k) == "number" then
    if type(v) == "function" then
     text = text..dump_func(v)
    else
     text = text..tostring( tabletostring (v)) or "nil"
    end
   elseif type(k) == "string" then
    text = text.."["..k.."]"
    if type(v) == "function" then
     text = text.." = "..dump_func(v)
    else
     text = text.." = "..tostring( tabletostring (v)) or "nil"
    end
   elseif type(k) == "function" then
    text = text.."["..dump_func(k).."]"
    if type(v) == "function" then
     text = text.." = "..dump_func(v)
    else
     text = text.." = "..tostring( tabletostring (v)) or "nil"
    end
   else
    text = text.."["..tostring( tabletostring (k)) or "nil".."]"
    if type(v) == "function" then
     text = text.." = "..dump_func(v)
    else
     text = text.." = "..tostring( tabletostring (v)) or "nil"
    end
   end
   count = count+1
  end
  text = text.."}"
  return text
 else
  return table
 end
end
CODELAND.TABLEtoSTRING = function(t) end
CODELAND.TABLEtoSTRING = function(table)
 if type(table) == "table" or type(table) == "userdata" then
  local text = ""
  local count = 0
  text = "{"
  for k,v in pairs((type(table) == "userdata") and getmetable(table) or table) do
   if count > 0 then
    text = text..", "
   end
   if false then-- type(k) == "number" then
    if type(v) == "function" then
     text = text..dump_func(v)
    elseif type(v) == "string" then
     text = text..'//"'..v..'//"'
    else
     text = text..tostring(CODELAND.TABLEtoSTRING(v)) or "nil"
    end
   elseif type(k) == "string" then
    text = text..[=[["]=]..k..[=["]]=]
    if type(v) == "function" then
     text = text.." = "..dump_func(v)
    elseif type(v) == "string" then
     text = text..[[ = "]]..v..'"'
    else
     text = text.." = "..tostring(CODELAND.TABLEtoSTRING(v)) or "nil"
    end
   elseif type(k) == "function" then
    text = text..[=[[]=]..dump_func(k)..[=[]]=]
    if type(v) == "function" then
     text = text.." = "..dump_func(v)
    elseif type(v) == "string" then
     text = text..[[ = "]]..v..'"'
    else
     text = text.." = "..tostring(CODELAND.TABLEtoSTRING(v)) or "nil"
    end
   else
    text = text..[=[[]=]..tostring(CODELAND.TABLEtoSTRING(k)) or "nil"..[=[]]=]
    if type(v) == "function" then
     text = text.." = "..dump_func(v)
    elseif type(v) == "string" then
     text = text..[[ = "]]..v..'"'
    else
     text = text.." = "..tostring(CODELAND.TABLEtoSTRING(v)) or "nil"
    end
   end
   count = count+1
  end
  text = text.."}"
  return text
 else
  return table
 end
end
local oldprint = print
print = function(...)
local list = {...}
local str = ""
for i = 1,#list do
 local text = list[i]
 if type(text) == "table" or type(text) == "userdata" then
  text = tabletostring(text)
 end
 if type(text) == "function" then
  text = dump_func(text)--"an Function"
 end
 if type(text) == "boolean" then
  text = text and "true" or "false"
 end
 --[[
 if type(text) == "userdata" then
  text = "an Userdata"
 end
 ]]
 if i > 1 then
  if #tostring(text) > 0 then
   str = (str or "nil")..", "
  end
 end
 str = str..tostring(text or "nil")
end
if current_name then
 minetest.chat_send_player(current_name,str)
end
oldprint(...)
end
CODELAND.LOG=print
function CODELAND.register_mouseclick(func)
 CODELAND.registered_mouseclicks[#CODELAND.registered_mouseclicks+1] = func
 return #CODELAND.registered_mouseclicks
end
function CODELAND.register_keypress(func)
 CODELAND.registered_keypresses[#CODELAND.registered_keypresses+1] = func
 return #CODELAND.registered_keypresses
end
function CODELAND.register_step(func)
 CODELAND.registered_steps[#CODELAND.registered_steps+1] = func
 return #CODELAND.registered_steps
end
function CODELAND.register_on_receive_fields(func)
 CODELAND.registered_on_receive_fields[#CODELAND.registered_on_receive_fields+1] = func
 return #CODELAND.registered_on_receive_fields
end
tpt = {}
gfx = {}
function gfx.textSize(str)
 local width,height = 0,0
 for line in str:gmatch("([^\r\n]+)") do
  width = math.max(width,(#line)*12)
  height = height+16
 end
 return width,height
end
graphics = gfx
function tpt.textwidth(str)
 local width = 0
 for line in str:gmatch("([^\r\n]+)") do
  width = math.max(width,(#line)*12)
 end
 return width
end
CODELAND.camera_control = false
CODELAND.output = ""
CODELAND.input_done = true
function CODELAND.input(func)
 if not CODELAND.input_done then
  return CODELAND.output
 end
 CODELAND.output = ""
 if current_name then
  CODELAND.input_done = false
minetest.show_formspec(current_name, "input", [[
 formspec_version[4]
 size[6,3.476]
 field[0.375,1.25;5.25,0.8;input;Type Here;]
 button_exit[1.5,2.3;3,0.8;ok;Okay]
]])
 end
 local runner;
 function runner()
  if CODELAND.input_done then
   func(CODELAND.output)
  else
   minetest.after(.1,runner)
  end
 end
 runner()
 return CODELAND.output
end
function CODELAND.confirm(title,func)
 if not CODELAND.input_done then
  return CODELAND.output
 end
 CODELAND.output = false
 if current_name then
  CODELAND.input_done = false
minetest.show_formspec(current_name, "confirm", [[
 formspec_version[4]
 size[6,3.476]
 label[0.375,0;]]..F(title)..[[]
 button_exit[0,2.3;3,0.8;yes;Yes]
 button_exit[3,2.3;3,0.8;no;No]
]])
 end
 while (false) do --not CODELAND.input_done) do
  --Nothing
 end
 local runner;
 function runner()
  if CODELAND.input_done then
   func(CODELAND.output)
  else
   minetest.after(.1,runner)
  end
 end
 runner()
 return CODELAND.output
end
	local localplayer
if INIT == "client" then
	minetest.register_on_connect(function()
		localplayer = minetest.localplayer
	end)
end
CODELAND.camera_rot_hor = math.rad(0)
CODELAND.camera_rot_ver = math.rad(180)
CODELAND.camera_pos = vector.new(0,0,0)
local old_camera_pos = vector.new(0,0,0)
-- Backwards Compatibility with Codeland for The Powder Toy
gfx.WIDTH = CODELAND.width
gfx.HEIGHT = CODELAND.height
function autorun_func()
if loadname then
local noerror,msg = pcall(dofile,loadname)
if not noerror then
exit_to_prompt = true
project_name=""
CODELAND.exit()
end
end
end
if not autorun_ready2 then
autorun_func()
end
function CODELAND.set_formspec(formspec)
if current_name then
 local player = minetest.get_player_by_name(current_name)
 inv_formspec = formspec
 player:set_inventory_formspec(formspec)
end
end
function CODELAND.show_formspec()
if current_name then
 local player = minetest.get_player_by_name(current_name)
minetest.show_formspec(current_name, "", inv_formspec)
end
end
function CODELAND.hide_formspec()
if current_name then
 local player = minetest.get_player_by_name(current_name)
minetest.show_formspec(current_name, "", "")
end
end
local old_sky_textures = nil
minetest.register_globalstep(function(dtime)
if updated or (not CODELAND.input_done) then
 return
end
 local name2 = minetest.settings:get("name") or "singleplayer"
 if minetest.is_singleplayer() then
  name2 = "singleplayer"
 end
 current_player = nil
 for _,player in ipairs(minetest.get_connected_players()) do
  local name = player:get_player_name() or "singleplayer"
  if name == name2 then
   current_player = player
  end
 end
minetest.set_timeofday(0.5)
if type(CODELAND.resolution) == "table" then
 CODELAND.width,CODELAND.height = 320*CODELAND.resolution[1],180*CODELAND.resolution[2]
else
 CODELAND.width,CODELAND.height = 320*CODELAND.resolution,180*CODELAND.resolution
end
-- Backwards Compatibility with Codeland for The Powder Toy
gfx.WIDTH = CODELAND.width
gfx.HEIGHT = CODELAND.height
local keys = {}
if current_name then
 local player = minetest.get_player_by_name(current_name)
	-- Set formspec prepend
	local name = current_name --player:get_player_name()
	local controls = player:get_player_control()
	keys = table.copy(controls)
	keys.LMB = nil
	keys.RMB = nil
	keys.dig = nil
	keys.place = nil
--	keys.zoom = nil
--minetest.chat_send_player(player:get_player_name(),"Mouse x: "..mouse_x.." y: "..mouse_y)
mouse_left_click = false
mouse_right_click = false
 if controls.LMB then
--minetest.chat_send_player(player:get_player_name(),"Mouse left click")
mouse_left_click = true
 end
 if controls.RMB then
--minetest.chat_send_player(player:get_player_name(),"Mouse right click")
mouse_right_click = true
 end
 --[[
 local noerror,message = pcall(dump2,player:get_eye_offset())
 minetest.chat_send_player(player:get_player_name(),message)
 player:set_eye_offset(vector.new(0,0,0), vector.new(0,0,0))
 ]]
	player:set_physics_override({speed = 0, jump = 0, gravity = 0})
 player:set_velocity(vector.new(0,0,0))
 player:set_acceleration(vector.new(0,0,0))
if type(CODELAND.resolution) == "table" then
 mouse_x = math.round(mouse_x-((math.deg(player:get_look_horizontal()-old_hor))*CODELAND.resolution[1]*(CODELAND.camera_control and 1 or 8)))
 mouse_y = math.round(mouse_y+((math.deg(player:get_look_vertical()-old_ver))*CODELAND.resolution[2]))
else
 mouse_x = math.round(mouse_x-((math.deg(player:get_look_horizontal()-old_hor))*CODELAND.resolution*(CODELAND.camera_control and 1 or 8)))
 mouse_y = math.round(mouse_y+((math.deg(player:get_look_vertical()-old_ver))*CODELAND.resolution))
end
--mouse_x = math.min(math.max(mouse_x,-1),CODELAND.width)
--mouse_y = math.min(math.max(mouse_y,-1),CODELAND.height)
mouse_x = math.mod(math.round(mouse_x),CODELAND.width)
mouse_y = math.mod(math.round(mouse_y),CODELAND.height)
local radians = math.rad(0)
if CODELAND.camera_control then
 CODELAND.camera_rot_hor = player:get_look_horizontal()
 CODELAND.camera_rot_ver = player:get_look_vertical()
 old_hor = CODELAND.camera_rot_hor
 old_ver = CODELAND.camera_rot_ver
else
player:set_look_horizontal(radians+CODELAND.camera_rot_hor)--math.rad(180))
-- player:set_look_vertical(radians+CODELAND.camera_rot_ver)--math.rad(180))
 old_hor = CODELAND.camera_rot_hor--math.rad(180)--player:get_look_horizontal()
 old_ver = player:get_look_vertical()
end
 if (CODELAND.camera_pos ~= old_camera_pos) then
 player:set_pos(CODELAND.camera_pos)
 old_camera_pos = CODELAND.camera_pos
 end
end
CODELAND.mouse_x,CODELAND.mouse_y = mouse_x,mouse_y
tpt.mousex,tpt.mousey = mouse_x,mouse_y -- Backwards Compatibility with Codeland for The Powder Toy
if mouse_left_click or mouse_right_click then
 mouse_hold = mouse_hold+1
else
 mouse_hold = 0
end
mouse_button = 0
mouse_evt = 0
if mouse_right_click or old_mouse_right_click then
 mouse_button = 3
 mouse_evt = (mouse_right_click and 1 or 0)+(old_mouse_right_click and 2 or 0)
end
if mouse_left_click or old_mouse_left_click then
 mouse_button = 1
 mouse_evt = (mouse_left_click and 1 or 0)+(old_mouse_left_click and 2 or 0)
end
prompt_update()
if (not in_prompt) and (not running) then
 if current_name then
local player = minetest.get_player_by_name(current_name)
 minetest.show_formspec(current_name, "prompt", prompt_formspec)
 --[=[
player:set_sky(math.round(CODELAND.bgcolor[1])*0x10000 + math.round(CODELAND.bgcolor[2])*0x100 + math.round(CODELAND.bgcolor[3]) + 0xFF000000, "plain", {})
]=]
 in_prompt = true
 end
end
dtime = dtime*math.min(CODELAND.speed,1)
for _ = 1,math.max(math.floor(CODELAND.speed),1) do
	timer = timer + dtime
 time = time + dtime
 CODELAND.music_phase = CODELAND.music_phase + (dtime*CODELAND.music_bpm)
 if old_music_phase ~= math.floor(CODELAND.music_phase) then
  if math.floor(CODELAND.music_phase) <= #CODELAND.music_sheet then
   local notes = CODELAND.music_sheet[math.floor(CODELAND.music_phase)]
   if notes then
    for k,v in pairs(notes) do
    if v.type == nil or v.type == "sample" then
     if v.note <= -1 then
      CODELAND.stop_sound(v.channel)
     else
      CODELAND.play_sound(v.name,v.channel,CODELAND.note_to_time(v.note),v.gain,v.loop)
     end
    elseif v.type == "psg" then
     if v.note <= -1 then
      CODELAND.stop_psg(v.channel)
     else
      CODELAND.play_psg(v.waveform,v.channel,CODELAND.note_to_time(v.note),v.gain)
     end
    end
    end
   end
  end
 end
 old_music_phase = math.floor(CODELAND.music_phase)
 if math.floor(CODELAND.music_phase) > CODELAND.music_loop_end then
  CODELAND.music_phase = CODELAND.music_loop_start
 end
 if not running then
  time = 0
  timer = 0
  d3d_count = 0
  drawing = [[]]
  --[[
if hud_id and current_name then
 local player = minetest.get_player_by_name(current_name)
 for k,v in pairs(hud_id) do
  player:hud_remove(k)
  hud_id[k] = nil
 end
end
]]
if current_name then
 local player = minetest.get_player_by_name(current_name)
 for k,v in pairs(hud_ids) do
  player:hud_remove(v.idx)
  hud_ids[k] = nil
 end
end
hud_defs_id = 0
hud_defs = {}
  return
 end
 local fps = CODELAND.FPS
 if d3d_count > 0 then
  fps = math.min(fps,16)
 end
	if timer < 1/(fps*math.min(CODELAND.speed,1)) then
--[=[
if current_name then
 minetest.show_formspec(current_name, "graphics", [[size[16,9]
 position[0.5,0.5]
 options[key_event=true;mouse_event=all]
 bgcolor[]]..minetest.rgba(CODELAND.bgcolor[1],CODELAND.bgcolor[2],CODELAND.bgcolor[3],255)..[[;true]
]]..drawing.."button[0,8.5;1,1;exit;Exit]button[1,8.5;3,1;exitToPrompt;Exit to Prompt]")
end
]=]
		return
	end

	timer = 0

d3d_count = 0
d3d_drawings = {}
--[[
if hud_id and current_name then
 local player = minetest.get_player_by_name(current_name)
 for k,v in pairs(hud_id) do
  player:hud_remove(k)
  hud_id[k] = nil
 end
end
]]
  
if current_name then
 local player = minetest.get_player_by_name(current_name)
 for k,v in pairs(hud_ids) do
-- print("id  ",k,"  def  ",v,"  def2  ",hud_defs[k],"  def3  ",player:hud_get(v.idx))
 if not hud_defs[k] then
  if player:hud_remove(v.idx) then
  hud_ids[k] = nil
  end
 end
 end
end
hud_defs_id = 0
hud_defs = {}

drawing = [[]]
--hud_drawing = ""
if current_name then
	local info = minetest.get_player_information(current_name)
	if info.platform then
	 PLATFORM = info.platform
	end
	--[[
local file = io.open(minetest.get_worldpath().."/information.lua","w")
if file then
file:write(minetest.serialize(info))
file:close()
end
]]
end
local noerror,message = pcall(main,time,dtime*math.max(CODELAND.speed,1))
if current_name and (not noerror) then
minetest.chat_send_player(current_name,minetest.colorize("#FF0000",message))
end
 for k,v in pairs(CODELAND.objects) do
  local def = CODELAND.registered_objects[v.type]
  if def then
   if def.on_draw then
   local noerror,message = pcall(def.on_draw,v.x,v.y,v.width,v.height,k)
   if not noerror then
    if current_name then
     minetest.chat_send_player(current_name,minetest.colorize("#FF0000",message))
    end
   end
   end
   if def.on_step then
   local noerror,message = pcall(def.on_step,v.x,v.y,k,v.type,dtime)
   if not noerror then
    if current_name then
     minetest.chat_send_player(current_name,minetest.colorize("#FF0000",message))
    end
   end
   end
   if def.on_click then
   if mouse_evt == 1 and (tpt.mousex >= v.x and tpt.mousey >= v.y and tpt.mousex <= v.x+v.width and tpt.mousey <= v.y+v.height) and not v.clicked then
    v.clicked = true
   local noerror,message = pcall(def.on_click,v.x,v.y,tpt.mousex,tpt.mousey,mouse_button,1,k)
   if not noerror then
   minetest.chat_send_player(current_name,minetest.colorize("#FF0000",message))
   end
   end
   if mouse_evt == 3 and v.clicked then
   local noerror,message = pcall(def.on_click,v.x,v.y,tpt.mousex,tpt.mousey,mouse_button,3,k)
   if not noerror then
   minetest.chat_send_player(current_name,minetest.colorize("#FF0000",message))
   end
   end
   if mouse_evt == 2 and v.clicked then
    v.clicked = false
   local noerror,message = pcall(def.on_click,v.x,v.y,tpt.mousex,tpt.mousey,mouse_button,2,k)
   if not noerror then
   minetest.chat_send_player(current_name,minetest.colorize("#FF0000",message))
   end
   end
   if mouse_evt == 3 and (tpt.mousex >= v.x and tpt.mousey >= v.y and tpt.mousex <= v.x+v.width and tpt.mousey <= v.y+v.height) and not v.clicked and mouse_hold <= 2 then
    v.clicked = true
   local noerror,message = pcall(def.on_click,v.x,v.y,tpt.mousex,tpt.mousey,mouse_button,1,k)
   if not noerror then
   minetest.chat_send_player(current_name,minetest.colorize("#FF0000",message))
   end
   end
   end
  end
 end
 for k,v in pairs(CODELAND.registered_mouseclicks) do
 if mouse_left_click or old_mouse_left_click then
  local noerror,message = pcall(v,mouse_x,mouse_y,1,(mouse_left_click and 1 or 0)+(old_mouse_left_click and 2 or 0),0)
   if current_name and (not noerror) then
   minetest.chat_send_player(current_name,minetest.colorize("#FF0000",message))
   end
 end
 if mouse_right_click or old_mouse_right_click then
  local noerror,message = pcall(v,mouse_x,mouse_y,3,(mouse_right_click and 1 or 0)+(old_mouse_right_click and 2 or 0),0)
   if current_name and (not noerror) then
   minetest.chat_send_player(current_name,minetest.colorize("#FF0000",message))
   end
 end
end
old_mouse_left_click = mouse_left_click
old_mouse_right_click = mouse_right_click
for k,v in pairs(CODELAND.registered_keypresses) do
 for k2,v2 in pairs(key_bits) do
  if keys[k2] or old_keys[k2] then
   local noerror,message = pcall(v,k2,v2,0,(keys[k2] and 1 or 0)+(old_keys[k2] and 2 or 0))
   if current_name and (not noerror) then
   minetest.chat_send_player(current_name,minetest.colorize("#FF0000",message))
   end
  end
 end
end
old_keys = keys
for k,v in pairs(CODELAND.registered_steps) do
 local noerror,message = pcall(v,time,dtime*math.max(CODELAND.speed,1))
   if current_name and (not noerror) then
   minetest.chat_send_player(current_name,minetest.colorize("#FF0000",message))
   end
end
 draw_image(CODELAND.override_mousex or CODELAND.mouse_x,CODELAND.override_mousey or mouse_y,CODELAND.mouse_w or 19,CODELAND.mouse_h or 19,CODELAND.mouse_img or "builtin_cursor.png")
  local updated = false
 local updated_file = io.open(minetest.get_modpath("default").."/source.lua","r")
if updated_file then
local code = updated_file:read("*a")
 if ((not downdated_init) or (type(downdated_init) ~= "string")) then
  downdated_init = code
 end
 updated = downdated_init ~= code
end
if updated then
 CODELAND.draw_text(0,0,12,12,0,"Codeland has been Updated! type: /update in chat to Update Codeland",{255,160,0})
end 
if current_name then
local player = minetest.get_player_by_name(current_name)
 for k,v in pairs(hud_defs) do
  if hud_ids[k] then
if hud_ids[k].def.hud_elem_type ~= v.hud_elem_type then
player:hud_remove(hud_ids[k].idx)
hud_ids[k] = {def=v,idx=player:hud_add(v)}
else
   for k2,v2 in pairs (v) do
    if hud_ids[k].def[k2] ~= v2 then
    player:hud_change(hud_ids[k].idx,k2,v2)
    hud_ids[k].def[k2] = v2
    end
   end
end
hud_ids[k].def = v
  else
   hud_ids[k] = {def=v,idx=player:hud_add(v)}
  end
 end
end

 --[[
 local player = minetest.get_player_by_name(current_name)
 player:hud_change(graphics_hud, "text", "(blank.png^[resize:"..(CODELAND.width*2).."x"..(CODELAND.height*2)..")"..hud_drawing)
 player:hud_change(graphics_hud, "scale", {x=2/CODELAND.resolution,y=2/CODELAND.resolution})
 ]]


 --for _, player in ipairs(minetest.get_connected_players()) do
if current_name then
local player = minetest.get_player_by_name(current_name)
	-- Set formspec prepend
	local name = current_name --player:get_player_name()
	local info = minetest.get_player_information(name)
if old_bgcolor ~= CODELAND.bgcolor then
	local formspec = [[
			bgcolor[]]..minetest.rgba(CODELAND.bgcolor[1],CODELAND.bgcolor[2],CODELAND.bgcolor[3],255)..[[;true]
 ]]
	if info.formspec_version > 1 then
		formspec = formspec .. "background9[5,5;1,1;gui_formbg.png^[colorize:"..minetest.rgba(CODELAND.bgcolor[1],CODELAND.bgcolor[2],CODELAND.bgcolor[3],255)..";true;10]"
	else
		formspec = formspec .. "background[5,5;1,1;gui_formbg.png^[colorize:"..minetest.rgba(CODELAND.bgcolor[1],CODELAND.bgcolor[2],CODELAND.bgcolor[3],255)..";true]"
	end
-- formspec = formspec .. "button[1,11;1,1;exit;Exit]"
	player:set_formspec_prepend(formspec)
--[=[
player:set_sky(math.round(CODELAND.bgcolor[1])*0x10000 + math.round(CODELAND.bgcolor[2])*0x100 + math.round(CODELAND.bgcolor[3]) + 0xFF000000, "plain", {})
]=]
update_sky()
end
if old_sky_textures ~= CODELAND.sky_textures then
 update_sky()
end
-- minetest.show_formspec(name, "", "")
--[=[
 minetest.show_formspec(name, "graphics", [[size[16,9]
 position[0.5,0.5]
 options[key_event=true;mouse_event=all]
 style_type[exit,exitToPrompt;noclip=true]
 bgcolor[]]..minetest.rgba(CODELAND.bgcolor[1],CODELAND.bgcolor[2],CODELAND.bgcolor[3],255)..[[;true]
]]..drawing.."button[0,9;1,1;exit;Exit]button[1,9;3,1;exitToPrompt;Exit to Prompt]")
]=]
end
-- end
old_bgcolor = CODELAND.bgcolor
old_sky_textures = CODELAND.sky_textures
end
end)
minetest.register_on_player_receive_fields(function(player, formname, fields)
if updated then
 return false
end 
 if current_name then
	if player:get_player_name() ~= current_name then
		return false
	end
	end
if formname == "" then
 for k,v in pairs (CODELAND.registered_on_receive_fields) do
  local noerror,message = pcall(v,fields)
  if not noerror then
   minetest.chat_send_player(current_name,minetest.colorize("#FF0000",message))
  end
 end
 return
end
	if formname == "confirm" then
	 if fields.quit then
	  CODELAND.input_done = true
	 end
	 if fields.yes then
	  CODELAND.output = true
	  CODELAND.input_done = true
	 end
	 if fields.no then
	  CODELAND.output = false
	  CODELAND.input_done = true
	 end
	 return false
	end
	if formname == "input" then
	 if fields.quit then
	  CODELAND.input_done = true
	 end
	 if fields.ok then
	  CODELAND.output = fields.input
	  CODELAND.input_done = true
	 end
	 return false
	end
 if formname == "prompt" and not running then
  if fields.command then
   prompt_text = fields.command
   if fields.command:sub(1,1) == "/" then -- It can help you
    fields.command = fields.command:sub(2)
   end
   minetest.show_formspec(current_name, "prompt", prompt_formspec)
  end
  if fields.ok then
   prompt_text = fields.command
   local splited = {}
   for word in prompt_text:gmatch("%S+") do
    table.insert(splited, word)
   end
   if splited[1] == "help" then
    prompt_log = prompt_log..[[
run <project name>; Run a Project.
exit; Exit Codeland.
bgcolor <red 0-255> <green 0-255> <blue 0-255>; Change Background Color.
speed <time>; Change Speed in times.
print <msg>; Print text in Prompt.
stop_music; Stop the Music 
play_music <project name> <name>; Play the Music from a Project.
beep <hertz> <seconds>; Play Beeper.
clear; Clears Screen in Prompt.
autorun <project name>; Set Autorun to a Project Name.
stop_all_psg; Stop all PSG channels.
stop_all_sounds; Stop all PCM channels.
stop_psg <channel 1-16>; Stop PSG channel.
stop_sound <channel 1-64>; Stop PCM channel.
play_psg <waveform 1-12> <channel 1-16> <pitch> <gain>; Play PSG channel.
]]
   elseif splited[1] == "play_psg" then
    local channel = tonumber(splited[3] or 1) or 1
    if channel < 1 or channel > 16 then
     prompt_log = prompt_log..[[
<style color=#FF0000>channel provided (]]..channel..[[) is outside the range [1, 16]</style> 
]]
     CODELAND.play_beep(1275)
     minetest.after(.08,function() CODELAND.stop_beep() end)
    else
     CODELAND.play_psg(tonumber(splited[2] or CODELAND.PSG.sine),channel,tonumber(splited[4] or 1),tonumber(splited[5] or .5))
    end
   elseif splited[1] == "stop_psg" then
    if splited[2] == nil then
     prompt_log = prompt_log..[[
<style color=#FF0000>unable stop PSG channel</style> 
]]
     CODELAND.play_beep(1275)
     minetest.after(.08,function() CODELAND.stop_beep() end)
    elseif not tonumber(splited[2]) then
     prompt_log = prompt_log..[[
<style color=#FF0000>unable stop PSG channel</style> 
]]
     CODELAND.play_beep(1275)
     minetest.after(.08,function() CODELAND.stop_beep() end)
    else
     CODELAND.stop_psg(tonumber(splited[2]))
    end
   elseif splited[1] == "stop_sound" then
    if splited[2] == nil then
     prompt_log = prompt_log..[[
<style color=#FF0000>unable stop PCM channel</style> 
]]
     CODELAND.play_beep(1275)
     minetest.after(.08,function() CODELAND.stop_beep() end)
    elseif not tonumber(splited[2]) then
     prompt_log = prompt_log..[[
<style color=#FF0000>unable stop PCM channel</style> 
]]
     CODELAND.play_beep(1275)
     minetest.after(.08,function() CODELAND.stop_beep() end)
    else
     CODELAND.stop_sound(tonumber(splited[2]))
    end
   elseif splited[1] == "stop_all_psg" then
    CODELAND.stop_all_psg()
   elseif splited[1] == "stop_all_sounds" then
    CODELAND.stop_all_sounds()
   elseif splited[1] == "autorun" then
    minetest.settings:set("autorun",splited[2])
   elseif splited[1] == "clear" then
    prompt_log = ""
   elseif splited[1] == "beep" then
    CODELAND.play_beep(tonumber(splited[2] or "1275"))
    minetest.after(tonumber(splited[3] or "0.08"),function() CODELAND.stop_beep() end)
   elseif splited[1] == "play_music" then
   if splited[2] and splited[3] then
    local noerror2,message2 = pcall(minetest.get_modpath,splited[2])
    if (not noerror2) or message2==nil then
     message2 = minetest.get_modpath("default")
     message2 = message2:sub(1,#message2-(#("default")))..splited[2]
    end
    local noerror,message = pcall(dofile,message2.."/"..splited[3])
    if noerror then
      CODELAND.play_music(message,tonumber(splited[4] or "1"))
    else
     prompt_log = prompt_log..[[
<style color=#FF0000>]]..message..[[</style> 
]]
    CODELAND.play_beep(1275)
    minetest.after(.08,function() CODELAND.stop_beep() end)
    end
    
   end
   elseif splited[1] == "stop_music" then
    CODELAND.stop_music()
   elseif splited[1] == "print" then
    local jointed = ""
    if #splited > 1 then
     for i = 2,#splited do
      jointed = jointed..splited[i].." "
     end
     prompt_log = prompt_log..[[
]]..jointed..[[ 
]]
    end
   elseif splited[1] == "speed" then
    if splited[2] then
     if tonumber(splited[2]) then
      CODELAND.speed = tonumber(splited[2])
      prompt_log = prompt_log..[[
Speed changed to ]]..splited[2]..[[x
]]
     else
      prompt_log = prompt_log..[[
<style color=#FF0000>The value: ]]..splited[2]..[[ must be a number</style> 
]]
    CODELAND.play_beep(1275)
    minetest.after(.08,function() CODELAND.stop_beep() end)
     end
    else
     prompt_log = prompt_log..[[
<style color=#FF0000>It Must have a Number to change Speed</style> 
]]
    CODELAND.play_beep(1275)
    minetest.after(.08,function() CODELAND.stop_beep() end)
    end
   elseif splited[1] == "bgcolor" then
    if #splited > 3 then
     CODELAND.bgcolor = {math.mod(math.round(tonumber(splited[2])),256),math.mod(math.round(tonumber(splited[3])),256),math.mod(math.round(tonumber(splited[4])),256)}
     prompt_log = prompt_log..[[
Background Color Changed
]]
    else
     prompt_log = prompt_log..[[
<style color=#FF0000>It Must have 3 Numbers to change Background Color</style> 
]]
    CODELAND.play_beep(1275)
    minetest.after(.08,function() CODELAND.stop_beep() end)
    end
   elseif false then --splited[1] == "restart" then
    core.request_shutdown("",true,0)
   elseif splited[1] == "exit" then
    core.request_shutdown("",false,0)
   elseif splited[1] == "run" then
    if splited[2] then
    local noerror2,message2 = pcall(minetest.get_modpath,splited[2])
    if (not noerror2) or message2==nil then
     message2 = minetest.get_modpath("default")
     message2 = message2:sub(1,#message2-(#("default")))..splited[2]
    end
    exit_to_prompt = false
    local noerror,message = pcall(dofile,message2.."/code.lua")
    if noerror then
     if not exit_to_prompt then
      in_prompt = false
      running = true
      main(0,0)
      project_name = splited[2]
     	local name = current_name
      minetest.show_formspec(name, "", "")
     else
      CODELAND.exit()
      prompt_update()
   minetest.show_formspec(current_name, "prompt", prompt_formspec)
     end
     return false
    else
     exit_to_prompt = true
     prompt_log = prompt_log..[[
<style color=#FF0000>]]..message..[[</style> 
]]
    CODELAND.play_beep(1275)
    minetest.after(.08,function() CODELAND.stop_beep() end)
    end
    end
   else
    prompt_log = prompt_log..[[
<style color=#FF0000>Unknown command: ]]..splited[1]..[[<style> 
]]
    CODELAND.play_beep(1275)
    minetest.after(.08,function() CODELAND.stop_beep() end)
   end
prompt_update()
   minetest.show_formspec(current_name, "prompt", prompt_formspec)
--[=[
player:set_sky(math.round(CODELAND.bgcolor[1])*0x10000 + math.round(CODELAND.bgcolor[2])*0x100 + math.round(CODELAND.bgcolor[3]) + 0xFF000000, "plain", {})
]=]
update_sky()
  end
  if fields.quit then
   minetest.show_formspec(current_name, "prompt", prompt_formspec)
--[=[
player:set_sky(math.round(CODELAND.bgcolor[1])*0x10000 + math.round(CODELAND.bgcolor[2])*0x100 + math.round(CODELAND.bgcolor[3]) + 0xFF000000, "plain", {})
]=]
update_sky()
  end
 end
 if formname ~= "graphics" then
		return false
	end

	local name = player:get_player_name()
	local info = minetest.get_player_information(name)
	--[[
	if fields.key_event then
		minetest.chat_send_player(name,"fields.key_event = " .. dump(minetest.explode_key_event(fields.key_event)))
	end
	if fields.mouse_event then
		minetest.chat_send_player(name,"fields.mouse_event = " .. dump(minetest.explode_mouse_event(fields.mouse_event)))
	end
	]]
if fields.exit then
 core.request_shutdown("",false,0)
end
if fields.exitToPrompt then
 running = false
 in_prompt = false
 function main(time,dtime)
 end
end
--[=[
if fields.quit then
minetest.show_formspec(name, "graphics", [[size[16,9]
 position[0.5,0.5]
 options[key_event=true;mouse_event=all]
 style_type[exit,exitToPrompt;noclip=true]
 bgcolor[]]..minetest.rgba(CODELAND.bgcolor[1],CODELAND.bgcolor[2],CODELAND.bgcolor[3],255)..[[;true]
]]..drawing.."button[0,9;1,1;exit;Exit]button[1,9;3,1;exitToPrompt;Exit to Prompt]")
end
]=]

end)
_COMPILED=nil
_COMPILED_PRJ=nil
