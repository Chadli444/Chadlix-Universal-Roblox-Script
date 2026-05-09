--[[ CHADLIX UNIVERSAL HUB - FIXED VERSION ]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

-- Settings
local Settings = {
    AutoClicker = false,
    AutoShoot = false,
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

local espObjects = {}

-- Create GUI (using PlayerGui instead of CoreGui)
local ChadlixHub = Instance.new("ScreenGui")
ChadlixHub.Name = "ChadlixHub"
ChadlixHub.Parent = player:WaitForChild("PlayerGui")

-- Main Container
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
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

local TopCover = Instance.new("Frame")
TopCover.Size = UDim2.new(1, 0, 0, 20)
TopCover.Position = UDim2.new(0, 0, 0.5, 0)
TopCover.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
TopCover.BorderSizePixel = 0
TopCover.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "CHADLIX HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

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
local tabs = {"Combat", "Movement", "Visuals"}
local tabButtons = {}
local currentTab = "Combat"

for i, tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 140, 0, 35)
    btn.Position = UDim2.new(0, 10 + (i-1)*150, 0, 50)
    btn.BackgroundColor3 = i == 1 and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(35, 35, 40)
    btn.BorderSizePixel = 0
    btn.Text = tabName
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    tabButtons[tabName] = btn
    
    btn.MouseButton1Click:Connect(function()
        currentTab = tabName
        for name, b in pairs(tabButtons) do
            b.BackgroundColor3 = name == tabName and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(35, 35, 40)
        end
        updateContent()
    end)
end

-- Content Area
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -100)
ContentFrame.Position = UDim2.new(0, 10, 0, 95)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Helper functions
local function makeToggle(label, position, default, callback)
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, -20, 0, 40)
    toggleBtn.Position = UDim2.new(0, 10, 0, position)
    toggleBtn.BackgroundColor3 = default and Color3.fromRGB(30, 130, 30) or Color3.fromRGB(60, 60, 65)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = label .. (default and " ON" or " OFF")
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 14
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = ContentFrame
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)
    
    local enabled = default
    
    toggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        toggleBtn.Text = label .. (enabled and " ON" or " OFF")
        toggleBtn.BackgroundColor3 = enabled and Color3.fromRGB(30, 130, 30) or Color3.fromRGB(60, 60, 65)
        callback(enabled)
    end)
    
    return toggleBtn
end

local function makeSlider(label, position, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -20, 0, 50)
    sliderFrame.Position = UDim2.new(0, 10, 0, position)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = ContentFrame
    Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(0, 8)
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(1, -10, 0, 20)
    valueLabel.Position = UDim2.new(0, 5, 0, 3)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = label..": "..default
    valueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
    valueLabel.Parent = sliderFrame
    
    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(1, -10, 0, 6)
    slider.Position = UDim2.new(0, 5, 0, 28)
    slider.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    slider.BorderSizePixel = 0
    slider.Text = ""
    slider.Parent = sliderFrame
    Instance.new("UICorner", slider).CornerRadius = UDim.new(0, 3)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
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
            valueLabel.Text = label..": "..value
            callback(value)
        end
    end)
end

-- Clear and rebuild content
function updateContent()
    for _, child in ipairs(ContentFrame:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    if currentTab == "Combat" then
        makeToggle("Auto Clicker", 10, false, function(on) Settings.AutoClicker = on; if on then coroutine.wrap(autoClickerLoop)() end end)
        makeToggle("Auto Shoot", 55, false, function(on) Settings.AutoShoot = on; if on then coroutine.wrap(autoShootLoop)() end end)
        makeToggle("Aim Assist", 100, false, function(on) Settings.AimAssist = on; if on then coroutine.wrap(aimAssistLoop)() end end)
        makeSlider("Aim Strength", 150, 0.01, 1, 0.15, function(v) Settings.AimStrength = v end)
        makeSlider("FOV Radius", 210, 20, 200, 80, function(v) Settings.FOVRadius = v end)
    
    elseif currentTab == "Movement" then
        makeToggle("Fly", 10, false, function(on) Settings.Fly = on; toggleFly() end)
        makeSlider("Fly Speed", 55, 10, 200, 50, function(v) Settings.FlySpeed = v end)
        makeToggle("Noclip", 115, false, function(on) Settings.Noclip = on; toggleNoclip() end)
        makeToggle("Infinite Jump", 160, false, function(on) Settings.InfJump = on; toggleInfJump() end)
    
    elseif currentTab == "Visuals" then
        makeToggle("Team ESP", 10, false, function(on) Settings.TeamESP = on; updateESP() end)
        makeToggle("Normal ESP", 55, false, function(on) Settings.NormalESP = on; updateESP() end)
        makeToggle("FPS / Ping", 100, false, function(on) Settings.FPSPing = on; fpsPingFrame.Visible = on; if on then coroutine.wrap(updateFPSPing)() end end)
    end
end

-- FPS/Ping Display
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

local function updateFPSPing()
    while Settings.FPSPing do
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        fpsLabel.Text = "FPS: "..fps
        fpsLabel.TextColor3 = fps >= 60 and Color3.fromRGB(0, 255, 0) or (fps >= 30 and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 50, 50))
        pingLabel.Text = "Ping: "..math.floor(player:GetNetworkPing() * 1000).."ms"
        pingLabel.TextColor3 = player:GetNetworkPing() <= 0.05 and Color3.fromRGB(0, 255, 0) or (player:GetNetworkPing() <= 0.1 and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 50, 50))
        task.wait(0.5)
    end
