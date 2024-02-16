pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- euclidean arp demo

#include util.p8.lua

#include ui.p8.lua
#include grid.p8.lua
#include audio.p8.lua
#include seq.p8.lua

function _init()
 ui_init()

 seq=seq_new(16)
 synth=synth_new()

 ui_add(toggle_new(
  0,0,2,3,
  function() return seq.playing end,
  function(x) seq:set_playing(x) end
 ))
 ui_add(note_grid_new())

 ui_add(num_spinner_new(
  16,0,15,3,60,200,0.2,1,
  function() return seq.bpm end,
  function(x) seq:set_tempo(x) end
 ))
 ui_add(label_new(30,0,6,'bpm'))

 ui_add(num_spinner_new(
  0,32,15,4,0,15,0.1,1,
  function() return seq.euclid_shift end,
  function(x) seq.euclid_shift=x seq:euclid_gen() end
 ))

 ui_add(num_spinner_new(
  16,32,15,4,0,16,0.1,1,
  function() return seq.euclid_pulses end,
  function(x) seq.euclid_pulses=x seq:euclid_gen() end
 ))
end

function _update60()
 ui_update()

 -- audio render
 while stat(108)<768 do
  local todo,trig,_,note=seq:run(96)

  if (trig) synth:play_note(note)

  local buf=synth:render(todo)
  for i=1,#buf do
   poke(0x7fff+i,(buf[i]*96+128)&-1)
  end
  serial(0x808,0x8000,todo)
 end
end

function _draw()
 cls()
 ui_draw()
end

__gfx__
0000000070000000003b000000330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000770000000033b00000bb3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000007770000000333b0000bbb300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000077770000003333b000bbbb30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000771100000033333000bbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000110000000033330000bbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000033300000bbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000033000000bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222220444444403333333011111110555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20000020400000403000003010000010500000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20000020400000403000003010000010500000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20000020400000403000003010000010500000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20000020400000403000003010000010500000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20000020400000403000003010000010500000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222220444444403333333011111110555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8888888099999990bbbbbbb0ccccccc0666666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8000028090000490b00003b0c00011c0600005600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8000008090000090b00000b0c00001c0600000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8000008090000090b00000b0c00000c0600000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8000008090000090b00000b0c00000c0600000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8000008090000090b00000b0c00000c0600000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8888888099999990bbbbbbb0ccccccc0666666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8888888099999990bbbbbbb0ccccccc0777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8222228094444490b33333b0c11111c0755555700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8222228094444490b33333b0c11111c0755555700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8222228094444490b33333b0c11111c0755555700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8222228094444490b33333b0c11111c0755555700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8222228094444490b33333b0c11111c0755555700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8888888099999990bbbbbbb0ccccccc0777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
