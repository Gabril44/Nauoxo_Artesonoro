local ffi = require('ffi')
ffi.cdef[[
int MultiByteToWideChar(unsigned int, unsigned long, const char*, int, wchar_t*, int);
void* ShellExecuteW(void*, const wchar_t*, const wchar_t*, const wchar_t*, const wchar_t*, int);
unsigned long GetFileAttributesW(const wchar_t*);
]]
local shell = ffi.load('shell32')
local function wide(s)
  if not s then return nil end
  local n = ffi.C.MultiByteToWideChar(65001, 0, s, -1, nil, 0)
  local b = ffi.new('wchar_t[?]', n)
  ffi.C.MultiByteToWideChar(65001, 0, s, -1, b, n)
  return b
end
local base = love.filesystem.getSourceBaseDirectory():gsub('/', '\\')
local games = {
  {'Ñandú Runner', 'Acevedo Adrian', 'Acevedo Adrian'},
  {'El vuelo del ñandú', 'Acevedo Ramon', 'Acevedo Ramon'},
  {'Mira al cielo', 'Alosheguem na piguem', 'Alosheguem-na-piguem---Mira-al-Cielo-2-main/index.html', true},
  {'Memoria de cartas', 'Cartas', 'Cartas'},
  {'El ñandú del cielo', 'Juego web', 'EL--ANDU-main/index.html', true},
  {'Estrellas', 'Atrapa las estrellas', 'Estrellas'},
  {'El ñandú del cielo', 'Romero Mauro', 'Romero Mauro'},
}
local selected, status, cooldown = 1, 'Elegí un juego para comenzar.', 0
local fonts, cards = {}, {}
local testing = false
local banner
local leaves
local ornament
local petals, pending = {}, nil
local function menuCoords(x,y)
  local w,h=love.graphics.getDimensions()
  local s=math.min(w/1100,h/780)
  return (x-(w-1100*s)/2)/s,(y-(h-780*s)/2)/s
end
local function path(g) return base .. '\\juegos\\' .. g[3]:gsub('/', '\\') end
local function exists(p) return ffi.C.GetFileAttributesW(wide(p)) ~= 4294967295 end
local function launchNow()
  local g = games[selected]
  local target = path(g)
  if not exists(target .. (g[4] and '' or '\\main.lua')) then
    status = 'No se encontró el juego. Revisá la carpeta juegos.'; return
  end
  local exe = base .. '\\motor\\love.exe'
  if not g[4] and not exists(exe) then status = 'Falta motor/love.exe.'; return end
  local params = nil
  if not g[4] then params = wide('"' .. target .. '"') end
  if g[4] then
    local edge = 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe'
    if not exists(edge) then edge='C:\\Program Files\\Microsoft\\Edge\\Application\\msedge.exe' end
    if not exists(edge) then status='Se necesita Microsoft Edge para abrir este juego en pantalla completa.'; return end
    local url='file:///' .. target:gsub('\\','/'):gsub('[^%w%-%._~/:]',function(c) return string.format('%%%02X',string.byte(c)) end)
    love.filesystem.createDirectory('web-profile')
    params=wide('--app="'..url..'" --kiosk --edge-kiosk-type=fullscreen --no-first-run --no-default-browser-check --user-data-dir="'..love.filesystem.getSaveDirectory()..'/web-profile"')
    exe=edge
  end
  local result = shell.ShellExecuteW(nil, wide('open'), wide(exe),
    params, wide(base), 1)
  if tonumber(ffi.cast('intptr_t', result)) <= 32 then
    status = 'No se pudo abrir el juego. Revisá los archivos o el navegador.'
  else status = 'Abriendo ' .. g[1] .. '. Cerrá el juego para volver aquí.' end
  cooldown = 1
