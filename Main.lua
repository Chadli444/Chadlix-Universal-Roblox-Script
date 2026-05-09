--[[
    CHADLIX UNIVERSAL HUB - FULL WORKING VERSION
    Auto clicker + Aim assist + ESP + Fly + Noclip + Inf Jump + FPS/Ping + Stats
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

-- Settings (persisted across tab switches)
local Settings = {
    AutoClicker = false,
    AimAssist = false,
    TeamESP = false,
    NormalESP = false,
    FPSPing = false,
    Fly = false,
    Noclip = false,
    InfJump = false,
    AimStrength = 0.3,
    FOVRadius = 120,
    FlySpeed = 50
}

-- Storage for connections / ESP objects
local Connections = {
    autoClicker = nil,
    aimAssist = nil,
    fpsPing = nil,
    fly = nil,
    noclip = nil,
    infJump = nil
}
local espObjects = {}

-- ==================== GUI SETUP ====================
local ChadlixHub = Instance.new("ScreenGui")
ChadlixHub.Name = "ChadlixHub"
ChadlixHub.ResetOnSpawn = false   -- Stays after death
ChadlixHub.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 340)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ChadlixHub
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)
-- Cover bottom corners of top bar
local TopCover = Instance.new("Frame")
TopCover.Size = UDim2.new(1, 0, 0, 20)
TopCover.Position = UDim2.new(0, 0, 0.5, 0)
TopCover.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
TopCover.BorderSizePixel = 0
TopCover.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 200, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "CHADLIX HUB"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 18
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 28, 0, 28)
CloseButton.Position = UDim2.new(1, -36, 0, 6)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TopBar
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 6)

-- Tab Buttons
local Tabs = {
    {name = "Combat", icon = "⚔️"},
    {name = "Movement", icon = "🏃"},
    {name = "Visuals", icon = "👁️"},
    {name = "Stats", icon = "📊"}
}
local tabButtons = {}
local currentTab = "Combat"

for i, tabData in ipairs(Tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 105, 0, 32)
    btn.Position = UDim2.new(0, 10 + (i-1)*113, 0, 48)
    btn.BackgroundColor3 = i == 1 and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(35, 35, 40)
    btn.BorderSizePixel = 0
    btn.Text = tabData.icon .. " " .. tabData.name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    tabButtons[tabData.name] = btn

    btn.MouseButton1Click:Connect(function()
        currentTab = tabData.name
        for name, b in pairs(tabButtons) do
            b.BackgroundColor3 = name == tabData.name and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(35, 35, 40)
        end
        refreshContent()
    end)
end

-- Content area
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -95)
ContentFrame.Position = UDim2.new(0, 10, 0, 90)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Helper to create a toggle button
local function makeToggle(label, yPos, default, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 38)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = default and Color3.fromRGB(30, 130, 30) or Color3.fromRGB(60, 60, 65)
    btn.BorderSizePixel = 0
    btn.Text = label .. " : " .. (default and "ON" or "OFF")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.Parent = ContentFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local enabled = default
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.Text = label .. " : " .. (enabled and "ON" or "OFF")
        btn.BackgroundColor3 = enabled and Color3.fromRGB(30, 130, 30) or Color3.fromRGB(60, 60, 65)
        callback(enabled, btn)
    end)
    return btn
end

-- Helper to create a slider
local function makeSlider(label, yPos, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 50)
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    frame.BorderSizePixel = 0
    frame.Parent = ContentFrame
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(1, -10, 0, 20)
    valueLabel.Position = UDim2.new(0, 5, 0, 3)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = label .. ": " .. default
    valueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
    valueLabel.Parent = frame

    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(1, -10, 0, 6)
    slider.Position = UDim2.new(0, 5, 0, 28)
    slider.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    slider.BorderSizePixel = 0
    slider.Text = ""
    slider.Parent = frame
    Instance.new("UICorner", slider).CornerRadius = UDim.new(0, 3)

    local fill = Instance.new("Frame")
    local percent = (default - min) / (max - min)
    fill.Size = UDim2.new(percent, 0, 1, 0)
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
            local p = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
            local value = math.round((min + (max - min) * p) * 100) / 100
            fill.Size = UDim2.new(p, 0, 1, 0)
            valueLabel.Text = label .. ": " .. value
            callback(value)
        end
    end)
end

