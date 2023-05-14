local music = CODELAND.new_music(4,17,16)
CODELAND.add_note(music,nil,"vibraphone",60,1)
CODELAND.add_note(music,nil,"vibraphone",62,2)
CODELAND.add_note(music,nil,"vibraphone",64,3)
CODELAND.add_note(music,nil,"vibraphone",65,4)
CODELAND.add_note(music,nil,"vibraphone",67,5)
CODELAND.add_note(music,nil,"vibraphone",65,4)
CODELAND.add_note(music,nil,"vibraphone",64,3)
CODELAND.add_note(music,nil,"vibraphone",62,2)
CODELAND.add_note(music,nil,"vibraphone",60,1)
CODELAND.add_note(music,nil,"vibraphone",62,2)
CODELAND.add_note(music,nil,"vibraphone",64,3)
CODELAND.add_note(music,nil,"vibraphone",65,4)
CODELAND.add_note(music,nil,"vibraphone",67,5)
CODELAND.add_note(music,nil,"vibraphone",65,4)
CODELAND.add_note(music,nil,"vibraphone",64,3)
CODELAND.add_note(music,nil,"vibraphone",62,2)
return music
--[[
local notes = {}
table.insert(notes, {{name="vibraphone",note=60,channel=1}})
table.insert(notes, {{name="vibraphone",note=62,channel=2}})
table.insert(notes, {{name="vibraphone",note=64,channel=3}})
table.insert(notes, {{name="vibraphone",note=65,channel=4}})
table.insert(notes, {{name="vibraphone",note=67,channel=5}})
table.insert(notes, {{name="vibraphone",note=65,channel=4}})
table.insert(notes, {{name="vibraphone",note=64,channel=3}})
table.insert(notes, {{name="vibraphone",note=62,channel=2}})
table.insert(notes, {{name="vibraphone",note=60,channel=1}})
table.insert(notes, {{name="vibraphone",note=62,channel=2}})
table.insert(notes, {{name="vibraphone",note=64,channel=3}})
table.insert(notes, {{name="vibraphone",note=65,channel=4}})
table.insert(notes, {{name="vibraphone",note=67,channel=5}})
table.insert(notes, {{name="vibraphone",note=65,channel=4}})
table.insert(notes, {{name="vibraphone",note=64,channel=3}})
table.insert(notes, {{name="vibraphone",note=62,channel=2}})
return {tempo=4,
        loopstart=17,
        loopend=16,
        notes=notes
       }
]]