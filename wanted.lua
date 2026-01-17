queue_on_teleport([[
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local PLACE_ID = game.PlaceId

-- Удаляем старый GUI если он есть, чтобы не дублировать
if CoreGui:FindFirstChild("MiniServerHopGui") then
    CoreGui.MiniServerHopGui:Destroy()
end

local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "MiniServerHopGui"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 120)
frame.Position = UDim2.new(0.5, -100, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 20)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "Aroon's Serverhop"
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16

local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 100, 0, 25)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.Text = "Toggle GUI"
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

toggleBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

local hopBtn = Instance.new("TextButton", frame)
hopBtn.Size = UDim2.new(1, -20, 0, 40)
hopBtn.Position = UDim2.new(0, 10, 0, 25)
hopBtn.Text = "Server Hop"
hopBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
hopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
hopBtn.Font = Enum.Font.SourceSansBold
hopBtn.TextSize = 18
Instance.new("UICorner", hopBtn).CornerRadius = UDim.new(0, 6)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, -20, 0, 20)
status.Position = UDim2.new(0, 10, 0, 75)
status.BackgroundTransparency = 1
status.Text = "Ready"
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.Font = Enum.Font.SourceSans
status.TextSize = 14
status.TextXAlignment = Enum.TextXAlignment.Center

-- ФУНКЦИЯ SERVER HOP
local function serverHop()
    status.Text = "Searching..."
    local cursor = "" 
    local foundServer = false
    
    -- Цикл поиска
    while not foundServer do
        -- Формируем URL с учетом курсора (страницы)
        local url = "https://games.roblox.com/v1/games/" .. PLACE_ID .. "/servers/Public?sortOrder=Asc&limit=100"
        if cursor ~= "" then
            url = url .. "&cursor=" .. cursor
        end
        
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
        
        if success and result and result.data then
            -- Проходимся по серверам на этой странице
            for _, server in pairs(result.data) do
                -- Условие: не сервер, где мы сейчас, и есть место (макс игроков - 1)
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    foundServer = true
                    status.Text = "Hopping..."
                    
                    -- Попытка телепортации
                    TeleportService:TeleportToPlaceInstance(PLACE_ID, server.id, LocalPlayer)
                    return true
                end
            end
            
            -- Если на этой странице нет мест, берем курсор следующей страницы
            if result.nextPageCursor then
                cursor = result.nextPageCursor
                status.Text = "Scanning next page..."
                task.wait(0.1) -- Небольшая задержка, чтобы не спамить запросами
            else
                -- Если страниц больше нет
                status.Text = "No servers found."
                break
            end
        else
            status.Text = "HTTP Error"
            warn("Error fetching servers: ", result)
            task.wait(1)
        end
    end
    return false
end

-- ... (весь код выше с GUI и функцией serverHop оставляем без изменений)

hopBtn.MouseButton1Click:Connect(function()
    serverHop()
end)

-- Загрузка внешнего скрипта (оставляем как было у вас)
task.spawn(function()
    local success, err = pcall(function()
        loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/29098fa663885d53fa8e864a605fe7bc.lua"))()
    end)
    
    if not success then
        warn("Ошибка запуска внешнего скрипта:", err)
    end
end)

-- Теперь этот код выполнится сразу, не дожидаясь окончания загрузки скрипта выше
print("Внешний скрипт запущен в фоне, продолжаем выполнение...")
print("dada")
-- === ИСПРАВЛЕННАЯ АВТОМАТИЧЕСКАЯ ЧАСТЬ ===

task.spawn(function()
    -- Ждем полной загрузки игры, чтобы скрипт не сломался на старте
    if not game:IsLoaded() then game.Loaded:Wait() end
    
    -- Настройки времени
    local waitTime = 300 -- Время ожидания перед попыткой (в секундах)
    
    print("Auto-hop timer started: " .. waitTime .. " seconds")
    
    -- Бесконечный цикл, который не остановится, пока не телепортирует
    while true do
        task.wait(waitTime) -- Ждем указанное время
        
        print("Starting auto-hop...")
        local success = serverHop()
        
        if success then
            print("Teleporting...")
            break -- Выходим из цикла, так как телепортация началась
        else
            print("Auto-hop failed or no server found. Retrying shortly...")
            -- Если не вышло, ждем немного (например, 5 секунд) и пробуем снова, 
            -- не ожидая полные 60 секунд заново (или можно поставить waitTime)
            task.wait(5) 
        end
    end
end)

]])

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local PLACE_ID = game.PlaceId

