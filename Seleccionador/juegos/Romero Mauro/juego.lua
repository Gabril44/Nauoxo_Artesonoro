------------------------------------------------------------
-- EL ÑANDÚ DEL CIELO
-- Juego 2D geométrico basado en el relato Qom
-- LÖVE2D
------------------------------------------------------------

local estado = "inicio"

local pantallaW = 960
local pantallaH = 540
local mundoW = 4200
local camaraX = 0
local gravedad = 1100

------------------------------------------------------------
-- SUELO VERDE
------------------------------------------------------------

local sueloVerdeY = 440
local jugadorSueloY = sueloVerdeY - 24
local hermanaSueloY = sueloVerdeY - 22
local perroSueloY = sueloVerdeY - 12

------------------------------------------------------------
-- JUGADOR
------------------------------------------------------------

local jugador = {
    x = 120,
    y = jugadorSueloY,
    w = 28,
    h = 48,
    vx = 0,
    vy = 0,
    velocidad = 260,
    salto = -500,
    suelo = true,
    vida = 3
}

------------------------------------------------------------
-- HERMANA
------------------------------------------------------------

local hermana = {
    x = 65,
    y = hermanaSueloY,
    distancia = 55
}

------------------------------------------------------------
-- PALOMA
------------------------------------------------------------

local paloma = {
    x = 900,
    y = 260,
    visible = true
}

local palomaHablo = false

------------------------------------------------------------
-- ANCIANA / BRUJA
------------------------------------------------------------

local anciana = {
    x = 1700,
    y = 365
}

local cercaAnciana = false

------------------------------------------------------------
-- FUEGO
------------------------------------------------------------

local fuego = {
    x = 1700,
    y = 420
}

------------------------------------------------------------
-- PERRITOS
------------------------------------------------------------

local perros = {
    x = 150,
    y = perroSueloY,
    activos = false
}

------------------------------------------------------------
-- MIEL
------------------------------------------------------------

local miel = {
    x = 600,
    y = 380,
    recogida = false
}

------------------------------------------------------------
-- SERPIENTE ARCO IRIS
------------------------------------------------------------

local serpiente = {
    x = 2500,
    y = 390,
    activa = true,
    avisoMostrado = false
}

------------------------------------------------------------
-- ÑANDÚ
------------------------------------------------------------

local nandu = {
    x = 2950,
    y = jugadorSueloY,
    w = 70,
    h = 50,
    vx = 0,
    vy = 0,
    velocidad = 260,
    visible = false
}

------------------------------------------------------------
-- PERSECUCIÓN
------------------------------------------------------------

local persecucionInicio = false
local nanduCorriendo = false
local nanduVolando = false
local distanciaPersecucion = 0
local nanduVelocidad = 210
local perrosVelocidad = 230

------------------------------------------------------------
-- CINEMÁTICA DEL VUELO
------------------------------------------------------------

local vueloTiempo = 0
local vueloDuracion = 4

local inicioVueloX = 0
local inicioVueloY = 0
local inicioJugadorX = 0
local inicioJugadorY = 0
local inicioHermanaX = 0
local inicioHermanaY = 0
local inicioPerrosX = 0
local inicioPerrosY = 0

------------------------------------------------------------
-- CINEMÁTICA FINAL DE CAPTURA
------------------------------------------------------------

local capturaTiempo = 0
local capturaDuracion = 5

local capturaInicioNanduX = 0
local capturaInicioNanduY = 0
local capturaInicioJugadorX = 0
local capturaInicioJugadorY = 0
local capturaInicioHermanaX = 0
local capturaInicioHermanaY = 0
local capturaInicioPerrosX = 0
local capturaInicioPerrosY = 0

local nanduAtrapado = false

------------------------------------------------------------
-- POSICIÓN DE LA CAPTURA
------------------------------------------------------------

local capturaCentroY = 285
local alturaNinos = 75
local alturaPerros = 110

------------------------------------------------------------
-- FINAL
------------------------------------------------------------

local finalTiempo = 0
local finalDuracion = 4

------------------------------------------------------------
-- TRANSICIÓN A IMAGEN
------------------------------------------------------------

local imagenTransicionTiempo = 0
local imagenTransicionDuracion = 2

local imagenFinal = nil
local imagenFinalRuta = "imagen_final.png"

------------------------------------------------------------
-- DATOS DEL PROYECTO
------------------------------------------------------------

local foto = nil
local fotoRuta = "foto.png"

------------------------------------------------------------
-- MENSAJES
------------------------------------------------------------

local mensaje = ""
local tiempoMensaje = 0

------------------------------------------------------------
-- ESTRELLAS
------------------------------------------------------------

local estrellas = {}

------------------------------------------------------------
-- PARTÍCULAS
------------------------------------------------------------

local particulas = {}

------------------------------------------------------------
-- MOSTRAR MENSAJE
------------------------------------------------------------

function mostrarMensaje(texto, tiempo)

    mensaje = texto
    tiempoMensaje = tiempo or 4

end

------------------------------------------------------------
-- DISTANCIA
------------------------------------------------------------

function distancia(x1, y1, x2, y2)

    local dx = x1 - x2
    local dy = y1 - y2

    return math.sqrt(dx * dx + dy * dy)

end

------------------------------------------------------------
-- PARTÍCULA
------------------------------------------------------------

function agregarParticula(x, y)

    table.insert(
        particulas,
        {
            x = x,
            y = y,
            vx = (math.random() - 0.5) * 120,
            vy = (math.random() - 0.5) * 120,
            vida = 1,
            tam = math.random(2, 5)
        }
    )

