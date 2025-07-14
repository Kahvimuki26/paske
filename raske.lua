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
Frame.Size = UDim2.new(0, 260, 0, 220)
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

-- Toggle Button
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

-- Dropdown for color
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

-- ESP logic
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

local lastUpdate = 0

RunService.RenderStepped:Connect(function(dt)
    if ESPEnabled then
        lastUpdate = lastUpdate + dt
        if lastUpdate >= 10 then -- update every 10 seconds
            updateBoxes()
            lastUpdate = 0
        end
    else
        for _, box in pairs(Boxes) do
            box:Destroy()
        end
        Boxes = {}
        lastUpdate = 0
    end
end)


ToggleButton.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    ToggleButton.Text = "Toggle ESP: " .. (ESPEnabled and "ON" or "OFF")
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightAlt then
        Frame.Visible = not Frame.Visible
    end
end)

print("Modern Cheat GUI loaded. Press Right Alt to toggle.")
