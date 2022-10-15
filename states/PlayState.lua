--[[
    PlayState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The PlayState class is the bulk of the game, where the player actually controls the bird and
    avoids pipes. When the player collides with a pipe, we should go to the GameOver state, where
    we then go back to the main menu.
]]

PlayState = Class{__includes = BaseState}

PIPE_SPEED = 60
PIPE_WIDTH = 70
PIPE_HEIGHT = 288

BIRD_WIDTH = 38
BIRD_HEIGHT = 24

pause = love.graphics.newImage('pause.png')

function PlayState:init()
    self.bird = Bird()
    self.pipePairs = {}
    self.timer = 0
    self.score = 0
    -- initialize our last recorded Y value for a gap placement to base other gaps off of
    self.lastY = -PIPE_HEIGHT + math.random(80) + 20
    self.spawnTime = 0
    -- disabled pause by default so game can be played
    self.pause = false
end

function PlayState:update(dt)
    if love.keyboard.wasPressed('p') then
        if self.pause then
            self.pause = false
            scrolling = true
            sounds['music']:resume()
        else
            self.pause = true
            scrolling = false
            sounds['music']:pause()
        end
        sounds['pause']:play()
    end

    if not self.pause then
        self.spawnTime = self.spawnTime + dt
        local rand = math.random(2, 20)
        if self.spawnTime > rand then
                   -- modify the last Y coordinate we placed so pipe gaps aren't too far apart
        -- no higher than 10 pixels below the top edge of the screen,
        -- and no lower than a gap length (90 pixels) from the bottom
        local y = math.max(-PIPE_HEIGHT + 10, 
        math.min(self.lastY + math.random(-20, 20), VIRTUAL_HEIGHT - 90 - PIPE_HEIGHT))

            table.insert(self.pipePairs, PipePair(y))
            self.spawnTime = 0
            self.lastY = y
        end

        -- update bird based on gravity and input
        self.bird:update(dt)

        -- reset if we get to the ground
        for k, pair in pairs(self.pipePairs) do
            pair:update(dt)

            for l, pipe in pairs(pair.pipes) do
            if self.bird:collides(pipe) then
                sounds ['explosion']:play()
                sounds ['hurt']:play()
                gStateMachine:change('score', { score = self.score})
            end
        end

        if not pair.scored then
            if pair.x + PIPE_WIDTH < self.bird.x then
                self.score = self.score + 1
                pair.scored = true
                sounds['score']:play()
            end
        end
    end

        for k, pair in pairs(self.pipePairs) do
            if pair.remove then
                table.remove(self.pipePairs, k)
            end
        end

        if self.bird.y > VIRTUAL_HEIGHT - 15 then
            sounds ['explosion']:play()
            sounds['hurt']:play()
            gStateMachine:change('score', {score = self.score})
        end
    end
end

function PlayState:render()
    for k,pair in pairs(self.pipePairs) do
        pair:render()
    end

    love.graphics.setFont(flappyFont)
    love.graphics.print('Score: '.. tostring(self.score), 8, 8)
    if self.score < 3 then
        love.graphics.draw(bronze, 140, 4)
    end
    if self.score > 2 and self.score < 5 then
        love.graphics.draw(silver, 140, 4)
    end
    if self.score > 4 then
        love.graphics.draw(gold, 140, 4)
    end
    self.bird:render()

        if self.pause then
            love.graphics.draw(pause, VIRTUAL_WIDTH / 2 - (pause:getWidth() / 2), VIRTUAL_HEIGHT / 2 - (pause:getHeight() / 2))
        end

    end

    function PlayState:enter()
        scrolling = true
    end

    function PlayState:exit()
        scrolling = false
    end

        