end

------------------------------------------------------------
-- LOAD
------------------------------------------------------------

function love.load()

    love.window.setMode(
        pantallaW,
        pantallaH,
        {
            fullscreen = true,
            fullscreentype = "desktop"
        }
    )

    love.window.setTitle(
        "El Ñandú del Cielo"
    )

    math.randomseed(os.time())

    for i = 1, 150 do

        table.insert(
            estrellas,
            {
                x = math.random(0, 5000),
                y = math.random(0, 500),
                tam = math.random(1, 3)
            }
        )

    end

    if love.filesystem.getInfo(imagenFinalRuta) then

        imagenFinal =
            love.graphics.newImage(
                imagenFinalRuta
            )

    end

    if love.filesystem.getInfo(fotoRuta) then

        foto =
            love.graphics.newImage(
                fotoRuta
            )

    end

end

------------------------------------------------------------
-- TECLA PRESIONADA
------------------------------------------------------------

function love.keypressed(key)

    if estado == "inicio" then

        if key == "space"
        or key == "return" then

            estado = "monte"

            mostrarMensaje(
                "Los dos hermanos comienzan su viaje por el monte.",
                5
            )

        end

    elseif estado == "monte"
    or estado == "perritos" then

        if key == "space" then

            if jugador.suelo then

                jugador.vy = jugador.salto
                jugador.suelo = false

            end

        end

        if estado == "perritos"
        and key == "space"
        and serpiente.activa
        and jugador.x >= 2200
        and jugador.x <= 2650 then

            serpiente.activa = false

            mostrarMensaje(
                "¡Los perritos atacaron y derrotaron a la serpiente Arco Iris!",
                5
            )

            for i = 1, 30 do

                agregarParticula(
                    serpiente.x,
                    serpiente.y
                )

            end

        end

    elseif estado == "anciana" then

        if key == "space" then

            estado = "fuego"

            mostrarMensaje(
                "Anciana: ¡Niños, acérquense y soplen el fuego!",
                4
            )

        end

    elseif estado == "fuego" then

        if key == "e" then

            estado = "empujar"

            mostrarMensaje(
                "Recuerdan el consejo de la paloma. ¡No deben soplar!",
                4
            )

        end

    elseif estado == "empujar" then

        if key == "space" then

            estado = "perritos"

            perros.activos = true
            perros.x = jugador.x - 55
            perros.y = perroSueloY

            mostrarMensaje(
                "¡Los hermanos empujaron a la anciana! Aparecieron dos perritos.",
                5
            )

        end

    elseif estado == "final" then

        if key == "return" then
            reiniciar()
        end

    elseif estado == "imagen_final" then

        if key == "return" then
            reiniciar()
        end

    end

end

------------------------------------------------------------
-- REINICIAR
------------------------------------------------------------

function reiniciar()

    estado = "inicio"
    camaraX = 0

    jugador.x = 120
    jugador.y = jugadorSueloY
    jugador.vx = 0
    jugador.vy = 0
    jugador.vida = 3
    jugador.suelo = true

    hermana.x = 65
    hermana.y = hermanaSueloY

    perros.x = 150
    perros.y = perroSueloY
    perros.activos = false

    miel.recogida = false

    paloma.x = 900
    paloma.y = 260
    paloma.visible = true
    palomaHablo = false

    cercaAnciana = false

    anciana.x = 1700
    anciana.y = 365

    fuego.x = 1700
    fuego.y = 420

    serpiente.x = 2500
    serpiente.y = 390
    serpiente.activa = true
    serpiente.avisoMostrado = false

    nandu.x = 2950
    nandu.y = jugadorSueloY
    nandu.vx = 0
    nandu.vy = 0
    nandu.visible = false

    persecucionInicio = false
    nanduCorriendo = false
    nanduVolando = false
    distanciaPersecucion = 0

    vueloTiempo = 0

    inicioVueloX = 0
    inicioVueloY = 0
    inicioJugadorX = 0
    inicioJugadorY = 0
    inicioHermanaX = 0
    inicioHermanaY = 0
    inicioPerrosX = 0
    inicioPerrosY = 0

    capturaTiempo = 0

    capturaInicioNanduX = 0
    capturaInicioNanduY = 0
    capturaInicioJugadorX = 0
    capturaInicioJugadorY = 0
    capturaInicioHermanaX = 0
    capturaInicioHermanaY = 0
    capturaInicioPerrosX = 0
    capturaInicioPerrosY = 0

    nanduAtrapado = false

    finalTiempo = 0
    imagenTransicionTiempo = 0
    mensaje = ""
    tiempoMensaje = 0
    particulas = {}

end

------------------------------------------------------------
-- UPDATE
------------------------------------------------------------

