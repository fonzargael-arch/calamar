-- Squid Game 2042 | GF Hub
-- By Gael Fonzar

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
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

--========================
-- SETTINGS
--========================
local Settings = {
    Aimbot = false,
    ESP = false,
    ShowEnemies = false,
    ShowTeam = false,
    ShowDistance = false,
    ShowHealth = false,
    ShowBoxes = false,
    ShowTracers = false,
    HoldKey = Enum.UserInputType.MouseButton2,
    FOV = 160,
    Smoothness = 0.15,
    AimPart = "Head",
    PredictMovement = false,
    IgnoreTeam = true,
    ShowFOVCircle = false,
    WallCheck = false,
    CurrentTheme = "Purple"
}

--========================
-- THEMES
--========================
local Themes = {
    Purple = {
        Background = Color3.fromRGB(15, 15, 15),
        SecondaryBackground = Color3.fromRGB(20, 20, 20),
        Stroke = Color3.fromRGB(60, 60, 80),
        Divider = Color3.fromRGB(30, 30, 30),
        Text = Color3.fromRGB(240, 240, 250),
        TextDark = Color3.fromRGB(150, 150, 170),
        Accent = Color3.fromRGB(135, 110, 255),
        AccentDark = Color3.fromRGB(100, 80, 200),
        Success = Color3.fromRGB(100, 220, 120),
        Error = Color3.fromRGB(255, 80, 80)
    },
    Red = {
        Background = Color3.fromRGB(15, 15, 15),
        SecondaryBackground = Color3.fromRGB(20, 20, 20),
        Stroke = Color3.fromRGB(80, 40, 40),
        Divider = Color3.fromRGB(30, 30, 30),
        Text = Color3.fromRGB(255, 240, 240),
        TextDark = Color3.fromRGB(170, 130, 130),
        Accent = Color3.fromRGB(255, 60, 60),
        AccentDark = Color3.fromRGB(200, 40, 40),
        Success = Color3.fromRGB(100, 220, 120),
        Error = Color3.fromRGB(255, 80, 80)
    },
    Blue = {
        Background = Color3.fromRGB(15, 15, 15),
        SecondaryBackground = Color3.fromRGB(20, 20, 20),
        Stroke = Color3.fromRGB(40, 60, 100),
        Divider = Color3.fromRGB(30, 30, 30),
        Text = Color3.fromRGB(240, 245, 255),
        TextDark = Color3.fromRGB(130, 150, 180),
        Accent = Color3.fromRGB(60, 130, 255),
        AccentDark = Color3.fromRGB(40, 100, 220),
        Success = Color3.fromRGB(100, 220, 120),
        Error = Color3.fromRGB(255, 80, 80)
    },
    Green = {
        Background = Color3.fromRGB(15, 15, 15),
        SecondaryBackground = Color3.fromRGB(20, 20, 20),
        Stroke = Color3.fromRGB(40, 80, 60),
        Divider = Color3.fromRGB(30, 30, 30),
        Text = Color3.fromRGB(240, 255, 245),
        TextDark = Color3.fromRGB(130, 170, 150),
        Accent = Color3.fromRGB(60, 255, 130),
        AccentDark = Color3.fromRGB(40, 200, 100),
        Success = Color3.fromRGB(100, 220, 120),
        Error = Color3.fromRGB(255, 80, 80)
    },
    Orange = {
        Background = Color3.fromRGB(15, 15, 15),
        SecondaryBackground = Color3.fromRGB(20, 20, 20),
        Stroke = Color3.fromRGB(80, 60, 40),
        Divider = Color3.fromRGB(30, 30, 30),
        Text = Color3.fromRGB(255, 245, 240),
        TextDark = Color3.fromRGB(170, 150, 130),
        Accent = Color3.fromRGB(255, 140, 60),
        AccentDark = Color3.fromRGB(220, 110, 40),
        Success = Color3.fromRGB(100, 220, 120),
        Error = Color3.fromRGB(255, 80, 80)
    },
    Pink = {
        Background = Color3.fromRGB(15, 15, 15),
        SecondaryBackground = Color3.fromRGB(20, 20, 20),
        Stroke = Color3.fromRGB(90, 40, 80),
        Divider = Color3.fromRGB(30, 30, 30),
        Text = Color3.fromRGB(255, 240, 250),
        TextDark = Color3.fromRGB(180, 130, 170),
        Accent = Color3.fromRGB(255, 100, 200),
        AccentDark = Color3.fromRGB(220, 70, 170),
        Success = Color3.fromRGB(100, 220, 120),
        Error = Color3.fromRGB(255, 80, 80)
    }
}

