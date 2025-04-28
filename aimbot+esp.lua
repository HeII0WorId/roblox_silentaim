local SilentAim = false
local AutoShoot = false
local ESP = false

local randomParts = {"Head", "UpperTorso", "LowerTorso", "LeftLeg", "RightLeg", "LeftArm", "RightArm"}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local ui = Instance.new("ScreenGui")
ui.Name = "F-Hub"
ui.ResetOnSpawn = false
ui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 180, 0, 250)
mainFrame.Position = UDim2.new(0, 20, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = ui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

local uiList = Instance.new("UIListLayout")
uiList.Padding = UDim.new(0, 10)
uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiList.VerticalAlignment = Enum.VerticalAlignment.Center
uiList.Parent = mainFrame

local function createButton(text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 140, 0, 40)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamBold
    button.TextScaled = true
    button.Text = text
    button.Parent = mainFrame
    button.MouseButton1Click:Connect(callback)
    return button
end

local silentAimButton = createButton("Silent Aim", function()
    SilentAim = not SilentAim
    silentAimButton.BackgroundColor3 = SilentAim and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(50, 50, 50)
end)

local autoShootButton = createButton("Auto Shoot", function()
    AutoShoot = not AutoShoot
    autoShootButton.BackgroundColor3 = AutoShoot and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(50, 50, 50)
end)

local espButton = createButton("ESP", function()
    ESP = not ESP
    espButton.BackgroundColor3 = ESP and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(50, 50, 50)
end)

local drawings = {}

local function createESP(plr)
    if drawings[plr] then return end
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Thickness = 2
    box.Filled = false
    local nameTag = Drawing.new("Text")
    nameTag.Visible = false
    nameTag.Color = Color3.new(1, 1, 1)
    nameTag.Size = 14
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.Font = 2
    drawings[plr] = {Box = box, Name = nameTag}
end

local function removeESP(plr)
    if drawings[plr] then
        drawings[plr].Box:Remove()
        drawings[plr].Name:Remove()
        drawings[plr] = nil
    end
end

local function isAlive(plr)
    return plr and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0
end

local function getRandomPart(char)
    for _ = 1, 5 do
        local partName = randomParts[math.random(#randomParts)]
        if char:FindFirstChild(partName) then
            return char[partName]
        end
    end
    return char:FindFirstChild("Head")
end

local function getClosestEnemy()
    local closest, dist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isAlive(plr) and plr.Team ~= LocalPlayer.Team then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local pos, visible = Camera:WorldToViewportPoint(hrp.Position)
                if visible then
                    local rayParams = RaycastParams.new()
                    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
                    local ray = workspace:Raycast(Camera.CFrame.Position, (hrp.Position - Camera.CFrame.Position).Unit * 500, rayParams)
                    if ray and ray.Instance and ray.Instance:IsDescendantOf(plr.Character) then
                        local mag = (Camera.CFrame.Position - hrp.Position).Magnitude
                        if mag < dist then
                            dist = mag
                            closest = plr
                        end
                    end
                end
            end
        end
    end
    return closest
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if SilentAim and method == "FireServer" and tostring(self) == "BulletEvent" then
        local target = getClosestEnemy()
        if target and isAlive(target) then
            local part = getRandomPart(target.Character)
            if part then
                args[1] = part.Position
                return oldNamecall(self, unpack(args))
            end
        end
    end
    return oldNamecall(self, ...)
end)

RunService.RenderStepped:Connect(function()
    if AutoShoot then
        local target = getClosestEnemy()
        if target then
            mouse1press()
            task.wait(0.1)
            mouse1release()
        end
    end
end)

RunService.RenderStepped:Connect(function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isAlive(plr) and plr.Team ~= LocalPlayer.Team then
            if ESP then
                createESP(plr)
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local pos, visible = Camera:WorldToViewportPoint(hrp.Position)
                    if visible then
                        local mag = (hrp.Position - Camera.CFrame.Position).Magnitude
                        local scale = 1 / mag * 100
                        local width = math.clamp(40 * scale, 2, 100)
                        local height = math.clamp(60 * scale, 2, 150)
                        local esp = drawings[plr]
                        esp.Box.Size = Vector2.new(width, height)
                        esp.Box.Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
                        esp.Box.Visible = true
                        esp.Name.Text = plr.Name
                        esp.Name.Position = Vector2.new(pos.X, pos.Y - height / 2 - 15)
                        esp.Name.Visible = true
                    else
                        drawings[plr].Box.Visible = false
                        drawings[plr].Name.Visible = false
                    end
                end
            else
                removeESP(plr)
            end
        else
            removeESP(plr)
        end
    end
end)
