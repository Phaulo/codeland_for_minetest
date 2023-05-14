local music = CODELAND.new_music(6,1,0)
CODELAND.add_note(music,nil,"kick",60,1)
CODELAND.add_rest(music)
CODELAND.add_note(music,nil,"hat",60,2)
CODELAND.add_note(music,nil,"kick",60,1)
CODELAND.add_note(music,nil,"snare",60,3)
CODELAND.add_rest(music)
CODELAND.add_note(music,nil,"hat",60,2)
CODELAND.add_note(music,nil,"snare",60,3)
CODELAND.add_rest(music)
CODELAND.add_note(music,nil,"kick",60,1)
CODELAND.add_note(music,CODELAND.add_note(music,nil,"kick",60,1),"hat",60,2)
CODELAND.add_rest(music)
CODELAND.add_note(music,nil,"snare",60,3)
CODELAND.add_rest(music)
CODELAND.add_note(music,nil,"hat",60,2)
CODELAND.add_rest(music)
return CODELAND.new_music(6,1,nil,music.notes)
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