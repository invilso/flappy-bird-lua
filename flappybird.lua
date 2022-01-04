local textures = {
    background = renderLoadTextureFromFile(getWorkingDirectory()..'\\resource\\flappybird\\background_big.png'),
    ground = renderLoadTextureFromFile(getWorkingDirectory()..'\\resource\\flappybird\\ground.png'),
    bird = renderLoadTextureFromFile(getWorkingDirectory()..'\\resource\\flappybird\\bird.png'),
    coin = renderLoadTextureFromFile(getWorkingDirectory()..'\\resource\\flappybird\\coin.png'),
    game_over = renderLoadTextureFromFile(getWorkingDirectory()..'\\resource\\flappybird\\game_over.png'),
    tap_to_play = renderLoadTextureFromFile(getWorkingDirectory()..'\\resource\\flappybird\\taptoplay.png'),
    pipes = {
        up = renderLoadTextureFromFile(getWorkingDirectory()..'\\resource\\flappybird\\pipe_up.png')
    }
}

local flappy_font = renderCreateFont('04b_19', 35)
-- local flappy_font = renderCreateFontFromFile(getWorkingDirectory()..'\\resource\\flappybird\\flappyfont.ttf', 35)

local positions = {
    background = {
        x = 50,
        y = 50
    },
    ground = {
        x = 0,
        y = 0
    },
    bird = {
        x = 0,
        y = 0
    },
}

local pipe_base = {
    position = {
        x = 0,
        y = 0
    },
    size = {
        x = 0,
        y = 0
    },
    angle = 0,
}

local pipes = {}

local sizes = {
    background = {
        x = 432,
        y = 256
    },
    ground = {
        x = 432,
        y = 55
    },
    bird = {
        x = 19,
        y = 14
    },
    pipe = {
        x = 27,
        y = 160
    },
    multipler = 2
}

local move = {
    bird = {
        speed_down = 0,
        status = 'MIDDLE'
    },
    pipes = {
        speed_multipler = 1,
    }
}


local active = false
local reverse = false
local score = 0
local max_score = 0


function main()
    while not isSampAvailable() do wait(50) end
    sampRegisterChatCommand('fpb', function() 
        active = not active 
        initializeGame()
    end)
    while true do
        wait(0)
        if positions.bird.x > positions.ground.x and positions.bird.x < positions.ground.x+(sizes.ground.x*sizes.multipler) and positions.bird.y > positions.ground.y and positions.bird.y < positions.ground.y+(sizes.ground.y*sizes.multipler) then
            initializeGame()
        end
    end
end

function downloadFiles()
    
end

function onD3DPresent()
    if active then
        if isSampAvailable() then
            if not isPauseMenuActive() then
                drawField()
                renderFontDrawText(flappy_font, score..'/'..max_score, (positions.background.x + (sizes.background.x*sizes.multipler)) / 2,(positions.background.y + (sizes.background.y*sizes.multipler)) / 4,-1)
            end
        end
    end
end


function initializeGame()
    positions.bird.y = (positions.background.y + (sizes.background.y*sizes.multipler)) / 2
    move.bird.speed_down = 0
    move.pipes.speed_multipler = 1
    score = 0
    pipes = {}
end

function drawField()
    renderBackground()
    renderBird()
    renderPipes()
    renderGround()
    moveBird()
    -- moveBackground()
end

function renderPipes()
    for key, pipe_base in ipairs(pipes) do
        for key2, pipe in pairs(pipe_base) do
            -- print(key2)
            if key2 == 'score_range' then
                renderDrawBox(pipe.position.x, pipe.position.y, pipe.size.x,pipe.size.y, 0xFFFFFFFF)
                if positions.bird.x > pipe.position.x and positions.bird.x < pipe.position.x+pipe.size.x and positions.bird.y > pipe.position.y and positions.bird.y < pipe.position.y+pipe.size.y then
                    if not pipe.checked then
                        score = score + 1
                        if score > max_score then
                            max_score = score
                        end
                        pipe.checked = true
                    end
                end
            else
                renderDrawTexture(textures.pipes.up, pipe.position.x, pipe.position.y, pipe.size.x, pipe.size.y, pipe.angle, -1)
                if positions.bird.x > pipe.position.x and positions.bird.x < pipe.position.x+pipe.size.x and positions.bird.y > pipe.position.y and positions.bird.y < pipe.position.y+pipe.size.y then
                    initializeGame()
                end
            end
            
            movePipe(pipe)
        end
    end
    tryCreatePipe()
