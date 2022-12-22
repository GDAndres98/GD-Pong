WINDOW_WIDTH = 1920
WINDOW_HEIGHT = 1080

function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT,{
        fullscreen = false,
        resizable = false,
        vsync = true
    })
end

function love.draw()
    love.graphics.printf(
        'Hello World!',
        0,
        WINDOW_HEIGHT/2-6,
        WINDOW_WIDTH,
        'center'
    )
end