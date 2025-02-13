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

function M.calculateBounce(ball, paddle)
    -- How far from the center of the paddle did the ball hit? (-1 to 1)
    local relativeIntersectY = (paddle.y + paddle.h / 2) - (ball.y + ball.h / 2)
    -- turn the ball's distance from paddle center into a percentage, middle is 0%, edges are 100%
    local normalized = relativeIntersectY / (paddle.h / 2)

    -- Max bounce angle (radians) — 75 degrees for more dynamic gameplay
    local maxBounceAngle = math.rad(50)

    -- Final bounce angle based on where the ball hit
    local bounceAngle = normalized * maxBounceAngle

    return bounceAngle
end

return M