local Theme = Themes[Settings.CurrentTheme]

--========================
-- UTILITIES
--========================
local function Tween(obj, props, duration)
    duration = duration or 0.3
    local tween = TweenService:Create(obj, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    tween:Play()
    return tween
end

local function UpdateTheme()
    Theme = Themes[Settings.CurrentTheme]
    -- Actualizar solo los strokes con el nuevo tema
    if _G.GFHubUI then
        _G.GFHubUI.UpdateColors()
    end
end

--========================
-- TEAM CHECK
--========================
local function IsEnemy(player)
    if not Settings.IgnoreTeam then return true end
    if not player.Team or not LocalPlayer.Team then return true end
    return player.Team.Name ~= LocalPlayer.Team.Name
end

--========================
-- WALL CHECK
--========================
local function HasLineOfSight(origin, target)
    if not Settings.WallCheck then return true end
    local ray = Ray.new(origin, (target - origin).Unit * (target - origin).Magnitude)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
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
FOV.Color = Color3.fromRGB(255, 255, 255)
FOV.Filled = false
FOV.Visible = Settings.ShowFOVCircle
FOV.Transparency = 0.8

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
    if not target or not target.Parent then return false end
    local player = Players:GetPlayerFromCharacter(target.Parent)
    if not player or not IsEnemy(player) then return false end
    local hum = target.Parent:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    local pos, vis = Camera:WorldToViewportPoint(target.Position)
    if not vis then return false end
    if Settings.WallCheck and not HasLineOfSight(Camera.CFrame.Position, target.Position) then
        return false
    end
    return true
end

local function PredictPosition(part)
    if not Settings.PredictMovement then return part.Position end
    local velocity = part.Velocity
    local distance = (part.Position - Camera.CFrame.Position).Magnitude
    local timeToHit = distance / 1000
    return part.Position + (velocity * timeToHit)
end

local function GetClosestTarget()
    local closest, dist = nil, Settings.FOV
    local mouse = UIS:GetMouseLocation()
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer or not plr.Character then continue end
        if not IsEnemy(plr) then continue end
        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
        local part = plr.Character:FindFirstChild(Settings.AimPart)
        if not hum or hum.Health <= 0 or not part then continue end
        local pos, vis = Camera:WorldToViewportPoint(part.Position)
        if not vis then continue end
        if Settings.WallCheck and not HasLineOfSight(Camera.CFrame.Position, part.Position) then
            continue
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
    esp.text.Size = 13
    esp.text.Center = true
    esp.text.Outline = true
    esp.text.Font = 2
    esp.box.Thickness = 2
    esp.box.Filled = false
    esp.box.Transparency = 1
    esp.tracer.Thickness = 2
    esp.tracer.Transparency = 1
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
                for _,v in pairs(esp) do v.Visible = false end
                return
            end
            if not player or not player.Parent or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                for _,v in pairs(esp) do v.Visible = false end
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
                local color = enemy and Theme.Error or Theme.Success
                local distance = math.floor((hrp.Position - Camera.CFrame.Position).Magnitude)
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
                if Settings.ShowBoxes then
                    local height = math.abs(headPos.Y - legPos.Y)
                    local width = height / 2
                    esp.box.Size = Vector2.new(width, height)
                    esp.box.Position = Vector2.new(pos.X - width/2, headPos.Y)
                    esp.box.Color = color
                    esp.box.Visible = true
                    local healthPercent = hum.Health / hum.MaxHealth
                    esp.healthbarBg.Size = Vector2.new(3, height)
                    esp.healthbarBg.Position = Vector2.new(pos.X - width/2 - 6, headPos.Y)
                    esp.healthbarBg.Visible = true
                    esp.healthbar.Size = Vector2.new(3, height * healthPercent)
                    esp.healthbar.Position = Vector2.new(pos.X - width/2 - 6, legPos.Y - (height * healthPercent))
                    esp.healthbar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                    esp.healthbar.Visible = true
                else
                    esp.box.Visible = false
                    esp.healthbar.Visible = false
                    esp.healthbarBg.Visible = false
                end
                if Settings.ShowTracers then
                    esp.tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    esp.tracer.To = Vector2.new(pos.X, pos.Y)
                    esp.tracer.Color = color
                    esp.tracer.Visible = true
                else
                    esp.tracer.Visible = false
                end
            else
                for _,v in pairs(esp) do v.Visible = false end
            end
        end)
    end)
    player.AncestryChanged:Connect(function()
        if not player.Parent then
            connection:Disconnect()
            for _,v in pairs(esp) do v:Remove() end
            ESPObjects[player] = nil
        end
    end)
