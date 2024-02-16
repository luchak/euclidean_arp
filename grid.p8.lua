LONG_PRESS_FRAMES=30

-- grid position is fixed
function grid_new(get_color, press)
 local function draw()
  local i=1
  for row=0,7 do
   for col=0,15 do
    local c=get_color(col,row)
    spr((1+c\5)*16+c%5,col*8,120-row*8)
   end
  end
 end

 local function mouse_up()
  local row=(128-mouse.y)\8
  local col=mouse.x\8
  if row>=0 and row<8 and col>=0 and col<16 then
   press(col,row,mouse.frames<LONG_PRESS_FRAMES)
  end
 end

 return widget_new(0,64,128,64,draw,{
  mouse_up=mouse_up
 })
end

function note_grid_new()
 return grid_new(
  function(col,row)
    if (seq.playing and seq.step==col) return 14
    if (seq.gate[col] and (seq.note[col]==row)) return 8
    return 4
  end,
  function(col,row,is_long)
   if seq.gate[col] and seq.note[col]==row then
    seq.gate[col]=false
   else
    seq.note[col]=row
    seq.gate[col]=true
   end
  end
 )
end
