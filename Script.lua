--[[
  NV Cheat Menu - Enhanced Edition
  Версия: 5.0
  С кнопкой быстрого доступа
]]

-- ========== СОЗДАНИЕ КНОПКИ TOGGLE UI ==========
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local TextButton = Instance.new("TextButton")
local UITextSizeConstraint = Instance.new("UITextSizeConstraint")

-- Настройка GUI
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Name = "NV_QuickAccess"

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
Frame.BackgroundTransparency = 0.500
Frame.Position = UDim2.new(0.858712733, 0, 0.0237762257, 0)
Frame.Size = UDim2.new(0.129513338, 0, 0.227972031, 0)
Frame.Active = true
Frame.Draggable = true

TextButton.Parent = Frame
TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextButton.BackgroundTransparency = 1.000
TextButton.Size = UDim2.new(1, 0, 1, 0)
TextButton.Font = Enum.Font.SourceSansBold
TextButton.Text = "NV\nMENU"
TextButton.TextColor3 = Color3.fromRGB(255, 50, 50)
TextButton.TextScaled = true
TextButton.TextSize = 50.000
TextButton.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
TextButton.TextStrokeTransparency = 0.000
TextButton.TextWrapped = true

UITextSizeConstraint.Parent = TextButton
UITextSizeConstraint.MaxTextSize = 30

-- ========== ЗАГРУЗКА RAYFIELD UI ==========
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ========== СОЗДАНИЕ ГЛАВНОГО ОКНА ==========
local Window = Rayfield:CreateWindow({
   Name = "🎮 NV Cheat Menu v5.0",
   LoadingTitle = "Rayfield Interface Suite",
   LoadingSubtitle = "by NV | Enhanced Edition",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "NV_Cheat_Config",
      FileName = "NV_Settings"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = true,
   KeySettings = {
      Title = "NV Cheat Menu - Доступ",
      Subtitle = "Система защиты",
      Note = "Ключ по умолчанию: NV2024",
      FileName = "NV_AccessKey",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"NV2024", "NVAccess123", "CheatMenu2024"}
   }
})

-- ========== УВЕДОМЛЕНИЕ О ЗАГРУЗКЕ ==========
Rayfield:Notify({
   Title = "NV Cheat Menu v5.0",
   Content = "Добро пожаловать! Используйте плавающую кнопку для быстрого доступа.",
   Duration = 6.5,
   Image = 4483362458,
   Actions = {
      Accept = {
         Name = "Понятно!",
         Callback = function()
            print("Пользователь принял уведомление")
         end
      },
   },
})

-- ========== ОСНОВНЫЕ СЕРВИСЫ ==========
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

-- ========== ЛОКАЛЬНЫЕ ПЕРЕМЕННЫЕ ==========
local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ========== СОЗДАНИЕ ВКЛАДОК ==========
local MainTab = Window:CreateTab("Главная", 4483362458)
local CombatTab = Window:CreateTab("Бой", 4483362458)
local VisualTab = Window:CreateTab("Визуал", 4483362458)
local PlayerTab = Window:CreateTab("Игрок", 4483362458)
local SettingsTab = Window:CreateTab("Настройки", 4483362458)

-- ========== РАЗДЕЛЫ ==========
local WelcomeSection = MainTab:CreateSection("Добро пожаловать")
local QuickSection = MainTab:CreateSection("Быстрые функции")

local AimSection = CombatTab:CreateSection("Аимбот")
local AutoSection = CombatTab:CreateSection("Автоматика")

local ESPSection = VisualTab:CreateSection("ESP")
local EffectsSection = VisualTab:CreateSection("Эффекты")

local StatsSection = PlayerTab:CreateSection("Характеристики")
local MovementSection = PlayerTab:CreateSection("Движение")

local ConfigSection = SettingsTab:CreateSection("Конфигурация")
local InfoSection = SettingsTab:CreateSection("Информация")

-- ========== ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ ==========
local CheatStates = {}
local Connections = {}
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "NV_ESP"
ESPFolder.Parent = workspace

