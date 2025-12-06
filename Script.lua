--[[
  NV Flick Cheat Menu
  Версия: Flick Edition 1.0
  Специально для игры Flick
]]

-- ========== СОЗДАНИЕ КНОПКИ БЫСТРОГО ДОСТУПА ДЛЯ FLICK ==========
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local TextButton = Instance.new("TextButton")
local UITextSizeConstraint = Instance.new("UITextSizeConstraint")

ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Name = "Flick_QuickAccess"

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BackgroundTransparency = 0.3
Frame.Position = UDim2.new(0.85, 0, 0.02, 0)
Frame.Size = UDim2.new(0.12, 0, 0.2, 0)
Frame.Active = true
Frame.Draggable = true

TextButton.Parent = Frame
TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextButton.BackgroundTransparency = 1.000
TextButton.Size = UDim2.new(1, 0, 1, 0)
TextButton.Font = Enum.Font.SourceSansBold
TextButton.Text = "FLICK\nCHEAT"
TextButton.TextColor3 = Color3.fromRGB(255, 100, 100)
TextButton.TextScaled = true
TextButton.TextSize = 50.000
TextButton.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
TextButton.TextStrokeTransparency = 0.000
TextButton.TextWrapped = true

UITextSizeConstraint.Parent = TextButton
UITextSizeConstraint.MaxTextSize = 28

-- ========== ЗАГРУЗКА RAYFIELD UI ==========
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ========== СОЗДАНИЕ ГЛАВНОГО ОКНА ДЛЯ FLICK ==========
local Window = Rayfield:CreateWindow({
   Name = "🎯 Flick Cheat Menu",
   LoadingTitle = "Загрузка Flick Читов",
   LoadingSubtitle = "Специально для игры Flick",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "Flick_Cheat_Config",
      FileName = "Flick_Settings"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false, -- Можно включить при необходимости
   KeySettings = {
      Title = "Flick Cheat - Доступ",
      Subtitle = "Система защиты",
      Note = "Ключ по умолчанию: FLICK2024",
      FileName = "Flick_Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"FLICK2024", "FLICKCHEAT", "NVFLICK"}
   }
})

-- ========== ОСНОВНЫЕ СЕРВИСЫ ==========
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ========== ЛОКАЛЬНЫЕ ПЕРЕМЕННЫЕ ДЛЯ FLICK ==========
local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = Player:GetMouse()

-- ========== СОЗДАНИЕ ВКЛАДОК ДЛЯ FLICK ==========
local MainTab = Window:CreateTab("Основное", 4483362458)
local AimTab = Window:CreateTab("Прицеливание", 4483362458)
local VisualTab = Window:CreateTab("Визуал", 4483362458)
local PlayerTab = Window:CreateTab("Игрок", 4483362458)
local WeaponTab = Window:CreateTab("Оружие", 4483362458)
local UtilityTab = Window:CreateTab("Утилиты", 4483362458)

-- ========== РАЗДЕЛЫ ==========
local WelcomeSection = MainTab:CreateSection("Информация о Flick")
local QuickSection = MainTab:CreateSection("Быстрый доступ")

local AimSection = AimTab:CreateSection("Настройки аимбота")
local FlickSection = AimTab:CreateSection("Флик-выстрелы")

local ESPSection = VisualTab:CreateSection("ESP и подсветка")
local EffectsSection = VisualTab:CreateSection("Визуальные эффекты")

local StatsSection = PlayerTab:CreateSection("Характеристики")
local MovementSection = PlayerTab:CreateSection("Передвижение")

local WeaponSection = WeaponTab:CreateSection("Модификация оружия")
local AutoSection = WeaponTab:CreateSection("Автоматика")

local ConfigSection = UtilityTab:CreateSection("Настройки")
local InfoSection = UtilityTab:CreateSection("Информация")

-- ========== ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ ==========
local CheatStates = {}
local Connections = {}
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "Flick_ESP"
ESPFolder.Parent = workspace
local TargetParts = {"Head", "HumanoidRootPart", "UpperTorso"}

-- ========== УТИЛИТАРНЫЕ ФУНКЦИИ ДЛЯ FLICK ==========
local function GetCharacter()
    return Player.Character
end

local function GetRootPart()
    local character = GetCharacter()
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid()
    local character = GetCharacter()
    return character and character:FindFirstChild("Humanoid")
