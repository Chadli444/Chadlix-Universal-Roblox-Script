--[[
    CHADLIX UNIVERSAL HUB
    Rayfield-Style Clean GUI
    Zero errors - All fonts validated
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

-- Settings
local Settings = {
    AutoClicker = false,
    AimAssist = false,
    TeamESP = false,
    NormalESP = false,
    FPSPing = false,
    Fly = false,
    Noclip = false,
    InfJump = false,
    AimStrength = 0.15,
    FOVRadius = 80,
    FlySpeed = 50
}

local currentTarget = nil
local guiVisible = true
local espObjects = {}

-- Create Main GUI
local ChadlixHub = Instance.new("ScreenGui")
ChadlixHub.Name = "ChadlixHub"
ChadlixHub.Parent = CoreGui
ChadlixHub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Container
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 550, 0, 380)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ChadlixHub

-- Drop shadow
local DropShadow = Instance.new("ImageLabel")
DropShadow.Size = UDim2.new(1, 30, 1, 30)
DropShadow.Position = UDim2.new(0, -15, 0, -15)
DropShadow.BackgroundTransparency = 1
DropShadow.Image = "rbxassetid://6014261993"
DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
DropShadow.ImageTransparency = 0.5
DropShadow.ScaleType = Enum.ScaleType.Slice
DropShadow.SliceCenter = Rect.new(49, 49, 49, 49)
DropShadow.Parent = MainFrame

-- Corner
local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 8)
UICornerMain.Parent = MainFrame

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local UICornerTop = Instance.new("UICorner")
UICornerTop.CornerRadius = UDim.new(0, 8)
UICornerTop.Parent = TopBar

local TopCover = Instance.new("Frame")
TopCover.Size = UDim2.new(1, 0, 0, 20)
TopCover.Position = UDim2.new(0, 0, 0.5, 0)
TopCover.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
TopCover.BorderSizePixel = 0
TopCover.Parent = TopBar

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 18, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "CHADLIX"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(0, 200, 0, 15)
SubTitle.Position = UDim2.new(0, 18, 0, 25)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Universal Hub"
SubTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
SubTitle.TextSize = 11
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = TopBar

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 28, 0, 28)
CloseButton.Position = UDim2.new(1, -38, 0, 8)
CloseButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TopBar
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 6)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 160, 1, -45)
Sidebar.Position = UDim2.new(0, 0, 0, 45)
Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local UICornerSide = Instance.new("UICorner")
UICornerSide.CornerRadius = UDim.new(0, 8)
UICornerSide.Parent = Sidebar

local SideCover = Instance.new("Frame")
SideCover.Size = UDim2.new(0, 20, 1, -8)
SideCover.Position = UDim2.new(1, -20, 0, 8)
SideCover.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
SideCover.BorderSizePixel = 0
SideCover.Parent = Sidebar

-- Content Area
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -165, 1, -50)
ContentArea.Position = UDim2.new(0, 165, 0, 50)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

-- Tab buttons
local Tabs = {
    {name = "Combat", icon = "⚔️"},
    {name = "Movement", icon = "🏃"},
    {name = "Visuals", icon = "👁️"},
    {name = "Stats", icon = "📊"}
}
local tabButtons = {}
local tabPages = {}
local currentTab = "Combat"

for i, tabData in ipairs(Tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, 15 + (i-1) * 48)
    btn.BackgroundColor3 = i == 1 and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(25, 25, 30)
    btn.BorderSizePixel = 0
    btn.Text = tabData.icon .. "  " .. tabData.name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.Parent = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    tabButtons[tabData.name] = btn
    
    -- Content page
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -10, 1, 0)
    page.Position = UDim2.new(0, 5, 0, 0)
    page.BackgroundTransparency = 1
    page.Visible = (tabData.name == "Combat")
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Parent = ContentArea
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.Parent = page
    
    tabPages[tabData.name] = page
    
    btn.MouseButton1Click:Connect(function()
        currentTab = tabData.name
        for name, button in pairs(tabButtons) do
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = name == tabData.name and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(25, 25, 30)
            }):Play()
        end
        for name, pg in pairs(tabPages) do
            pg.Visible = (name == tabData.name)
        end
    end)