function love.update(dt)

    if tiempoMensaje > 0 then
        tiempoMensaje = tiempoMensaje - dt
    end

    if palomaHablo
    and tiempoMensaje <= 0 then

        paloma.visible = false
        paloma.x = -1000
        paloma.y = -1000

    end

    for i = #particulas, 1, -1 do

        local p = particulas[i]

        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        p.vida = p.vida - dt

        if p.vida <= 0 then

            table.remove(
                particulas,
                i
            )

        end

    end

    if estado == "monte"
    or estado == "perritos"
    or estado == "anciana"
    or estado == "fuego"
    or estado == "empujar" then

        actualizarJugador(dt)
        actualizarHermana(dt)

        if not miel.recogida then

            if distancia(
                jugador.x,
                jugador.y,
                miel.x,
                miel.y
            ) < 50 then

                miel.recogida = true

                mostrarMensaje(
                    "Encontraron miel silvestre.",
                    3
                )

            end

        end

        if estado == "monte"
        and paloma.visible
        and not palomaHablo then

            if distancia(
                jugador.x,
                jugador.y,
                paloma.x,
                paloma.y
            ) < 70 then

                palomaHablo = true

                mostrarMensaje(
                    "Paloma: ¡Cuidado! La anciana puede matarlos. ¡No soplen su fuego!",
                    6
                )

            end

        end

        if estado == "monte"
        and jugador.x > 1550 then

            estado = "anciana"
            jugador.x = 1500

            actualizarHermana(dt)

            cercaAnciana = true

            mostrarMensaje(
                "Encontraste a la anciana.",
                3
            )

        end

        if estado == "perritos" then

            perros.x = jugador.x - 55
            perros.y = perroSueloY

            if jugador.x >= 2200
            and jugador.x <= 2650
            and serpiente.activa
            and not serpiente.avisoMostrado then

                serpiente.avisoMostrado = true

                mostrarMensaje(
                    "¡Una enorme serpiente Arco Iris! Presiona ESPACIO para ordenar el ataque.",
                    5
                )

            end

            if jugador.x > 2750
            and not serpiente.activa
            and not persecucionInicio then

                iniciarPersecucion()

            end

        end

    end

    if estado == "persecucion" then
        actualizarPersecucion(dt)
    end

    if estado == "vuelo_cinematica" then
        actualizarVueloCinematica(dt)
    end

    if estado == "captura" then
        actualizarCaptura(dt)
    end

    if estado == "final" then

        finalTiempo = finalTiempo + dt

        if finalTiempo >= finalDuracion then

            estado = "transicion_imagen"
            imagenTransicionTiempo = 0

        end

    end

    if estado == "transicion_imagen" then

        imagenTransicionTiempo =
            imagenTransicionTiempo + dt

        if imagenTransicionTiempo >= imagenTransicionDuracion then

            estado = "imagen_final"

            imagenTransicionTiempo =
                imagenTransicionDuracion

        end

    end

    if estado == "monte"
    or estado == "perritos"
    or estado == "anciana"
    or estado == "fuego"
    or estado == "empujar"
    or estado == "persecucion" then

        camaraX =
            jugador.x -
            pantallaW * 0.35

        camaraX =
            math.max(
                0,
                math.min(
                    mundoW - pantallaW,
                    camaraX
                )
            )

    elseif estado == "vuelo_cinematica" then

        camaraX =
            nandu.x -
            pantallaW * 0.5

    elseif estado == "captura" then

        camaraX =
            nandu.x -
            pantallaW * 0.5

    end

end

------------------------------------------------------------
-- ACTUALIZAR JUGADOR
------------------------------------------------------------

function actualizarJugador(dt)

    jugador.vx = 0

    if love.keyboard.isDown("a")
    or love.keyboard.isDown("left") then

        jugador.vx =
            -jugador.velocidad

    end

    if love.keyboard.isDown("d")
    or love.keyboard.isDown("right") then

        jugador.vx =
            jugador.velocidad

    end

    jugador.x =
        jugador.x +
        jugador.vx * dt

    jugador.x =
        math.max(
            30,
            math.min(
                mundoW - 30,
                jugador.x
            )
        )

    jugador.vy =
        jugador.vy +
        gravedad * dt

    jugador.y =
        jugador.y +
        jugador.vy * dt

    if jugador.y >= jugadorSueloY then

        jugador.y = jugadorSueloY
        jugador.vy = 0
        jugador.suelo = true

    else

        jugador.suelo = false

    end

end

------------------------------------------------------------
-- ACTUALIZAR HERMANA
------------------------------------------------------------

function actualizarHermana(dt)

    local objetivoX =
        jugador.x -
        hermana.distancia

    hermana.x =
        hermana.x +
        (objetivoX - hermana.x) *
        8 *
        dt

    if math.abs(
        hermana.x - objetivoX
    ) > 120 then

        hermana.x = objetivoX

    end

    hermana.y = hermanaSueloY

end

------------------------------------------------------------
-- INICIAR PERSECUCIÓN
------------------------------------------------------------

function iniciarPersecucion()

    estado = "persecucion"

    persecucionInicio = true
    nandu.visible = true

    nandu.x =
        jugador.x + 180

    nandu.y = jugadorSueloY

    nanduCorriendo = false
    nanduVolando = false
    distanciaPersecucion = 0

    jugador.y = jugadorSueloY

    hermana.x =
        jugador.x - 55

    hermana.y = hermanaSueloY

    perros.y = perroSueloY

    mostrarMensaje(
        "¡Miren! ¡Un Ñandú! ¡Los niños y los perritos comienzan a seguirlo!",
        4
    )

end

------------------------------------------------------------
-- ACTUALIZAR PERSECUCIÓN
------------------------------------------------------------

function actualizarPersecucion(dt)

    if not nanduCorriendo then

        if tiempoMensaje <= 0 then

            nanduCorriendo = true

            mostrarMensaje(
                "¡El Ñandú sale corriendo! ¡Síganlo!",
                3
            )

        end

        return

    end

    nandu.x =
        nandu.x +
        nanduVelocidad * dt

    jugador.vx =
        jugador.velocidad

    jugador.x =
        jugador.x +
        jugador.velocidad * dt

    jugador.y = jugadorSueloY

    hermana.x =
        jugador.x - 55

    hermana.y = hermanaSueloY

    perros.x =
        perros.x +
        perrosVelocidad * dt

    distanciaPersecucion =
        distanciaPersecucion +
        nanduVelocidad * dt

    nandu.y =
        jugadorSueloY -
        math.abs(
            math.sin(
                distanciaPersecucion * 0.025
            )
        ) * 55

    perros.y =
        nandu.y + 35

    if math.random() < 0.2 then

        agregarParticula(
            nandu.x - 30,
            nandu.y + 20
        )

    end

    if distanciaPersecucion > 700 then

        comenzarVuelo()

    end

