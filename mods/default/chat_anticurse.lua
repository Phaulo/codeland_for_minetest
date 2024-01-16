-- Codeland Lua Code: chat_anticurse
-- punish player for cursing by disconnecting them
--
--  Created in 2015 by Andrey. 
--  Updated in 2023 by Phaulo Riquelme.
--  This mod is Free and Open Source Software, released under the LGPL 2.1 or later.
-- 
-- See README.txt for more information.

local mode = minetest.settings:get("anticurse_mode")
local modname = "default"

local replace = dofile(minetest.get_modpath(modname).."/replace.lua")

chat_anticurse = {}
chat_anticurse.simplemask = {}
-- some english, some portuguese, some spanish and some russian curse words
-- i don't want to keep these words as cleartext in code, so they are stored like this.
local x1="a"
local x2="i"
local x3="u"
local x4="e"
local x5="o"
local x6="h"
local y1="y"
local y2="и"
local y3="о"
local y4="е"
local y5="я"

function chat_anticurse.register_simplemask(simplemask)
 if simplemask == nil then
  error("The Simplemask is missing")
 end
 if type(simplemask) ~= "string" then
  error("The Simplemask must be a String!")
 end
 chat_anticurse.simplemask[#chat_anticurse.simplemask+1] = simplemask
end
chat_anticurse.register_simplemask(" "..x1.."s" .. "s ")
chat_anticurse.register_simplemask("dumb"..x1.."s" .. "s ")
chat_anticurse.register_simplemask(" d" .. ""..x2.."ck")
chat_anticurse.register_simplemask(" p"..x4.."n" .. "is")
chat_anticurse.register_simplemask(" p" .. ""..x3.."ssy")
chat_anticurse.register_simplemask(" h"..x5.."" .. "r".."ny ")
chat_anticurse.register_simplemask(" b"..x2.."" .. "tch ")
chat_anticurse.register_simplemask(" b"..x2.."" .. "tch"..x4)
chat_anticurse.register_simplemask(" s"..x4.."" .. "x")
chat_anticurse.register_simplemask(" "..y4.."б" .. "а")
chat_anticurse.register_simplemask(" бл"..y5.."" .. " ")
chat_anticurse.register_simplemask(" ж" .. ""..y3.."п")
chat_anticurse.register_simplemask(" х" .. ""..y1.."й")
chat_anticurse.register_simplemask(" ч" .. "л"..y4.."н")
chat_anticurse.register_simplemask(" п"..y2.."" .. "зд")
chat_anticurse.register_simplemask(" в"..y3.."" .. "збуд")
chat_anticurse.register_simplemask(" в"..y3.."з" .. "б"..y1.."ж")
chat_anticurse.register_simplemask(" сп"..y4.."" .. "рм")
chat_anticurse.register_simplemask(" бл"..y5.."" .. "д")
chat_anticurse.register_simplemask(" бл"..y5.."" .. "ть")
chat_anticurse.register_simplemask(" с" .. ""..y4.."кс")
chat_anticurse.register_simplemask("f" .. ""..x3.."ck")
chat_anticurse.register_simplemask("s" .. ""..x6..x1.."t")
chat_anticurse.register_simplemask("wh" .. ""..x5.."r"..x4)
chat_anticurse.register_simplemask("d" .. ""..x1.."wn")
chat_anticurse.register_simplemask(""..x1.."rs"..x4.."h"..x5.."l"..x4.."")
chat_anticurse.register_simplemask(" c"..x3.."nt ")
chat_anticurse.register_simplemask(" c"..x3.." ")
local nh_pt_sp = {"nh","ñ"}
local e_pt_sp = {x4,x2..x4}
for i = 1,2 do
local z1 = e_pt_sp[i]
local z2 = nh_pt_sp[i]
chat_anticurse.register_simplemask("m" .. ""..z1.."" .. "rd" ..x1)
chat_anticurse.register_simplemask("m" .. ""..z1.."" .. "rd" ..x2..z2..x1)
chat_anticurse.register_simplemask("b" .. ""..x5.."" .. "st" ..x2..z2..x1)
chat_anticurse.register_simplemask("b" .. ""..x3.."md"..x2..z2..x1)
end
chat_anticurse.register_simplemask("b" .. ""..x5.."" .. "st" ..x1)
chat_anticurse.register_simplemask("b" .. ""..x5.."" .. "st" ..x2.."c"..x1)
chat_anticurse.register_simplemask("b" .. ""..x3.."md"..x1)
chat_anticurse.register_simplemask(" p" .. ""..x3.."t" .. x1)
chat_anticurse.register_simplemask(" p" .. ""..x5.."rr" .. x1)
chat_anticurse.register_simplemask("c" .. ""..x1.."g".. x1)
chat_anticurse.register_simplemask("c" .. ""..x1.."g".. x5)
chat_anticurse.register_simplemask("c" .. ""..x1.."g".. x3)

chat_anticurse.censor = function(text)
 text = " "..text.." "
 for k,v in pairs(replace) do
  text = text:gsub(k,v)
 end
 for i=1, #chat_anticurse.simplemask do
  if string.find(text, chat_anticurse.simplemask[i], 1, true) ~=nil then
   error("Censoring Failed. We're apparently with difficulty to finish the replacement list over here!")
  end
 end
 return text:sub(2,#text-1)
end

local detect_cussword = function(message)
 local checkingmessage=string.lower( " "..message .." " )
    for k,v in pairs(replace) do
        if string.find(checkingmessage, k, 1, true) ~=nil then
            return true
        end
    end
    
    return false
end

chat_anticurse.check_message = function(name, message)
 local checkingmessage=string.lower( name.." "..message .." " )
	local uncensored = 0
    for i=1, #chat_anticurse.simplemask do
        if string.find(checkingmessage, chat_anticurse.simplemask[i], 1, true) ~=nil then
            uncensored = 2
            break
        end
    end
    
    --additional checks
    if 
        string.find(checkingmessage, " c"..x3.."" .. "m ", 1, true) ~=nil and 
        not (string.find(checkingmessage, " c"..x3.."" .. "m " .. "se", 1, true) ~=nil) and
        not (string.find(checkingmessage, " c"..x3.."" .. "m " .. "to", 1, true) ~=nil)
    then
        uncensored = 2
    end
    return uncensored
end

minetest.register_on_chat_message(function(name, message)
    if mode == 2 then
        if detect_cussword(message) then
            for k,v in pairs(replace) do
                message = message:gsub(k,v)
            end
            minetest.chat_send_player(name, "Watch your language young boy!")
        end
    end
    local uncensored = chat_anticurse.check_message(name, message)
    if uncensored == 1 then
        minetest.kick_player(name, "Hey! Was there a bad word?")
        minetest.log("action", "Player "..name.." warned for cursing. Chat:"..message)
        return true
    end
    if uncensored == 2 then
        minetest.kick_player(name, "Cursing or words, inappropriate to game server. Kids may be playing here!")
        minetest.chat_send_all("Player "..name.." warned for cursing")
        minetest.log("action", "Player "..name.." warned for cursing. Chat:"..message)
        return true
    end
end)

if minetest.chatcommands["me"] then
    local old_command = minetest.chatcommands["me"].func
    minetest.chatcommands["me"].func = function(name, param)
    if mode == 2 then
        if detect_cussword(message) then
            for k,v in pairs(replace) do
                message = message:gsub(k,v)
            end
            minetest.chat_send_player(name, "Watch your language young boy!")
        end
    end
        local uncensored = chat_anticurse.check_message(name, param)
        if uncensored == 1 then
            minetest.kick_player(name, "Hey! Was there a bad word?")
            minetest.log("action", "Player "..name.." warned for cursing. Msg:"..param)
            return
        end
        if uncensored == 2 then
            minetest.kick_player(name, "Cursing or words, inappropriate to game server. Kids may be playing here!")
            minetest.chat_send_all("Player "..name.." warned for cursing")
            minetest.log("action", "Player "..name.." warned for cursing. Me:"..param)
            return
        end
        return old_command(name, param)
    end
end

if minetest.chatcommands["msg"] then
    local old_command = minetest.chatcommands["msg"].func
    minetest.chatcommands["msg"].func = function(name, param)
    if mode == 2 then
        if detect_cussword(message) then
            for k,v in pairs(replace) do
                message = message:gsub(k,v)
            end
            minetest.chat_send_player(name, "Watch your language young boy!")
        end
    end
        local uncensored = chat_anticurse.check_message(name, param)
        if uncensored == 1 then
            minetest.kick_player(name, "Hey! Was there a bad word?")
            minetest.log("action", "Player "..name.." warned for cursing. Msg:"..param)
            return
        end
        if uncensored == 2 then
            minetest.kick_player(name, "Cursing or words, inappropriate to game server. Kids may be playing here!")
            minetest.chat_send_all("Player "..name.." warned for cursing",name)
            minetest.log("action", "Player "..name.." warned for cursing. Msg:"..param)
            return
        end
        return old_command(name, param)
    end
end
