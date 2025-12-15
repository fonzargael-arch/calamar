-- Squid Game 2042 | Aimbot + ESP
-- Arreglado por Claude

--========================
-- PLACE ID CHECK
--========================
local PLACE_ID = 113075977776798
if game.PlaceId ~= PLACE_ID then
    warn("Este script es solo para Squid Game 2042")
    return
end

--========================
-- SERVICES
--========================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

--========================
-- SETTINGS
--========================
local Settings = {
    Aimbot = false,
    ESP = false,
    ShowEnemies = true,
    ShowTeam = true,
    HoldKey = Enum.UserInputType.MouseButton2,
    FOV = 160,
    Smoothness = 0.15,
    AimPart = "Head"
}

--========================
-- TEAM CHECK
--========================
local function IsEnemy(player)
    if not player.Team or not LocalPlayer.Team then
        return true
    end
    return player.Team.Name ~= LocalPlayer.Team.Name
end

--========================
-- FOV CIRCLE
--========================
local FOV = Drawing.new("Circle")
FOV.Thickness = 1
FOV.NumSides = 60
FOV.Radius = Settings.FOV
FOV.Color = Color3.fromRGB(255,0,0)
FOV.Filled = false
FOV.Visible = true

--========================
-- AIMBOT LOGIC
--========================
local Holding = false

UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.UserInputType == Settings.HoldKey then
        Holding = true
    end
end)

UIS.InputEnded:Connect(function(i,gp)
    if gp then return end
    if i.UserInputType == Settings.HoldKey then
        Holding = false
    end
end)

local function GetClosestTarget()
    local closest, dist = nil, Settings.FOV
    local mouse = UIS:GetMouseLocation()

    for _,plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if not plr.Character then continue end
        if not IsEnemy(plr) then continue end

        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
        local part = plr.Character:FindFirstChild(Settings.AimPart)
        if not hum or hum.Health <= 0 or not part then continue end

        local pos, vis = Camera:WorldToViewportPoint(part.Position)
        if not vis then continue end

        local mag = (Vector2.new(pos.X,pos.Y) - mouse).Magnitude
        if mag < dist then
            dist = mag
            closest = part
        end
    end
    return closest
end

--========================
-- ESP SYSTEM
--========================
local ESPObjects = {}

local function CreateESP(player)
    if player == LocalPlayer then return end

    local text = Drawing.new("Text")
    text.Size = 13
    text.Center = true
    text.Outline = true

    ESPObjects[player] = text

    local connection
    connection = RunService.RenderStepped:Connect(function()
        pcall(function()
            if not Settings.ESP then
                text.Visible = false
                return
            end

            if not player or not player.Parent or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                text.Visible = false
                return
            end

            local pos, onscreen = Camera:WorldToViewportPoint(
                player.Character.HumanoidRootPart.Position + Vector3.new(0,2,0)
            )

            if onscreen then
                local enemy = IsEnemy(player)
                if enemy and not Settings.ShowEnemies then
                    text.Visible = false
                    return
                end
                if not enemy and not Settings.ShowTeam then
                    text.Visible = false
                    return
                end

                text.Text = player.Name
                text.Position = Vector2.new(pos.X,pos.Y)
                text.Color = enemy and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,0)
                text.Visible = true
            else
                text.Visible = false
            end
        end)
    end)
    
    -- Limpiar cuando el jugador se va
    player.AncestryChanged:Connect(function()
        if not player.Parent then
            connection:Disconnect()
            if text then
                text:Remove()
            end
            ESPObjects[player] = nil
        end
    end)
end

for _,p in ipairs(Players:GetPlayers()) do
    CreateESP(p)
end
Players.PlayerAdded:Connect(CreateESP)

--========================
-- GUI
--========================
local Gui = Instance.new("ScreenGui", CoreGui)
Gui.Name = "SquidAdmin"
Gui.ResetOnSpawn = false

local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0,220,0,210)
Main.Position = UDim2.new(0,20,0.4,0)
Main.BackgroundColor3 = Color3.fromRGB(120,0,0)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

local Corner = Instance.new("UICorner", Main)
Corner.CornerRadius = UDim.new(0,8)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,30)
Title.Text = "🦑 Squid Game 2042"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

local Buttons = {}