end

------------------------------------------------------------
-- COMENZAR VUELO
------------------------------------------------------------

function comenzarVuelo()

    if nanduVolando then
        return
    end

    nanduVolando = true

    estado = "vuelo_cinematica"

    vueloTiempo = 0

    inicioVueloX = nandu.x
    inicioVueloY = nandu.y

    inicioJugadorX = jugador.x
    inicioJugadorY = jugador.y

    inicioHermanaX = hermana.x
    inicioHermanaY = hermana.y

    inicioPerrosX = perros.x
    inicioPerrosY = perros.y

    mostrarMensaje(
        "¡El Ñandú salta... y comienza a volar! ¡Los niños y los perritos lo siguen!",
        4
    )

end

------------------------------------------------------------
-- CINEMÁTICA DEL VUELO
------------------------------------------------------------

function actualizarVueloCinematica(dt)

    vueloTiempo =
        vueloTiempo + dt

    local progreso =
        vueloTiempo /
        vueloDuracion

    progreso =
        math.min(
            progreso,
            1
        )

    nandu.x =
        inicioVueloX +
        progreso * 500

    nandu.y =
        inicioVueloY -
        progreso * 350

    jugador.x =
        inicioJugadorX +
        progreso * 500

    jugador.y =
        inicioJugadorY -
        progreso * 350

    hermana.x =
        inicioHermanaX +
        progreso * 500

    hermana.y =
        inicioHermanaY -
        progreso * 350

    perros.x =
        inicioPerrosX +
        progreso * 500

    perros.y =
        inicioPerrosY -
        progreso * 350

    if math.random() < 0.35 then

        agregarParticula(
            nandu.x - 30,
            nandu.y + 20
        )

    end

    nandu.y =
        nandu.y +
        math.sin(
            vueloTiempo * 10
        ) * 5

    if progreso >= 1 then
        comenzarCaptura()
    end

end

------------------------------------------------------------
-- COMENZAR CAPTURA
------------------------------------------------------------

function comenzarCaptura()

    estado = "captura"

    capturaTiempo = 0
    nanduAtrapado = false

    capturaInicioNanduX = nandu.x
    capturaInicioNanduY = nandu.y

    capturaInicioJugadorX = jugador.x
    capturaInicioJugadorY = jugador.y

    capturaInicioHermanaX = hermana.x
    capturaInicioHermanaY = hermana.y

    capturaInicioPerrosX = perros.x
    capturaInicioPerrosY = perros.y

    mostrarMensaje(
        "¡Los niños y los perritos alcanzaron al Ñandú!",
        4
    )

end

------------------------------------------------------------
-- CINEMÁTICA FINAL DE CAPTURA
------------------------------------------------------------

function actualizarCaptura(dt)

    capturaTiempo =
        capturaTiempo + dt

    local progreso =
        capturaTiempo /
        capturaDuracion

    progreso =
        math.min(
            progreso,
            1
        )

    if progreso < 0.35 then

        local p =
            progreso / 0.35

        nandu.x =
            capturaInicioNanduX -
            p * 80

        nandu.y =
            capturaInicioNanduY +
            p * (
                capturaCentroY -
                capturaInicioNanduY
            )

        jugador.x =
            capturaInicioJugadorX +
            p * 60

        jugador.y =
            capturaInicioJugadorY +
            p * (
                (capturaCentroY + alturaNinos) -
                capturaInicioJugadorY
            )

        hermana.x =
            capturaInicioHermanaX +
            p * 40

        hermana.y =
            capturaInicioHermanaY +
            p * (
                (capturaCentroY + alturaNinos) -
                capturaInicioHermanaY
            )

        perros.x =
            capturaInicioPerrosX +
            p * 60

        perros.y =
            capturaInicioPerrosY +
            p * (
                (capturaCentroY + alturaPerros) -
                capturaInicioPerrosY
            )

    elseif progreso < 0.70 then

        local p =
            (progreso - 0.35) /
            0.35

        nandu.x =
            capturaInicioNanduX -
            80 +
            p * 35

        nandu.y =
            capturaCentroY

        jugador.x =
            nandu.x -
            100 +
            p * 70

        jugador.y =
            nandu.y +
            alturaNinos

        hermana.x =
            nandu.x +
            85 -
            p * 65

        hermana.y =
            nandu.y +
            alturaNinos

        perros.x =
            nandu.x -
            50 +
            p * 25

        perros.y =
            nandu.y +
            alturaPerros

    else

        local p =
            (progreso - 0.70) /
            0.30

        nandu.x =
            capturaInicioNanduX -
            45

        nandu.y =
            capturaCentroY

        jugador.x =
            nandu.x -
            55 +
            p * 10

        jugador.y =
            nandu.y +
            alturaNinos

        hermana.x =
            nandu.x +
            55 -
            p * 10

        hermana.y =
            nandu.y +
            alturaNinos

        perros.x =
            nandu.x - 45

        perros.y =
            nandu.y +
            alturaPerros

        if not nanduAtrapado then

            nanduAtrapado = true

            mostrarMensaje(
                "¡Lo atraparon! Los niños y los perritos rodearon al Ñandú.",
                4
            )

            for i = 1, 50 do

                agregarParticula(
                    nandu.x,
                    nandu.y
                )

            end

        end

    end

    if capturaTiempo >= capturaDuracion then

        estado = "final"
        finalTiempo = 0

        mostrarMensaje(
            "Los niños, los perritos y el Ñandú quedaron unidos para siempre en el cielo.",
            5
        )

    end