end

for _,p in ipairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

--========================
-- INTRO SCREEN
--========================
local IntroGui = Instance.new("ScreenGui", CoreGui)
IntroGui.Name = "GFIntro"
IntroGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local IntroFrame = Instance.new("Frame", IntroGui)
IntroFrame.Size = UDim2.new(1, 0, 1, 0)
IntroFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
IntroFrame.BorderSizePixel = 0

local IntroText1 = Instance.new("TextLabel", IntroFrame)
IntroText1.Size = UDim2.new(0, 400, 0, 80)
IntroText1.Position = UDim2.new(0.5, -200, 0.5, -40)
IntroText1.BackgroundTransparency = 1
IntroText1.Text = "GF HUB"
IntroText1.TextColor3 = Color3.fromRGB(255, 255, 255)
IntroText1.Font = Enum.Font.GothamBold
IntroText1.TextSize = 60
IntroText1.TextTransparency = 1

local IntroText2 = Instance.new("TextLabel", IntroFrame)
IntroText2.Size = UDim2.new(0, 400, 0, 40)
IntroText2.Position = UDim2.new(0.5, -200, 0.5, 50)
IntroText2.BackgroundTransparency = 1
IntroText2.Text = "PRESENTS"
IntroText2.TextColor3 = Theme.Accent
IntroText2.Font = Enum.Font.Gotham
IntroText2.TextSize = 24
IntroText2.TextTransparency = 1

-- Animación de intro
Tween(IntroText1, {TextTransparency = 0}, 1)
wait(0.5)
Tween(IntroText2, {TextTransparency = 0}, 1)
wait(2)
Tween(IntroText1, {TextTransparency = 1}, 0.5)
Tween(IntroText2, {TextTransparency = 1}, 0.5)
wait(0.5)
Tween(IntroFrame, {BackgroundTransparency = 1}, 0.5)
wait(0.5)
IntroGui:Destroy()

--========================
-- GUI PRINCIPAL
--========================
local Gui = Instance.new("ScreenGui", CoreGui)
Gui.Name = "GFHub"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Shadow = Instance.new("ImageLabel", Gui)
Shadow.Name = "Shadow"
Shadow.BackgroundTransparency = 1
Shadow.Size = UDim2.new(0, 520, 0, 520)
Shadow.Position = UDim2.new(0.5, -260, 0.5, -260)
Shadow.Image = "rbxassetid://6015897843"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(49, 49, 450, 450)

local Main = Instance.new("Frame", Shadow)
Main.Name = "Main"
Main.Size = UDim2.new(0, 480, 0, 520)
Main.Position = UDim2.new(0.5, -240, 0.5, -260)
Main.BackgroundColor3 = Theme.Background
Main.BorderSizePixel = 0
Main.ClipsDescendants = true

local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Theme.Accent
MainStroke.Thickness = 2
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local TopBar = Instance.new("Frame", Main)
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundColor3 = Theme.SecondaryBackground
TopBar.BorderSizePixel = 0

local TopCorner = Instance.new("UICorner", TopBar)
TopCorner.CornerRadius = UDim.new(0, 12)