-- ========== УТИЛИТАРНЫЕ ФУНКЦИИ ==========
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

-- ========== ФУНКЦИЯ ПЕРЕКЛЮЧЕНИЯ ИНТЕРФЕЙСА ==========
local function ToggleRayfieldUI()
    Rayfield:Toggle()
    
    -- Анимация кнопки при нажатии
    TextButton.TextColor3 = Color3.fromRGB(50, 255, 50)
    task.wait(0.1)
    TextButton.TextColor3 = Color3.fromRGB(255, 50, 50)
end

-- Назначаем функцию на кнопку
TextButton.MouseButton1Down:Connect(ToggleRayfieldUI)

-- ========== ПРИВЕТСТВЕННОЕ СООБЩЕНИЕ ==========
WelcomeSection:CreateParagraph({
    Title = "👾 NV Cheat Menu v5.0",
    Content = "Улучшенный скрипт с плавающей кнопкой быстрого доступа!\nНажмите на кнопку 'NV MENU' для открытия/закрытия интерфейса."
})

-- ========== 1. БЫСТРЫЕ ФУНКЦИИ ==========
local QuickAimToggle = QuickSection:CreateToggle({
   Name = "Быстрый Аимбот",
   CurrentValue = false,
   Flag = "QuickAim",
   Callback = function(Value)
        CheatStates.QuickAim = Value
        
        if Value then
            Connections.QuickAim = RunService.RenderStepped:Connect(function()
                local target = FindNearestPlayer(500, true)
                if target and target.Character then
                    local head = target.Character:FindFirstChild("Head")
                    if head and Camera then
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
                    end
                end
            end)
        else
            if Connections.QuickAim then
                Connections.QuickAim:Disconnect()
            end
        end
   end,
})

local QuickBunnyToggle = QuickSection:CreateToggle({
   Name = "Банни-Хоп",
   CurrentValue = false,
   Flag = "QuickBunny",
   Callback = function(Value)
        CheatStates.QuickBunny = Value
        
        if Value then
            Connections.QuickBunny = RunService.Heartbeat:Connect(function()
                local humanoid = GetHumanoid()
                if humanoid then
                    humanoid.Jump = true
                end
            end)
        else
            if Connections.QuickBunny then
                Connections.QuickBunny:Disconnect()
            end
        end
   end,
})

-- ========== 2. РАСШИРЕННЫЙ АИМБОТ ==========
local AimBotToggle = AimSection:CreateToggle({
   Name = "Аимбот",
   CurrentValue = false,
   Flag = "AimBot",
   Callback = function(Value)
        CheatStates.AimBot = Value
        
        if Value then
            Connections.AimBot = RunService.RenderStepped:Connect(function()
                local target, distance = FindNearestPlayer(AimRangeSlider.CurrentValue, IgnoreTeamToggle.CurrentValue)
                
                if target and target.Character then
                    local part = target.Character:FindFirstChild(AimPartDropdown.CurrentOption[1])
                    if part and Camera then
                        -- Предсказание движения
                        local prediction = 0
                        if PredictionToggle.CurrentValue then
                            prediction = (distance / 1000) * (part.Velocity.Magnitude / 50)
                        end
                        
                        local targetPos = part.Position + part.Velocity * prediction
                        
                        -- Плавный аим
                        if SmoothAimToggle.CurrentValue then
                            local smooth = AimSmoothSlider.CurrentValue / 100
                            Camera.CFrame = Camera.CFrame:Lerp(
                                CFrame.new(Camera.CFrame.Position, targetPos),
                                1 - smooth
                            )
                        else
                            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
                        end
                    end
                end
            end)
        else
            if Connections.AimBot then
                Connections.AimBot:Disconnect()
            end
        end
   end,
})

-- Настройки аимбота
local AimRangeSlider = AimSection:CreateSlider({
   Name = "Дальность аимбота",
   Range = {50, 1000},
   Increment = 50,
   Suffix = "studs",
   CurrentValue = 600,
   Flag = "AimRange",
   Callback = function(Value) end,
})