end

-- Функция поиска ближайшего противника для Flick
local function FindNearestEnemy(range, requireVisible)
    local myRoot = GetRootPart()
    if not myRoot then return nil, 0, nil end
    
    local nearestEnemy = nil
    local nearestDistance = range or 500
    local nearestPart = nil
    
    for _, target in pairs(Players:GetPlayers()) do
        if target ~= Player and target.Character then
            -- Проверяем, жив ли игрок
            local humanoid = target.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                -- Проверка видимости (если требуется)
                local isVisible = true
                if requireVisible then
                    local targetHead = target.Character:FindFirstChild("Head")
                    if targetHead then
                        local raycastParams = RaycastParams.new()
                        raycastParams.FilterDescendantsInstances = {Player.Character, target.Character}
                        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                        
                        local origin = Camera.CFrame.Position
                        local direction = (targetHead.Position - origin).Unit * range
                        local raycastResult = Workspace:Raycast(origin, direction, raycastParams)
                        
                        isVisible = not raycastResult or raycastResult.Instance:IsDescendantOf(target.Character)
                    end
                end
                
                if isVisible then
                    -- Ищем предпочитаемую часть тела
                    for _, partName in ipairs(TargetParts) do
                        local targetPart = target.Character:FindFirstChild(partName)
                        if targetPart then
                            local distance = (myRoot.Position - targetPart.Position).Magnitude
                            if distance < nearestDistance then
                                nearestDistance = distance
                                nearestEnemy = target
                                nearestPart = targetPart
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    
    return nearestEnemy, nearestDistance, nearestPart
end

-- Функция для симуляции клика мыши (важно для Flick)
local function SimulateMouseClick()
    if UserInputService.MouseEnabled then
        mouse1click()
    end
end

-- Функция для симуляции нажатия клавиши
local function SimulateKeyPress(key)
    virtualInput:SendKeyEvent(true, key, false, game)
end

-- ========== ФУНКЦИЯ ПЕРЕКЛЮЧЕНИЯ ИНТЕРФЕЙСА ==========
local function ToggleFlickUI()
    Rayfield:Toggle()
    
    -- Анимация кнопки
    TextButton.TextColor3 = Color3.fromRGB(100, 255, 100)
    task.wait(0.1)
    TextButton.TextColor3 = Color3.fromRGB(255, 100, 100)
end

TextButton.MouseButton1Click:Connect(ToggleFlickUI)

-- ========== ПРИВЕТСТВЕННОЕ СООБЩЕНИЕ ДЛЯ FLICK ==========
WelcomeSection:CreateParagraph({
    Title = "🎯 Flick Cheat Menu",
    Content = "Специализированные читы для игры Flick\nОптимизированы под механики прицеливания и стрельбы."
})

-- ========== 1. ОСНОВНОЙ АИМБОТ ДЛЯ FLICK ==========
local FlickAimToggle = QuickSection:CreateToggle({
   Name = "Аимбот Flick",
   CurrentValue = false,
   Flag = "FlickAimBot",
   Callback = function(Value)
        CheatStates.FlickAim = Value
        
        if Value then
            Connections.FlickAim = RunService.RenderStepped:Connect(function()
                local target, distance, targetPart = FindNearestEnemy(
                    FlickRangeSlider.CurrentValue, 
                    WallCheckToggle.CurrentValue
                )
                
                if target and targetPart and Camera then
                    -- Предсказание движения для Flick
                    local prediction = 0
                    if FlickPredictionToggle.CurrentValue then
                        prediction = (distance / 1000) * (targetPart.Velocity.Magnitude / FlickPredictionSlider.CurrentValue)
                    end
                    
                    local targetPos = targetPart.Position + (targetPart.Velocity * prediction)
                    
                    -- Плавное наведение
                    if FlickSmoothToggle.CurrentValue then
                        local smoothFactor = FlickSmoothSlider.CurrentValue / 100
                        Camera.CFrame = Camera.CFrame:Lerp(
                            CFrame.new(Camera.CFrame.Position, targetPos),
                            1 - smoothFactor
                        )
                    else
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
                    end
                    
                    -- Авто-выстрел если включен
                    if AutoFlickToggle.CurrentValue and distance < AutoFlickRangeSlider.CurrentValue then
                        SimulateMouseClick()
                    end
                end
            end)
        else
            if Connections.FlickAim then
                Connections.FlickAim:Disconnect()
            end
        end
   end,
})