end

------------------------------------------------------------
-- DRAW
------------------------------------------------------------

function love.draw()

    local ventanaW, ventanaH =
        love.graphics.getDimensions()

    local escala =
        math.min(
            ventanaW / pantallaW,
            ventanaH / pantallaH
        )

    local desplazamientoX =
        (ventanaW - pantallaW * escala) / 2

    local desplazamientoY =
        (ventanaH - pantallaH * escala) / 2

    love.graphics.clear(0, 0, 0, 1)
    love.graphics.push()
    love.graphics.translate(
        desplazamientoX,
        desplazamientoY
    )
    love.graphics.scale(
        escala,
        escala
    )

    if estado == "inicio" then

        dibujarInicio()

    elseif estado == "vuelo_cinematica"
    or estado == "captura" then

        dibujarCielo()

    elseif estado == "final" then

        dibujarFinal()

    elseif estado == "transicion_imagen" then

        dibujarFinal()

        local progreso =
            imagenTransicionTiempo /
            imagenTransicionDuracion

        progreso =
            math.min(
                progreso,
                1
            )

        love.graphics.setColor(
            0,
            0,
            0,
            progreso
        )

        love.graphics.rectangle(
            "fill",
            0,
            0,
            pantallaW,
            pantallaH
        )

        if imagenFinal then

            dibujarImagenFinal(
                progreso
            )

        end

    elseif estado == "imagen_final" then

        dibujarImagenFinal(1)

    else

        dibujarMonte()

    end

    --------------------------------------------------------
    -- AVISOS
    --------------------------------------------------------

    if tiempoMensaje > 0
    and estado ~= "imagen_final" then

        love.graphics.setColor(
            0,
            0,
            0,
            0.80
        )

        love.graphics.rectangle(
            "fill",
            80,
            25,
            800,
            90,
            15
        )

        love.graphics.setColor(
            1,
            1,
            1
        )

        love.graphics.setFont(
            love.graphics.newFont(22)
        )

        love.graphics.printf(
            mensaje,
            105,
            42,
            750,
            "center"
        )

    end

    if estado == "anciana"
    and tiempoMensaje <= 0 then

        dibujarBoton(
            "ESPACIO - INTERACTUAR",
            260,
            420,
            440,
            60
        )

    end

    if estado == "fuego"
    and tiempoMensaje <= 0 then

        dibujarBoton(
            "E - RECORDAR EL CONSEJO",
            240,
            420,
            480,
            60
        )

    end

    if estado == "empujar"
    and tiempoMensaje <= 0 then

        dibujarBoton(
            "ESPACIO - EMPUJAR",
            260,
            420,
            440,
            60
        )

    end

    if estado == "perritos"
    and serpiente.activa
    and jugador.x >= 2200
    and jugador.x <= 2650
    and tiempoMensaje <= 0 then

        dibujarBoton(
            "ESPACIO - ORDENAR ATAQUE",
            230,
            420,
            500,
            60
        )

    end

    --------------------------------------------------------
    -- DATOS DEL PROYECTO
    --------------------------------------------------------

    dibujarDatosProyecto()

    love.graphics.pop()

end

------------------------------------------------------------
-- DATOS DEL PROYECTO
------------------------------------------------------------

function dibujarDatosProyecto()

    local margen = 12
    local ancho = 270
    local alto = 72

    local x =
        pantallaW -
        ancho -
        margen

    local y =
        pantallaH -
        alto -
        margen

    love.graphics.setColor(
        0,
        0,
        0,
        0.68
    )

    love.graphics.rectangle(
        "fill",
        x,
        y,
        ancho,
        alto,
        8
    )

    if foto then

        local fw = foto:getWidth()
        local fh = foto:getHeight()

        local escala =
            math.min(
                52 / fw,
                58 / fh
            )

        local nuevoAncho =
            fw * escala

        local nuevoAlto =
            fh * escala

        love.graphics.setColor(
            1,
            1,
            1,
            1
        )

        love.graphics.draw(
            foto,
            x + 8,
            y + (alto - nuevoAlto) / 2,
            0,
            escala,
            escala
        )

    end

    love.graphics.setColor(
        1,
        1,
        1,
        1
    )

    love.graphics.setFont(
        love.graphics.newFont(13)
    )

    love.graphics.print(
        "Mauro Romero",
        x + 68,
        y + 7
    )

    love.graphics.setFont(
        love.graphics.newFont(9)
    )

    love.graphics.print(
        "U.E.G.P. Nº 72 CACIQUE PELAYO",
        x + 68,
        y + 28
    )

    love.graphics.print(
        "Nauoxo: El ñandú en el cielo",
        x + 68,
        y + 46
    )

end

------------------------------------------------------------
-- BOTÓN
------------------------------------------------------------

function dibujarBoton(texto, x, y, w, h)

    love.graphics.setColor(
        0,
        0,
        0,
        0.85
    )

    love.graphics.rectangle(
        "fill",
        x,
        y,
        w,
        h,
        12
    )

    love.graphics.setColor(
        1,
        1,
        1
    )

    love.graphics.printf(
        texto,
        x,
        y + 20,
        w,
        "center"
    )

end

------------------------------------------------------------
-- MONTE
------------------------------------------------------------