end
local function launch()
  if cooldown>0 or pending then return end
  pending=0.65
  local r=cards[selected]
  local x,y=r and r[1]+r[3]/2 or 550,r and r[2]+r[4]/2 or 390
  for i=1,65 do
    petals[#petals+1]={x=x,y=y,vx=love.math.random(-360,360),vy=love.math.random(-370,60),a=love.math.random()*6.28,spin=love.math.random(-5,5),life=1.4,size=love.math.random(5,12)}
  end
end
function love.load(args)
  banner = love.graphics.newImage('banner.png')
  leaves = love.graphics.newImage('hojitas.png')
  ornament = love.graphics.newImage('adorno.png')
  fonts.title = love.graphics.newFont(44)
  fonts.card = love.graphics.newFont(21)
  fonts.body = love.graphics.newFont(15)
  fonts.small = love.graphics.newFont(12)
  for _, a in ipairs(args or {}) do
    if a == '--self-test' then
      local ok, failures = true, {}
      for _, g in ipairs(games) do
        if not exists(path(g) .. (g[4] and '' or '\\main.lua')) then ok = false; table.insert(failures,g[3]) end
      end
      local f = io.open(base .. '\\verificacion.txt', 'w')
      f:write(ok and 'OK: 7 juegos encontrados; interfaz y fuentes cargadas.\n' or table.concat(failures,'\n')); f:close()
      if not ok then love.event.quit(1) else testing = true end
    end
  end
end
function love.update(dt)
  cooldown=math.max(0,cooldown-dt)
  for i=#petals,1,-1 do
    local p=petals[i];p.life=p.life-dt;p.x=p.x+p.vx*dt;p.y=p.y+p.vy*dt;p.vy=p.vy+360*dt;p.a=p.a+p.spin*dt
    if p.life<=0 then table.remove(petals,i) end
  end
  if pending then pending=pending-dt;if pending<=0 then pending=nil;launchNow() end end
end
local function color(r,g,b) love.graphics.setColor(r/255,g/255,b/255) end
local function foliage(x,y,width,angle,alpha)
  local scale = width/leaves:getWidth()
  love.graphics.setColor(1,1,1,alpha or 1)
  love.graphics.draw(leaves,x,y,angle or 0,scale,scale,leaves:getWidth()/2,leaves:getHeight()/2)
end
function love.draw()
  local actualW,actualH = love.graphics.getDimensions()
  local w,h=1100,780
  local scale=math.min(actualW/w,actualH/h)
  love.graphics.clear(69/255,113/255,52/255)
  love.graphics.push('all')
  love.graphics.translate((actualW-w*scale)/2,(actualH-h*scale)/2)
  love.graphics.scale(scale)
  foliage(113,108,145,-0.12)
  foliage(w-113,108,145,0.12)
  love.graphics.setColor(1,1,1)
  local bannerWidth = math.min(620,w-400)
  local bannerScale = bannerWidth/banner:getWidth()
  love.graphics.draw(banner,(w-bannerWidth)/2,8,0,bannerScale,bannerScale)
  color(237,245,230); love.graphics.setFont(fonts.small)
  love.graphics.print('CACIQUE PELAYO',36,46)
  love.graphics.print('NAUOXO',36,65)
  love.graphics.setFont(fonts.body)
  love.graphics.printf('Un encuentro para jugar y descubrir',0,119,w,'center')
  love.graphics.setFont(fonts.small)
  love.graphics.printf(#games .. ' JUEGOS',0,56,w-36,'right')
  local cw = (w-88)/2
  local ch = (h-242)/4
  cards = {}
  for i,g in ipairs(games) do
    local x = 36 + ((i-1)%2)*(cw+16)
    local y = 146 + math.floor((i-1)/2)*(ch+12)
    cards[i] = {x,y,cw,ch}
    if i == selected then color(27,70,76) else color(20,31,49) end
    love.graphics.rectangle('fill',x,y,cw,ch,12,12)
    foliage(x+cw-61,y+40,92,i%2 == 0 and 0.15 or -0.15,0.85)
    if i == selected then color(73,220,181); love.graphics.setLineWidth(2); love.graphics.rectangle('line',x,y,cw,ch,12,12) end
    color(73,220,181); love.graphics.setFont(fonts.small)
    love.graphics.print(string.format('%02d  /  %s', i, g[4] and 'WEB' or 'LUA · LÖVE'),x+18,y+13)
    color(242,246,255); love.graphics.setFont(fonts.card); love.graphics.print(g[1],x+18,y+33)
    color(162,182,202); love.graphics.setFont(fonts.body); love.graphics.print(g[2],x+18,y+61)
    if i == selected then color(73,220,181); love.graphics.printf('JUGAR  ›',x+10,y+ch-25,cw-28,'right') end
  end
  local ox = 36+cw+16+cw/2
  local oy = 146+3*(ch+12)+ch/2
  foliage(ox-cw/2+55,oy,90,-0.3)
  foliage(ox+cw/2-55,oy,90,0.3)
  local ornamentScale = math.min((cw-200)/ornament:getWidth(),(ch-24)/ornament:getHeight())
  love.graphics.setColor(1,1,1)
  love.graphics.draw(ornament,ox,oy,0,ornamentScale,ornamentScale,ornament:getWidth()/2,ornament:getHeight()/2)
  love.graphics.setFont(fonts.body); color(208,220,233); love.graphics.print(status,36,h-57)
  love.graphics.setFont(fonts.small); color(237,245,230)
  love.graphics.print('CLIC / ENTER: jugar     FLECHAS: elegir     F11: pantalla completa     ESC: salir',36,h-29)
  for _,p in ipairs(petals) do
    love.graphics.push()
    love.graphics.translate(p.x,p.y);love.graphics.rotate(p.a)
    love.graphics.setColor(235/255,137/255,141/255,math.min(1,p.life*2))
    love.graphics.ellipse('fill',0,0,p.size,p.size*0.48)
    love.graphics.pop()
  end
  love.graphics.pop()
  if testing then
    testing = false
    love.graphics.captureScreenshot(function(data)
      local png = data:encode('png')
      local file = assert(io.open(base .. '\\Vista-previa.png', 'wb'))
      file:write(png:getString()); file:close()
      love.event.quit(0)
    end)
  end
end
function love.keypressed(key)
  if pending then return end
  if key == 'escape' then love.event.quit()
  elseif key == 'return' or key == 'kpenter' then launch()
  elseif key == 'right' then selected = selected%#games+1
  elseif key == 'left' then selected = (selected-2)%#games+1
  elseif key == 'down' then selected = (selected+1)%#games+1
  elseif key == 'up' then selected = (selected-3)%#games+1
  elseif key == 'f11' then love.window.setFullscreen(not love.window.getFullscreen(), 'desktop') end
end
local function hit(x,y)
  for i,r in ipairs(cards) do if x>=r[1] and x<=r[1]+r[3] and y>=r[2] and y<=r[2]+r[4] then return i end end
end
function love.mousemoved(x,y) if pending then return end;local i=hit(menuCoords(x,y)); if i then selected=i end end
function love.mousepressed(x,y,b) if pending then return end;local i=hit(menuCoords(x,y)); if b==1 and i then selected=i; launch() end end

