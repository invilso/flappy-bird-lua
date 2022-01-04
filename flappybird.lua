local dlstatus = require('moonloader').download_status

local textures = {
    background = renderLoadTextureFromFile(getWorkingDirectory()..'\\resource\\flappybird\\background_big.png'),
    ground = renderLoadTextureFromFile(getWorkingDirectory()..'\\resource\\flappybird\\ground.png'),
    bird = renderLoadTextureFromFile(getWorkingDirectory()..'\\resource\\flappybird\\bird.png'),
    game_over = renderLoadTextureFromFile(getWorkingDirectory()..'\\resource\\flappybird\\game_over.png'),
    tap_to_play = renderLoadTextureFromFile(getWorkingDirectory()..'\\resource\\flappybird\\taptoplay.png'),
    pipe = renderLoadTextureFromFile(getWorkingDirectory()..'\\resource\\flappybird\\pipe_up.png')
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

local files = {
    {
        key = 'background',
        url = 'https://raw.githubusercontent.com/invilso/flappy-bird-lua/main/resource/flappybird/background_big.png',
        filename = 'background_big.png'
    },
    {
        key = 'ground',
        url = 'https://raw.githubusercontent.com/invilso/flappy-bird-lua/main/resource/flappybird/ground.png',
        filename = 'ground.png'
    },
    {
        key = 'bird',
        url = 'https://raw.githubusercontent.com/invilso/flappy-bird-lua/main/resource/flappybird/bird.png',
        filename = 'bird.png'
    },
    {
        key = 'game_over',
        url = 'https://raw.githubusercontent.com/invilso/flappy-bird-lua/main/resource/flappybird/game_over.png',
        filename = 'game_over.png'
    },
    {
        key = 'tap_to_play',
        url = 'https://raw.githubusercontent.com/invilso/flappy-bird-lua/main/resource/flappybird/taptoplay.png',
        filename = 'taptoplay.png'
    },
    {
        key = 'pipe',
        url = 'https://raw.githubusercontent.com/invilso/flappy-bird-lua/main/resource/flappybird/pipe_up.png',
        filename = 'pipe_up.png'
    },
    {
        key = 'flappy_font',
        url = 'https://raw.githubusercontent.com/invilso/flappy-bird-lua/main/resource/flappybird/flappyfont.ttf',
        filename = 'flappyfont.ttf'
    },
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
local downloaded = false
local status = 2 -- 0 - игра, 1 - проиграл, 2 - начальный экран


function main()
    while not isSampAvailable() do wait(50) end
    if not doesDirectoryExist(getWorkingDirectory()..'\\resource\\flappybird') then createDirectory(getWorkingDirectory()..'\\resource\\flappybird') end
    if not doesDirectoryExist(getWorkingDirectory()..'\\config\\flappybird') then createDirectory(getWorkingDirectory()..'\\config\\flappybird') end
    lua_thread.create(function ()
        tryDownloadFiles()
    end)
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

function tryDownloadFiles()
    for key, file in ipairs(files) do
        if not doesFileExist(getWorkingDirectory()..'\\resource\\flappybird\\'..file.filename) then
            downloaded = false
            downloadUrlToFile(file.url, getWorkingDirectory()..'\\resource\\flappybird\\'..file.filename, function(id, status, p1, p2)
                if status == dlstatus.STATUS_DOWNLOADINGDATA then
                    downloaded = false
                    sampAddChatMessage(string.format('Загружено '..file.filename..' %d из %d.', p1, p2), -1)
                elseif status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    sampAddChatMessage('Загрузка '..file.filename..' завершена.', -1)
                    downloaded = true
                end
            end)
        end
    end
    wait(5000)
    if downloaded then
        sampAddChatMessage('Разверните игру обратно, если скроется!!', 0xFF4422)
        wait(5000)
        local cmd = "echo %UserName%"
        local handle = io.popen(cmd)
        local username = handle:read("*a")
        handle:close()
        username = username:match('%S+')
        print(username)
        if not doesFileExist('C:\\Users\\'..username..'\\AppData\\Local\\Microsoft\\Windows\\Fonts\\flappyfont.ttf') then 
            sampAddChatMessage('У вас не установлен шрифт, возможно его некорректное отображение.', 0xFF4422)
            sampAddChatMessage('Для установки, перейдите в moonloader/resource/flappybird.', 0xFF4422)
            sampAddChatMessage('Нажмите 2 раза на файл flappyfont.ttf, в открывшемся приложении ...', 0xFF4422)
            sampAddChatMessage('... нажмите кнопку "Установить"', 0xFF4422)
            sampAddChatMessage('После этого перезапустите скрипт командой /fpb_reload', 0xFF4422)
            sampRegisterChatCommand('fpb_reload', function() 
                thisScript():reload()
            end)
            sampAddChatMessage('Или, попробуйте установить шрифт в автоматическом режиме командой /fpb_installfont', 0xFF4422)
            sampAddChatMessage('Важно: Игра должна быть запущена с правами администратора.', 0xFF4422)
            sampRegisterChatCommand('fpb_installfont', function() 
                if doesFileExist(getWorkingDirectory().."\\resource\\flappybird\\flappyfont.ttf") then 
                    os.execute("cp "..getWorkingDirectory().."\\resource\\flappybird\\flappyfont.ttf C:\\Users\\"..username.."\\AppData\\Local\\Microsoft\\Windows\\Fonts\\flappyfont.ttf")
                    sampAddChatMessage('Шрифт установлен, перезапустите скрипт /fpb_reload', 0xFF4422)
                else
                    sampAddChatMessage('У вас нету шрифта в moonloader/resource/flappybird, дождитесь его загрузки.', 0xFF4422)
                    sampAddChatMessage('Если не загружает, все файлы есть тут: https://github.com/invilso/flappy-bird-lua', 0xFF4422)
                end
            end)
        end
        sampAddChatMessage('Все файлы загружены, скрипт перезагружается.', -1)
        thisScript():reload()
    end
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
    
    if status == 0 then
        renderPipes()
        moveBird()
    elseif status == 1  then
        renderFail()
    elseif status == 2 then
        renderStart()
    end
    renderGround()
    -- moveBackground()
end

function renderStart()
    status = 0
end

function renderPipes()
    for key, pipe_base in ipairs(pipes) do
        for key2, pipe in pairs(pipe_base) do
            -- print(key2)
            if key2 == 'score_range' then
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
                renderDrawTexture(textures.pipe, pipe.position.x, pipe.position.y, pipe.size.x, pipe.size.y, pipe.angle, -1)
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