local TopFix = Instance.new("Frame", TopBar)
TopFix.Size = UDim2.new(1, 0, 0, 25)
TopFix.Position = UDim2.new(0, 0, 1, -25)
TopFix.BackgroundColor3 = Theme.SecondaryBackground
TopFix.BorderSizePixel = 0

local LogoFrame = Instance.new("Frame", TopBar)
LogoFrame.Size = UDim2.new(0, 35, 0, 35)
LogoFrame.Position = UDim2.new(0, 10, 0.5, -17.5)
LogoFrame.BackgroundColor3 = Theme.Accent
LogoFrame.BorderSizePixel = 0

local LogoCorner = Instance.new("UICorner", LogoFrame)
LogoCorner.CornerRadius = UDim.new(1, 0)

local LogoStroke = Instance.new("UIStroke", LogoFrame)
LogoStroke.Color = Color3.fromRGB(255, 255, 255)
LogoStroke.Thickness = 2

local LogoText = Instance.new("TextLabel", LogoFrame)
LogoText.Size = UDim2.new(1, 0, 1, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = "GF"
LogoText.TextColor3 = Color3.new(1, 1, 1)
LogoText.Font = Enum.Font.GothamBold
LogoText.TextSize = 16

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -160, 1, -10)
Title.Position = UDim2.new(0, 55, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "GF HUB"
Title.TextColor3 = Theme.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextYAlignment = Enum.TextYAlignment.Top

local Subtitle = Instance.new("TextLabel", TopBar)
Subtitle.Size = UDim2.new(1, -160, 1, -5)
Subtitle.Position = UDim2.new(0, 55, 0, 0)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Squid Game 2042"
Subtitle.TextColor3 = Theme.TextDark
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 11
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.TextYAlignment = Enum.TextYAlignment.Bottom

local MinBtn = Instance.new("TextButton", TopBar)
MinBtn.Size = UDim2.new(0, 35, 0, 35)
MinBtn.Position = UDim2.new(1, -45, 0.5, -17.5)
MinBtn.BackgroundColor3 = Theme.SecondaryBackground
MinBtn.Text = "—"
MinBtn.TextColor3 = Theme.Text
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 16
MinBtn.BorderSizePixel = 0

local MinCorner = Instance.new("UICorner", MinBtn)
MinCorner.CornerRadius = UDim.new(0, 8)

local MinStroke = Instance.new("UIStroke", MinBtn)
MinStroke.Color = Theme.Stroke
MinStroke.Thickness = 1

local Divider = Instance.new("Frame", Main)
Divider.Size = UDim2.new(1, -40, 0, 2)
Divider.Position = UDim2.new(0, 20, 0, 60)
Divider.BackgroundColor3 = Theme.Divider
Divider.BorderSizePixel = 0

local ScrollFrame = Instance.new("ScrollingFrame", Main)
ScrollFrame.Size = UDim2.new(1, -40, 1, -80)
ScrollFrame.Position = UDim2.new(0, 20, 0, 70)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Theme.Accent
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local UIList = Instance.new("UIListLayout", ScrollFrame)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 8)

-- Almacenar referencias para actualizar colores
_G.GFHubUI = {
    Elements = {},
    UpdateColors = function()
        -- Actualizar SOLO los strokes y accent colors
        MainStroke.Color = Theme.Accent
        LogoFrame.BackgroundColor3 = Theme.Accent
        ScrollFrame.ScrollBarImageColor3 = Theme.Accent
        
        -- Actualizar strokes de elementos
        for _, element in pairs(_G.GFHubUI.Elements) do
            if element.Type == "Section" then
                element.Label.TextColor3 = Theme.Accent
            elseif element.Type == "Credits" then
                element.Stroke.Color = Theme.Accent
                element.Label.TextColor3 = Theme.Accent
            end
        end
        
        -- Actualizar logo minimizado si existe
        if MiniButton and MiniButton.Parent then
            local miniStroke = MiniButton:FindFirstChildOfClass("UIStroke")
            local ring = MiniButton:FindFirstChild("ImageLabel")
            if miniStroke then
                miniStroke.Color = Theme.Accent
            end
            if ring then
                ring.ImageColor3 = Theme.Accent
            end
        end
    end
}

