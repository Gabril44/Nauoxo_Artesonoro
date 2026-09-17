function love.load()

    -- musica del juego
    musica = love.audio.newSource("iron.mp3", "stream")
    musica:setLooping(true)
    musica:play()

    -- salto
    salto = love.audio.newSource("turren.mp3", "static")

    estado = "menu"
    score = 0

    tiempo = 0
    velocidadAnimacion = 0.1
    frame = 1

    frameMuerte = 1
    tiempoMuerte = 0

    sprites = {
        love.graphics.newImage("ñandu.png"),
        love.graphics.newImage("ñanduu.png"),
        
    }

    muerte = {
        love.graphics.newImage("ñandu.png"),
        love.graphics.newImage("ñanduu.png"),
        
    }

    menu = love.graphics.newImage("cacique pelayo.png")

    local menuAncho, menuAlto = menu:getDimensions()
    menuScaleX = 800 / menuAncho
    menuScaleY = 600 / menuAlto

    radio = 30

    birdX = 200
    y = 300
    velY = 0

    gravedadBase = 500

    shakeDuracion = 0
    shakeMagnitud = 0

    fondoColor = {0.02, 0.02, 0.08}

    inmortal = false
    tiempoInmortal = 0
    duracionInmortal = 3

    pausado = false
    tiempoPausa = 0

    estrellas = {}

    for i = 1, 80 do
        table.insert(estrellas, {
            x = math.random(0, 800),
            y = math.random(0, 600),
            r = math.random(1, 3),
            brillo = math.random(50, 100) / 100
        })
    end

    luna = {
        x = 650,
        y = 120,
        r = 50
    }

    obstaculos = {
        {x = 1100, gapY = 130, passed = false, color = {1, 0.3, 0.3}, fase = math.random(0, 100), semilla = false},
        {x = 400, gapY = 200, passed = false, color = {0.3, 1, 0.3}, fase = math.random(0, 100), semilla = false},
        {x = 600, gapY = 250, passed = false, color = {0.3, 0.3, 1}, fase = math.random(0, 100), semilla = false},
        {x = 900, gapY = 180, passed = false, color = {1, 1, 0.3}, fase = math.random(0, 100), semilla = false}
    }

    dificultad = 1
    velocidadObstaculos = 150
    gapBase = 120
end


function resetGame()

    score = 0

    y = 300
    velY = 0

    frame = 1
    tiempo = 0

    frameMuerte = 1
    tiempoMuerte = 0

    shakeDuracion = 0
    shakeMagnitud = 0

    inmortal = false
    tiempoInmortal = 0

    pausado = false

    for i = 1, #obstaculos do
        obstaculos[i].x = 400 + i * 250
        obstaculos[i].gapY = math.random(100, 300)
        obstaculos[i].passed = false
        obstaculos[i].fase = math.random(0, 100)
        obstaculos[i].semilla = false
    end

    estado = "jugando"
end


function love.update(dt)

    if pausado then
        return
    end

    if estado == "jugando" then

        if inmortal then
            tiempoInmortal = tiempoInmortal - dt

            if tiempoInmortal <= 0 then
                inmortal = false
            end
        end

        tiempo = tiempo + dt

        if tiempo > velocidadAnimacion then
            frame = frame + 1

            if frame > #sprites then
                frame = 1
            end

            tiempo = 0
        end

        dificultad = 1 + score * 0.05

        velY = velY + (gravedadBase * (1 + score * 0.02)) * dt
        y = y + velY * dt

        if y - radio < 0 or y + radio > 600 then
            estado = "gameover"
            shakeDuracion = 0.4
            shakeMagnitud = 8
        end

        local obstaculoAncho = 50
        local t = love.timer.getTime()

        for i = 1, #obstaculos do

            local o = obstaculos[i]

            o.x = o.x - (velocidadObstaculos * dificultad) * dt
            o.gapY = o.gapY + math.sin(t * 2 + o.fase) * 0.5

            o.color[1] = 0.5 + math.sin(t + o.fase) * 0.5
            o.color[2] = 0.5 + math.sin(t * 1.3 + o.fase) * 0.5
            o.color[3] = 0.5 + math.sin(t * 1.7 + o.fase) * 0.5

            if o.x < -50 then

                local maxX = 0

                for j = 1, #obstaculos do
                    if obstaculos[j].x > maxX then
                        maxX = obstaculos[j].x
                    end
                end

                o.x = maxX + math.random(250, 350)
                o.gapY = math.random(100, 300)
                o.passed = false
                o.semilla = math.random() < 0.2
            end

            if not o.passed and o.x + obstaculoAncho < birdX then
                score = score + 1
                o.passed = true
            end

            local gapActual = math.max(70, gapBase - score * 2)

            local dentroX =
                birdX + radio > o.x and
                birdX - radio < o.x + obstaculoAncho

            local dentroHueco =
                (y + radio > o.gapY) and
                (y - radio < o.gapY + gapActual)

            if dentroX and dentroHueco and o.semilla then
                inmortal = true
                tiempoInmortal = duracionInmortal
                o.semilla = false
            end

            if dentroX and not dentroHueco and not inmortal then
                estado = "gameover"
                shakeDuracion = 0.4
                shakeMagnitud = 8
            end
        end
    end

    if estado == "gameover" then

        tiempoMuerte = tiempoMuerte + dt

        if tiempoMuerte > 0.15 then

            frameMuerte = frameMuerte + 1

            if frameMuerte > #muerte then
                frameMuerte = #muerte
            end

            tiempoMuerte = 0
        end
    end

    for i = 1, #estrellas do
        estrellas[i].brillo = 0.5 + math.sin(love.timer.getTime() * 2 + i) * 0.5
    end

    if shakeDuracion > 0 then
        shakeDuracion = shakeDuracion - dt
    end
