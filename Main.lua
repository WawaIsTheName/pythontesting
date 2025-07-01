local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Settings
local settings = {
    enabled = true,
    triggerOn = true,
    toggleKey = Enum.KeyCode.Home,
    triggerToggleKey = Enum.KeyCode.T,
    shootDelay = 0,
    firstShotDelay = 0.02,
    lastShotTime = 0,
    targetDetectedTime = 0,
    hasTarget = false,
    spreadControlEnabled = false,
    spreadControlToggleKey = Enum.KeyCode.B,
    lastSpreadShotTime = 0,
    spreadShotInterval = 0,
    maxSpreadDistance = 100, -- Increased to 100px
    firstShotFired = false
}

-- UI Creation
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TriggerBotUI"
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 370, 0, 320)
mainFrame.Position = UDim2.new(0.5, -185, 0.5, -160)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

-- Store the last position when dragging
local lastPosition = mainFrame.Position

-- Make frame draggable
local dragging
local dragInput
local dragStart
local startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    local newPosition = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    mainFrame.Position = newPosition
    lastPosition = newPosition
end

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and input.Position.Y - mainFrame.AbsolutePosition.Y <= 30 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateInput(input)
    end
end)

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.BorderSizePixel = 0
title.Text = "MangoBot"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = mainFrame

-- Toggle button
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0.9, 0, 0, 25)
toggleButton.Position = UDim2.new(0.05, 0, 0, 35)
toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggleButton.BorderSizePixel = 0
toggleButton.Text = "Disable Triggerbot"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.Gotham
toggleButton.TextSize = 12
toggleButton.Parent = mainFrame

local triggerStatusLabel = Instance.new("TextLabel")
triggerStatusLabel.Name = "TriggerStatusLabel"
triggerStatusLabel.Size = UDim2.new(1, -20, 0, 20)
triggerStatusLabel.Position = UDim2.new(0, 10, 0, 65)
triggerStatusLabel.BackgroundTransparency = 1
triggerStatusLabel.Text = "Active: ON (Press T)"
triggerStatusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
triggerStatusLabel.Font = Enum.Font.Gotham
triggerStatusLabel.TextSize = 12
triggerStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
triggerStatusLabel.Parent = mainFrame

-- Spread Control Toggle
local spreadControlButton = Instance.new("TextButton")
spreadControlButton.Name = "SpreadControlButton"
spreadControlButton.Size = UDim2.new(0.9, 0, 0, 25)
spreadControlButton.Position = UDim2.new(0.05, 0, 0, 90)
spreadControlButton.BackgroundColor3 = settings.spreadControlEnabled and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(120, 50, 50)
spreadControlButton.BorderSizePixel = 0
spreadControlButton.Text = settings.spreadControlEnabled and "Spread Control: ON (B)" or "Spread Control: OFF (B)"
spreadControlButton.TextColor3 = Color3.fromRGB(255, 255, 255)
spreadControlButton.Font = Enum.Font.Gotham
spreadControlButton.TextSize = 12
spreadControlButton.Parent = mainFrame

-- First Shot Delay slider
local firstDelaySlider = Instance.new("Frame")
firstDelaySlider.Name = "FirstDelaySlider"
firstDelaySlider.Size = UDim2.new(0.9, 0, 0, 30)
firstDelaySlider.Position = UDim2.new(0.05, 0, 0, 120)
firstDelaySlider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
firstDelaySlider.BorderSizePixel = 0
firstDelaySlider.Parent = mainFrame

local firstDelayTitle = Instance.new("TextLabel")
firstDelayTitle.Name = "FirstDelayTitle"
firstDelayTitle.Size = UDim2.new(1, 0, 0.5, 0)
firstDelayTitle.Position = UDim2.new(0, 0, 0, 0)
firstDelayTitle.BackgroundTransparency = 1
firstDelayTitle.Text = "First Shot Delay: 0.02s"
firstDelayTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
firstDelayTitle.Font = Enum.Font.Gotham
firstDelayTitle.TextSize = 12
firstDelayTitle.TextXAlignment = Enum.TextXAlignment.Left
firstDelayTitle.Parent = firstDelaySlider

local firstDelayBar = Instance.new("Frame")
firstDelayBar.Name = "FirstDelayBar"
firstDelayBar.Size = UDim2.new(1, 0, 0, 5)
firstDelayBar.Position = UDim2.new(0, 0, 0.5, 5)
firstDelayBar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
firstDelayBar.BorderSizePixel = 0
firstDelayBar.Parent = firstDelaySlider

