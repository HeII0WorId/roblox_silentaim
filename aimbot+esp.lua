local SilentAim = false
local AutoShoot = false
local ESP = false

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local ui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ui.Name = "ScriptHub"
ui.ResetOnSpawn = false

local main = Instance.new("Frame", ui)
main.Size = UDim2.new(0, 180, 0, 220)
main.Position = UDim2.new(0, 20, 0.5, -110)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
main.BorderSizePixel = 0

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0, 8)

local layout = Instance.new("UIListLayout", main)
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center

local function createButton(name, callback)
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(0, 140, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.Text = name
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local silentBtn = createButton("Silent Aim", function()
    SilentAim = not SilentAim
    silentBtn.BackgroundColor3 = SilentAim and Color3.fromRGB(0,170,0) or Color3.fromRGB(50,50,50)
end)

local autoBtn = createButton("Auto Shoot", function()
    AutoShoot = not AutoShoot
    autoBtn.BackgroundColor3 = AutoShoot and Color3.fromRGB(0,170,0) or Color3.fromRGB(50,50,50)
end)

local espBtn = createButton("ESP", function()
    ESP = not ESP
    espBtn.BackgroundColor3 = ESP and Color3.fromRGB(0,170,0) or Color3.fromRGB(50,50,50)
end)

local function isAlive(plr)
    return plr and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0
end

local function getClosestEnemy()
    local closest, dist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isAlive(plr) and plr.Team ~= LocalPlayer.Team then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local pos, visible = Camera:WorldToViewportPoint(hrp.Position)
                if visible then
                    local mag = (Camera.CFrame.Position - hrp.Position).Magnitude
                    if mag < dist then
                        dist = mag
                        closest = plr
                    end
                end
            end
        end
    end
    return closest
end

local espGui = {}

RunService.RenderStepped:Connect(function()
    if ESP then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and isAlive(plr) and plr.Team ~= LocalPlayer.Team then
                if not espGui[plr] then
                    local billboard = Instance.new("BillboardGui", plr.Character:WaitForChild("HumanoidRootPart"))
                    billboard.Size = UDim2.new(0,100,0,40)
                    billboard.StudsOffset = Vector3.new(0,3,0)
                    billboard.AlwaysOnTop = true
                    local label = Instance.new("TextLabel", billboard)
                    label.Size = UDim2.new(1,0,1,0)
                    label.BackgroundTransparency = 1
                    label.TextColor3 = Color3.new(1,0,0)
                    label.Font = Enum.Font.GothamBold
                    label.TextScaled = true
                    label.Text = plr.Name
                    espGui[plr] = billboard
                end
            else
                if espGui[plr] then
                    espGui[plr]:Destroy()
                    espGui[plr] = nil
                end
            end
        end
    else
        for plr, gui in pairs(espGui) do
            if gui then
                gui:Destroy()
            end
        end
        espGui = {}
    end
end)

RunService.RenderStepped:Connect(function()
    if SilentAim then
        local target = getClosestEnemy()
        if target and isAlive(target) then
            local hrp = target.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                Mouse.Target = hrp
                Mouse.Hit = hrp.CFrame
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if AutoShoot then
        local target = getClosestEnemy()
        if target and (Camera.CFrame.Position - target.Character.HumanoidRootPart.Position).Magnitude < 50 then
            mouse1click()
        end
    end
end)
