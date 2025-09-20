--// Services & Player Setup
local player = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local runService = game:GetService("RunService")

-- Default humanoid values
local DEFAULT_SPEED = 16
local DEFAULT_JUMP = 50

--// GUI Initialization
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "jhaiianUniversalMobileFixed" -- Unique identifier
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false -- Prevents GUI from disappearing on respawn

--// Mobile detection (adjust defaults for touch devices)
local isMobile = uis.TouchEnabled and not uis.MouseEnabled
if isMobile then
    DEFAULT_SPEED = 20
    DEFAULT_JUMP = 60
end

--// Main Frame (container)
local mainFrame = Instance.new("Frame")
mainFrame.Size = isMobile and UDim2.new(0, 400, 0, 350) or UDim2.new(0, 350, 0, 300)
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

-- Close GUI logic
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

--// Container for all interactive elements
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, 0, 1, -title.AbsoluteSize.Y)
contentContainer.Position = UDim2.new(0, 0, 0, title.AbsoluteSize.Y)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainFrame

--// Reusable Slider Creator
local function createSlider(name, posY, default, callback)
    -- Frame container for each slider
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, isMobile and 80 or 70)
    frame.Position = UDim2.new(0.05, 0, posY, 0)
    frame.BackgroundColor3 = Color3.fromRGB(25, 50, 90)
    frame.Parent = contentContainer
    
    -- Rounded corners
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 6)
    frameCorner.Parent = frame

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
end

--// Helper: Get Humanoid safely
local function getHumanoid()
    local success, humanoid = pcall(function()
        local char = player.Character or player.CharacterAdded:Wait()
        return char:WaitForChild("Humanoid")
    end)
    return success and humanoid or nil
end

-- Walk Speed Slider
createSlider("Walk Speed", 0.2, DEFAULT_SPEED, function(value)
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.WalkSpeed = (value == 0) and DEFAULT_SPEED or value
    end
end)

-- Jump Power Slider
createSlider("Jump Power", 0.45, DEFAULT_JUMP, function(value)
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.JumpPower = (value == 0) and DEFAULT_JUMP or value
    end
end)

--// Infinite Jump Toggle Button
local infBtn = Instance.new("TextButton")
infBtn.Size = UDim2.new(0.9, 0, 0, isMobile and 60 or 50)
infBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
infBtn.BackgroundColor3 = Color3.fromRGB(25, 50, 90)
infBtn.Text = "Infinite Jump: OFF"
infBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
infBtn.Font = Enum.Font.GothamBold
infBtn.TextScaled = true
infBtn.Parent = contentContainer

local infBtnCorner = Instance.new("UICorner")
infBtnCorner.CornerRadius = UDim.new(0, 6)
infBtnCorner.Parent = infBtn

local infiniteJump = false
infBtn.MouseButton1Click:Connect(function()
    infiniteJump = not infiniteJump
    infBtn.Text = "Infinite Jump: " .. (infiniteJump and "ON" or "OFF")
    infBtn.BackgroundColor3 = infiniteJump and Color3.fromRGB(40, 100, 60) or Color3.fromRGB(25, 50, 90)
end)

-- Allow infinite jumps if toggle is ON
uis.JumpRequest:Connect(function()
    if infiniteJump then
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