local firstDelayFill = Instance.new("Frame")
firstDelayFill.Name = "FirstDelayFill"
firstDelayFill.Size = UDim2.new(0.02, 0, 1, 0)
firstDelayFill.Position = UDim2.new(0, 0, 0, 0)
firstDelayFill.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
firstDelayFill.BorderSizePixel = 0
firstDelayFill.Parent = firstDelayBar

local firstDelayButton = Instance.new("TextButton")
firstDelayButton.Name = "FirstDelayButton"
firstDelayButton.Size = UDim2.new(1, 0, 0.5, 0)
firstDelayButton.Position = UDim2.new(0, 0, 0.5, 5)
firstDelayButton.BackgroundTransparency = 1
firstDelayButton.Text = ""
firstDelayButton.Parent = firstDelaySlider

-- Regular Delay slider
local delaySlider = Instance.new("Frame")
delaySlider.Name = "DelaySlider"
delaySlider.Size = UDim2.new(0.9, 0, 0, 30)
delaySlider.Position = UDim2.new(0.05, 0, 0, 155)
delaySlider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
delaySlider.BorderSizePixel = 0
delaySlider.Parent = mainFrame

local delayTitle = Instance.new("TextLabel")
delayTitle.Name = "DelayTitle"
delayTitle.Size = UDim2.new(1, 0, 0.5, 0)
delayTitle.Position = UDim2.new(0, 0, 0, 0)
delayTitle.BackgroundTransparency = 1
delayTitle.Text = "Shot Delay: 0s"
delayTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
delayTitle.Font = Enum.Font.Gotham
delayTitle.TextSize = 12
delayTitle.TextXAlignment = Enum.TextXAlignment.Left
delayTitle.Parent = delaySlider

local delayBar = Instance.new("Frame")
delayBar.Name = "DelayBar"
delayBar.Size = UDim2.new(1, 0, 0, 5)
delayBar.Position = UDim2.new(0, 0, 0.5, 5)
delayBar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
delayBar.BorderSizePixel = 0
delayBar.Parent = delaySlider

local delayFill = Instance.new("Frame")
delayFill.Name = "DelayFill"
delayFill.Size = UDim2.new(0, 0, 1, 0)
delayFill.Position = UDim2.new(0, 0, 0, 0)
delayFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
delayFill.BorderSizePixel = 0
delayFill.Parent = delayBar

local delayButton = Instance.new("TextButton")
delayButton.Name = "DelayButton"
delayButton.Size = UDim2.new(1, 0, 0.5, 0)
delayButton.Position = UDim2.new(0, 0, 0.5, 5)
delayButton.BackgroundTransparency = 1
delayButton.Text = ""
delayButton.Parent = delaySlider

-- Spread Shot Interval slider
local spreadIntervalSlider = Instance.new("Frame")
spreadIntervalSlider.Name = "SpreadIntervalSlider"
spreadIntervalSlider.Size = UDim2.new(0.9, 0, 0, 30)
spreadIntervalSlider.Position = UDim2.new(0.05, 0, 0, 190)
spreadIntervalSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
spreadIntervalSlider.BorderSizePixel = 0
spreadIntervalSlider.Parent = mainFrame

local spreadIntervalTitle = Instance.new("TextLabel")
spreadIntervalTitle.Name = "SpreadIntervalTitle"
spreadIntervalTitle.Size = UDim2.new(1, 0, 0.5, 0)
spreadIntervalTitle.Position = UDim2.new(0, 0, 0, 0)
spreadIntervalTitle.BackgroundTransparency = 1
spreadIntervalTitle.Text = "Spread Interval: 0s"
spreadIntervalTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
spreadIntervalTitle.Font = Enum.Font.Gotham
spreadIntervalTitle.TextSize = 12
spreadIntervalTitle.TextXAlignment = Enum.TextXAlignment.Left
spreadIntervalTitle.Parent = spreadIntervalSlider

local spreadIntervalBar = Instance.new("Frame")
spreadIntervalBar.Name = "SpreadIntervalBar"
spreadIntervalBar.Size = UDim2.new(1, 0, 0, 5)
spreadIntervalBar.Position = UDim2.new(0, 0, 0.5, 5)
spreadIntervalBar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
spreadIntervalBar.BorderSizePixel = 0
spreadIntervalBar.Parent = spreadIntervalSlider

local spreadIntervalFill = Instance.new("Frame")
spreadIntervalFill.Name = "SpreadIntervalFill"
spreadIntervalFill.Size = UDim2.new(0, 0, 1, 0)
spreadIntervalFill.Position = UDim2.new(0, 0, 0, 0)
spreadIntervalFill.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
spreadIntervalFill.BorderSizePixel = 0
spreadIntervalFill.Parent = spreadIntervalBar

