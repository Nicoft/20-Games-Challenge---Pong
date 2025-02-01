local love = require "love"

--functions
function checkCollision(a, b)
    return a.x < b.x + b.w and
           a.x + a.w > b.x and
           a.y < b.y + b.h and
           a.y + a.h > b.y
end

function random(a, b)
    return math.random(a,b)
end


-- resources
local h1 = love.graphics.newFont("fonts/NotJamChunkySans.ttf",48)
local h2 = love.graphics.newFont("fonts/NotJamChunkySans.ttf",18)

--text data
local title = "PONG"

--constants
WINDOW_WIDTH = love.graphics.getWidth()
WINDOW_HEIGHT = love.graphics.getHeight()
love.math.setRandomSeed(love.timer.getTime())

--variables
local titleWidth = h1:getWidth(title)
local titleHeight = h1:getHeight(title)
local gameState = "paused"

local paddle = {
    w = 20,
    h = 100
}

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
    dy = 0,
    speed = 200,

    draw = function(self)
        love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    end,
    update = function(self, dt)

        --check to see if the ball collides with player 2. If yes, change direction to left, give random y direction.
        if checkCollision(paddle2, self) then
            self.dx = -1
            self.dy = random(-1,1)

        end

        --check to see if the ball collides with player 1. If yes, change direction to right, give random y direction.
        if checkCollision(paddle1, self) then
            self.dx = 1
            self.dy = random(-1,1)
        end

        --if the ball touches the top or bottom, reverse Y direction.
        if self.y <= 0 then
            self.dy = self.dy * -1
        end

        if self.y >= (WINDOW_HEIGHT - self.h) then
            self.dy = self.dy * -1
        end

        --ball movement
        self.x = self.x + self.speed * self.dx * dt
        self.y = self.y + self.speed * self.dy * dt
    end
}




function love.load ()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setFont(h1)
    ball.x = ball.DEFAULT_X - ball.w/2
    ball.y = ball.DEFAULT_Y - ball.h/2
end

function love.update(dt)
    if gameState == "play" then
        --player1
        if love.keyboard.isDown('w') then
            paddle1.dy = -1
        elseif love.keyboard.isDown('s') then
            paddle1.dy = 1
        else
            paddle1.dy = 0
        end

        --player2
        if love.keyboard.isDown('up') then
            paddle2.dy = -1
        elseif love.keyboard.isDown('down') then
            paddle2.dy = 1
        else
            paddle2.dy = 0
        end

        paddle1:update(dt)
        paddle2:update(dt)

        ball:update(dt)
    end

end

function love.draw()
    love.graphics.setFont(h1)
    love.graphics.print("PONG", WINDOW_WIDTH/2 - titleWidth/2, WINDOW_HEIGHT*0.1)
    love.graphics.setFont(h2)
    if gameState == "paused" then
        love.graphics.print("Press Enter to Play", WINDOW_WIDTH/2 - h2:getWidth("Press Enter to Play")/2, WINDOW_HEIGHT*0.2)
    end

    paddle1:draw()
    paddle2:draw()
    ball:draw()

    --fps debugging
    love.graphics.print(love.timer.getFPS())
end

function love.keypressed(key, unicode)
	if key == "escape" then
		love.event.quit()
	end
    if key == "return" then
        gameState = "play"
    end
end
