push = require 'push'
Class = require 'class'

require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    math.randomseed(os.time())

    smallFont = love.graphics.newFont('font.ttf', 8)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    love.graphics.setFont(smallFont)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    -- Initialize score variables
    player1score = 0
    player2score = 0

    -- Call paddle and ball constructors
    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    -- Initialize game state
    gameState = 'start'
end

function love.update(dt)
    -- Handle player 1 movement
    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then 
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    -- Handle player 2 movement
    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

    -- Update ball position and velocity if in play state
    if gameState == 'play' then
        ball:update(dt)
    end

    -- Update paddle positions
    player1:update(dt)
    player2:update(dt)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'play'
        else
            gameState = 'start'
            ball:reset()
        end
    end
end

function love.draw()
    push:apply('start')

    -- Set background color
    love.graphics.clear(0.16, 0.18, 0.2, 1)

    -- Draw welcome text
    love.graphics.setFont(smallFont)
    love.graphics.printf('PONG', 0, 20, VIRTUAL_WIDTH,'center')

    -- Draw score
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1score), VIRTUAL_WIDTH / 2 - 50,
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2score), VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3)

    -- Draw left and right paddles
    player1:render()
    player2:render()

    -- Draw ball
    ball:render()

    push:apply('end')
end