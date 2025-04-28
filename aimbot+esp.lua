--// Settings
local AimbotEnabled = true
local ESPEnabled = true
local AimbotFOV = 90
local AimbotSmoothness = 0.15

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--// Variables
local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
local Drawings = {}

--// Functions
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
            local head = player.Character:FindFirstChild("Head")
            if head then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - ScreenCenter).Magnitude
                    if distance < closestDistance and distance < AimbotFOV then
                        closestDistance = distance
                        closestPlayer = player
                    end
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

local function createESP(player)
    if Drawings[player] then return end

    local box = Drawing.new("Square")
    box.Visible = false
    box.Thickness = 2
    box.Filled = false
    box.Color = Color3.fromRGB(255, 0, 0)

    Drawings[player] = box
end

local function removeESP(player)
    if Drawings[player] then
        Drawings[player]:Remove()
        Drawings[player] = nil
    end
end

local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isAlive(player) then
            createESP(player)

            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local distance = (Camera.CFrame.Position - hrp.Position).Magnitude
                    local sizeFactor = math.clamp(3000 / distance, 20, 120)

                    local box = Drawings[player]
                    box.Size = Vector2.new(sizeFactor, sizeFactor * 1.5)
                    box.Position = Vector2.new(screenPos.X - sizeFactor/2, screenPos.Y - sizeFactor*1.5/2)
                    box.Color = isEnemy(player) and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 0, 255)
                    box.Visible = ESPEnabled
                else
                    if Drawings[player] then
                        Drawings[player].Visible = false
                    end
                end
            end
        else
            removeESP(player)
        end
    end
end

--// Main Loop
RunService.RenderStepped:Connect(function()
    ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    if AimbotEnabled then
        local target = getClosestEnemy()
        if target then
            aimAt(target)
        end
    end

    if ESPEnabled then
        updateESP()
    end
end)
