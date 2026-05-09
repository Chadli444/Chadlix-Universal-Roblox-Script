--[[
    CHADLIX AUTO SHOOT + AIM ASSIST
    Every possible fire method included
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Settings
local AimAssistEnabled = true
local AutoShootEnabled = true
local AimStrength = 0.3
local FOVRadius = 150

-- Create simple toggle GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 80)
frame.Position = UDim2.new(0, 10, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 20)
title.BackgroundTransparency = 1
title.Text = "AIM + SHOOT"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold

local aimToggle = Instance.new("TextButton", frame)
aimToggle.Size = UDim2.new(0.45, 0, 0, 30)
aimToggle.Position = UDim2.new(0.05, 0, 0, 25)
aimToggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
aimToggle.BorderSizePixel = 0
aimToggle.Text = "AIM: ON"
aimToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
aimToggle.TextSize = 11
aimToggle.Font = Enum.Font.GothamBold
Instance.new("UICorner", aimToggle).CornerRadius = UDim.new(0, 4)

local shootToggle = Instance.new("TextButton", frame)
shootToggle.Size = UDim2.new(0.45, 0, 0, 30)
shootToggle.Position = UDim2.new(0.5, 0, 0, 25)
shootToggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
shootToggle.BorderSizePixel = 0
shootToggle.Text = "SHOOT: ON"
shootToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
shootToggle.TextSize = 11
shootToggle.Font = Enum.Font.GothamBold
Instance.new("UICorner", shootToggle).CornerRadius = UDim.new(0, 4)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, 0, 0, 18)
status.Position = UDim2.new(0, 0, 0, 60)
status.BackgroundTransparency = 1
status.Text = "No target"
status.TextColor3 = Color3.fromRGB(255, 255, 255)
status.TextSize = 11
status.Font = Enum.Font.Gotham

-- Toggle functions
aimToggle.MouseButton1Click:Connect(function()
    AimAssistEnabled = not AimAssistEnabled
    aimToggle.Text = AimAssistEnabled and "AIM: ON" or "AIM: OFF"
    aimToggle.BackgroundColor3 = AimAssistEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
end)

shootToggle.MouseButton1Click:Connect(function()
    AutoShootEnabled = not AutoShootEnabled
    shootToggle.Text = AutoShootEnabled and "SHOOT: ON" or "SHOOT: OFF"
    shootToggle.BackgroundColor3 = AutoShootEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
end)

-- Get nearest enemy to crosshair
local function getNearestEnemy()
    local mousePos = UserInputService:GetMouseLocation()
    local nearest = nil
    local nearestDist = FOVRadius
    
    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= player and target.Character then
            local head = target.Character:FindFirstChild("Head")
            local humanoid = target.Character:FindFirstChild("Humanoid")
            
            if head and humanoid and humanoid.Health > 0 then
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

-- Get player under mouse via raycast
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

-- Fire weapon using ALL possible methods
local function fireWeapon()
    local character = player.Character
    if not character then return end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return end
    
    -- Method 1: Direct Activate
    pcall(function()
        if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
            tool:Activate()
        end
    end)
    
    -- Method 2: Mouse click simulation (multiple ways)
    pcall(function()
        mouse1click()
    end)
    
    pcall(function()
        mouse1press()
        task.wait(0.001)
        mouse1release()
    end)
    
    -- Method 3: VirtualInputManager
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.001)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
    
    -- Method 4: Fire all RemoteEvents in the tool
    for _, obj in ipairs(tool:GetDescendants()) do
        pcall(function()
            if obj:IsA("RemoteEvent") then
                obj:FireServer()
                obj:FireServer("MouseButton1")
                obj:FireServer("Activated")
            end
        end)
    end
    
    -- Method 5: Fire all BindableEvents
    for _, obj in ipairs(tool:GetDescendants()) do
        pcall(function()
            if obj:IsA("BindableEvent") then
                obj:Fire()
            end
        end)
    end
    
    -- Method 6: ClickDetectors
    for _, obj in ipairs(tool:GetDescendants()) do
        pcall(function()
            if obj:IsA("ClickDetector") then
                fireclickdetector(obj)
            end
        end)
    end
    
    -- Method 7: Direct RemoteEvent fire from character/backpack
    for _, obj in ipairs(character:GetDescendants()) do
        if obj:IsA("RemoteEvent") and (obj.Name:lower():find("shoot") or obj.Name:lower():find("fire") or obj.Name:lower():find("attack")) then
            pcall(function()
                obj:FireServer()
            end)
        end
    end
    
    -- Method 8: Fire from player's Backpack/PlayerGui
    for _, obj in ipairs(player:GetDescendants()) do
        if obj:IsA("RemoteEvent") and (obj.Name:lower():find("shoot") or obj.Name:lower():find("fire") or obj.Name:lower():find("attack") or obj.Name:lower():find("gun")) then
            pcall(function()
                obj:FireServer()
            end)
        end
    end
end

-- Main loop
coroutine.wrap(function()
    while true do
        local target = getNearestEnemy()
        local mouseTarget = getPlayerUnderMouse()
        
        -- Combined target detection
        local finalTarget = mouseTarget or target
        
        -- Update status
        if finalTarget then
            status.Text = "Target: " .. finalTarget.Name
            status.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            status.Text = "No target"
            status.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
        
        -- Aim Assist
        if AimAssistEnabled and target then
            local head = target.Character and target.Character:FindFirstChild("Head")
            if head then
                local mousePos = UserInputService:GetMouseLocation()
                local headPos = camera:WorldToViewportPoint(head.Position)
                local targetPos = Vector2.new(headPos.X, headPos.Y)
                local dir = targetPos - mousePos
                local dist = dir.Magnitude
                
                if dist < FOVRadius then
                    local strength = AimStrength * (1 - dist / FOVRadius)
                    local newPos = mousePos + dir * strength
                    
                    local deltaX = newPos.X - mousePos.X
                    local deltaY = newPos.Y - mousePos.Y
                    
                    -- Use multiple methods to move mouse
                    pcall(function() mousemoverel(deltaX, deltaY) end)
                    
                    -- Fallback: Use VirtualInputManager for mouse movement
                    pcall(function()
                        VirtualInputManager:SendMouseMoveEvent(newPos.X, newPos.Y, game)
                    end)
                end
            end
        end
        
        -- Auto Shoot
        if AutoShootEnabled and finalTarget then
            fireWeapon()
        end
        
        task.wait(0.05)
    end
end)()

print("Chadlix Auto Shoot + Aim Assist loaded!")
print("Aim Assist: " .. (AimAssistEnabled and "ON" or "OFF"))
print("Auto Shoot: " .. (AutoShootEnabled and "ON" or "OFF"))
