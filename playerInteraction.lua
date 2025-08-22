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
    
    if isAmmoBoxPresent then
      checkAmmoBoxCollision()
    end
    
    checkTargetBorderCollision()
    projectileY = projectileY - projectileSpeed
    
  end
  
end

function checkPlayerBorderCollision()
  if x > windowWidth or x < 0 then
    x = windowWidth - x
  end
end