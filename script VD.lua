local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local localPlayer = Players.LocalPlayer

-- Функция для безопасного получения PlayerGui
local function getPlayerGui()
    local success, result = pcall(function()
        return localPlayer:WaitForChild("PlayerGui")
    end)
    if success then
        return result
    else
        return CoreGui
    end
end

local playerGui = getPlayerGui()

-- Удаляем старые GUI если есть
if playerGui:FindFirstChild("CheatMenuGui") then
    playerGui.CheatMenuGui:Destroy()
end
if playerGui:FindFirstChild("FunctionButtonsGui") then
    playerGui.FunctionButtonsGui:Destroy()
end

-- Создаем основной GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CheatMenuGui"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.Parent = playerGui

-- GUI для функциональных кнопок
local functionButtonsGui = Instance.new("ScreenGui")
functionButtonsGui.Name = "FunctionButtonsGui"
functionButtonsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
functionButtonsGui.ResetOnSpawn = false
functionButtonsGui.DisplayOrder = 998
functionButtonsGui.Parent = playerGui

-- Переменные для состояний
local noClipEnabled = false
local tpwalking = false
local aimbotEnabled = false
local crosshairEnabled = false
local espPlayerEnabled = false
local espGeneratorEnabled = false
local menuOpen = false
local buttonsLocked = false
local autoGenEnabled = false
local palletESPEnabled = false
local rgbKillerEnabled = false
local tpKillerEnabled = false
local immortalityEnabled = false
local superJumpEnabled = false
local originalJumpPower = 50

-- ПЕРЕМЕННЫЕ ДЛЯ TPWALK
local tpwalkSpeed = 4
local savedSpeed = "4"

-- ПЕРЕМЕННЫЕ ДЛЯ AUTO-GEN
local noSkillEnabled = false
local noSkillToggleUser = false
local hookSkillInstalled = false
local autoGenConnection = nil

-- Whitelist для GUI элементов которые не нужно удалять
local guiWhitelist = {
    Rayfield = true,
    DevConsoleMaster = true,
    RobloxGui = true,
    PlayerList = true,
    Chat = true,
    BubbleChat = true,
    Backpack = true
}

-- Точные названия skillcheck элементов
local skillExactNames = {
    SkillCheckPromptGui = true,
    ["SkillCheckPromptGui-con"] = true,
    SkillCheckEvent = true,
    SkillCheckFailEvent = true,
    SkillCheckResultEvent = true
}

-- Хранилище позиций кнопок
local buttonPositions = {
    ["Атака"] = UDim2.new(0, 60, 0, 15),
    ["NoClip"] = UDim2.new(0, 140, 0, 15),
    ["TPWalk"] = UDim2.new(0, 220, 0, 15),
    ["Aimbot"] = UDim2.new(0, 60, 0, 95)
}

-- Хранилище кейбиндов
local keybinds = {
    ["Атака"] = "E",
    ["NoClip"] = "N", 
    ["TPWalk"] = "T",
    ["Aimbot"] = "F",
    ["Прицел"] = "C",
    ["ESP Player"] = "P",
    ["ESP Generator"] = "G",
    ["Блокировка"] = "L",
    ["Auto-Gen"] = "H",
    ["Pallet ESP"] = "J",
    ["RGB Killer"] = "R",
    ["TP Killer"] = "K",
    ["Бессмертие"] = "I",
    ["Прыжки"] = "V"
}

-- ЦВЕТА ФИОЛЕТОВОЙ СТЕКЛЯННОЙ ТЕМЫ
local PURPLE_COLORS = {
    PRIMARY = Color3.fromRGB(138, 43, 226),  -- Фиолетовый
    SECONDARY = Color3.fromRGB(147, 112, 219), -- Светло-фиолетовый
    DARK = Color3.fromRGB(75, 0, 130),       -- Темно-фиолетовый
    GLASS = Color3.fromRGB(106, 90, 205),    -- Стеклянный фиолетовый
    ACCENT = Color3.fromRGB(186, 85, 211)    -- Акцентный фиолетовый
}

-- Размеры элементов (УМЕНЬШЕН РАЗМЕР МЕНЮ И КНОПКИ)
local BUTTON_SIZE = UDim2.new(0, 30, 0, 30)
local MENU_SIZE = UDim2.new(0, 140, 0, 400) -- УВЕЛИЧЕНА ВЫСОТА ДО 400
local FUNCTION_BUTTON_SIZE = UDim2.new(0, 70, 0, 70)
local FUNCTION_BUTTON_SIZE_LARGE = UDim2.new(0, 75, 0, 75)

-- ========== НОВЫЕ ФУНКЦИИ ==========

-- Функция TP Killer (телепортация к убийце)
local function teleportToKiller()
    local killer = nil
    
    -- Ищем убийцу среди игроков
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            local role = getRole(player)
            if role == "Killer" then
                killer = player
                break
            end
        end
    end
    
    if killer and killer.Character and killer.Character:FindFirstChild("HumanoidRootPart") then
        local localChar = localPlayer.Character
        if localChar and localChar:FindFirstChild("HumanoidRootPart") then
            localChar.HumanoidRootPart.CFrame = killer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            print("✅ Телепортирован к убийце: " .. killer.Name)
        else
            print("❌ Ошибка: ваш персонаж не найден")
        end
    else
        print("❌ Убийца не найден")
    end
end

-- Функция бессмертия
local immortalityConnection = nil

local function toggleImmortality(button)
    immortalityEnabled = not immortalityEnabled
    
    if immortalityEnabled then
        if button then
            button.BackgroundColor3 = PURPLE_COLORS.SECONDARY
        end
        
        -- Сохраняем оригинальное здоровье
        local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            originalJumpPower = humanoid.JumpPower
            
            -- Защита от смерти
            immortalityConnection = humanoid.Died:Connect(function()
                if immortalityEnabled then
                    -- Воскрешаем персонажа
                    wait(2)
                    if localPlayer.Character then
                        localPlayer.Character:BreakJoints()
                    end
                end
            end)
            
            -- Авто-восстановление здоровья
            local healthConnection
            healthConnection = RunService.Heartbeat:Connect(function()
                if not immortalityEnabled or not humanoid or humanoid.Parent == nil then
                    healthConnection:Disconnect()
                    return
                end
                
                -- Восстанавливаем здоровье если оно меньше максимума
                if humanoid.Health < humanoid.MaxHealth then
                    humanoid.Health = humanoid.MaxHealth
                end
            end)
        end
        
        print("✅ Бессмертие включено")
    else
        if button then
            button.BackgroundColor3 = PURPLE_COLORS.DARK
        end
        
        if immortalityConnection then
            immortalityConnection:Disconnect()
            immortalityConnection = nil
        end
        
        print("❌ Бессмертие выключено")
    end
end

-- Функция супер-прыжков
local function toggleSuperJump(button)
    superJumpEnabled = not superJumpEnabled
    
    if superJumpEnabled then
        if button then
            button.BackgroundColor3 = PURPLE_COLORS.SECONDARY
        end
        
        local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            originalJumpPower = humanoid.JumpPower
            humanoid.JumpPower = 100 -- Увеличенная сила прыжка
        end
        
        print("✅ Супер-прыжки включены")
    else
        if button then
            button.BackgroundColor3 = PURPLE_COLORS.DARK
        end
        
        local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = originalJumpPower
        end
        
        print("❌ Супер-прыжки выключены")
    end
end

-- Функция для получения роли игрока
local function getRole(player)
    if player and player.Team then
        local teamName = player.Team.Name:lower()
        if teamName:find("killer") or teamName:find("maniac") or teamName:find("убийца") or teamName:find("маньяк") then 
            return "Killer" 
        end
    end
    return "Survivor"
end

-- ========== AUTO-GEN ФУНКЦИИ ==========

-- Функция проверки является ли объект skillcheck'ом
local function isExactSkill(inst)
    local n = inst and inst.Name
    if not n then return false end
    if skillExactNames[n] then return true end
    return n:lower():find("skillcheck", 1, true) ~= nil
end

-- Функция полного удаления skillcheck объектов
local function hardDelete(obj)
    pcall(function()
        if obj:IsA("ProximityPrompt") then 
            obj.Enabled = false 
            obj.HoldDuration = 1e9 
        end
        if obj:IsA("ScreenGui") or obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
            if obj:IsA("ScreenGui") and guiWhitelist[obj.Name] then return end
            obj.Enabled = false 
            obj.Visible = false 
            obj.ResetOnSpawn = false 
            obj:Destroy()
        else
            obj:Destroy()
        end
    end)
end

-- Однократное удаление всех существующих skillcheck'ов
local function nukeSkillExactOnce()
    local pg = localPlayer:FindFirstChild("PlayerGui")
    if pg then
        for _, g in ipairs(pg:GetChildren()) do
            if isExactSkill(g) then 
                hardDelete(g) 
            end
        end
        for _, d in ipairs(pg:GetDescendants()) do
            if isExactSkill(d) then 
                hardDelete(d) 
            end
        end
    end

    for _, g in ipairs(StarterGui:GetChildren()) do
        if isExactSkill(g) then 
            hardDelete(g) 
        end
    end

    local rem = ReplicatedStorage:FindFirstChild("Remotes")
    if rem then
        for _, d in ipairs(rem:GetDescendants()) do
            if isExactSkill(d) then 
                hardDelete(d) 
            end
        end
    end
