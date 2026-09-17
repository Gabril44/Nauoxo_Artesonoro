local gameState = "menu" -- "menu", "playing", "gameover", "story_menu", "story_view"

local screenWidth, screenHeight = 800, 600

-- Jugador (canasta)
local playerBaseWidth = 90
local playerBaseSpeed = 420
local player = {
    width = playerBaseWidth,
    height = 24,
    speed = playerBaseSpeed,
}
player.x = screenWidth / 2 - player.width / 2
player.y = screenHeight - 60

-- Impulso (dash) de la canasta
local boostMaxBase = 100
local boostCost = 30
local boostRechargeRate = 22
local boostSpeedMultiplier = 2.6
local boostDuration = 0.22
local boostActive = false
local boostTimer = 0
local boostMeter = boostMaxBase

-- Sistema de Efectos Especiales Acumulables
local activeEffects = {}
local specialEffectDuration = 8

local effectLabels = {
    player_grow = { text = "¡Canasta gigante!", color = {0.3, 1, 0.5, 1} },
    fast_charge = { text = "¡Carga rápida!", color = {0.3, 1, 0.5, 1} },
    player_fast = { text = "¡Súper velocidad!", color = {0.3, 1, 0.5, 1} },
    empty = { text = "¡Barra vaciada!", color = {1, 0.35, 0.35, 1} },
    player_shrink = { text = "¡Canasta diminuta!", color = {1, 0.35, 0.35, 1} },
    shrink = { text = "¡Impulso reducido!", color = {1, 0.35, 0.35, 1} },
    slow_charge = { text = "¡Carga lenta!", color = {1, 0.35, 0.35, 1} },
    player_slow = { text = "¡Velocidad reducida!", color = {1, 0.35, 0.35, 1} },
    heal = { text = "¡+1 Vida!", color = {1, 0.3, 0.4, 1} },
}
local beneficialEffects = { "player_grow", "fast_charge", "player_fast" }
local detrimentalEffects = { "empty", "player_shrink", "shrink", "slow_charge", "player_slow" }

-- Estrellas
local stars = {}
local spawnTimer = 0
local spawnInterval = 0.8
local starMinSpeed = 120
local starMaxSpeed = 260
local starMaxHorizontalSpeed = 140
local specialStarChance = 0.25
local healStarChance = 0.20 -- 20% de las especiales son rojas (salud)

-- Puntaje y vidas
local score = 0
local lives = 3
local maxLives = 3
local highscore = 0

-- Dificultad progresiva
local elapsedTime = 0

-- Partículas y textos flotantes
local particles = {}
local floatingTexts = {}

-- Imágenes y Audio
local imgCorazon = nil
local imgEstrella = nil
local Musica_Para_EL_Menu = nil
local Musica_Para_Leer = nil
local Musica_Para_Jugar = nil

