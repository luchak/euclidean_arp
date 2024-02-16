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