local AimPartDropdown = AimSection:CreateDropdown({
   Name = "Часть тела",
   Options = {"Head", "HumanoidRootPart", "UpperTorso"},
   CurrentOption = {"Head"},
   MultipleOptions = false,
   Flag = "AimPart",
   Callback = function(Option) end,
})

local SmoothAimToggle = AimSection:CreateToggle({
   Name = "Плавный аим",
   CurrentValue = true,
   Flag = "SmoothAim",
   Callback = function(Value) end,
})

local AimSmoothSlider = AimSection:CreateSlider({
   Name = "Сглаживание",
   Range = {1, 100},
   Increment = 5,
   Suffix = "%",
   CurrentValue = 30,
   Flag = "AimSmooth",
   Callback = function(Value) end,
})

local PredictionToggle = AimSection:CreateToggle({
   Name = "Предсказание",
   CurrentValue = true,
   Flag = "Prediction",
   Callback = function(Value) end,
})

local IgnoreTeamToggle = AimSection:CreateToggle({
   Name = "Игнорировать команду",
   CurrentValue = true,
   Flag = "IgnoreTeam",
   Callback = function(Value) end,
})

-- ========== 3. АВТОСТРЕЛЬБА ==========
local AutoShootToggle = AutoSection:CreateToggle({
   Name = "Автострельба",
   CurrentValue = false,
   Flag = "AutoShoot",
   Callback = function(Value)
        CheatStates.AutoShoot = Value
        
        if Value then
            Connections.AutoShoot = RunService.RenderStepped:Connect(function()
                local target = FindNearestPlayer(150, true)
                if target and target.Character then
                    local character = GetCharacter()
                    if character then
                        for _, tool in pairs(character:GetChildren()) do
                            if tool:IsA("Tool") then
                                tool:Activate()
                                break
                            end
                        end
                    end
                end
            end)
        else
            if Connections.AutoShoot then
                Connections.AutoShoot:Disconnect()
            end
        end
   end,
})

-- ========== 4. КРУТИЛКА ==========
local SpinToggle = AutoSection:CreateToggle({
   Name = "Крутилка",
   CurrentValue = false,
   Flag = "SpinBot",
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
            end
        end
   end,
})

local SpinSpeedSlider = AutoSection:CreateSlider({
   Name = "Скорость вращения",
   Range = {5, 50},
   Increment = 1,
   Suffix = "град/кадр",
   CurrentValue = 15,
   Flag = "SpinSpeed",
   Callback = function(Value) end,
})

-- ========== 5. ESP СИСТЕМА ==========
local ESPToggle = ESPSection:CreateToggle({
   Name = "ESP",
   CurrentValue = false,
   Flag = "ESPEnabled",
   Callback = function(Value)
        CheatStates.ESP = Value
        
        if Value then
            local function CreateESP(player)
                if player == Player then return end
                
                local character = player.Character
                if not character then return end
                
                -- Highlight
                local highlight = Instance.new("Highlight")
                highlight.Name = player.Name .. "_ESP"
                highlight.Adornee = character
                highlight.FillColor = ESPColorPicker.CurrentColor
                highlight.FillTransparency = 0.6
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.OutlineTransparency = 0
                highlight.Parent = ESPFolder
            end
            
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character then
                    CreateESP(player)
                end
                
                player.CharacterAdded:Connect(function()
                    task.wait(0.5)
                    CreateESP(player)
                end)
            end
        else
            for _, child in pairs(ESPFolder:GetChildren()) do
                child:Destroy()
            end
        end
   end,
})

local ESPColorPicker = ESPSection:CreateColorPicker({
    Name = "Цвет ESP",
    Color = Color3.fromRGB(255, 50, 50),
    Flag = "ESPColor",
    Callback = function(Value)
        for _, child in pairs(ESPFolder:GetChildren()) do
            if child:IsA("Highlight") then
                child.FillColor = Value
            end
        end
    end
})