local function Button(txt,y,callback)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(1,-20,0,30)
    b.Position = UDim2.new(0,10,0,y)
    b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(150,0,0)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.Gotham
    b.TextSize = 12
    b.BorderSizePixel = 0
    
    local btnCorner = Instance.new("UICorner", b)
    btnCorner.CornerRadius = UDim.new(0,5)
    
    b.MouseButton1Click:Connect(function()
        callback(b)
    end)
    
    return b
end

Buttons.Aimbot = Button("Aimbot: OFF",40,function(self)
    Settings.Aimbot = not Settings.Aimbot
    self.Text = "Aimbot: "..(Settings.Aimbot and "ON" or "OFF")
    self.BackgroundColor3 = Settings.Aimbot and Color3.fromRGB(0,150,0) or Color3.fromRGB(150,0,0)
end)

Buttons.ESP = Button("ESP: OFF",75,function(self)
    Settings.ESP = not Settings.ESP
    self.Text = "ESP: "..(Settings.ESP and "ON" or "OFF")
    self.BackgroundColor3 = Settings.ESP and Color3.fromRGB(0,150,0) or Color3.fromRGB(150,0,0)
end)

Buttons.Enemies = Button("Ver Enemigos: ON",110,function(self)
    Settings.ShowEnemies = not Settings.ShowEnemies
    self.Text = "Ver Enemigos: "..(Settings.ShowEnemies and "ON" or "OFF")
    self.BackgroundColor3 = Settings.ShowEnemies and Color3.fromRGB(0,150,0) or Color3.fromRGB(150,0,0)
end)

Buttons.Team = Button("Ver Team: ON",145,function(self)
    Settings.ShowTeam = not Settings.ShowTeam
    self.Text = "Ver Team: "..(Settings.ShowTeam and "ON" or "OFF")
    self.BackgroundColor3 = Settings.ShowTeam and Color3.fromRGB(0,150,0) or Color3.fromRGB(150,0,0)
end)

-- Inicializar colores
Buttons.Enemies.BackgroundColor3 = Color3.fromRGB(0,150,0)
Buttons.Team.BackgroundColor3 = Color3.fromRGB(0,150,0)

local Min = Instance.new("TextButton", Main)
Min.Size = UDim2.new(0,25,0,25)
Min.Position = UDim2.new(1,-30,0,2)
Min.Text = "–"
Min.BackgroundColor3 = Color3.fromRGB(150,0,0)
Min.TextColor3 = Color3.new(1,1,1)
Min.Font = Enum.Font.GothamBold
Min.TextSize = 18
Min.BorderSizePixel = 0

local minCorner = Instance.new("UICorner", Min)
minCorner.CornerRadius = UDim.new(0,5)

local MiniBtn
Min.MouseButton1Click:Connect(function()
    Main.Visible = false
    if MiniBtn then MiniBtn:Destroy() end
    
    MiniBtn = Instance.new("TextButton", Gui)
    MiniBtn.Size = UDim2.new(0,120,0,30)
    MiniBtn.Position = UDim2.new(0,20,0.4,0)
    MiniBtn.Text = "🦑 Abrir Panel"
    MiniBtn.BackgroundColor3 = Color3.fromRGB(120,0,0)
    MiniBtn.TextColor3 = Color3.new(1,1,1)
    MiniBtn.Font = Enum.Font.Gotham
    MiniBtn.TextSize = 12
    MiniBtn.BorderSizePixel = 0
    
    local miniCorner = Instance.new("UICorner", MiniBtn)
    miniCorner.CornerRadius = UDim.new(0,5)
    
    MiniBtn.MouseButton1Click:Connect(function()
        Main.Visible = true
        MiniBtn:Destroy()
        MiniBtn = nil
    end)
end)

--========================
-- MAIN LOOP
--========================
RunService.RenderStepped:Connect(function()
    pcall(function()
        local mouse = UIS:GetMouseLocation()
        FOV.Position = Vector2.new(mouse.X,mouse.Y)
        FOV.Radius = Settings.FOV

        if Settings.Aimbot and Holding then
            local target = GetClosestTarget()
            if target then
                Camera.CFrame = Camera.CFrame:Lerp(
                    CFrame.new(Camera.CFrame.Position, target.Position),
                    Settings.Smoothness
                )
            end
        end
    end)
end)

print("✅ Squid Game 2042 Script cargado correctamente")
