-- ARSENAL SILENT AIM + GUI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local SilentAimEnabled = false

-- UI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "SilentAimGUI"
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 150, 0, 50)
Frame.Position = UDim2.new(0, 50, 0, 100)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.Active = true
Frame.Draggable = true

local Button = Instance.new("TextButton", Frame)
Button.Size = UDim2.new(1, 0, 1, 0)
Button.Text = "Silent Aim: OFF"
Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Button.TextColor3 = Color3.new(1,1,1)
Button.Font = Enum.Font.GothamBold
Button.TextScaled = true

Button.MouseButton1Click:Connect(function()
    SilentAimEnabled = not SilentAimEnabled
    Button.Text = SilentAimEnabled and "Silent Aim: ON" or "Silent Aim: OFF"
end)

-- Helper Functions
local function isAlive(player)
    return player and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0
end

local function isEnemy(player)
    return player.Team ~= LocalPlayer.Team
end

local function getClosestEnemy()
    local closestPlayer
    local closestDistance = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isAlive(player) and isEnemy(player) then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                if dist < closestDistance then
                    closestDistance = dist
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

-- Hook
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if SilentAimEnabled and method == "FireServer" then
        local eventName = tostring(self):lower()
        if eventName:find("firebullet") or eventName:find("shoot") then
            local target = getClosestEnemy()
            if target and isAlive(target) then
                local head = target.Character:FindFirstChild("Head")
                if head then
                    args[1] = head.Position
                    return oldNamecall(self, unpack(args))
                end
            end
        end
    end

    return oldNamecall(self, ...)
end)