end

-- Установка хуков для блокировки RemoteEvent/BindableEvent
local function installSkillBlock()
    if hookSkillInstalled then return end

    if typeof(hookmetamethod) == "function" and typeof(getnamecallmethod) == "function" then
        local old
        old = hookmetamethod(game, "__namecall", function(self, ...)
            local m = getnamecallmethod()
            if noSkillEnabled and typeof(self) == "Instance" and isExactSkill(self) and (m == "FireServer" or m == "InvokeServer") then
                return nil
            end
            return old(self, ...)
        end)
        hookSkillInstalled = true
    end
end

-- Подключения для отслеживания новых skillcheck'ов
local rsAddConn, pgAddConn, pgDescConn, sgAddConn, remAddConn, wsAddConn
local charAddConns = {}

-- Включение анти-скиллчека
local function startNoSkill()
    installSkillBlock()
    nukeSkillExactOnce()

    local pg = localPlayer:FindFirstChild("PlayerGui")
    if pg then
        if pgAddConn then pgAddConn:Disconnect() end
        pgAddConn = pg.ChildAdded:Connect(function(ch)
            if noSkillEnabled and isExactSkill(ch) then 
                hardDelete(ch) 
            end
        end)

        if pgDescConn then pgDescConn:Disconnect() end
        pgDescConn = pg.DescendantAdded:Connect(function(d)
            if noSkillEnabled and isExactSkill(d) then 
                hardDelete(d) 
            end
        end)
    end

    if sgAddConn then sgAddConn:Disconnect() end
    sgAddConn = StarterGui.ChildAdded:Connect(function(ch)
        if noSkillEnabled and isExactSkill(ch) then 
            hardDelete(ch) 
        end
    end)

    local rem = ReplicatedStorage:FindFirstChild("Remotes")
    if rem then
        if remAddConn then remAddConn:Disconnect() end
        remAddConn = rem.DescendantAdded:Connect(function(d)
            if noSkillEnabled and isExactSkill(d) then 
                hardDelete(d) 
            end
        end)
    end

    if rsAddConn then rsAddConn:Disconnect() end
    rsAddConn = ReplicatedStorage.DescendantAdded:Connect(function(d)
        if not noSkillEnabled then return end
        if d:IsA("ScreenGui") or d:IsA("BillboardGui") or d:IsA("SurfaceGui") or 
           d:IsA("RemoteEvent") or d:IsA("RemoteFunction") or d:IsA("BindableEvent") then
            if isExactSkill(d) then 
                hardDelete(d) 
            end
        end
    end)

    for _, pl in ipairs(Players:GetPlayers()) do
        if charAddConns[pl] then charAddConns[pl]:Disconnect() end
        charAddConns[pl] = pl.CharacterAdded:Connect(function(ch)
            if not noSkillEnabled then return end
            task.wait(0.1)
            for _, d in ipairs(ch:GetDescendants()) do
                if isExactSkill(d) then 
                    hardDelete(d) 
                end
            end
        end)

        if pl.Character then
            for _, d in ipairs(pl.Character:GetDescendants()) do
                if isExactSkill(d) then 
                    hardDelete(d) 
                end
            end
        end
    end

    if wsAddConn then wsAddConn:Disconnect() end
    wsAddConn = Workspace.DescendantAdded:Connect(function(d)
        if noSkillEnabled and isExactSkill(d) then 
            hardDelete(d) 
        end
    end)
end

-- Выключение анти-скиллчека
local function stopNoSkill()
    if pgAddConn then pgAddConn:Disconnect() pgAddConn = nil end
    if pgDescConn then pgDescConn:Disconnect() pgDescConn = nil end
    if sgAddConn then sgAddConn:Disconnect() sgAddConn = nil end
    if remAddConn then remAddConn:Disconnect() remAddConn = nil end
    if rsAddConn then rsAddConn:Disconnect() rsAddConn = nil end
    if wsAddConn then wsAddConn:Disconnect() wsAddConn = nil end

    for pl, cn in pairs(charAddConns) do
        if cn then cn:Disconnect() end
        charAddConns[pl] = nil
    end
end

-- Toggle функция для Auto-Gen
local function toggleAutoGen(button)
    autoGenEnabled = not autoGenEnabled
    noSkillEnabled = autoGenEnabled
    noSkillToggleUser = autoGenEnabled

    if autoGenEnabled then
        if button then
            button.BackgroundColor3 = PURPLE_COLORS.SECONDARY
        end
        startNoSkill()
        print("✅ Auto-Gen включен")
    else
        if button then
            button.BackgroundColor3 = PURPLE_COLORS.DARK
        end
        stopNoSkill()
        print("❌ Auto-Gen выключен")
    end
end

-- ========== PALLET ESP ФУНКЦИИ ==========

-- Настройки Pallet ESP
local palletColor = Color3.fromRGB(138, 43, 226) -- Фиолетовый цвет

-- Вспомогательные функции
local function alive(obj)
    if not obj then return false end
    local success = pcall(function() return obj.Parent end)
    return success and obj.Parent ~= nil
end

-- Функция для создания контурного ESP
local function createPalletHighlight(model)
    if not alive(model) then return nil end

    local highlight = Instance.new("Highlight")
    highlight.Name = "PalletESP_Highlight"
    highlight.Adornee = model
    highlight.FillTransparency = 1
    highlight.OutlineColor = palletColor
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    return highlight
end

-- Регистрация паллетов
local palletRegistry = {}

local function findPallets()
    for model, entry in pairs(palletRegistry) do
        if entry.highlight then 
            entry.highlight:Destroy() 
        end
    end
    palletRegistry = {}

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name == "Palletwrong" or obj.Name:lower():find("pallet")) then
            if not palletRegistry[obj] then
                palletRegistry[obj] = {
                    model = obj,
                    highlight = nil
                }
            end
        end
    end
end

local function updatePalletESP()
    if not palletESPEnabled then
        for model, entry in pairs(palletRegistry) do
            if entry.highlight then 
                entry.highlight:Destroy() 
                entry.highlight = nil
            end
        end
        return
    end

    for model, entry in pairs(palletRegistry) do
        if model and alive(model) then
            if not entry.highlight or not alive(entry.highlight) then
                entry.highlight = createPalletHighlight(model)
                if entry.highlight then
                    entry.highlight.Parent = model
                end
            else
                entry.highlight.OutlineColor = palletColor
            end
        else
            if entry.highlight then 
                entry.highlight:Destroy() 
            end
            palletRegistry[model] = nil
        end
    end
end

-- Основной цикл ESP
local espLoopConnection = nil

local function startPalletESPLoop()
    if espLoopConnection then return end
    espLoopConnection = RunService.Heartbeat:Connect(updatePalletESP)
end

local function stopPalletESPLoop()
    if espLoopConnection then
        espLoopConnection:Disconnect()
        espLoopConnection = nil
    end
end

-- Toggle функция для Pallet ESP
local function togglePalletESP(button)
    palletESPEnabled = not palletESPEnabled

    if palletESPEnabled then
        if button then
            button.BackgroundColor3 = PURPLE_COLORS.SECONDARY
        end
        findPallets()
        startPalletESPLoop()
        print("✅ Pallet ESP включен (фиолетовый контур)")
    else
        if button then
            button.BackgroundColor3 = PURPLE_COLORS.DARK
        end
        stopPalletESPLoop()
        for model, entry in pairs(palletRegistry) do
            if entry.highlight then 
                entry.highlight:Destroy() 
            end
        end
        print("❌ Pallet ESP выключен")
    end
end

-- Авто-обновление при изменении карты
local function setupMapMonitoring()
    Workspace.DescendantAdded:Connect(function(descendant)
        if palletESPEnabled and descendant:IsA("Model") and 
           (descendant.Name == "Palletwrong" or descendant.Name:lower():find("pallet")) then
            if not palletRegistry[descendant] then
                palletRegistry[descendant] = {
                    model = descendant,
                    highlight = nil
                }
            end
        end
    end)

    Workspace.DescendantRemoving:Connect(function(descendant)
        if descendant:IsA("Model") and palletRegistry[descendant] then
            local entry = palletRegistry[descendant]
            if entry.highlight then entry.highlight:Destroy() end
            palletRegistry[descendant] = nil
        end
    end)
end

-- Инициализация Pallet ESP
setupMapMonitoring()

Workspace.ChildAdded:Connect(function(child)
    if child.Name == "Map" or child.Name == "Map1" then
        task.wait(3)
        if palletESPEnabled then
            findPallets()
        end
    end
end)

task.delay(2, findPallets)

-- ========== КОНЕЦ PALLET ESP ФУНКЦИЙ ==========

-- ========== RGB KILLER ФУНКЦИИ ==========

