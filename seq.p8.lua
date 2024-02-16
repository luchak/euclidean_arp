function arp_up_new(notes)
 notes=copy(notes)
 sort(notes)

 local i=1
 return function()
  local out=notes[i]
  i=(i%#notes)+1
  return out
 end
end

function seq_new(length)
 local seq={
  length=length,
  gate={},
  note={},
  playing=false,
  step_pos=0,
  step_len=700,
  step=0,
  bpm=120,

  euclid_shift=0,
  euclid_pulses=0,

  euclid_notes={0,4,7,10},
  euclid_note_set=set({0,4,7,10})
 }

 for i=0,length-1 do
  seq.gate[i]=false
  seq.note[i]=0
 end

 function seq:set_playing(playing)
  if not playing then
   self.step_pos=0
   self.step=0
  end
  self.playing = playing
 end

 function seq:set_tempo(bpm)
  self.bpm=bpm
  self.step_len=(5512.5*(15/bpm)+.5)\1
 end

 function seq:run(length)
  if not self.playing then
   return length,false,false,self.note[self.step]
  end

  if self.step_pos>=self.step_len then
   self.step_pos=0
   self.step=(self.step+1)%self.length
  end
  local gate=self.gate[self.step]
  local trig=(self.step_pos==0) and gate
  local todo=min(self.step_len-self.step_pos,length)
  self.step_pos+=todo
  return todo,trig,self.gate[self.step],self.note[self.step]
 end

 function seq:euclid_gen()
  for i=0,self.length-1 do
   self.gate[i]=false
  end

  if (self.euclid_pulses==0) return
  if (#self.euclid_notes==0) return

  local arp=arp_up_new(self.euclid_notes)
  for x=0,self.length-1,self.length/self.euclid_pulses do
   local idx=((x+.5)\1+self.euclid_shift)%self.length
   self.gate[idx]=true
   self.note[idx]=arp()
  end
 end

 function seq:toggle_euclid_mask_note(note)
  if self.euclid_note_set[note] then
   del(self.euclid_notes,note)
  else
   add(self.euclid_notes,note)
  end
  self.euclid_note_set=set(self.euclid_notes)
  self:euclid_gen()
 end

 seq:set_tempo(120)
 return seq
end
