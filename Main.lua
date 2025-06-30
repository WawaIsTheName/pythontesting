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
    triggerOn = true, -- Automatically turn on when script starts
    toggleKey = Enum.KeyCode.Home,
    triggerToggleKey = Enum.KeyCode.T,
    shootDelay = 0, -- Default delay between shots in seconds
    firstShotDelay = 0.03, -- Changed to 0.03 as requested
    lastShotTime = 0,
    targetDetectedTime = 0,
    hasTarget = false
}

-- UI Creation
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TriggerBotUI"
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 240, 0, 200) -- Increased height for new warning label
mainFrame.Position = UDim2.new(0.5, -110, 0.5, -90)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

-- Make frame draggable
local dragging
local dragInput
local dragStart
local startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
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
toggleButton.Text = "Enable Triggerbot"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.Gotham
toggleButton.TextSize = 12
toggleButton.Parent = mainFrame

local triggerStatusLabel = Instance.new("TextLabel")
triggerStatusLabel.Name = "TriggerStatusLabel"
triggerStatusLabel.Size = UDim2.new(1, -20, 0, 20)
triggerStatusLabel.Position = UDim2.new(0, 10, 0, 65)
triggerStatusLabel.BackgroundTransparency = 1
triggerStatusLabel.Text = "Active: ON (Press T)" -- Changed to ON by default
triggerStatusLabel.TextColor3 = Color3.fromRGB(50, 255, 50) -- Green since it's on by default
triggerStatusLabel.Font = Enum.Font.Gotham
triggerStatusLabel.TextSize = 12
triggerStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
triggerStatusLabel.Parent = mainFrame

-- First Shot Delay slider
local firstDelaySlider = Instance.new("Frame")
firstDelaySlider.Name = "FirstDelaySlider"
firstDelaySlider.Size = UDim2.new(0.9, 0, 0, 30)
firstDelaySlider.Position = UDim2.new(0.05, 0, 0, 90)
firstDelaySlider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
firstDelaySlider.BorderSizePixel = 0
firstDelaySlider.Parent = mainFrame

local firstDelayTitle = Instance.new("TextLabel")
firstDelayTitle.Name = "FirstDelayTitle"
firstDelayTitle.Size = UDim2.new(1, 0, 0.5, 0)
firstDelayTitle.Position = UDim2.new(0, 0, 0, 0)
firstDelayTitle.BackgroundTransparency = 1
firstDelayTitle.Text = "First Shot Delay: 0.03s" -- Updated to show 0.03 by default
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
firstDelayFill.Size = UDim2.new(0.03, 0, 1, 0) -- Set to 0.03 by default
firstDelayFill.Position = UDim2.new(0, 0, 0, 0)
firstDelayFill.BackgroundColor3 = Color3.fromRGB(255, 150, 0) -- Orange color for first shot delay
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
delaySlider.Position = UDim2.new(0.05, 0, 0, 125)
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
delayFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255) -- Blue color for regular delay
delayFill.BorderSizePixel = 0
delayFill.Parent = delayBar

local delayButton = Instance.new("TextButton")
delayButton.Name = "DelayButton"
delayButton.Size = UDim2.new(1, 0, 0.5, 0)
delayButton.Position = UDim2.new(0, 0, 0.5, 5)
delayButton.BackgroundTransparency = 1
delayButton.Text = ""
delayButton.Parent = delaySlider

-- Added warning label
local warningLabel = Instance.new("TextLabel")
warningLabel.Name = "WarningLabel"
warningLabel.Size = UDim2.new(1, -20, 0, 20)
warningLabel.Position = UDim2.new(0, 10, 0, 160)
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
keybindLabel.Position = UDim2.new(0, 10, 0, 180)
keybindLabel.BackgroundTransparency = 1
keybindLabel.Text = "Toggle GUI: Home | Toggle TriggerBot: T"
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
        -- When disabling via button, also turn off trigger
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
end

local function toggleUI()
    mainFrame.Visible = not mainFrame.Visible
    if mainFrame.Visible then
        -- Animate appearance
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        local tween = TweenService:Create(
            mainFrame,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 220, 0, 200), Position = UDim2.new(0.5, -110, 0.5, -100)}
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

local function updateSlider(input, sliderType)
    local bar = sliderType == "firstDelay" and firstDelayBar or delayBar
    local relativeX = input.Position.X - bar.AbsolutePosition.X
    local percentage = math.clamp(relativeX / bar.AbsoluteSize.X, 0, 1)
    
    if sliderType == "firstDelay" then
        settings.firstShotDelay = percentage
    else
        settings.shootDelay = percentage
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

-- Triggerbot Logic
local holdingMouse = false
local manualShooting = false

UserInputService.InputBegan:Connect(function(input, isProcessed)
    if not isProcessed then
        -- Toggle UI
        if input.KeyCode == settings.toggleKey then
            toggleUI()
        end
        
        -- Toggle triggerbot on/off when enabled
        if settings.enabled and input.KeyCode == settings.triggerToggleKey then
            settings.triggerOn = not settings.triggerOn
            settings.hasTarget = false -- Reset target detection when toggling
            updateUI()
            if not settings.triggerOn and holdingMouse then
                mouse1release()
                holdingMouse = false
            end
        end
    end

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        manualShooting = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        manualShooting = false
    end
end)

local function isEnemy(player, character)
    if player and player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 then
            return true
        end
    end
    return false
end

local function isEnemyUnderCrosshair()
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
        local isStandardPart = inst:IsA("BasePart")
        local isUnionOrMesh = inst:IsA("UnionOperation") or inst:IsA("MeshPart")
        
        local shouldPenetrate =
            inst.Transparency == 1 or
            (isStandardPart and not inst.CanCollide) or
            (isUnionOrMesh and inst.CollisionFidelity ~= Enum.CollisionFidelity.Precise) or
            inst:IsA("TrussPart") or
            inst:IsA("Decal") or inst:IsA("Texture") or
            inst.Massless or
            (inst.Name:lower():find("air") or
             inst.Name:lower():find("space") or
             inst.Name:lower():find("gap") or
             inst.Name:lower():find("invis") or
             inst.Name:lower():find("empty"))

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
            return true
        end
    end

    return false
end

RunService.RenderStepped:Connect(function()
    if settings.enabled and settings.triggerOn and not manualShooting then
        local currentTime = tick()
        local hasEnemy = isEnemyUnderCrosshair()
        
        if hasEnemy then
            if not settings.hasTarget then
                -- First time detecting target
                settings.hasTarget = true
                settings.targetDetectedTime = currentTime
            end
            
            -- Check if first shot delay has passed
            local firstDelayPassed = (currentTime - settings.targetDetectedTime) >= settings.firstShotDelay
            -- Check if regular delay has passed since last shot
            local regularDelayPassed = (currentTime - settings.lastShotTime) >= settings.shootDelay
            
            if firstDelayPassed and regularDelayPassed then
                if not holdingMouse then
                    mouse1press()
                    holdingMouse = true
                end
                settings.lastShotTime = currentTime
            end
        else
            settings.hasTarget = false
            if holdingMouse then
                mouse1release()
                holdingMouse = false
            end
        end
    else
        settings.hasTarget = false
        if holdingMouse then
            mouse1release()
            holdingMouse = false
        end
    end
end)

-- Initial UI update
updateUI()