end

-- Get player under mouse
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

-- Auto Clicker
function autoClickerLoop()
    while Settings.AutoClicker do
        local target = getPlayerUnderMouse()
        if target and target.Character then
            local part = target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
            if part then
                mouse.Target = part
                mouse1press()
                wait(0.01)
                mouse1release()
            end
        end
        wait(0.03)
    end
end

-- Auto Shoot
function autoShootLoop()
    while Settings.AutoShoot do
        local target = getPlayerUnderMouse()
        local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
        
        if target and tool then
            -- Try all fire methods
            pcall(function() tool:Activate() end)
            
            -- Fire remotes
            for _, obj in ipairs(tool:GetDescendants()) do
                if obj:IsA("RemoteEvent") then
                    pcall(function() obj:FireServer() end)
                end
            end
            
            -- Activation via mouse
            pcall(function()
                mouse1press()
                wait(0.01)
                mouse1release()
            end)
        end
        wait(0.07)
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
                local pos, onScreen = camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
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

function aimAssistLoop()
    while Settings.AimAssist do
        local target, dist = getNearestEnemy()
        if target and target.Character then
            local head = target.Character:FindFirstChild("Head")
            if head then
                local mousePos = UserInputService:GetMouseLocation()
                local headPos = camera:WorldToViewportPoint(head.Position)
                local dir = Vector2.new(headPos.X, headPos.Y) - mousePos
                local strength = Settings.AimStrength * (1 - dist / Settings.FOVRadius)
                local newPos = mousePos + dir * strength
                mousemoverel((newPos.X - mousePos.X) / 2, (newPos.Y - mousePos.Y) / 2)
            end
        end
        wait()
    end
end

-- Fly
local flyConnection
function toggleFly()
    if Settings.Fly then
        local char = player.Character or player.CharacterAdded:Wait()
        local hum = char:WaitForChild("Humanoid")
        local root = char:WaitForChild("HumanoidRootPart")
        
        if flyConnection then flyConnection:Disconnect() end
        for _, v in ipairs(root:GetChildren()) do
            if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then v:Destroy() end
        end
        
        hum.PlatformStand = true
        
        local gyro = Instance.new("BodyGyro", root)
        gyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        gyro.P = 3000
        
        local vel = Instance.new("BodyVelocity", root)
        vel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        vel.P = 3000
        
        flyConnection = RunService.RenderStepped:Connect(function()
            if not Settings.Fly or not root or not root.Parent then
                if flyConnection then flyConnection:Disconnect() end
                gyro:Destroy(); vel:Destroy()
                if hum then hum.PlatformStand = false end
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
            if dir.Magnitude > 0 then vel.Velocity = dir.Unit * Settings.FlySpeed end
        end)
    else
        if flyConnection then flyConnection:Disconnect() end
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

-- Noclip
local noclipConnection
function toggleNoclip()
    if Settings.Noclip then
        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = RunService.Stepped:Connect(function()
            if player.Character then
                for _, v in ipairs(player.Character:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
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
local infJumpConnection
function toggleInfJump()
    if Settings.InfJump then
        if infJumpConnection then infJumpConnection:Disconnect() end
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
    -- Clear all first
    for target, _ in pairs(espObjects) do
        clearESP(target)
    end
    
    -- Create new ESP
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

-- Player connections
for _, target in ipairs(Players:GetPlayers()) do
    if target ~= player then
        target.CharacterAdded:Connect(updateESP)
        target.CharacterRemoving:Connect(function() clearESP(target); updateESP() end)
    end
end
Players.PlayerAdded:Connect(function(target)
    target.CharacterAdded:Connect(updateESP)
end)
Players.PlayerRemoving:Connect(function(target) clearESP(target) end)
player:GetPropertyChangedSignal("Team"):Connect(updateESP)

-- Respawn handling
player.CharacterAdded:Connect(function()
    if Settings.Fly then
        wait(0.1)
        Settings.Fly = false
        Settings.Fly = true
        toggleFly()
    end
end)

-- Close
CloseButton.MouseButton1Click:Connect(function() ChadlixHub:Destroy() end)

-- Keybind N
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.N then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Init
updateESP()
updateContent()