end


function love.keypressed(key)

    if key == "escape" then
        if estado == "jugando" then
            pausado = not pausado
        end
    end

    if key == "space" then

        salto:stop()
        salto:play()

        if estado == "menu" then

            resetGame()

        elseif estado == "gameover" then

            resetGame()

        elseif estado == "jugando" and not pausado then

            velY = -250
        end
    end
end


function love.draw()

    local offsetX, offsetY = 0, 0

    love.graphics.clear(fondoColor)

    for i = 1, #estrellas do

        local s = estrellas[i]

        love.graphics.setColor(1, 1, 1, s.brillo)
        love.graphics.circle("fill", s.x, s.y, s.r)
    end

    love.graphics.setColor(1, 1, 0.9)
    love.graphics.circle("fill", luna.x, luna.y, luna.r)

    if estado == "jugando" or estado == "gameover" then

        if shakeDuracion > 0 then
            offsetX = love.math.random(-shakeMagnitud, shakeMagnitud)
            offsetY = love.math.random(-shakeMagnitud, shakeMagnitud)
        end

        love.graphics.push()
        love.graphics.translate(offsetX, offsetY)

        local obstaculoAncho = 50

        if estado == "gameover" then

            love.graphics.draw(
                muerte[frameMuerte],
                birdX,
                y,
                0,
                1,
                1,
                20,
                20
            )

        else

            love.graphics.draw(
                sprites[frame],
                birdX,
                y,
                0,
                1,
                1,
                20,
                20
            )
        end

        if inmortal then
            love.graphics.setColor(0.6, 0.2, 1, 0.25)
            love.graphics.circle("fill", birdX + 30, y + 20, 55)
        end

        for i = 1, #obstaculos do

            local o = obstaculos[i]

            love.graphics.setColor(o.color[1], o.color[2], o.color[3])

            local gapActual = math.max(70, gapBase - score * 2)

            love.graphics.rectangle("fill", o.x, 0, obstaculoAncho, o.gapY)

            love.graphics.rectangle(
                "fill",
                o.x,
                o.gapY + gapActual,
                obstaculoAncho,
                600
            )

            if o.semilla then
                love.graphics.setColor(0.7, 0.2, 1)
                love.graphics.circle(
                    "fill",
                    o.x + obstaculoAncho / 2,
                    o.gapY + gapActual / 2,
                    8
                )
            end
        end

        love.graphics.pop()
    end

    love.graphics.setColor(0, 1, 1)
    love.graphics.print("Score = " .. score, 700, 20)

    if estado == "gameover" then

        love.graphics.setColor(1, 1, 1)
        love.graphics.print("GAME OVER", 260, 220, 0, 3, 3)
        love.graphics.print("Presiona ESPACIO", 260, 280, 0, 2, 2)
    end

   if estado == "menu" then

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(menu, 0, 0, 0, menuScaleX, menuScaleY)

    love.graphics.setColor(0, 0, 0)

    love.graphics.print(
        "presiona ESPACIO para empezar",
        220, 320
    )

    love.graphics.print(
        "RAMON ACEVEDO",
        10, 10
    )    

    love.graphics.print(
        "ESCUELA CACIQUE PELAYO",
        10, 30
    )

end

    if pausado then

        tiempoPausa = tiempoPausa + love.timer.getDelta()

        love.graphics.setColor(0, 0, 0, 0.6)

        love.graphics.rectangle("fill", 0, 0, 800, 600)

        local alpha = 0.5 + math.sin(tiempoPausa * 3) * 0.5

        love.graphics.setColor(1, 1, 1, alpha)

        love.graphics.print("PAUSA", 320, 220, 0, 3, 3)

        love.graphics.setColor(1, 1, 1)

        love.graphics.print(
            "Pulsa ESC para continuar",
            220,
            300
        )
    end
end