local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CheatGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

-- UI Styling Helper
local function styleFrame(frame)
    frame.BackgroundColor3 = Color3.fromRGB(40, 35, 60)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Active = true

    local uicorner = Instance.new("UICorner")
    uicorner.CornerRadius = UDim.new(0, 10)
    uicorner.Parent = frame
end

-- Main Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 260, 0, 390) -- extended height for new controls
Frame.Position = UDim2.new(0, 20, 0, 20)
Frame.Visible = false
Frame.Parent = ScreenGui
styleFrame(Frame)

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "ESP Cheat Menu"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = Frame

-- Toggle ESP Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 220, 0, 35)
ToggleButton.Position = UDim2.new(0, 20, 0, 40)
ToggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 100)
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.Font = Enum.Font.Gotham
ToggleButton.TextSize = 16
ToggleButton.Text = "Toggle ESP: OFF"
ToggleButton.Parent = Frame
styleFrame(ToggleButton)

-- Team Check Toggle
local TeamCheck = false
local TeamToggle = Instance.new("TextButton")
TeamToggle.Size = UDim2.new(0, 220, 0, 30)
TeamToggle.Position = UDim2.new(0, 20, 0, 80)
TeamToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
TeamToggle.TextColor3 = Color3.new(1, 1, 1)
TeamToggle.Font = Enum.Font.Gotham
TeamToggle.TextSize = 14
TeamToggle.Text = "Team Check: OFF"
TeamToggle.Parent = Frame
styleFrame(TeamToggle)

TeamToggle.MouseButton1Click:Connect(function()
    TeamCheck = not TeamCheck
    TeamToggle.Text = "Team Check: " .. (TeamCheck and "ON" or "OFF")
end)

-- ESP Color Label & Dropdown
local ColorLabel = Instance.new("TextLabel")
ColorLabel.Size = UDim2.new(0, 220, 0, 20)
ColorLabel.Position = UDim2.new(0, 20, 0, 120)
ColorLabel.BackgroundTransparency = 1
ColorLabel.Text = "ESP Color:"
ColorLabel.Font = Enum.Font.Gotham
ColorLabel.TextSize = 14
ColorLabel.TextColor3 = Color3.new(1, 1, 1)
ColorLabel.Parent = Frame

local ColorDropdown = Instance.new("TextButton")
ColorDropdown.Size = UDim2.new(0, 220, 0, 30)
ColorDropdown.Position = UDim2.new(0, 20, 0, 140)
ColorDropdown.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
ColorDropdown.TextColor3 = Color3.new(1, 1, 1)
ColorDropdown.Font = Enum.Font.Gotham
ColorDropdown.TextSize = 14
ColorDropdown.Text = "Red"
ColorDropdown.Parent = Frame
styleFrame(ColorDropdown)

local ColorOptions = {
    Red = Color3.new(1, 0, 0),
    Green = Color3.new(0, 1, 0),
    Blue = Color3.new(0, 0, 1),
    Yellow = Color3.fromRGB(255, 255, 0),
    White = Color3.new(1, 1, 1)
}
local ESPColor = ColorOptions["Red"]

ColorDropdown.MouseButton1Click:Connect(function()
    local keys = {}
    for k in pairs(ColorOptions) do table.insert(keys, k) end
    local current = table.find(keys, ColorDropdown.Text) or 1
    local nextColor = keys[(current % #keys) + 1]
    ColorDropdown.Text = nextColor
    ESPColor = ColorOptions[nextColor]
end)

-- ESP Logic
local ESPEnabled = false
local Boxes = {}

local function createBox(player)
    local box = Instance.new("BoxHandleAdornment")
    box.Adornee = nil
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Transparency = 0.5
    box.Color3 = ESPColor
    box.Size = Vector3.new(4, 6, 4)
    box.Parent = Camera
    return box
end

local function updateBoxes()
    for p, box in pairs(Boxes) do
        if not p.Parent or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then
            box:Destroy()
            Boxes[p] = nil
        end
    end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not TeamCheck or player.Team ~= LocalPlayer.Team then
                if not Boxes[player] then
                    Boxes[player] = createBox(player)
                end
                Boxes[player].Adornee = player.Character.HumanoidRootPart
                Boxes[player].Color3 = ESPColor
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    if ESPEnabled then
        updateBoxes()
    else
        for _, box in pairs(Boxes) do
            box:Destroy()
        end
        Boxes = {}
    end
end)

ToggleButton.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    ToggleButton.Text = "Toggle ESP: " .. (ESPEnabled and "ON" or "OFF")
end)

-- ======= Aimbot Variables =======
local AimbotEnabled = false
local AimbotTargetPart = "Head" -- default
local AimbotFOV = 100 -- max pixels from center
local AimbotSmoothness = 0.2 -- 0 = instant, 1 = slow

-- Function to get closest target part within FOV
local function getClosestTarget()
    local closestPlayer = nil
    local shortestDistance = AimbotFOV

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer
           and player.Character
           and player.Character:FindFirstChild(AimbotTargetPart)
           and (not TeamCheck or player.Team ~= LocalPlayer.Team) then

            local part = player.Character[AimbotTargetPart]
            local screenPoint, onScreen = Camera:WorldToViewportPoint(part.Position)

            if onScreen then
                local dist = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    closestPlayer = part
                end
            end
        end
    end

    return closestPlayer
end

-- Aimbot update loop
RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local target = getClosestTarget()
        if target then
            local dir = (target.Position - Camera.CFrame.Position).Unit
            local desiredCFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + dir)
            Camera.CFrame = Camera.CFrame:Lerp(desiredCFrame, AimbotSmoothness)
        end
    end
end)