-- Clear and rebuild content based on current tab
local contentElements = {}

function refreshContent()
    -- Delete old buttons/frames in content area
    for _, child in ipairs(ContentFrame:GetChildren()) do
        child:Destroy()
    end
    contentElements = {}

    if currentTab == "Combat" then
        makeToggle("Auto Clicker", 10, Settings.AutoClicker, function(on) Settings.AutoClicker = on; if on then startAutoClicker() else stopAutoClicker() end end)
        makeToggle("Aim Assist", 55, Settings.AimAssist, function(on) Settings.AimAssist = on; if on then startAimAssist() else stopAimAssist() end end)
        makeSlider("Aim Strength", 105, 0.01, 1, Settings.AimStrength, function(v) Settings.AimStrength = v end)
        makeSlider("FOV Radius", 165, 20, 200, Settings.FOVRadius, function(v) Settings.FOVRadius = v end)

    elseif currentTab == "Movement" then
        makeToggle("Fly", 10, Settings.Fly, function(on) Settings.Fly = on; toggleFly() end)
        makeSlider("Fly Speed", 55, 10, 200, Settings.FlySpeed, function(v) Settings.FlySpeed = v end)
        makeToggle("Noclip", 115, Settings.Noclip, function(on) Settings.Noclip = on; toggleNoclip() end)
        makeToggle("Infinite Jump", 160, Settings.InfJump, function(on) Settings.InfJump = on; toggleInfJump() end)

    elseif currentTab == "Visuals" then
        makeToggle("Team ESP", 10, Settings.TeamESP, function(on) Settings.TeamESP = on; updateESP() end)
        makeToggle("Normal ESP", 55, Settings.NormalESP, function(on) Settings.NormalESP = on; updateESP() end)
        makeToggle("FPS / Ping", 100, Settings.FPSPing, function(on) Settings.FPSPing = on; fpsPingFrame.Visible = on; if on then startFPSPing() else stopFPSPing() end end)

    elseif currentTab == "Stats" then
        local statsFrame = Instance.new("Frame")
        statsFrame.Size = UDim2.new(1, -20, 0, 200)
        statsFrame.Position = UDim2.new(0, 10, 0, 10)
        statsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        statsFrame.BorderSizePixel = 0
        statsFrame.Parent = ContentFrame
        Instance.new("UICorner", statsFrame).CornerRadius = UDim.new(0, 8)
        table.insert(contentElements, statsFrame)

        local statLabels = {}
        local names = {"Time Played", "Kills", "Deaths", "K/D Ratio", "Ping"}
        local icons = {"⏱️", "💀", "☠️", "📊", "📡"}

        for i, name in ipairs(names) do
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -20, 0, 28)
            label.Position = UDim2.new(0, 10, 0, 10 + (i-1)*34)
            label.BackgroundTransparency = 1
            label.Text = icons[i] .. " " .. name .. ": --"
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.TextSize = 14
            label.Font = Enum.Font.GothamBold
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = statsFrame
            statLabels[name] = label
        end
        startStatsUpdater(statLabels)
    end
end

-- ==================== FPS / PING DISPLAY ====================
local fpsPingFrame = Instance.new("Frame")
fpsPingFrame.Size = UDim2.new(0, 130, 0, 36)
fpsPingFrame.Position = UDim2.new(0, 10, 0, 10)
fpsPingFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
fpsPingFrame.BackgroundTransparency = 0.4
fpsPingFrame.BorderSizePixel = 0
fpsPingFrame.Visible = false
fpsPingFrame.Parent = ChadlixHub
Instance.new("UICorner", fpsPingFrame).CornerRadius = UDim.new(0, 6)

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(1, -10, 0, 17)
fpsLabel.Position = UDim2.new(0, 5, 0, 1)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: 0"
fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
fpsLabel.TextSize = 13
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.Parent = fpsPingFrame

local pingLabel = Instance.new("TextLabel")
pingLabel.Size = UDim2.new(1, -10, 0, 17)
pingLabel.Position = UDim2.new(0, 5, 0, 18)
pingLabel.BackgroundTransparency = 1
pingLabel.Text = "Ping: 0ms"
pingLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
pingLabel.TextSize = 13
pingLabel.Font = Enum.Font.GothamBold
pingLabel.TextXAlignment = Enum.TextXAlignment.Left
pingLabel.Parent = fpsPingFrame

