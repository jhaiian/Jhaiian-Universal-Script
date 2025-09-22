--// Services & Player Setup
local player = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local VirtualUser = game:GetService('VirtualUser')
local HttpService = game:GetService("HttpService")

-- Default humanoid values
local DEFAULT_SPEED = 16
local DEFAULT_JUMP = 50

-- Store settings
local currentWalkSpeed = DEFAULT_SPEED
local currentJumpPower = DEFAULT_JUMP
local infiniteJumpEnabled = false
local antiAfkEnabled = false
local guiActive = true

-- Store original values to restore when GUI closes
local originalWalkSpeed = DEFAULT_SPEED
local originalJumpPower = DEFAULT_JUMP

-- Anti-AFK connection
local antiAfkConnection = nil

-- Configuration paths
local configFolder = "Jhaiian"
local configFileName = "Jhaiian Universal Script.json"
local configPath = configFolder .. "/" .. configFileName

--// Configuration Management Functions
local function saveConfig()
    local config = {
        WalkSpeed = currentWalkSpeed,
        JumpPower = currentJumpPower,
        InfiniteJump = infiniteJumpEnabled,
        AntiAFK = antiAfkEnabled
    }
    
    local success, err = pcall(function()
        -- Create folder if it doesn't exist
        if not isfolder(configFolder) then
            makefolder(configFolder)
        end
        
        -- Write configuration to file
        writefile(configPath, HttpService:JSONEncode(config))
    end)
    
    if not success then
        warn("Failed to save configuration: " .. tostring(err))
    end
end

local function loadConfig()
    local success, config = pcall(function()
        if isfile(configPath) then
            return HttpService:JSONDecode(readfile(configPath))
        end
        return nil
    end)
    
    if success and config then
        -- Apply loaded configuration
        currentWalkSpeed = config.WalkSpeed or DEFAULT_SPEED
        currentJumpPower = config.JumpPower or DEFAULT_JUMP
        infiniteJumpEnabled = config.InfiniteJump or false
        antiAfkEnabled = config.AntiAFK or false
        
        -- Apply Anti-AFK setting if enabled
        if antiAfkEnabled then
            toggleAntiAfk(true)
        end
        
        return true
    end
    
    return false
end

--// GUI Initialization
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "jhaiianUniversalMobileFixed"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

--// Mobile detection
local isMobile = uis.TouchEnabled and not uis.MouseEnabled
if isMobile then
    DEFAULT_SPEED = 20
    DEFAULT_JUMP = 60
    currentWalkSpeed = DEFAULT_SPEED
    currentJumpPower = DEFAULT_JUMP
end

--// Get humanoid and apply current settings
local function getHumanoid()
    local success, humanoid = pcall(function()
        local char = player.Character or player.CharacterAdded:Wait()
        local hum = char:WaitForChild("Humanoid")
        
        -- Store original values if we haven't already
        if originalWalkSpeed == DEFAULT_SPEED then
            originalWalkSpeed = hum.WalkSpeed
        end
        if originalJumpPower == DEFAULT_JUMP then
            originalJumpPower = hum.JumpPower
        end
        
        -- Apply current settings if GUI is active
        if guiActive then
            hum.WalkSpeed = currentWalkSpeed
            hum.JumpPower = currentJumpPower
        end
        
        return hum
    end)
    
    return success and humanoid or nil
end

-- Function to reset character to original values
local function resetCharacter()
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.WalkSpeed = originalWalkSpeed
        humanoid.JumpPower = originalJumpPower
    end
    infiniteJumpEnabled = false
    
    -- Disable Anti-AFK
    if antiAfkConnection then
        antiAfkConnection:Disconnect()
        antiAfkConnection = nil
    end
    antiAfkEnabled = false
end

-- Function to toggle Anti-AFK
local function toggleAntiAfk(enabled)
    antiAfkEnabled = enabled
    
    if antiAfkConnection then
        antiAfkConnection:Disconnect()
        antiAfkConnection = nil
    end
    
    if enabled then
        antiAfkConnection = player.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end

-- Set up character added event to apply current settings
player.CharacterAdded:Connect(function(character)
    if guiActive then
        -- If GUI is active, apply current settings to new character
        character:WaitForChild("Humanoid").WalkSpeed = currentWalkSpeed
        character:WaitForChild("Humanoid").JumpPower = currentJumpPower
    else
        -- If GUI is closed, reset the new character
        resetCharacter()
    end
end)