-- ---------------------------
-- HISTORIA Y CAPÍTULOS
-- ---------------------------
local storyParts = {
    {
        title = "Parte 1: Los Niños y el Consejo de la Paloma",
        unlockScore = 0,
        text = "Cuentan que una vez un niño vivía solo con su hermana menor. Ellos sufrían mucho porque no tenían un lugar fijo donde parar, ni nadie que los cuidara. Caminaban por el campo y comían lo que encontraban, por ejemplo mieles silvestres.\n\nCuando caía la tarde ellos buscaban un árbol donde subirse porque sabían que había animales salvajes. Durante la noche se turnaban para dormir y cuando amanecía bajaban y retomaban su caminar por el campo.\n\nUn día vieron una paloma y el hermano mayor preparó su honda para tirarle, pero de repente escuchó que la paloma hablaba y le decía: 'Te pido por favor que no me hagas nada, porque yo quiero avisarles algo que van a encontrar'. Entonces el niño no le hizo daño y prestó atención."
    },
    {
        title = "Parte 2: La Advertencia y la Trampa",
        unlockScore = 50,
        text = "La paloma continuó diciendo: 'Tengan mucho cuidado ustedes por donde van, porque hay una anciana que puede matarlos y comerlos. Ella se pone muy contenta cuando ve llegar a alguien y se pone a hacer una fogata. Después le pide que sople su fuego. Esa es una trampa. Dicen que ha matado a muchos que andaban por el monte cazando'.\n\nY siguió diciendo la paloma: 'Es por eso que ustedes deben ser astutos, no le hagan caso cuando se encuentren con ella y les ordene soplar el fuego. Díganle que no saben soplar y que ella misma sople. Cuando el fuego esté más fuerte, empújenla para que se caiga.\n\nCuando haya muerto córtenle el pecho izquierdo y saldrán unos perritos. Agárrenlos para ustedes. Pero, cuidado con el otro pecho porque allí tiene víboras'. Cuando la paloma terminó de hablar los niños se quedaron tranquilos porque ya sabían lo que iban a encontrar."
    },
    {
        title = "Parte 3: El Encuentro con la Abuela Caníbal",
        unlockScore = 120,
        text = "Luego siguieron caminando y después de mucho caminar se encontraron con la abuela caníbal. Cuando la anciana vio llegar a los niños, se puso muy contenta y se preparó para recibirlos muy bien. Pero ellos ya sabían su mala intención.\n\nLa anciana se apuró a hacer la fogata e invitó a los niños a acercarse para soplar el fuego. Pero ellos le dijeron: 'Abuela, no sabemos soplar, ¿por qué no lo hace usted?'\n\nLa anciana se agachó para soplar y cuando el fuego tomó fuerza, los dos niños se unieron para empujarla y así murió. Después le cortaron el seno izquierdo y salieron dos perritos. Y del seno derecho salieron viboritas."
    },
    {
        title = "Parte 4: La Persecución al Cielo",
        unlockScore = 200,
        text = "Los perritos crecieron tan rápido que los niños pudieron montar sobre ellos. Mientras andaban encontraron una víbora grande llamada Arco iris y los niños ordenaron a los perros que la mataran.\n\nAl otro día encontraron un Ñandú y también ordenaron a los perros que lo corrieran, porque querían montarlo. Los perros lo corrían pero el Ñandú los esquivaba. Cuando se cansaba el Ñandú los perros lo saltaban. Así lo hicieron varias veces.\n\nEl Ñandú también saltaba, hasta que alcanzó a volar. Entonces el Ñandú se fue para arriba y los perros también lo hicieron detrás del Ñandú, y arrastraron a los Niños. Cuando llegaron al cielo recién los Perros alcanzaron a morder al Ñandú en el cuello. Y así se quedaron para siempre.\n\nY es por eso que vemos en el cielo al ÑANDÚ, a los PERRITOS y a los dos NIÑOS, en la época de frío."
    }
}
local selectedStoryIndex = 1

-- ---------------------------
-- UTILIDADES DE AUDIO
-- ---------------------------
local function updateMusic()
    local targetTrack = nil

    if gameState == "menu" then
        targetTrack = Musica_Para_EL_Menu
    elseif gameState == "story_menu" or gameState == "story_view" then
        targetTrack = Musica_Para_Leer
    elseif gameState == "playing" or gameState == "gameover" then
        targetTrack = Musica_Para_Jugar
    end

    -- Detener pistas que no correspondan
    if targetTrack ~= Musica_Para_EL_Menu and Musica_Para_EL_Menu then Musica_Para_EL_Menu:stop() end
    if targetTrack ~= Musica_Para_Leer and Musica_Para_Leer then Musica_Para_Leer:stop() end
    if targetTrack ~= Musica_Para_Jugar and Musica_Para_Jugar then Musica_Para_Jugar:stop() end

    -- Reproducir la pista correspondiente solo si no está sonando ya
    if targetTrack and not targetTrack:isPlaying() then
        targetTrack:play()
    end
end

