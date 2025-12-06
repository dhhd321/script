--[[
  Flick Cheat Menu - LIGHT EDITION
  Упрощенная рабочая версия
]]

-- ========== ОСНОВНЫЕ СЕРВИСЫ ==========
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

-- ========== ЛОКАЛЬНЫЕ ПЕРЕМЕННЫЕ ==========
local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = Player:GetMouse()

-- ========== СОЗДАНИЕ ПРОСТОГО GUI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlickCheatGUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(80, 80, 100)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Title.TextColor3 = Color3.fromRGB(255, 100, 100)
Title.Text = "FLICK CHEAT MENU"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = MainFrame

-- ========== ФУНКЦИИ ДЛЯ FLICK ==========
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

-- Функция поиска ближайшего врага
local function FindNearestEnemy(range)
    local myRoot = GetRootPart()
    if not myRoot then return nil end
    
    local nearest = nil
    local nearestDist = range or 500
    
    for _, target in pairs(Players:GetPlayers()) do
        if target ~= Player and target.Character then
            local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = target.Character:FindFirstChild("Humanoid")
            
            if targetRoot and humanoid and humanoid.Health > 0 then
                local dist = (myRoot.Position - targetRoot.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest = target
                end
            end
        end
    end
    
    return nearest
end

-- ========== ПЕРЕМЕННЫЕ СОСТОЯНИЙ ==========
local CheatStates = {
    AimBot = false,
    TriggerBot = false,
    ESP = false,
    Speed = false
}

local Connections = {}

-- ========== СОЗДАНИЕ КНОПОК ==========
local yPosition = 50
local buttonHeight = 35
local buttonSpacing = 5

local function CreateButton(text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9, 0, 0, buttonHeight)
    button.Position = UDim2.new(0.05, 0, 0, yPosition)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = text
    button.Font = Enum.Font.SourceSans
    button.TextSize = 16
    button.Parent = MainFrame
    
    yPosition = yPosition + buttonHeight + buttonSpacing
    
    button.MouseButton1Click:Connect(callback)
    return button
end

-- ========== 1. АИМБОТ ДЛЯ FLICK ==========
local AimBotButton = CreateButton("АИМБОТ: ВЫКЛ", function()
    CheatStates.AimBot = not CheatStates.AimBot
    
    if CheatStates.AimBot then
        AimBotButton.Text = "АИМБОТ: ВКЛ"
        AimBotButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        
        Connections.AimBot = RunService.RenderStepped:Connect(function()
            local target = FindNearestEnemy(500)
            
            if target and target.Character then
                local head = target.Character:FindFirstChild("Head")
                if head and Camera then
                    -- Простой аим на голову
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
                end
            end
        end)
    else
        AimBotButton.Text = "АИМБОТ: ВЫКЛ"
        AimBotButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        
        if Connections.AimBot then
            Connections.AimBot:Disconnect()
            Connections.AimBot = nil
        end
    end
end)

-- ========== 2. ТРИГГЕРБОТ ДЛЯ FLICK ==========
local TriggerBotButton = CreateButton("ТРИГГЕРБОТ: ВЫКЛ", function()
    CheatStates.TriggerBot = not CheatStates.TriggerBot
    
    if CheatStates.TriggerBot then
        TriggerBotButton.Text = "ТРИГГЕРБОТ: ВКЛ"
        TriggerBotButton.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
        
        Connections.TriggerBot = RunService.RenderStepped:Connect(function()
            -- Проверяем, наведена ли мышь на врага
            local target = Mouse.Target
            if target then
                local model = target:FindFirstAncestorOfClass("Model")
                if model then
                    local player = Players:GetPlayerFromCharacter(model)
                    if player and player ~= Player then
                        -- Симулируем клик мыши
                        mouse1click()
                    end
                end
            end
        end)
    else
        TriggerBotButton.Text = "ТРИГГЕРБОТ: ВЫКЛ"
        TriggerBotButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        
        if Connections.TriggerBot then
            Connections.TriggerBot:Disconnect()
            Connections.TriggerBot = nil
        end
    end
end)

-- ========== 3. ESP ДЛЯ FLICK ==========
local ESPButton = CreateButton("ESP: ВЫКЛ", function()
    CheatStates.ESP = not CheatStates.ESP
    
    if CheatStates.ESP then
        ESPButton.Text = "ESP: ВКЛ"
        ESPButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        
        -- Создаем подсветку для всех игроков
        local function HighlightPlayer(player)
            if player == Player then return end
            
            local character = player.Character
            if not character then return end
            
            local highlight = Instance.new("Highlight")
            highlight.Name = player.Name .. "_ESP"
            highlight.Adornee = character
            highlight.FillColor = Color3.fromRGB(255, 50, 50)
            highlight.FillTransparency = 0.7
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineTransparency = 0
            highlight.Parent = character
        end
        
        -- Применяем к существующим игрокам
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                HighlightPlayer(player)
            end
        end
        
    else
        ESPButton.Text = "ESP: ВЫКЛ"
        ESPButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        
        -- Удаляем все подсветки
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                for _, child in pairs(player.Character:GetChildren()) do
                    if child:IsA("Highlight") then
                        child:Destroy()
                    end
                end
            end
        end
    end
end)

-- ========== 4. УСКОРЕНИЕ ==========
local SpeedButton = CreateButton("УСКОРЕНИЕ: ВЫКЛ", function()
    CheatStates.Speed = not CheatStates.Speed
    
    if CheatStates.Speed then
        SpeedButton.Text = "УСКОРЕНИЕ: ВКЛ"
        SpeedButton.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
        
        local humanoid = GetHumanoid()
        if humanoid then
            humanoid.WalkSpeed = 50
        end
        
        -- Применяем к новым персонажам
        Player.CharacterAdded:Connect(function(character)
            task.wait(0.5)
            local hum = character:WaitForChild("Humanoid")
            hum.WalkSpeed = 50
        end)
    else
        SpeedButton.Text = "УСКОРЕНИЕ: ВЫКЛ"
        SpeedButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        
        local humanoid = GetHumanoid()
        if humanoid then
            humanoid.WalkSpeed = 16
        end
    end
end)

-- ========== 5. КНОПКА ОТКЛЮЧЕНИЯ ==========
local DisableButton = CreateButton("⛔ ОТКЛЮЧИТЬ ВСЕ", function()
    -- Отключаем все функции
    if CheatStates.AimBot then
        AimBotButton.MouseButton1Click:Fire()
    end
    
    if CheatStates.TriggerBot then
        TriggerBotButton.MouseButton1Click:Fire()
    end
    
    if CheatStates.ESP then
        ESPButton.MouseButton1Click:Fire()
    end
    
    if CheatStates.Speed then
        SpeedButton.MouseButton1Click:Fire()
    end
    
    -- Показываем уведомление
    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(1, -20, 0, 40)
    notif.Position = UDim2.new(0, 10, 0, yPosition + 10)
    notif.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    notif.TextColor3 = Color3.fromRGB(255, 255, 255)
    notif.Text = "Все функции отключены!"
    notif.Font = Enum.Font.SourceSansBold
    notif.TextSize = 16
    notif.Parent = MainFrame
    
    task.wait(2)
    notif:Destroy()
end)

-- ========== 6. КНОПКА СКРЫТИЯ ИНТЕРФЕЙСА ==========
local HideButton = CreateButton("📱 СКРЫТЬ/ПОКАЗАТЬ", function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- ========== ГОРЯЧИЕ КЛАВИШИ ==========
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F5 then
        -- Показать/скрыть меню
        MainFrame.Visible = not MainFrame.Visible
    elseif input.KeyCode == Enum.KeyCode.F6 then
        -- Быстрое включение/выключение аимбота
        if not CheatStates.AimBot then
            AimBotButton.MouseButton1Click:Fire()
        else
            AimBotButton.MouseButton1Click:Fire()
        end
    elseif input.KeyCode == Enum.KeyCode.F7 then
        -- Отключить все
        DisableButton.MouseButton1Click:Fire()
    end
end)

-- ========== ИНФОРМАЦИОННАЯ ПАНЕЛЬ ==========
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -20, 0, 40)
InfoLabel.Position = UDim2.new(0, 10, 0, yPosition + 60)
InfoLabel.BackgroundTransparency = 1
InfoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
InfoLabel.Text = "Управление: F5 - меню, F6 - аимбот, F7 - отключить"
InfoLabel.Font = Enum.Font.SourceSans
InfoLabel.TextSize = 12
InfoLabel.Parent = MainFrame