function updateFPSPing()
    while Settings.FPSPing do
        local dt = task.wait(0.5)
        local fps = math.floor(1 / dt)
        local ping = math.floor(player:GetNetworkPing() * 1000)
        fpsLabel.Text = "FPS: " .. fps
        pingLabel.Text = "Ping: " .. ping .. "ms"
        fpsLabel.TextColor3 = fps >= 60 and Color3.fromRGB(0, 255, 0) or (fps >= 30 and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 50, 50))
        pingLabel.TextColor3 = ping <= 80 and Color3.fromRGB(0, 255, 0) or (ping <= 150 and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 50, 50))
    end
end

function startFPSPing()
    if Connections.fpsPing then Connections.fpsPing:Disconnect() end
    Connections.fpsPing = coroutine.wrap(function() updateFPSPing() end)
    Connections.fpsPing()
end

function stopFPSPing()
    if Connections.fpsPing then Connections.fpsPing:Disconnect() end
end

-- ==================== AUTO CLICKER (the core feature) ====================
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

    local result = workspace:Raycast(ray.Origin, ray.Direction * 999, params)
    if result then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character and result.Instance:IsDescendantOf(plr.Character) then
                return plr
            end
        end
    end
    return nil
end

function autoClickerLoop()
    while Settings.AutoClicker do
        local target = getPlayerUnderMouse()
        if target and target.Character then
            -- Left click simulation
            mouse1press()
            task.wait(0.005)
            mouse1release()
        end
        task.wait(0.03) -- click every 0.03 sec when on target
    end
end

function startAutoClicker()
    if Connections.autoClicker then Connections.autoClicker:Disconnect() end
    Connections.autoClicker = coroutine.wrap(function() autoClickerLoop() end)
    Connections.autoClicker()
end

function stopAutoClicker()
    if Connections.autoClicker then Connections.autoClicker:Disconnect() end
end

-- ==================== AIM ASSIST ====================
local function getNearestEnemy()
    local mousePos = UserInputService:GetMouseLocation()
    local nearest = nil
    local nearestDist = Settings.FOVRadius

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            local hum = plr.Character:FindFirstChild("Humanoid")
            if head and hum and hum.Health > 0 then
                local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearest = plr
                    end
                end
            end
        end
    end
    return nearest, nearestDist
end

function aimAssistLoop()
    while Settings.AimAssist do
        local target, dist = getNearestEnemy()
        if target and target.Character then
            local head = target.Character:FindFirstChild("Head")
            if head then
                local mousePos = UserInputService:GetMouseLocation()
                local headScreenPos = camera:WorldToViewportPoint(head.Position)
                local direction = Vector2.new(headScreenPos.X, headScreenPos.Y) - mousePos
                local strength = Settings.AimStrength * (1 - dist / Settings.FOVRadius)
                local newPos = mousePos + direction * strength

                local deltaX = newPos.X - mousePos.X
                local deltaY = newPos.Y - mousePos.Y
                mousemoverel(deltaX, deltaY)
            end
        end
        task.wait()
    end
end

function startAimAssist()
    if Connections.aimAssist then Connections.aimAssist:Disconnect() end
    Connections.aimAssist = coroutine.wrap(function() aimAssistLoop() end)
    Connections.aimAssist()
end

function stopAimAssist()
    if Connections.aimAssist then Connections.aimAssist:Disconnect() end
end

-- ==================== MOVEMENT FEATURES ====================
function toggleFly()
    if Settings.Fly then
        -- Clean previous fly
        if Connections.fly then Connections.fly:Disconnect() end
        local char = player.Character or player.CharacterAdded:Wait()
        local hum = char:WaitForChild("Humanoid")
        local root = char:WaitForChild("HumanoidRootPart")

        for _, v in ipairs(root:GetChildren()) do
            if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then v:Destroy() end
        end

        hum.PlatformStand = true

        local gyro = Instance.new("BodyGyro")
        gyro.MaxTorque = Vector3.new(400000, 400000, 400000)
        gyro.P = 3000
        gyro.Parent = root

        local vel = Instance.new("BodyVelocity")
        vel.MaxForce = Vector3.new(400000, 400000, 400000)
        vel.P = 3000
        vel.Parent = root

        Connections.fly = RunService.RenderStepped:Connect(function()
            if not Settings.Fly or not root or not root.Parent then
                if Connections.fly then Connections.fly:Disconnect() end
                gyro:Destroy(); vel:Destroy()
                if hum then hum.PlatformStand = false end
                return
            end
            gyro.CFrame = camera.CFrame
            local move = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0, 1, 0) end
            if move.Magnitude > 0 then
                vel.Velocity = move.Unit * Settings.FlySpeed
            else
                vel.Velocity = Vector3.new(0, 0, 0)
            end
        end)
    else
        if Connections.fly then Connections.fly:Disconnect() end
        if player.Character then
            local hum = player.Character:FindFirstChild("Humanoid")
            if hum then hum.PlatformStand = false end
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                for _, v in ipairs(root:GetChildren()) do
                    if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then v:Destroy() end
                end
            end
        end
    end
