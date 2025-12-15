-- Squid Game 2042 | Aimbot + ESP PRO
-- Versión Mejorada

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
    ShowDistance = true,
    ShowHealth = true,
    ShowBoxes = false,
    ShowTracers = false,
    HoldKey = Enum.UserInputType.MouseButton2,
    FOV = 160,
    Smoothness = 0.15,
    AimPart = "Head",
    PredictMovement = true,
    IgnoreTeam = true,
    ShowFOVCircle = true,
    WallCheck = false,
    AutoShoot = false
}

--========================
-- TEAM CHECK
--========================
local function IsEnemy(player)
    if not Settings.IgnoreTeam then return true end
    if not player.Team or not LocalPlayer.Team then
        return true
    end
    return player.Team.Name ~= LocalPlayer.Team.Name
end

--========================
-- WALL CHECK
--========================
local function HasLineOfSight(origin, target)
    if not Settings.WallCheck then return true end
    
    local ray = Ray.new(origin, (target - origin).Unit * (target - origin).Magnitude)
    local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
    
    if hit then
        local character = hit:FindFirstAncestorOfClass("Model")
        if character and Players:GetPlayerFromCharacter(character) then
            return true
        end
        return false
    end
    return true
end

--========================
-- FOV CIRCLE
--========================
local FOV = Drawing.new("Circle")
FOV.Thickness = 2
FOV.NumSides = 64
FOV.Radius = Settings.FOV
FOV.Color = Color3.fromRGB(255,255,255)
FOV.Filled = false
FOV.Visible = Settings.ShowFOVCircle
FOV.Transparency = 0.5

--========================
-- AIMBOT LOGIC
--========================
local Holding = false
local CurrentTarget = nil
local LastTargetCheck = 0

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
        CurrentTarget = nil
    end
end)

local function IsTargetValid(target)
    if not target then return false end
    if not target.Parent then return false end
    
    local player = Players:GetPlayerFromCharacter(target.Parent)
    if not player then return false end
    if not IsEnemy(player) then return false end
    
    local hum = target.Parent:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    
    local pos, vis = Camera:WorldToViewportPoint(target.Position)
    if not vis then return false end
    
    if Settings.WallCheck then
        if not HasLineOfSight(Camera.CFrame.Position, target.Position) then
            return false
        end
    end
    
    return true
end

local function PredictPosition(part)
    if not Settings.PredictMovement then return part.Position end
    
    local velocity = part.Velocity
    local distance = (part.Position - Camera.CFrame.Position).Magnitude
    local timeToHit = distance / 1000 -- Ajusta según la velocidad de las balas
    
    return part.Position + (velocity * timeToHit)
