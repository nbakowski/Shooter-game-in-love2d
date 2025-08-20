function love.load()
  projectileSize = 10
  rectangleWidth, rectangleHeight = 50, 50
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

  moveTarget()

  checkPlayerBorderCollision()

  crtShader:send("time", love.timer.getTime())

  crtShader:send("resolution", { windowWidth, windowHeight })
end

function love.draw()
  love.graphics.setCanvas(canvas)

  love.graphics.clear(0.3, 0.4, 0.2)

  -- generate interface
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("Press ESC to exit", 50, 50, 0, 3)
  love.graphics.print("Points: " .. points, 50, 100, 0, 3)
  love.graphics.print("Lives: " .. lives, 50, 150, 0, 3)


  -- generate the player
  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle("fill", x, y, rectangleWidth, rectangleHeight)
  love.graphics.rectangle("fill", x + (rectangleWidth - projectileSize) / 2, y, projectileSize, -rectangleHeight / 2)

  -- generate the projectile
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", projectileX, projectileY, projectileSize, projectileSize)

  -- generate the target
  love.graphics.setColor(1, 0, 0)
  love.graphics.rectangle("fill", targetX, targetY, targetWidth, targetHeight)

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
  targetY = targetY + targetSpeed

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
    checkTargetBorderCollision()
    checkTargetCollision()
    projectileY = projectileY - projectileSpeed
  end
end

function checkTargetBorderCollision()
  if projectileY < 0 then
    if lives > 0 then
      success = love.audio.play(lostLifeSource)
      lives = lives - 1
      isProjectilePresent = false
      projectileX, projectileY = x + (rectangleWidth - projectileSize) / 2, y - projectileSize
    else
      success = love.audio.play(failSource)
      isProjectilePresent = false
      isGameOver = true
      targetSpeed = 0
    end
  end
end

function checkTargetCollision()
  if projectileX > targetX - projectileSize and projectileX < targetX + targetWidth + projectileSize and projectileY < targetY then
    success = love.audio.play(bangAudioSource)

    isProjectilePresent = false
    isTargetPresent = false

    points = points + 1
    targetSpeed = targetSpeed + targetSpeedInterval
    movementSpeed = movementSpeed + movementSpeedInterval

    local targetSize = math.random(20, 100)
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
