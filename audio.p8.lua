function synth_new()
 local synth={
  amp=0,
  amp_decay=.999,
  phase=0,
  dphase=0
 }

 function synth:play_note(n)
  self.amp=0.8
  -- 11.8886 is approx 65536/5512.5
  self.dphase=2^(n/12)*261.63*11.8886
 end

 function synth:render(samples)
  local out={}
  local phase,dphase,amp,amp_decay=self.phase,self.dphase,self.amp,self.amp_decay
  for i=1,samples do
   out[i]=sin(phase>>>16)*amp
   phase+=dphase
   amp*=amp_decay
  end
  self.phase=phase
  self.dphase=dphase
  self.amp=amp
  return out
 end

 return synth
end
