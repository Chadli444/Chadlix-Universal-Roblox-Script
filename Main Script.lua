-- LocalScript (StarterGui or StarterPlayerScripts)
-- CHADLIX UNIVERSAL HUB

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

-- ==================== SETTINGS ====================
local autoClickerEnabled = false
local aimAssistEnabled = false
local teamEspEnabled = false
local normalEspEnabled = false
local fpsPingEnabled = false
local flyEnabled = false
local noclipEnabled = false
local infJumpEnabled = false
local currentTarget = nil
local guiVisible = true

local aimStrength = 0.15
local fovRadius = 80
local flySpeed = 50

local espObjects = {}

-- ==================== GUI SETUP ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ChadlixHub"
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 270, 0, 400)
mainFrame.Position = UDim2.new(0.5, -135, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

-- Top accent line
local topAccent = Instance.new("Frame")
topAccent.Size = UDim2.new(1, 0, 0, 3)
topAccent.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
topAccent.BorderSizePixel = 0
topAccent.Parent = mainFrame

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.Position = UDim2.new(0, 0, 0, 3)
titleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -50, 1, 0)
titleText.Position = UDim2.new(0, 18, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "🔥 CHADLIX UNIVERSAL HUB"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextSize = 14
titleText.Font = Enum.Font.GothamBlack
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 28, 0, 28)
closeButton.Position = UDim2.new(1, -36, 0, 6)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeButton.BorderSizePixel = 0
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 14
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = titleBar
Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0, 6)

-- Subtitle
local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -30, 0, 18)
subtitle.Position = UDim2.new(0, 15, 0, 48)
subtitle.BackgroundTransparency = 1
subtitle.Text = "by Chadlix"
subtitle.TextColor3 = Color3.fromRGB(120, 120, 120)
subtitle.TextSize = 11
subtitle.Font = Enum.Font.GothamItalic
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = mainFrame

-- Category tabs
local categoryFrame = Instance.new("Frame")
categoryFrame.Size = UDim2.new(1, 0, 0, 30)
categoryFrame.Position = UDim2.new(0, 0, 0, 70)
categoryFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
categoryFrame.BorderSizePixel = 0
categoryFrame.Parent = mainFrame

local categories = {"Combat", "Movement", "Visuals", "Stats"}
local categoryButtons = {}
local currentCategory = "Combat"
local contentPages = {}

for i, cat in ipairs(categories) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.25, -3, 1, 0)
	btn.Position = UDim2.new((i-1)*0.25, 2, 0, 0)
	btn.BackgroundColor3 = i == 1 and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(35, 35, 40)
	btn.BorderSizePixel = 0
	btn.Text = cat
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = 11
	btn.Font = Enum.Font.GothamBold
	btn.Parent = categoryFrame
	categoryButtons[cat] = btn
	
	local page = Instance.new("Frame")
	page.Size = UDim2.new(1, 0, 1, -105)
	page.Position = UDim2.new(0, 0, 0, 105)
	page.BackgroundTransparency = 1
	page.Visible = (cat == "Combat")
	page.Parent = mainFrame
	contentPages[cat] = page
	
	btn.MouseButton1Click:Connect(function()
		currentCategory = cat
		for c, b in pairs(categoryButtons) do
			b.BackgroundColor3 = c == cat and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(35, 35, 40)
		end
		for c, p in pairs(contentPages) do
			p.Visible = (c == cat)
		end
	end)
end

-- Helper functions
local function createSeparator(parent, yPos)
	local sep = Instance.new("Frame")
	sep.Size = UDim2.new(1, -30, 0, 1)
	sep.Position = UDim2.new(0, 15, 0, yPos)
	sep.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
	sep.BorderSizePixel = 0
	sep.Parent = parent
	return sep
end

local function createToggle(parent, yPos, label, icon)
	local sectionLabel = Instance.new("TextLabel")
	sectionLabel.Size = UDim2.new(1, -30, 0, 20)
	sectionLabel.Position = UDim2.new(0, 15, 0, yPos)
	sectionLabel.BackgroundTransparency = 1
	sectionLabel.Text = icon.."  "..label
	sectionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	sectionLabel.TextSize = 12
	sectionLabel.Font = Enum.Font.GothamBold
	sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
	sectionLabel.Parent = parent

	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Size = UDim2.new(1, -30, 0, 32)
	toggleBtn.Position = UDim2.new(0, 15, 0, yPos + 22)
	toggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
	toggleBtn.BorderSizePixel = 0
	toggleBtn.Text = "DISABLED"
	toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggleBtn.TextSize = 13
	toggleBtn.Font = Enum.Font.GothamBold
	toggleBtn.Parent = parent
	Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

	local statusDot = Instance.new("Frame")
	statusDot.Size = UDim2.new(0, 10, 0, 10)
	statusDot.Position = UDim2.new(0, 10, 0.5, -5)
	statusDot.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
	statusDot.BorderSizePixel = 0
	statusDot.Parent = toggleBtn
	Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)

	return toggleBtn, statusDot
