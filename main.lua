--[[
  Squid Game 2042 | Admin Panel
  PlaceId Locked: 113075977776798
  Teams: Jugadores (Players) vs Guardias (Guards)
  Features:
   - Aimbot (enemy-only)
   - FOV (optimized)
   - ESP (persistent, dead/alive)
   - Minimize to floating button (never fully closes)
   - Movable, always-on-top
]]

-- ===== PLACE LOCK =====
local ALLOWED_PLACE = 113075977776798
if game.PlaceId ~= ALLOWED_PLACE then
    warn("This script only works in Squid Game 2042")
    return
end

-- ===== SERVICES =====
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ===== CONFIG =====
local CFG = {
    AimbotEnabled = false,
    ESPEnabled = true,
    ShowEnemies = true,
    ShowTeam = false,
    FOV = 160,
    Smoothness = 0.15,
    ActivationKey = Enum.UserInputType.MouseButton2,
    TargetPart = "Head",
}

-- ===== TEAM CHECK =====
local function IsEnemy(player)
    if not player.Team or not LocalPlayer.Team then return true end
    if player.Team.Name == "Guardias" and LocalPlayer.Team.Name == "Jugadores" then return true end
    if player.Team.Name == "Jugadores" and LocalPlayer.Team.Name == "Guardias" then return true end
    return false
end

-- ===== FOV DRAWING =====
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 60, 60)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.NumSides = 32
FOVCircle.Visible = true
FOVCircle.Radius = CFG.FOV

-- ===== AIMBOT =====
local Holding = false
UserInputService.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.UserInputType == CFG.ActivationKey then Holding = true end
end)
UserInputService.InputEnded:Connect(function(i,gp)
    if gp then return end
    if i.UserInputType == CFG.ActivationKey then Holding = false end
end)

local function GetTarget()
    local closest, part = nil, nil
    local minDist = CFG.FOV
    local mouse = UserInputService:GetMouseLocation()

    for _,plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if not plr.Character then continue end
        if not IsEnemy(plr) then continue end

        local p = plr.Character:FindFirstChild(CFG.TargetPart)
        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
        if not p or not hum then continue end

        local screen, onScreen = Camera:WorldToViewportPoint(p.Position)
        if not onScreen then continue end

        local dist = (Vector2.new(screen.X,screen.Y) - Vector2.new(mouse.X,mouse.Y)).Magnitude
        if dist < minDist then
            minDist = dist
            closest = plr
            part = p
        end
    end
    return part
end

-- ===== ESP =====
local ESP = {}

local function CreateESP(player)
    if ESP[player] then return end

    local box = Drawing.new("Text")
    box.Center = true
    box.Outline = true
    box.Size = 14
    box.Text = player.Name
    box.Visible = false

    ESP[player] = box
end

local function RemoveESP(player)
    if ESP[player] then
        ESP[player]:Remove()
        ESP[player] = nil
    end
end

for _,p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then CreateESP(p) end
end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- ===== GUI =====
local gui = Instance.new("ScreenGui")

gui.Name = "DragonAdmin"
gui.ResetOnSpawn = false

pcall(function()
    gui.Parent = gethui and gethui() or CoreGui
end)

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,300,0,230)
main.Position = UDim2.new(0.5,-150,0.5,-115)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundColor3 = Color3.fromRGB(40,0,0)
title.Text = "🐉 Squid Game 2042 Admin"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14

local close = Instance.new("TextButton", title)
close.Size = UDim2.new(0,30,1,0)
close.Position = UDim2.new(1,-30,0,0)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(120,0,0)

local mini = Instance.new("TextButton", gui)
mini.Size = UDim2.new(0,120,0,30)
mini.Position = UDim2.new(0,10,0.5,0)
mini.Text = "Open Admin"
mini.Visible = false
mini.BackgroundColor3 = Color3.fromRGB(40,0,0)
mini.TextColor3 = Color3.new(1,1,1)
mini.Active = true
mini.Draggable = true

close.MouseButton1Click:Connect(function()
    main.Visible = false
    mini.Visible = true
end)
mini.MouseButton1Click:Connect(function()
    main.Visible = true
    mini.Visible = false
end)

local function Toggle(name, default, y, cb)
    local b = Instance.new("TextButton", main)
    b.Size = UDim2.new(0,260,0,28)
    b.Position = UDim2.new(0,20,0,y)
    b.Text = name..": "..(default and "ON" or "OFF")
    b.BackgroundColor3 = Color3.fromRGB(60,0,0)
    b.TextColor3 = Color3.new(1,1,1)

    local v = default
    b.MouseButton1Click:Connect(function()
        v = not v
        b.Text = name..": "..(v and "ON" or "OFF")
        cb(v)
    end)
end

Toggle("Aimbot", CFG.AimbotEnabled, 50, function(v) CFG.AimbotEnabled = v end)
Toggle("ESP", CFG.ESPEnabled, 90, function(v) CFG.ESPEnabled = v end)
Toggle("Show Enemies", CFG.ShowEnemies, 130, function(v) CFG.ShowEnemies = v end)
Toggle("Show Team", CFG.ShowTeam, 170, function(v) CFG.ShowTeam = v end)

-- ===== MAIN LOOP =====
RunService.RenderStepped:Connect(function()
    local mouse = UserInputService:GetMouseLocation()
    FOVCircle.Position = Vector2.new(mouse.X, mouse.Y)
    FOVCircle.Radius = CFG.FOV

    if CFG.AimbotEnabled and Holding then
        local part = GetTarget()
        if part then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, part.Position), CFG.Smoothness)
        end
    end

    for plr,txt in pairs(ESP) do
        if not CFG.ESPEnabled then txt.Visible = false continue end
        if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then
            txt.Visible = false continue
        end

        local enemy = IsEnemy(plr)
        if (enemy and not CFG.ShowEnemies) or (not enemy and not CFG.ShowTeam) then
            txt.Visible = false continue
        end

        local pos, onScreen = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
        if onScreen then
            txt.Visible = true
            txt.Position = Vector2.new(pos.X, pos.Y)
            txt.Color = enemy and Color3.fromRGB(255,80,80) or Color3.fromRGB(80,160,255)
        else
            txt.Visible = false
        end
    end
end)