local spreadIntervalButton = Instance.new("TextButton")
spreadIntervalButton.Name = "SpreadIntervalButton"
spreadIntervalButton.Size = UDim2.new(1, 0, 0.5, 0)
spreadIntervalButton.Position = UDim2.new(0, 0, 0.5, 5)
spreadIntervalButton.BackgroundTransparency = 1
spreadIntervalButton.Text = ""
spreadIntervalButton.Parent = spreadIntervalSlider

-- Max Spread Distance slider (updated to 100px max)
local spreadDistanceSlider = Instance.new("Frame")
spreadDistanceSlider.Name = "SpreadDistanceSlider"
spreadDistanceSlider.Size = UDim2.new(0.9, 0, 0, 30)
spreadDistanceSlider.Position = UDim2.new(0.05, 0, 0, 225)
spreadDistanceSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
spreadDistanceSlider.BorderSizePixel = 0
spreadDistanceSlider.Parent = mainFrame

local spreadDistanceTitle = Instance.new("TextLabel")
spreadDistanceTitle.Name = "SpreadDistanceTitle"
spreadDistanceTitle.Size = UDim2.new(1, 0, 0.5, 0)
spreadDistanceTitle.Position = UDim2.new(0, 0, 0, 0)
spreadDistanceTitle.BackgroundTransparency = 1
spreadDistanceTitle.Text = "Max Spread: 5px"
spreadDistanceTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
spreadDistanceTitle.Font = Enum.Font.Gotham
spreadDistanceTitle.TextSize = 12
spreadDistanceTitle.TextXAlignment = Enum.TextXAlignment.Left
spreadDistanceTitle.Parent = spreadDistanceSlider

local spreadDistanceBar = Instance.new("Frame")
spreadDistanceBar.Name = "SpreadDistanceBar"
spreadDistanceBar.Size = UDim2.new(1, 0, 0, 5)
spreadDistanceBar.Position = UDim2.new(0, 0, 0.5, 5)
spreadDistanceBar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
spreadDistanceBar.BorderSizePixel = 0
spreadDistanceBar.Parent = spreadDistanceSlider

local spreadDistanceFill = Instance.new("Frame")
spreadDistanceFill.Name = "SpreadDistanceFill"
spreadDistanceFill.Size = UDim2.new(settings.maxSpreadDistance / 100, 0, 1, 0) -- Changed to 100px max
spreadDistanceFill.Position = UDim2.new(0, 0, 0, 0)
spreadDistanceFill.BackgroundColor3 = Color3.fromRGB(255, 0, 150)
spreadDistanceFill.BorderSizePixel = 0
spreadDistanceFill.Parent = spreadDistanceBar

local spreadDistanceButton = Instance.new("TextButton")
spreadDistanceButton.Name = "SpreadDistanceButton"
spreadDistanceButton.Size = UDim2.new(1, 0, 0.5, 0)
spreadDistanceButton.Position = UDim2.new(0, 0, 0.5, 5)
spreadDistanceButton.BackgroundTransparency = 1
spreadDistanceButton.Text = ""
spreadDistanceButton.Parent = spreadDistanceSlider

-- Added warning label
local warningLabel = Instance.new("TextLabel")
warningLabel.Name = "WarningLabel"
warningLabel.Size = UDim2.new(1, -20, 0, 20)
warningLabel.Position = UDim2.new(0, 10, 0, 260)
warningLabel.BackgroundTransparency = 1
warningLabel.Text = "Trigger Bot may not detect some players due to part hitboxes"
warningLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
warningLabel.Font = Enum.Font.Gotham
warningLabel.TextSize = 10
warningLabel.TextXAlignment = Enum.TextXAlignment.Left
warningLabel.Parent = mainFrame

local keybindLabel = Instance.new("TextLabel")
keybindLabel.Name = "KeybindLabel"
keybindLabel.Size = UDim2.new(1, -20, 0, 20)
keybindLabel.Position = UDim2.new(0, 10, 0, 280)
keybindLabel.BackgroundTransparency = 1
keybindLabel.Text = "Toggle GUI: Home | Toggle TriggerBot: T | Spread Control: B"
keybindLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
keybindLabel.Font = Enum.Font.Gotham
keybindLabel.TextSize = 10
keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
keybindLabel.Parent = mainFrame