local rgbKillerConnection = nil
-- ПОЛНАЯ РАДУГА ВСЕХ ЦВЕТОВ
local rainbowColors = {
    Color3.fromRGB(255, 0, 0),      -- Красный
    Color3.fromRGB(255, 127, 0),    -- Оранжевый
    Color3.fromRGB(255, 255, 0),    -- Желтый
    Color3.fromRGB(0, 255, 0),      -- Зеленый
    Color3.fromRGB(0, 0, 255),      -- Синий
    Color3.fromRGB(75, 0, 130),     -- Индиго
    Color3.fromRGB(148, 0, 211),    -- Фиолетовый
    Color3.fromRGB(255, 0, 255),    -- Розовый
    Color3.fromRGB(255, 165, 0),    -- Оранжевый
    Color3.fromRGB(0, 255, 255),    -- Голубой
    Color3.fromRGB(255, 192, 203),  -- Розовый
    Color3.fromRGB(0, 128, 0)       -- Темно-зеленый
}

local function getRainbowColor(time)
    local index = math.floor((time * 3) % #rainbowColors) + 1
    local nextIndex = (index % #rainbowColors) + 1
    local alpha = (time * 3) % 1

    return rainbowColors[index]:Lerp(rainbowColors[nextIndex], alpha)
end

local function updateRGBKiller()
    if not rgbKillerEnabled then return end

    local currentTime = tick()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local character = player.Character
            local role = getRole(player)

            if role == "Killer" then
                local highlight = character:FindFirstChild("ESP_HL")
                local head = character:FindFirstChild("Head")
                local tag = head and head:FindFirstChild("ESP_Tag")

                if highlight then
                    local rainbowColor = getRainbowColor(currentTime)
                    highlight.FillColor = rainbowColor
                    highlight.OutlineColor = rainbowColor
                end

                if tag then
                    local label = tag:FindFirstChild("Label")
                    if label then
                        local rainbowColor = getRainbowColor(currentTime)
                        label.TextColor3 = rainbowColor
                    end
                end
            end
        end
    end
end

-- ОБНОВЛЕННАЯ ФУНКЦИЯ RGB KILLER - ПОЛНАЯ РАДУГА
local function toggleRGBKiller(button)
    rgbKillerEnabled = not rgbKillerEnabled

    if rgbKillerEnabled then
        if button then
            button.BackgroundColor3 = PURPLE_COLORS.SECONDARY
        end

        if not rgbKillerConnection then
            rgbKillerConnection = RunService.Heartbeat:Connect(function()
                updateRGBKiller()
            end)
        end

        print("✅ RGB Killer включен - убийцы переливаются ВСЕМИ цветами радуги")
    else
        if button then
            button.BackgroundColor3 = PURPLE_COLORS.DARK
        end

        if rgbKillerConnection then
            rgbKillerConnection:Disconnect()
            rgbKillerConnection = nil
        end

        if espPlayerEnabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= localPlayer and player.Character then
                    local character = player.Character
                    local role = getRole(player)

                    if role == "Killer" then
                        local highlight = character:FindFirstChild("ESP_HL")
                        local head = character:FindFirstChild("Head")
                        local tag = head and head:FindFirstChild("ESP_Tag")

                        if highlight then
                            highlight.FillColor = Color3.fromRGB(255, 0, 0)
                            highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                        end

                        if tag then
                            local label = tag:FindFirstChild("Label")
                            if label then
                                label.TextColor3 = Color3.fromRGB(255, 0, 0)
                            end
                        end
                    end
                end
            end
        end

        print("❌ RGB Killer выключен")
    end
end

-- ========== КОНЕЦ RGB KILLER ФУНКЦИЙ ==========

-- ФУНКЦИЯ ДЛЯ СОЗДАНИЯ СТЕКЛЯННОГО ЭФФЕКТА (БЕЗ ТЕНИ)
local function createGlassEffect(frame)
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = PURPLE_COLORS.SECONDARY
    uiStroke.Thickness = 1
    uiStroke.Transparency = 0.3
    uiStroke.Parent = frame

    return uiStroke
end

-- СОЗДАЕМ ОСНОВНУЮ КНОПКУ МЕНЮ С ФИОЛЕТОВЫМ СТЕКЛЯННЫМ ДИЗАЙНОМ
local mainButton = Instance.new("TextButton")
mainButton.Name = "MainMenuButton"
mainButton.Size = BUTTON_SIZE
mainButton.Position = UDim2.new(0, 10, 0, 10)
mainButton.BackgroundColor3 = PURPLE_COLORS.PRIMARY
mainButton.BackgroundTransparency = 0.2
mainButton.BorderSizePixel = 0
mainButton.AutoButtonColor = true
mainButton.ZIndex = 1000
mainButton.Visible = true
mainButton.Active = true
mainButton.Selectable = true
mainButton.Text = "☰"
mainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
mainButton.TextScaled = true
mainButton.Font = Enum.Font.GothamBold
mainButton.TextWrapped = true

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0.3, 0)
mainCorner.Parent = mainButton

createGlassEffect(mainButton)

mainButton.Parent = screenGui

-- Выпадающее меню с фиолетовым стеклянным дизайном и ЗАКРУГЛЕННЫМИ ВЕРХНИМИ УГЛАМИ (БЕЗ ПЛЕНКИ)
local menuFrame = Instance.new("Frame")
menuFrame.Name = "CheatMenuFrame"
menuFrame.Size = MENU_SIZE
menuFrame.Position = UDim2.new(0, 10, 0, 50)
menuFrame.BackgroundColor3 = PURPLE_COLORS.DARK
menuFrame.BackgroundTransparency = 0.3  -- УВЕЛИЧЕНА ПРОЗРАЧНОСТЬ
menuFrame.BorderSizePixel = 0
menuFrame.Visible = false
menuFrame.ZIndex = 999

-- ЗАКРУГЛЕНИЕ ВСЕХ УГЛОВ ДЛЯ МЕНЮ
local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0.15, 0)
menuCorner.Parent = menuFrame

createGlassEffect(menuFrame)

-- ЗАГОЛОВОК С ЗАКРУГЛЕННЫМИ ВЕРХНИМИ УГЛАМИ
local menuTitle = Instance.new("TextLabel")
menuTitle.Name = "MenuTitle"
menuTitle.Size = UDim2.new(1, 0, 0, 25)
menuTitle.Position = UDim2.new(0, 0, 0, 0)
menuTitle.BackgroundColor3 = PURPLE_COLORS.PRIMARY
menuTitle.BackgroundTransparency = 0.1
menuTitle.BorderSizePixel = 0
menuTitle.Text = "🔪 Violence District"
menuTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
menuTitle.TextScaled = true
menuTitle.Font = Enum.Font.GothamBold
menuTitle.Parent = menuFrame

-- ЗАКРУГЛЕНИЕ ВСЕХ УГЛОВ ДЛЯ ЗАГОЛОВКА
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0.15, 0)
titleCorner.Parent = menuTitle

local titleStroke = Instance.new("UIStroke")
titleStroke.Color = PURPLE_COLORS.SECONDARY
titleStroke.Thickness = 1
titleStroke.Transparency = 0.5
titleStroke.Parent = menuTitle

local buttonsContainer = Instance.new("Frame")
buttonsContainer.Name = "ButtonsContainer"
buttonsContainer.Size = UDim2.new(1, -8, 1, -40)
buttonsContainer.Position = UDim2.new(0, 4, 0, 30)
buttonsContainer.BackgroundTransparency = 1
buttonsContainer.Parent = menuFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.Parent = buttonsContainer

-- Функция для показа настроек кейбинда
function showKeybindSettings(functionName)
    local settingsGui = Instance.new("ScreenGui")
    settingsGui.Name = "KeybindSettingsGui"
    settingsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    settingsGui.Parent = playerGui

    local background = Instance.new("Frame")
    background.Size = UDim2.new(0, 250, 0, 120)
    background.Position = UDim2.new(0.5, -125, 0.5, -60)
    background.BackgroundColor3 = PURPLE_COLORS.DARK
    background.BackgroundTransparency = 0.3  -- УВЕЛИЧЕНА ПРОЗРАЧНОСТЬ
    background.BorderSizePixel = 0

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.15, 0)
    corner.Parent = background

    createGlassEffect(background)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = PURPLE_COLORS.PRIMARY
    title.BackgroundTransparency = 0.1
    title.Text = "Настройка " .. functionName
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = background

    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(0.8, 0, 0, 30)
    inputBox.Position = UDim2.new(0.1, 0, 0.3, 0)
    inputBox.BackgroundColor3 = PURPLE_COLORS.GLASS
    inputBox.BackgroundTransparency = 0.3
    inputBox.Text = keybinds[functionName]
    inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    inputBox.TextScaled = true
    inputBox.PlaceholderText = "Введите кейбинд..."
    inputBox.Parent = background

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0.1, 0)
    inputCorner.Parent = inputBox

    local saveButton = Instance.new("TextButton")
    saveButton.Size = UDim2.new(0.8, 0, 0, 30)
    saveButton.Position = UDim2.new(0.1, 0, 0.7, 0)
    saveButton.BackgroundColor3 = PURPLE_COLORS.SECONDARY
    saveButton.BackgroundTransparency = 0.2
    saveButton.Text = "💾 Сохранить"
    saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveButton.TextScaled = true
    saveButton.Font = Enum.Font.GothamBold
    saveButton.Parent = background

    local saveCorner = Instance.new("UICorner")
    saveCorner.CornerRadius = UDim.new(0.1, 0)
    saveCorner.Parent = saveButton

    createGlassEffect(saveButton)

    saveButton.MouseButton1Click:Connect(function()
        local newKey = inputBox.Text
        if newKey ~= "" then
            keybinds[functionName] = newKey
            local buttonFrame = buttonsContainer:FindFirstChild(functionName .. "ButtonFrame")
            if buttonFrame then
                local buttonRow = buttonFrame:FindFirstChild("ButtonRow")
                if buttonRow then
                    local mainButton = buttonRow:FindFirstChild(functionName .. "Button")
                    if mainButton then
                        mainButton.Text = functionName .. " [" .. newKey .. "]"
                    end
                end
            end
            settingsGui:Destroy()
        end
    end)

    background.Parent = settingsGui