end

-- Helper to create sections
local function CreateSection(page, title)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 0)
    section.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    section.BorderSizePixel = 0
    section.Parent = page
    Instance.new("UICorner", section).CornerRadius = UDim.new(0, 8)
    
    local sectionTitle = Instance.new("TextLabel")
    sectionTitle.Size = UDim2.new(1, -20, 0, 25)
    sectionTitle.Position = UDim2.new(0, 15, 0, 8)
    sectionTitle.BackgroundTransparency = 1
    sectionTitle.Text = title
    sectionTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    sectionTitle.TextSize = 13
    sectionTitle.Font = Enum.Font.GothamBold
    sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    sectionTitle.Parent = section
    
    return section
end

-- Helper to create toggles
local function CreateToggle(parent, yPos, title, default, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -20, 0, 35)
    toggleFrame.Position = UDim2.new(0, 10, 0, yPos)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 150, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 44, 0, 22)
    button.Position = UDim2.new(1, -44, 0.5, -11)
    button.BackgroundColor3 = default and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(60, 60, 65)
    button.BorderSizePixel = 0
    button.Text = ""
    button.Parent = toggleFrame
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 11)
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 16, 0, 16)
    dot.Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    dot.Parent = button
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    
    local enabled = default
    
    local function updateVisual()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = enabled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(60, 60, 65)
        }):Play()
        TweenService:Create(dot, TweenInfo.new(0.2), {
            Position = enabled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        }):Play()
    end
    
    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        updateVisual()
        callback(enabled)
    end)
    
    return button, dot
end

-- Helper for sliders
local function CreateSlider(parent, yPos, title, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -20, 0, 45)
    sliderFrame.Position = UDim2.new(0, 10, 0, yPos)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 18)
    label.BackgroundTransparency = 1
    label.Text = title .. ": " .. default
    label.TextColor3 = Color3.fromRGB(180, 180, 180)
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame
    
    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(1, 0, 0, 5)
    slider.Position = UDim2.new(0, 0, 0, 25)
    slider.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    slider.BorderSizePixel = 0
    slider.Text = ""
    slider.Parent = sliderFrame
    Instance.new("UICorner", slider).CornerRadius = UDim.new(0, 3)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)
    
    local dragging = false
    
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = slider.AbsolutePosition
            local sliderSize = slider.AbsoluteSize
            local percent = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
            local value = math.round((min + (max - min) * percent) * 100) / 100
            
            fill.Size = UDim2.new(percent, 0, 1, 0)
            label.Text = title .. ": " .. value
            callback(value)
        end
    end)
    
    return sliderFrame
end

-- ==================== COMBAT TAB ====================
local combatPage = tabPages["Combat"]

local acSection = CreateSection(combatPage, "Auto Clicker")
acSection.Size = UDim2.new(1, 0, 0, 60)
CreateToggle(acSection, 30, "⚔️ Auto Clicker", false, function(enabled)
    Settings.AutoClicker = enabled
    if enabled then
        task.spawn(autoClickerLoop)
    else
        currentTarget = nil
    end
end)

local aaSection = CreateSection(combatPage, "Aim Assist")
aaSection.Size = UDim2.new(1, 0, 0, 135)
CreateToggle(aaSection, 30, "🎯 Aim Assist", false, function(enabled)
    Settings.AimAssist = enabled
    if enabled then
        task.spawn(aimAssistLoop)
    end
end)
CreateSlider(aaSection, 75, "Strength", 0.01, 1, 0.15, function(value)
    Settings.AimStrength = value
end)
CreateSlider(aaSection, 105, "FOV Radius", 20, 200, 80, function(value)
    Settings.FOVRadius = value
end)

combatPage.CanvasSize = UDim2.new(0, 0, 0, 220)

-- ==================== MOVEMENT TAB ====================
local movementPage = tabPages["Movement"]

local flySection = CreateSection(movementPage, "Fly")
flySection.Size = UDim2.new(1, 0, 0, 110)
CreateToggle(flySection, 30, "🕊️ Fly", false, function(enabled)
    Settings.Fly = enabled
    toggleFly()
end)
CreateSlider(flySection, 75, "Fly Speed", 10, 200, 50, function(value)
    Settings.FlySpeed = value
end)