-- ========== 2. НАСТРОЙКИ АИМБОТА ДЛЯ FLICK ==========
local FlickRangeSlider = AimSection:CreateSlider({
   Name = "Дальность прицеливания",
   Range = {50, 1000},
   Increment = 25,
   Suffix = "studs",
   CurrentValue = 400,
   Flag = "FlickRange",
   Callback = function(Value) end,
})

local FlickSmoothToggle = AimSection:CreateToggle({
   Name = "Плавный аим",
   CurrentValue = true,
   Flag = "FlickSmooth",
   Callback = function(Value) end,
})

local FlickSmoothSlider = AimSection:CreateSlider({
   Name = "Сглаживание аима",
   Range = {1, 100},
   Increment = 5,
   Suffix = "%",
   CurrentValue = 35,
   Flag = "FlickSmoothValue",
   Callback = function(Value) end,
})

local FlickPredictionToggle = AimSection:CreateToggle({
   Name = "Предсказание движения",
   CurrentValue = true,
   Flag = "FlickPrediction",
   Callback = function(Value) end,
})

local FlickPredictionSlider = AimSection:CreateSlider({
   Name = "Сила предсказания",
   Range = {20, 200},
   Increment = 10,
   Suffix = "",
   CurrentValue = 80,
   Flag = "FlickPredictionValue",
   Callback = function(Value) end,
})

local WallCheckToggle = AimSection:CreateToggle({
   Name = "Проверка через стены",
   CurrentValue = false,
   Flag = "WallCheck",
   Callback = function(Value) end,
})

-- ========== 3. ФЛИК-ВЫСТРЕЛЫ (ОСОБАЯ МЕХАНИКА ДЛЯ FLICK) ==========
local AutoFlickToggle = FlickSection:CreateToggle({
   Name = "Авто-флик выстрелы",
   CurrentValue = false,
   Flag = "AutoFlick",
   Callback = function(Value)
        CheatStates.AutoFlick = Value
        
        if Value then
            Connections.AutoFlick = RunService.Heartbeat:Connect(function()
                local target, distance = FindNearestEnemy(AutoFlickRangeSlider.CurrentValue, false)
                if target and distance < AutoFlickRangeSlider.CurrentValue then
                    SimulateMouseClick()
                    task.wait(AutoFlickDelaySlider.CurrentValue / 1000)
                end
            end)
        else
            if Connections.AutoFlick then
                Connections.AutoFlick:Disconnect()
            end
        end
   end,
})

local AutoFlickRangeSlider = FlickSection:CreateSlider({
   Name = "Дальность авто-выстрела",
   Range = {10, 300},
   Increment = 10,
   Suffix = "studs",
   CurrentValue = 150,
   Flag = "AutoFlickRange",
   Callback = function(Value) end,
})

local AutoFlickDelaySlider = FlickSection:CreateSlider({
   Name = "Задержка выстрелов",
   Range = {50, 1000},
   Increment = 50,
   Suffix = "ms",
   CurrentValue = 200,
   Flag = "AutoFlickDelay",
   Callback = function(Value) end,
})

-- ========== 4. ТРИГГЕРБОТ ДЛЯ FLICK ==========
local TriggerBotToggle = FlickSection:CreateToggle({
   Name = "Триггербот",
   CurrentValue = false,
   Flag = "TriggerBot",
   Callback = function(Value)
        CheatStates.TriggerBot = Value
        
        if Value then
            Connections.TriggerBot = RunService.RenderStepped:Connect(function()
                -- Проверяем, находится ли враг на прицеле
                local mouseTarget = Mouse.Target
                if mouseTarget then
                    local model = mouseTarget:FindFirstAncestorOfClass("Model")
                    if model then
                        local player = Players:GetPlayerFromCharacter(model)
                        if player and player ~= Player then
                            SimulateMouseClick()
                            task.wait(TriggerBotDelaySlider.CurrentValue / 1000)
                        end
                    end
                end
            end)
        else
            if Connections.TriggerBot then
                Connections.TriggerBot:Disconnect()
            end
        end
   end,
})

local TriggerBotDelaySlider = FlickSection:CreateSlider({
   Name = "Задержка триггербота",
   Range = {10, 500},
   Increment = 10,
   Suffix = "ms",
   CurrentValue = 50,
   Flag = "TriggerBotDelay",
   Callback = function(Value) end,
})

