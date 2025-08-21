function love.load()
  
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
  crtShader = love.graphics.newShader("crt.glsl")
  canvas = love.graphics.newCanvas(windowWidth, windowHeight)

  -- load audio
  bangAudioSource = love.audio.newSource("bang.mp3", "static")
  lostLifeSource = love.audio.newSource("lost_life.mp3", "static")
  failSource = love.audio.newSource("fail.mp3", "stream")
  newGameSource = love.audio.newSource("new_game.mp3", "stream")
  
  spacehipImage = love.graphics.newImage("spaceship.png")
  ufoImage = love.graphics.newImage("ufo.png")
  spaceImage = love.graphics.newImage("space.png")
  ammoBoxImage = love.graphics.newImage("ammo_box.png")
  
  movementSpeed = 10
  projectileSpeed = 20
  targetSpeed = 1
  ammoDirection = "right"

  targetSpeedInterval = 1 / 10
  movementSpeedInterval = 1 / 5

  isProjectilePresent = false
  isGameOver = false
  isAmmoBoxPresent = false
  projectileX, projectileY = x + (playerWidth - projectileSize) / 2, y
  
end

function love.update(dt)
  
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
  
  love.graphics.setCanvas(canvas)

  love.graphics.clear(0, 0.05, 0.1)
  
  -- draw background image
  love.graphics.draw(spaceImage, 0, 0, 0, love.graphics.getWidth() / 508, love.graphics.getHeight() / 288)
  
  -- generate interface
  love.graphics.setColor(0, 0, 0, 0.1)
  for i = 15 ,0 , -1 do
    love.graphics.rectangle("fill", 25 - i, 75 - i, 375 + i * 2, 300 + i * 2)
  end
  
  love.graphics.setColor(0, 1, 0)
  love.graphics.print("Press ESC to exit", 50, 100, 0, 3)
  love.graphics.print("Timer: " .. string.format("%.2f", timer), 50, 150, 0, 3)
  love.graphics.print("Points: " .. points, 50, 200, 0, 3)
  love.graphics.print("Lives: " .. lives, 50, 250, 0, 3)
  love.graphics.print("Ammo: " .. ammo, 50, 300, 0, 3)
  
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
  if ammo < 3 then
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(ammoBoxImage, ammoX, ammoY, 0, 1, 1)
  end

  -- game over screen
  if isGameOver then
    love.graphics.setColor(1, 0, 0)
    love.graphics.print("YOU LOST! Press R to restart", windowWidth / 2 - 350, windowHeight / 2, 0, 4)
  end

  love.graphics.setCanvas()
  love.graphics.setColor({ 1, 1, 1 })
  love.graphics.setShader(crtShader)
  love.graphics.draw(canvas, 0, 0)
  love.graphics.setShader()
end

function moveTarget()
  
  targetY = targetY + targetSpeed -- move target

  if targetY > windowHeight - targetHeight then
    
    if lives > 0 then
      
      success = love.audio.play(lostLifeSource)
      lives = lives - 1
      isTargetPresent = false
      
    else
      
      success = love.audio.play(failSource)
      targetSpeed = 0
      isGameOver = true
      
    end
    
  end
  
end

function moveAmmo()
    
    if ammoDirection == "right" then
  
      ammoX = ammoX + targetSpeed
      
    elseif ammoDirection == "left" then
      
      ammoX = ammoX - targetSpeed
      
    end
    
    if ammoX > windowWidth - ammoBoxWidth then
      ammoX = windowWidth - ammoBoxWidth
      ammoDirection = "left"
    elseif ammoX < 0 then
      ammoX = 0
      ammoDirection = "right"
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
  success = love.audio.play(newGameSource)
  lastShotTime = 0
  timer = 0
  
end

function inputHandling()
  
  if isGameOver then
    
    if love.keyboard.isDown("r") then
      restartGame()
    elseif love.keyboard.isDown("escape") then
      love.event.quit()
    end
    
  elseif not isGameOver then
    
    if love.keyboard.isDown("right") then
  
      x = x + movementSpeed
      
      if not isProjectilePresent then
    
        projectileX = x + (playerWidth - projectileSize) / 2
        
      end
      
    elseif love.keyboard.isDown("left") then
      
      x = x - movementSpeed
      
      if not isProjectilePresent then
        
        projectileX = x + (playerWidth - projectileSize) / 2
        
      end
      
    elseif love.keyboard.isDown("up") then
      
      if ammo > 0 and not isProjectilePresent and lastShotTime >= shotCooldown then
      
        isProjectilePresent = true
        ammo = ammo - 1
        lastShotTime = 0
        
        end
      
    elseif love.keyboard.isDown("escape") then
      
      love.event.quit()
      
    end
    
  end
  
end

function shootProjectile()
  
  if isProjectilePresent then
    
    checkTargetCollision()
    checkAmmoBoxCollision()
    checkTargetBorderCollision()
    projectileY = projectileY - projectileSpeed
    
  end
  
end

function checkTargetBorderCollision()
  
  if projectileY < 0 then
    
    if lives > 0 then
      
      isProjectilePresent = false
      success = love.audio.play(lostLifeSource)
      lives = lives - 1
      projectileX, projectileY = x + (playerWidth - projectileSize) / 2, y
    else
      
      isProjectilePresent = false
      success = love.audio.play(failSource)
      isGameOver = true
      targetSpeed = 0
      
    end
    
  end
  
end

function checkTargetCollision()
  
  if projectileX > targetX and projectileX + projectileSize < targetX + targetWidth and projectileY < targetY + targetHeight then
    
    isProjectilePresent = false
    isTargetPresent = false
    
    success = love.audio.play(bangAudioSource)

    points = points + 1
    targetSpeed = targetSpeed + targetSpeedInterval
    movementSpeed = movementSpeed + movementSpeedInterval

    projectileX, projectileY = x + (playerWidth - projectileSize) / 2, y
    
  end
  
end

function checkAmmoBoxCollision()
  
  if projectileX > ammoX and projectileX + projectileSize < ammoX + ammoBoxWidth and projectileY < ammoY + ammoBoxHeight and isAmmoBoxPresent then
    
    isProjectilePresent = false
    isAmmoBoxPresent = false
    
    success = love.audio.play(bangAudioSource)

    ammo = ammo + 8

    projectileX, projectileY = x + (playerWidth - projectileSize) / 2, y
    
  end
  
end

function generateTarget()
  if not isTargetPresent then
    targetX = math.random(playerWidth, windowWidth - playerWidth)
    targetY = math.random(playerHeight, windowHeight / 2)
    isTargetPresent = true
  end
end

function generateAmmoBox()
  if not isAmmoBoxPresent then
    ammoX = math.random(playerWidth, windowWidth - playerWidth)
    ammoY = math.random(playerHeight, windowHeight / 2)
    isAmmoBoxPresent = true
  end
end

function checkPlayerBorderCollision()
  if x > windowWidth or x < 0 then
    x = windowWidth - x
  end
end
