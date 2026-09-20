local screenWidth = 900
local screenHeight = 700

local cantidadPares = 8

local tiempoMostrar = 0.8

-- ============================================
-- DATOS DEL JUEGO
-- ============================================

local cartas = {}

local primeraCarta = nil
local segundaCarta = nil

local esperando = false
local tiempoEspera = 0

local movimientos = 0
local paresEncontrados = 0

local juegoTerminado = false

local fuente
local fuenteGrande

-- Arreglo de imágenes para las cartas
local imagenes = {}

-- Variable para la música y volumen (Estado intermedio inicial: 0.5)
local musica
local volumenActual = 0.5 

-- ============================================
-- CONFIGURACIÓN DEL FONDO (ESTRELLAS)
-- ============================================

local estrellas = {}
local cantidadEstrellas = 100

function inicializarEstrellas()
    estrellas = {}
    for i = 1, cantidadEstrellas do
        table.insert(estrellas, {
            x = math.random(0, screenWidth),
            y = math.random(0, screenHeight),
            velocidad = math.random(20, 80), -- Velocidad de desplazamiento horizontal
            radio = math.random(1, 3),      -- Tamaño de la estrella
            brillo = math.random(50, 255) / 255 -- Intensidad de color
        })
    end
end

-- ============================================
-- CONFIGURACIÓN DE LAS CARTAS (AMPLIADAS)
-- ============================================

local columnas = 4

local cartaAncho = 200
local cartaAlto = 200

local espacio = 25

local inicioX
local inicioY

-- ============================================
-- CREAR LAS CARTAS
-- ============================================