-- Aimbot Toggle Button
local AimbotButton = Instance.new("TextButton")
AimbotButton.Size = UDim2.new(0, 220, 0, 30)
AimbotButton.Position = UDim2.new(0, 20, 0, 180)
AimbotButton.BackgroundColor3 = Color3.fromRGB(100, 60, 100)
AimbotButton.TextColor3 = Color3.new(1, 1, 1)
AimbotButton.Font = Enum.Font.Gotham
AimbotButton.TextSize = 14
AimbotButton.Text = "Aimbot: OFF"
AimbotButton.Parent = Frame
styleFrame(AimbotButton)

AimbotButton.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    AimbotButton.Text = "Aimbot: " .. (AimbotEnabled and "ON" or "OFF")
    AimbotButton.BackgroundColor3 = AimbotEnabled and Color3.fromRGB(140, 90, 140) or Color3.fromRGB(100, 60, 100)
end)

-- Aimbot Target Part Dropdown Label
local TargetLabel = Instance.new("TextLabel")
TargetLabel.Size = UDim2.new(0, 220, 0, 20)
TargetLabel.Position = UDim2.new(0, 20, 0, 220)
TargetLabel.BackgroundTransparency = 1
TargetLabel.Text = "Aimbot Target:"
TargetLabel.Font = Enum.Font.Gotham
TargetLabel.TextSize = 14
TargetLabel.TextColor3 = Color3.new(1, 1, 1)
TargetLabel.Parent = Frame

-- Aimbot Target Part Dropdown Button
local TargetDropdown = Instance.new("TextButton")
TargetDropdown.Size = UDim2.new(0, 220, 0, 30)
TargetDropdown.Position = UDim2.new(0, 20, 0, 240)
TargetDropdown.BackgroundColor3 = Color3.fromRGB(70, 70, 100)
TargetDropdown.TextColor3 = Color3.new(1, 1, 1)
TargetDropdown.Font = Enum.Font.Gotham
TargetDropdown.TextSize = 14
TargetDropdown.Text = AimbotTargetPart
TargetDropdown.Parent = Frame
styleFrame(TargetDropdown)

local TargetParts = { "Head", "HumanoidRootPart" }
TargetDropdown.MouseButton1Click:Connect(function()
    local current = table.find(TargetParts, TargetDropdown.Text) or 1
    local nextPart = TargetParts[(current % #TargetParts) + 1]
    TargetDropdown.Text = nextPart
    AimbotTargetPart = nextPart
end)

-- FOV Label
local FOVLabel = Instance.new("TextLabel")
FOVLabel.Size = UDim2.new(0, 220, 0, 20)
FOVLabel.Position = UDim2.new(0, 20, 0, 280)
FOVLabel.BackgroundTransparency = 1
FOVLabel.Text = "FOV: " .. AimbotFOV
FOVLabel.Font = Enum.Font.Gotham
FOVLabel.TextSize = 14
FOVLabel.TextColor3 = Color3.new(1, 1, 1)
FOVLabel.Parent = Frame

-- FOV Slider (simulated with a frame button)
local FOVSlider = Instance.new("TextButton")
FOVSlider.Size = UDim2.new(0, 220, 0, 10)
FOVSlider.Position = UDim2.new(0, 20, 0, 300)
FOVSlider.BackgroundColor3 = Color3.fromRGB(90, 90, 130)
FOVSlider.Text = ""
FOVSlider.AutoButtonColor = false
FOVSlider.Parent = Frame
styleFrame(FOVSlider)

local draggingFOV = false
local function updateFOVSlider(input)
    local pos = math.clamp((input.Position.X - FOVSlider.AbsolutePosition.X) / FOVSlider.AbsoluteSize.X, 0, 1)
    AimbotFOV = math.floor(pos * 300) -- max 300 px
    FOVLabel.Text = "FOV: " .. AimbotFOV
end

FOVSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingFOV = true
        updateFOVSlider(input)
    end
end)

FOVSlider.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingFOV = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingFOV and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateFOVSlider(input)
    end
end)

-- Smoothness Label
local SmoothLabel = Instance.new("TextLabel")
SmoothLabel.Size = UDim2.new(0, 220, 0, 20)
SmoothLabel.Position = UDim2.new(0, 20, 0, 320)
SmoothLabel.BackgroundTransparency = 1
SmoothLabel.Text = "Smoothness: " .. tostring(AimbotSmoothness)
SmoothLabel.Font = Enum.Font.Gotham
SmoothLabel.TextSize = 14
SmoothLabel.TextColor3 = Color3.new(1, 1, 1)
SmoothLabel.Parent = Frame

-- Smoothness Slider
local SmoothSlider = Instance.new("TextButton")
SmoothSlider.Size = UDim2.new(0, 220, 0, 10)
SmoothSlider.Position = UDim2.new(0, 20, 0, 340)
SmoothSlider.BackgroundColor3 = Color3.fromRGB(90, 90, 130)
SmoothSlider.Text = ""
SmoothSlider.AutoButtonColor = false
SmoothSlider.Parent = Frame
styleFrame(SmoothSlider)

local draggingSmooth = false
local function updateSmoothSlider(input)
    local pos = math.clamp((input.Position.X - SmoothSlider.AbsolutePosition.X) / SmoothSlider.AbsoluteSize.X, 0, 1)
    AimbotSmoothness = tonumber(string.format("%.2f", pos))
    SmoothLabel.Text = "Smoothness: " .. AimbotSmoothness
end

SmoothSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSmooth = true
        updateSmoothSlider(input)
    end
end)

SmoothSlider.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSmooth = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingSmooth and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateSmoothSlider(input)
    end
end)

-- GUI toggle hotkey
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightAlt then
        Frame.Visible = not Frame.Visible
    end
end)

print("Modern Cheat GUI loaded. Press Right Alt to toggle.")
