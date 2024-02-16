function ui_init()
 widgets={}

 mouse={
  x=0,
  y=0,
  b=0
 }

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
 last_mouse=mouse
 mouse={
  x=mid(stat(32),127),
  y=mid(stat(33),127),
  b=stat(34),
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

function widget_new(x,y,w,h,draw,handlers)
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

function num_spinner_new(x,y,col,min_val,max_val,sens,get,set)
 return widget_new(x,y,8,8,
  function()
   print(get(),x,y,col)
  end,
  {
   drag_start=function()
   end,
   drag=function()
    set(not get())
   end,
   drag_end=function()
   end,
  }
 )
end