end

function toggleNoclip()
    if Settings.Noclip then
        if Connections.noclip then Connections.noclip:Disconnect() end
        Connections.noclip = RunService.Stepped:Connect(function()
            if player.Character then
                for _, v in ipairs(player.Character:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end)
    else
        if Connections.noclip then Connections.noclip:Disconnect() end
        if player.Character then
            for _, v in ipairs(player.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end
        end
    end
end

function toggleInfJump()
    if Settings.InfJump then
        if Connections.infJump then Connections.infJump:Disconnect() end
        Connections.infJump = UserInputService.JumpRequest:Connect(function()
            local char = player.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    else
        if Connections.infJump then Connections.infJump:Disconnect() end
    end
end

-- ==================== ESP ====================
local function createESP(target, isTeam)
    clearESP(target)
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
        billboard.Size = UDim2.new(0, 100, 0, 20)
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

function updateESP()
    for target, _ in pairs(espObjects) do clearESP(target) end

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

-- ==================== STATS ====================
function startStatsUpdater(statLabels)
    task.spawn(function()
        while true do
            local leaderstats = player:FindFirstChild("leaderstats")
            if leaderstats then
                local kills = leaderstats:FindFirstChild("Kills") or leaderstats:FindFirstChild("KOs")
                local deaths = leaderstats:FindFirstChild("Deaths") or leaderstats:FindFirstChild("Wipeouts")
                local time = leaderstats:FindFirstChild("Time") or leaderstats:FindFirstChild("Playtime")

                if kills and kills:IsA("IntValue") then
                    statLabels["Kills"].Text = "💀 Kills: " .. kills.Value
                end
                if deaths and deaths:IsA("IntValue") then
                    statLabels["Deaths"].Text = "☠️ Deaths: " .. deaths.Value
                end
                if kills and deaths and kills:IsA("IntValue") and deaths:IsA("IntValue") then
                    local kd = deaths.Value > 0 and math.round(kills.Value / deaths.Value * 100) / 100 or kills.Value
                    statLabels["K/D Ratio"].Text = "📊 K/D Ratio: " .. kd
                end
                if time and time:IsA("IntValue") then
                    local mins = math.floor(time.Value / 60)
                    local secs = time.Value % 60
                    statLabels["Time Played"].Text = "⏱️ Time Played: " .. mins .. "m " .. secs .. "s"
                end
            end
            statLabels["Ping"].Text = "📡 Ping: " .. math.floor(player:GetNetworkPing() * 1000) .. "ms"
            task.wait(1)
        end
    end)
end

-- ==================== PLAYER CONNECTIONS (ESP) ====================
for _, target in ipairs(Players:GetPlayers()) do
    if target ~= player then
        target.CharacterAdded:Connect(updateESP)
        target.CharacterRemoving:Connect(function() clearESP(target) end)
    end
end
Players.PlayerAdded:Connect(function(target)
    target.CharacterAdded:Connect(updateESP)
end)
Players.PlayerRemoving:Connect(function(target) clearESP(target) end)
player:GetPropertyChangedSignal("Team"):Connect(updateESP)

-- Respawn handling (re-enable fly if it was active)
player.CharacterAdded:Connect(function()
    if Settings.Fly then
        task.wait(0.2)
        Settings.Fly = false
        Settings.Fly = true
        toggleFly()
    end
end)

-- ==================== GUI INTERACTIONS ====================
CloseButton.MouseButton1Click:Connect(function() ChadlixHub:Destroy() end)

-- Toggle GUI with 'N'
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.N then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Start initial content and ESP
refreshContent()
updateESP()