function crearCartas()

    cartas = {}

    -- Crear los pares utilizando las imágenes cargadas
    for i = 1, cantidadPares do

        local img = imagenes[i]

        local carta1 = {
            id = i,
            imagen = img,
            descubierta = false,
            encontrada = false
        }

        local carta2 = {
            id = i,
            imagen = img,
            descubierta = false,
            encontrada = false
        }

        table.insert(cartas, carta1)
        table.insert(cartas, carta2)

    end

    -- Mezclar cartas
    for i = #cartas, 2, -1 do

        local j = math.random(i)

        cartas[i], cartas[j] = cartas[j], cartas[i]

    end

    -- Calcular posición y centrar en pantalla completa
    local filas = math.ceil(#cartas / columnas)
    cartaAncho = math.floor(math.min((screenWidth - 80 - (columnas-1)*espacio)/columnas, (screenHeight - 300 - (filas-1)*espacio)/filas))
    cartaAlto = cartaAncho

    local anchoTotal =
        columnas * cartaAncho +
        (columnas - 1) * espacio

    local altoTotal =
        filas * cartaAlto +
        (filas - 1) * espacio

    inicioX = (screenWidth - anchoTotal) / 2
    -- Centramos verticalmente dejando espacio arriba para el título y la info
    inicioY = 150

    -- Asignar posiciones
    for i, carta in ipairs(cartas) do

        local columna = (i - 1) % columnas
        local fila = math.floor((i - 1) / columnas)

        carta.x =
            inicioX +
            columna * (cartaAncho + espacio)

        carta.y =
            inicioY +
            fila * (cartaAlto + espacio)

        carta.ancho = cartaAncho
        carta.alto = cartaAlto

    end

end

-- ============================================
-- INICIAR / REINICIAR
-- ============================================

function reiniciarJuego()

    primeraCarta = nil
    segundaCarta = nil

    esperando = false
    tiempoEspera = 0

    movimientos = 0
    paresEncontrados = 0

    juegoTerminado = false

    crearCartas()

end

-- ============================================
-- LOVE LOAD
-- ============================================

function love.load()

    -- Cargar las 8 imágenes (asegurate de que estén en la misma carpeta del main.lua)
    imagenes[1] = love.graphics.newImage("imagen1.jpg")
    imagenes[2] = love.graphics.newImage("imagen2.jpg")
    imagenes[3] = love.graphics.newImage("imagen3.jpg")
    imagenes[4] = love.graphics.newImage("imagen4.jpg")
    imagenes[5] = love.graphics.newImage("imagen5.jpg")
    imagenes[6] = love.graphics.newImage("imagen6.jpg")
    imagenes[7] = love.graphics.newImage("imagen7.jpg")
    imagenes[8] = love.graphics.newImage("imagen8.jpg")

    -- Cargar y configurar la música de fondo
    musica = love.audio.newSource("Katawa Shoujo OST - The Student Council (Shizune's Theme) - Ravenholme.mp3", "stream")
    musica:setLooping(true) 
    musica:setVolume(volumenActual) -- Establece el volumen en estado intermedio (0.5)
    love.audio.play(musica)  
    
    math.randomseed(os.time())

    -- Configurar pantalla completa usando la resolución nativa del monitor
    love.window.setMode(0, 0, {
        fullscreen = true,
        fullscreentype = "desktop",
        vsync = true
    })

    -- Actualizar las dimensiones reales de la pantalla
    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()

    love.window.setTitle(
        "Juego de Memoria"
    )

    fuente = love.graphics.newFont(24)
    fuenteGrande = love.graphics.newFont(42)

    inicializarEstrellas()
    reiniciarJuego()

end

-- ============================================
-- ACTUALIZAR
-- ============================================

function love.update(dt)

    -- Actualizar las estrellas (movimiento de derecha a izquierda)
    for _, estrella in ipairs(estrellas) do
        estrella.x = estrella.x - estrella.velocidad * dt
        if estrella.x < 0 then
            estrella.x = screenWidth
            estrella.y = math.random(0, screenHeight)
        end
    end

    if esperando then

        tiempoEspera =
            tiempoEspera - dt

        if tiempoEspera <= 0 then

            if primeraCarta.id ~= segundaCarta.id then

                primeraCarta.descubierta = false
                segundaCarta.descubierta = false

            else

                primeraCarta.encontrada = true
                segundaCarta.encontrada = true

                paresEncontrados =
                    paresEncontrados + 1

            end

            primeraCarta = nil
            segundaCarta = nil

            esperando = false

            if paresEncontrados == cantidadPares then

                juegoTerminado = true

            end

        end

    end

end

-- ============================================
-- DIBUJAR
-- ============================================

function love.draw()

    -- Fondo oscuro base
    love.graphics.clear(
        0.05,
        0.05,
        0.08
    )

    -- Dibujar estrellas
    for _, estrella in ipairs(estrellas) do
        love.graphics.setColor(estrella.brillo, estrella.brillo, estrella.brillo)
        love.graphics.circle("fill", estrella.x, estrella.y, estrella.radio)
    end

    -- ========================================
    -- TÍTULO
    -- ========================================

    love.graphics.setFont(fuenteGrande)

    love.graphics.setColor(
        1,
        1,
        1
    )

    love.graphics.printf(
        "JUEGO DE MEMORIA",
        0,
        40,
        screenWidth,
        "center"
    )

    -- ========================================
    -- INFORMACIÓN
    -- ========================================

    love.graphics.setFont(fuente)

    love.graphics.printf(
        "Movimientos: " .. movimientos ..
        "    Pares: " ..
        paresEncontrados ..
        " / " ..
        cantidadPares,
        0,
        100,
        screenWidth,
        "center"
    )

    -- ========================================
    -- CARTAS
    -- ========================================

    for _, carta in ipairs(cartas) do

        dibujarCarta(carta)

    end

    -- ========================================
    -- INTERFAZ INFERIOR IZQUIERDA (AUTOR Y VOLUMEN)
    -- ========================================

    -- Texto de autoría abajo a la izquierda
    love.graphics.setColor(1, 1, 1, 0.7)
    love.graphics.setFont(fuente)
    love.graphics.print("Hecho por Arce Alan", 30, screenHeight - 45)

    -- Botón de Disminuir Volumen (-)
    love.graphics.setColor(0.2, 0.2, 0.4, 0.9)
    love.graphics.rectangle("fill", 30, screenHeight - 110, 40, 40, 6, 6)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", 30, screenHeight - 110, 40, 40, 6, 6)
    love.graphics.printf("-", 30, screenHeight - 103, 40, "center")

    -- Botón de Aumentar Volumen (+)
    love.graphics.setColor(0.2, 0.2, 0.4, 0.9)
    love.graphics.rectangle("fill", 80, screenHeight - 110, 40, 40, 6, 6)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", 80, screenHeight - 110, 40, 40, 6, 6)
    love.graphics.printf("+", 80, screenHeight - 103, 40, "center")

    -- Indicador de nivel de volumen
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.print("Volumen: " .. math.floor(volumenActual * 100) .. "%", 135, screenHeight - 102)

    -- ========================================
    -- VICTORIA
    -- ========================================

    if juegoTerminado then

        love.graphics.setColor(
            0,
            0,
            0,
            0.75
        )

        love.graphics.rectangle(
            "fill",
            0,
            0,
            screenWidth,
            screenHeight
        )

        love.graphics.setColor(
            1,
            1,
            1
        )

        local centerY = screenHeight / 2

        love.graphics.setFont(fuenteGrande)

        love.graphics.printf(
            "¡GANASTE!",
            0,
            centerY - 90,
            screenWidth,
            "center"
        )

        love.graphics.setFont(fuente)

        love.graphics.printf(
            "Terminaste en " ..
            movimientos ..
            " movimientos",
            0,
            centerY - 20,
            screenWidth,
            "center"
        )

        love.graphics.printf(
            "Presioná R para jugar nuevamente",
            0,
            centerY + 30,
            screenWidth,
            "center"
        )

    end

end

-- ============================================
-- DIBUJAR UNA CARTA
-- ============================================

function dibujarCarta(carta)

    if carta.encontrada then

        love.graphics.setColor(
            0.2,
            0.65,
            0.3,
            0.5 
        )

        love.graphics.rectangle(
            "fill",
            carta.x,
            carta.y,
            carta.ancho,
            carta.alto,
            12,
            12
        )

        love.graphics.setColor(1, 1, 1, 1)
        local imgW = carta.imagen:getWidth()
        local imgH = carta.imagen:getHeight()
        local escalaX = carta.ancho / imgW
        local escalaY = carta.alto / imgH

        love.graphics.draw(carta.imagen, carta.x, carta.y, 0, escalaX, escalaY)

        return

    end

    if carta.descubierta then

        love.graphics.setColor(
            0.85,
            0.85,
            0.9
        )

        love.graphics.rectangle(
            "fill",
            carta.x,
            carta.y,
            carta.ancho,
            carta.alto,
            12,
            12
        )

        love.graphics.setColor(1, 1, 1, 1)
        local imgW = carta.imagen:getWidth()
        local imgH = carta.imagen:getHeight()
        local escalaX = carta.ancho / imgW
        local escalaY = carta.alto / imgH

        love.graphics.draw(carta.imagen, carta.x, carta.y, 0, escalaX, escalaY)

    else

        love.graphics.setColor(
            0.25,
            0.35,
            0.75
        )

        love.graphics.rectangle(
            "fill",
            carta.x,
            carta.y,
            carta.ancho,
            carta.alto,
            12,
            12
        )

        love.graphics.setColor(
            0.8,
            0.85,
            1
        )

        love.graphics.setFont(fuenteGrande)

        love.graphics.printf(
            "?",
            carta.x,
            carta.y + 70, 
            carta.ancho,
            "center"
        )

    end

    love.graphics.setColor(
        1,
        1,
        1
    )

    love.graphics.setLineWidth(3)

    love.graphics.rectangle(
        "line",
        carta.x,
        carta.y,
        carta.ancho,
        carta.alto,
        12,
        12
    )

end

-- ============================================
-- CLICK DEL MOUSE
-- ============================================

function love.mousepressed(x, y, button)

    if button ~= 1 then
        return
    end

    if x >= 30 and x <= 70 and false then
        volumenActual = math.max(0, volumenActual - 0.1)
        musica:setVolume(volumenActual)
        return
    end

    -- Botón Más (+)
    if x >= 80 and x <= 120 and false then
        volumenActual = math.min(1, volumenActual + 0.1)
        musica:setVolume(volumenActual)
        return
    end

    if juegoTerminado then
        return
    end

    if esperando then
        return
    end

    for _, carta in ipairs(cartas) do

        if x >= carta.x
        and x <= carta.x + carta.ancho
        and y >= carta.y
        and y <= carta.y + carta.alto then

            if carta.descubierta then
                return
            end

            if carta.encontrada then
                return
            end

            carta.descubierta = true

            if primeraCarta == nil then

                primeraCarta = carta

            elseif segundaCarta == nil then

                segundaCarta = carta

                movimientos =
                    movimientos + 1

                esperando = true

                tiempoEspera =
                    tiempoMostrar

            end

            return

        end

    end

end

-- ============================================
-- TECLADO
-- ============================================

function love.keypressed(key)

    if key == "escape" then
        love.event.quit()
    end

    if key == "r" then
        reiniciarJuego()
    end

end
-- Native-size responsive board, keeping all 16 cards and the current round.
local compactFont
local function arrangeCards()
    screenWidth,screenHeight=love.graphics.getDimensions()
    espacio=10
    local best=0
    for _,cols in ipairs({4,6,8,2}) do
        local rows=math.ceil(#cartas/cols)
        local size=math.floor(math.min((screenWidth-24-(cols-1)*espacio)/cols,(screenHeight-106-(rows-1)*espacio)/rows))
        if size>best then best=size;columnas=cols end
    end
    cartaAncho,cartaAlto=best,best
    local rows=math.ceil(#cartas/columnas)
    inicioY=54+(screenHeight-106-(rows*best+(rows-1)*espacio))/2
    for i,c in ipairs(cartas) do
        local row=math.floor((i-1)/columnas)
        local count=math.min(columnas,#cartas-row*columnas)
        local left=(screenWidth-(count*best+(count-1)*espacio))/2
        c.x=left+((i-1)%columnas)*(best+espacio)
        c.y=inicioY+row*(best+espacio)
        c.ancho,c.alto=best,best
    end
end
local createOriginal=crearCartas
function crearCartas() createOriginal();arrangeCards() end
function love.resize() arrangeCards();inicializarEstrellas() end
function dibujarCarta(c)
    love.graphics.setColor(0.20,0.29,0.56)
    love.graphics.rectangle('fill',c.x,c.y,c.ancho,c.alto,8,8)
    if c.descubierta or c.encontrada then
        local s=math.min((c.ancho-4)/c.imagen:getWidth(),(c.alto-4)/c.imagen:getHeight())
        love.graphics.setColor(1,1,1)
        love.graphics.draw(c.imagen,c.x+c.ancho/2,c.y+c.alto/2,0,s,s,c.imagen:getWidth()/2,c.imagen:getHeight()/2)
    else
        love.graphics.setFont(fuenteGrande)
        love.graphics.setColor(0.9,0.94,1)
        love.graphics.printf('?',c.x,c.y+(c.alto-fuenteGrande:getHeight())/2,c.ancho,'center')
    end
    love.graphics.setColor(c.encontrada and 0.4 or 0.9,1,c.encontrada and 0.5 or 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line',c.x,c.y,c.ancho,c.alto,8,8)
end
function love.draw()
    compactFont=compactFont or love.graphics.newFont(18)
    love.graphics.clear(0.05,0.05,0.08)
    for _,s in ipairs(estrellas) do
        love.graphics.setColor(s.brillo,s.brillo,s.brillo)
        love.graphics.circle('fill',s.x,s.y,s.radio)
    end
    love.graphics.setFont(compactFont)
    love.graphics.setColor(1,1,1)
    love.graphics.printf('MEMORIA  ·  '..paresEncontrados..'/8 pares  ·  '..movimientos..' movimientos',8,10,screenWidth-16,'center')
    for _,c in ipairs(cartas) do dibujarCarta(c) end
    love.graphics.setFont(compactFont)
    for i,label in ipairs({'−','+'}) do
        local x=12+(i-1)*48
        love.graphics.setColor(0.2,0.2,0.4)
        love.graphics.rectangle('fill',x,screenHeight-44,40,36,6,6)
        love.graphics.setColor(1,1,1)
        love.graphics.printf(label,x,screenHeight-41,40,'center')
    end
    love.graphics.setColor(0.8,0.85,0.9)
    love.graphics.print(math.floor(volumenActual*100)..'%',110,screenHeight-39)
    love.graphics.printf('Arce Alan',160,screenHeight-39,math.max(1,screenWidth-300),'center')
    love.graphics.setColor(0.27,0.44,0.2)
    love.graphics.rectangle('fill',screenWidth-130,screenHeight-44,118,36,6,6)
    love.graphics.setColor(1,1,1)
    love.graphics.printf('Reiniciar',screenWidth-130,screenHeight-41,118,'center')
    if juegoTerminado then
        love.graphics.setColor(0,0,0,0.75)
        love.graphics.rectangle('fill',0,screenHeight/2-70,screenWidth,140)
        love.graphics.setColor(1,1,1)
        love.graphics.setFont(fuenteGrande)
        love.graphics.printf('¡GANASTE!',0,screenHeight/2-55,screenWidth,'center')
        love.graphics.setFont(fuente)
        love.graphics.printf('Tocá Reiniciar para volver a jugar',0,screenHeight/2+8,screenWidth,'center')
    end
end
local clickOriginal=love.mousepressed
function love.mousepressed(x,y,b)
    if b~=1 then return end
    if y>=screenHeight-44 then
        if x>=12 and x<=52 then volumenActual=math.max(0,volumenActual-0.1);musica:setVolume(volumenActual)
        elseif x>=60 and x<=100 then volumenActual=math.min(1,volumenActual+0.1);musica:setVolume(volumenActual)
        elseif x>=screenWidth-130 and x<=screenWidth-12 then reiniciarJuego() end
        return
    end
    clickOriginal(x,y,b)
end
