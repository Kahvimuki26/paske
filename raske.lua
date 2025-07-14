-- Customizable ESP Script for Arsenal-style game

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESPColor = Color3.new(1, 0, 0)
local ESPEnabled = true
local Boxes = {}

-- Create a box for a player
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

-- Update boxes every frame
RunService.RenderStepped:Connect(function()
    if not ESPEnabled then
        for _, box in pairs(Boxes) do
            box:Destroy()
        end
        Boxes = {}
        return
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not Boxes[player] then
                Boxes[player] = createBox(player)
            end
            Boxes[player].Adornee = player.Character.HumanoidRootPart
            Boxes[player].Color3 = ESPColor
        elseif Boxes[player] then
            Boxes[player]:Destroy()
            Boxes[player] = nil
        end
    end
end)

print("ESP Loaded. Use ESPEnabled = false to disable.")