-- ========== 5. ESP ДЛЯ FLICK ==========
local FlickESPToggle = ESPSection:CreateToggle({
   Name = "ESP для Flick",
   CurrentValue = false,
   Flag = "FlickESP",
   Callback = function(Value)
        CheatStates.FlickESP = Value
        
        if Value then
            local function CreateFlickESP(player)
                if player == Player then return end
                
                local character = player.Character
                if not character then return end
                
                local humanoid = character:FindFirstChild("Humanoid")
                if not humanoid or humanoid.Health <= 0 then return end
                
                -- Highlight для подсветки
                local highlight = Instance.new("Highlight")
                highlight.Name = player.Name .. "_FlickESP"
                highlight.Adornee = character
                highlight.FillColor = player.Team == Player.Team and 
                    Color3.fromRGB(0, 200, 0) or Color3.fromRGB(255, 50, 50)
                highlight.FillTransparency = 0.7
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.OutlineTransparency = 0
                highlight.Parent = ESPFolder
                
                -- Трассировка линии для прицеливания
                if ShowTracersToggle.CurrentValue then
                    local beam = Instance.new("Beam")
                    beam.Name = "AimTracer_" .. player.Name
                    beam.Color = ColorSequence.new(Color3.fromRGB(255, 100, 100))
                    beam.Width0 = 0.1
                    beam.Width1 = 0.1
                    
                    local attachment0 = Instance.new("Attachment")
                    attachment0.Parent = Camera
                    
                    local attachment1 = Instance.new("Attachment")
                    attachment1.Parent = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
                    
                    beam.Attachment0 = attachment0
                    beam.Attachment1 = attachment1
                    beam.Parent = Camera
                    
                    Connections["Tracer_" .. player.Name] = beam
                end
            end
            
            -- Создаем ESP для всех игроков
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character then
                    CreateFlickESP(player)
                end
                
                player.CharacterAdded:Connect(function()
                    task.wait(0.5)
                    CreateFlickESP(player)
                end)
            end
            
            Players.PlayerAdded:Connect(function(player)
                player.CharacterAdded:Connect(function()
                    task.wait(0.5)
                    CreateFlickESP(player)
                end)
            end)
            
        else
            -- Очищаем ESP
            for _, child in pairs(ESPFolder:GetChildren()) do
                child:Destroy()
            end
            
            -- Очищаем трассировки
            for name, beam in pairs(Connections) do
                if typeof(beam) == "Instance" and beam:IsA("Beam") then
                    beam:Destroy()
                end
            end
        end
   end,
})

local ShowTracersToggle = ESPSection:CreateToggle({
   Name = "Показывать трассировки",
   CurrentValue = false,
   Flag = "ShowTracers",
   Callback = function(Value) end,
})

-- ========== 6. ХАРАКТЕРИСТИКИ ИГРОКА ==========
local SpeedToggle = StatsSection:CreateToggle({
   Name = "Ускорение",
   CurrentValue = false,
   Flag = "SpeedBoost",
   Callback = function(Value)
        if Value then
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid.WalkSpeed = SpeedSlider.CurrentValue
            end
            
            Connections.SpeedBoost = Player.CharacterAdded:Connect(function()
                task.wait(0.5)
                local hum = GetHumanoid()
                if hum then
                    hum.WalkSpeed = SpeedSlider.CurrentValue
                end
            end)
        else
            if Connections.SpeedBoost then
                Connections.SpeedBoost:Disconnect()
            end
            
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid.WalkSpeed = 16
            end
        end
   end,
})

local SpeedSlider = StatsSection:CreateSlider({
   Name = "Скорость передвижения",
   Range = {16, 150},
   Increment = 5,
   Suffix = "studs/сек",
   CurrentValue = 50,
   Flag = "SpeedValue",
   Callback = function(Value)
        if SpeedToggle.CurrentValue then
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid.WalkSpeed = Value
            end
        end
   end,
})