end

function movePipe(pipe)
    pipe.position.x = pipe.position.x - 2 * move.pipes.speed_multipler
    if move.pipes.speed_multipler < 1.55 then
        move.pipes.speed_multipler = move.pipes.speed_multipler + 0.000005
    end
end

function createPipe()
    local size_x = sizes.pipe.x * sizes.multipler
    local background_y = sizes.background.y * sizes.multipler - sizes.ground.y * sizes.multipler
    local pipe_up = {
        angle = 180,
        size = {
            x = size_x,
            y = math.random((background_y / 4.5), (background_y / 1.8))
        },
        position = {
            x = (positions.background.x + (sizes.background.x*sizes.multipler)) - size_x,
            y = positions.background.y
        }
    }
    
    local pipe_down = {
        angle = 0,
        size = {
            x = pipe_up.size.x,
            y = background_y - (pipe_up.size.y + ((sizes.bird.y*sizes.multipler)*5)/2)
        },
        position = {
            x = pipe_up.position.x,
            y = pipe_up.size.y + ((sizes.bird.y*sizes.multipler)*5)
        }
    }
    local score_range = {
        size = {
            x = pipe_up.size.x,
            y = (pipe_down.size.y + pipe_up.size.y) - background_y + ((sizes.bird.y*sizes.multipler)*5) + (10*sizes.multipler)
        },
        position = {
            x = pipe_up.position.x,
            y = (pipe_up.position.y + pipe_up.size.y)
        },
        checked = false
    }
    local pipe = {
        up = pipe_up,
        down = pipe_down,
        score_range = score_range
    }
    table.insert(pipes, pipe)
end

function tryCreatePipe()
    if #pipes == 0 then
        createPipe()
    else
        if pipes[#pipes].up.position.x + (sizes.pipe.x*sizes.multipler*(4+math.random(0.5, 1.8))) < (positions.background.x + (sizes.background.x*sizes.multipler)) then
            createPipe()
        end
    end
end

function renderBird()
    positions.bird.x = (positions.background.x + (sizes.background.x*sizes.multipler)) / 2
    renderDrawTexture(textures.bird, positions.bird.x, positions.bird.y, sizes.bird.x*sizes.multipler, sizes.bird.y*sizes.multipler, getBirdAngle(), -1)
end

function getBirdAngle()
    if move.bird.status == 'UP' then
        return 345.0
    elseif move.bird.status == 'DOWN' then
        return 35.0
    else
        return 0.0
    end
end

function moveBird()
    if isKeyJustPressed(0x20) or isKeyJustPressed(0x01) then
        if positions.bird.x > positions.background.x and positions.bird.x < positions.background.x+(sizes.background.x*sizes.multipler) and positions.bird.y > positions.background.y and positions.bird.y < positions.background.y+(sizes.background.y*sizes.multipler) then
            catchUpBird()
        end
    end
    putDownBird()
end

function catchUpBird()
    lua_thread.create(function()
        move.bird.speed_down = 0
        for i = 1, 10*sizes.multipler do
            positions.bird.y = positions.bird.y - 3.5
            move.bird.status = 'UP'
            wait(0)
        end
        move.bird.status = 'MIDDLE'
    end)
end

function putDownBird()
    if move.bird.status == 'MIDDLE' then
        move.bird.status = 'DOWN'
    end
    positions.bird.y = positions.bird.y + 1.3 + move.bird.speed_down
    move.bird.speed_down = move.bird.speed_down + 0.035
end

function renderBackground()
    renderDrawTexture(textures.background, positions.background.x, positions.background.y, sizes.background.x*sizes.multipler,sizes.background.y*sizes.multipler, 0.0, -1)
end

function renderGround()
    positions.ground.y = positions.background.y + (sizes.background.y*sizes.multipler) - (sizes.ground.y*sizes.multipler)
    positions.ground.x = positions.background.x
    renderDrawTexture(textures.ground, positions.ground.x, positions.ground.y, sizes.ground.x*sizes.multipler, sizes.ground.y*sizes.multipler, 0.0, -1)
end

function moveBackground()
    if positions.background.x == 200 then
        reverse = true
    elseif positions.background.x == 50 then
        reverse = false
    end
    if reverse then
        positions.background.x = positions.background.x - 1
    else
        positions.background.x = positions.background.x + 1
    end
end