function dibujarMonte()

    love.graphics.clear(
        0.08,
        0.25,
        0.15
    )

    love.graphics.setColor(
        0.20,
        0.45,
        0.65
    )

    love.graphics.rectangle(
        "fill",
        0,
        0,
        pantallaW,
        440
    )

    love.graphics.setColor(
        0.12,
        0.30,
        0.20
    )

    for x = -200, 1200, 250 do

        love.graphics.polygon(
            "fill",
            x,
            440,
            x + 125,
            230,
            x + 250,
            440
        )

    end

    love.graphics.setColor(
        0.10,
        0.32,
        0.12
    )

    love.graphics.rectangle(
        "fill",
        0,
        sueloVerdeY,
        pantallaW,
        pantallaH - sueloVerdeY
    )

    love.graphics.setColor(
        0.30,
        0.20,
        0.10
    )

    love.graphics.rectangle(
        "fill",
        -camaraX,
        400,
        mundoW,
        sueloVerdeY - 400
    )

    for x = 100, 4200, 280 do

        dibujarArbol(
            x - camaraX,
            sueloVerdeY
        )

    end

    if not miel.recogida then

        dibujarMiel(
            miel.x - camaraX,
            miel.y
        )

    end

    if paloma.visible then

        dibujarPaloma(
            paloma.x - camaraX,
            paloma.y
        )

    end

    if estado == "anciana"
    or estado == "fuego"
    or estado == "empujar" then

        dibujarAnciana(
            anciana.x - camaraX,
            anciana.y
        )

        dibujarFuego(
            fuego.x - camaraX,
            fuego.y
        )

    end

    if estado == "perritos"
    and serpiente.activa then

        dibujarSerpiente(
            serpiente.x - camaraX,
            serpiente.y
        )

    end

    if perros.activos then

        dibujarPerros(
            perros.x - camaraX,
            perros.y
        )

    end

    if nandu.visible
    and estado == "persecucion" then

        dibujarNanduObjeto(
            nandu.x - camaraX,
            nandu.y,
            1
        )

    end

    dibujarJugador(
        jugador.x - camaraX,
        jugador.y
    )

    dibujarHermana(
        hermana.x - camaraX,
        hermana.y
    )

    --------------------------------------------------------
    -- CONTROLES
    --------------------------------------------------------

    love.graphics.setColor(
        1,
        1,
        1
    )

    love.graphics.print(
        "A/D: mover   ESPACIO: saltar",
        20,
        500
    )

end

------------------------------------------------------------
-- ÁRBOL
------------------------------------------------------------

function dibujarArbol(x, y)

    love.graphics.setColor(
        0.25,
        0.12,
        0.05
    )

    love.graphics.rectangle(
        "fill",
        x - 12,
        y - 100,
        24,
        100
    )

    love.graphics.setColor(
        0.05,
        0.35,
        0.12
    )

    love.graphics.polygon(
        "fill",
        x,
        y - 180,
        x - 65,
        y - 70,
        x + 65,
        y - 70
    )

    love.graphics.setColor(
        0.08,
        0.45,
        0.15
    )

    love.graphics.polygon(
        "fill",
        x,
        y - 145,
        x - 50,
        y - 45,
        x + 50,
        y - 45
    )

end

------------------------------------------------------------
-- JUGADOR
------------------------------------------------------------

function dibujarJugador(x, y)

    love.graphics.setColor(
        0.85,
        0.25,
        0.25
    )

    love.graphics.rectangle(
        "fill",
        x - 14,
        y - 24,
        28,
        48,
        7
    )

    love.graphics.setColor(
        1,
        0.75,
        0.55
    )

    love.graphics.circle(
        "fill",
        x,
        y - 35,
        13
    )

    love.graphics.setColor(
        0.1,
        0.1,
        0.1
    )

    love.graphics.rectangle(
        "fill",
        x - 13,
        y - 47,
        26,
        7
    )

end

------------------------------------------------------------
-- HERMANA
------------------------------------------------------------

function dibujarHermana(x, y)

    love.graphics.setColor(
        0.75,
        0.35,
        0.8
    )

    love.graphics.rectangle(
        "fill",
        x - 12,
        y - 22,
        24,
        44,
        7
    )

    love.graphics.setColor(
        1,
        0.75,
        0.55
    )

    love.graphics.circle(
        "fill",
        x,
        y - 32,
        12
    )

end

------------------------------------------------------------
-- MIEL
------------------------------------------------------------

function dibujarMiel(x, y)

    love.graphics.setColor(
        0.65,
        0.35,
        0.05
    )

    love.graphics.rectangle(
        "fill",
        x - 22,
        y - 20,
        44,
        40,
        8
    )

    love.graphics.setColor(
        1,
        0.75,
        0.1
    )

    love.graphics.rectangle(
        "fill",
        x - 15,
        y - 13,
        30,
        26,
        5
    )

end

------------------------------------------------------------
-- PALOMA
------------------------------------------------------------

function dibujarPaloma(x, y)

    love.graphics.setColor(
        0.9,
        0.9,
        0.95
    )

    love.graphics.circle(
        "fill",
        x,
        y,
        16
    )

    love.graphics.polygon(
        "fill",
        x - 10,
        y,
        x - 45,
        y - 20,
        x - 30,
        y + 10
    )

    love.graphics.polygon(
        "fill",
        x + 10,
        y,
        x + 45,
        y - 20,
        x + 30,
        y + 10
    )

    love.graphics.setColor(
        1,
        0.75,
        0.1
    )

    love.graphics.polygon(
        "fill",
        x + 15,
        y,
        x + 30,
        y + 5,
        x + 15,
        y + 8
    )

