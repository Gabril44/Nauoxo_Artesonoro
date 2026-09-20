-- Nandu Runner en Lua usando LOVE2D (love2d.org)
-- Para correrlo: instala LOVE y ejecuta "love ." dentro de esta carpeta,
-- o arrastra la carpeta sobre el ejecutable de love.exe / love.app
--
-- El juego arranca en pantalla completa (usa la resolucion de tu monitor)
-- y todas las medidas se escalan proporcionalmente a partir de un diseno
-- pensado originalmente para 600x200.

-- Nombres de archivos de imagen del nandu (cambialos si los tuyos se llaman distinto)
local NANDU_RUN_1 = "nandu1.png"
local NANDU_RUN_2 = "nandu2.png"
local NANDU_JUMP  = "nandu3.png"

-- Nombres de archivos de imagen de los perros: un par de corrida por cada perro
local DOG_RUN_IMAGES = {
    { "perro1_a.png", "perro1_b.png" },
    { "perro2_a.png", "perro2_b.png" },
    { "perro3_a.png", "perro3_b.png" },
}
local PERRO_MORDER = "perro_morder.png" -- cuadro de mordida (compartido)
local LOGO_IMAGE = "fondo72.png" -- imagen que va en la esquina superior derecha

-- Colores del fondo tipo campo
local SKY_COLOR   = { 0.80, 0.87, 0.72 }
local GRASS_COLOR = { 0.45, 0.58, 0.27 }
local GRASS_LINE  = { 0.30, 0.42, 0.16 }

local WIDTH, HEIGHT
local SCALE
local GROUND_Y -- altura (en Y) donde apoyan los pies de los personajes

local images = {}
local ANIM_SPEED = 0.02 -- segundos entre cuadros al correr
local animTimer = 0
local animFrame = 1

local NUM_DOGS = 3
local dogs = {}

local dino
local obstacles
local speed
local score
local gameOver
local started
local spawnTimer
local biteDogIndex

local function newDog(index)
    return {
        x = 0, y = GROUND_Y,
        w = 24 * SCALE, h = 24 * SCALE,
        drawW = 30 * SCALE, drawH = 30 * SCALE,
        imgIndex = index,                      -- cual par de imagenes de corrida usa (1, 2 o 3)
        chaseOffset = (index - 1) * 20 * SCALE, -- cada perro un poco mas atras que el anterior
        animTimer = math.random() * 0.3,
        animFrame = math.random(1, 2),
    }
end

local function resetGame()
    local drawW, drawH = dino.drawW, dino.drawH
    dino = {
        x = WIDTH * 0.23, y = GROUND_Y - (drawH - 30 * SCALE), w = 30 * SCALE, h = 30 * SCALE,
        vy = 0, jumping = false,
        drawW = drawW, drawH = drawH
    }
    obstacles = {}
    speed = 250 * SCALE
    score = 0
    gameOver = false
    started = true
    spawnTimer = 0
    biteDogIndex = nil

    dogs = {}
    for i = 1, NUM_DOGS do
        dogs[i] = newDog(i)
    end
end

local function jump()
    if not started or gameOver then
        resetGame()
        return
    end
    if not dino.jumping then
        dino.vy = -520 * SCALE
        dino.jumping = true
    end
end

function love.load()
    love.window.setTitle("Nandu Runner")
    love.window.setMode(0, 0, { fullscreen = true, fullscreentype = "desktop" })
    WIDTH, HEIGHT = love.graphics.getDimensions()

    -- SCALE = 1 en una pantalla de referencia de 200px de alto (el diseno original)
    SCALE = HEIGHT / 200
    GROUND_Y = HEIGHT - 40 * SCALE

    images.run1 = love.graphics.newImage(NANDU_RUN_1)
    images.run2 = love.graphics.newImage(NANDU_RUN_2)
    images.jump = love.graphics.newImage(NANDU_JUMP)

    images.dogRun = {}
    for i, pair in ipairs(DOG_RUN_IMAGES) do
        images.dogRun[i] = {
            love.graphics.newImage(pair[1]),
            love.graphics.newImage(pair[2]),
        }
    end
    images.dogBite = love.graphics.newImage(PERRO_MORDER)
    images.logo = love.graphics.newImage(LOGO_IMAGE)

    love.graphics.setFont(love.graphics.newFont(14 * SCALE))

    local drawH = 40 * SCALE
    local drawW = drawH * (images.run1:getWidth() / images.run1:getHeight())

    started = false
    gameOver = false
    dino = {
        x = WIDTH * 0.23, y = GROUND_Y - (drawH - 30 * SCALE), w = 30 * SCALE, h = 30 * SCALE,
        vy = 0, jumping = false,
        drawW = drawW, drawH = drawH
    }
    obstacles = {}
    speed = 250 * SCALE
    score = 0
    spawnTimer = 0
    biteDogIndex = nil

    dogs = {}
    for i = 1, NUM_DOGS do
        dogs[i] = newDog(i)
    end

    love.graphics.setBackgroundColor(SKY_COLOR)
end

function love.keypressed(key)
    if key == "space" or key == "up" then
        jump()
    elseif key == "escape" then
        love.event.quit()
    end
end

function love.mousepressed()
    jump()
end

local function spawnObstacle()
    local h = (20 + math.random() * 20) * SCALE
    table.insert(obstacles, { x = WIDTH, y = GROUND_Y + 30 * SCALE - h, w = 15 * SCALE, h = h })
end

local function checkCollision(a, b)
    return a.x < b.x + b.w and a.x + a.w > b.x and a.y + a.h > b.y
