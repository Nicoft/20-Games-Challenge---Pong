local love = require "love"

local M = {}

--AABB collision detection
function M.checkCollision(a, b)
    return a.x < b.x + b.w and
           a.x + a.w > b.x and
           a.y < b.y + b.h and
           a.y + a.h > b.y
end

--randomly return -1 or 1
function M.randomDirection()
    return love.math.random(0, 1) == 0 and -1 or 1
end

--return magnitude of inputs
function M.magnitude(dx,dy)
    return math.sqrt(dx^2 + dy^2)
end

--print text centered with given font and y-height
function M.drawTextCentered(text, font, yOffset)
    love.graphics.setFont(font)
    local width = font:getWidth(text)
    love.graphics.print(text, (WINDOW_WIDTH - width) / 2, yOffset)
end

return M