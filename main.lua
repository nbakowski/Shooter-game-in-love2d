loadfile 'ammoHandling.lua'()
loadfile 'targetHandling.lua'()
loadfile 'playerInteraction.lua'()
loadfile 'menu.lua'()

function love.load()
  
  font = love.graphics.newFont("assets/fonts/PressStart2P-vaV7.ttf", 32)
  
  projectileSize = 10
  playerWidth, playerHeight = 140, 132
  targetWidth, targetHeight = 150, 150
  ammoBoxWidth, ammoBoxHeight = 150, 94

  love.window.setMode(0, 0, { fullscreen = true, centered = true })

  windowWidth, windowHeight = love.graphics.getWidth(), love.graphics.getHeight()
  x, y = (windowWidth - playerWidth) / 2, windowHeight - playerHeight * 1.5
  isTargetPresent = false

  points = 0
  lives = 5
  ammo = 10
  shotCooldown = 0.5
  lastShotTime = 0
  timer = 0

  -- iniate the shaders and the canvas
  crtShader = love.graphics.newShader("assets/shaders/crt.glsl")
  canvas = love.graphics.newCanvas(windowWidth, windowHeight)

  -- load audio
  bangAudioSource = love.audio.newSource("assets/sounds/bang.mp3", "static")
  lostLifeSource = love.audio.newSource("assets/sounds/lost_life.mp3", "static")
  failSource = love.audio.newSource("assets/sounds/fail.mp3", "static")
  newGameSource = love.audio.newSource("assets/sounds/new_game.mp3", "static")
  gameStartSource = love.audio.newSource("assets/sounds/game_start.mp3", "static")
  
  spacehipImage = love.graphics.newImage("assets/images/spaceship.png")
  ufoImage = love.graphics.newImage("assets/images/ufo.png")
  spaceImage = love.graphics.newImage("assets/images/space.png")
  ammoBoxImage = love.graphics.newImage("assets/images/ammo_box.png")
  
  movementSpeed = 10
  projectileSpeed = 20
  targetSpeed = 1
  ammoDirection = "right"

  targetSpeedInterval = 1 / 10
  movementSpeedInterval = 1 / 5

  isProjectilePresent = false
  isGameOver = false
  isAmmoBoxPresent = false
  isGameStarted = false
  projectileX, projectileY = x + (playerWidth - projectileSize) / 2, y
  
end
  
  function love.update(dt)
    
    if not isGameStarted then
      
      inputHandling()
      
      crtShader:send("time", love.timer.getTime())

      crtShader:send("resolution", { windowWidth, windowHeight })
    
    end
  
      if not isGameOver then
        timer = timer + dt
      end
      
      lastShotTime = lastShotTime + dt
      
      inputHandling()

      shootProjectile()

      generateTarget()
      
      generateAmmoBox()

      checkPlayerBorderCollision()

      crtShader:send("time", love.timer.getTime())

      crtShader:send("resolution", { windowWidth, windowHeight })
      
      moveTarget()
      
      moveAmmo()
  
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
    love.graphics.draw(spacehipImage, x ,y, 0, 1, 1)
    
    -- generate the projectile
    if isProjectilePresent then
      love.graphics.setColor(1, 0.5 , 0)
      love.graphics.rectangle("fill", projectileX, projectileY, projectileSize, projectileSize)
    end

    -- generate the target
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(ufoImage, targetX, targetY, 0, 1, 1)
    
    -- generate ammo box
    if ammo < 4 then
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

function restartGame()
  
  projectileX, projectileY = x + (playerWidth - projectileSize) / 2, y
  points = 0
  isGameOver = false
  isTargetPresent = false
  targetSpeed = 1
  movementSpeed = 10
  lives = 3
  ammo = 5
  playSound(newGameSource)
  lastShotTime = 0
  timer = 0
  
end

function playSound(audioSource)
    
    audioSource:stop()
    audioSource:play()
  
end