end

local function updateToggleButton(button, dot, enabled)
	if enabled then
		button.Text = "ENABLED"
		button.BackgroundColor3 = Color3.fromRGB(30, 130, 30)
		dot.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
	else
		button.Text = "DISABLED"
		button.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
		dot.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
	end
end

-- ==================== COMBAT PAGE ====================
local combatPage = contentPages["Combat"]

-- Auto Clicker
local autoClickerToggle, acStatusDot = createToggle(combatPage, 10, "AUTO CLICKER", "⚔️")
createSeparator(combatPage, 70)

-- Aim Assist
local aimAssistToggle, aaStatusDot = createToggle(combatPage, 75, "AIM ASSIST", "🎯")

-- Strength slider
local strengthLabel = Instance.new("TextLabel")
strengthLabel.Size = UDim2.new(1, -30, 0, 15)
strengthLabel.Position = UDim2.new(0, 18, 0, 132)
strengthLabel.BackgroundTransparency = 1
strengthLabel.Text = "Strength: 0.15"
strengthLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
strengthLabel.TextSize = 11
strengthLabel.Font = Enum.Font.Gotham
strengthLabel.TextXAlignment = Enum.TextXAlignment.Left
strengthLabel.Parent = combatPage

local strengthSlider = Instance.new("Frame")
strengthSlider.Size = UDim2.new(1, -30, 0, 5)
strengthSlider.Position = UDim2.new(0, 15, 0, 150)
strengthSlider.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
strengthSlider.BorderSizePixel = 0
strengthSlider.Parent = combatPage
Instance.new("UICorner", strengthSlider).CornerRadius = UDim.new(0, 3)
local strengthFill = Instance.new("Frame")
strengthFill.Size = UDim2.new(aimStrength, 0, 1, 0)
strengthFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
strengthFill.BorderSizePixel = 0
strengthFill.Parent = strengthSlider
Instance.new("UICorner", strengthFill).CornerRadius = UDim.new(0, 3)

-- FOV slider
local fovLabel = Instance.new("TextLabel")
fovLabel.Size = UDim2.new(1, -30, 0, 15)
fovLabel.Position = UDim2.new(0, 18, 0, 162)
fovLabel.BackgroundTransparency = 1
fovLabel.Text = "FOV: 80px"
fovLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
fovLabel.TextSize = 11
fovLabel.Font = Enum.Font.Gotham
fovLabel.TextXAlignment = Enum.TextXAlignment.Left
fovLabel.Parent = combatPage

local fovSlider = Instance.new("Frame")
fovSlider.Size = UDim2.new(1, -30, 0, 5)
fovSlider.Position = UDim2.new(0, 15, 0, 180)
fovSlider.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
fovSlider.BorderSizePixel = 0
fovSlider.Parent = combatPage
Instance.new("UICorner", fovSlider).CornerRadius = UDim.new(0, 3)
local fovFill = Instance.new("Frame")
fovFill.Size = UDim2.new(fovRadius / 200, 0, 1, 0)
fovFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
fovFill.BorderSizePixel = 0
fovFill.Parent = fovSlider
Instance.new("UICorner", fovFill).CornerRadius = UDim.new(0, 3)

-- ==================== MOVEMENT PAGE ====================
local movementPage = contentPages["Movement"]

-- Fly
local flyToggle, flyStatusDot = createToggle(movementPage, 10, "FLY", "🕊️")
createSeparator(movementPage, 70)

-- Fly speed slider
local flySpeedLabel = Instance.new("TextLabel")
flySpeedLabel.Size = UDim2.new(1, -30, 0, 15)
flySpeedLabel.Position = UDim2.new(0, 18, 0, 75)
flySpeedLabel.BackgroundTransparency = 1
flySpeedLabel.Text = "Fly Speed: 50"
flySpeedLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
flySpeedLabel.TextSize = 11
flySpeedLabel.Font = Enum.Font.Gotham
flySpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
flySpeedLabel.Parent = movementPage