-- Удаляем старый GUI если он есть, чтобы не дублировать
if CoreGui:FindFirstChild("MiniServerHopGui") then
    CoreGui.MiniServerHopGui:Destroy()
end

local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "MiniServerHopGui"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 120)
frame.Position = UDim2.new(0.5, -100, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 20)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "Aroon's Serverhop"
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16

local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 100, 0, 25)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.Text = "Toggle GUI"
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

toggleBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

local hopBtn = Instance.new("TextButton", frame)
hopBtn.Size = UDim2.new(1, -20, 0, 40)
hopBtn.Position = UDim2.new(0, 10, 0, 25)
hopBtn.Text = "Server Hop"
hopBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
hopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
hopBtn.Font = Enum.Font.SourceSansBold
hopBtn.TextSize = 18
Instance.new("UICorner", hopBtn).CornerRadius = UDim.new(0, 6)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, -20, 0, 20)
status.Position = UDim2.new(0, 10, 0, 75)
status.BackgroundTransparency = 1
status.Text = "Ready"
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.Font = Enum.Font.SourceSans
status.TextSize = 14
status.TextXAlignment = Enum.TextXAlignment.Center

-- ФУНКЦИЯ SERVER HOP
local function serverHop()
    status.Text = "Searching..."
    local cursor = "" 
    local foundServer = false
    
    -- Цикл поиска
    while not foundServer do
        -- Формируем URL с учетом курсора (страницы)
        local url = "https://games.roblox.com/v1/games/" .. PLACE_ID .. "/servers/Public?sortOrder=Asc&limit=100"
        if cursor ~= "" then
            url = url .. "&cursor=" .. cursor
        end
        
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
        
        if success and result and result.data then
            -- Проходимся по серверам на этой странице
            for _, server in pairs(result.data) do
                -- Условие: не сервер, где мы сейчас, и есть место (макс игроков - 1)
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    foundServer = true
                    status.Text = "Hopping..."
                    
                    -- Попытка телепортации
                    TeleportService:TeleportToPlaceInstance(PLACE_ID, server.id, LocalPlayer)
                    return true
                end
            end
            
            -- Если на этой странице нет мест, берем курсор следующей страницы
            if result.nextPageCursor then
                cursor = result.nextPageCursor
                status.Text = "Scanning next page..."
                task.wait(0.1) -- Небольшая задержка, чтобы не спамить запросами
            else
                -- Если страниц больше нет
                status.Text = "No servers found."
                break
            end
        else
            status.Text = "HTTP Error"
            warn("Error fetching servers: ", result)
            task.wait(1)
        end
    end
    return false
end

-- ... (весь код выше с GUI и функцией serverHop оставляем без изменений)

hopBtn.MouseButton1Click:Connect(function()
    serverHop()
end)

-- Загрузка внешнего скрипта (оставляем как было у вас)
task.spawn(function()
    local success, err = pcall(function()
        loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/29098fa663885d53fa8e864a605fe7bc.lua"))()
    end)
    
    if not success then
        warn("Ошибка запуска внешнего скрипта:", err)
    end
end)

-- Теперь этот код выполнится сразу, не дожидаясь окончания загрузки скрипта выше
print("Внешний скрипт запущен в фоне, продолжаем выполнение...")
print("dada")
-- === ИСПРАВЛЕННАЯ АВТОМАТИЧЕСКАЯ ЧАСТЬ ===

task.spawn(function()
    -- Ждем полной загрузки игры, чтобы скрипт не сломался на старте
    if not game:IsLoaded() then game.Loaded:Wait() end
    
    -- Настройки времени
    local waitTime = 300 -- Время ожидания перед попыткой (в секундах)
    
    print("Auto-hop timer started: " .. waitTime .. " seconds")
    
    -- Бесконечный цикл, который не остановится, пока не телепортирует
    while true do
        task.wait(waitTime) -- Ждем указанное время
        
        print("Starting auto-hop...")
        local success = serverHop()
        
        if success then
            print("Teleporting...")
            break -- Выходим из цикла, так как телепортация началась
        else
            print("Auto-hop failed or no server found. Retrying shortly...")
            -- Если не вышло, ждем немного (например, 5 секунд) и пробуем снова, 
            -- не ожидая полные 60 секунд заново (или можно поставить waitTime)
            task.wait(5) 
        end
    end
end)