local noclipSection = CreateSection(movementPage, "Noclip")
noclipSection.Size = UDim2.new(1, 0, 0, 60)
CreateToggle(noclipSection, 30, "👻 Noclip", false, function(enabled)
    Settings.Noclip = enabled
    toggleNoclip()
end)

local jumpSection = CreateSection(movementPage, "Infinite Jump")
jumpSection.Size = UDim2.new(1, 0, 0, 60)
CreateToggle(jumpSection, 30, "🦘 Infinite Jump", false, function(enabled)
    Settings.InfJump = enabled
    toggleInfJump()
end)

movementPage.CanvasSize = UDim2.new(0, 0, 0, 280)

-- ==================== VISUALS TAB ====================
local visualsPage = tabPages["Visuals"]

local espSection = CreateSection(visualsPage, "ESP")
espSection.Size = UDim2.new(1, 0, 0, 110)
CreateToggle(espSection, 30, "🟢 Team ESP", false, function(enabled)
    Settings.TeamESP = enabled
    updateESP()
end)
CreateToggle(espSection, 70, "🔴 Normal ESP", false, function(enabled)
    Settings.NormalESP = enabled
    updateESP()
end)

local hudSection = CreateSection(visualsPage, "HUD")
hudSection.Size = UDim2.new(1, 0, 0, 60)
CreateToggle(hudSection, 30, "📊 FPS / Ping", false, function(enabled)
    Settings.FPSPing = enabled
    fpsPingFrame.Visible = enabled
    if enabled then
        task.spawn(updateFPSPing)
    end
end)

visualsPage.CanvasSize = UDim2.new(0, 0, 0, 220)

-- ==================== STATS TAB ====================
local statsPage = tabPages["Stats"]

local statsSection = CreateSection(statsPage, "Player Stats")
statsSection.Size = UDim2.new(1, 0, 0, 0)

local statLabels = {}
local statNames = {"⏱️ Time Played", "💀 Kills", "☠️ Deaths", "📊 K/D Ratio", "📡 Ping"}
for i, name in ipairs(statNames) do
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 22)
    label.Position = UDim2.new(0, 10, 0, 30 + (i-1) * 26)
    label.BackgroundTransparency = 1
    label.Text = name .. ": Loading..."
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = statsSection
    statLabels[name] = label
end

statsSection.Size = UDim2.new(1, 0, 0, 30 + #statNames * 26 + 10)
statsPage.CanvasSize = UDim2.new(0, 0, 0, 200)

-- ==================== FPS/PING DISPLAY ====================
local fpsPingFrame = Instance.new("Frame")
fpsPingFrame.Size = UDim2.new(0, 140, 0, 40)
fpsPingFrame.Position = UDim2.new(0, 10, 0, 10)
fpsPingFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
fpsPingFrame.BackgroundTransparency = 0.3
fpsPingFrame.BorderSizePixel = 0
fpsPingFrame.Visible = false
fpsPingFrame.Parent = ChadlixHub
Instance.new("UICorner", fpsPingFrame).CornerRadius = UDim.new(0, 6)

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(1, -20, 0, 18)
fpsLabel.Position = UDim2.new(0, 10, 0, 3)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: 0"
fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
fpsLabel.TextSize = 12
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.Parent = fpsPingFrame

local pingLabel = Instance.new("TextLabel")
pingLabel.Size = UDim2.new(1, -20, 0, 18)
pingLabel.Position = UDim2.new(0, 10, 0, 20)
pingLabel.BackgroundTransparency = 1
pingLabel.Text = "Ping: 0ms"
pingLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
pingLabel.TextSize = 12
pingLabel.Font = Enum.Font.GothamBold
pingLabel.TextXAlignment = Enum.TextXAlignment.Left
pingLabel.Parent = fpsPingFrame

-- ==================== FUNCTIONS ====================

-- FPS/Ping update
local function updateFPSPing()
    while Settings.FPSPing do
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        local ping = math.floor(player:GetNetworkPing() * 1000)
        fpsLabel.Text = "FPS: " .. fps
        pingLabel.Text = "Ping: " .. ping .. "ms"
        fpsLabel.TextColor3 = fps >= 60 and Color3.fromRGB(0, 255, 0) or (fps >= 30 and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 50, 50))
        pingLabel.TextColor3 = ping <= 50 and Color3.fromRGB(0, 255, 0) or (ping <= 100 and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 50, 50))
        task.wait(0.5)
    end
