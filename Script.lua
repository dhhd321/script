--[[
  NV Cheat Menu - Rayfield Edition
  Версия: 2.1
  Загрузка на свой страх и риск!
]]

-- Загрузка библиотеки Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Создание главного окна интерфейса [citation:1][citation:4]
local Window = Rayfield:CreateWindow({
    Name = "🔧 NV Cheat Menu",
    LoadingTitle = "Загрузка интерфейса...",
    LoadingSubtitle = "by NV",
    ConfigurationSaving = {
        Enabled = true, -- Позволяет сохранять настройки
        FolderName = "NV_Cheat_Config"
    },
    Discord = {
        Enabled = false, -- Можно включить и указать ссылку на Discord
        Invite = "noinvite",
        RememberJoins = true
    },
    KeySystem = false, -- Можно включить систему ключей при необходимости [citation:3]
    ToggleUIKeybind = Enum.KeyCode.RightControl, -- Клавиша для показа/скрытия меню
})

-- Уведомление о загрузке [citation:2]
Rayfield:Notify({
    Title = "Меню загружено",
    Content = "Нажмите RightControl, чтобы открыть/скрыть меню.",
    Duration = 5,
})

-- Основные сервисы Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Локальные переменные
local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Создание вкладок, как в вашем исходном меню [citation:2]
local MainTab = Window:CreateTab("Основные", 4483362458) -- Иконка: шестерёнка
local VisualTab = Window:CreateTab("Визуал", 4483362458)
local PlayerTab = Window:CreateTab("Игрок", 4483362458)

-- Разделы для организации [citation:2]
local CombatSection = MainTab:CreateSection("Боевые функции")
local MoveSection = MainTab:CreateSection("Передвижение")
local VisualSection = VisualTab:CreateSection("Эффекты")
local ModSection = PlayerTab:CreateSection("Модификации")

-- Глобальные переменные для состояний и соединений
local CheatStates = {}
local Connections = {}

-- ФУНКЦИИ-УТИЛИТЫ (из вашего старого скрипта)
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

local function FindNearestPlayer(range)
    local myRoot = GetRootPart()
    if not myRoot then return nil end
    
    local nearestPlayer = nil
    local nearestDistance = range or 500
    
    for _, target in pairs(Players:GetPlayers()) do
        if target ~= Player and target.Character then
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
    return nearestPlayer
end

-- 1. АИМБОТ (переделан на Toggle из Rayfield) [citation:4]
local AimBotToggle = CombatSection:CreateToggle({
    Name = "Включить Аимбот",
    CurrentValue = false,
    Flag = "AimBotToggle",
    Callback = function(Value)
        CheatStates.AimBot = Value
        if Value then
            Connections.AimBot = RunService.RenderStepped:Connect(function()
                local target = FindNearestPlayer(AimBotRangeSlider.CurrentValue)
                if target and target.Character then
                    local targetRoot = target.Character:FindFirstChild(AimBotPartDropdown.CurrentOption)
                    if targetRoot and Camera then
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetRoot.Position)
                    end
                end
            end)
            Rayfield:Notify({Title = "Аимбот", Content = "Функция включена.", Duration = 2})
        else
            if Connections.AimBot then Connections.AimBot:Disconnect() end
        end
    end,
})

-- Настройки аимбота: Слайдер для дистанции [citation:4]
local AimBotRangeSlider = CombatSection:CreateSlider({
    Name = "Дальность аимбота",
    Range = {50, 1000},
    Increment = 50,
    Suffix = "studs",
    CurrentValue = 500,
    Flag = "AimBotRange",
    Callback = function(Value) end,
})

-- Настройки аимбота: Выпадающий список для части тела [citation:4]
local AimBotPartDropdown = CombatSection:CreateDropdown({
    Name = "Целиться в",
    Options = {"HumanoidRootPart", "Head", "UpperTorso"},
    CurrentOption = "HumanoidRootPart",
    Flag = "AimBotPart",
    Callback = function(Option) end,
})

-- 2. БАННИ-ХОП
local BunnyHopToggle = MoveSection:CreateToggle({
    Name = "Включить Bunny Hop",
    CurrentValue = false,
    Flag = "BunnyHopToggle",
    Callback = function(Value)
        CheatStates.BunnyHop = Value
        if Value then
            Connections.BunnyHop = RunService.Heartbeat:Connect(function()
                local humanoid = GetHumanoid()
                if humanoid then humanoid.Jump = true end
            end)
        else
            if Connections.BunnyHop then Connections.BunnyHop:Disconnect() end
        end
    end,
})

