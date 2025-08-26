local love = require("love")

function inputHandling(dt)
    if love.keyboard.isDown("f11") then
        if isFullScreen then
            love.window.setFullscreen(isFullScreen)
        else
            love.window.setFullscreen(isFullScreen, "desktop")
        end
        isFullScreen = not isFullScreen
    end
    if not isGameStarted and love.keyboard.isDown("r") then
        isGameStarted = true
        playSound(gameStartSource)
        return
    else
        if isGameOver then
            if love.keyboard.isDown("r") then
                restartGame()
            elseif love.keyboard.isDown("escape") then
                love.event.quit()
            end
        else
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
            elseif love.keyboard.isDown("escape") then
                love.event.quit()
            end

            if love.keyboard.isDown("up") then
                if ammo > 0 and not isProjectilePresent and lastShotTime >= shotCooldown then
                    isProjectilePresent = true
                    ammo = ammo - 1
                    lastShotTime = 0
                end
            end
        end
    end
end

function checkPlayerBorderCollision()
    if x > windowWidth - playerWidth or x < 0 + playerWidth then
        x = windowWidth - x
    end
end
