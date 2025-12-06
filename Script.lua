--[[
  NV Cheat Menu для Roblox
  Версия: 2.0 (Rayfield UI Edition)
  Использование на свой страх и риск!
]]

-- Загрузка Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

-- Инициализация Rayfield
local Window = Rayfield:CreateWindow({
    Name = "🎮 NV Menu v2.0",
    LoadingTitle = "Загрузка...",
    LoadingSubtitle = "by NV",
    ConfigurationSaving = {
        Enabled = false,
        FileName = "NVConfig"
    },
    Telegram = {
        Enabled = false,
        Invite = "https://t.me/CorescriptsII",
        RememberJoins = true
    },
    KeySystem = false
})

-- Основные сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- Локальные переменные
local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = Player:GetMouse()

-- Состояния функций
local States = {
    AimBot = false,
    BunnyHop = false,
    Spin = false,
    AutoShoot = false,
    ESP = false,
    Speed = false
}

-- Хранение соединений
local Connections = {}
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "NV_ESP"
ESPFolder.Parent = workspace

-- Утилиты
local function GetCharacter()
    return Player.Character or Player.CharacterAdded:Wait()
end

local function GetRootPart()
    local character = GetCharacter()
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid()
    local character = GetCharacter()
    return character and character:FindFirstChild("Humanoid")
end

-- Функция поиска ближайшего игрока
local function FindNearestPlayer(range, checkTeam)
    local myRoot = GetRootPart()
    if not myRoot then return nil end
    
    local nearestPlayer = nil
    local nearestDistance = range
    
    for _, target in pairs(Players:GetPlayers()) do
        if target ~= Player and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            if checkTeam and target.Team == Player.Team then
                continue
            end
            
            local targetRoot = target.Character.HumanoidRootPart
            local distance = (myRoot.Position - targetRoot.Position).Magnitude
            
            if distance < nearestDistance then
                nearestDistance = distance
                nearestPlayer = target
            end
        end
    end
    
    return nearestPlayer, nearestDistance
end

-- Создание вкладок
local MainTab = Window:CreateTab("Основные", "rbxassetid://4483345998")
local VisualsTab = Window:CreateTab("Визуалы", "rbxassetid://4483345998")
local PlayerTab = Window:CreateTab("Игрок", "rbxassetid://4483345998")
local SettingsTab = Window:CreateTab("Настройки", "rbxassetid://4483345998")

-- Разделы
local CombatSection = MainTab:CreateSection("Боевые функции")
local MovementSection = MainTab:CreateSection("Передвижение")
local VisualsSection = VisualsTab:CreateSection("Визуальные эффекты")
local PlayerSection = PlayerTab:CreateSection("Модификации игрока")
local ConfigSection = SettingsTab:CreateSection("Конфигурация")

-- АИМБОТ
local AimBotToggle = CombatSection:CreateToggle({
    Name = "Аимбот",
    CurrentValue = false,
    Flag = "AimBotToggle",
    Callback = function(Value)
        States.AimBot = Value
        
        if Value then
            Connections.AimBot = RunService.RenderStepped:Connect(function()
                local target, distance = FindNearestPlayer(AimBotRangeSlider.CurrentValue, IgnoreTeamToggle.CurrentValue)
                
                if target and target.Character then
                    local targetRoot = target.Character:FindFirstChild(AimBotPartDropdown.CurrentValue)
                    local targetHead = target.Character:FindFirstChild("Head")
                    
                    if targetRoot and Camera then
                        local prediction = 0
                        if AimPredictionToggle.CurrentValue and targetRoot.Velocity.Magnitude > 0 then
                            prediction = (distance / AimBotPredictionSlider.CurrentValue) * (targetRoot.Velocity.Magnitude / 100)
                        end
                        
                        local targetPosition = targetRoot.Position + targetRoot.Velocity * prediction
                        
                        if SmoothAimToggle.CurrentValue then
                            local smoothness = AimSmoothnessSlider.CurrentValue
                            local currentCFrame = Camera.CFrame
                            local targetCFrame = CFrame.new(currentCFrame.Position, targetPosition)
                            Camera.CFrame = currentCFrame:Lerp(targetCFrame, 1 - (smoothness / 100))
                        else
                            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
                        end
                    end
                end
            end)
        else
            if Connections.AimBot then
                Connections.AimBot:Disconnect()
                Connections.AimBot = nil
            end
        end
    end
})

