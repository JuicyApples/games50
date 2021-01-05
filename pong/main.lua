WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

Class = require 'class'
push = require 'push'

require 'Ball'
require 'Paddle'

function love.load()
    -- seed random number 
    math.randomseed(os.time())

    -- increase size
    love.graphics.setDefaultFilter('nearest','nearest')

    -- set font
    smallFont = love.graphics.newFont('font.ttf',8)
    scoreFont = love.graphics.newFont('font.ttf',32)
    victoryFont = love.graphics.newFont('font.ttf',24)

    -- sounds
    sounds = {
        ['paddle_hit'] = love.audio.newSource('paddle_hit.wav','static'),
        ['point_scored'] = love.audio.newSource('point_scored.wav','static'),
        ['wall_hit'] = love.audio.newSource('wall_hit.wav','static'),
    }

    -- player scores
    player1score = 0
    player2score = 0

    -- server
    servingPlayer = math.random(2) == 1 and 1 or 2

    -- winning player
    winningPlayer = 0

    -- paddle y axis
    paddle1 = Paddle(5,VIRTUAL_HEIGHT/2-10,5,20)
    paddle2 = Paddle(VIRTUAL_WIDTH-10,VIRTUAL_HEIGHT/2-10,5,20)

    -- ball 
    ball = Ball(VIRTUAL_WIDTH/2 -2,VIRTUAL_HEIGHT/2 -2,5 , 5)


    gameState = 'start'

    if servingPlayer == 1 then
        ball.dx = 100 
    else
        ball.dx = -100
    end

    --push
    push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT,WINDOW_WIDTH,WINDOW_HEIGHT,{
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    -- set title
    love.window.setTitle('Pong')
end

function love.resize(w,h)
    push:resize(w,h)
end

function love.update(dt)

    if gameState == 'play' then 
        paddle1:update(dt)
        paddle2:update(dt)

        if ball:collides(paddle1) then
            --deflect ball to right
            ball.dx = -ball.dx * 1.1
            ball.x = paddle1.x + 4

            sounds['paddle_hit']:play()
            -- keep velocity same direction but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10,150)
            else
                ball.dy = math.random(10,150)
            end
        end

        if ball:collides(paddle2) then
            --deflect ball to left
            ball.dx = -ball.dx * 1.1
            ball.x = paddle2.x - 4

            sounds['paddle_hit']:play()
            -- keep velocity same direction but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10,150)
            else
                ball.dy = math.random(10,150)
            end
        end

        if ball.y < 0 then
            --deflect ball down
            ball.dy = -ball.dy
            ball.y = 0

            sounds['wall_hit']:play()
        end

        if ball.y > VIRTUAL_HEIGHT - 4 then
            --deflect ball up
            ball.dy = -ball.dy
            ball.y = VIRTUAL_HEIGHT - 4

            sounds['wall_hit']:play()
        end

        if ball.x < 0 then
            -- ball go right
            player2score = player2score + 1
            servingPlayer = 1

            sounds['point_scored']:play()

            if player2score == 3 then
                gameState = 'victory'
                winningPlayer = 2
            else
                gameState = 'serve'
                ball:reset()
            end

            paddle1 = Paddle(5,VIRTUAL_HEIGHT/2-10,5,20)
            paddle2 = Paddle(VIRTUAL_WIDTH-10,VIRTUAL_HEIGHT/2-10,5,20)
        end

        if ball.x > VIRTUAL_WIDTH - 4 then
            -- ball go left
            player1score = player1score + 1
            servingPlayer = 2
            
            sounds['point_scored']:play()

            if player1score == 3 then
                gameState = 'victory'
                winningPlayer = 1
            else
                gameState = 'serve'
                ball:reset()
            end

            paddle1 = Paddle(5,VIRTUAL_HEIGHT/2-10,5,20)
            paddle2 = Paddle(VIRTUAL_WIDTH-10,VIRTUAL_HEIGHT/2-10,5,20)
        end

        if love.keyboard.isDown('w') then
            paddle1.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('s') then
            paddle1.dy = PADDLE_SPEED
        else
            paddle1.dy = 0
        end

        if love.keyboard.isDown('up') then
            paddle2.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('down') then
            paddle2.dy = PADDLE_SPEED
        else
            paddle2.dy = 0
        end


        -- computers 

        if paddle1.y < ball.y then
            paddle1.dy = ball.dy 
        elseif paddle1.y > ball.y then
            paddle1.dy = ball.dy 
        else 
            paddle1.dy = 0
        end

        if paddle2.y < ball.y then
            paddle2.dy = ball.dy 
        elseif paddle2.y > ball.y then
            paddle2.dy = ball.dy 
        else 
            paddle2.dy = 0
        end

        ball:update(dt)
    end
end

function love.keypressed(key)
    -- terminate
    if key == 'escape' then
        love.event.quit()
    --  change game state 
    elseif key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'victory' then
            gameState = 'start'
            player1score = 0
            player2score = 0
            ball:reset()
        end
        paddle1 = Paddle(5,VIRTUAL_HEIGHT/2-10,5,20)
        paddle2 = Paddle(VIRTUAL_WIDTH-10,VIRTUAL_HEIGHT/2-10,5,20)
    end
end

function love.draw()

    push:apply('start')

    -- set background colour
    love.graphics.clear(40/255,45/255,52/255,255/255)

    -- draw ball
    ball:render()

    -- draw paddles
    paddle1:render()
    paddle2:render()
   
    -- change font and print
    love.graphics.setFont(smallFont)

    if gameState == 'start' then
        love.graphics.setColor(0,1,0,1)
        love.graphics.printf("Welcome to Pong!",0,20,VIRTUAL_WIDTH,'center')
        love.graphics.printf("Press Enter to Play",0,32 ,VIRTUAL_WIDTH , 'center')
    elseif gameState == 'serve' then
        love.graphics.printf("Player" .. tostring(servingPlayer) .. "'s turn!",0,20,VIRTUAL_WIDTH,'center')
        love.graphics.printf("Press Enter to Serve",0,32 ,VIRTUAL_WIDTH , 'center')
    elseif gameState == 'victory' then
        love.graphics.setFont(victoryFont)
        love.graphics.printf("Player " .. tostring(winningPlayer) .. " wins!",0,20,VIRTUAL_WIDTH,'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press Enter to restart",0,42 ,VIRTUAL_WIDTH , 'center')
    end

    love.graphics.setFont(scoreFont)
    love.graphics.print(player1score,VIRTUAL_WIDTH/2 - 50,VIRTUAL_HEIGHT/3)
    love.graphics.print(player2score,VIRTUAL_WIDTH/2 + 30,VIRTUAL_HEIGHT/3)
    
    -- display fps
    displayFPS()

    push:apply('end')
end

function displayFPS()
    love.graphics.setColor(0,1,0,1)
    love.graphics.setFont(smallFont)
    love.graphics.print('FPS:' .. tostring(love.timer.getFPS()),40,20)
    love.graphics.setColor(1,1,1,1)
end