end

------------------------------------------------------------
-- ANCIANA / BRUJA
------------------------------------------------------------

function dibujarAnciana(x, y)

    love.graphics.setColor(
        0.35,
        0.08,
        0.35
    )

    love.graphics.polygon(
        "fill",
        x,
        y - 100,
        x - 45,
        y,
        x + 45,
        y
    )

    love.graphics.setColor(
        0.85,
        0.65,
        0.45
    )

    love.graphics.circle(
        "fill",
        x,
        y - 100,
        25
    )

    love.graphics.setColor(
        0.15,
        0.05,
        0.15
    )

    love.graphics.circle(
        "fill",
        x - 8,
        y - 105,
        3
    )

    love.graphics.circle(
        "fill",
        x + 8,
        y - 105,
        3
    )

end

------------------------------------------------------------
-- FUEGO
------------------------------------------------------------

function dibujarFuego(x, y)

    love.graphics.setColor(
        0.8,
        0.2,
        0.05
    )

    love.graphics.polygon(
        "fill",
        x,
        y - 70,
        x - 30,
        y,
        x + 30,
        y
    )

    love.graphics.setColor(
        1,
        0.75,
        0.05
    )

    love.graphics.polygon(
        "fill",
        x,
        y - 50,
        x - 15,
        y,
        x + 15,
        y
    )

end

------------------------------------------------------------
-- PERRITOS
------------------------------------------------------------

function dibujarPerros(x, y)

    dibujarPerro(
        x,
        y
    )

    dibujarPerro(
        x + 35,
        y
    )

end

function dibujarPerro(x, y)

    love.graphics.setColor(
        0.65,
        0.40,
        0.20
    )

    love.graphics.rectangle(
        "fill",
        x - 18,
        y - 12,
        36,
        24,
        6
    )

    love.graphics.circle(
        "fill",
        x + 20,
        y - 15,
        13
    )

    love.graphics.polygon(
        "fill",
        x + 12,
        y - 23,
        x + 5,
        y - 42,
        x + 20,
        y - 27
    )

end

------------------------------------------------------------
-- SERPIENTE ARCO IRIS
------------------------------------------------------------

function dibujarSerpiente(x, y)

    local colores = {
        {1, 0.1, 0.1},
        {1, 0.6, 0.1},
        {1, 1, 0.1},
        {0.2, 1, 0.2},
        {0.2, 0.7, 1},
        {0.5, 0.2, 1}
    }

    for i = 1, 6 do

        love.graphics.setColor(
            colores[i]
        )

        love.graphics.circle(
            "fill",
            x + (i - 3) * 18,
            y - math.sin(i) * 15,
            18
        )

    end

end

------------------------------------------------------------
-- ÑANDÚ
------------------------------------------------------------

function dibujarNanduObjeto(x, y, escala)

    escala = escala or 1

    love.graphics.push()

    love.graphics.translate(
        x,
        y
    )

    love.graphics.scale(
        escala,
        escala
    )

    love.graphics.setColor(
        0.25,
        0.25,
        0.28
    )

    love.graphics.circle(
        "fill",
        0,
        0,
        35
    )

    love.graphics.rectangle(
        "fill",
        25,
        -70,
        14,
        75
    )

    love.graphics.circle(
        "fill",
        35,
        -78,
        18
    )

    love.graphics.setColor(
        0.85,
        0.65,
        0.1
    )

    love.graphics.polygon(
        "fill",
        48,
        -78,
        75,
        -70,
        48,
        -65
    )

    love.graphics.setColor(
        0.2,
        0.2,
        0.2
    )

    love.graphics.setLineWidth(7)

    love.graphics.line(
        -15,
        25,
        -15,
        75
    )

    love.graphics.line(
        15,
        25,
        15,
        75
    )

    love.graphics.setColor(
        0.35,
        0.35,
        0.38
    )

    love.graphics.polygon(
        "fill",
        -20,
        -5,
        -75,
        -35,
        -45,
        15
    )

    love.graphics.pop()

end

------------------------------------------------------------
-- CIELO
------------------------------------------------------------

function dibujarCielo()

    love.graphics.clear(
        0.02,
        0.03,
        0.15
    )

    for _, estrella in ipairs(estrellas) do

        local x =
            estrella.x - camaraX

        if x > -10
        and x < 970 then

            love.graphics.setColor(
                1,
                1,
                1,
                0.8
            )

            love.graphics.circle(
                "fill",
                x,
                estrella.y,
                estrella.tam
            )

        end

    end

    love.graphics.setColor(
        0.95,
        0.95,
        0.8
    )

    love.graphics.circle(
        "fill",
        800,
        100,
        55
    )

    love.graphics.setColor(
        0.02,
        0.03,
        0.15
    )

    love.graphics.circle(
        "fill",
        820,
        85,
        55
    )

    dibujarNanduObjeto(
        nandu.x - camaraX,
        nandu.y,
        1.2
    )

    if estado == "captura" then

        dibujarJugador(
            jugador.x - camaraX,
            jugador.y
        )

        dibujarHermana(
            hermana.x - camaraX,
            hermana.y
        )

        if perros.activos then

            dibujarPerros(
                perros.x - camaraX,
                perros.y
            )

        end

        if nanduAtrapado then

            love.graphics.setColor(
                1,
                0.75,
                0.55
            )

            love.graphics.setLineWidth(6)

            love.graphics.line(
                jugador.x - camaraX + 10,
                jugador.y - 5,
                nandu.x - camaraX - 20,
                nandu.y
            )

            love.graphics.line(
                hermana.x - camaraX - 10,
                hermana.y - 5,
                nandu.x - camaraX + 20,
                nandu.y
            )

        end

    end

    for _, p in ipairs(particulas) do

        love.graphics.setColor(
            1,
            1,
            1,
            p.vida
        )

        love.graphics.circle(
            "fill",
            p.x - camaraX,
            p.y,
            p.tam
        )

    end

    love.graphics.setColor(
        1,
        1,
        1
    )

    love.graphics.setFont(
        love.graphics.newFont(26)
    )

    if estado == "captura" then

        love.graphics.printf(
            "LOS NIÑOS Y LOS PERRITOS ATRAPAN AL ÑANDÚ",
            0,
            25,
            960,
            "center"
        )

    else

        love.graphics.printf(
            "EL ÑANDÚ VUELA POR EL CIELO",
            0,
            25,
            960,
            "center"
        )

    end