-- ---------------------------
-- UTILIDADES DEL JUEGO
-- ---------------------------
local function resetGame()
    stars = {}
    particles = {}
    floatingTexts = {}
    activeEffects = {}
    score = 0
    lives = 3
    elapsedTime = 0
    spawnInterval = 0.8
    
    player.width = playerBaseWidth
    player.speed = playerBaseSpeed
    player.x = screenWidth / 2 - player.width / 2

    boostMeter = boostMaxBase
    boostActive = false
    boostTimer = 0
end

local function spawnStar()
    local isSpecial = math.random() < specialStarChance
    local effectType = nil
    local starType = "normal"
    
    if isSpecial then
        if math.random() < healStarChance then
            starType = "heal"
        elseif math.random() < 0.5 then
            starType = "beneficial"
            effectType = "beneficial"
        else
            starType = "detrimental"
            effectType = "detrimental"
        end
    end

    local star = {
        x = math.random(20, screenWidth - 20),
        y = -20,
        radius = math.random(12, 18),
        speed = math.random(starMinSpeed, starMaxSpeed),
        vx = math.random(-starMaxHorizontalSpeed, starMaxHorizontalSpeed),
        rotation = 0,
        rotSpeed = math.random(-3, 3),
        colorShift = math.random(),
        isSpecial = isSpecial,
        starType = starType,
        effectType = effectType,
    }
    table.insert(stars, star)
end

local function spawnParticles(x, y, color)
    color = color or {1, 0.85, 0.2}
    for i = 1, 10 do
        table.insert(particles, {
            x = x,
            y = y,
            vx = math.random(-120, 120),
            vy = math.random(-200, -40),
            life = 0.5,
            maxLife = 0.5,
            color = color,
        })
    end
end

local function addFloatingText(x, y, effectKey)
    local info = effectLabels[effectKey]
    if not info then return end
    table.insert(floatingTexts, {
        text = info.text,
        x = x,
        y = y,
        color = info.color,
        life = 1.3,
        maxLife = 1.3,
    })
end