-- UI Functions
local function updateUI()
    if settings.enabled then
        toggleButton.Text = "Disable Triggerbot"
        toggleButton.BackgroundColor3 = Color3.fromRGB(50, 120, 50)
    else
        toggleButton.Text = "Enable Triggerbot"
        toggleButton.BackgroundColor3 = Color3.fromRGB(120, 50, 50)
        if settings.triggerOn then
            settings.triggerOn = false
            if holdingMouse then
                mouse1release()
                holdingMouse = false
            end
        end
    end
    
    triggerStatusLabel.Text = "Active: " .. (settings.triggerOn and "ON (Press T)" or "OFF (Press T)")
    triggerStatusLabel.TextColor3 = settings.triggerOn and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    
    firstDelayTitle.Text = "First Shot Delay: " .. string.format("%.2f", settings.firstShotDelay) .. "s"
    firstDelayFill.Size = UDim2.new(settings.firstShotDelay, 0, 1, 0)
    
    delayTitle.Text = "Shot Delay: " .. string.format("%.2f", settings.shootDelay) .. "s"
    delayFill.Size = UDim2.new(settings.shootDelay, 0, 1, 0)
    
    spreadControlButton.Text = settings.spreadControlEnabled and "Spread Control: ON (B)" or "Spread Control: OFF (B)"
    spreadControlButton.BackgroundColor3 = settings.spreadControlEnabled and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(120, 50, 50)
    
    spreadIntervalTitle.Text = "Spread Interval: " .. string.format("%.1f", settings.spreadShotInterval) .. "s"
    spreadIntervalFill.Size = UDim2.new(settings.spreadShotInterval / 0.5, 0, 1, 0)
    
    spreadDistanceTitle.Text = "Max Spread: " .. string.format("%.0f", settings.maxSpreadDistance) .. "px"
    spreadDistanceFill.Size = UDim2.new(settings.maxSpreadDistance / 100, 0, 1, 0) -- Updated to 100px max
end

local function toggleUI()
    mainFrame.Visible = not mainFrame.Visible
    if mainFrame.Visible then
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        mainFrame.Position = lastPosition
        local tween = TweenService:Create(
            mainFrame,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 370, 0, 320)}
        )
        tween:Play()
    end
end

-- UI Interactions
toggleButton.MouseButton1Click:Connect(function()
    settings.enabled = not settings.enabled
    updateUI()
    
    if not settings.enabled and holdingMouse then
        mouse1release()
        holdingMouse = false
    end
end)

spreadControlButton.MouseButton1Click:Connect(function()
    settings.spreadControlEnabled = not settings.spreadControlEnabled
    updateUI()
end)

local function updateSlider(input, sliderType)
    local bar, maxValue
    if sliderType == "firstDelay" then
        bar = firstDelayBar
        maxValue = 1
    elseif sliderType == "delay" then
        bar = delayBar
        maxValue = 1
    elseif sliderType == "spreadInterval" then
        bar = spreadIntervalBar
        maxValue = 0.5
    elseif sliderType == "spreadDistance" then
        bar = spreadDistanceBar
        maxValue = 100 -- Updated to 100px max
    end
    
    local relativeX = input.Position.X - bar.AbsolutePosition.X
    local percentage = math.clamp(relativeX / bar.AbsoluteSize.X, 0, 1)
    local value = percentage * maxValue
    
    if sliderType == "firstDelay" then
        settings.firstShotDelay = value
    elseif sliderType == "delay" then
        settings.shootDelay = value
    elseif sliderType == "spreadInterval" then
        settings.spreadShotInterval = value
    elseif sliderType == "spreadDistance" then
        settings.maxSpreadDistance = value
    end
    
    updateUI()
end

firstDelayButton.MouseButton1Down:Connect(function()
    updateSlider({Position = UserInputService:GetMouseLocation()}, "firstDelay")
    
    local connection
    connection = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input, "firstDelay")
        end
    end)
    
    local releaseConnection
    releaseConnection = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            connection:Disconnect()
            releaseConnection:Disconnect()
        end
    end)
end)

delayButton.MouseButton1Down:Connect(function()
    updateSlider({Position = UserInputService:GetMouseLocation()}, "delay")
    
    local connection
    connection = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input, "delay")
        end
    end)
    
    local releaseConnection
    releaseConnection = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            connection:Disconnect()
            releaseConnection:Disconnect()
        end
    end)
end)

spreadIntervalButton.MouseButton1Down:Connect(function()
    updateSlider({Position = UserInputService:GetMouseLocation()}, "spreadInterval")
    
    local connection
    connection = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input, "spreadInterval")
        end
    end)
    
    local releaseConnection
    releaseConnection = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            connection:Disconnect()
            releaseConnection:Disconnect()
        end
    end)
end)

