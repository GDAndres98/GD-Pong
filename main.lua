push = require 'push'
Class = require 'class'

require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1920
WINDOW_HEIGHT = 1080

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

BALL_WIDTH = 4
BALL_HEIGHT = 4

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    math.randomseed(os.time())

    smallFont = love.graphics.newFont('font.ttf', 8)
    scoreFont = love.graphics.newFont('font.ttf', 32)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    player1Score = 0
    player2Score = 0

    -- paddles
    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    -- ball
    ball = Ball(VIRTUAL_WIDTH / 2 - BALL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - BALL_HEIGHT / 2, BALL_WIDTH, BALL_HEIGHT)

    gameState = 'start'

end

function love.update(dt)
    -- player 1 movement
    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    -- player 2 movement
    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

    if gameState == 'play' then
        ball:update(dt)
    end

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

    -- Background
    love.graphics.clear(30 / 255, 30 / 255, 30 / 255, 255 / 255)

    -- Hello World text
    love.graphics.setFont(smallFont)
    love.graphics.printf('Hello World! ' .. gameState, 0, 20, VIRTUAL_WIDTH, 'center')

    -- score test
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

    -- paddles
    player1:render()
    player2:render()

    -- ball
    ball:render()

    push:apply('end')
end
