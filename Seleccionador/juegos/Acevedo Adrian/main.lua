-- Shared display/input adapter. Original game code remains in juego.lua.
local cfg = require('tinkuy_config')
local gw, gh = cfg.width, cfg.height
local realDimensions = love.graphics.getDimensions
local realSetMode = love.window.setMode
local realMouse = love.mouse.getPosition
local realDown = love.keyboard.isDown
local held, pointers = {}, {}
local canvas, uiFont, original, test, frames
local function controlsLayout(w)
  if cfg.cards then return 0,0 end
  local columns=math.max(2,math.min(6,math.floor((w-24)/110)))
  columns=math.min(columns,#cfg.keys)
  return columns,math.ceil(#cfg.keys/columns)*60+16
end
local function layout()
  local w,h = realDimensions()
  local _,bottom = controlsLayout(w)
  local scale = math.min(w/gw,math.max(1,h-56-bottom)/gh)
  return w,h,scale,(w-gw*scale)/2,56+(h-56-bottom-gh*scale)/2
end
local function coords(x,y)
  local _,_,s,ox,oy = layout()
  return (x-ox)/s,(y-oy)/s
end
love.graphics.getDimensions = function() return gw,gh end
love.graphics.getWidth = function() return gw end
love.graphics.getHeight = function() return gh end
love.window.setMode = function() return true end
love.window.setFullscreen = function() return true end
love.mouse.getPosition = function() return coords(realMouse()) end
love.mouse.getX = function() local x = love.mouse.getPosition(); return x end
love.mouse.getY = function() local _,y = love.mouse.getPosition(); return y end
love.keyboard.isDown = function(...)
  for i=1,select('#',...) do if held[select(i,...)] then return true end end
  return realDown(...)
end
assert(love.filesystem.load('juego.lua'))()
original = {}
for _,name in ipairs({'load','draw','update','resize','keypressed','keyreleased','mousepressed','mousereleased','mousemoved'}) do original[name]=love[name] end
local function press(key)
  held[key] = (held[key] or 0)+1
  if original.keypressed then original.keypressed(key,key,false) end
end
local function release(key)
  if held[key] then held[key]=held[key]-1; if held[key]<=0 then held[key]=nil end end
  if original.keyreleased then original.keyreleased(key,key) end
end
local function buttons()
  local w,h=realDimensions()
  local result={{x=12,y=8,w=180,h=40,label='Volver a TINKUY',exit=true}}
  if not cfg.cards then
    local keys=cfg.keys
    local columns,bottom=controlsLayout(w)
    local bw=math.min(130,(w-24-(columns-1)*8)/columns)
    for i,key in ipairs(keys) do
      result[#result+1]={x=12+((i-1)%columns)*(bw+8),y=h-bottom+8+math.floor((i-1)/columns)*60,w=bw,h=52,key=key[1],label=key[2]}
    end
  end
  return result
end
local function hit(x,y)
  for _,b in ipairs(buttons()) do if x>=b.x and x<=b.x+b.w and y>=b.y and y<=b.y+b.h then return b end end
end
function love.load(args)
  frames=0
  for i,a in ipairs(args or {}) do
    if a=='--tinkuy-test' then test={w=tonumber(args[i+1]),h=tonumber(args[i+2]),out=args[i+3]} end
  end
  realSetMode(test and test.w or 0,test and test.h or 0,{fullscreen=not test,fullscreentype='desktop',resizable=true,minwidth=320,minheight=320})
  local dw,dh=realDimensions()
  if cfg.cards then gw,gh=dw,math.max(1,dh-56) end
  if original.load then original.load(args) end
  canvas=love.graphics.newCanvas(gw,gh)
  uiFont=love.graphics.newFont(15)
end
function love.resize(w,h)
  if cfg.cards and canvas then
    gw,gh=w,math.max(1,h-56)
    canvas:release()
    canvas=love.graphics.newCanvas(gw,gh)
    if original.resize then original.resize(gw,gh) end
  end
end
function love.update(dt)
  if original.update then original.update(math.min(dt,0.05)) end
  if test then
    frames=frames+1
    if frames==2 and not cfg.cards then press(cfg.start or 'space') end
    if frames==3 and not cfg.cards then release(cfg.start or 'space') end
    if frames==5 and cfg.cards and original.mousepressed then original.mousepressed(gw*0.4,gh*0.3,1) end
  end
end
function love.draw()
  love.graphics.push('all')
  love.graphics.setCanvas(canvas)
  love.graphics.origin()
  love.graphics.clear(love.graphics.getBackgroundColor())
  if original.draw then original.draw() end
  love.graphics.setCanvas()
  love.graphics.pop()
  love.graphics.push('all')
  love.graphics.origin()
  local w,h,s,ox,oy=layout()
  love.graphics.clear(0.035,0.055,0.08)
  love.graphics.setColor(1,1,1)
  love.graphics.draw(canvas,ox,oy,0,s,s)
  love.graphics.setFont(uiFont)
  for _,b in ipairs(buttons()) do
    love.graphics.setColor(0.27,0.44,0.20)
    if b.key and held[b.key] then love.graphics.setColor(0.91,0.52,0.55) end
    love.graphics.rectangle('fill',b.x,b.y,b.w,b.h,9,9)
    love.graphics.setColor(1,1,1)
    love.graphics.printf(b.label,b.x,b.y+(b.h-18)/2,b.w,'center')
  end
  if w>570 then love.graphics.setColor(0.9,0.9,0.9); love.graphics.print('ESC: volver al selector',210,20) end
  love.graphics.pop()
  if test and frames>=12 then
    local out=test.out
    local useEscape=test.w==800
    test=nil
    love.graphics.captureScreenshot(function(data)
      local f=assert(io.open(out,'wb')); f:write(data:encode('png'):getString()); f:close()
      if useEscape then love.keypressed('escape') else love.mousepressed(40,24,1,false) end
    end)
  end
end
function love.keypressed(key,scan,rep)
  if key=='escape' then love.event.quit(); return end
  if original.keypressed then original.keypressed(key,scan,rep) end
end
function love.keyreleased(key,scan) if original.keyreleased then original.keyreleased(key,scan) end end
local function pointerDown(id,x,y)
  local b=hit(x,y)
  if b then
    if b.exit then love.event.quit() else pointers[id]=b.key; press(b.key) end
    return
  end
  local gx,gy=coords(x,y)
  if gx>=0 and gx<=gw and gy>=0 and gy<=gh then
    pointers[id]='game'
    if original.mousepressed then original.mousepressed(gx,gy,1) end
  end
end
local function pointerUp(id,x,y)
  local key=pointers[id]; pointers[id]=nil
  if key=='game' then
    if original.mousereleased then local gx,gy=coords(x,y); original.mousereleased(gx,gy,1) end
  elseif key then release(key) end
end
function love.mousepressed(x,y,b,touch) if b==1 and not touch then pointerDown('mouse',x,y) end end
function love.mousereleased(x,y,b,touch) if b==1 and not touch then pointerUp('mouse',x,y) end end
function love.mousemoved(x,y,dx,dy)
  if original.mousemoved then local gx,gy=coords(x,y); local _,_,s=layout(); original.mousemoved(gx,gy,dx/s,dy/s) end
end
function love.touchpressed(id,x,y) pointerDown(id,x,y) end
function love.touchreleased(id,x,y) pointerUp(id,x,y) end
function love.focus(focused)
  if not focused then for id,key in pairs(pointers) do if key~='game' then release(key) end; pointers[id]=nil end end
end
