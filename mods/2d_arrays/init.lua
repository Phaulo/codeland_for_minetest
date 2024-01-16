addons["2d_arrays"] = true
CODELAND.d2d_arrays = {}
function CODELAND.d2d_arrays.new(width,height)
 width = math.max(width or 32,1)
 if type(width) ~= "number" and width == width then
  error("expecting number but getting "..(type(width) or "nothing")..".")
 end
 if width ~= width then
  error("expecting number but getting NaN.")
 end
 if math.abs(width) == math.huge then
  error("you may not use a infinity number.")
 end
 width = math.floor(width)
 height = math.max(height or 32,1)
 if type(height) ~= "number" and height == height then
  error("expecting number but getting "..(type(height) or "nothing")..".")
 end
 if height ~= height then
  error("expecting number but getting NaN.")
 end
 if math.abs(height) == math.huge then
  error("you may not use a infinity number.")
 end
 height = math.floor(height)
y_meta = {
__index = function(_,key)
 if type(key) ~= "number" and key == key then
  error("x pos must be a number!")
 end
 if math.abs(key) == math.huge or key ~= key then
  key = 0
 end
 key = math.floor(key)
 if key < 1 or key >= width+1 then
  error("x pos is outta range")
 end
 return rawget(_,key)
end, __newindex = function(_,key,value)
 if type(key) ~= "number" and key == key then
  error("x pos must be a number!")
 end
 if math.abs(key) == math.huge or key ~= key then
  key = 0
 end
 key = math.floor(key)
 if key < 1 or key >= width+1 then
  error("x pos is outta range")
 end
 rawset(_,key,value)
end}
 local metatable = {width = width,height = height}
 for y = 1,height,1 do
  metatable[y] = {}
  for x = 1,width,1 do
   metatable[y][x] = nil
  end
  setmetatable(metatable[y],y_meta)
 end
 setmetatable(metatable,{
__index = function(_,key)
 if type(key) ~= "number" and key == key then
  return rawget(_,key)--error("y pos must be a number!")
 end
 if math.abs(key) == math.huge or key ~= key then
  key = 0
 end
 key = math.floor(key)
 if key < 1 or key >= width+1 then
  error("y pos is outta range")
 end
 return rawget(_,key)
end, __newindex = function(_,key,value)
 if type(key) ~= "number" and key == key then
  error("y pos must be a number!")
 end
 if math.abs(key) == math.huge or key ~= key then
  key = 0
 end
 key = math.floor(key)
 if key < 1 or key >= width+1 then
  error("y pos is outta range")
 end
 if type(value) ~= "table" then
  error("the value must be a array!")
 end
 local value2 = table.copy(value)
 setmetatable(value2,y_meta)
 rawset(_,key,value2)
end})
 return metatable
end