-- Настройки аимбота
local AimBotRangeSlider = CombatSection:CreateSlider({
    Name = "Дальность аимбота",
    Range = {100, 1000},
    Increment = 10,
    Suffix = "studs",
    CurrentValue = 200,
    Flag = "AimBotRange",
    Callback = function(Value) end
})

local AimBotPartDropdown = CombatSection:CreateDropdown({
    Name = "Часть тела",
    Options = {"HumanoidRootPart", "Head", "UpperTorso"},
    CurrentOption = "HumanoidRootPart",
    Flag = "AimBotPart",
    Callback = function(Option) end
})

local SmoothAimToggle = CombatSection:CreateToggle({
    Name = "Плавный аим",
    CurrentValue = false,
    Flag = "SmoothAim",
    Callback = function(Value) end
})

local AimSmoothnessSlider = CombatSection:CreateSlider({
    Name = "Сглаживание аима",
    Range = {1, 20},
    Increment = 1,
    Suffix = "",
    CurrentValue = 10,
    Flag = "AimSmoothness",
    Callback = function(Value) end
})

local AimPredictionToggle = CombatSection:CreateToggle({
    Name = "Предсказание",
    CurrentValue = false,
    Flag = "AimPrediction",
    Callback = function(Value) end
})

local AimBotPredictionSlider = CombatSection:CreateSlider({
    Name = "Сила предсказания",
    Range = {10, 100},
    Increment = 5,
    Suffix = "",
    CurrentValue = 30,
    Flag = "AimPredictionPower",
    Callback = function(Value) end
})

local IgnoreTeamToggle = CombatSection:CreateToggle({
    Name = "Игнорировать команду",
    CurrentValue = true,
    Flag = "IgnoreTeam",
    Callback = function(Value) end
})

-- БАННИ-ХОП
local BunnyHopToggle = MovementSection:CreateToggle({
    Name = "Банни-хоп",
    CurrentValue = false,
    Flag = "BunnyHopToggle",
    Callback = function(Value)
        States.BunnyHop = Value
        
        if Value then
            Connections.BunnyHop = RunService.Heartbeat:Connect(function()
                local humanoid = GetHumanoid()
                if humanoid and humanoid.FloorMaterial == Enum.Material.Air then
                    humanoid.Jump = true
                end
            end)
        else
            if Connections.BunnyHop then
                Connections.BunnyHop:Disconnect()
                Connections.BunnyHop = nil
            end
        end
    end
})

-- КРУТИЛКА
local SpinToggle = MovementSection:CreateToggle({
    Name = "Крутилка",
    CurrentValue = false,
    Flag = "SpinToggle",
    Callback = function(Value)
        States.Spin = Value
        
        if Value then
            Connections.Spin = RunService.RenderStepped:Connect(function()
                local root = GetRootPart()
                if root then
                    local speed = SpinSpeedSlider.CurrentValue
                    root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(speed), 0)
                end
            end)
        else
            if Connections.Spin then
                Connections.Spin:Disconnect()
                Connections.Spin = nil
            end
        end
    end
})

local SpinSpeedSlider = MovementSection:CreateSlider({
    Name = "Скорость кручения",
    Range = {5, 50},
    Increment = 1,
    Suffix = "",
    CurrentValue = 12,
    Flag = "SpinSpeed",
    Callback = function(Value) end
})

-- АВТОСТРЕЛЬБА
local AutoShootToggle = CombatSection:CreateToggle({
    Name = "Автострельба",
    CurrentValue = false,
    Flag = "AutoShootToggle",
    Callback = function(Value)
        States.AutoShoot = Value
        
        if Value then
            Connections.AutoShoot = RunService.RenderStepped:Connect(function()
                local target, distance = FindNearestPlayer(AutoShootRangeSlider.CurrentValue, IgnoreTeamToggle.CurrentValue)
                
                if target and target.Character then
                    local character = GetCharacter()
                    if character then
                        for _, tool in pairs(character:GetChildren()) do
                            if tool:IsA("Tool") then
                                local remote = tool:FindFirstChildOfClass("RemoteEvent") or tool:FindFirstChildOfClass("RemoteFunction")
                                if remote then
                                    remote:FireServer()
                                else
                                    tool:Activate()
                                end
                                break
                            end
                        end
                    end
                end
            end)
        else
            if Connections.AutoShoot then
                Connections.AutoShoot:Disconnect()
                Connections.AutoShoot = nil
            end
        end
    end
})