local function applySpecialEffect(x, y, starType, effectType)
    if starType == "heal" then
        if lives < maxLives then
            lives = lives + 1
        end
        spawnParticles(x, y, {1, 0.2, 0.3})
        addFloatingText(x, y, "heal")
        return
    end

    local effect
    if effectType == "beneficial" then
        effect = beneficialEffects[math.random(#beneficialEffects)]
    else
        effect = detrimentalEffects[math.random(#detrimentalEffects)]
    end

    if effect == "empty" then
        boostMeter = 0
    else
        activeEffects[effect] = specialEffectDuration
    end

    addFloatingText(x, y, effect)
end

local function tryActivateBoost()
    if not boostActive and boostMeter >= boostCost then
        boostActive = true
        boostTimer = boostDuration
        boostMeter = boostMeter - boostCost
        return true
    end
    return false
end

local function drawImageStar(s)
    if not imgEstrella then return end
    
    local imgW = imgEstrella:getWidth()
    local imgH = imgEstrella:getHeight()
    local scale = (s.radius * 2.2) / math.max(imgW, imgH)
    
    love.graphics.push()
    love.graphics.translate(s.x, s.y)
    love.graphics.rotate(s.rotation)
    
    if s.isSpecial then
        if s.starType == "heal" then
            love.graphics.setColor(1, 0.3, 0.4, 1)
        elseif s.starType == "beneficial" then
            love.graphics.setColor(0.3, 0.7, 1, 1)
        else
            love.graphics.setColor(0.3, 1, 0.4, 1)
        end
    else
        love.graphics.setColor(1, 0.9, 0.4, 1)
    end
    
    love.graphics.draw(imgEstrella, 0, 0, 0, scale, scale, imgW / 2, imgH / 2)
    love.graphics.pop()
end

local function drawAuthorCredits()
    love.graphics.setFont(fontSmall)
    love.graphics.setColor(0.6, 0.6, 0.7, 0.8)
    love.graphics.print("Hecho por Arce Alan", 16, screenHeight - 26)
    love.graphics.setColor(1, 1, 1, 1)
end

-- ---------------------------
-- CALLBACKS DE LOVE2D
-- ---------------------------
function love.load()
    imgCorazon = love.graphics.newImage("corazon.png")
    imgEstrella = love.graphics.newImage("Estrella.png")

    Musica_Para_EL_Menu = love.audio.newSource("Musica_De_Menu.mp3", "stream")
    Musica_Para_EL_Menu:setLooping(true)

    Musica_Para_Leer = love.audio.newSource("Katawa Shoujo OST #09 - Daylight.mp3", "stream")
    Musica_Para_Leer:setLooping(true)

    Musica_Para_Jugar = love.audio.newSource("Katawa Shoujo OST #25 - Afternoon.mp3", "stream")
    Musica_Para_Jugar:setLooping(true)
    
    love.window.setTitle("Recolecta Estrellas - Relato del Ñandú")
    love.window.setMode(screenWidth, screenHeight)
    math.randomseed(os.time())
    love.graphics.setBackgroundColor(0.06, 0.07, 0.14)

    fontBig = love.graphics.newFont(40)
    fontMedium = love.graphics.newFont(22)
    fontSmall = love.graphics.newFont(15)

    bgStars = {}
    for i = 1, 60 do
        table.insert(bgStars, {
            x = math.random(0, screenWidth),
            y = math.random(0, screenHeight),
            size = math.random(1, 3),
            twinkle = math.random(),
        })
    end

    updateMusic()
end

function love.update(dt)
    for _, bs in ipairs(bgStars) do
        bs.twinkle = bs.twinkle + dt
    end

    if gameState == "playing" then
        elapsedTime = elapsedTime + dt
        spawnInterval = math.max(0.28, 0.8 - elapsedTime * 0.01)

        for eff, timer in pairs(activeEffects) do
            activeEffects[eff] = timer - dt
            if activeEffects[eff] <= 0 then
                activeEffects[eff] = nil
            end
        end

        local currentWidthMult = 1
        if activeEffects["player_grow"] then currentWidthMult = currentWidthMult * 2 end
        if activeEffects["player_shrink"] then currentWidthMult = currentWidthMult * 0.5 end
        player.width = playerBaseWidth * currentWidthMult

        local currentSpeedMult = 1
        if activeEffects["player_fast"] then currentSpeedMult = currentSpeedMult * 1.5 end
        if activeEffects["player_slow"] then currentSpeedMult = currentSpeedMult * 0.5 end
        player.speed = playerBaseSpeed * currentSpeedMult

        local currentRechargeMult = 1
        if activeEffects["fast_charge"] then currentRechargeMult = currentRechargeMult * 2 end
        if activeEffects["slow_charge"] then currentRechargeMult = currentRechargeMult * 0.5 end

        local currentBoostMax = boostMaxBase
        if activeEffects["shrink"] then currentBoostMax = boostMaxBase * 0.5 end

        if boostMeter < currentBoostMax then
            boostMeter = math.min(currentBoostMax, boostMeter + boostRechargeRate * currentRechargeMult * dt)
        end

        if boostActive then
            boostTimer = boostTimer - dt
            if boostTimer <= 0 then
                boostActive = false
            end
        end

        local currentSpeed = player.speed * (boostActive and boostSpeedMultiplier or 1)
        if love.keyboard.isDown("left", "a") then
            player.x = player.x - currentSpeed * dt
        end
        if love.keyboard.isDown("right", "d") then
            player.x = player.x + currentSpeed * dt
        end
        player.x = math.max(0, math.min(screenWidth - player.width, player.x))

        spawnTimer = spawnTimer + dt
        if spawnTimer >= spawnInterval then
            spawnTimer = 0
            spawnStar()
        end

        for i = #stars, 1, -1 do
            local s = stars[i]
            s.y = s.y + s.speed * dt
            s.x = s.x + s.vx * dt
            s.rotation = s.rotation + s.rotSpeed * dt

            if s.x - s.radius <= 0 then
                s.x = s.radius
                s.vx = -s.vx
            elseif s.x + s.radius >= screenWidth then
                s.x = screenWidth - s.radius
                s.vx = -s.vx
            end

            if s.y + s.radius >= player.y
                and s.y - s.radius <= player.y + player.height
                and s.x >= player.x - s.radius
                and s.x <= player.x + player.width + s.radius then
                
                if s.isSpecial then
                    score = score + 5
                    local particleColor = {0.3, 1, 0.4}
                    if s.starType == "heal" then
                        particleColor = {1, 0.2, 0.3}
                    elseif s.starType == "beneficial" then
                        particleColor = {0.3, 0.55, 1}
                    end
                    
                    spawnParticles(s.x, s.y, particleColor)
                    applySpecialEffect(s.x, s.y, s.starType, s.effectType)
                else
                    score = score + 10
                    spawnParticles(s.x, s.y, {1, 0.85, 0.2})
                end
                table.remove(stars, i)
            elseif s.y - s.radius > screenHeight then
                table.remove(stars, i)
                if not s.isSpecial then
                    lives = lives - 1
                    if lives <= 0 then
                        if score > highscore then
                            highscore = score
                        end
                        gameState = "gameover"
                        updateMusic()
                    end
                end
            end
        end

        for i = #particles, 1, -1 do
            local p = particles[i]
            p.x = p.x + p.vx * dt
            p.y = p.y + p.vy * dt
            p.vy = p.vy + 400 * dt
            p.life = p.life - dt
            if p.life <= 0 then
                table.remove(particles, i)
            end
        end

        for i = #floatingTexts, 1, -1 do
            local ft = floatingTexts[i]
            ft.y = ft.y - 40 * dt
            ft.life = ft.life - dt
            if ft.life <= 0 then
                table.remove(floatingTexts, i)
            end
        end
    end
end

-- ---------------------------
-- DIBUJO DE PANTALLAS
-- ---------------------------
local function drawBackground()
    for _, bs in ipairs(bgStars) do
        local alpha = 0.4 + 0.6 * math.abs(math.sin(bs.twinkle * 2))
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.circle("fill", bs.x, bs.y, bs.size)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

local function drawMenu()
    drawBackground()

    love.graphics.setFont(fontBig)
    love.graphics.setColor(1, 0.85, 0.2, 1)
    love.graphics.printf("So Mañec Piguem Le’ec", 0, 100, screenWidth, "center")

    love.graphics.setFont(fontMedium)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Presiona ENTER o ESPACIO para jugar", 0, 180, screenWidth, "center")
    
    love.graphics.setColor(0.3, 0.8, 1, 1)
    love.graphics.printf("Presiona 'H' para leer la Historia del Ñandú", 0, 220, screenWidth, "center")

    love.graphics.setFont(fontSmall)
    love.graphics.setColor(0.8, 0.8, 0.9, 1)
    love.graphics.printf("Muévete con las flechas o A / D | Usa ESPACIO para impulso", 0, 280, screenWidth, "center")
    love.graphics.setColor(0.4, 0.65, 1, 1)
    love.graphics.printf("¡Desbloquea capítulos del relato obteniendo mejores puntajes!", 0, 310, screenWidth, "center")

    if highscore > 0 then
        love.graphics.setColor(1, 0.85, 0.2, 1)
        love.graphics.printf("Mejor puntaje: " .. highscore, 0, 360, screenWidth, "center")
    end

    if imgEstrella then
        love.graphics.setColor(1, 1, 1, 1)
        local scale = 70 / math.max(imgEstrella:getWidth(), imgEstrella:getHeight())
        love.graphics.draw(imgEstrella, screenWidth / 2, 430, love.timer.getTime(), scale, scale, imgEstrella:getWidth() / 2, imgEstrella:getHeight() / 2)
    end

    love.graphics.setFont(fontSmall)
    love.graphics.setColor(0.6, 0.6, 0.7, 1)
    love.graphics.printf("ESC para salir", 0, screenHeight - 40, screenWidth, "center")

    drawAuthorCredits()
end

local function drawStoryMenu()
    drawBackground()

    love.graphics.setFont(fontBig)
    love.graphics.setColor(0.3, 0.8, 1, 1)
    love.graphics.printf("RELATO DEL ÑANDÚ DEL CIELO", 0, 50, screenWidth, "center")

    love.graphics.setFont(fontMedium)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Selecciona una parte (Usa 1, 2, 3 o 4):", 0, 120, screenWidth, "center")

    local startY = 180
    for i, part in ipairs(storyParts) do
        local unlocked = highscore >= part.unlockScore
        if unlocked then
            love.graphics.setColor(0.2, 0.9, 0.4, 1)
            love.graphics.printf("[" .. i .. "] " .. part.title, 50, startY + (i - 1) * 70, screenWidth - 100, "left")
        else
            love.graphics.setColor(0.5, 0.5, 0.5, 1)
            love.graphics.printf("[" .. i .. "] BLOQUEADO (Requiere " .. part.unlockScore .. " pts)", 50, startY + (i - 1) * 70, screenWidth - 100, "left")
        end
    end

    love.graphics.setFont(fontSmall)
    love.graphics.setColor(0.8, 0.8, 0.9, 1)
    love.graphics.printf("Tu Record Actual: " .. highscore .. " pts", 0, screenHeight - 80, screenWidth, "center")
    love.graphics.printf("Presiona ESC o BORRAR (Backspace) para regresar al menú principal", 0, screenHeight - 40, screenWidth, "center")
end

local function drawStoryView()
    drawBackground()

    local part = storyParts[selectedStoryIndex]
    love.graphics.setFont(fontBig)
    love.graphics.setColor(1, 0.85, 0.2, 1)
    love.graphics.printf(part.title, 40, 40, screenWidth - 80, "center")

    love.graphics.setFont(fontMedium)
    love.graphics.setColor(0.9, 0.9, 0.95, 1)
    love.graphics.printf(part.text, 60, 120, screenWidth - 120, "left")

    love.graphics.setFont(fontSmall)
    love.graphics.setColor(0.6, 0.6, 0.7, 1)
    love.graphics.printf("Presiona ESC o BORRAR para volver a la lista de capítulos", 362, screenHeight - 17, screenWidth)
end

local function drawPlayer()
    if boostActive then
        love.graphics.setColor(0.9, 0.7, 0.3, 1)
    else
        love.graphics.setColor(0.55, 0.35, 0.2, 1)
    end
    love.graphics.rectangle("fill", player.x, player.y, player.width, player.height, 6, 6)
    love.graphics.setColor(0.75, 0.5, 0.3, 1)
    love.graphics.rectangle("line", player.x, player.y, player.width, player.height, 6, 6)
end

local function drawBoostBar()
    local baseBarWidth = 180
    local barHeight = 14
    local x = 16
    local y = 76

    local currentBoostMax = boostMaxBase * (activeEffects["shrink"] and 0.5 or 1)
    local containerWidth = baseBarWidth * (currentBoostMax / boostMaxBase)
    local baseFillRatio = math.min(1, boostMeter / currentBoostMax)
    local canBoost = boostMeter >= boostCost

    -- Fondo de la barra principal
    love.graphics.setColor(0.15, 0.15, 0.22, 1)
    love.graphics.rectangle("fill", x, 82, containerWidth, barHeight, 4, 4)

    -- Relleno de la barra principal
    if canBoost then
        love.graphics.setColor(0.3, 0.75, 1, 1)
    else
        love.graphics.setColor(0.4, 0.4, 0.5, 1)
    end
    love.graphics.rectangle("fill", x, 82, containerWidth * baseFillRatio, barHeight, 4, 4)

    -- Borde de la barra principal
    love.graphics.setColor(0.7, 0.7, 0.8, 1)
    love.graphics.rectangle("line", x, 82, containerWidth, barHeight, 4, 4)

    -- Texto y etiquetas
    love.graphics.setFont(fontSmall)
    local label = "Impulso (ESPACIO)"
    
    local firstEffect = next(activeEffects)
    if firstEffect and effectLabels[firstEffect] then
        love.graphics.setColor(effectLabels[firstEffect].color)
        label = label .. " - " .. effectLabels[firstEffect].text
    else
        love.graphics.setColor(1, 1, 1, 1)
    end
    love.graphics.print(label, x, 82 - 18)
    love.graphics.setColor(1, 1, 1, 1)
end 

local function drawGame()
    drawBackground()

    for _, s in ipairs(stars) do
        drawImageStar(s)
    end

    for _, p in ipairs(particles) do
        love.graphics.setColor(p.color[1], p.color[2], p.color[3], p.life / p.maxLife)
        love.graphics.circle("fill", p.x, p.y, 3)
    end

    drawPlayer()

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(fontMedium)
    love.graphics.print("Puntaje: " .. score, 16, 12)

    love.graphics.setFont(fontSmall)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Vidas:", 16, 46)
    
    if imgCorazon then
        local heartScale = 22 / math.max(imgCorazon:getWidth(), imgCorazon:getHeight())
        local startX = 68
        for i = 1, lives do
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(imgCorazon, startX + (i - 1) * 24, 46, 0, heartScale, heartScale)
        end
    end

    drawBoostBar()

    love.graphics.setFont(fontSmall)
    for _, ft in ipairs(floatingTexts) do
        local alpha = ft.life / ft.maxLife
        love.graphics.setColor(ft.color[1], ft.color[2], ft.color[3], alpha)
        love.graphics.printf(ft.text, ft.x - 100, ft.y, 200, "center")
    end
    love.graphics.setColor(1, 1, 1, 1)
end

local function drawGameOver()
    drawBackground()

    love.graphics.setFont(fontBig)
    love.graphics.setColor(1, 0.3, 0.3, 1)
    love.graphics.printf("JUEGO TERMINADO", 0, 160, screenWidth, "center")

    love.graphics.setFont(fontMedium)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Puntaje final: " .. score, 0, 240, screenWidth, "center")

    love.graphics.setColor(1, 0.85, 0.2, 1)
    love.graphics.printf("Mejor puntaje: " .. highscore, 0, 275, screenWidth, "center")

    love.graphics.setFont(fontSmall)
    love.graphics.setColor(0.8, 0.8, 0.9, 1)
    love.graphics.printf("Presiona ENTER para volver al menú", 0, 340, screenWidth, "center")
end

function love.draw()
    if gameState == "menu" then
        drawMenu()
    elseif gameState == "playing" then
        drawGame()
    elseif gameState == "gameover" then
        drawGameOver()
    elseif gameState == "story_menu" then
        drawStoryMenu()
    elseif gameState == "story_view" then
        drawStoryView()
    end
end

-- ---------------------------
-- INPUT CONTROLS
-- ---------------------------
function love.keypressed(key)
    if key == "escape" then
        if gameState == "menu" then
            love.event.quit()
        elseif gameState == "story_view" then
            gameState = "story_menu"
        else
            gameState = "menu"
        end
        updateMusic()
    end

    if key == "backspace" then
        if gameState == "story_view" then
            gameState = "story_menu"
        elseif gameState == "story_menu" then
            gameState = "menu"
        end
        updateMusic()
    end

    if gameState == "menu" and key == "h" then
        gameState = "story_menu"
        updateMusic()
    end

    if gameState == "story_menu" then
        local index = tonumber(key)
        if index and index >= 1 and index <= #storyParts then
            if highscore >= storyParts[index].unlockScore then
                selectedStoryIndex = index
                gameState = "story_view"
                updateMusic()
            end
        end
    end

    if key == "return" then
        if gameState == "menu" then
            resetGame()
            gameState = "playing"
            updateMusic()
        elseif gameState == "gameover" then
            gameState = "menu"
            updateMusic()
        end
    end

    if key == "space" then
        if gameState == "menu" then
            resetGame()
            gameState = "playing"
            updateMusic()
        elseif gameState == "gameover" then
            gameState = "menu"
            updateMusic()
        elseif gameState == "playing" then
            tryActivateBoost()
        end
    end
end