--[[
  NV Cheat Menu - Rayfield UI Edition
  Версия: 3.0
  Использование на свой страх и риск!
]]

-- Загрузка Rayfield UI библиотеки
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Создание главного окна (используя вашу конфигурацию)
local Window = Rayfield:CreateWindow({
   Name = "🎮 NV Cheat Menu v3.0",
   LoadingTitle = "Rayfield Interface Suite",
   LoadingSubtitle = "by NV | Модифицировано от Sirius",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "NV_Cheat_Config", -- Папка для сохранения настроек
      FileName = "NV_Cheat_Settings"
   },
   Telegram = {
      Enabled = true,
      Invite = "https://t.me/CorescriptsII",
      RememberJoins = true
   },
   KeySystem = false, -- Можно включить систему ключей при необходимости
   KeySettings = {
      Title = "NV Cheat Menu - Доступ",
      Subtitle = "Система ключей",
      Note = "Обратитесь к автору для получения ключа",
      FileName = "NV_Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"NV2024", "CheatMenuAccess"}
   }
})

-- Основные сервисы Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

-- Локальные переменные
local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Создание вкладок
local MainTab = Window:CreateTab("Главная", "rbxassetid://4483345998") -- Иконка шестерёнки
local VisualsTab = Window:CreateTab("Визуал", "rbxassetid://4483362458")
local PlayerTab = Window:CreateTab("Игрок", "rbxassetid://4483362458")
local SettingsTab = Window:CreateTab("Настройки", "rbxassetid://4483362458")

-- Создание разделов
local CombatSection = MainTab:CreateSection("Боевые функции")
local MovementSection = MainTab:CreateSection("Передвижение")
local ESPsection = VisualsTab:CreateSection("ESP / Визуализация")
local EffectsSection = VisualsTab:CreateSection("Эффекты")
local CharacterSection = PlayerTab:CreateSection("Персонаж")
local ConfigSection = SettingsTab:CreateSection("Конфигурация")
local InfoSection = SettingsTab:CreateSection("Информация")

-- Глобальные состояния и соединения
local CheatStates = {}
local Connections = {}
local ESPFolders = {}

-- Утилитарные функции
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

local function FindNearestPlayer(range, ignoreTeam)
    local myRoot = GetRootPart()
    if not myRoot then return nil, 0 end
    
    local nearestPlayer = nil
    local nearestDistance = range or 500
    
    for _, target in pairs(Players:GetPlayers()) do
        if target ~= Player and target.Character then
            if ignoreTeam and target.Team and Player.Team and target.Team == Player.Team then
                continue
            end
            
            local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local distance = (myRoot.Position - targetRoot.Position).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestPlayer = target
                end
            end
        end
    end
    
    return nearestPlayer, nearestDistance
end

-- 1. АИМБОТ система
local AimBotToggle = CombatSection:CreateToggle({
    Name = "Аимбот",
    CurrentValue = false,
    Flag = "AimBotEnabled",
    Callback = function(Value)
        CheatStates.AimBot = Value
        
        if Value then
            Connections.AimBot = RunService.RenderStepped:Connect(function()
                local target, distance = FindNearestPlayer(AimBotRangeSlider.CurrentValue, IgnoreTeamToggle.CurrentValue)
                
                if target and target.Character then
                    local targetPart = target.Character:FindFirstChild(AimBotPartDropdown.CurrentOption)
                    if targetPart and Camera then
                        local prediction = 0
                        if AimPredictionToggle.CurrentValue then
                            prediction = (distance / AimBotPredictionSlider.CurrentValue) * (targetPart.Velocity.Magnitude / 100)
                        end
                        
                        local targetPos = targetPart.Position + targetPart.Velocity * prediction
                        
                        if SmoothAimToggle.CurrentValue then
                            local smoothFactor = AimSmoothnessSlider.CurrentValue / 100
                            Camera.CFrame = Camera.CFrame:Lerp(
                                CFrame.new(Camera.CFrame.Position, targetPos),
                                1 - smoothFactor
                            )
                        else
                            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
                        end
                    end
                end
            end)
            
            Rayfield:Notify({
                Title = "Аимбот активирован",
                Content = "Наведение на ближайшего противника",
                Duration = 2,
            })
        else
            if Connections.AimBot then
                Connections.AimBot:Disconnect()
                Connections.AimBot = nil
            end
        end
    end,
})