end

-- ФУНКЦИЯ ДЛЯ ПОКАЗА НАСТРОЕК TPWALK
function showTPWalkSettings()
    local settingsGui = Instance.new("ScreenGui")
    settingsGui.Name = "TPWalkSettingsGui"
    settingsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    settingsGui.Parent = playerGui

    local background = Instance.new("Frame")
    background.Size = UDim2.new(0, 300, 0, 250)
    background.Position = UDim2.new(0.5, -150, 0.5, -125)
    background.BackgroundColor3 = PURPLE_COLORS.DARK
    background.BackgroundTransparency = 0.3  -- УВЕЛИЧЕНА ПРОЗРАЧНОСТЬ
    background.BorderSizePixel = 0

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.15, 0)
    corner.Parent = background

    createGlassEffect(background)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = PURPLE_COLORS.PRIMARY
    title.BackgroundTransparency = 0.1
    title.Text = "⚡ Настройка TPWalk"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = background

    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(0.8, 0, 0, 20)
    speedLabel.Position = UDim2.new(0.1, 0, 0.15, 0)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Скорость (рекомендуется 4-10):"
    speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedLabel.TextScaled = true
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.Parent = background

    local speedBox = Instance.new("TextBox")
    speedBox.Size = UDim2.new(0.8, 0, 0, 30)
    speedBox.Position = UDim2.new(0.1, 0, 0.25, 0)
    speedBox.BackgroundColor3 = PURPLE_COLORS.GLASS
    speedBox.BackgroundTransparency = 0.3
    speedBox.Text = tostring(tpwalkSpeed)
    speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedBox.TextScaled = true
    speedBox.PlaceholderText = "Введите скорость..."
    speedBox.Parent = background

    local speedCorner = Instance.new("UICorner")
    speedCorner.CornerRadius = UDim.new(0.1, 0)
    speedCorner.Parent = speedBox

    local keybindLabel = Instance.new("TextLabel")
    keybindLabel.Size = UDim2.new(0.8, 0, 0, 20)
    keybindLabel.Position = UDim2.new(0.1, 0, 0.45, 0)
    keybindLabel.BackgroundTransparency = 1
    keybindLabel.Text = "Кейбинд:"
    keybindLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    keybindLabel.TextScaled = true
    keybindLabel.Font = Enum.Font.Gotham
    keybindLabel.Parent = background

    local keybindBox = Instance.new("TextBox")
    keybindBox.Size = UDim2.new(0.8, 0, 0, 30)
    keybindBox.Position = UDim2.new(0.1, 0, 0.55, 0)
    keybindBox.BackgroundColor3 = PURPLE_COLORS.GLASS
    keybindBox.BackgroundTransparency = 0.3
    keybindBox.Text = keybinds["TPWalk"]
    keybindBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    keybindBox.TextScaled = true
    keybindBox.PlaceholderText = "Введите кейбинд..."
    keybindBox.Parent = background

    local keybindCorner = Instance.new("UICorner")
    keybindCorner.CornerRadius = UDim.new(0.1, 0)
    keybindCorner.Parent = keybindBox

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0.8, 0, 0, 30)
    toggleBtn.Position = UDim2.new(0.1, 0, 0.75, 0)
    toggleBtn.BackgroundColor3 = tpwalking and PURPLE_COLORS.SECONDARY or PURPLE_COLORS.DARK
    toggleBtn.BackgroundTransparency = 0.2
    toggleBtn.Text = tpwalking and "🔴 Деактивировать" or "🟢 Активировать"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextScaled = true
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = background

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0.1, 0)
    toggleCorner.Parent = toggleBtn

    createGlassEffect(toggleBtn)

    local saveButton = Instance.new("TextButton")
    saveButton.Size = UDim2.new(0.8, 0, 0, 30)
    saveButton.Position = UDim2.new(0.1, 0, 0.9, 0)
    saveButton.BackgroundColor3 = PURPLE_COLORS.SECONDARY
    saveButton.BackgroundTransparency = 0.2
    saveButton.Text = "💾 Сохранить и закрыть"
    saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveButton.TextScaled = true
    saveButton.Font = Enum.Font.GothamBold
    saveButton.Parent = background

    local saveCorner = Instance.new("UICorner")
    saveCorner.CornerRadius = UDim.new(0.1, 0)
    saveCorner.Parent = saveButton

    createGlassEffect(saveButton)

    toggleBtn.MouseButton1Click:Connect(function()
        if tpwalking then
            stopTPWalk()
            toggleBtn.BackgroundColor3 = PURPLE_COLORS.DARK
            toggleBtn.Text = "🟢 Активировать"
        else
            local speed = tonumber(speedBox.Text) or tpwalkSpeed
            if speed and speed > 0 then
                startTPWalk(speed)
                toggleBtn.BackgroundColor3 = PURPLE_COLORS.SECONDARY
                toggleBtn.Text = "🔴 Деактивировать"
            end
        end
    end)

    saveButton.MouseButton1Click:Connect(function()
        local newSpeed = tonumber(speedBox.Text)
        if newSpeed and newSpeed > 0 then
            tpwalkSpeed = newSpeed
            savedSpeed = tostring(newSpeed)

            if tpwalking then
                stopTPWalk()
                startTPWalk(newSpeed)
            end
        end

        local newKey = keybindBox.Text
        if newKey ~= "" then
            keybinds["TPWalk"] = newKey

            local tpWalkButtonFrame = buttonsContainer:FindFirstChild("TPWalkButtonFrame")
            if tpWalkButtonFrame then
                local buttonRow = tpWalkButtonFrame:FindFirstChild("ButtonRow")
                if buttonRow then
                    local mainButton = buttonRow:FindFirstChild("TPWalkButton")
                    if mainButton then
                        mainButton.Text = "TPWalk [" .. newKey .. "]"
                    end
                end
            end
        end

        settingsGui:Destroy()
    end)

    background.Parent = settingsGui
end

-- Функция для создания кнопок меню с фиолетовым стеклянным дизайном
function createMenuButtonWithSettings(text, defaultKey)
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Name = text .. "ButtonFrame"
    buttonFrame.Size = UDim2.new(1, 0, 0, 22)
    buttonFrame.BackgroundTransparency = 1

    local buttonRow = Instance.new("Frame")
    buttonRow.Name = "ButtonRow"
    buttonRow.Size = UDim2.new(1, 0, 1, 0)
    buttonRow.BackgroundTransparency = 1
    buttonRow.Parent = buttonFrame

    local button = Instance.new("TextButton")
    button.Name = text .. "Button"
    button.Size = UDim2.new(0.75, 0, 1, 0)
    button.Position = UDim2.new(0, 0, 0, 0)
    button.BackgroundColor3 = PURPLE_COLORS.DARK
    button.BackgroundTransparency = 0.3
    button.BorderSizePixel = 0
    button.Text = text .. " [" .. defaultKey .. "]"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.Font = Enum.Font.Gotham
    button.AutoButtonColor = true
    button.TextWrapped = true

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0.1, 0)
    buttonCorner.Parent = button

    createGlassEffect(button)

    local settingsButton = Instance.new("TextButton")
    settingsButton.Name = text .. "Settings"
    settingsButton.Size = UDim2.new(0.2, 0, 1, 0)
    settingsButton.Position = UDim2.new(0.8, 0, 0, 0)
    settingsButton.BackgroundColor3 = PURPLE_COLORS.GLASS
    settingsButton.BackgroundTransparency = 0.3
    settingsButton.BorderSizePixel = 0
    settingsButton.Text = "⚙"
    settingsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    settingsButton.Font = Enum.Font.Gotham
    settingsButton.AutoButtonColor = true

    local settingsCorner = Instance.new("UICorner")
    settingsCorner.CornerRadius = UDim.new(0.1, 0)
    settingsCorner.Parent = settingsButton

    createGlassEffect(settingsButton)

    button.MouseButton1Click:Connect(function()
        if text == "Атака" then
            toggleButtonVisibility("Атака", button)
        elseif text == "NoClip" then
            toggleButtonVisibility("NoClip", button)
        elseif text == "TPWalk" then
            toggleButtonVisibility("TPWalk", button)
        elseif text == "Aimbot" then
            toggleButtonVisibility("Aimbot", button)
        elseif text == "Прицел" then
            toggleCrosshair(button)
        elseif text == "ESP Player" then
            toggleESPPlayer(button)
        elseif text == "ESP Generator" then
            toggleESPGenerator(button)
        elseif text == "Блокировка" then
            toggleLockButtons(button)
        elseif text == "Auto-Gen" then
            toggleAutoGen(button)
        elseif text == "Pallet ESP" then
            togglePalletESP(button)
        elseif text == "RGB Killer" then
            toggleRGBKiller(button)
        elseif text == "TP Killer" then
            teleportToKiller()
        elseif text == "Бессмертие" then
            toggleImmortality(button)
        elseif text == "Прыжки" then
            toggleSuperJump(button)
        end
    end)

    settingsButton.MouseButton1Click:Connect(function()
        if text == "TPWalk" then
            showTPWalkSettings()
        else
            showKeybindSettings(text)
        end
    end)

    button.Parent = buttonRow
    settingsButton.Parent = buttonRow
    buttonRow.Parent = buttonFrame

    return buttonFrame
