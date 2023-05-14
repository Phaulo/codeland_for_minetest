dofile(minetest.get_modpath("default").."/chat_anticurse.lua")
local file = io.open(minetest.get_modpath("default").."/compile.txt","r")
if file then
local str = file:read("*a")
local nerror, msg = pcall(minetest.get_modpath,str)
if nerror then
_COMPILED = true
_COMPILED_PRJ = str
else
file:close()
error("Error Entering Project: "..msg)
return
end
file:close()
end
local nerror,msg = pcall(dofile,minetest.get_modpath("default").."/source.lua")
if not nerror then
error(msg)
end
