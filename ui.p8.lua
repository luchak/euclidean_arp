function ui_init()
 widgets={}

 mouse={
  x=0,
  y=0,
  b=0,
  dy=0
 }

 mouse_locked=false

 -- enable mouse
 poke(0x5f2d,1)
end

function ui_draw()
 for w in all(widgets) do
  w:draw()
 end

 spr(1,mouse.x,mouse.y)
end

function ui_update()
 local mx,my=stat(32),stat(33)
 last_mouse=mouse
 mouse={
  x=mid(mx,127),
  y=mid(my,127),
  b=stat(34),
  -- dy is in host pixels i believe
  dy=stat(39) or 4*(my-last_mouse.y),
  frames=last_mouse.frames and min(last_mouse.frames+1,0x7fff),
  tgt=last_mouse.tgt,
 }

 if mouse.tgt then
  if mouse.b==0 then
   mouse.tgt.mouse_up()
   mouse.tgt=nil
  else
   mouse.tgt.mouse_move()
  end
 else
  if mouse.b>0 then
   for w in all(widgets) do
    if w:hit(mouse.x,mouse.y) then
     w.mouse_down()
     mouse.tgt=w
     mouse.frames=0
     break
    end
   end
  end
 end
end

function ui_add(widget)
 add(widgets, widget)
end

function ui_lock_mouse()
 poke(0x5f2d,5)
 mouse_locked=true
end

function ui_unlock_mouse()
 poke(0x5f2d,1)
 mouse_locked=false
end

function widget_new(x,y,w,h,draw,handlers)
 handlers=handlers or {}
 local widget={
  x=x,
  y=y,
  w=w,
  h=h,
  draw=draw,
  mouse_up=handlers.mouse_up or never,
  mouse_down=handlers.mouse_down or never,
  mouse_move=handlers.mouse_move or never,
 }

 function widget:hit(x,y)
  return x>=self.x and x<self.x+self.w and y>=self.y and y<self.y+self.h
 end

 return widget
end

function label_new(x,y,col,text)
 return widget_new(
  x,y,#text*4,8,
  function()
   print(text,x,y+1,col)
  end
 )
end

function toggle_new(x,y,spr_off,spr_on,get,set)
 return widget_new(x,y,8,8,
  function()
   spr(get() and spr_on or spr_off,x,y)
  end,
  {
   mouse_down=function()
    set(not get())
   end
  }
 )
end

function num_spinner_new(x,y,col,digits,min_val,max_val,sens,step,get,set)
 local drag_val
 return widget_new(x,y,digits*4,8,
  function()
   local s=tostr(get())
   print(s,x+4*max(digits-#s),y+1,col)
   --print(get())
  end,
  {
   mouse_down=function()
    ui_lock_mouse()
    drag_val=get()
   end,
   mouse_move=function()
    if mouse.dy != 0 then
     drag_val=mid(min_val,max_val,drag_val-mouse.dy*sens)
     set(drag_val\step*step)
    end
   end,
   mouse_up=function()
    ui_unlock_mouse()
   end,
  }
 )
end