local function Section(text)
    local section = Instance.new("TextLabel", ScrollFrame)
    section.Size = UDim2.new(1, 0, 0, 25)
    section.BackgroundTransparency = 1
    section.Text = text
    section.TextColor3 = Theme.Accent
    section.Font = Enum.Font.GothamBold
    section.TextSize = 13
    section.TextXAlignment = Enum.TextXAlignment.Left
    
    table.insert(_G.GFHubUI.Elements, {Type = "Section", Label = section})
    return section
end

local function Toggle(text, default, callback)
    local toggle = Instance.new("Frame", ScrollFrame)
    toggle.Size = UDim2.new(1, 0, 0, 40)
    toggle.BackgroundColor3 = Theme.SecondaryBackground
    toggle.BorderSizePixel = 0
    
    local toggleCorner = Instance.new("UICorner", toggle)
    toggleCorner.CornerRadius = UDim.new(0, 8)
    
    local toggleStroke = Instance.new("UIStroke", toggle)
    toggleStroke.Color = Theme.Stroke
    toggleStroke.Thickness = 1
    
    local label = Instance.new("TextLabel", toggle)
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local button = Instance.new("TextButton", toggle)
    button.Size = UDim2.new(0, 40, 0, 20)
    button.Position = UDim2.new(1, -50, 0.5, -10)
    button.BackgroundColor3 = default and Theme.Success or Theme.Stroke
    button.Text = ""
    button.BorderSizePixel = 0
    
    local btnCorner = Instance.new("UICorner", button)
    btnCorner.CornerRadius = UDim.new(1, 0)
    
    local indicator = Instance.new("Frame", button)
    indicator.Size = UDim2.new(0, 16, 0, 16)
    indicator.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    indicator.BackgroundColor3 = Color3.new(1, 1, 1)
    indicator.BorderSizePixel = 0
    
    local indCorner = Instance.new("UICorner", indicator)
    indCorner.CornerRadius = UDim.new(1, 0)
    
    local state = default
    
    local elementData = {
        Type = "Toggle",
        Frame = toggle,
        Stroke = toggleStroke,
        Label = label,
        Button = button,
        State = state
    }
    table.insert(_G.GFHubUI.Elements, elementData)
    
    button.MouseButton1Click:Connect(function()
        state = not state
        elementData.State = state
        callback(state)
        
        Tween(button, {BackgroundColor3 = state and Theme.Success or Theme.Stroke}, 0.2)
        Tween(indicator, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.2)
    end)
    
    return toggle
end

local function ThemeButton(themeName, themeColor)
    local btn = Instance.new("TextButton", ScrollFrame)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Theme.SecondaryBackground
    btn.BorderSizePixel = 0
    btn.Text = ""
    
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 8)
    
    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Color = Theme.Stroke
    btnStroke.Thickness = 1
    
    local colorPreview = Instance.new("Frame", btn)
    colorPreview.Size = UDim2.new(0, 25, 0, 25)
    colorPreview.Position = UDim2.new(0, 10, 0.5, -12.5)
    colorPreview.BackgroundColor3 = themeColor
    colorPreview.BorderSizePixel = 0
    
    local colorCorner = Instance.new("UICorner", colorPreview)
    colorCorner.CornerRadius = UDim.new(1, 0)
    
    local colorStroke = Instance.new("UIStroke", colorPreview)
    colorStroke.Color = Color3.fromRGB(255, 255, 255)
    colorStroke.Thickness = 2
    
    local label = Instance.new("TextLabel", btn)
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 45, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = themeName
    label.TextColor3 = Theme.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local elementData = {
        Type = "ThemeButton",
        Button = btn,
        Stroke = btnStroke,
        Label = label
    }
    table.insert(_G.GFHubUI.Elements, elementData)
    
    btn.MouseButton1Click:Connect(function()
        Settings.CurrentTheme = themeName
        UpdateTheme()
    end)
    
    return btn
end

