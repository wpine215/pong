Class = require 'class'
local moonshine = require 'moonshine'

require 'Ball'
require 'Paddle'
require 'dashedLine'

WINDOW_WIDTH = 1920
WINDOW_HEIGHT = 1080

VIRTUAL_WIDTH = WINDOW_WIDTH
VIRTUAL_HEIGHT = WINDOW_HEIGHT

BALL_SIZE = 18
PADDLE_WIDTH = 25
PADDLE_HEIGHT = 100

BALL_DY_SERVE_MIN = -225
BALL_DY_SERVE_MAX = 225

BALL_DY_MIN = 45
BALL_DY_MAX = 675

BALL_DX_MIN = 630
BALL_DX_MAX = 900

PADDLE_SPEED = 850
POINTS_TO_WIN = 10

function love.load()
    --love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('PONG')
    love.mouse.setVisible(false)

    math.randomseed(os.time())

    smallFont = love.graphics.newFont('font.ttf', 36)
    largeFont = love.graphics.newFont('font.ttf', 72)
    scoreFont = love.graphics.newFont('font.ttf', 144)
    love.graphics.setFont(smallFont)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = true,
        resizable = false,
        vsync = true
    })

    -- Initialize score variables
    player1score = 0
    player2score = 0

    -- Set player 1 to serve first
    servingPlayer = 1

    -- Call paddle and ball constructors
    player1 = Paddle(45, 135, PADDLE_WIDTH, PADDLE_HEIGHT)
    player2 = Paddle(VIRTUAL_WIDTH - PADDLE_WIDTH - 45, VIRTUAL_HEIGHT - 135 - PADDLE_HEIGHT, PADDLE_WIDTH, PADDLE_HEIGHT)

    ball = Ball((VIRTUAL_WIDTH / 2) - (BALL_SIZE / 2), (VIRTUAL_HEIGHT / 2) - (BALL_SIZE / 2), BALL_SIZE, BALL_SIZE)

    -- Load effects
    effect = moonshine(moonshine.effects.crt).chain(moonshine.effects.scanlines)

    -- Initialize game state
    gameState = 'start'
end

function love.update(dt)
    if gameState == 'serve' then
        ball.dy = math.random(BALL_DY_SERVE_MIN, BALL_DY_SERVE_MAX)
        if servingPlayer == 1 then
            ball.dx = math.random(BALL_DX_MIN, BALL_DX_MAX)
        else
            ball.dx = -math.random(BALL_DX_MIN, BALL_DX_MAX)
        end
    elseif gameState == 'play' then
        if ball:collides(player1) then
            -- Reverse ball x-direction and speed it up
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + PADDLE_WIDTH

            -- Reverse ball y-direction and randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(BALL_DY_MIN, BALL_DY_MAX)
            else
                ball.dy = math.random(BALL_DY_MIN, BALL_DY_MAX)
            end

            sounds['paddle_hit']:play()
        end

        if ball:collides(player2) then
            -- Reverse ball x-direction and speed it up
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - BALL_SIZE

            -- Reverse ball y-direction and randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(BALL_DY_MIN, BALL_DY_MAX)
            else
                ball.dy = math.random(BALL_DY_MIN, BALL_DY_MAX)
            end

            sounds['paddle_hit']:play()
        end

        -- Detect top screen collision
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy

            sounds['wall_hit']:play()
        end

        -- Detect bottom screen collision, accounting for ball size
        if ball.y >= VIRTUAL_HEIGHT - BALL_SIZE then
            ball.y = VIRTUAL_HEIGHT - BALL_SIZE
            ball.dy = -ball.dy

            sounds['wall_hit']:play()
        end

        -- Detect left screen collision for scoring
        if ball.x < -BALL_SIZE + 1 then
            servingPlayer = 1
            player2score = player2score + 1
            sounds['score']:play()

            if player2score == POINTS_TO_WIN then
                winningPlayer = 2
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end

        -- Detect right screen collision for scoring
        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1score = player1score + 1
            sounds['score']:play()

            if player1score == POINTS_TO_WIN then
                winningPlayer = 1
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end
    end

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
    elseif key == 'enter' or key == 'return' or key == 'space' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            -- Reset the game
            gameState = 'serve'
            ball:reset()
            player1score = 0
            player2score = 0

            -- Give the loser the next serve
            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end

function love.draw()
    
    effect(function()

    -- Set background color
    love.graphics.clear(0.16, 0.18, 0.2, 1)
 
    displayScore()

    love.graphics.setColor(0,1,0,1)
    love.graphics.setLineWidth(4)
    dashedLine(VIRTUAL_WIDTH / 2, 0, VIRTUAL_WIDTH / 2, 20, 20, 40)
    dashedLine(VIRTUAL_WIDTH / 2, 130, VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT + 20, 20, 40)
    love.graphics.setColor(1,1,1,1)

    -- Draw text
    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to PONG', 0, 40, VIRTUAL_WIDTH,'center')
        love.graphics.printf('Press space to play', 0, 80, VIRTUAL_WIDTH,'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. servingPlayer .. ' is serving', 0, 40, VIRTUAL_WIDTH,'center')
        love.graphics.printf('Press space to serve!', 0, 80, VIRTUAL_WIDTH,'center')
    elseif gameState == 'play' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('PONG', 0, 40, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'done' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('PLAYER ' .. tostring(winningPlayer) .. ' WINS!', 0, 40, VIRTUAL_WIDTH, 'center')
    end

    -- Draw left and right paddles
    player1:render()
    player2:render()

    -- Draw ball
    ball:render()

    -- Display FPS counter
    displayFPS()

    end)
end

function displayScore()
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1score), VIRTUAL_WIDTH / 2 - 200,
        VIRTUAL_HEIGHT / 6)
    love.graphics.print(tostring(player2score), VIRTUAL_WIDTH / 2 + 120,
        VIRTUAL_HEIGHT / 6)
end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0,1,0,1)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), VIRTUAL_WIDTH - 180, 45)
end