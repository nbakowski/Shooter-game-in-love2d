function checkTargetCollision()
  if
    projectileX > targetX and projectileX + projectileSize < targetX + targetWidth and
      projectileY < targetY + targetHeight
   then
    isProjectilePresent = false
    isTargetPresent = false

    isTargetExploding = true
    targetExplosionTimer = 0
    targetExplosionX, targetExplosionY = targetX, targetY

    playSound(bangAudioSource)

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

function moveTarget(dt)
  targetY = targetY + targetSpeed * dt-- move target

  if targetY > windowHeight - targetHeight then
    if lives > 0 then
      playSound(lostLifeSource)
      lives = lives - 1
      isTargetPresent = false
    else
      if not isGameOver then
        love.audio.play(failSource)
      end
      targetSpeed = 0
      isGameOver = true
    end
  end
end
