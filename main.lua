-- Script modified for Squid Game 2042
-- Aimbot + ESP Team Based

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CONFIG
local Aimbot = {
    Enabled = false,
    ActivationKey = Enum.UserInputType.MouseButton2,
    FOV = 150,
    Smoothness = 0.12,
    TargetPart = "Head",
    ShowFOV = false,
    ESP = false
}

local HoldingKey = false
local ESPObjects = {}

-- TEAM COLORS
local TEAM_COLORS = {
    Ally = Color3.fromRGB(0,255,0),
    Enemy = Color3.fromRGB(255,0,0)
}

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255,0,0)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.NumSides = 64
FOVCircle.Visible = false

-- INPUT
UserInputService.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.UserInputType == Aimbot.ActivationKey then
        HoldingKey = true
    end
end)

UserInputService.InputEnded:Connect(function(i,gp)
    if gp then return end
    if i.UserInputType == Aimbot.ActivationKey then
        HoldingKey = false
    end
end)

-- HELPERS
local function IsAlive(plr)
    local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function IsEnemy(plr)
    if not plr.Team or not LocalPlayer.Team then
        return true
    end
    return plr.Team ~= LocalPlayer.Team
end

local function OnScreen(part)
    local pos, vis = Camera:WorldToViewportPoint(part.Position)
    return vis, Vector2.new(pos.X,pos.Y)
end

-- ESP
local function ClearESP()
    for _,v in pairs(ESPObjects) do
        if v then v:Remove() end
    end
    ESPObjects = {}
end

local function CreateESP(plr)
    if plr == LocalPlayer then return end
    if ESPObjects[plr] then return end

    local text = Drawing.new("Text")
    text.Size = 14
    text.Center = true
    text.Outline = true
    text.Font = 2
    ESPObjects[plr] = text
end

-- TARGET
local function GetClosestTarget()
    local closest = Aimbot.FOV
    local target, part
    local mouse = UserInputService:GetMouseLocation()

    for _,plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if not IsEnemy(plr) then continue end
        if not IsAlive(plr) then continue end

        local char = plr.Character
        local p = char and char:FindFirstChild(Aimbot.TargetPart)
        if not p then continue end

        local onScr, pos = OnScreen(p)
        if not onScr then continue end

        local dist = (pos - mouse).Magnitude
        if dist < closest then
            closest = dist
            target = plr
            part = p
        end
    end

    return target, part
end

local function AimAt(part)
    local camPos = Camera.CFrame.Position
    local cf = CFrame.new(camPos, part.Position)
    Camera.CFrame = Camera.CFrame:Lerp(cf, Aimbot.Smoothness)
end

-- GUI
local function GUI()
    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "DragonAimbot"

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0,320,0,240)
    frame.Position = UDim2.new(0.5,-160,0.5,-120)
    frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    frame.BorderSizePixel = 0
    Instance.new("UICorner",frame).CornerRadius = UDim.new(0,12)

    local y = 40
    local function Toggle(text, val, cb)
        local lbl = Instance.new("TextLabel",frame)
        lbl.Text = text
        lbl.Position = UDim2.new(0,10,0,y)
        lbl.Size = UDim2.new(0,180,0,20)
        lbl.TextColor3 = Color3.new(1,1,1)
        lbl.BackgroundTransparency = 1
        lbl.TextXAlignment = Left

        local btn = Instance.new("TextButton",frame)
        btn.Position = UDim2.new(0,230,0,y)
        btn.Size = UDim2.new(0,60,0,20)
        btn.Text = val and "ON" or "OFF"
        btn.BackgroundColor3 = val and Color3.fromRGB(0,150,0) or Color3.fromRGB(150,0,0)

        btn.MouseButton1Click:Connect(function()
            val = not val
            btn.Text = val and "ON" or "OFF"
            btn.BackgroundColor3 = val and Color3.fromRGB(0,150,0) or Color3.fromRGB(150,0,0)
            cb(val)
        end)
        y += 30
    end

    Toggle("Aimbot",false,function(v) Aimbot.Enabled=v end)
    Toggle("ESP",false,function(v)
        Aimbot.ESP=v
        if not v then ClearESP() end
    end)
    Toggle("Show FOV",false,function(v)
        Aimbot.ShowFOV=v
        FOVCircle.Visible=v
    end)
end

GUI()

-- LOOP
RunService.RenderStepped:Connect(function()
    local mouse = UserInputService:GetMouseLocation()
    FOVCircle.Position = Vector2.new(mouse.X,mouse.Y)
    FOVCircle.Radius = Aimbot.FOV

    -- ESP UPDATE
    if Aimbot.ESP then
        for _,plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                CreateESP(plr)
                local head = plr.Character.Head
                local onScr,pos = OnScreen(head)
                local esp = ESPObjects[plr]
                if esp then
                    esp.Visible = onScr
                    esp.Text = plr.Name
                    esp.Position = pos - Vector2.new(0,25)
                    esp.Color = IsEnemy(plr) and TEAM_COLORS.Enemy or TEAM_COLORS.Ally
                end
            end
        end
    end

    -- AIMBOT
    if Aimbot.Enabled and HoldingKey then
        local plr,part = GetClosestTarget()
        if part then
            AimAt(part)
        end
    end
end)

