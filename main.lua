function love.load()
  projectileSize = 10
  rectangleWidth, rectangleHeight = 75, 100
  targetWidth, targetHeight = 75, 75

  love.window.setMode(0, 0, { fullscreen = true, centered = true })

  windowWidth, windowHeight = love.graphics.getWidth(), love.graphics.getHeight()
  x, y = (windowWidth - rectangleWidth) / 2, windowHeight - rectangleHeight * 1.5
  isFoodPresent = false

  points = 0
  lives = 3

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

  movementSpeed = 10
  projectileSpeed = 20
  targetSpeed = 1

  targetSpeedInterval = 1 / 10
  movementSpeedInterval = 1 / 5

  isProjectilePresent = false
  isGameOver = false
  projectileX, projectileY = x + (rectangleWidth - projectileSize) / 2, y - projectileSize
  
end

function love.update(dt)
  
  inputHandling()

  shootProjectile()

  generateTarget()

  checkPlayerBorderCollision()

  crtShader:send("time", love.timer.getTime())

  crtShader:send("resolution", { windowWidth, windowHeight })
  
  moveTarget()
  
end

function love.draw()
  
  love.graphics.setCanvas(canvas)

  love.graphics.clear(0, 0.1, 0.3)
  
  -- draw background image
  love.graphics.draw(spaceImage, 0, 0, 0, love.graphics.getWidth() / 508, love.graphics.getHeight() / 288)
  
  -- generate interface
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("Press ESC to exit", 50, 50, 0, 3)
  love.graphics.print("Points: " .. points, 50, 100, 0, 3)
  love.graphics.print("Lives: " .. lives, 50, 150, 0, 3)
  
  -- draw player model
  love.graphics.draw(spacehipImage, x - rectangleWidth / 2 + 5, y - 200 + rectangleHeight)

  -- generate the projectile
  love.graphics.setColor(1, 0.5, 0)
  love.graphics.rectangle("fill", projectileX, projectileY, projectileSize, projectileSize)

  -- generate the target
  love.graphics.setColor(1, 1, 1)
  -- love.graphics.rectangle("fill", targetX, targetY, targetWidth, targetHeight)
  love.graphics.draw(ufoImage, targetX, targetY, 0, targetWidth / 150, targetHeight / 150)

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

function restartGame()
  
  projectileX, projectileY = x + (rectangleWidth - projectileSize) / 2, y - projectileSize
  points = 0
  isGameOver = false
  isTargetPresent = false
  targetSpeed = 1
  movementSpeed = 10
  lives = 3
  success = love.audio.play(newGameSource)
  
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
    
        projectileX = x + (rectangleWidth - projectileSize) / 2
        
      end
      
    elseif love.keyboard.isDown("left") then
      
      x = x - movementSpeed
      
      if not isProjectilePresent then
        
        projectileX = x + (rectangleWidth - projectileSize) / 2
        
      end
      
    elseif love.keyboard.isDown("up") then
      
      isProjectilePresent = true
      
    elseif love.keyboard.isDown("escape") then
      
      love.event.quit()
      
    end
    
  end
  
end

function shootProjectile()
  
  if isProjectilePresent then
    
    checkTargetCollision()
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
      projectileX, projectileY = x + (rectangleWidth - projectileSize) / 2, y - projectileSize
    else
      
      isProjectilePresent = false
      success = love.audio.play(failSource)
      isGameOver = true
      targetSpeed = 0
      
    end
    
  end
  
end

function checkTargetCollision()
  if projectileX > targetX - projectileSize and projectileX < targetX + targetWidth and projectileY < targetY then
    success = love.audio.play(bangAudioSource)

    isProjectilePresent = false
    isTargetPresent = false

    points = points + 1
    targetSpeed = targetSpeed + targetSpeedInterval
    movementSpeed = movementSpeed + movementSpeedInterval

    local targetSize = math.random(50, 150)
    targetWidth, targetHeight = targetSize, targetSize

    projectileX, projectileY = x + (rectangleWidth - projectileSize) / 2, y - projectileSize
  end
end

function generateTarget()
  if not isTargetPresent then
    targetX = math.random(rectangleWidth, windowWidth - rectangleWidth)
    targetY = math.random(rectangleHeight, windowHeight / 2)
    isTargetPresent = true
  end
end

function checkPlayerBorderCollision()
  if x > windowWidth or x < 0 then
    x = windowWidth - x
  end
end