-- Load configuration before creating GUI
loadConfig()

-- Get original values immediately
getHumanoid()

--// Main Frame (container)
local mainFrame = Instance.new("Frame")
mainFrame.Size = isMobile and UDim2.new(0, 400, 0, 450) or UDim2.new(0, 350, 0, 400)
mainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 20, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Rounded corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

--// Title bar
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, isMobile and 50 or 40)
title.BackgroundColor3 = Color3.fromRGB(20, 40, 80)
title.BorderSizePixel = 0
title.Text = "⚡ Jhaiian Universal Script ⚡"
title.TextColor3 = Color3.fromRGB(0, 200, 255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = title

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 10)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextScaled = true
closeButton.Parent = title
closeButton.ZIndex = 2

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 15)
closeCorner.Parent = closeButton

-- Close GUI logic with reset functionality
closeButton.MouseButton1Click:Connect(function()
    -- Reset player properties to original values
    resetCharacter()
    guiActive = false
    
    -- Remove the GUI
    screenGui:Destroy()
end)

--// Container for all interactive elements
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, 0, 1, -title.AbsoluteSize.Y)
contentContainer.Position = UDim2.new(0, 0, 0, title.AbsoluteSize.Y)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainFrame

-- Add padding to the content container to space out elements
local containerPadding = Instance.new("UIPadding")
containerPadding.PaddingTop = UDim.new(0, 10)
containerPadding.PaddingBottom = UDim.new(0, 10)
containerPadding.Parent = contentContainer

