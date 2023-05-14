local music = CODELAND.new_music(8,1,0)
CODELAND.add_psg_note(music,nil,CODELAND.PSG.noise,CODELAND.time_to_note(.25),1)
CODELAND.add_psg_note(music,nil,CODELAND.PSG.noise,-1,1)
CODELAND.add_psg_note(music,nil,CODELAND.PSG.noise,CODELAND.time_to_note(2),1)
CODELAND.add_psg_note(music,nil,CODELAND.PSG.noise,CODELAND.time_to_note(.25),1)
CODELAND.add_psg_note(music,nil,CODELAND.PSG.noise,CODELAND.time_to_note(.75),1)
CODELAND.add_psg_note(music,nil,CODELAND.PSG.noise,-1,1)
CODELAND.add_psg_note(music,nil,CODELAND.PSG.noise,CODELAND.time_to_note(2),1)
CODELAND.add_psg_note(music,nil,CODELAND.PSG.noise,CODELAND.time_to_note(.75),1)
CODELAND.add_psg_note(music,nil,CODELAND.PSG.noise,-1,1)
CODELAND.add_psg_note(music,nil,CODELAND.PSG.noise,CODELAND.time_to_note(.25),1)
CODELAND.add_psg_note(music,CODELAND.add_psg_note(music,nil,CODELAND.PSG.noise,CODELAND.time_to_note(.25),2),CODELAND.PSG.noise,CODELAND.time_to_note(2),1)
CODELAND.add_psg_note(music,CODELAND.add_psg_note(music,nil,CODELAND.PSG.noise,-1,2),CODELAND.PSG.noise,-1,1)
CODELAND.add_psg_note(music,nil,CODELAND.PSG.noise,CODELAND.time_to_note(.75),1)
CODELAND.add_psg_note(music,nil,CODELAND.PSG.noise,-1,1)
CODELAND.add_psg_note(music,nil,CODELAND.PSG.noise,CODELAND.time_to_note(2),1)
CODELAND.add_psg_note(music,nil,CODELAND.PSG.noise,-1,1)
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