local flySpeedSlider = Instance.new("Frame")
flySpeedSlider.Size = UDim2.new(1, -30, 0, 5)
flySpeedSlider.Position = UDim2.new(0, 15, 0, 93)
flySpeedSlider.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
flySpeedSlider.BorderSizePixel = 0
flySpeedSlider.Parent = movementPage
Instance.new("UICorner", flySpeedSlider).CornerRadius = UDim.new(0, 3)
local flySpeedFill = Instance.new("Frame")
flySpeedFill.Size = UDim2.new(flySpeed/200, 0, 1, 0)
flySpeedFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
flySpeedFill.BorderSizePixel = 0
flySpeedFill.Parent = flySpeedSlider
Instance.new("UICorner", flySpeedFill).CornerRadius = UDim.new(0, 3)

createSeparator(movementPage, 105)

-- Noclip
local noclipToggle, noclipStatusDot = createToggle(movementPage, 110, "NOCLIP", "👻")

createSeparator(movementPage, 168)

-- Infinite Jump
local infJumpToggle, infJumpStatusDot = createToggle(movementPage, 173, "INFINITE JUMP", "🦘")

-- ==================== VISUALS PAGE ====================
local visualsPage = contentPages["Visuals"]

-- Team ESP
local teamEspToggle, teStatusDot = createToggle(visualsPage, 10, "TEAM ESP", "🟢")
createSeparator(visualsPage, 68)

-- Normal ESP
local normalEspToggle, neStatusDot = createToggle(visualsPage, 73, "NORMAL ESP", "🔴")
createSeparator(visualsPage, 131)

-- FPS/Ping
local fpsPingToggle, fpStatusDot = createToggle(visualsPage, 136, "FPS / PING", "📊")

-- ==================== STATS PAGE ====================
local statsPage = contentPages["Stats"]

-- Stats display
local statsFrame = Instance.new("Frame")
statsFrame.Size = UDim2.new(1, -30, 0, 200)
statsFrame.Position = UDim2.new(0, 15, 0, 10)
statsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
statsFrame.BorderSizePixel = 0
statsFrame.Parent = statsPage
Instance.new("UICorner", statsFrame).CornerRadius = UDim.new(0, 8)

local statsListLayout = Instance.new("UIListLayout")
statsListLayout.Padding = UDim.new(0, 6)
statsListLayout.Parent = statsFrame

local statLabels = {}

local function createStatLabel(name)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 28)
	frame.BackgroundTransparency = 1
	frame.Parent = statsFrame
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = name..": Loading..."
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.TextSize = 13
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame
	
	return label
end

statLabels["Time Played"] = createStatLabel("⏱️ Time Played")
statLabels["Kills"] = createStatLabel("💀 Kills")
statLabels["Deaths"] = createStatLabel("☠️ Deaths")
statLabels["KD Ratio"] = createStatLabel("📊 K/D Ratio")
statLabels["Ping"] = createStatLabel("📡 Ping")

-- Update stats
local function updateStats()
	task.spawn(function()
		while true do
			local leaderstats = player:FindFirstChild("leaderstats")
			if leaderstats then
				local kills = leaderstats:FindFirstChild("Kills") or leaderstats:FindFirstChild("KOs")
				local deaths = leaderstats:FindFirstChild("Deaths") or leaderstats:FindFirstChild("Wipeouts")
				local time = leaderstats:FindFirstChild("Time") or leaderstats:FindFirstChild("Playtime")
				
				if kills and kills:IsA("IntValue") then
					statLabels["Kills"].Text = "💀 Kills: "..kills.Value
				end
				if deaths and deaths:IsA("IntValue") then
					statLabels["Deaths"].Text = "☠️ Deaths: "..deaths.Value
				end
				if kills and deaths and kills:IsA("IntValue") and deaths:IsA("IntValue") then
					local kd = deaths.Value > 0 and math.round(kills.Value / deaths.Value * 100) / 100 or kills.Value
					statLabels["KD Ratio"].Text = "📊 K/D Ratio: "..kd
				end
				if time and time:IsA("IntValue") then
					local mins = math.floor(time.Value / 60)
					local secs = time.Value % 60
					statLabels["Time Played"].Text = string.format("⏱️ Time Played: %d:%02d", mins, secs)
				end
			else
				for _, label in pairs(statLabels) do
					label.Text = string.gsub(label.Text, ": .*", ": No data")
				end
			end
			
			statLabels["Ping"].Text = "📡 Ping: "..math.floor(player:GetNetworkPing() * 1000).."ms"
			
			task.wait(1)
		end
	end)
