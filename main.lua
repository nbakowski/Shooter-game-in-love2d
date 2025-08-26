require "ammoHandling"
require "targetHandling"
require "playerInteraction"
require "projectile"
require "menu"

local love = require("love")
local INITIAL_MOVEMENT_SPEED = 500
local INITIAL_TARGET_SPEED = 100
local INITIAL_LIVES = 5
local INITIAL_AMMO = 10
local SHOT_COOLDOWN = 0.5

function love.load()
    font = love.graphics.newFont("assets/fonts/PressStart2P-vaV7.ttf", 32)

    -- define dimensions for in game objects
    projectileSize = 10
    playerWidth, playerHeight = 140, 132
    targetWidth, targetHeight = 150, 150
    ammoBoxWidth, ammoBoxHeight = 150, 94

    isFullScreen = false

    love.window.setMode(0, 0, { resizable = true })
    love.window.setTitle("SigmaShooter")

    windowWidth, windowHeight = love.graphics.getWidth(), love.graphics.getHeight()
    x, y = (windowWidth - playerWidth) / 2, windowHeight - playerHeight * 1.5
    projectileX, projectileY = x + (playerWidth - projectileSize) / 2, y

    points = 0
    lives = INITIAL_LIVES
    ammo = INITIAL_AMMO
    shotCooldown = SHOT_COOLDOWN
    lastShotTime = 0
    timer = 0

    -- animation stuff
    spriteTimer = 0
    animationSpeed = 6

    -- explosion related stuff
    isTargetExploding = false
    isAmmoExploding = false
    targetExplosionTimer = 0
    ammoExplosionTimer = 0
    explosionDuration = 0.25
    targetExplosionX, targetExplosionY = 0, 0
    ammoExplosionX, ammoExplosionY = 0, 0

    -- iniate the shaders and the canvas
    crtShader = love.graphics.newShader("assets/shaders/crt.glsl")
    canvas = love.graphics.newCanvas(windowWidth, windowHeight)

    -- load audio
    bangAudioSource = love.audio.newSource("assets/sounds/bang.mp3", "static")
    lostLifeSource = love.audio.newSource("assets/sounds/lost_life.mp3", "static")
    failSource = love.audio.newSource("assets/sounds/fail.mp3", "static")
    newGameSource = love.audio.newSource("assets/sounds/new_game.mp3", "static")
    gameStartSource = love.audio.newSource("assets/sounds/game_start.mp3", "static")

    -- load images
    spacehipImage = love.graphics.newImage("assets/images/spaceship.png")
    ufoImage = love.graphics.newImage("assets/images/ufo.png")
    spaceImage = love.graphics.newImage("assets/images/space.png")
    ammoBoxImage = love.graphics.newImage("assets/images/ammo_box.png")
    explosionSource = love.graphics.newImage("assets/images/spritesheet.png")

    -- set parameters
    movementSpeed = INITIAL_MOVEMENT_SPEED
    projectileSpeed = 900
    targetSpeed = INITIAL_TARGET_SPEED
    ammoDirection = "right"

    -- timing
    targetSpeedInterval = 4
    movementSpeedInterval = 2

    -- booleans
    isProjectilePresent = false
    isGameOver = false
    isAmmoBoxPresent = false
    isGameStarted = false
    isTargetPresent = false

    quads = {}
    local imgWidth, imgHeight = explosionSource:getWidth(), explosionSource:getHeight()
    local spriteWidth = imgWidth / 3

    for i = 0, 2 do
        table.insert(quads, love.graphics.newQuad(i * spriteWidth, 0, spriteWidth, imgHeight, imgWidth, imgHeight))
    end
end

function love.update(dt)
    if not isGameStarted then
        inputHandling(dt)

        crtShader:send("time", love.timer.getTime())

        crtShader:send("resolution", { windowWidth, windowHeight })
    else
        if not isGameOver then
            timer = timer + dt
            spriteTimer = spriteTimer + dt * animationSpeed
        end

        lastShotTime = lastShotTime + dt

        if isTargetExploding then
            targetExplosionTimer = targetExplosionTimer + dt
            if targetExplosionTimer >= explosionDuration then
                isTargetExploding = false
            end
        end

        if isAmmoExploding then
            ammoExplosionTimer = ammoExplosionTimer + dt
            if ammoExplosionTimer >= explosionDuration then
                isAmmoExploding = false
            end
        end

        updateGameLogic(dt)

        crtShader:send("time", love.timer.getTime())

        crtShader:send("resolution", { windowWidth, windowHeight })

        moveTarget(dt)

        moveAmmo(dt)
    end
