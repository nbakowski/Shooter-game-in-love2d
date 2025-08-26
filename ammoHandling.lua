local love = require("love")

function checkAmmoBoxCollision()
    if
        projectileX > ammoX and projectileX + projectileSize < ammoX + ammoBoxWidth and projectileY < ammoY + ammoBoxHeight and
        isAmmoBoxPresent and
        ammo < 4
    then
        isProjectilePresent = false
        isAmmoBoxPresent = false

        isAmmoExploding = true
        ammoExplosionTimer = 0
        ammoExplosionX, ammoExplosionY = ammoX, ammoY

        playSound(bangAudioSource)

        ammo = ammo + 8

        projectileX, projectileY = x + (playerWidth - projectileSize) / 2, y
    end
end

function generateAmmoBox()
    if not isAmmoBoxPresent then
        ammoX = math.random(playerWidth, windowWidth - playerWidth)
        ammoY = math.random(playerHeight, windowHeight / 2)
        isAmmoBoxPresent = true
    end
end

function moveAmmo(dt)
    if ammoDirection == "right" then
        ammoX = ammoX + targetSpeed * dt
    elseif ammoDirection == "left" then
        ammoX = ammoX - targetSpeed * dt
    end

    if ammoX > windowWidth - ammoBoxWidth then
        ammoX = windowWidth - ammoBoxWidth
        ammoDirection = "left"
    elseif ammoX < 0 then
        ammoX = 0
        ammoDirection = "right"
    end
end