end

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
        
        if Settings.WallCheck then
            if not HasLineOfSight(Camera.CFrame.Position, part.Position) then
                continue
            end
        end

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

    local esp = {
        text = Drawing.new("Text"),
        box = Drawing.new("Square"),
        tracer = Drawing.new("Line"),
        healthbar = Drawing.new("Square"),
        healthbarBg = Drawing.new("Square")
    }
    
    -- Text
    esp.text.Size = 13
    esp.text.Center = true
    esp.text.Outline = true
    esp.text.Font = 2
    
    -- Box
    esp.box.Thickness = 1
    esp.box.Filled = false
    esp.box.Transparency = 1
    
    -- Tracer
    esp.tracer.Thickness = 1
    esp.tracer.Transparency = 1
    
    -- Health bar
    esp.healthbar.Filled = true
    esp.healthbar.Thickness = 1
    esp.healthbar.Transparency = 1
    
    esp.healthbarBg.Filled = true
    esp.healthbarBg.Thickness = 1
    esp.healthbarBg.Transparency = 1
    esp.healthbarBg.Color = Color3.fromRGB(0,0,0)

    ESPObjects[player] = esp

    local connection
    connection = RunService.RenderStepped:Connect(function()
        pcall(function()
            if not Settings.ESP then
                for _,v in pairs(esp) do
                    v.Visible = false
                end
                return
            end

            if not player or not player.Parent or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                for _,v in pairs(esp) do
                    v.Visible = false
                end
                return
            end

            local hrp = player.Character.HumanoidRootPart
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            local head = player.Character:FindFirstChild("Head")
            
            if not hum or not head then return end

            local pos, onscreen = Camera:WorldToViewportPoint(hrp.Position)
            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
            local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))

            if onscreen then
                local enemy = IsEnemy(player)
                if enemy and not Settings.ShowEnemies then
                    for _,v in pairs(esp) do v.Visible = false end
                    return
                end
                if not enemy and not Settings.ShowTeam then
                    for _,v in pairs(esp) do v.Visible = false end
                    return
                end

                local color = enemy and Color3.fromRGB(255,50,50) or Color3.fromRGB(50,255,50)
                local distance = math.floor((hrp.Position - Camera.CFrame.Position).Magnitude)
                
                -- Text
                local displayText = player.Name
                if Settings.ShowDistance then
                    displayText = displayText .. " [" .. distance .. "m]"
                end
                if Settings.ShowHealth then
                    displayText = displayText .. " | " .. math.floor(hum.Health) .. "HP"
                end
                
                esp.text.Text = displayText
                esp.text.Position = Vector2.new(headPos.X, headPos.Y)
                esp.text.Color = color
                esp.text.Visible = true
                
                -- Box
                if Settings.ShowBoxes then
                    local height = math.abs(headPos.Y - legPos.Y)
                    local width = height / 2
                    
                    esp.box.Size = Vector2.new(width, height)
                    esp.box.Position = Vector2.new(pos.X - width/2, headPos.Y)
                    esp.box.Color = color
                    esp.box.Visible = true
                    
                    -- Health bar
                    local healthPercent = hum.Health / hum.MaxHealth
                    esp.healthbarBg.Size = Vector2.new(3, height)
                    esp.healthbarBg.Position = Vector2.new(pos.X - width/2 - 6, headPos.Y)
                    esp.healthbarBg.Visible = true
                    
                    esp.healthbar.Size = Vector2.new(3, height * healthPercent)
                    esp.healthbar.Position = Vector2.new(pos.X - width/2 - 6, legPos.Y - (height * healthPercent))
                    esp.healthbar.Color = Color3.fromRGB(
                        255 * (1 - healthPercent),
                        255 * healthPercent,
                        0
                    )
                    esp.healthbar.Visible = true
                else
                    esp.box.Visible = false
                    esp.healthbar.Visible = false
                    esp.healthbarBg.Visible = false
                end
                
                -- Tracer
                if Settings.ShowTracers then
                    esp.tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    esp.tracer.To = Vector2.new(pos.X, pos.Y)
                    esp.tracer.Color = color
                    esp.tracer.Visible = true
                else
                    esp.tracer.Visible = false
                end
            else
                for _,v in pairs(esp) do
                    v.Visible = false
                end
            end
        end)
    end)
    
    player.AncestryChanged:Connect(function()
        if not player.Parent then
            connection:Disconnect()
            for _,v in pairs(esp) do
                v:Remove()
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
Main.Size = UDim2.new(0,260,0,380)
Main.Position = UDim2.new(0,20,0.5,-190)
Main.BackgroundColor3 = Color3.fromRGB(25,25,30)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

local Corner = Instance.new("UICorner", Main)
Corner.CornerRadius = UDim.new(0,10)

local TopBar = Instance.new("Frame", Main)
TopBar.Size = UDim2.new(1,0,0,35)
TopBar.BackgroundColor3 = Color3.fromRGB(180,0,0)
TopBar.BorderSizePixel = 0

local TopCorner = Instance.new("UICorner", TopBar)
TopCorner.CornerRadius = UDim.new(0,10)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1,-40,1,0)
Title.Position = UDim2.new(0,5,0,0)
Title.Text = "🦑 SQUID GAME PRO"
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

local ScrollFrame = Instance.new("ScrollingFrame", Main)
ScrollFrame.Size = UDim2.new(1,-10,1,-45)
ScrollFrame.Position = UDim2.new(0,5,0,40)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.CanvasSize = UDim2.new(0,0,0,0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local UIList = Instance.new("UIListLayout", ScrollFrame)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0,5)

local Buttons = {}

local function Section(txt)
    local s = Instance.new("TextLabel", ScrollFrame)
    s.Size = UDim2.new(1,-10,0,25)
    s.Text = txt
    s.TextXAlignment = Enum.TextXAlignment.Left
    s.TextColor3 = Color3.fromRGB(255,200,50)
    s.BackgroundTransparency = 1
    s.Font = Enum.Font.GothamBold
    s.TextSize = 13
    return s
end

local function Button(txt, default, callback)
    local b = Instance.new("TextButton", ScrollFrame)
    b.Size = UDim2.new(1,-10,0,32)
    b.Text = txt .. (type(default) == "boolean" and (default and ": ON" or ": OFF") or "")
    b.BackgroundColor3 = type(default) == "boolean" and (default and Color3.fromRGB(0,150,0) or Color3.fromRGB(150,0,0)) or Color3.fromRGB(100,100,100)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.Gotham
    b.TextSize = 12
    b.BorderSizePixel = 0
    
    local btnCorner = Instance.new("UICorner", b)
    btnCorner.CornerRadius = UDim.new(0,6)
    
    b.MouseButton1Click:Connect(function()
        callback(b)
    end)
    
    return b
