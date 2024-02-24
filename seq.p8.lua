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
arp_names={
 'up',
 'down',
 'updn',
 'thmb',
 'pnky'
}

rep_type_names={
 'n=r|',
 'n=r>',
 'n>r|',
 'n>r>'
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
  -- see arps array for index meanings
  euclid_arp=1,
  euclid_note_reps=0,
  euclid_rep_del=1,
  -- 1: repeats keep note, repeats cut off
  -- 2: repeats keep note, repeats do not cut off
  -- 3: repeats change note, repeats cut off
  -- 4: repeats change note, repeats do not cut off
  euclid_rep_type=1,

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
  local new_gate=copy0(self.gate)

  -- place pulses and shift
  if self.euclid_pulses > 0 then
   for x=0,self.loop-1,self.loop/self.euclid_pulses do
    local idx=(flr(x)+self.euclid_shift)
    new_gate[idx%self.loop]=true
   end
  end

  -- invert pulses and build list
  local gate_list={}
  for i=0,self.loop-1 do
   if (self.euclid_inv>0) new_gate[i]=not new_gate[i]
   if (new_gate[i]) add(gate_list,i)
  end

  -- assign arp notes and add repeats
  local arp=arps[self.euclid_arp](self.euclid_notes)
  local arp_note
  local rep_change=(self.euclid_rep_type-1)\2>0
  local rep_overlap=(self.euclid_rep_type-1)%2>0
  for idx=1,#gate_list do
   local i=gate_list[idx]
   local i_next=gate_list[idx+1]
   local limit=min(self.loop-1,i+self.euclid_note_reps*self.euclid_rep_del)
   if (i_next and not rep_overlap) limit=min(limit,gate_list[idx+1])
   for j=i,limit,self.euclid_rep_del do
    if (j==i or rep_change) arp_note=arp()
    self.gate[j]=true
    self.note[j]=arp_note
   end
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
