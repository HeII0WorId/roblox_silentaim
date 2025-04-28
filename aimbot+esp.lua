local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local espEnabled = false
local silentAimEnabled = false

local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "MobileFastHub"

local openButton = Instance.new("TextButton", gui)
openButton.Size = UDim2.new(0, 100, 0, 40)
openButton.Position = UDim2.new(0, 10, 0, 10)
openButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
openButton.TextColor3 = Color3.new(1,1,1)
openButton.Font = Enum.Font.GothamBold
openButton.TextScaled = true
openButton.Text = "Open Hub"
Instance.new("UICorner", openButton).CornerRadius = UDim.new(0, 8)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 240)
frame.Position = UDim2.new(0, 20, 0.5, -120)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Visible = false
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Text = "Fast Script Hub"
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

local espBtn = Instance.new("TextButton", frame)
espBtn.Size = UDim2.new(0, 160, 0, 50)
espBtn.Position = UDim2.new(0, 20, 0, 60)
espBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
espBtn.TextColor3 = Color3.new(1,1,1)
espBtn.Font = Enum.Font.GothamBold
espBtn.TextScaled = true
espBtn.Text = "ESP: OFF"

local silentBtn = Instance.new("TextButton", frame)
silentBtn.Size = UDim2.new(0, 160, 0, 50)
silentBtn.Position = UDim2.new(0, 20, 0, 130)
silentBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
silentBtn.TextColor3 = Color3.new(1,1,1)
silentBtn.Font = Enum.Font.GothamBold
silentBtn.TextScaled = true
silentBtn.Text = "Silent Aim: OFF"

openButton.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
    openButton.Text = frame.Visible and "Close Hub" or "Open Hub"
end)

espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
    espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(50,50,50)
end)

silentBtn.MouseButton1Click:Connect(function()
    silentAimEnabled = not silentAimEnabled
    silentBtn.Text = silentAimEnabled and "Silent Aim: ON" or "Silent Aim: OFF"
    silentBtn.BackgroundColor3 = silentAimEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(50,50,50)
end)

local dragging
local dragInput
local dragStart
local startPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

RunService.RenderStepped:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local function getClosestEnemy()
    local closest, shortest = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Team ~= LocalPlayer.Team then
            local char = plr.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local pos, onScreen = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position)
                if onScreen then
                    local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                    if dist < shortest then
                        shortest = dist
                        closest = plr
                    end
                end
            end
        end
    end
    return closest
end

local espGui = Instance.new("Folder", gui)
espGui.Name = "EspFolder"

RunService.RenderStepped:Connect(function()
    if espEnabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local tag = espGui:FindFirstChild(plr.Name) or Instance.new("BillboardGui", espGui)
                tag.Name = plr.Name
                tag.Adornee = plr.Character.HumanoidRootPart
                tag.Size = UDim2.new(0,100,0,30)
                tag.StudsOffset = Vector3.new(0,3,0)
                tag.AlwaysOnTop = true

                local label = tag:FindFirstChild("NameLabel") or Instance.new("TextLabel", tag)
                label.Name = "NameLabel"
                label.Size = UDim2.new(1,0,1,0)
                label.BackgroundTransparency = 1
                label.TextColor3 = plr.Team == LocalPlayer.Team and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
                label.Font = Enum.Font.GothamBold
                label.TextScaled = true
                label.Text = plr.Name
            end
        end
    else
        espGui:ClearAllChildren()
    end
end)

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    if tostring(self) == "BulletEvent" and getnamecallmethod() == "FireServer" and silentAimEnabled then
        local target = getClosestEnemy()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            args[1] = target.Character.Head.Position
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)