end

-- ==================== FPS/PING DISPLAY ====================
local fpsPingFrame = Instance.new("Frame")
fpsPingFrame.Size = UDim2.new(0, 130, 0, 42)
fpsPingFrame.Position = UDim2.new(0, 10, 0, 10)
fpsPingFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
fpsPingFrame.BackgroundTransparency = 0.35
fpsPingFrame.BorderSizePixel = 0
fpsPingFrame.Visible = false
fpsPingFrame.Parent = screenGui
Instance.new("UICorner", fpsPingFrame).CornerRadius = UDim.new(0, 8)

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(1, 0, 0.5, 0)
fpsLabel.Position = UDim2.new(0, 12, 0, 3)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: 0"
fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
fpsLabel.TextSize = 13
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.Parent = fpsPingFrame

local pingLabel = Instance.new("TextLabel")
pingLabel.Size = UDim2.new(1, 0, 0.5, 0)
pingLabel.Position = UDim2.new(0, 12, 0.5, -3)
pingLabel.BackgroundTransparency = 1
pingLabel.Text = "Ping: 0ms"
pingLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
pingLabel.TextSize = 13
pingLabel.Font = Enum.Font.GothamBold
pingLabel.TextXAlignment = Enum.TextXAlignment.Left
pingLabel.Parent = fpsPingFrame

local function updateFPSPing()
	while fpsPingEnabled do
		local fps = math.floor(1 / RunService.RenderStepped:Wait())
		local ping = math.floor(player:GetNetworkPing() * 1000)
		fpsLabel.Text = "FPS: "..fps
		pingLabel.Text = "Ping: "..ping.."ms"
		fpsLabel.TextColor3 = fps >= 60 and Color3.fromRGB(0, 255, 0) or (fps >= 30 and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 50, 50))
		pingLabel.TextColor3 = ping <= 50 and Color3.fromRGB(0, 255, 0) or (ping <= 100 and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 50, 50))
		task.wait(0.5)
	end
end

-- ==================== FLY SYSTEM ====================
local flyConnection = nil
local function toggleFly()
	flyEnabled = not flyEnabled
	updateToggleButton(flyToggle, flyStatusDot, flyEnabled)
	
	if flyEnabled then
		local character = player.Character or player.CharacterAdded:Wait()
		local humanoid = character:WaitForChild("Humanoid")
		local rootPart = character:WaitForChild("HumanoidRootPart")
		
		humanoid.PlatformStand = true
		
		local bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
		bodyGyro.P = 3000
		bodyGyro.Parent = rootPart
		
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
		bodyVelocity.Velocity = Vector3.new(0, 0, 0)
		bodyVelocity.P = 3000
		bodyVelocity.Parent = rootPart
		
		flyConnection = RunService.RenderStepped:Connect(function()
			if not flyEnabled or not rootPart.Parent then
				flyConnection:Disconnect()
				bodyGyro:Destroy()
				bodyVelocity:Destroy()
				humanoid.PlatformStand = false
				return
			end
			
			bodyGyro.CFrame = camera.CFrame
			
			local moveDir = Vector3.new()
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0, 1, 0) end
			
			bodyVelocity.Velocity = moveDir.Unit * flySpeed
		end)
	end
end