end

Section("━━━ AIMBOT ━━━")

Buttons.Aimbot = Button("Aimbot", Settings.Aimbot, function(self)
    Settings.Aimbot = not Settings.Aimbot
    self.Text = "Aimbot: "..(Settings.Aimbot and "ON" or "OFF")
    self.BackgroundColor3 = Settings.Aimbot and Color3.fromRGB(0,150,0) or Color3.fromRGB(150,0,0)
end)

Buttons.Predict = Button("Predicción Movimiento", Settings.PredictMovement, function(self)
    Settings.PredictMovement = not Settings.PredictMovement
    self.Text = "Predicción Movimiento: "..(Settings.PredictMovement and "ON" or "OFF")
    self.BackgroundColor3 = Settings.PredictMovement and Color3.fromRGB(0,150,0) or Color3.fromRGB(150,0,0)
end)

Buttons.WallCheck = Button("Ignorar Paredes", Settings.WallCheck, function(self)
    Settings.WallCheck = not Settings.WallCheck
    self.Text = "Ignorar Paredes: "..(Settings.WallCheck and "ON" or "OFF")
    self.BackgroundColor3 = Settings.WallCheck and Color3.fromRGB(0,150,0) or Color3.fromRGB(150,0,0)
end)

Buttons.FOVCircle = Button("Círculo FOV", Settings.ShowFOVCircle, function(self)
    Settings.ShowFOVCircle = not Settings.ShowFOVCircle
    FOV.Visible = Settings.ShowFOVCircle
    self.Text = "Círculo FOV: "..(Settings.ShowFOVCircle and "ON" or "OFF")
    self.BackgroundColor3 = Settings.ShowFOVCircle and Color3.fromRGB(0,150,0) or Color3.fromRGB(150,0,0)
end)

Section("━━━ ESP/VISUAL ━━━")

Buttons.ESP = Button("ESP General", Settings.ESP, function(self)
    Settings.ESP = not Settings.ESP
    self.Text = "ESP General: "..(Settings.ESP and "ON" or "OFF")
    self.BackgroundColor3 = Settings.ESP and Color3.fromRGB(0,150,0) or Color3.fromRGB(150,0,0)
end)

Buttons.Distance = Button("Mostrar Distancia", Settings.ShowDistance, function(self)
    Settings.ShowDistance = not Settings.ShowDistance
    self.Text = "Mostrar Distancia: "..(Settings.ShowDistance and "ON" or "OFF")
    self.BackgroundColor3 = Settings.ShowDistance and Color3.fromRGB(0,150,0) or Color3.fromRGB(150,0,0)
end)

Buttons.Health = Button("Mostrar Vida", Settings.ShowHealth, function(self)
    Settings.ShowHealth = not Settings.ShowHealth
    self.Text = "Mostrar Vida: "..(Settings.ShowHealth and "ON" or "OFF")
    self.BackgroundColor3 = Settings.ShowHealth and Color3.fromRGB(0,150,0) or Color3.fromRGB(150,0,0)
end)

Buttons.Boxes = Button("Cajas ESP", Settings.ShowBoxes, function(self)
    Settings.ShowBoxes = not Settings.ShowBoxes
    self.Text = "Cajas ESP: "..(Settings.ShowBoxes and "ON" or "OFF")
    self.BackgroundColor3 = Settings.ShowBoxes and Color3.fromRGB(0,150,0) or Color3.fromRGB(150,0,0)
end)

Buttons.Tracers = Button("Líneas al Centro", Settings.ShowTracers, function(self)
    Settings.ShowTracers = not Settings.ShowTracers
    self.Text = "Líneas al Centro: "..(Settings.ShowTracers and "ON" or "OFF")
    self.BackgroundColor3 = Settings.ShowTracers and Color3.fromRGB(0,150,0) or Color3.fromRGB(150,0,0)
end)

Section("━━━ FILTROS ━━━")

Buttons.Enemies = Button("Ver Enemigos", Settings.ShowEnemies, function(self)
    Settings.ShowEnemies = not Settings.ShowEnemies
    self.Text = "Ver Enemigos: "..(Settings.ShowEnemies and "ON" or "OFF")
    self.BackgroundColor3 = Settings.ShowEnemies and Color3.fromRGB(0,150,0) or Color3.fromRGB(150,0,0)
end)

Buttons.Team = Button("Ver Equipo", Settings.ShowTeam, function(self)
    Settings.ShowTeam = not Settings.ShowTeam
    self.Text = "Ver Equipo: "..(Settings.ShowTeam and "ON" or "OFF")
    self.BackgroundColor3 = Settings.ShowTeam and Color3.fromRGB(0,150,0) or Color3.fromRGB(150,0,0)
end)