-- Crear secciones
Section("━━━ AIMBOT ━━━")

Toggle("Aimbot", Settings.Aimbot, function(v)
    Settings.Aimbot = v
end)

Toggle("Predicción de Movimiento", Settings.PredictMovement, function(v)
    Settings.PredictMovement = v
end)

Toggle("Verificar Paredes", Settings.WallCheck, function(v)
    Settings.WallCheck = v
end)

Toggle("Círculo FOV", Settings.ShowFOVCircle, function(v)
    Settings.ShowFOVCircle = v
    FOV.Visible = v
end)

Section("━━━ ESP / VISUAL ━━━")

Toggle("ESP Activado", Settings.ESP, function(v)
    Settings.ESP = v
end)

Toggle("Mostrar Distancia", Settings.ShowDistance, function(v)
    Settings.ShowDistance = v
end)

Toggle("Mostrar Vida", Settings.ShowHealth, function(v)
    Settings.ShowHealth = v
end)

Toggle("Cajas ESP", Settings.ShowBoxes, function(v)
    Settings.ShowBoxes = v
end)

Toggle("Tracers", Settings.ShowTracers, function(v)
    Settings.ShowTracers = v
end)

Section("━━━ FILTROS ━━━")

Toggle("Ver Enemigos", Settings.ShowEnemies, function(v)
    Settings.ShowEnemies = v
end)

Toggle("Ver Equipo", Settings.ShowTeam, function(v)
    Settings.ShowTeam = v
end)

Section("━━━ TEMAS ━━━")

ThemeButton("Purple", Color3.fromRGB(135, 110, 255))
ThemeButton("Red", Color3.fromRGB(255, 60, 60))
ThemeButton("Blue", Color3.fromRGB(60, 130, 255))
ThemeButton("Green", Color3.fromRGB(60, 255, 130))
ThemeButton("Orange", Color3.fromRGB(255, 140, 60))
ThemeButton("Pink", Color3.fromRGB(255, 100, 200))

Section("━━━ CRÉDITOS ━━━")

local Credits = Instance.new("Frame", ScrollFrame)
Credits.Size = UDim2.new(1, 0, 0, 70)
Credits.BackgroundColor3 = Theme.SecondaryBackground
Credits.BorderSizePixel = 0

local CreditsCorner = Instance.new("UICorner", Credits)
CreditsCorner.CornerRadius = UDim.new(0, 8)

local CreditsStroke = Instance.new("UIStroke", Credits)
CreditsStroke.Color = Theme.Accent
CreditsStroke.Thickness = 2

local CreditsText = Instance.new("TextLabel", Credits)
CreditsText.Size = UDim2.new(1, -20, 1, 0)
CreditsText.Position = UDim2.new(0, 10, 0, 0)
CreditsText.BackgroundTransparency = 1
CreditsText.Text = "💎 GAEL FONZAR SCRIPTS 💎\n\nCreado con ❤️ por Lola 🐉"
CreditsText.TextColor3 = Theme.Accent
CreditsText.Font = Enum.Font.GothamBold
CreditsText.TextSize = 14
CreditsText.TextYAlignment = Enum.TextYAlignment.Center

table.insert(_G.GFHubUI.Elements, {Type = "Credits", Frame = Credits, Stroke = CreditsStroke, Label = CreditsText})

-- Minimizar con logo GF
local MiniButton
local miniDragging, miniDragInput, miniDragStart, miniStartPos