end

-- Функция переключения видимости круглых кнопок
function toggleButtonVisibility(functionName, menuButton)
    local button = functionButtonsGui:FindFirstChild(functionName .. "FunctionButton")
    if button then
        button.Visible = not button.Visible
        if button.Visible then
            menuButton.BackgroundColor3 = PURPLE_COLORS.SECONDARY
        else
            menuButton.BackgroundColor3 = PURPLE_COLORS.DARK
        end
    end
end

-- СОЗДАЕМ КНОПКИ МЕНЮ С ФИОЛЕТОВЫМ ДИЗАЙНОМ
local attackButtonMenu = createMenuButtonWithSettings("Атака", keybinds["Атака"])
attackButtonMenu.Parent = buttonsContainer

local noClipButtonMenu = createMenuButtonWithSettings("NoClip", keybinds["NoClip"])
noClipButtonMenu.Parent = buttonsContainer

local tpWalkButtonMenu = createMenuButtonWithSettings("TPWalk", keybinds["TPWalk"])
tpWalkButtonMenu.Parent = buttonsContainer

local aimbotButtonMenu = createMenuButtonWithSettings("Aimbot", keybinds["Aimbot"])
aimbotButtonMenu.Parent = buttonsContainer

local crosshairButtonMenu = createMenuButtonWithSettings("Прицел", keybinds["Прицел"])
crosshairButtonMenu.Parent = buttonsContainer

local espPlayerButtonMenu = createMenuButtonWithSettings("ESP Player", keybinds["ESP Player"])
espPlayerButtonMenu.Parent = buttonsContainer

local espGeneratorButtonMenu = createMenuButtonWithSettings("ESP Generator", keybinds["ESP Generator"])
espGeneratorButtonMenu.Parent = buttonsContainer

local lockButtonMenu = createMenuButtonWithSettings("Блокировка", keybinds["Блокировка"])
lockButtonMenu.Parent = buttonsContainer

local autoGenButtonMenu = createMenuButtonWithSettings("Auto-Gen", keybinds["Auto-Gen"])
autoGenButtonMenu.Parent = buttonsContainer

local palletESPButtonMenu = createMenuButtonWithSettings("Pallet ESP", keybinds["Pallet ESP"])
palletESPButtonMenu.Parent = buttonsContainer

local rgbKillerButtonMenu = createMenuButtonWithSettings("RGB Killer", keybinds["RGB Killer"])
rgbKillerButtonMenu.Parent = buttonsContainer

-- НОВЫЕ КНОПКИ
local tpKillerButtonMenu = createMenuButtonWithSettings("TP Killer", keybinds["TP Killer"])
tpKillerButtonMenu.Parent = buttonsContainer

local immortalityButtonMenu = createMenuButtonWithSettings("Бессмертие", keybinds["Бессмертие"])
immortalityButtonMenu.Parent = buttonsContainer

local superJumpButtonMenu = createMenuButtonWithSettings("Прыжки", keybinds["Прыжки"])
superJumpButtonMenu.Parent = buttonsContainer

local telegramLabel = Instance.new("TextLabel")
telegramLabel.Name = "TelegramLabel"
telegramLabel.Size = UDim2.new(1, 0, 0, 12)
telegramLabel.Position = UDim2.new(0, 0, 1, -14)
telegramLabel.BackgroundTransparency = 1
telegramLabel.Text = "by @cheatorgame0"
telegramLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
telegramLabel.TextScaled = true
telegramLabel.Font = Enum.Font.Gotham
telegramLabel.Parent = menuFrame

menuFrame.Parent = screenGui

-- Функция пульсации кнопки
function pulseButton(button, originalSize)
    local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local sizeTween = TweenService:Create(button, tweenInfo, {Size = FUNCTION_BUTTON_SIZE_LARGE})
    sizeTween:Play()

    delay(0.1, function()
        local sizeBackTween = TweenService:Create(button, tweenInfo, {Size = originalSize})
        sizeBackTween:Play()
    end)
end

-- УНИВЕРСАЛЬНАЯ ФУНКЦИЯ ПЕРЕТАСКИВАНИЯ
function createDraggableButton(button, functionName)
    local isDragging = false
    local dragStart, startPos
    local dragConnection

    local function update(input)
        if buttonsLocked then return end

        local delta = input.Position - dragStart
        local newPosition = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X,
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )

        button.Position = newPosition
        buttonPositions[functionName] = newPosition
    end

    button.InputBegan:Connect(function(input)
        if buttonsLocked then return end

        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input.Position
            startPos = button.Position

            button.BackgroundTransparency = 0.1
            button.Size = FUNCTION_BUTTON_SIZE_LARGE

            dragConnection = UserInputService.InputChanged:Connect(function(inputChanged)
                if isDragging and (inputChanged.UserInputType == Enum.UserInputType.MouseMovement or inputChanged.UserInputType == Enum.UserInputType.Touch) then
                    update(inputChanged)
                end
            end)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and isDragging then
            isDragging = false
            button.BackgroundTransparency = 0.3
            button.Size = FUNCTION_BUTTON_SIZE

            if dragConnection then
                dragConnection:Disconnect()
            end
        end
    end)
end

-- Функция создания круглой кнопки с фиолетовым стеклянным дизайном
function createFunctionButton(functionName, defaultKey)
    local button = Instance.new("TextButton")
    button.Name = functionName .. "FunctionButton"
    button.Size = FUNCTION_BUTTON_SIZE
    button.Position = buttonPositions[functionName] or UDim2.new(0, math.random(50, 150), 0, math.random(50, 150))
    button.BackgroundColor3 = PURPLE_COLORS.PRIMARY
    button.BackgroundTransparency = 0.3
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Visible = false
    button.ZIndex = 100
    button.Active = true
    button.Selectable = true
    button.Text = ""

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button

    createGlassEffect(button)

    local label = Instance.new("TextLabel")
    label.Name = functionName .. "Label"
    label.Size = UDim2.new(1, 0, 0.7, 0)
    label.Position = UDim2.new(0, 0, 0.1, 0)
    label.BackgroundTransparency = 1
    label.Text = functionName
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.ZIndex = 101
    label.TextWrapped = true
    label.Parent = button

    local tgLabel = Instance.new("TextLabel")
    tgLabel.Name = functionName .. "TgLabel"
    tgLabel.Size = UDim2.new(1, 0, 0.3, 0)
    tgLabel.Position = UDim2.new(0, 0, 0.7, 0)
    tgLabel.BackgroundTransparency = 1
    tgLabel.Text = "tg @cheatorgame0"
    tgLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    tgLabel.TextScaled = true
    tgLabel.Font = Enum.Font.Gotham
    tgLabel.TextYAlignment = Enum.TextYAlignment.Top
    tgLabel.ZIndex = 101
    tgLabel.TextWrapped = true
    tgLabel.Parent = button

    createDraggableButton(button, functionName)

    button.MouseButton1Click:Connect(function()
        if functionName == "Атака" then
            performAttack(button)
        elseif functionName == "NoClip" then
            toggleNoClip(button)
        elseif functionName == "TPWalk" then
            toggleTPWalk(button)
        elseif functionName == "Aimbot" then
            toggleAimbot(button)
        end
    end)

    button.Parent = functionButtonsGui
    return button
end

-- СОЗДАЕМ КРУГЛЫЕ КНОПКИ С ФИОЛЕТОВЫМ ДИЗАЙНОМ
local attackButton = createFunctionButton("Атака", "E")
local noClipButton = createFunctionButton("NoClip", "N")
local tpWalkButton = createFunctionButton("TPWalk", "T")
local aimbotButton = createFunctionButton("Aimbot", "F")