-- 3. КРУТИЛКА (Спин) [citation:4]
local SpinToggle = MoveSection:CreateToggle({
    Name = "Включить Крутилку",
    CurrentValue = false,
    Flag = "SpinToggle",
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
            if Connections.Spin then Connections.Spin:Disconnect() end
        end
    end,
})

-- Слайдер для скорости кручения [citation:4]
local SpinSpeedSlider = MoveSection:CreateSlider({
    Name = "Скорость кручения",
    Range = {5, 50},
    Increment = 1,
    Suffix = "",
    CurrentValue = 12,
    Flag = "SpinSpeed",
    Callback = function(Value) end,
})

-- 4. АВТОСТРЕЛЬБА
local AutoShootToggle = CombatSection:CreateToggle({
    Name = "Включить Автострельбу",
    CurrentValue = false,
    Flag = "AutoShootToggle",
    Callback = function(Value)
        CheatStates.AutoShoot = Value
        if Value then
            Connections.AutoShoot = RunService.RenderStepped:Connect(function()
                local target = FindNearestPlayer(100)
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
            if Connections.AutoShoot then Connections.AutoShoot:Disconnect() end
        end
    end,
})

-- 5. ESP/WALLHACK (НОВАЯ ФУНКЦИЯ - Визуал)
local ESPToggle = VisualSection:CreateToggle({
    Name = "Включить ESP (Wallhack)",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(Value)
        CheatStates.ESP = Value
        if Value then
            -- Простая реализация подсветки игроков
            for _, target in pairs(Players:GetPlayers()) do
                if target ~= Player and target.Character then
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = target.Character
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.Parent = target.Character
                    Connections["ESP_"..target.Name] = highlight
                end
            end
        else
            -- Удаление подсветки
            for name, conn in pairs(Connections) do
                if string.find(name, "ESP_") and conn then
                    conn:Destroy()
                    Connections[name] = nil
                end
            end
        end
    end,
})

-- 6. ИЗМЕНЕНИЕ СКОРОСТИ И ПРЫЖКА (Игрок) [citation:2]
local SpeedSlider = ModSection:CreateSlider({
    Name = "Скорость передвижения",
    Range = {16, 200},
    Increment = 4,
    Suffix = "studs/sec",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        local humanoid = GetHumanoid()
        if humanoid then
            humanoid.WalkSpeed = Value
        end
    end,
})

local JumpSlider = ModSection:CreateSlider({
    Name = "Сила прыжка",
    Range = {50, 500},
    Increment = 10,
    Suffix = "",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(Value)
        local humanoid = GetHumanoid()
        if humanoid then
            humanoid.JumpPower = Value
        end
    end,
})

-- 7. КНОПКА ЭКСТРЕННОГО ОТКЛЮЧЕНИЯ (важная функция) [citation:2]
local EmergencyButton = PlayerTab:CreateButton({
    Name = "⛔ ЭКСТРЕННОЕ ОТКЛЮЧЕНИЕ (F10)",
    Callback = function()
        -- Отключаем все тогглы
        AimBotToggle:Set(false)
        BunnyHopToggle:Set(false)
        SpinToggle:Set(false)
        AutoShootToggle:Set(false)
        ESPToggle:Set(false)
        
        -- Сбрасываем скорость и прыжок
        local humanoid = GetHumanoid()
        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
        end
        
        -- Уведомление
        Rayfield:Notify({
            Title = "Экстренное отключение",
            Content = "Все читы отключены!",
            Duration = 4,
            Image = 4483345998,
        })
    end,
})

-- Горячая клавиша для экстренного отключения (F10)
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F10 then
        EmergencyButton.Callback()
    end
end)

-- ФУТЕР С ИНФОРМАЦИЕЙ [citation:4]
local InfoSection = PlayerTab:CreateSection("Информация")
local InfoLabel = PlayerTab:CreateLabel("Управление:")
local InfoLabel2 = PlayerTab:CreateLabel("RightControl - Показать/скрыть меню")
local InfoLabel3 = PlayerTab:CreateLabel("F10 - Экстренное отключение")
local WarningLabel = PlayerTab:CreateParagraph({
    Title = "ВНИМАНИЕ",
    Content = "Использование читов может привести к блокировке аккаунта. Вы используете это ПО на свой страх и риск."
})

print("======================================")
print("NV Cheat Menu (Rayfield) загружен!")
print("Управление: RightControl, F10")
print("======================================")
