local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CheatGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui -- executor style

-- Main frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 120)
Frame.Position = UDim2.new(0, 20, 0, 20)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Visible = false
Frame.Parent = ScreenGui

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Cheat GUI"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 22
Title.Parent = Frame

-- ESP toggle button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 180, 0, 40)
ToggleButton.Position = UDim2.new(0, 20, 0, 50)
ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.Font = Enum.Font.SourceSansSemibold
ToggleButton.TextSize = 18
ToggleButton.Text = "Toggle ESP: OFF"
ToggleButton.Parent = Frame

-- ESP logic
local ESPEnabled = false
local ESPColor = Color3.new(1, 0, 0)
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
            if not Boxes[player] then
                Boxes[player] = createBox(player)
            end
            Boxes[player].Adornee = player.Character.HumanoidRootPart
            Boxes[player].Color3 = ESPColor
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

-- Show/hide GUI with Right Alt
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightAlt then
        Frame.Visible = not Frame.Visible
    end
end)

print("Cheat GUI loaded. Press Right Alt to toggle GUI.")