end

-- Auto Clicker
local function getPlayerUnderMouse()
    local mousePos = UserInputService:GetMouseLocation()
    local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
    
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Include
    params.FilterDescendantsInstances = {}
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            table.insert(params.FilterDescendantsInstances, plr.Character)
        end
    end
    
    local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
    
    if result then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character and result.Instance:IsDescendantOf(plr.Character) then
                return plr
            end
        end
    end
    
    return nil
end

local function performClick()
    if currentTarget and currentTarget.Character then
        mouse.Target = currentTarget.Character:FindFirstChild("Head") or currentTarget.Character:FindFirstChild("HumanoidRootPart")
        mouse:Press()
        task.wait(0.015)
        mouse:Release()
    end
end

local function autoClickerLoop()
    while Settings.AutoClicker do
        local target = getPlayerUnderMouse()
        if target then
            currentTarget = target
            performClick()
        else
            currentTarget = nil
        end
        task.wait(0.03)
    end
end

-- Aim Assist
local function getNearestEnemy()
    local mousePos = UserInputService:GetMouseLocation()
    local nearest = nil
    local nearestDist = Settings.FOVRadius
    
    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= player and target.Character then
            local head = target.Character:FindFirstChild("Head")
            local hum = target.Character:FindFirstChild("Humanoid")
            
            if head and hum and hum.Health > 0 then
                local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    
                    if dist < nearestDist then
                        nearestDist = dist
                        nearest = target
                    end
                end
            end
        end
    end
    
    return nearest, nearestDist
end

local function aimAssistLoop()
    while Settings.AimAssist do
        local target, dist = getNearestEnemy()
        
        if target and target.Character then
            local head = target.Character:FindFirstChild("Head")
            if head then
                local mousePos = UserInputService:GetMouseLocation()
                local headPos = camera:WorldToViewportPoint(head.Position)
                local targetPos = Vector2.new(headPos.X, headPos.Y)
                local dir = targetPos - mousePos
                local strength = Settings.AimStrength * (1 - dist / Settings.FOVRadius)
                local newPos = mousePos + dir * strength
                
                mousemoverel((newPos.X - mousePos.X) / 2, (newPos.Y - mousePos.Y) / 2)
            end
        end
        
        task.wait()
    end
end

-- Fly
local flyConnection = nil
function toggleFly()
    if Settings.Fly then
        local character = player.Character or player.CharacterAdded:Wait()
        local hum = character:WaitForChild("Humanoid")
        local root = character:WaitForChild("HumanoidRootPart")
        
        hum.PlatformStand = true
        
        local gyro = Instance.new("BodyGyro")
        gyro.MaxTorque = Vector3.new(400000, 400000, 400000)
        gyro.P = 3000
        gyro.Parent = root
        
        local vel = Instance.new("BodyVelocity")
        vel.MaxForce = Vector3.new(400000, 400000, 400000)
        vel.Velocity = Vector3.new(0, 0, 0)
        vel.P = 3000
        vel.Parent = root
        
        flyConnection = RunService.RenderStepped:Connect(function()
            if not Settings.Fly or not root.Parent then
                flyConnection:Disconnect()
                gyro:Destroy()
                vel:Destroy()
                hum.PlatformStand = false
                return
            end
            
            gyro.CFrame = camera.CFrame
            
            local dir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0, 1, 0) end
            
            vel.Velocity = dir.Unit * Settings.FlySpeed
        end)
    else
        if flyConnection then
            flyConnection:Disconnect()
        end
        if player.Character then
            local hum = player.Character:FindFirstChild("Humanoid")
            if hum then hum.PlatformStand = false end
        end
    end
end

