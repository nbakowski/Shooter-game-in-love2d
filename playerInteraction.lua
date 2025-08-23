function inputHandling(dt)
  if not isGameStarted and love.keyboard.isDown("r") then
    isGameStarted = true
    playSound(gameStartSource)
    return
  end

  if isGameOver then
    if love.keyboard.isDown("r") then
      restartGame()
    elseif love.keyboard.isDown("escape") then
      love.event.quit()
    end
  elseif not isGameOver then
    if love.keyboard.isDown("right") then
      x = x + movementSpeed * dt

      if not isProjectilePresent then
        projectileX = x + (playerWidth - projectileSize) / 2
      end
    elseif love.keyboard.isDown("left") then
      x = x - movementSpeed * dt

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

function checkPlayerBorderCollision()
  if x > windowWidth or x < 0 then
    x = windowWidth - x
  end
end
