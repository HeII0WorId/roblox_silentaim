-- Settings
local AimbotEnabled = true
local AimbotSmoothness = 0.15

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

local function aimAt(target)
    if not target or not target.Character then return end
    local head = target.Character:FindFirstChild("Head")
    if not head then return end

    local camCF = Camera.CFrame
    local direction = (head.Position - camCF.Position).Unit
    local newLook = camCF.LookVector:Lerp(direction, AimbotSmoothness)
    Camera.CFrame = CFrame.new(camCF.Position, camCF.Position + newLook)
end

-- Main Loop
RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local target = getClosestEnemy()
        if target then
            aimAt(target)
        end
    end
end)
