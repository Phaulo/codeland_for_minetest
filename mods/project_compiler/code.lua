CODELAND.bgcolor = {0,0,0} -- black hex color
CODELAND.FPS = 250
CODELAND.resolution = 2
local function get_path()
local minetestpath = minetest.get_modpath("default")
--[=[
minetestpath = CODELAND.explode("/",minetestpath)

minetestpath[#minetestpath] = nil
minetestpath[#minetestpath] = nil

return table.concat(minetestpath,"/")
]=]
return minetestpath:sub(1,#minetestpath-#("/mods/default"))
end
local ready = true
function main(time)
if time >= .25 then
 if ready then
  CODELAND.input(function(output)
if (not output) or (output and (#output <= 0)) then
 CODELAND.exit()
 ready = false
 return
end
local path = minetest.get_worldpath().."/"..output
   print("Creating Directory...")
   local success = minetest.mkdir(path)
   if success then
    print("Done")
   else
    print("Error Creating Directory")
return
   end
   print("Copying Files and Directories...")
   local success = minetest.mkdir(path.."/utils")
   if success then
    local file = io.open(path.."/utils/optimize_textures.sh","w")
if file then
 file:write([=[#!/bin/bash

# Colors with 0 alpha need to be preserved, because opaque leaves ignore alpha.
# For that purpose, the use of indexed colors is disabled (-nc).

find -name '../*.png' -print0 | xargs -0 optipng -o7 -zm1-9 -nc -strip all -clobber
]=])
file:close()
end
   else
    print("Error Copying File and Directories")
return
   end
   local success = minetest.mkdir(path.."/mods/default")
   if success then
minetest.cpdir(get_path().."/mods/default",path.."/mods/default")
local file = io.open(path.."/mods/default/compile.txt","w")
if file then
file:write(output)
file:close()
end
   else
    print("Error Copying File and Directories")
return
   end
   local success = minetest.mkdir(path.."/mods/"..output)
   if success then
minetest.cpdir(get_path().."/mods/"..output,path.."/mods/"..output)
   else
    print("Error Copying File and Directories")
return
   end
local file = io.open(path.."/minetest.conf","w")
if file then
file:write("dedicated_server_step = 0.002")
file:close()
   else
    print("Error Copying File and Directories")
return
end
local file = io.open(path.."/settingtypes.txt","w")
if file then
file:write([=[# This file contains settings of codeland that can be changed in
# minetest.conf

#    In creative mode players are able to dig all kind of blocks nearly
#    instantly, and have access to unlimited resources.
#    Some of the functionality is only available if this setting is present
#    at startup.
creative_mode (Creative mode) bool false

#    Upsample Images
upsample_images (Upsample Images) bool false

#    Safe Mode
#    Gives a Lagproof to your Codeland from Number of Sprites up to 22.
safe_mode (Safe Mode) bool true

#    Sprite Flickering
#    Make Sprites Flick only when the number is up to 22.
#    
#    Warning: Seizure
sprite_flickering (Sprite Flickering) bool true

#    Sprite Flickering Type
sprite_flickering_type (Sprite Flickering Type) enum by_order by_order,random

#    Sprite Limit
sprite_limit (Sprite Limit) int 18 2 21]=])
file:close()
   else
    print("Error Copying File and Directories")
return
end
local file = io.open(path.."/game.conf","w")
if file then
local uppercase = ""
local up = true
for i = 1,#output do
 local sub = output:sub(i,i)
 if sub == "_" then
  uppercase = uppercase.." "
  up = true
 else
  uppercase = uppercase .. (up and sub:upper() or sub)
  up = false
 end
end
file:write([=[disabled_settings = creative_mode, enable_damage
name       = ]=]..output..[=[ 
title       = ]=]..uppercase..[=[ 
description = Made with Codeland
allowed_mapgens = singlenode
moddable = false
map_persistent = false]=])
file:close()
   else
    print("Error Copying File and Directories")
return
end
print "Done!"
  end)
  ready = false
CODELAND.exit()
 end
end
end