end

function love.draw()
    if not isGameStarted then
        drawMenu()
    else
        love.graphics.setCanvas(canvas)

        love.graphics.clear(0, 0.05, 0.1)

        -- draw background image
        love.graphics.draw(spaceImage, 0, 0, 0, love.graphics.getWidth() / 508, love.graphics.getHeight() / 288)

        -- generate interface
        love.graphics.setColor(0, 1, 0)
        love.graphics.print("Press ESC to exit", 50, 100)
        love.graphics.print("Timer: " .. string.format("%.2f", timer), 50, 150)
        love.graphics.print("Points: " .. points, 50, 200)
        love.graphics.print("Lives: " .. lives, 50, 250)
        love.graphics.print("Ammo: " .. ammo, 50, 300)

        -- draw player model
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(spacehipImage, x, y, 0, 1, 1)

        -- generate the projectile
        if isProjectilePresent then
            love.graphics.setColor(0, 1, 0)
            love.graphics.rectangle("fill", projectileX, projectileY, projectileSize, projectileSize)
        end

        -- generate the target
        love.graphics.setColor(1, 1, 1)
        if isTargetExploding then
            love.graphics.draw(explosionSource, quads[(math.floor(spriteTimer) % 3) + 1], targetExplosionX,
                targetExplosionY)
        elseif isTargetPresent then
            love.graphics.draw(ufoImage, targetX, targetY, 0, 1, 1)
        end

        -- generate ammo box
        if isAmmoExploding then
            love.graphics.draw(explosionSource, quads[(math.floor(spriteTimer) % 3) + 1], ammoExplosionX, ammoExplosionY)
        elseif ammo < 4 and isAmmoBoxPresent then
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(ammoBoxImage, ammoX, ammoY, 0, 1, 1)
        end

        -- game over screen
        if isGameOver then
            love.graphics.setColor(1, 0, 0)
            printMessage("YOU LOST! Press R to restart", 0)
        end

        love.graphics.setCanvas()
        love.graphics.setColor({ 1, 1, 1 })
        love.graphics.setShader(crtShader)
        love.graphics.draw(canvas, 0, 0)
        love.graphics.setShader()
    end
end

function love.quit()
    canvas:release()
    bangAudioSource:release()
    lostLifeSource:release()
    failSource:release()
    newGameSource:release()
    gameStartSource:release()
end

function playSound(audioSource)
    audioSource:stop()
    audioSource:play()
end

function updateGameLogic(dt)
    inputHandling(dt)
    shootProjectile(dt)
    generateTarget()
    generateAmmoBox()
    checkPlayerBorderCollision()
end

function restartGame()
    projectileX, projectileY = x + (playerWidth - projectileSize) / 2, y
    points = 0
    isGameOver = false
    isTargetPresent = false
    movementSpeed = INITIAL_MOVEMENT_SPEED
    targetSpeed = INITIAL_TARGET_SPEED
    lives = INITIAL_LIVES
    ammo = INITIAL_AMMO
    playSound(newGameSource)
    lastShotTime = 0
    timer = 0
end

function love.resize(w, h)
    -- Update window dimensions
    windowWidth, windowHeight = w, h

    -- Recreate canvas with new dimensions
    canvas = love.graphics.newCanvas(windowWidth, windowHeight)

    -- Adjust player position to maintain relative position from bottom
    x = (windowWidth - playerWidth) / 2
    y = windowHeight - playerHeight * 1.5

    -- Update projectile position relative to player
    if not isProjectilePresent then
        projectileX = x + (playerWidth - projectileSize) / 2
        projectileY = y
    end

    -- Send new resolution to shader
    crtShader:send("resolution", { windowWidth, windowHeight })
end
