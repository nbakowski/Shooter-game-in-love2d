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

function generateTarget()
  if not isTargetPresent then
    targetX = math.random(playerWidth, windowWidth - playerWidth)
    targetY = math.random(playerHeight, windowHeight / 2)
    isTargetPresent = true
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