--// Reusable Slider Creator
local function createSlider(name, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, isMobile and 80 or 70)
    frame.BackgroundColor3 = Color3.fromRGB(25, 50, 90)
    frame.Parent = contentContainer
    
    -- Add margin bottom to create space between elements
    local margin = Instance.new("UIPadding")
    margin.PaddingBottom = UDim.new(0, 15) -- Bottom margin
    margin.Parent = frame
    
    -- Rounded corners
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 6)
    frameCorner.Parent = frame

    -- Add padding inside the frame
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 5)
    padding.PaddingBottom = UDim.new(0, 5)
    padding.PaddingLeft = UDim.new(0, 5)
    padding.PaddingRight = UDim.new(0, 5)
    padding.Parent = frame

    -- Label for slider name
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.7, 0, 0.4, 0)
    title.BackgroundTransparency = 1
    title.Text = name
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = isMobile and Enum.Font.GothamBold or Enum.Font.Gotham
    title.TextScaled = true
    title.Parent = frame

    -- Value display
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.3, 0, 0.4, 0)
    valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextScaled = true
    valueLabel.Parent = frame

    -- Slider bar
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -20, 0.3, 0)
    bar.Position = UDim2.new(0, 10, 0.6, 0)
    bar.BackgroundColor3 = Color3.fromRGB(60, 80, 120)
    bar.Parent = frame
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 4)
    barCorner.Parent = bar

    -- Slider knob
    local knob = Instance.new("Frame")
    knob.Size = isMobile and UDim2.new(0, 25, 1.5, 0) or UDim2.new(0, 20, 1.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    knob.Parent = bar
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(0, 4)
    knobCorner.Parent = knob

    -- Slider interaction
    local dragging = false
    local function update(input)
        local relativeX = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        knob.Position = UDim2.new(relativeX, -knob.AbsoluteSize.X/2, -0.25, 0)
        local value = math.floor(0 + 100 * relativeX)
        valueLabel.Text = tostring(value)
        callback(value)
    end

    -- Input handling
    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mainFrame.Draggable = false
            update(input)
        end
    end
    local function onInputEnded(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            mainFrame.Draggable = true
        end
    end
    local function onInputChanged(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end

    -- Event connections
    bar.InputBegan:Connect(onInputBegan)
    knob.InputBegan:Connect(onInputBegan)
    uis.InputEnded:Connect(onInputEnded)
    uis.InputChanged:Connect(onInputChanged)

    -- Set initial knob position
    knob.Position = UDim2.new(default / 100, -knob.AbsoluteSize.X/2, -0.25, 0)
    callback(default)
    
    return frame
end

--// Reusable Toggle Button Creator
local function createToggleButton(text, initialState, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9, 0, 0, isMobile and 50 or 45)
    button.BackgroundColor3 = Color3.fromRGB(25, 50, 90)
    button.Text = text .. ": " .. (initialState and "ON" or "OFF")
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextScaled = true
    button.Parent = contentContainer
    
    -- Add margin bottom to create space between elements
    local margin = Instance.new("UIPadding")
    margin.PaddingBottom = UDim.new(0, 15) -- Bottom margin
    margin.Parent = button
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = button
    
    -- Add padding to button
    local buttonPadding = Instance.new("UIPadding")
    buttonPadding.PaddingTop = UDim.new(0, 5)
    buttonPadding.PaddingBottom = UDim.new(0, 5)
    buttonPadding.Parent = button
    
    -- Set initial color
    button.BackgroundColor3 = initialState and Color3.fromRGB(40, 100, 60) or Color3.fromRGB(25, 50, 90)
    
    button.MouseButton1Click:Connect(function()
        local newState = not initialState
        initialState = newState
        button.Text = text .. ": " .. (newState and "ON" or "OFF")
        button.BackgroundColor3 = newState and Color3.fromRGB(40, 100, 60) or Color3.fromRGB(25, 50, 90)
        callback(newState)
    end)
    
    return button
end

-- Create UI Layout with proper spacing
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 15) -- Space between elements
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Top
layout.Parent = contentContainer

-- Walk Speed Slider
local walkSpeedSlider = createSlider("Walk Speed", currentWalkSpeed, function(value)
    currentWalkSpeed = (value == 0) and DEFAULT_SPEED or value
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.WalkSpeed = currentWalkSpeed
    end
    saveConfig() -- Save configuration when changed
end)

-- Jump Power Slider
local jumpPowerSlider = createSlider("Jump Power", currentJumpPower, function(value)
    currentJumpPower = (value == 0) and DEFAULT_JUMP or value
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.JumpPower = currentJumpPower
    end
    saveConfig() -- Save configuration when changed
end)

-- Infinite Jump Toggle Button
local infiniteJumpButton = createToggleButton("Infinite Jump", infiniteJumpEnabled, function(state)
    infiniteJumpEnabled = state
    saveConfig() -- Save configuration when changed
end)

-- Anti-AFK Toggle Button
local antiAfkButton = createToggleButton("Anti-AFK", antiAfkEnabled, function(state)
    antiAfkEnabled = state
    toggleAntiAfk(state)
    saveConfig() -- Save configuration when changed
end)

-- Allow infinite jumps if toggle is ON
uis.JumpRequest:Connect(function()
    if infiniteJumpEnabled and guiActive then
        local humanoid = getHumanoid()
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

--// Mobile-specific extras: Minimize Button & Auto screen adjustment
if isMobile then
    -- Minimize button
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    minimizeBtn.Position = UDim2.new(1, -75, 0, 10)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    minimizeBtn.Text = "_"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextScaled = true
    minimizeBtn.Parent = title

    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 15)
    minimizeCorner.Parent = minimizeBtn
    
    local minimized = false
    local originalSize = mainFrame.Size
    
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            contentContainer.Visible = false
            mainFrame.Size = UDim2.new(0, title.AbsoluteSize.X, 0, title.AbsoluteSize.Y)
            minimizeBtn.Text = "+"
        else
            contentContainer.Visible = true
            mainFrame.Size = originalSize
            minimizeBtn.Text = "_"
        end
    end)

    -- Keep GUI inside screen bounds
    local function ensureOnScreen()
        local viewportSize = workspace.CurrentCamera.ViewportSize
        local absolutePosition = mainFrame.AbsolutePosition
        local absoluteSize = mainFrame.AbsoluteSize
        
        if absolutePosition.X + absoluteSize.X > viewportSize.X then
            mainFrame.Position = UDim2.new(0, viewportSize.X - absoluteSize.X - 10, mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset)
        end
        if absolutePosition.Y + absoluteSize.Y > viewportSize.Y then
            mainFrame.Position = UDim2.new(mainFrame.Position.X.Scale, mainFrame.Position.X.Offset, 0, viewportSize.Y - absoluteSize.Y - 10)
        end
        if absolutePosition.X < 0 then
            mainFrame.Position = UDim2.new(0, 10, mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset)
        end
        if absolutePosition.Y < 0 then
            mainFrame.Position = UDim2.new(mainFrame.Position.X.Scale, mainFrame.Position.X.Offset, 0, 10)
        end
    end
    task.wait(0.5)
    ensureOnScreen()
end