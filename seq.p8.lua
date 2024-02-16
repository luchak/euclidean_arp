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
  scale={0,1,3,5,7,8,10,12}
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
   return length,false,false,self.scale[1+self.note[self.step]]
  end

  if self.step_pos>=self.step_len then
   self.step_pos=0
   self.step=(self.step+1)%self.length
  end
  local gate=self.gate[self.step]
  local trig=(self.step_pos==0) and gate
  local todo=min(self.step_len-self.step_pos,length)
  self.step_pos+=todo
  return todo,trig,self.gate[self.step],self.scale[1+self.note[self.step]]
 end

 seq:set_tempo(120)
 return seq
end