local AutoShootRangeSlider = CombatSection:CreateSlider({
    Name = "Дальность автострельбы",
    Range = {10, 200},
    Increment = 5,
    Suffix = "studs",
    CurrentValue = 100,
    Flag = "AutoShootRange",
    Callback = function(Value) end
})

-- ESP (Wallhack)
local ESPToggle = VisualsSection:CreateToggle({
    Name = "ESP (Wallhack)",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(Value)
        States.ESP = Value
        
        if Value then
            local function CreateESP(player)
                if player == Player then return end
                
                local character = player.Character
                if not character then return end
                
                local highlight = Instance.new("Highlight")
                highlight.Name = player.Name .. "_ESP"
                highlight.Adornee = character
                highlight.FillColor = player.Team == Player.Team and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                highlight.FillTransparency = 0.7
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.OutlineTransparency = 0
                highlight.Parent = ESPFolder
                
                local textLabel = Instance.new("TextLabel")
                textLabel.Name = "DistanceLabel"
                textLabel.Text = player.Name
                textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                textLabel.BackgroundTransparency = 1
                textLabel.Size = UDim2.new(0, 100, 0, 20)
                textLabel.Font = Enum.Font.SourceSansBold
                textLabel.TextSize = 14
                
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "ESP_Billboard"
                billboard.Adornee = character:WaitForChild("Head")
                billboard.Size = UDim2.new(0, 100, 0, 50)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = character.Head
                textLabel.Parent = billboard
                
                Connections[player.Name .. "_ESP"] = RunService.RenderStepped:Connect(function()
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        local distance = (GetRootPart().Position - character.HumanoidRootPart.Position).Magnitude
                        textLabel.Text = string.format("%s [%d]", player.Name, math.floor(distance))
                    end
                end)
            end
            
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character then
                    CreateESP(player)
                end
                
                player.CharacterAdded:Connect(function(character)
                    CreateESP(player)
                end)
            end
            
            Players.PlayerAdded:Connect(function(player)
                player.CharacterAdded:Connect(function(character)
                    CreateESP(player)
                end)
            end)
        else
            for name, connection in pairs(Connections) do
                if string.find(name, "_ESP") then
                    connection:Disconnect()
                end
            end
            
            for _, child in pairs(ESPFolder:GetChildren()) do
                child:Destroy()
            end
            
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("Head") then
                    local billboard = player.Character.Head:FindFirstChild("ESP_Billboard")
                    if billboard then
                        billboard:Destroy()
                    end
                end
            end
        end
    end
})

-- УВЕЛИЧЕНИЕ СКОРОСТИ
local SpeedToggle = PlayerSection:CreateToggle({
    Name = "Увеличение скорости",
    CurrentValue = false,
    Flag = "SpeedToggle",
    Callback = function(Value)
        States.Speed = Value
        
        if Value then
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid.WalkSpeed = SpeedValueSlider.CurrentValue
            end
            
            Connections.Speed = Player.CharacterAdded:Connect(function(character)
                wait(0.5)
                local hum = character:WaitForChild("Humanoid")
                hum.WalkSpeed = SpeedValueSlider.CurrentValue
            end)
        else
            if Connections.Speed then
                Connections.Speed:Disconnect()
                Connections.Speed = nil
            end
            
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid.WalkSpeed = 16
            end
        end
    end
})

local SpeedValueSlider = PlayerSection:CreateSlider({
    Name = "Значение скорости",
    Range = {16, 100},
    Increment = 2,
    Suffix = "studs",
    CurrentValue = 50,
    Flag = "SpeedValue",
    Callback = function(Value)
        if States.Speed then
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid.WalkSpeed = Value
            end
        end
    end
})

