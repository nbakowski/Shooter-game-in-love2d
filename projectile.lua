local love = require("love")

function shootProjectile(dt)
    if isProjectilePresent then
        checkTargetCollision()

        checkAmmoBoxCollision()

        checkProjectileBorderCollision()
        projectileY = projectileY - projectileSpeed * dt
    end
end

function checkProjectileBorderCollision()
    if projectileY < 0 then
        if lives > 0 then
            isProjectilePresent = false
            playSound(lostLifeSource)
            lives = lives - 1
            projectileX, projectileY = x + (playerWidth - projectileSize) / 2, y
        else
            isProjectilePresent = false
            playSound(failSource)
            isGameOver = true
            targetSpeed = 0
        end
    end
end