spreadDistanceButton.MouseButton1Down:Connect(function()
    updateSlider({Position = UserInputService:GetMouseLocation()}, "spreadDistance")
    
    local connection
    connection = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input, "spreadDistance")
        end
    end)
    
    local releaseConnection
    releaseConnection = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            connection:Disconnect()
            releaseConnection:Disconnect()
        end
    end)
end)

-- Triggerbot Logic
local holdingMouse = false
local manualShooting = false
local lastTargetPosition = nil
local lastTargetDistance = nil
local lastTargetTime = 0
local spreadControlHolding = false

local function isEnemy(player, character)
    if player and player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        return humanoid and humanoid.Health > 0
    end
    return false
end

local function getEnemyUnderCrosshair()
    local camera = workspace.CurrentCamera
    local origin = camera.CFrame.Position
    local direction = (Mouse.Hit.Position - origin).Unit * 1000

    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.IgnoreWater = true

    local maxIterations = 20
    local iterations = 0
    local result = workspace:Raycast(origin, direction, rayParams)

    while result and result.Instance and iterations < maxIterations do
        local inst = result.Instance
        local shouldPenetrate = inst.Transparency == 1 or 
                              (inst:IsA("BasePart") and not inst.CanCollide) or
                              (inst:IsA("UnionOperation") or inst:IsA("MeshPart")) and 
                              inst.CollisionFidelity ~= Enum.CollisionFidelity.Precise or
                              inst:IsA("TrussPart") or inst:IsA("Decal") or inst:IsA("Texture") or
                              inst.Massless or
                              inst.Name:lower():find("air") or inst.Name:lower():find("space") or
                              inst.Name:lower():find("gap") or inst.Name:lower():find("invis") or
                              inst.Name:lower():find("empty")

        if shouldPenetrate then
            table.insert(rayParams.FilterDescendantsInstances, inst)
            iterations += 1
            result = workspace:Raycast(origin, direction, rayParams)
        else
            break
        end
    end

    if result and result.Instance then
        local character = result.Instance:FindFirstAncestorOfClass("Model")
        local player = Players:GetPlayerFromCharacter(character)
        if isEnemy(player, character) then
            return true, result.Position, (result.Position - origin).Magnitude
        end
    end

    return false, nil, nil
end

local function shouldUseSpreadControl(targetPosition)
    if not settings.spreadControlEnabled then return false end
    
    local camera = workspace.CurrentCamera
    local screenPos = camera:WorldToScreenPoint(targetPosition)
    local mousePos = UserInputService:GetMouseLocation()
    local distFromCrosshair = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
    
    return distFromCrosshair > settings.maxSpreadDistance
end

local function handleShooting(currentTime, hasEnemy, enemyPosition, enemyDistance)
    if hasEnemy then
        if not settings.hasTarget then
            -- New target detected
            settings.hasTarget = true
            settings.targetDetectedTime = currentTime
            settings.firstShotFired = false
            holdingMouse = false
        end

        -- First shot delay check
        local firstDelayPassed = (currentTime - settings.targetDetectedTime) >= settings.firstShotDelay
        local regularDelayPassed = (currentTime - settings.lastShotTime) >= settings.shootDelay

        -- Main triggerbot shooting logic
        if (firstDelayPassed or settings.firstShotFired) and regularDelayPassed then
            if not holdingMouse then
                mouse1press()
                holdingMouse = true
            end
            settings.lastShotTime = currentTime
            settings.firstShotFired = true
            lastTargetPosition = enemyPosition
            lastTargetDistance = enemyDistance
        end

        -- Spread control logic - fires continuously when enabled and target is in range
        if settings.spreadControlEnabled and shouldUseSpreadControl(enemyPosition) then
            if not spreadControlHolding then
                mouse1press()
                spreadControlHolding = true
            end
        elseif spreadControlHolding then
            mouse1release()
            spreadControlHolding = false
        end
    else
        -- No target detected
        if holdingMouse then
            mouse1release()
            holdingMouse = false
        end
        if spreadControlHolding then
            mouse1release()
            spreadControlHolding = false
        end
        settings.hasTarget = false
    end
end

RunService.RenderStepped:Connect(function()
    local currentTime = tick()
    
    if settings.enabled and settings.triggerOn and not manualShooting then
        local hasEnemy, enemyPosition, enemyDistance = getEnemyUnderCrosshair()
        handleShooting(currentTime, hasEnemy, enemyPosition, enemyDistance)
    else
        if holdingMouse then
            mouse1release()
            holdingMouse = false
        end
        if spreadControlHolding then
            mouse1release()
            spreadControlHolding = false
        end
        settings.hasTarget = false
    end
end)

-- Initial UI update
updateUI()