-- Функция переключения меню
function toggleMenu()
    menuOpen = not menuOpen
    menuFrame.Visible = menuOpen

    if menuOpen then
        mainButton.BackgroundColor3 = PURPLE_COLORS.SECONDARY
        mainButton.Text = "✕"
        print("Меню открыто")
    else
        mainButton.BackgroundColor3 = PURPLE_COLORS.PRIMARY
        mainButton.Text = "☰"
        print("Меню закрыто")
    end
end

-- Обработчик основной кнопки
mainButton.MouseButton1Click:Connect(function()
    toggleMenu()
end)

-- ПЕРЕТАСКИВАНИЕ ОСНОВНОЙ КНОПКИ С МЕНЮ
local isMainDragging = false
local mainDragStart, mainStartPos, menuStartPos

mainButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isMainDragging = true
        mainDragStart = input.Position
        mainStartPos = mainButton.Position
        menuStartPos = menuFrame.Position

        mainButton.Size = UDim2.new(0, 35, 0, 35)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isMainDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - mainDragStart

        mainButton.Position = UDim2.new(
            mainStartPos.X.Scale, 
            mainStartPos.X.Offset + delta.X,
            mainStartPos.Y.Scale, 
            mainStartPos.Y.Offset + delta.Y
        )

        menuFrame.Position = UDim2.new(
            mainStartPos.X.Scale,
            mainStartPos.X.Offset + delta.X,
            mainStartPos.Y.Scale,
            mainStartPos.Y.Offset + delta.Y + 40
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isMainDragging = false
        mainButton.Size = BUTTON_SIZE
    end
end)

-- ФУНКЦИЯ ПРИЦЕЛА (ПО ЦЕНТРУ ЭКРАНА)
function toggleCrosshair(button)
    crosshairEnabled = not crosshairEnabled

    if crosshairEnabled then
        button.BackgroundColor3 = PURPLE_COLORS.SECONDARY

        local existingGui = playerGui:FindFirstChild("CrosshairGui")
        if existingGui then
            existingGui:Destroy()
        end

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "CrosshairGui"
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.ResetOnSpawn = false
        screenGui.IgnoreGuiInset = true

        local crosshair = Instance.new("Frame")
        crosshair.Name = "Crosshair"
        crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
        crosshair.Position = UDim2.new(0.5, 0, 0.5, 0)
        crosshair.Size = UDim2.new(0, 24, 0, 24)
        crosshair.BackgroundTransparency = 1

        local line1 = Instance.new("Frame")
        line1.Name = "Line1"
        line1.AnchorPoint = Vector2.new(0.5, 0.5)
        line1.Position = UDim2.new(0.5, 0, 0.5, 0)
        line1.Size = UDim2.new(0, 2, 0, 20)
        line1.BackgroundColor3 = PURPLE_COLORS.PRIMARY
        line1.BorderSizePixel = 0
        line1.Parent = crosshair

        local line2 = Instance.new("Frame")
        line2.Name = "Line2"
        line2.AnchorPoint = Vector2.new(0.5, 0.5)
        line2.Position = UDim2.new(0.5, 0, 0.5, 0)
        line2.Size = UDim2.new(0, 20, 0, 2)
        line2.BackgroundColor3 = PURPLE_COLORS.PRIMARY
        line2.BorderSizePixel = 0
        line2.Parent = crosshair

        crosshair.Parent = screenGui
        screenGui.Parent = playerGui
    else
        button.BackgroundColor3 = PURPLE_COLORS.DARK

        local existingGui = playerGui:FindFirstChild("CrosshairGui")
        if existingGui then
            existingGui:Destroy()
        end
    end
end

-- Вспомогательные функции
function findClosestPlayer(maxDistance)
    local closestPlayer = nil
    local shortestDistance = maxDistance or 100

    if not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end

    local localRoot = localPlayer.Character.HumanoidRootPart

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local character = player.Character
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

            if humanoidRootPart then
                local distance = (localRoot.Position - humanoidRootPart.Position).Magnitude

                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end

    return closestPlayer
end

-- ========== УЛУЧШЕННЫЙ АИМБОТ ==========
local aimbotConnection = nil
local currentTarget = nil

function getTargetBodyPart(character)
    local localCharacter = localPlayer.Character
    if not localCharacter or not localCharacter:FindFirstChild("HumanoidRootPart") then
        return nil
    end

    local targetRoot = character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        return nil
    end

    local targetLookVector = targetRoot.CFrame.LookVector
    local toTargetVector = (targetRoot.Position - localCharacter.HumanoidRootPart.Position).Unit

    local dotProduct = targetLookVector:Dot(toTargetVector)

    if dotProduct > 0 then
        if character:FindFirstChild("RightHand") then
            return character.RightHand
        elseif character:FindFirstChild("Right Arm") then
            return character["Right Arm"]
        elseif character:FindFirstChild("RightUpperArm") then
            return character.RightUpperArm
        elseif character:FindFirstChild("RightLowerArm") then
            return character.RightLowerArm
        end
    else
        if character:FindFirstChild("LeftHand") then
            return character.LeftHand
        elseif character:FindFirstChild("Left Arm") then
            return character["Left Arm"]
        elseif character:FindFirstChild("LeftUpperArm") then
            return character.LeftUpperArm
        elseif character:FindFirstChild("LeftLowerArm") then
            return character.LeftLowerArm
        end
    end

    if character:FindFirstChild("UpperTorso") then
        return character.UpperTorso
    elseif character:FindFirstChild("Torso") then
        return character.Torso
    elseif character:FindFirstChild("HumanoidRootPart") then
        return character.HumanoidRootPart
    elseif character:FindFirstChild("Head") then
        return character.Head
    end
    return nil
end

function takeControlOfCamera()
    local camera = workspace.CurrentCamera

    local originalCameraType = camera.CameraType
    local originalSubject = camera.CameraSubject

    camera.CameraType = Enum.CameraType.Scriptable

    local function updateCamera()
        if not aimbotEnabled or not currentTarget or not currentTarget.Character then
            return false
        end

        local targetPart = getTargetBodyPart(currentTarget.Character)
        local localCharacter = localPlayer.Character

        if targetPart and localCharacter and localCharacter:FindFirstChild("HumanoidRootPart") then
            local targetPosition = targetPart.Position

            if targetPart.Name == "LeftHand" or targetPart.Name == "Left Arm" or targetPart.Name == "LeftUpperArm" or targetPart.Name == "LeftLowerArm" or
               targetPart.Name == "RightHand" or targetPart.Name == "Right Arm" or targetPart.Name == "RightUpperArm" or targetPart.Name == "RightLowerArm" then
                targetPosition = targetPosition + targetPart.CFrame.LookVector * 0.5 + Vector3.new(0, 0.2, 0)
            end

            local rootPosition = localCharacter.HumanoidRootPart.Position

            local lookVector = (targetPosition - rootPosition).Unit
            local cameraPosition = rootPosition - lookVector * 8 + Vector3.new(0, 3, 0)

            local newCFrame = CFrame.new(cameraPosition, targetPosition)
            camera.CFrame = newCFrame

            local horizontalLookVector = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
            localCharacter.HumanoidRootPart.CFrame = CFrame.new(rootPosition, rootPosition + horizontalLookVector)

            return true
        end

        return false
    end

    local cameraLoop
    cameraLoop = RunService.Heartbeat:Connect(function()
        if not updateCamera() then
            cameraLoop:Disconnect()
            camera.CameraType = originalCameraType
            camera.CameraSubject = originalSubject
        end
    end)

    return cameraLoop
end

function toggleAimbot(button)
    aimbotEnabled = not aimbotEnabled
    pulseButton(button, FUNCTION_BUTTON_SIZE)

    if aimbotEnabled then
        button.BackgroundColor3 = PURPLE_COLORS.SECONDARY
        button:FindFirstChild("AimbotLabel").Text = "ВКЛ"

        currentTarget = findClosestPlayer(100)

        if currentTarget then
            startAimbot()
        else
            aimbotEnabled = false
            button.BackgroundColor3 = PURPLE_COLORS.PRIMARY
            button:FindFirstChild("AimbotLabel").Text = "Aimbot"
        end

    else
        button.BackgroundColor3 = PURPLE_COLORS.PRIMARY
        button:FindFirstChild("AimbotLabel").Text = "Aimbot"
        currentTarget = nil

        stopAimbot()
    end
end