-- ========== 6. ХАРАКТЕРИСТИКИ ИГРОКА ==========
local SpeedToggle = StatsSection:CreateToggle({
   Name = "Изменить скорость",
   CurrentValue = false,
   Flag = "SpeedMod",
   Callback = function(Value)
        if Value then
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid.WalkSpeed = SpeedSlider.CurrentValue
            end
            
            Connections.SpeedMod = Player.CharacterAdded:Connect(function()
                task.wait(0.5)
                local hum = GetHumanoid()
                if hum then
                    hum.WalkSpeed = SpeedSlider.CurrentValue
                end
            end)
        else
            if Connections.SpeedMod then
                Connections.SpeedMod:Disconnect()
            end
            
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid.WalkSpeed = 16
            end
        end
   end,
})

local SpeedSlider = StatsSection:CreateSlider({
   Name = "Скорость",
   Range = {16, 200},
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
   Name = "Изменить прыжок",
   CurrentValue = false,
   Flag = "JumpMod",
   Callback = function(Value)
        if Value then
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid.JumpPower = JumpSlider.CurrentValue
            end
            
            Connections.JumpMod = Player.CharacterAdded:Connect(function()
                task.wait(0.5)
                local hum = GetHumanoid()
                if hum then
                    hum.JumpPower = JumpSlider.CurrentValue
                end
            end)
        else
            if Connections.JumpMod then
                Connections.JumpMod:Disconnect()
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
   Range = {50, 500},
   Increment = 10,
   Suffix = "",
   CurrentValue = 100,
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
        end
        CheatStates.NightVision = Value
   end,
})

-- ========== 8. ЭКСТРЕННОЕ ОТКЛЮЧЕНИЕ ==========
local EmergencyButton = ConfigSection:CreateButton({
   Name = "⛔ ЭКСТРЕННОЕ ОТКЛЮЧЕНИЕ",
   Callback = function()
        -- Отключаем все функции
        QuickAimToggle:Set(false)
        QuickBunnyToggle:Set(false)
        AimBotToggle:Set(false)
        AutoShootToggle:Set(false)
        SpinToggle:Set(false)
        ESPToggle:Set(false)
        SpeedToggle:Set(false)
        JumpToggle:Set(false)
        NightVisionToggle:Set(false)
        
        -- Сбрасываем настройки
        local humanoid = GetHumanoid()
        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
        end
        
        Lighting.Ambient = Color3.fromRGB(0, 0, 0)
        Lighting.Brightness = 1
        
        Rayfield:Notify({
            Title = "Экстренное отключение",
            Content = "Все функции отключены!",
            Duration = 4,
            Image = 4483362458
        })
   end,
})

-- ========== 9. НАСТРОЙКА КЛАВИШ ==========
local ToggleKeybind = ConfigSection:CreateKeybind({
   Name = "Клавиша для интерфейса",
   CurrentKeybind = "RightControl",
   HoldToInteract = false,
   Flag = "ToggleKey",
   Callback = function(Keybind)
        ToggleRayfieldUI()
   end,
})

local EmergencyKeybind = ConfigSection:CreateKeybind({
   Name = "Клавиша отключения",
   CurrentKeybind = "F10",
   HoldToInteract = false,
   Flag = "EmergencyKey",
   Callback = function(Keybind)
        EmergencyButton.Callback()
   end,
})

-- ========== 10. ДОПОЛНИТЕЛЬНЫЕ НАСТРОЙКИ ==========
local ButtonColorPicker = ConfigSection:CreateColorPicker({
    Name = "Цвет кнопки",
    Color = Color3.fromRGB(255, 50, 50),
    Flag = "ButtonColor",
    Callback = function(Value)
        TextButton.TextColor3 = Value
    end
})

local ButtonTextInput = ConfigSection:CreateInput({
   Name = "Текст кнопки",
   PlaceholderText = "Введите текст кнопки",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        if Text ~= "" then
            TextButton.Text = Text
        end
   end,
})