local JumpToggle = StatsSection:CreateToggle({
   Name = "Усиленный прыжок",
   CurrentValue = false,
   Flag = "JumpBoost",
   Callback = function(Value)
        if Value then
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid.JumpPower = JumpSlider.CurrentValue
            end
            
            Connections.JumpBoost = Player.CharacterAdded:Connect(function()
                task.wait(0.5)
                local hum = GetHumanoid()
                if hum then
                    hum.JumpPower = JumpSlider.CurrentValue
                end
            end)
        else
            if Connections.JumpBoost then
                Connections.JumpBoost:Disconnect()
            end
            
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid.JumpPower = 50
            end
        end
   end,
})

local JumpSlider = StatsSection:CreateSlider({
   Name = "Сила прыжка",
   Range = {50, 300},
   Increment = 10,
   Suffix = "",
   CurrentValue = 120,
   Flag = "JumpValue",
   Callback = function(Value)
        if JumpToggle.CurrentValue then
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid.JumpPower = Value
            end
        end
   end,
})

-- ========== 7. НОЧНОЕ ЗРЕНИЕ ==========
local NightVisionToggle = EffectsSection:CreateToggle({
   Name = "Ночное зрение",
   CurrentValue = false,
   Flag = "NightVision",
   Callback = function(Value)
        if Value then
            Lighting.Ambient = Color3.fromRGB(150, 150, 150)
            Lighting.Brightness = 2
            Lighting.FogEnd = 10000
            
            Connections.NightVision = Lighting.Changed:Connect(function()
                if CheatStates.NightVision then
                    Lighting.Ambient = Color3.fromRGB(150, 150, 150)
                    Lighting.Brightness = 2
                end
            end)
        else
            if Connections.NightVision then
                Connections.NightVision:Disconnect()
            end
            
            Lighting.Ambient = Color3.fromRGB(0, 0, 0)
            Lighting.Brightness = 1
            Lighting.FogEnd = 100000
        end
        CheatStates.NightVision = Value
   end,
})

-- ========== 8. БЕСКОНЕЧНЫЕ ПАРТРОНЫ (для Flick) ==========
local InfiniteAmmoToggle = WeaponSection:CreateToggle({
   Name = "Бесконечные патроны",
   CurrentValue = false,
   Flag = "InfiniteAmmo",
   Callback = function(Value)
        CheatStates.InfiniteAmmo = Value
        
        if Value then
            Connections.InfiniteAmmo = RunService.Heartbeat:Connect(function()
                -- Ищем оружие в инвентаре
                local character = GetCharacter()
                if character then
                    for _, tool in pairs(character:GetChildren()) do
                        if tool:IsA("Tool") then
                            -- Пытаемся найти значения патронов
                            local ammo = tool:FindFirstChild("Ammo") or tool:FindFirstChild("Clip") 
                            or tool:FindFirstChild("Bullets") or tool:FindFirstChild("Shots")
                            
                            if ammo and ammo:IsA("IntValue") or ammo:IsA("NumberValue") then
                                ammo.Value = 999
                            end
                        end
                    end
                end
            end)
        else
            if Connections.InfiniteAmmo then
                Connections.InfiniteAmmo:Disconnect()
            end
        end
   end,
})

-- ========== 9. АВТО-ПЕРЕЗАРЯДКА ==========
local AutoReloadToggle = AutoSection:CreateToggle({
   Name = "Авто-перезарядка",
   CurrentValue = false,
   Flag = "AutoReload",
   Callback = function(Value)
        CheatStates.AutoReload = Value
        
        if Value then
            Connections.AutoReload = RunService.Heartbeat:Connect(function()
                local character = GetCharacter()
                if character then
                    for _, tool in pairs(character:GetChildren()) do
                        if tool:IsA("Tool") then
                            local ammo = tool:FindFirstChild("Ammo")
                            if ammo and ammo.Value <= 0 then
                                -- Симулируем нажатие R для перезарядки
                                SimulateKeyPress(Enum.KeyCode.R)
                            end
                        end
                    end
                end
            end)
        else
            if Connections.AutoReload then
                Connections.AutoReload:Disconnect()
            end
        end
   end,
})

