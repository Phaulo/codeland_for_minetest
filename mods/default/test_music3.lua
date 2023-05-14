local music = CODELAND.new_music(8,1,0)
local function pulse_sweep(note,reverse)
 if reverse then
  for i = 50,6.25,-6.25 do
   CODELAND.add_psg_note(music,nil,CODELAND.PSG.pulse[i],note,1)
  end
 else
  for i = 6.25,50,6.25 do
   CODELAND.add_psg_note(music,nil,CODELAND.PSG.pulse[i],note,1)
  end
 end
end
pulse_sweep(60,true)
pulse_sweep(60,false)
pulse_sweep(62,true)
pulse_sweep(62,false)
pulse_sweep(64,true)
pulse_sweep(64,false)
pulse_sweep(65,true)
pulse_sweep(67,false)
return CODELAND.new_music(8,1,nil,music.notes)
--[[
return {tempo=6,
        loopstart=1,
        loopend=16,
        notes={
         [1] = {{name="kick",note=60,channel=1}},
         [2] = {},
         [3] = {{name="hat",note=60,channel=2}},
         [4] = {{name="kick",note=60,channel=1}},
         [5] = {{name="snare",note=60,channel=3}},
         [6] = {},
         [7] = {{name="hat",note=60,channel=2}},
         [8] = {{name="snare",note=60,channel=3}},
         [9] = {},
         [10] = {{name="kick",note=60,channel=1}},
         [11] = {{name="kick",note=60,channel=1},{name="hat",note=60,channel=2}},
         [12] = {},
         [13] = {{name="snare",note=60,channel=3}},
         [14] = {},
         [15] = {{name="hat",note=60,channel=2}},
         [16] = {}
        }
       }
]]