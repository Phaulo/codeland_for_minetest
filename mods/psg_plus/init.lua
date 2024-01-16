addons["psg_plus"] = true
local psg = {}
local psg_fade = {}
local psg_fade_pitch = {}
local psg_vol = {}
local psg_pitch = {}
local psg_waveform = {}
local psg_vol_old = {}
local psg_pitch_old = {}
local psg_waveform_old = {}
local psg_playing = {}
local psg_pitch_adjust = 0.975
for i = 1,16 do
 psg[i] = -1
 psg_fade[i] = nil
 psg_fade_pitch[i] = nil
 psg_vol[i] = 0
 psg_pitch[i] = 0
 psg_waveform[i] = 0
 psg_vol_old[i] = 0
 psg_pitch_old[i] = 0
 psg_waveform_old[i] = 0
 psg_playing[i] = false
end
local time = 0
local current_name;
local psg_waveforms = {
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
function CODELAND.play_psg(id,channel,pitch,gain)
if channel < 1 or channel > 16 then
error("channel provided ("..channel..") is outside the range [1, 16]")
end
 psg_fade[channel] = nil
 psg_fade_pitch[channel] = nil
 psg_vol[channel] = math.min(math.max(gain or .5,0.0005),1)
 psg_pitch[channel] = pitch
 psg_waveform[channel] = math.min(math.max(id,1),12)
 psg_playing[channel] = true
 if psg[channel] then
  minetest.sound_stop(psg[channel])
 end
 psg[channel] = -1
 return true
end
function CODELAND.stop_psg(channel)
if channel < 1 or channel > 16 then
error("channel provided ("..channel..") is outside the range [1, 16]")
end
 if not psg_playing[channel] then
  return false
 end
 psg_fade[channel] = nil
 psg_fade_pitch[channel] = nil
 psg_vol[channel] = 0
 psg_pitch[channel] = 0
 psg_waveform[channel] = 0
 psg_playing[channel] = false
 return true
end
function CODELAND.fade_psg(channel,secs,volume)
if channel < 1 or channel > 16 then
error("channel provided ("..channel..") is outside the range [1, 16]")
end
 if psg_playing[channel] then
  psg_fade[channel] = {start = psg_vol[channel], endi = math.min(math.max((volume or 0)/100,0.0005),1), time = 0, secs = secs}
  return true
 end
 return false
end
function CODELAND.fade_pitch_psg(channel,secs,pitch)
if channel < 1 or channel > 16 then
error("channel provided ("..channel..") is outside the range [1, 16]")
end
 if psg_playing[channel] then
  psg_fade_pitch[channel] = {start = psg_pitch[channel], endi = pitch or 1, time = 0, secs = secs or 1}
  return true
 end
 return false
end
function CODELAND.set_psg_volume(channel,volume,stop_fade)
if channel < 1 or channel > 16 then
error("channel provided ("..channel..") is outside the range [1, 16]")
end
 if psg_playing[channel] then
  psg_vol[channel] = math.min(math.max((volume or 0)/100,0.0005),1)
  if stop_fade then
   psg_fade[channel] = nil
  elseif psg_fade[channel] then
   psg_fade[channel] = {start = math.min(math.max((volume or 0)/100,0.0005),1), endi = psg_fade[channel].endi, time = psg_fade[channel].time, secs = psg_fade[channel].secs}
  end
  return true
 end
 return false
end
function CODELAND.set_psg_pitch(channel,pitch,stop_fade)
if channel < 1 or channel > 16 then
error("channel provided ("..channel..") is outside the range [1, 16]")
end
 if psg_playing[channel] then
  psg_pitch[channel] = pitch or 1
  if stop_fade then
   psg_fade_pitch[channel] = nil
  elseif psg_fade[channel] then
   psg_fade_pitch[channel] = {start = pitch or 1, endi = psg_fade_pitch[channel].endi, time = psg_fade_pitch[channel].time, secs = psg_fade_pitch[channel].secs}
  end
  return true
 end
 return false
end
function CODELAND.set_psg_waveform(channel,waveform)
if channel < 1 or channel > 16 then
error("channel provided ("..channel..") is outside the range [1, 16]")
end
 if psg_playing[channel] then
  psg_waveform[channel] = math.min(math.max(waveform,1),12)
  return true
 end
 return false
end
function CODELAND.stop_all_psg()
 for channel = 1,16,1 do
  if psg_playing[channel] then
   psg_fade[channel] = nil
   psg_fade_pitch[channel] = nil
   psg_vol[channel] = 0
   psg_pitch[channel] = 0
   psg_waveform[channel] = 0
   psg_playing[channel] = false
  end
 end
end
function CODELAND.add_pitch_fading_psg_note(music,time,id,note,channel,gain,secs,pitch)
 time = time or (#music.notes+1)
 if not music.notes[time] then
  music.notes[time] = {}
 end
 music.notes[time][#music.notes[time]+1] = {waveform=id,note=note,channel=channel,type="psg",gain=gain,pitch_fade={secs=secs,pitch=pitch}}
 return time
end
function CODELAND.add_psg_pitch_fading(music,time,channel,secs,pitch)
 time = time or (#music.notes+1)
 if not music.notes[time] then
  music.notes[time] = {}
 end
 music.notes[time][#music.notes[time]+1] = {channel=channel,type="psg_pitch_fade",secs=secs,pitch=pitch}
 return time
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
 function music:add_fading_note(time,name,note,channel,gain,secs,vol)
  return CODELAND.add_fading_note(self,time,name,note,channel,gain,secs,vol)
 end
 function music:add_fading_psg_note(time,id,note,channel,gain,secs,vol)
  return CODELAND.add_fading_psg_note(self,time,id,note,channel,gain,secs,vol)
 end
 function music:add_pitch_fading_psg_note(time,id,note,channel,gain,secs,vol)
  return CODELAND.add_pitch_fading_psg_note(self,time,id,note,channel,gain,secs,vol)
 end
 function music:add_fading(time,channel,secs,vol)
  return CODELAND.add_fading(self,time,channel,secs,vol)
 end
 function music:add_psg_fading(time,channel,secs,vol)
  return CODELAND.add_psg_fading(self,time,channel,secs,vol)
 end
 function music:add_psg_pitch_fading(time,channel,secs,vol)
  return CODELAND.add_psg_pitch_fading(self,time,channel,secs,vol)
 end
 function music:get_size()
  return CODELAND.music_size(self)
 end
 return music
end

minetest.register_globalstep(function(dtime)
 local name2 = minetest.settings:get("name") or "singleplayer"
 if minetest.is_singleplayer() then
  name2 = "singleplayer"
 end
 current_name = nil
 for _,player in ipairs(minetest.get_connected_players()) do
  local name = player:get_player_name() or "singleplayer"
  if name == name2 then
   current_name = name
  end
 end
 for i = 1,16 do
  if psg_fade[i] then
   local x = math.min((psg_fade[i].time)/psg_fade[i].secs,1)^2
   psg_vol[i] = (psg_fade[i].start*(1-x))+(psg_fade[i].endi*x)
   if psg_fade[i].time >= psg_fade[i].secs then
    psg_vol[i] = psg_fade[i].endi
    psg_fade[i] = nil
   else
    psg_fade[i].time = psg_fade[i].time+dtime
   end
  end
  if psg_fade_pitch[i] then
   local x = math.min((psg_fade_pitch[i].time)/psg_fade_pitch[i].secs,1)
   psg_pitch[i] = (psg_fade_pitch[i].start*(1-x))+(psg_fade_pitch[i].endi*x)
   if psg_fade_pitch[i].time >= psg_fade_pitch[i].secs then
    psg_pitch[i] = psg_fade_pitch[i].endi
    psg_fade_pitch[i] = nil
   else
    psg_fade_pitch[i].time = psg_fade_pitch[i].time+dtime
   end
  end
  if not psg_waveforms[psg_waveform[i]] then
   psg_playing[i] = false
   if psg[i] > -1 then
    minetest.sound_stop(psg[i])
   end
   psg[i] = -1
  end
  if psg[i] > -1 then
   if (psg_pitch[i] ~= psg_pitch_old[i] or psg_waveform[i] ~= psg_waveform_old[i]) then
    minetest.sound_stop(psg[i])
    psg[i] = minetest.sound_play(psg_waveforms[psg_waveform[i]],{gain=math.max(math.min(psg_vol[i],1),0.0005),loop=true,pitch=psg_pitch[i]*psg_pitch_adjust*(psg_waveform[i] == 12 and 4 or 1),to_player=current_name}) or -1
   elseif psg_vol[i] ~= psg_vol_old[i] then
    minetest.sound_fade(psg[i],100,math.max(math.min(psg_vol[i],1),0.0005))
   end
  end
  if psg_waveforms[psg_waveform[i]] then
   if psg[i] <= -1 then
    psg[i] = minetest.sound_play(psg_waveforms[psg_waveform[i]],{gain=math.max(math.min(psg_vol[i],1),0.0005),loop=true,pitch=psg_pitch[i]*psg_pitch_adjust*(psg_waveform[i] == 12 and 4 or 1),to_player=current_name}) or -1
   end
  end
  psg_vol_old[i] = psg_vol[i]
  psg_pitch_old[i] = psg_pitch[i]
  psg_waveform_old[i] = psg_waveform[i]
 end
 time=time+dtime
end)