MinBtn.MouseButton1Click:Connect(function()
    Tween(Shadow, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
    Tween(Main, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
    wait(0.3)
    Shadow.Visible = false
    
    if MiniButton then MiniButton:Destroy() end
    
    MiniButton = Instance.new("ImageButton", Gui)
    MiniButton.Name = "MiniLogo"
    MiniButton.Size = UDim2.new(0, 0, 0, 0)
    MiniButton.Position = UDim2.new(0, 20, 0, 20)
    MiniButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MiniButton.BorderSizePixel = 0
    MiniButton.Image = ""
    MiniButton.Active = true
    MiniButton.Draggable = false
    
    local miniCorner = Instance.new("UICorner", MiniButton)
    miniCorner.CornerRadius = UDim.new(1, 0)
    
    local miniStroke = Instance.new("UIStroke", MiniButton)
    miniStroke.Color = Theme.Accent
    miniStroke.Thickness = 3
    
    local gfFrame = Instance.new("Frame", MiniButton)
    gfFrame.Size = UDim2.new(0.7, 0, 0.7, 0)
    gfFrame.Position = UDim2.new(0.15, 0, 0.15, 0)
    gfFrame.BackgroundTransparency = 1
    
    local gfText = Instance.new("TextLabel", gfFrame)
    gfText.Size = UDim2.new(1, 0, 1, 0)
    gfText.BackgroundTransparency = 1
    gfText.Text = "GF"
    gfText.TextColor3 = Color3.new(1, 1, 1)
    gfText.Font = Enum.Font.GothamBold
    gfText.TextSize = 28
    gfText.TextScaled = true
    
    local ring1 = Instance.new("ImageLabel", MiniButton)
    ring1.Name = "Ring"
    ring1.Size = UDim2.new(1, 0, 1, 0)
    ring1.BackgroundTransparency = 1
    ring1.Image = "rbxassetid://3570695787"
    ring1.ImageColor3 = Theme.Accent
    ring1.ImageTransparency = 0.3
    
    Tween(MiniButton, {Size = UDim2.new(0, 70, 0, 70)}, 0.3)
    
    local rotConnection
    rotConnection = RunService.RenderStepped:Connect(function()
        if ring1 and ring1.Parent then
            ring1.Rotation = ring1.Rotation + 0.5
        else
            if rotConnection then
                rotConnection:Disconnect()
            end
        end
    end)
    
    -- Dragging para el logo minimizado
    MiniButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            miniDragging = true
            miniDragStart = input.Position
            miniStartPos = MiniButton.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    miniDragging = false
                end
            end)
        end
    end)
    
    MiniButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            miniDragInput = input
        end
    end)
    
    local miniDragConnection
    miniDragConnection = UIS.InputChanged:Connect(function(input)
        if input == miniDragInput and miniDragging then
            local delta = input.Position - miniDragStart
            MiniButton.Position = UDim2.new(
                miniStartPos.X.Scale,
                miniStartPos.X.Offset + delta.X,
                miniStartPos.Y.Scale,
                miniStartPos.Y.Offset + delta.Y
            )
        end
    end)
    
    MiniButton.MouseButton1Click:Connect(function()
        if not miniDragging then
            miniDragConnection:Disconnect()
            if rotConnection then
                rotConnection:Disconnect()
            end
            
            Tween(MiniButton, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
            wait(0.3)
            MiniButton:Destroy()
            MiniButton = nil
            
            Shadow.Visible = true
            Shadow.Size = UDim2.new(0, 0, 0, 0)
            Main.Size = UDim2.new(0, 0, 0, 0)
            Tween(Shadow, {Size = UDim2.new(0, 520, 0, 520)}, 0.3)
            Tween(Main, {Size = UDim2.new(0, 480, 0, 520)}, 0.3)
        end
    end)
end)

-- ARREGLAR DRAGGING
local dragging, dragInput, dragStart, startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Shadow.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Tween(Shadow, {
            Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        }, 0.1)
    end
end)

-- Animación de entrada
Shadow.Size = UDim2.new(0, 0, 0, 0)
Main.Size = UDim2.new(0, 0, 0, 0)
wait(0.5)
Tween(Shadow, {Size = UDim2.new(0, 520, 0, 520)}, 0.5)
Tween(Main, {Size = UDim2.new(0, 480, 0, 520)}, 0.5)

--========================
-- MAIN LOOP
--========================
RunService.RenderStepped:Connect(function()
    pcall(function()
        local mouse = UIS:GetMouseLocation()
        FOV.Position = Vector2.new(mouse.X,mouse.Y)
        FOV.Radius = Settings.FOV

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

print("✅ GF HUB - Loaded Successfully")
print("💎 Created by Gael Fonzar")
print("🎨 Theme System Active")
print("🎯 All Features Ready")
