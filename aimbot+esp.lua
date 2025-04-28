-- Settings
local SilentAimEnabled = true

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Functions
local function isAlive(player)
    return player and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0
end

local function isEnemy(player)
    return player.Team ~= LocalPlayer.Team
end

local function getClosestEnemy()
    local closestPlayer = nil
    local closestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isAlive(player) and isEnemy(player) then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local distance = (Camera.CFrame.Position - hrp.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end

    return closestPlayer
end

-- Silent Aim Hook
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if SilentAimEnabled and method == "FireServer" and tostring(self) == "BulletEvent" then
        local target = getClosestEnemy()
        if target and isAlive(target) then
            local head = target.Character:FindFirstChild("Head")
            if head then
                args[1] = head.Position
                return oldNamecall(self, unpack(args))
            end
        end
    end

    return oldNamecall(self, ...)
end)