-- ==================== NOCLIP SYSTEM ====================
local noclipConnection = nil
local function toggleNoclip()
	noclipEnabled = not noclipEnabled
	updateToggleButton(noclipToggle, noclipStatusDot, noclipEnabled)
	
	if noclipEnabled then
		noclipConnection = RunService.Stepped:Connect(function()
			if player.Character then
				for _, part in ipairs(player.Character:GetDescendants()) do
					if part:IsA("BasePart") and part.CanCollide then
						part.CanCollide = false
					end
				end
			end
		end)
	else
		if noclipConnection then
			noclipConnection:Disconnect()
		end
		if player.Character then
			for _, part in ipairs(player.Character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = true
				end
			end
		end
	end
end

-- ==================== INFINITE JUMP ====================
local infJumpConnection = nil
local function toggleInfJump()
	infJumpEnabled = not infJumpEnabled
	updateToggleButton(infJumpToggle, infJumpStatusDot, infJumpEnabled)
	
	if infJumpEnabled then
		infJumpConnection = UserInputService.JumpRequest:Connect(function()
			if player.Character and player.Character:FindFirstChild("Humanoid") then
				player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end)
	else
		if infJumpConnection then
			infJumpConnection:Disconnect()
		end
	end
end

-- ==================== SLIDER SYSTEMS ====================
local function makeSliderDraggable(sliderFrame, fillFrame, label, callback, min, max, decimals)
	local dragging = false
	
	sliderFrame.InputBegan:Connect(function(input)
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
			local sliderPos = sliderFrame.AbsolutePosition
			local sliderSize = sliderFrame.AbsoluteSize
			local percent = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
			local value = math.round((min + (max - min) * percent) * (10 ^ decimals)) / (10 ^ decimals)
			
			fillFrame.Size = UDim2.new(percent, 0, 1, 0)
			callback(value, label)
		end
	end)
end

makeSliderDraggable(strengthSlider, strengthFill, strengthLabel, function(v, l)
	aimStrength = v
	l.Text = "Strength: "..v
end, 0.01, 1, 2)

makeSliderDraggable(fovSlider, fovFill, fovLabel, function(v, l)
	fovRadius = v
	l.Text = "FOV: "..v.."px"
end, 20, 200, 0)

makeSliderDraggable(flySpeedSlider, flySpeedFill, flySpeedLabel, function(v, l)
	flySpeed = v
	l.Text = "Fly Speed: "..v
end, 10, 200, 0)

-- ==================== AUTO CLICKER ====================
local function getPlayerUnderMouse()
	local mousePosition = UserInputService:GetMouseLocation()
	local ray = camera:ViewportPointToRay(mousePosition.X, mousePosition.Y)
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = {}
	
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			table.insert(raycastParams.FilterDescendantsInstances, plr.Character)
		end
	end
	
	local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
	
	if raycastResult then
		local hit = raycastResult.Instance
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character and hit:IsDescendantOf(plr.Character) then
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
	while autoClickerEnabled do
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

-- ==================== AIM ASSIST ====================
local function getNearestEnemyToCursor()
	local mousePos = UserInputService:GetMouseLocation()
	local nearestPlayer = nil
	local nearestDistance = fovRadius
	
	for _, target in ipairs(Players:GetPlayers()) do
		if target ~= player and target.Character then
			local head = target.Character:FindFirstChild("Head")
			local humanoid = target.Character:FindFirstChild("Humanoid")
			
			if head and humanoid and humanoid.Health > 0 then
				local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
				
				if onScreen then
					local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
					
					if distance < nearestDistance then
						nearestDistance = distance
						nearestPlayer = target
					end
				end
			end
		end
	end
	
	return nearestPlayer, nearestDistance
end

local function aimAssistLoop()
	while aimAssistEnabled do
		local target, distance = getNearestEnemyToCursor()
		
		if target and target.Character then
			local head = target.Character:FindFirstChild("Head")
			if head then
				local mousePos = UserInputService:GetMouseLocation()
				local headScreenPos = camera:WorldToViewportPoint(head.Position)
				local targetPos = Vector2.new(headScreenPos.X, headScreenPos.Y)
				local direction = targetPos - mousePos
				local pullStrength = aimStrength * (1 - distance / fovRadius)
				local newMousePos = mousePos + direction * pullStrength
				
				mousemoverel((newMousePos.X - mousePos.X) / 2, (newMousePos.Y - mousePos.Y) / 2)
			end
		end
		
		task.wait()
	end
end

-- ==================== ESP SYSTEM ====================
local function createESP(targetPlayer, isTeam)
	local character = targetPlayer.Character
	if not character then return end
	
	local highlight = Instance.new("Highlight")
	highlight.Name = "ESP_Highlight_"..targetPlayer.Name
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	
	if isTeam then
		highlight.FillColor = Color3.fromRGB(0, 255, 0)
		highlight.OutlineColor = Color3.fromRGB(0, 200, 0)
	else
		highlight.FillColor = Color3.fromRGB(255, 0, 0)
		highlight.OutlineColor = Color3.fromRGB(200, 0, 0)
	end
	
	highlight.Parent = character
	
	if not espObjects[targetPlayer] then espObjects[targetPlayer] = {} end
	table.insert(espObjects[targetPlayer], highlight)
	
	local head = character:FindFirstChild("Head")
	if head then
		local billboard = Instance.new("BillboardGui")
		billboard.Size = UDim2.new(0, 100, 0, 30)
		billboard.StudsOffset = Vector3.new(0, 3, 0)
		billboard.AlwaysOnTop = true
		billboard.Parent = head
		
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, 0, 0, 15)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = targetPlayer.Name
		nameLabel.TextColor3 = isTeam and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
		nameLabel.TextSize = 12
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.Parent = billboard
		
		table.insert(espObjects[targetPlayer], billboard)
	end
