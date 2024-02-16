function always()
 return true
end

function never()
 return false
end

function log(...)
 for arg in all({...}) do
  printh(tostr(arg)..' \0','log')
 end
 printh('','log')
end

function join(a,sep)
 local out=''
 for i=1,#a-1 do
  out..=tostr(a[i])..sep
 end
 if (#a>=1) out..=a[#a]
 return out
end

function copy(a)
 local out={}
 for i=1,#a do
  out[i]=a[i]
 end
 return out
end

function sort(a)
 for i=1,#a do
  for j=i+1,#a do
   if (a[i]>a[j]) a[i],a[j]=a[j],a[i]
  end
 end
end

function set(a)
 local out={}
 for i=1,#a do
  out[a[i]]=true
 end
 return out
end