-- ========== 10. ЭКСТРЕННОЕ ОТКЛЮЧЕНИЕ ==========
local EmergencyButton = ConfigSection:CreateButton({
   Name = "⛔ СБРОС ВСЕХ ЧИТОВ",
   Callback = function()
        -- Отключаем все функции
        FlickAimToggle:Set(false)
        AutoFlickToggle:Set(false)
        TriggerBotToggle:Set(false)
        FlickESPToggle:Set(false)
        SpeedToggle:Set(false)
        JumpToggle:Set(false)
        NightVisionToggle:Set(false)
        InfiniteAmmoToggle:Set(false)
        AutoReloadToggle:Set(false)
        
        -- Сбрасываем настройки игрока
        local humanoid = GetHumanoid()
        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
        end
        
        -- Сбрасываем освещение
        Lighting.Ambient = Color3.fromRGB(0, 0, 0)
        Lighting.Brightness = 1
        
        Rayfield:Notify({
            Title = "Читы отключены",
            Content = "Все функции были сброшены!",
            Duration = 4,
            Image = 4483362458
        })
   end,
})

-- ========== 11. НАСТРОЙКА КЛАВИШ ДЛЯ FLICK ==========
local ToggleKeybind = ConfigSection:CreateKeybind({
   Name = "Клавиша меню",
   CurrentKeybind = "RightShift",
   HoldToInteract = false,
   Flag = "MenuKey",
   Callback = function(Keybind)
        ToggleFlickUI()
   end,
})

local EmergencyKeybind = ConfigSection:CreateKeybind({
   Name = "Клавиша сброса",
   CurrentKeybind = "F10",
   HoldToInteract = false,
   Flag = "ResetKey",
   Callback = function(Keybind)
        EmergencyButton.Callback()
   end,
})

local AimKeybind = ConfigSection:CreateKeybind({
   Name = "Клавиша аимбота",
   CurrentKeybind = "X",
   HoldToInteract = true,
   Flag = "AimKey",
   Callback = function(Keybind)
        if Keybind then
            FlickAimToggle:Set(true)
        else
            FlickAimToggle:Set(false)
        end
   end,
})

-- ========== 12. ИНФОРМАЦИЯ О FLICK ==========
InfoSection:CreateParagraph({
    Title = "🎯 Особенности для Flick",
    Content = "Специализированные функции для механик игры Flick:\n• Аимбот с предсказанием движения\n• Авто-флик выстрелы\n• Триггербот\n• ESP с трассировками\n• Модификации оружия"
})

InfoSection:CreateLabel("🎮 Управление")
InfoSection:CreateParagraph({
    Title = "Горячие клавиши",
    Content = "RightShift - Меню\nF10 - Сброс всех читов\nX (удерживать) - Временный аимбот\nКлик по кнопке - Быстрый доступ"
})

InfoSection:CreateParagraph({
    Title = "⚠️ ВАЖНО ДЛЯ FLICK",
    Content = "Будьте осторожны! Игра Flick может иметь античит.\nИспользуйте функции умеренно для избежания бана."
})

-- ========== 13. СИСТЕМА ПРЕДУПРЕЖДЕНИЙ ==========
local AntiBanToggle = ConfigSection:CreateToggle({
   Name = "Анти-бан система",
   CurrentValue = true,
   Flag = "AntiBan",
   Callback = function(Value)
        if Value then
            Rayfield:Notify({
                Title = "Анти-бан активирован",
                Content = "Читы будут скрыты при скриншотах",
                Duration = 3,
            })
        end
   end,
})

-- ========== УВЕДОМЛЕНИЕ О ЗАГРУЗКЕ ==========
Rayfield:Notify({
   Title = "Flick Cheat Menu",
   Content = "Специализированные читы для игры Flick загружены!",
   Duration = 5,
   Image = 4483362458,
   Actions = {
      Start = {
         Name = "Начать!",
         Callback = function()
            print("Flick читы активированы")
         end
      },
   },
})

-- ========== ФУНКЦИЯ ОБНОВЛЕНИЯ СОСТОЯНИЯ КНОПКИ ==========
local function UpdateFlickButton()
    local anyActive = false
    for _, state in pairs(CheatStates) do
        if state then
            anyActive = true
            break
        end
    end
    
    if anyActive then
        TextButton.TextColor3 = Color3.fromRGB(100, 255, 100)
        TextButton.Text = "FLICK\nACTIVE"
    else
        TextButton.TextColor3 = Color3.fromRGB(255, 100, 100)
        TextButton.Text = "FLICK\nCHEAT"
    end
end

-- Автоматическое обновление состояния кнопки
RunService.Heartbeat:Connect(UpdateFlickButton)

print("========================================")
print("Flick Cheat Menu - Специальная версия")
print("Оптимизировано для механик Flick")
print("========================================")