end

local function removeESP(targetPlayer)
	if espObjects[targetPlayer] then
		for _, obj in ipairs(espObjects[targetPlayer]) do
			if obj and obj.Parent then obj:Destroy() end
		end
		espObjects[targetPlayer] = nil
	end
end

local function clearAllESP()
	for _, objects in pairs(espObjects) do
		for _, obj in ipairs(objects) do
			if obj and obj.Parent then obj:Destroy() end
		end
	end
	espObjects = {}
end

local function updateESP()
	clearAllESP()
	for _, target in ipairs(Players:GetPlayers()) do
		if target ~= player and target.Character then
			local isTeam = target.Team == player.Team and player.Team ~= nil
			if isTeam and teamEspEnabled then createESP(target, true)
			elseif not isTeam and normalEspEnabled then createESP(target, false) end
		end
	end
end

-- ==================== TOGGLE FUNCTIONS ====================
local function toggleAutoClicker()
	autoClickerEnabled = not autoClickerEnabled
	updateToggleButton(autoClickerToggle, acStatusDot, autoClickerEnabled)
	if autoClickerEnabled then task.spawn(autoClickerLoop) else currentTarget = nil end
end

local function toggleAimAssist()
	aimAssistEnabled = not aimAssistEnabled
	updateToggleButton(aimAssistToggle, aaStatusDot, aimAssistEnabled)
	if aimAssistEnabled then task.spawn(aimAssistLoop) end
end

local function toggleTeamESP()
	teamEspEnabled = not teamEspEnabled
	updateToggleButton(teamEspToggle, teStatusDot, teamEspEnabled)
	updateESP()
end

local function toggleNormalESP()
	normalEspEnabled = not normalEspEnabled
	updateToggleButton(normalEspToggle, neStatusDot, normalEspEnabled)
	updateESP()
end

local function toggleFPSPing()
	fpsPingEnabled = not fpsPingEnabled
	updateToggleButton(fpsPingToggle, fpStatusDot, fpsPingEnabled)
	fpsPingFrame.Visible = fpsPingEnabled
	if fpsPingEnabled then task.spawn(updateFPSPing) end
end

-- ==================== PLAYER CONNECTIONS ====================
local function onPlayerAdded(target)
	target.CharacterAdded:Connect(function() updateESP() end)
	target.CharacterRemoving:Connect(function() updateESP() end)
end

for _, target in ipairs(Players:GetPlayers()) do
	if target ~= player then onPlayerAdded(target) end
end
Players.PlayerAdded:Connect(function(target)
	if target ~= player then onPlayerAdded(target) end
end)
Players.PlayerRemoving:Connect(removeESP)
player:GetPropertyChangedSignal("Team"):Connect(updateESP)

-- ==================== BUTTON CONNECTIONS ====================
autoClickerToggle.MouseButton1Click:Connect(toggleAutoClicker)
aimAssistToggle.MouseButton1Click:Connect(toggleAimAssist)
flyToggle.MouseButton1Click:Connect(toggleFly)
noclipToggle.MouseButton1Click:Connect(toggleNoclip)
infJumpToggle.MouseButton1Click:Connect(toggleInfJump)
teamEspToggle.MouseButton1Click:Connect(toggleTeamESP)
normalEspToggle.MouseButton1Click:Connect(toggleNormalESP)
fpsPingToggle.MouseButton1Click:Connect(toggleFPSPing)

closeButton.MouseButton1Click:Connect(function()
	guiVisible = false
	mainFrame.Visible = false
end)

-- ==================== KEYBIND ====================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.N then
		guiVisible = not guiVisible
		mainFrame.Visible = guiVisible
	end
end)

-- ==================== STARTUP ====================
updateESP()
updateStats()