function startAimbot()
    if aimbotConnection then
        aimbotConnection:Disconnect()
    end

    local mainLoop
    local backupLoop

    mainLoop = RunService.Heartbeat:Connect(function()
        if not aimbotEnabled or not currentTarget or not currentTarget.Character then
            mainLoop:Disconnect()
            if backupLoop then
                backupLoop:Disconnect()
            end
            return
        end

        takeControlOfCamera()
    end)

    backupLoop = RunService.RenderStepped:Connect(function()
        if not aimbotEnabled or not currentTarget or not currentTarget.Character then
            backupLoop:Disconnect()
            return
        end

        local camera = workspace.CurrentCamera
        local targetPart = getTargetBodyPart(currentTarget.Character)
        local localCharacter = localPlayer.Character

        if targetPart and localCharacter and localCharacter:FindFirstChild("HumanoidRootPart") then
            local targetPosition = targetPart.Position

            if targetPart.Name == "LeftHand" or targetPart.Name == "Left Arm" or targetPart.Name == "LeftUpperArm" or targetPart.Name == "LeftLowerArm" or
               targetPart.Name == "RightHand" or targetPart.Name == "Right Arm" or targetPart.Name == "RightUpperArm" or targetPart.Name == "RightLowerArm" then
                targetPosition = targetPosition + targetPart.CFrame.LookVector * 0.5 + Vector3.new(0, 0.2, 0)
            end

            local rootPosition = localCharacter.HumanoidRootPart.Position

            local lookVector = (targetPosition - rootPosition).Unit
            local cameraPosition = rootPosition - lookVector * 10 + Vector3.new(0, 5, 0)
            camera.CFrame = CFrame.new(cameraPosition, targetPosition)
        end
    end)

    aimbotConnection = {
        Disconnect = function()
            if mainLoop then
                mainLoop:Disconnect()
            end
            if backupLoop then
                backupLoop:Disconnect()
            end
        end
    }
end

function stopAimbot()
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end

    local camera = workspace.CurrentCamera
    camera.CameraType = Enum.CameraType.Custom
    if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
        camera.CameraSubject = localPlayer.Character.Humanoid
    end
end

-- ========== КОНЕЦ УЛУЧШЕННОГО АИМБОТА ==========

-- TPWALK ФУНКЦИИ
function startTPWalk(speed)
    if tpwalking then return end

    tpwalking = true
    tpwalkSpeed = tonumber(speed) or 4
    local char = localPlayer.Character
    local hum = char and char:FindFirstChildWhichIsA("Humanoid")
    if not hum then 
        tpwalking = false
        return 
    end

    task.spawn(function()
        while tpwalking and char and hum and hum.Parent do
            local delta = RunService.Heartbeat:Wait()
            if hum.MoveDirection.Magnitude > 0 then
                pcall(function()
                    char:TranslateBy(hum.MoveDirection * tpwalkSpeed * delta * 10)
                end)
            end
            if not localPlayer.Character or localPlayer.Character ~= char then
                tpwalking = false
            end
        end
    end)

    if tpWalkButton then
        tpWalkButton.BackgroundColor3 = PURPLE_COLORS.SECONDARY
        tpWalkButton:FindFirstChild("TPWalkLabel").Text = "ВКЛ"
    end
end

function stopTPWalk()
    tpwalking = false

    if tpWalkButton then
        tpWalkButton.BackgroundColor3 = PURPLE_COLORS.PRIMARY
        tpWalkButton:FindFirstChild("TPWalkLabel").Text = "TPWalk"
    end
end

function toggleTPWalk(button)
    pulseButton(button, FUNCTION_BUTTON_SIZE)

    if tpwalking then
        stopTPWalk()
    else
        startTPWalk(tpwalkSpeed)
    end
end

-- ОСНОВНЫЕ ФУНКЦИИ
function performAttack(button)
    pulseButton(button, FUNCTION_BUTTON_SIZE)

    local closestPlayer = findClosestPlayer(50)

    if closestPlayer then
        local args = {[1] = closestPlayer.Character}

        local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
        if remotes then
            local killers = remotes:FindFirstChild("Killers")
            if killers then
                local stalker = killers:FindFirstChild("Stalker")
                if stalker then
                    local grab = stalker:FindFirstChild("grab")
                    if grab then
                        grab:FireServer(unpack(args))

                        button.BackgroundColor3 = PURPLE_COLORS.SECONDARY
                        button:FindFirstChild("АтакаLabel").Text = "Успешно"

                        delay(0.5, function()
                            button.BackgroundColor3 = PURPLE_COLORS.PRIMARY
                            button:FindFirstChild("АтакаLabel").Text = "Атака"
                        end)
                        return
                    end
                end
            end
        end
    end
end

