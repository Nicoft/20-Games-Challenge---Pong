local love = require "love"
local utils = require "utils"




-- resources
local h1 = love.graphics.newFont("fonts/NotJamChunkySans.ttf",48)
local h2 = love.graphics.newFont("fonts/NotJamChunkySans.ttf",18)
local blop = love.audio.newSource("sounds/blop.mp3", "static")
local blip = love.audio.newSource("sounds/blip.mp3", "static")
local gameover = love.audio.newSource("sounds/gameover.wav", "static")

--constants
WINDOW_WIDTH = love.graphics.getWidth()
WINDOW_HEIGHT = love.graphics.getHeight()

local function calculateBounce(ball, paddle)
    -- How far from the center of the paddle did the ball hit? (-1 to 1)
    local relativeIntersectY = (paddle.y + paddle.h / 2) - (ball.y + ball.h / 2)
    -- turn the ball's distance from paddle center into a percentage
    local normalized = relativeIntersectY / (paddle.h / 2)

    -- Max bounce angle (radians) — 75 degrees for more dynamic gameplay
    local maxBounceAngle = math.rad(50)

    -- Final bounce angle based on where the ball hit
    local bounceAngle = normalized * maxBounceAngle

    return bounceAngle
end


local function createPaddle(id, x, y)
    return {
        id = id,
        w = 20,
        h = 100,
        x = x,
        y = y, 
        speed = 400,
        dy = 0,
        draw = function(self)
            love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
        end,
        update = function(self, dt)

            --paddle movement, with max a min stoppers for top and bottom edge of screen.
            if self.dy < 0 then
                self.y = math.max(0, self.y + self.speed * self.dy * dt)
            else
                self.y = math.min(WINDOW_HEIGHT-self.h, self.y + self.speed * self.dy * dt)
            end
        end
    }
end

--variables
local gameState = "paused"

local score_player1 = 0
local score_player2 = 0

local paddle = {
    w = 20,
    h = 100
}
local paddle1 = createPaddle(1, 50, WINDOW_HEIGHT/2 - paddle.h/2)
local paddle2 = createPaddle(2, WINDOW_WIDTH - 50 - paddle.w, WINDOW_HEIGHT/2 - paddle.h/2)

local ball = {
    DEFAULT_X = WINDOW_WIDTH/2,
    DEFAULT_Y = WINDOW_HEIGHT/2,
    x = 0,
    y = 0,
    w = 20,
    h = 20,
    dx = 1,
    dy = 1,
    speed = 300,

    draw = function(self)
        love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    end,
    update = function(self, dt)

        --if the ball touches the top or bottom, reverse Y direction.
        if self.y <= 0 then
            blip:play()
            self.y = 0
            self.dy = -self.dy
        end

        if self.y >= (WINDOW_HEIGHT - self.h) then
            blip:play()
            self.y = WINDOW_HEIGHT - self.h
            self.dy = -self.dy
        end

        --ball movement
        self.x = self.x + self.speed * self.dx * dt
        self.y = self.y + self.speed * self.dy * dt
    end
}

local function resetPositions()
    paddle1.y = WINDOW_HEIGHT / 2 - paddle.h / 2
    paddle2.y = WINDOW_HEIGHT / 2 - paddle.h / 2
    ball.x = ball.DEFAULT_X - ball.w / 2
    ball.y = ball.DEFAULT_Y - ball.h / 2
    -- Small random vertical angle
    local angle = math.rad(love.math.random(-30, 30)) -- Random angle between -30° and 30°
    ball.dy = math.sin(angle)
    ball.speed = 300
end


function love.load ()
    love.math.setRandomSeed(os.time() + love.timer.getTime())
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setFont(h1)

    ball.dx = utils.randomDirection()
    resetPositions()

end

function love.update(dt)
    if gameState == "play" then
        --player1
        paddle1.dy = (love.keyboard.isDown('w') and -1) or (love.keyboard.isDown('s') and 1) or 0
        --player2
        paddle2.dy = (love.keyboard.isDown('up') and -1) or (love.keyboard.isDown('down') and 1) or 0

        paddle1:update(dt)
        paddle2:update(dt)
        ball:update(dt)

        if utils.checkCollision(paddle1, ball) then
            blop:play()
            local angle = calculateBounce(ball, paddle1)
            ball.dx = math.cos(angle) -- Adjust X based on the angle
            ball.dy = -math.sin(angle)
            local magnitude = utils.magnitude(ball.dx,ball.dy)
            ball.dx = ball.dx / magnitude
            ball.dy = ball.dy / magnitude
            ball.x = paddle1.x + paddle1.w
            ball.speed = ball.speed * 1.05 -- Gradual speed increase
        end
        
        if utils.checkCollision(paddle2, ball) then
            blop:play()
            local angle = calculateBounce(ball, paddle2)
            ball.dx = -math.cos(angle) -- Reverse direction for player 2
            ball.dy = -math.sin(angle)
            local magnitude = utils.magnitude(ball.dx,ball.dy)
            ball.dx = ball.dx / magnitude
            ball.dy = ball.dy / magnitude
            ball.x = paddle2.x - ball.w
            ball.speed = ball.speed * 1.05
        end

        if ball.x <= 0 then
            gameover:play()
            score_player2 = score_player2 + 1
            gameState = "paused"
            ball.dx = -1
            resetPositions()
        end

        if (ball.x + ball.w) >= WINDOW_WIDTH then
            gameover:play()
            score_player1 = score_player1 + 1
            gameState = "paused"
            ball.dx = 1
            resetPositions()
        end

    end

end

function love.draw()
    utils.drawTextCentered("PONG",h1,WINDOW_HEIGHT*0.1)
    love.graphics.print(score_player1, WINDOW_WIDTH*0.15, WINDOW_HEIGHT*0.1)
    love.graphics.print(score_player2, WINDOW_WIDTH*0.85-h1:getWidth(score_player2)/2, WINDOW_HEIGHT*0.1)
    if gameState == "paused" then
        utils.drawTextCentered("Press Enter to Play",h2,WINDOW_HEIGHT*0.2)
    end

    paddle1:draw()
    paddle2:draw()
    ball:draw()

    --fps debugging
    -- love.graphics.print("dx : "..ball.dx,80)
    -- love.graphics.print(love.timer.getFPS())
end

function love.keypressed(key, unicode)
	if key == "escape" then
		love.event.quit()
	end
    if key == "return" then
        gameState = "play"
    end
end
