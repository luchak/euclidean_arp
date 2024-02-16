function pbstep(rp)
 return rp+rp-((rp*rp+1)^^(rp>>31))
end

function synth_new()
 local synth={
  amp=0,
  amp_decay=.9995,
  phase=0,
  dphase=0,
  f1=0,
  f2=0,
  fmod=0,
  fmod_decay=.9995
 }

 function synth:play_note(n)
  self.amp=0.8
  self.fmod=1
  -- 11.8886 is approx 65536/5512.5
  self.dphase=2^(n/12)*130.813*11.8886
 end

 function synth:render(samples)
  local out={}
  local phase,dphase,amp,amp_decay,f1,f2,fmod,fmod_decay=self.phase,self.dphase,self.amp,self.amp_decay,self.f1,self.f2,self.fmod,self.fmod_decay
  for i=1,samples do
   local fc=0.4*fmod
   local pr=phase+0x8000
   local osc=amp*((phase>>15)-((pr^^(pr>>31))<dphase and pbstep(pr/dphase) or 0))
   osc-=4*(f2-osc)
   f1+=fc*(osc-f1)
   f2+=fc*(f1-f2)
   out[i]=f2
   phase+=dphase
   amp*=amp_decay
   fmod*=fmod_decay
  end
  self.phase=phase
  self.dphase=dphase
  self.amp=amp
  self.f1=f1
  self.f2=f2
  self.fmod=fmod
  return out
 end

 return synth
end
