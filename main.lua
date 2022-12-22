push = require 'push'
Class = require 'class'

require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1920
WINDOW_HEIGHT = 1080

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_WIDTH = 5
PADDLE_HEIGHT = 20
PADDLE_SPEED = 200

BALL_WIDTH = 4
BALL_HEIGHT = 4

SCORE_LIMIT = 3

function love.load()
    love.window.setTitle('Pong')
    love.graphics.setDefaultFilter('nearest', 'nearest')

    math.randomseed(os.time())

    smallFont = love.graphics.newFont('font.ttf', 8)
    scoreFont = love.graphics.newFont('font.ttf', 32)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    player1Score = 0
    player2Score = 0
    gameState = 'start'
    servingPlayer = 1
    winningPlayer = 0

    -- paddles
    player1 = Paddle(10, 30, PADDLE_WIDTH, PADDLE_HEIGHT)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, PADDLE_WIDTH, PADDLE_HEIGHT)

    -- ball
    ball = Ball(VIRTUAL_WIDTH / 2 - BALL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - BALL_HEIGHT / 2, BALL_WIDTH, BALL_HEIGHT)

end

function love.resize(w, h)
    push:resize(w, h)
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

        collides1 = ball:collides(player1)
        collides2 = ball:collides(player2)

        -- paddle hit the ball
        if collides1 or collides2 then
            sounds['paddle_hit']:play()
            ball.dx = -ball.dx * 1.03
            ball.x = collides1 and player1.x + PADDLE_WIDTH or player2.x - BALL_WIDTH

            newDy = math.random(10, 150)
            ball.dy = ball.dy < 0 and -newDy or newDy
        end

        if ball.y <= 0 then
            sounds['wall_hit']:play()
            ball.y = 0
            ball.dy = -ball.dy
        elseif ball.y >= VIRTUAL_HEIGHT - BALL_HEIGHT then
            sounds['wall_hit']:play()
            ball.y = VIRTUAL_HEIGHT - BALL_HEIGHT
            ball.dy = -ball.dy
        end

        -- score
        if ball.x - BALL_WIDTH < 0 then
            sounds['score']:play()
            servingPlayer = 1
            player2Score = player2Score + 1
            ball:reset()
            gameState = 'serve'
        elseif ball.x > VIRTUAL_WIDTH then
            sounds['score']:play()
            servingPlayer = 2
            player1Score = player1Score + 1
            ball:reset()
            gameState = 'serve'
        end

        if player1Score == SCORE_LIMIT then
            winningPlayer = 1
            gameState = 'done'
        elseif player2Score == SCORE_LIMIT then
            winningPlayer = 2
            gameState = 'done'
        else
            ball:update(dt)
        end

    end

    player1:update(dt)
    player2:update(dt)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' or gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            gameState = 'start'
            resetGame()
        end
    elseif key == 'return' then
        gameState = 'start'
        ball:reset()
    end

end

function love.draw()
    push:apply('start')

    -- Background
    love.graphics.clear(30 / 255, 30 / 255, 30 / 255, 255 / 255)

    -- Hello World text
    love.graphics.setFont(smallFont)
    love.graphics.printf('PONG!', 0, 10, VIRTUAL_WIDTH, 'center')
    if gameState == 'serve' or gameState == 'start' then
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. ' serves', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'done' then
        love.graphics.printf('GAME OVER', 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(scoreFont)
        love.graphics.printf('PLAYER ' .. tostring(winningPlayer) .. ' wins!', 0, 50, VIRTUAL_WIDTH, 'center')
    end

    -- score test
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

    -- paddles
    player1:render()
    player2:render()

    -- ball
    ball:render()

    displayFPS()

    push:apply('end')
end

function resetGame()
    player1Score = 0
    player2Score = 0
    gameState = 'start'
    servingPlayer = winningPlayer == 1 and 2 or 1
    ball:reset()
end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255 / 255, 0, 255 / 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()))
end
