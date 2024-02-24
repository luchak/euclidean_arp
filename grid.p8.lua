LONG_PRESS_FRAMES=30
BLACK_KEYS=set({1,3,6,8,10})

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
 local note_grid=grid_new(
  function(col,row)
    col+=grid_page*16
    local note_row=row+grid_trans-36
    if (seq.playing and seq.step==col) return 14
    if seq.gate[col] then
     local note=seq.note[col]
     if (note==note_row) return 8
     if (row==0 and note<grid_trans-36) return 5
     if (row==7 and note>=grid_trans-28) return 5
    end
    return 4
  end,
  function(col,row,is_long)
   col+=grid_page*16
   local note_row=row+grid_trans-36
   if seq.gate[col] and seq.note[col]==note_row then
    seq.gate[col]=false
   else
    seq.note[col]=note_row
    seq.gate[col]=true
   end
  end
 )
 return note_grid
end

function euclid_mask_grid_new()
 local function mask_to_grid(x)
  return x%12,x\12*16+3
 end

 local function grid_to_mask(col,row)
  return (row-3)*12+col
 end

 return grid_new(
  function(col,row)
    if (col>=12) return 4
    local c=BLACK_KEYS[col] and 0 or 1
    local idx=row*12+col
    if (idx>=grid_trans and idx<grid_trans+8) c+=5
    if (seq.euclid_note_set[grid_to_mask(col,row)]) c=13
    return c
  end,
  function(col,row,is_long)
   if (col<12) seq:toggle_euclid_mask_note(grid_to_mask(col,row))
  end
 )
end