function toggleNoClip(button)
    noClipEnabled = not noClipEnabled
    pulseButton(button, FUNCTION_BUTTON_SIZE)

    if noClipEnabled then
        button.BackgroundColor3 = PURPLE_COLORS.SECONDARY
        button:FindFirstChild("NoClipLabel").Text = "ВКЛ"

        if localPlayer.Character then
            for _, part in ipairs(localPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    else
        button.BackgroundColor3 = PURPLE_COLORS.PRIMARY
        button:FindFirstChild("NoClipLabel").Text = "NoClip"

        if localPlayer.Character then
            for _, part in ipairs(localPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- ESP PLAYER
local espPlayerConnections = {}
local espPlayerLoopConn = nil

function toggleESPPlayer(button)
    espPlayerEnabled = not espPlayerEnabled

    if espPlayerEnabled then
        button.BackgroundColor3 = PURPLE_COLORS.SECONDARY
        startESPPlayer()
    else
        button.BackgroundColor3 = PURPLE_COLORS.DARK
        stopESPPlayer()
    end
end

function startESPPlayer()
    local survivorColor = Color3.fromRGB(0, 255, 0)
    local killerColor = PURPLE_COLORS.PRIMARY

    local function alive(i)
        if not i then return false end
        local ok = pcall(function() return i.Parent end)
        return ok and i.Parent ~= nil
    end

    local function validPart(p) 
        return p and alive(p) and p:IsA("BasePart") 
    end

    local function makeBillboard(text, color3)
        local g = Instance.new("BillboardGui")
        g.Name = "ESP_Tag"
        g.AlwaysOnTop = true
        g.Size = UDim2.new(0, 200, 0, 36)
        g.StudsOffset = Vector3.new(0, 3, 0)

        local l = Instance.new("TextLabel")
        l.Name = "Label"
        l.BackgroundTransparency = 1
        l.Size = UDim2.new(1, 0, 1, 0)
        l.Font = Enum.Font.GothamBold
        l.Text = text
        l.TextSize = 14
        l.TextColor3 = color3 or Color3.new(1,1,1)
        l.TextStrokeTransparency = 0
        l.TextStrokeColor3 = Color3.new(0,0,0)
        l.Parent = g

        return g
    end

    local function ensureHighlight(model, fill)
        if not (model and model:IsA("Model") and alive(model)) then return nil end

        local hl = model:FindFirstChild("ESP_HL")
        if not hl then
            local h = Instance.new("Highlight")
            h.Name = "ESP_HL"
            h.Adornee = model
            h.FillTransparency = 0.5
            h.OutlineTransparency = 0
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Parent = model
            hl = h
        end

        local player = Players:GetPlayerFromCharacter(model)
        if not rgbKillerEnabled or not player or getRole(player) ~= "Killer" then
            hl.FillColor = fill
            hl.OutlineColor = fill
        end
        return hl
    end

    local function clearHighlight(model)
        if model and model:FindFirstChild("ESP_HL") then
            model.ESP_HL:Destroy()
        end
    end

    local function applyOnePlayerESP(p)
        if p == localPlayer then return end

        local c = p.Character
        if not (c and alive(c)) then return end

        local col = (getRole(p) == "Killer") and killerColor or survivorColor

        ensureHighlight(c, col)

        local head = c:FindFirstChild("Head")
        if validPart(head) then
            local tag = head:FindFirstChild("ESP_Tag") or makeBillboard(p.Name, col)
            tag.Name = "ESP_Tag"
            tag.Parent = head
        end
    end

    espPlayerLoopConn = RunService.Heartbeat:Connect(function()
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= localPlayer then 
                applyOnePlayerESP(pl) 
            end
        end
    end)

    local function watchPlayer(p)
        espPlayerConnections[p] = {}

        table.insert(espPlayerConnections[p], p.CharacterAdded:Connect(function()
            task.wait(0.5)
            applyOnePlayerESP(p) 
        end))

        if p.Character then 
            applyOnePlayerESP(p) 
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do 
        if p ~= localPlayer then 
            watchPlayer(p) 
        end 
    end
end

function stopESPPlayer()
    if espPlayerLoopConn then
        espPlayerLoopConn:Disconnect()
        espPlayerLoopConn = nil
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local character = player.Character
            if character:FindFirstChild("ESP_HL") then
                character.ESP_HL:Destroy()
            end
            local head = character:FindFirstChild("Head")
            if head and head:FindFirstChild("ESP_Tag") then
                head.ESP_Tag:Destroy()
            end
        end
    end

    for player, connections in pairs(espPlayerConnections) do
        for _, connection in pairs(connections) do
            connection:Disconnect()
        end
    end
    espPlayerConnections = {}
end

-- ESP GENERATOR
local generatorHighlights = {}
local generatorRunServiceConn = nil

function toggleESPGenerator(button)
    espGeneratorEnabled = not espGeneratorEnabled

    if espGeneratorEnabled then
        button.BackgroundColor3 = PURPLE_COLORS.SECONDARY
        startESPGenerator()
    else
        button.BackgroundColor3 = PURPLE_COLORS.DARK
        stopESPGenerator()
    end
end

function startESPGenerator()
    local generatorBrokenColor = PURPLE_COLORS.ACCENT
    local generatorFixedColor = PURPLE_COLORS.SECONDARY

    local function getGeneratorProgress(generator)
        local repairProgress = generator:GetAttribute("RepairProgress")
        if repairProgress then
            if repairProgress <= 1 then
                return math.floor(repairProgress * 100)
            else
                return math.min(math.floor(repairProgress), 100)
            end
        end
        return 0
    end

    local function updateGeneratorESP()
        for generator, data in pairs(generatorHighlights) do
            if data.highlight then data.highlight:Destroy() end
            if data.billboard then data.billboard:Destroy() end
        end
        generatorHighlights = {}

        local map = Workspace:FindFirstChild("Map") or Workspace:FindFirstChild("Map1")
        if not map then return 0 end

        local generatorCount = 0

        for _, obj in ipairs(map:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == "Generator" then
                generatorCount = generatorCount + 1

                local mainPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if mainPart then
                    local progress = getGeneratorProgress(obj)
                    local color = progress >= 100 and generatorFixedColor or generatorBrokenColor

                    local highlight = Instance.new("Highlight")
                    highlight.FillColor = color
                    highlight.OutlineColor = color
                    highlight.FillTransparency = 0.6
                    highlight.OutlineTransparency = 0
                    highlight.Adornee = obj
                    highlight.Parent = obj

                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "GeneratorESP"
                    billboard.AlwaysOnTop = true
                    billboard.Size = UDim2.new(0, 200, 0, 50)
                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                    billboard.Adornee = mainPart
                    billboard.Parent = mainPart

                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.Text = progress .. "%"
                    label.TextColor3 = color
                    label.TextStrokeTransparency = 0
                    label.TextStrokeColor3 = Color3.new(0, 0, 0)
                    label.Font = Enum.Font.GothamBold
                    label.TextSize = 14
                    label.Parent = billboard

                    generatorHighlights[obj] = {
                        highlight = highlight,
                        billboard = billboard
                    }
                end
            end
        end

        return generatorCount
    end

    local count = updateGeneratorESP()

    generatorRunServiceConn = RunService.Heartbeat:Connect(function()
        for generator, data in pairs(generatorHighlights) do
            if generator and generator.Parent then
                local progress = getGeneratorProgress(generator)
                local color = progress >= 100 and generatorFixedColor or generatorBrokenColor

                if data.highlight then
                    data.highlight.FillColor = color
                    data.highlight.OutlineColor = color
                end

                if data.billboard then
                    local label = data.billboard:FindFirstChild("TextLabel")
                    if label then
                        label.Text = progress .. "%"
                        label.TextColor3 = color
                    end
                end
            else
                if data.highlight then data.highlight:Destroy() end
                if data.billboard then data.billboard:Destroy() end
                generatorHighlights[generator] = nil
            end
        end
    end)
end

function stopESPGenerator()
    if generatorRunServiceConn then
        generatorRunServiceConn:Disconnect()
        generatorRunServiceConn = nil
    end

    for generator, data in pairs(generatorHighlights) do
        if data.highlight then data.highlight:Destroy() end
        if data.billboard then data.billboard:Destroy() end
    end
    generatorHighlights = {}
end

-- БЛОКИРОВКА КНОПОК
function toggleLockButtons(button)
    buttonsLocked = not buttonsLocked

    if buttonsLocked then
        button.BackgroundColor3 = PURPLE_COLORS.SECONDARY
    else
        button.BackgroundColor3 = PURPLE_COLORS.DARK
    end
end

-- ========== ЗАЩИТА ОТ ИСЧЕЗНОВЕНИЯ МЕНЮ ПРИ ТЕЛЕПОРТАЦИИ ==========

local function ensureGUI()
    if not screenGui or not screenGui.Parent then
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "CheatMenuGui"
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.ResetOnSpawn = false
        screenGui.DisplayOrder = 999
        screenGui.Parent = playerGui

        mainButton.Parent = screenGui
        menuFrame.Parent = screenGui
    end

    if not functionButtonsGui or not functionButtonsGui.Parent then
        functionButtonsGui = Instance.new("ScreenGui")
        functionButtonsGui.Name = "FunctionButtonsGui"
        functionButtonsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        functionButtonsGui.ResetOnSpawn = false
        functionButtonsGui.DisplayOrder = 998
        functionButtonsGui.Parent = playerGui

        if attackButton then attackButton.Parent = functionButtonsGui end
        if noClipButton then noClipButton.Parent = functionButtonsGui end
        if tpWalkButton then tpWalkButton.Parent = functionButtonsGui end
        if aimbotButton then aimbotButton.Parent = functionButtonsGui end
    end
end

local guiCheckConnection
guiCheckConnection = RunService.Heartbeat:Connect(function()
    ensureGUI()
end)

localPlayer:GetPropertyChangedSignal("PlayerGui"):Connect(function()
    wait(1)
    playerGui = getPlayerGui()
    ensureGUI()
end)

localPlayer.CharacterAdded:Connect(function(character)
    task.wait(1)

    ensureGUI()

    if noClipEnabled then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    if tpwalking then
        stopTPWalk()
        startTPWalk(tpwalkSpeed)
    end

    if aimbotEnabled then
        currentTarget = findClosestPlayer(100)
        if not currentTarget then
            toggleAimbot(aimbotButton)
        else
            stopAimbot()
            wait(0.1)
            startAimbot()
        end
    end
    
    -- Восстанавливаем настройки после респавна
    if immortalityEnabled then
        toggleImmortality(nil)
        toggleImmortality(nil) -- Двойной вызов для активации
    end
    
    if superJumpEnabled then
        toggleSuperJump(nil)
        toggleSuperJump(nil) -- Двойной вызов для активации
    end
end)

localPlayer.CharacterRemoving:Connect(function(character)
    if tpwalking then
        stopTPWalk()
    end
end)

-- Обработчик кейбиндов
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.UserInputType == Enum.UserInputType.Keyboard then
        local key = input.KeyCode.Name

        for functionName, keybind in pairs(keybinds) do
            if key == keybind then
                if functionName == "Атака" and attackButton.Visible then
                    performAttack(attackButton)
                elseif functionName == "NoClip" and noClipButton.Visible then
                    toggleNoClip(noClipButton)
                elseif functionName == "TPWalk" and tpWalkButton.Visible then
                    toggleTPWalk(tpWalkButton)
                elseif functionName == "Aimbot" and aimbotButton.Visible then
                    toggleAimbot(aimbotButton)
                elseif functionName == "Прицел" then
                    toggleCrosshair(crosshairButtonMenu:FindFirstChild("ПрицелButton"))
                elseif functionName == "ESP Player" then
                    toggleESPPlayer(espPlayerButtonMenu:FindFirstChild("ESP PlayerButton"))
                elseif functionName == "ESP Generator" then
                    toggleESPGenerator(espGeneratorButtonMenu:FindFirstChild("ESP GeneratorButton"))
                elseif functionName == "Блокировка" then
                    toggleLockButtons(lockButtonMenu:FindFirstChild("БлокировкаButton"))
                elseif functionName == "Auto-Gen" then
                    toggleAutoGen(autoGenButtonMenu:FindFirstChild("Auto-GenButton"))
                elseif functionName == "Pallet ESP" then
                    togglePalletESP(palletESPButtonMenu:FindFirstChild("Pallet ESPButton"))
                elseif functionName == "RGB Killer" then
                    toggleRGBKiller(rgbKillerButtonMenu:FindFirstChild("RGB KillerButton"))
                elseif functionName == "TP Killer" then
                    teleportToKiller()
                elseif functionName == "Бессмертие" then
                    toggleImmortality(immortalityButtonMenu:FindFirstChild("БессмертиеButton"))
                elseif functionName == "Прыжки" then
                    toggleSuperJump(superJumpButtonMenu:FindFirstChild("ПрыжкиButton"))
                end
                break
            end
        end

        if key == "M" then
            toggleMenu()
        end
    end
end)

-- Гарантированное создание кнопки при запуске
wait(2)

if mainButton then
    mainButton.Visible = true
    mainButton.Active = true
    mainButton.Selectable = true
end

print("=== 🔪 VIOLENCE DISTRICT ЗАГРУЖЕНО ===")
print("✅ Основная кнопка меню создана в левом верхнем углу")
print("✅ Все функции работают:")
print("   - Auto-Gen (кейбинд H)")
print("   - Pallet ESP (кейбинд J)") 
print("   - RGB Killer (кейбинд R) - ПОЛНАЯ РАДУГА ВСЕХ ЦВЕТОВ")
print("   - ESP Player (кейбинд P)")
print("   - ESP Generator (кейбинд G)")
print("   - TP Killer (кейбинд K) - телепортация к убийце")
print("   - Бессмертие (кейбинд I) - неуязвимость и восстановление здоровья")
print("   - Прыжки (кейбинд V) - увеличенная высота прыжка")
print("✅ Нажмите M для открытия/закрытия меню")