end

------------------------------------------------------------
-- INICIO
------------------------------------------------------------

function dibujarInicio()

    love.graphics.clear(
        0.04,
        0.08,
        0.16
    )

    love.graphics.setColor(
        0.2,
        0.7,
        0.4
    )

    love.graphics.rectangle(
        "fill",
        0,
        420,
        960,
        120
    )

    love.graphics.setColor(
        1,
        1,
        1
    )

    love.graphics.setFont(
        love.graphics.newFont(46)
    )

    love.graphics.printf(
        "EL ÑANDÚ DEL CIELO",
        0,
        120,
        960,
        "center"
    )

    love.graphics.setFont(
        love.graphics.newFont(24)
    )

    love.graphics.printf(
        "Una aventura del pueblo Qom",
        0,
        190,
        960,
        "center"
    )

    dibujarNanduObjeto(
        480,
        320,
        1.5
    )

    love.graphics.setFont(
        love.graphics.newFont(20)
    )

    love.graphics.printf(
        "ESPACIO / ENTER para comenzar",
        0,
        460,
        960,
        "center"
    )

end

------------------------------------------------------------
-- FINAL
------------------------------------------------------------

function dibujarFinal()

    love.graphics.clear(
        0.015,
        0.02,
        0.10
    )

    for _, estrella in ipairs(estrellas) do

        love.graphics.setColor(
            1,
            1,
            1
        )

        love.graphics.circle(
            "fill",
            estrella.x % 960,
            estrella.y,
            estrella.tam
        )

    end

    local puntos = {
        {330, 280},
        {410, 230},
        {490, 260},
        {570, 210},
        {650, 250}
    }

    love.graphics.setColor(
        1,
        1,
        1
    )

    for i = 1, #puntos do

        love.graphics.circle(
            "fill",
            puntos[i][1],
            puntos[i][2],
            7
        )

        if i > 1 then

            love.graphics.line(
                puntos[i - 1][1],
                puntos[i - 1][2],
                puntos[i][1],
                puntos[i][2]
            )

        end

    end

    dibujarNanduObjeto(
        480,
        285,
        1.5
    )

    dibujarJugador(
        370,
        350
    )

    dibujarHermana(
        590,
        350
    )

    dibujarPerros(
        435,
        385
    )

    love.graphics.setColor(
        1,
        0.75,
        0.55
    )

    love.graphics.setLineWidth(5)

    love.graphics.line(
        380,
        345,
        440,
        310
    )

    love.graphics.line(
        580,
        345,
        520,
        310
    )

    love.graphics.setColor(
        1,
        1,
        1
    )

    love.graphics.setFont(
        love.graphics.newFont(44)
    )

    love.graphics.printf(
        "EL ÑANDÚ DEL CIELO",
        0,
        80,
        960,
        "center"
    )

    love.graphics.setFont(
        love.graphics.newFont(22)
    )

    love.graphics.printf(
        "Los niños, los perritos y el Ñandú",
        0,
        405,
        960,
        "center"
    )

    love.graphics.printf(
        "quedaron para siempre unidos bajo las estrellas.",
        0,
        435,
        960,
        "center"
    )

    love.graphics.setFont(
        love.graphics.newFont(18)
    )

    love.graphics.printf(
        "ENTER para volver a comenzar",
        0,
        490,
        960,
        "center"
    )

end

------------------------------------------------------------
-- IMAGEN FINAL
------------------------------------------------------------

function dibujarImagenFinal(opacidad)

    if not imagenFinal then

        love.graphics.setColor(
            1,
            1,
            1,
            opacidad
        )

        love.graphics.setFont(
            love.graphics.newFont(26)
        )

        love.graphics.printf(
            "Falta colocar imagen_final.png",
            0,
            245,
            pantallaW,
            "center"
        )

        love.graphics.setFont(
            love.graphics.newFont(18)
        )

        love.graphics.printf(
            "Coloca la imagen junto al archivo main.lua",
            0,
            285,
            pantallaW,
            "center"
        )

        return

    end

    local ancho =
        imagenFinal:getWidth()

    local alto =
        imagenFinal:getHeight()

    local escala =
        math.max(
            pantallaW / ancho,
            pantallaH / alto
        )

    local nuevoAncho =
        ancho * escala

    local nuevoAlto =
        alto * escala

    local x =
        (pantallaW - nuevoAncho) / 2

    local y =
        (pantallaH - nuevoAlto) / 2

    love.graphics.setColor(
        1,
        1,
        1,
        opacidad
    )

    love.graphics.draw(
        imagenFinal,
        x,
        y,
        0,
        escala,
        escala
    )

end
