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

function arp_down_new(notes)
 notes=copy(notes)
 sort(notes)

 local i=#notes
 return function()
  local out=notes[i]
  i=i-1
  if (i<1) i=#notes
  return out
 end
end

function arp_up_down_new(notes)
 notes=copy(notes)
 sort(notes)

 local i=1
 local di=1
 return function()
  local out=notes[i]
  i+=di
  if (i<1 or i>#notes) di=-di i=mid(1,i,#notes) i+=di
  return out
 end
end

function arp_thumb_new(notes)
 notes=copy(notes)
 sort(notes)

 local i=2
 local parity=false
 return function()
  local out=notes[1]
  if #notes>1 and parity then
   out=notes[i]
   i+=1
   if (i>#notes) i=2
  end
  parity=not parity
  return out
 end
end

function arp_pinky_new(notes)
 notes=copy(notes)
 sort(notes)

 local i=1
 local parity=false
 return function()
  local out=notes[#notes]
  if #notes>1 and parity then
   out=notes[i]
   i+=1
   if (i>#notes-1) i=1
  end
  parity=not parity
  return out
 end
end

arps={
 arp_up_new,
 arp_down_new,
 arp_up_down_new,
 arp_thumb_new,
 arp_pinky_new,
}

function seq_new(length)
 local seq={
  length=length,
  loop=16,
  gate={},
  note={},
  playing=false,
  step_pos=0,
  step_len=700,
  step=0,
  bpm=120,

  euclid_shift=0,
  euclid_pulses=0,
  euclid_len=16,
  euclid_inv=0,
  euclid_arp=1,

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

 function seq:set_loop(loop)
  self.loop=loop
 end

 function seq:run(length)
  if not self.playing then
   return length,false,false,self.note[self.step]
  end

  if self.step_pos>=self.step_len then
   self.step_pos=0
   self.step=(self.step+1)%self.loop
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

  if (#self.euclid_notes==0) return

  self.loop=self.euclid_len

  if self.euclid_pulses > 0 then
   for x=0,self.loop-1,self.loop/self.euclid_pulses do
    local idx=((x+.5)\1+self.euclid_shift)%self.loop
    self.gate[idx]=true
   end
  end

  local arp=arps[self.euclid_arp](self.euclid_notes)
  for i=0,self.loop-1 do
   if (self.euclid_inv>0) self.gate[i]=not self.gate[i]

   if (self.gate[i]) self.note[i]=arp()
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