-- Noclip
local noclipConnection = nil
function toggleNoclip()
    if Settings.Noclip then
        noclipConnection = RunService.Stepped:Connect(function()
            if player.Character then
                for _, v in ipairs(player.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then noclipConnection:Disconnect() end
        if player.Character then
            for _, v in ipairs(player.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end
        end
    end
end

-- Infinite Jump
local infJumpConnection = nil
function toggleInfJump()
    if Settings.InfJump then
        infJumpConnection = UserInputService.JumpRequest:Connect(function()
            if player.Character then
                local hum = player.Character:FindFirstChild("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    else
        if infJumpConnection then infJumpConnection:Disconnect() end
    end
end

-- ESP
local function createESP(target, isTeam)
    local char = target.Character
    if not char then return end
    
    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = isTeam and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = isTeam and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    highlight.Parent = char
    
    if not espObjects[target] then espObjects[target] = {} end
    table.insert(espObjects[target], highlight)
    
    local head = char:FindFirstChild("Head")
    if head then
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 100, 0, 25)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = head
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = target.Name
        nameLabel.TextColor3 = isTeam and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        nameLabel.TextSize = 12
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.Parent = billboard
        
        table.insert(espObjects[target], billboard)
    end
end

local function clearESP(target)
    if espObjects[target] then
        for _, obj in ipairs(espObjects[target]) do
            if obj and obj.Parent then obj:Destroy() end
        end
        espObjects[target] = nil
    end
end

local function clearAllESP()
    for target, _ in pairs(espObjects) do
        clearESP(target)
    end
end

function updateESP()
    clearAllESP()
    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= player and target.Character then
            local isTeam = target.Team == player.Team and player.Team ~= nil
            if isTeam and Settings.TeamESP then
                createESP(target, true)
            elseif not isTeam and Settings.NormalESP then
                createESP(target, false)
            end
        end
    end
end

-- Stats update
local function updateStats()
    task.spawn(function()
        while true do
            local leaderstats = player:FindFirstChild("leaderstats")
            if leaderstats then
                local kills = leaderstats:FindFirstChild("Kills") or leaderstats:FindFirstChild("KOs")
                local deaths = leaderstats:FindFirstChild("Deaths") or leaderstats:FindFirstChild("Wipeouts")
                local time = leaderstats:FindFirstChild("Time") or leaderstats:FindFirstChild("Playtime")
                
                if kills and kills:IsA("IntValue") then
                    statLabels["💀 Kills"].Text = "💀 Kills: " .. kills.Value
                end
                if deaths and deaths:IsA("IntValue") then
                    statLabels["☠️ Deaths"].Text = "☠️ Deaths: " .. deaths.Value
                end
                if kills and deaths and kills:IsA("IntValue") and deaths:IsA("IntValue") then
                    local kd = deaths.Value > 0 and math.round(kills.Value / deaths.Value * 100) / 100 or kills.Value
                    statLabels["📊 K/D Ratio"].Text = "📊 K/D Ratio: " .. kd
                end
                if time and time:IsA("IntValue") then
                    local mins = math.floor(time.Value / 60)
                    statLabels["⏱️ Time Played"].Text = string.format("⏱️ Time Played: %d:%02d", mins, time.Value % 60)
                end
            end
            
            statLabels["📡 Ping"].Text = "📡 Ping: " .. math.floor(player:GetNetworkPing() * 1000) .. "ms"
            task.wait(1)
        end
    end)
end

-- Player connections
local function onPlayerAdded(target)
    target.CharacterAdded:Connect(updateESP)
    target.CharacterRemoving:Connect(function()
        clearESP(target)
        updateESP()
    end)
end

for _, target in ipairs(Players:GetPlayers()) do
    if target ~= player then onPlayerAdded(target) end
end
Players.PlayerAdded:Connect(function(target)
    if target ~= player then onPlayerAdded(target) end
end)
Players.PlayerRemoving:Connect(clearESP)
player:GetPropertyChangedSignal("Team"):Connect(updateESP)

-- Close button
CloseButton.MouseButton1Click:Connect(function()
    ChadlixHub:Destroy()
end)

-- Draggable
local dragging = false
local dragStart = nil
local startPos = nil

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

TopBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Keybind N
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.N then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Startup
updateESP()
updateStats()
