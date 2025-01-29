local love = require "love"


-- resources
local myFont = love.graphics.newFont("fonts/NotJamChunkySans.ttf",48)

--text data
local title = "PONG"

--constants
WINDOW_WIDTH = love.graphics.getWidth()
WINDOW_HEIGHT = love.graphics.getHeight()

--variables
local titleWidth = myFont:getWidth(title)
local titleHeight = myFont:getHeight(title)

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


function love.load ()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setFont(myFont)
end

function love.update(dt)

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

end

function love.draw()

    love.graphics.print("PONG", WINDOW_WIDTH/2 - titleWidth/2, WINDOW_HEIGHT*0.1)

    love.graphics.rectangle("fill", WINDOW_WIDTH/2,WINDOW_HEIGHT/2, 20, 20)
    paddle1:draw()
    paddle2:draw()
end

function love.keypressed(key, unicode)
	if key == "escape" then
		love.event.quit()
	end
end