end

function love.update(dt)
    if not started or gameOver then return end

    -- nandu: fisica de salto
    dino.vy = dino.vy + 1400 * SCALE * dt
    dino.y = dino.y + dino.vy * dt
    if dino.y > GROUND_Y then
        dino.y = GROUND_Y
        dino.vy = 0
        dino.jumping = false
    end

    -- animacion de correr del nandu
    if not dino.jumping then
        animTimer = animTimer + dt
        if animTimer >= ANIM_SPEED then
            animTimer = 0
            animFrame = animFrame == 1 and 2 or 1
        end
    end

    -- obstaculos (cuadraditos que hay que saltar)
    spawnTimer = spawnTimer + dt
    if spawnTimer > 1.5 then
        spawnTimer = 0
        spawnObstacle()
    end

    for i = #obstacles, 1, -1 do
        local o = obstacles[i]
        o.x = o.x - speed * dt
        if o.x + o.w < 0 then
            table.remove(obstacles, i)
        elseif checkCollision(dino, o) then
            gameOver = true
            biteDogIndex = 1 -- tropezo: los perros que lo seguian lo alcanzan
            dogs[1].x = dino.x -- lo alcanza justo donde choco
        end
    end

    -- perros: persiguen desde atras. la distancia se va achicando a medida
    -- que sube la velocidad, y si te alcanzan es game over (mordida)
    local chaseGap = math.max(20 * SCALE, 90 * SCALE - (speed - 250 * SCALE) * 0.5)

    for i, d in ipairs(dogs) do
        d.animTimer = d.animTimer + dt
        if d.animTimer >= ANIM_SPEED then
            d.animTimer = 0
            d.animFrame = d.animFrame == 1 and 2 or 1
        end

        if not gameOver then
            d.x = dino.x - chaseGap - d.chaseOffset
        end

        if not gameOver and checkCollision(dino, d) then
            gameOver = true
            biteDogIndex = i
        end
    end

    if not gameOver then
        score = score + dt * 10
        speed = speed + dt * 2 * SCALE
    end
end

local function drawNandu()
    local sprite
    if dino.jumping then
        sprite = images.jump
    else
        sprite = (animFrame == 1) and images.run1 or images.run2
    end
    local scaleX = dino.drawW / sprite:getWidth()
    local scaleY = dino.drawH / sprite:getHeight()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(sprite, dino.x, dino.y - (dino.drawH - dino.h), 0, scaleX, scaleY)
end

local function drawDog(d, isBiting)
    if d.x + d.drawW < 0 or d.x > WIDTH then return end

    local sprite
    local drawW = d.drawW
    local drawH = d.drawH

    if isBiting then
        sprite = images.dogBite

        -- Perro de mordida un poco más grande
        drawW = drawW * 2.20
        drawH = drawH * 2.20
    else
        local pair = images.dogRun[d.imgIndex]
        sprite = (d.animFrame == 1) and pair[1] or pair[2]
    end

    local scaleX = drawW / sprite:getWidth()
    local scaleY = drawH / sprite:getHeight()

    love.graphics.setColor(1, 1, 1)

    -- Mantiene los pies aproximadamente en el mismo lugar
    local drawY = d.y - (drawH - d.h) + 20 * SCALE


    love.graphics.draw(sprite, d.x, drawY, 0, scaleX, scaleY)
end


function love.draw()
    -- pasto
    love.graphics.setColor(GRASS_COLOR)
    love.graphics.rectangle(
        "fill",
        0,
        GROUND_Y + 30 * SCALE,
        WIDTH,
        HEIGHT - (GROUND_Y + 30 * SCALE)
    )

    -- linea de horizonte
    love.graphics.setColor(GRASS_LINE)
    love.graphics.setLineWidth(2 * SCALE)
    love.graphics.line(
        0,
        GROUND_Y + 30 * SCALE,
        WIDTH,
        GROUND_Y + 30 * SCALE
    )
    love.graphics.setLineWidth(1)

    -- Perros normales: se dibujan primero
    for i, d in ipairs(dogs) do
        if not (gameOver and biteDogIndex == i) then
            drawDog(d, false)
        end
    end

    -- obstaculos
    love.graphics.setColor(0.18, 0.49, 0.2)
    for _, o in ipairs(obstacles) do
        love.graphics.rectangle("fill", o.x, o.y, o.w, o.h)
    end

    -- ÑANDÚ: siempre se dibuja, incluso durante GAME OVER
    drawNandu()

    -- Perro que muerde: se dibuja DESPUÉS del ñandú,
    -- así queda delante de él
    if gameOver and biteDogIndex then
        drawDog(dogs[biteDogIndex], true)
    end

    -- puntaje
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.print(
        "Puntaje: " .. math.floor(score),
        15 * SCALE,
        15 * SCALE
    )

    -- logo en la esquina superior derecha
    do
        local logoH = 60 * SCALE
        local logoScale = logoH / images.logo:getHeight()
        local logoW = images.logo:getWidth() * logoScale

        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(
            images.logo,
            WIDTH - logoW - 15 * SCALE,
            15 * SCALE,
            0,
            logoScale,
            logoScale
        )
    end

    if not started then
        love.graphics.printf(
            "Presiona ESPACIO para empezar",
            0,
            HEIGHT * 0.45,
            WIDTH,
            "center"
        )
    elseif gameOver then
        love.graphics.printf(
            "Los perros lo alcanzaron - GAME OVER - ESPACIO para reiniciar",
            0,
            HEIGHT * 0.45,
            WIDTH,
            "center"
        )
    end
end