-- УВЕЛИЧЕНИЕ ПРЫЖКА
local JumpPowerToggle = PlayerSection:CreateToggle({
    Name = "Увеличение прыжка",
    CurrentValue = false,
    Flag = "JumpPowerToggle",
    Callback = function(Value)
        if Value then
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid.JumpPower = JumpPowerSlider.CurrentValue
            end
            
            Connections.JumpPower = Player.CharacterAdded:Connect(function(character)
                wait(0.5)
                local hum = character:WaitForChild("Humanoid")
                hum.JumpPower = JumpPowerSlider.CurrentValue
            end)
        else
            if Connections.JumpPower then
                Connections.JumpPower:Disconnect()
                Connections.JumpPower = nil
            end
            
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid.JumpPower = 50
            end
        end
    end
})

local JumpPowerSlider = PlayerSection:CreateSlider({
    Name = "Сила прыжка",
    Range = {50, 200},
    Increment = 5,
    Suffix = "",
    CurrentValue = 100,
    Flag = "JumpPowerValue",
    Callback = function(Value)
        if JumpPowerToggle.CurrentValue then
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid.JumpPower = Value
            end
        end
    end
})

-- НОЧНОЕ ЗРЕНИЕ
local NightVisionToggle = VisualsSection:CreateToggle({
    Name = "Ночное зрение",
    CurrentValue = false,
    Flag = "NightVisionToggle",
    Callback = function(Value)
        if Value then
            local lighting = game:GetService("Lighting")
            lighting.Ambient = Color3.fromRGB(255, 255, 255)
            lighting.Brightness = 3
            lighting.ClockTime = 14
            lighting.GeographicLatitude = 41.73
            lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        else
            local lighting = game:GetService("Lighting")
            lighting.Ambient = Color3.fromRGB(0, 0, 0)
            lighting.Brightness = 1
            lighting.ClockTime = 14
            lighting.GeographicLatitude = 41.73
            lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
        end
    end
})

-- КНОПКИ УПРАВЛЕНИЯ
local EmergencyButton = ConfigSection:CreateButton({
    Name = "⛔ Экстренное отключение",
    Callback = function()
        -- Отключаем все функции
        AimBotToggle:Set(false)
        BunnyHopToggle:Set(false)
        SpinToggle:Set(false)
        AutoShootToggle:Set(false)
        ESPToggle:Set(false)
        SpeedToggle:Set(false)
        JumpPowerToggle:Set(false)
        NightVisionToggle:Set(false)
        
        -- Отключаем все соединения
        for name, connection in pairs(Connections) do
            if connection then
                connection:Disconnect()
            end
        end
        
        -- Очищаем ESP
        for _, child in pairs(ESPFolder:GetChildren()) do
            child:Destroy()
        end
        
        -- Сбрасываем скорость и прыжок
        local humanoid = GetHumanoid()
        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
        end
        
        Rayfield:Notify({
            Title = "Экстренное отключение",
            Content = "Все функции были отключены!",
            Duration = 3,
            Image = "rbxassetid://4483345998"
        })
    end
})

local RefreshButton = ConfigSection:CreateButton({
    Name = "🔄 Обновить персонажа",
    Callback = function()
        local character = GetCharacter()
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.Health = 0
            end
        end
    end
})

-- ИНФОРМАЦИОННЫЙ ЛЕЙБЛ
ConfigSection:CreateLabel("Управление:")
ConfigSection:CreateLabel("K - Показать/скрыть меню")
ConfigSection:CreateLabel("F10 - Экстренное отключение")

-- ФУНКЦИИ ГОРЯЧИХ КЛАВИШ
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.K then
        Rayfield:Toggle()
    elseif input.KeyCode == Enum.KeyCode.F10 then
        EmergencyButton.Callback()
    end
end)

-- УВЕДОМЛЕНИЕ О ЗАГРУЗКЕ
wait(1)
Rayfield:Notify({
    Title = "NV Cheat Menu v2.0",
    Content = "Меню успешно загружено! Нажмите K для открытия.",
    Duration = 5,
    Image = "rbxassetid://4483345998"
})

print("======================================")
print("NV Menu v2.0")
print("Успешно загружен!")
print("Управление: K - меню, F10 - отключение")
print("======================================") 