-- ========== КНОПКА ЗАКРЫТИЯ ==========
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 14
CloseButton.Parent = MainFrame

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ========== АВТОМАТИЧЕСКОЕ ОБНОВЛЕНИЕ ESP ==========
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        if CheatStates.ESP then
            task.wait(0.5)
            local highlight = Instance.new("Highlight")
            highlight.Name = player.Name .. "_ESP"
            highlight.Adornee = character
            highlight.FillColor = Color3.fromRGB(255, 50, 50)
            highlight.FillTransparency = 0.7
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineTransparency = 0
            highlight.Parent = character
        end
    end)
end)

-- ========== СООБЩЕНИЕ О ЗАГРУЗКЕ ==========
print("========================================")
print("Flick Cheat Menu - Light Edition")
print("Успешно загружен!")
print("Управление: F5 - меню, F6 - аимбот, F7 - отключить")
print("========================================")

-- Показываем уведомление о загрузке
local LoadingLabel = Instance.new("TextLabel")
LoadingLabel.Size = UDim2.new(0, 200, 0, 40)
LoadingLabel.Position = UDim2.new(0.5, -100, 0.1, 0)
LoadingLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
LoadingLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
LoadingLabel.Text = "Flick Cheat загружен!"
LoadingLabel.Font = Enum.Font.SourceSansBold
LoadingLabel.TextSize = 16
LoadingLabel.Parent = ScreenGui

task.wait(2)
LoadingLabel:Destroy()
