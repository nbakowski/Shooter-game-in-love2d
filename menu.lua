local love = require("love")

function drawMenu()
    love.graphics.setCanvas(canvas)

    love.graphics.clear(0, 0.05, 0.1)

    love.graphics.draw(spaceImage, 0, 0, 0, love.graphics.getWidth() / 508, love.graphics.getHeight() / 288)

    love.graphics.setFont(font)

    love.graphics.setColor(1, 0, 0)
    printMessage("CONTROLS", 175)

    love.graphics.setColor(0, 1, 0)
    printMessage("Press LEFT and RIGHT to move", 100)
    printMessage("Press UP to shoot", 25)
    printMessage("Press R to start", -50)

    love.graphics.setCanvas()
    love.graphics.setColor({ 1, 1, 1 })
    love.graphics.setShader(crtShader)
    love.graphics.draw(canvas, 0, 0)
    love.graphics.setShader()
end

function printMessage(message, offset)
    love.graphics.print(
        message,
        (love.graphics.getWidth() / 2 - font:getWidth(message) / 2),
        windowHeight / 2 - offset,
        0,
        1
    )
end