-- Настройки аимбота
local AimBotRangeSlider = CombatSection:CreateSlider({
    Name = "Дальность аимбота",
    Range = {50, 1000},
    Increment = 25,
    Suffix = "studs",
    CurrentValue = 1000,
    Flag = "AimBotRange",
    Callback = function(Value) end,
})

local AimBotPartDropdown = CombatSection:CreateDropdown({
    Name = "Цель для аимбота",
    Options = {"Head", "HumanoidRootPart", "UpperTorso"},
    CurrentOption = "Head",
    Flag = "AimBotPart",
    Callback = function(Option) end,
})

local SmoothAimToggle = CombatSection:CreateToggle({
    Name = "Плавный аим",
    CurrentValue = true,
    Flag = "SmoothAimEnabled",
    Callback = function(Value) end,
})

local AimSmoothnessSlider = CombatSection:CreateSlider({
    Name = "Сглаживание аима",
    Range = {1, 100},
    Increment = 5,
    Suffix = "%",
    CurrentValue = 30,
    Flag = "AimSmoothness",
    Callback = function(Value) end,
})

local AimPredictionToggle = CombatSection:CreateToggle({
    Name = "Предсказание движения",
    CurrentValue = false,
    Flag = "AimPrediction",
    Callback = function(Value) end,
})

local AimBotPredictionSlider = CombatSection:CreateSlider({
    Name = "Сила предсказания",
    Range = {10, 100},
    Increment = 5,
    Suffix = "",
    CurrentValue = 50,
    Flag = "PredictionStrength",
    Callback = function(Value) end,
})

local IgnoreTeamToggle = CombatSection:CreateToggle({
    Name = "Игнорировать свою команду",
    CurrentValue = true,
    Flag = "IgnoreTeam",
    Callback = function(Value) end,
})

-- 2. БАННИ-ХОП
local BunnyHopToggle = MovementSection:CreateToggle({
    Name = "Банни-хоп",
    CurrentValue = false,
    Flag = "BunnyHopEnabled",
    Callback = function(Value)
        CheatStates.BunnyHop = Value
        
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
    end,
})

-- 3. КРУТИЛКА
local SpinToggle = MovementSection:CreateToggle({
    Name = "Крутилка",
    CurrentValue = false,
    Flag = "SpinEnabled",
    Callback = function(Value)
        CheatStates.Spin = Value
        
        if Value then
            Connections.Spin = RunService.RenderStepped:Connect(function()
                local root = GetRootPart()
                if root then
                    root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(SpinSpeedSlider.CurrentValue), 0)
                end
            end)
        else
            if Connections.Spin then
                Connections.Spin:Disconnect()
                Connections.Spin = nil
            end
        end
    end,
})

local SpinSpeedSlider = MovementSection:CreateSlider({
    Name = "Скорость вращения",
    Range = {5, 50},
    Increment = 1,
    Suffix = "град/кадр",
    CurrentValue = 12,
    Flag = "SpinSpeed",
    Callback = function(Value) end,
})