-- ========== 11. ИНФОРМАЦИОННАЯ СЕКЦИЯ ==========
InfoSection:CreateLabel("📱 Быстрый доступ")
InfoSection:CreateParagraph({
    Title = "Плавающая кнопка",
    Content = "Используйте плавающую кнопку 'NV MENU' для быстрого открытия/закрытия меню.\nКнопку можно перемещать по экрану."
})

InfoSection:CreateLabel("🎮 Управление")
InfoSection:CreateParagraph({
    Title = "Горячие клавиши",
    Content = "RightControl - Открыть/закрыть меню\nF10 - Экстренное отключение\nКлик по кнопке - Быстрый доступ"
})

InfoSection:CreateParagraph({
    Title = "⚠️ ВНИМАНИЕ",
    Content = "Используйте на свой страх и риск!\nАвтор не несет ответственности за блокировку аккаунта."
})

-- ========== 12. КНОПКА СБРОСА ==========
local ResetButton = ConfigSection:CreateButton({
   Name = "🔄 Сбросить настройки",
   Callback = function()
        ButtonColorPicker:Set(Color3.fromRGB(255, 50, 50))
        ButtonTextInput.Callback("NV\nMENU")
        TextButton.Text = "NV\nMENU"
        
        Rayfield:Notify({
            Title = "Настройки сброшены",
            Content = "Все настройки восстановлены по умолчанию",
            Duration = 3,
        })
   end,
})

-- ========== ДОПОЛНИТЕЛЬНЫЕ ГОРЯЧИЕ КЛАВИШИ ==========
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F9 then
        -- Быстрое меню
        Rayfield:Notify({
            Title = "⚡ Быстрое меню",
            Content = "Выберите действие:",
            Duration = 8,
            Image = 4483362458,
            Actions = {
                ToggleQuickAim = {
                    Name = QuickAimToggle.CurrentValue and "Выкл. быстрый аим" or "Вкл. быстрый аим",
                    Callback = function()
                        QuickAimToggle:Set(not QuickAimToggle.CurrentValue)
                    end
                },
                ToggleESP = {
                    Name = ESPToggle.CurrentValue and "Выкл. ESP" or "Вкл. ESP",
                    Callback = function()
                        ESPToggle:Set(not ESPToggle.CurrentValue)
                    end
                },
                ToggleSpeed = {
                    Name = SpeedToggle.CurrentValue and "Норм. скорость" or "Увел. скорость",
                    Callback = function()
                        SpeedToggle:Set(not SpeedToggle.CurrentValue)
                    end
                },
            },
        })
    end
end)

-- ========== ФИНАЛЬНОЕ УВЕДОМЛЕНИЕ ==========
task.wait(2)
Rayfield:Notify({
    Title = "Готово!",
    Content = "NV Cheat Menu v5.0 успешно загружен!\nИспользуйте плавающую кнопку или RightControl для открытия меню.",
    Duration = 5,
    Image = 4483362458,
})

print("========================================")
print("NV Cheat Menu v5.0 - Enhanced Edition")
print("Плавающая кнопка активирована")
print("Ключ доступа: NV2024")
print("========================================")

-- ========== ФУНКЦИЯ ДЛЯ ОБНОВЛЕНИЯ ЦВЕТА КНОПКИ ==========
local function UpdateButtonColor()
    -- Меняем цвет кнопки в зависимости от состояния
    local anyActive = false
    for _, state in pairs(CheatStates) do
        if state then
            anyActive = true
            break
        end
    end
    
    if anyActive then
        TextButton.TextColor3 = Color3.fromRGB(50, 255, 50)  -- Зеленый если что-то активно
    else
        TextButton.TextColor3 = ButtonColorPicker.CurrentColor  -- Обычный цвет
    end
end

-- Следим за изменениями состояний
RunService.Heartbeat:Connect(UpdateButtonColor)