local Min = Instance.new("TextButton", TopBar)
Min.Size = UDim2.new(0,30,0,30)
Min.Position = UDim2.new(1,-33,0,2.5)
Min.Text = "━"
Min.BackgroundColor3 = Color3.fromRGB(150,0,0)
Min.TextColor3 = Color3.new(1,1,1)
Min.Font = Enum.Font.GothamBold
Min.TextSize = 18
Min.BorderSizePixel = 0

local minCorner = Instance.new("UICorner", Min)
minCorner.CornerRadius = UDim.new(0,6)

local MiniBtn
Min.MouseButton1Click:Connect(function()
    Main.Visible = false
    if MiniBtn then MiniBtn:Destroy() end
    
    MiniBtn = Instance.new("TextButton", Gui)
    MiniBtn.Size = UDim2.new(0,140,0,35)
    MiniBtn.Position = UDim2.new(0,20,0.5,0)
    MiniBtn.Text = "🦑 Abrir"
    MiniBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
    MiniBtn.TextColor3 = Color3.new(1,1,1)
    MiniBtn.Font = Enum.Font.GothamBold
    MiniBtn.TextSize = 14
    MiniBtn.BorderSizePixel = 0
    
    local miniCorner = Instance.new("UICorner", MiniBtn)
    miniCorner.CornerRadius = UDim.new(0,8)
    
    MiniBtn.MouseButton1Click:Connect(function()
        Main.Visible = true
        MiniBtn:Destroy()
        MiniBtn = nil
    end)
end)

--========================
-- STATS DISPLAY
--========================
local StatsGui = Instance.new("ScreenGui", CoreGui)
StatsGui.Name = "StatsDisplay"
StatsGui.ResetOnSpawn = false

local StatsFrame = Instance.new("Frame", StatsGui)
StatsFrame.Size = UDim2.new(0,200,0,100)
StatsFrame.Position = UDim2.new(1,-210,0,10)
StatsFrame.BackgroundColor3 = Color3.fromRGB(25,25,30)
StatsFrame.BackgroundTransparency = 0.3
StatsFrame.BorderSizePixel = 0

local statsCorner = Instance.new("UICorner", StatsFrame)
statsCorner.CornerRadius = UDim.new(0,8)

local StatsText = Instance.new("TextLabel", StatsFrame)
StatsText.Size = UDim2.new(1,-10,1,-10)
StatsText.Position = UDim2.new(0,5,0,5)
StatsText.BackgroundTransparency = 1
StatsText.TextColor3 = Color3.new(1,1,1)
StatsText.Font = Enum.Font.Code
StatsText.TextSize = 11
StatsText.TextXAlignment = Enum.TextXAlignment.Left
StatsText.TextYAlignment = Enum.TextYAlignment.Top

--========================
-- MAIN LOOP
--========================
RunService.RenderStepped:Connect(function()
    pcall(function()
        local mouse = UIS:GetMouseLocation()
        FOV.Position = Vector2.new(mouse.X,mouse.Y)
        FOV.Radius = Settings.FOV

        -- Actualizar stats
        local targetText = CurrentTarget and "LOCKED" or "SEARCHING"
        local playersVisible = 0
        for _,p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local pos, vis = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if vis then playersVisible = playersVisible + 1 end
            end
        end
        
        StatsText.Text = string.format(
            "STATUS: %s\nTarget: %s\nPlayers: %d\nFPS: %d\nPing: %dms",
            Settings.Aimbot and "ACTIVE" or "IDLE",
            targetText,
            playersVisible,
            math.floor(1/RunService.RenderStepped:Wait()),
            math.floor(LocalPlayer:GetNetworkPing() * 1000)
        )

        if Settings.Aimbot and Holding then
            local currentTime = tick()
            if currentTime - LastTargetCheck > 0.1 or not IsTargetValid(CurrentTarget) then
                LastTargetCheck = currentTime
                CurrentTarget = GetClosestTarget()
            end
            
            if CurrentTarget and IsTargetValid(CurrentTarget) then
                local aimPos = PredictPosition(CurrentTarget)
                Camera.CFrame = Camera.CFrame:Lerp(
                    CFrame.new(Camera.CFrame.Position, aimPos),
                    Settings.Smoothness
                )
            else
                CurrentTarget = nil
            end
        end
    end)
end)

print("✅ Squid Game 2042 PRO - Cargado exitosamente")
print("📊 Estadísticas en tiempo real activadas")
print("🎯 Predicción de movimiento habilitada")