-- 4. АВТОСТРЕЛЬБА
local AutoShootToggle = CombatSection:CreateToggle({
    Name = "Автострельба",
    CurrentValue = false,
    Flag = "AutoShootEnabled",
    Callback = function(Value)
        CheatStates.AutoShoot = Value
        
        if Value then
            Connections.AutoShoot = RunService.RenderStepped:Connect(function()
                local target, distance = FindNearestPlayer(100, IgnoreTeamToggle.CurrentValue)
                
                if target and target.Character then
                    local character = GetCharacter()
                    if character then
                        for _, tool in pairs(character:GetChildren()) do
                            if tool:IsA("Tool") then
                                local remote = tool:FindFirstChildOfClass("RemoteEvent") or 
                                              tool:FindFirstChildOfClass("RemoteFunction")
                                if remote then
                                    pcall(function()
                                        remote:FireServer()
                                    end)
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
    end,
})

-- 5. ESP / Wallhack система
local ESPToggle = ESPsection:CreateToggle({
    Name = "ESP (Подсветка игроков)",
    CurrentValue = false,
    Flag = "ESPEnabled",
    Callback = function(Value)
        CheatStates.ESP = Value
        
        if Value then
            -- Создаем папку для ESP объектов
            ESPFolders.main = Instance.new("Folder")
            ESPFolders.main.Name = "NV_ESP"
            ESPFolders.main.Parent = workspace
            
            local function CreateESP(player)
                if player == Player then return end
                
                local character = player.Character
                if not character then return end
                
                -- Highlight для подсветки
                local highlight = Instance.new("Highlight")
                highlight.Name = player.Name .. "_ESP"
                highlight.Adornee = character
                highlight.FillColor = player.Team == Player.Team and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                highlight.FillTransparency = 0.7
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.OutlineTransparency = 0
                highlight.Parent = ESPFolders.main
                
                -- BillboardGui для отображения имени и дистанции
                if character:FindFirstChild("Head") then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "ESP_Info"
                    billboard.Adornee = character.Head
                    billboard.Size = UDim2.new(0, 200, 0, 50)
                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                    billboard.AlwaysOnTop = true
                    billboard.Parent = character.Head
                    
                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.Name = "NameLabel"
                    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
                    nameLabel.Position = UDim2.new(0, 0, 0, 0)
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.Text = player.Name
                    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    nameLabel.Font = Enum.Font.SourceSansBold
                    nameLabel.TextSize = 14
                    nameLabel.Parent = billboard
                    
                    local distanceLabel = Instance.new("TextLabel")
                    distanceLabel.Name = "DistanceLabel"
                    distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
                    distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
                    distanceLabel.BackgroundTransparency = 1
                    distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                    distanceLabel.Font = Enum.Font.SourceSans
                    distanceLabel.TextSize = 12
                    distanceLabel.Parent = billboard
                    
                    -- Обновление дистанции
                    Connections["ESP_Update_" .. player.Name] = RunService.RenderStepped:Connect(function()
                        if character and character.Parent and GetRootPart() then
                            local distance = (GetRootPart().Position - character:GetPivot().Position).Magnitude
                            distanceLabel.Text = string.format("[%d studs]", math.floor(distance))
                        end
                    end)
                end
            end
            
            -- Создаем ESP для всех существующих игроков
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character then
                    CreateESP(player)
                end
                
                -- Отслеживаем появление новых персонажей
                player.CharacterAdded:Connect(function(character)
                    wait(0.5) -- Ждем загрузки персонажа
                    CreateESP(player)
                end)
            end
            
            -- Отслеживаем новых игроков
            Players.PlayerAdded:Connect(function(player)
                player.CharacterAdded:Connect(function(character)
                    wait(0.5)
                    CreateESP(player)
                end)
            end)
            
        else
            -- Удаляем все ESP объекты
            if ESPFolders.main then
                ESPFolders.main:Destroy()
                ESPFolders.main = nil
            end
            
            -- Отключаем все соединения ESP
            for name, connection in pairs(Connections) do
                if string.find(name, "ESP_") then
                    connection:Disconnect()
                    Connections[name] = nil
                end
            end
            
            -- Удаляем BillboardGui у игроков
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("Head") then
                    local billboard = player.Character.Head:FindFirstChild("ESP_Info")
                    if billboard then
                        billboard:Destroy()
                    end
                end
            end
        end
    end,
})

-- 6. ИЗМЕНЕНИЕ ХАРАКТЕРИСТИК ИГРОКА
local SpeedToggle = CharacterSection:CreateToggle({
    Name = "Изменить скорость",
    CurrentValue = false,
    Flag = "SpeedModEnabled",
    Callback = function(Value)
        if Value then
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid.WalkSpeed = SpeedSlider.CurrentValue
            end
            
            Connections.SpeedMod = Player.CharacterAdded:Connect(function(character)
                wait(0.5)
                local hum = character:WaitForChild("Humanoid")
                hum.WalkSpeed = SpeedSlider.CurrentValue
            end)
        else
            if Connections.SpeedMod then
                Connections.SpeedMod:Disconnect()
                Connections.SpeedMod = nil
            end
            
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid.WalkSpeed = 16
            end
        end
    end,
})

local SpeedSlider = CharacterSection:CreateSlider({
    Name = "Скорость передвижения",
    Range = {16, 200},
    Increment = 4,
    Suffix = "studs/sec",
    CurrentValue = 50,
    Flag = "WalkSpeedValue",
    Callback = function(Value)
        if SpeedToggle.CurrentValue then
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid.WalkSpeed = Value
            end
        end
    end,
})

local JumpToggle = CharacterSection:CreateToggle({
    Name = "Изменить силу прыжка",
    CurrentValue = false,
    Flag = "JumpModEnabled",
    Callback = function(Value)
        if Value then
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid.JumpPower = JumpSlider.CurrentValue
            end
            
            Connections.JumpMod = Player.CharacterAdded:Connect(function(character)
                wait(0.5)
                local hum = character:WaitForChild("Humanoid")
                hum.JumpPower = JumpSlider.CurrentValue
            end)
        else
            if Connections.JumpMod then
                Connections.JumpMod:Disconnect()
                Connections.JumpMod = nil
            end
            
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid.JumpPower = 50
            end
        end
    end,
})

local JumpSlider = CharacterSection:CreateSlider({
    Name = "Сила прыжка",
    Range = {50, 500},
    Increment = 10,
    Suffix = "",
    CurrentValue = 100,
    Flag = "JumpPowerValue",
    Callback = function(Value)
        if JumpToggle.CurrentValue then
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid.JumpPower = Value
            end
        end
    end,
})

-- 7. НОЧНОЕ ЗРЕНИЕ
local NightVisionToggle = EffectsSection:CreateToggle({
    Name = "Ночное зрение",
    CurrentValue = false,
    Flag = "NightVisionEnabled",
    Callback = function(Value)
        if Value then
            local lighting = game:GetService("Lighting")
            lighting.Ambient = Color3.fromRGB(200, 200, 200)
            lighting.Brightness = 2
            lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            
            Connections.NightVision = lighting.Changed:Connect(function()
                if CheatStates.NightVision then
                    lighting.Ambient = Color3.fromRGB(200, 200, 200)
                    lighting.Brightness = 2
                end
            end)
        else
            if Connections.NightVision then
                Connections.NightVision:Disconnect()
                Connections.NightVision = nil
            end
            
            local lighting = game:GetService("Lighting")
            lighting.Ambient = Color3.fromRGB(0, 0, 0)
            lighting.Brightness = 1
            lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
        end
        CheatStates.NightVision = Value
    end,
})

-- КНОПКА ЭКСТРЕННОГО ОТКЛЮЧЕНИЯ
local EmergencyButton = ConfigSection:CreateButton({
    Name = "⛔ ЭКСТРЕННОЕ ОТКЛЮЧЕНИЕ ВСЕГО",
    Callback = function()
        -- Отключаем все тогглы
        AimBotToggle:Set(false)
        BunnyHopToggle:Set(false)
        SpinToggle:Set(false)
        AutoShootToggle:Set(false)
        ESPToggle:Set(false)
        SpeedToggle:Set(false)
        JumpToggle:Set(false)
        NightVisionToggle:Set(false)
        
        -- Сбрасываем все настройки персонажа
        local humanoid = GetHumanoid()
        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
        end
        
        Rayfield:Notify({
            Title = "Экстренное отключение",
            Content = "Все функции были отключены!",
            Duration = 4,
            Image = "rbxassetid://4483345998"
        })
    end,
})

-- Горячие клавиши
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F9 then
        -- Скрыть/показать интерфейс
        Rayfield:Toggle()
    elseif input.KeyCode == Enum.KeyCode.F10 then
        EmergencyButton.Callback()
    end
end)

-- Информационная панель
InfoSection:CreateLabel("Управление:")
InfoSection:CreateLabel("K - Показать/скрыть меню")
InfoSection:CreateLabel("F10 - Экстренное отключение")

InfoSection:CreateParagraph({
    Title = "⚠️ ВНИМАНИЕ",
    Content = "Использование читов нарушает правила Roblox и может привести к блокировке аккаунта. Автор не несет ответственности за последствия использования данного ПО."
})

-- Уведомление о загрузке
Rayfield:Notify({
    Title = "NV Cheat Menu v3.0",
    Content = "Меню успешно загружено! Нажмите F9 для открытия.",
    Duration = 6,
    Image = "rbxassetid://4483345998"
})

print("========================================")
print("NV Cheat Menu v3.0 (Rayfield UI Edition)")
print("Успешно инициализирован!")
print("Управление: F9 - меню, F10 - экстренное отключение")
print("========================================")
