--// FULLY FIXED AIM ASSIST TRAINER
--// Put this LocalScript inside:
--// StarterPlayer > StarterPlayerScripts

----------------------------------------------------
-- SERVICES
----------------------------------------------------

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

----------------------------------------------------
-- SETTINGS
----------------------------------------------------

local AIM_ENABLED = false
local GUI_VISIBLE = true

local FOV_RADIUS = 140
local AIM_SMOOTHNESS = 0.10
local MAX_DISTANCE = 120

local AUTO_SHOOT = true
local SHOOT_DELAY = 0.12

local lastShot = 0

----------------------------------------------------
-- GUI
----------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "AimAssistTrainer"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

----------------------------------------------------
-- MAIN FRAME
----------------------------------------------------

local main = Instance.new("Frame")
main.Parent = gui
main.Size = UDim2.new(0,320,0,240)
main.Position = UDim2.new(0,20,0.5,-120)
main.BackgroundColor3 = Color3.fromRGB(22,22,22)
main.BorderSizePixel = 0

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0,12)
mainCorner.Parent = main

----------------------------------------------------
-- TITLE
----------------------------------------------------

local title = Instance.new("TextLabel")
title.Parent = main
title.BackgroundTransparency = 1
title.Position = UDim2.new(0,20,0,15)
title.Size = UDim2.new(1,-40,0,30)
title.Font = Enum.Font.GothamBold
title.Text = "Aim Assist Trainer"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left

----------------------------------------------------
-- DIVIDER
----------------------------------------------------

local divider = Instance.new("Frame")
divider.Parent = main
divider.Position = UDim2.new(0,15,0,50)
divider.Size = UDim2.new(1,-30,0,1)
divider.BackgroundColor3 = Color3.fromRGB(45,45,45)
divider.BorderSizePixel = 0

----------------------------------------------------
-- AIM ASSIST TOGGLE
----------------------------------------------------

local toggleFrame = Instance.new("Frame")
toggleFrame.Parent = main
toggleFrame.BackgroundTransparency = 1
toggleFrame.Position = UDim2.new(0,20,0,70)
toggleFrame.Size = UDim2.new(1,-40,0,40)

local toggleLabel = Instance.new("TextLabel")
toggleLabel.Parent = toggleFrame
toggleLabel.BackgroundTransparency = 1
toggleLabel.Size = UDim2.new(0.7,0,1,0)
toggleLabel.Font = Enum.Font.Gotham
toggleLabel.Text = "Aim Assist"
toggleLabel.TextColor3 = Color3.fromRGB(220,220,220)
toggleLabel.TextSize = 16
toggleLabel.TextXAlignment = Enum.TextXAlignment.Left

local toggleButton = Instance.new("Frame")
toggleButton.Parent = toggleFrame
toggleButton.AnchorPoint = Vector2.new(1,0.5)
toggleButton.Position = UDim2.new(1,0,0.5,0)
toggleButton.Size = UDim2.new(0,50,0,24)
toggleButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
toggleButton.BorderSizePixel = 0

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1,0)
toggleCorner.Parent = toggleButton

local toggleCircle = Instance.new("Frame")
toggleCircle.Parent = toggleButton
toggleCircle.Size = UDim2.new(0,20,0,20)
toggleCircle.Position = UDim2.new(0,2,0.5,-10)
toggleCircle.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggleCircle.BorderSizePixel = 0

local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1,0)
circleCorner.Parent = toggleCircle

----------------------------------------------------
-- AUTO SHOOT TOGGLE
----------------------------------------------------

local shootFrame = Instance.new("Frame")
shootFrame.Parent = main
shootFrame.BackgroundTransparency = 1
shootFrame.Position = UDim2.new(0,20,0,115)
shootFrame.Size = UDim2.new(1,-40,0,40)

local shootLabel = Instance.new("TextLabel")
shootLabel.Parent = shootFrame
shootLabel.BackgroundTransparency = 1
shootLabel.Size = UDim2.new(0.7,0,1,0)
shootLabel.Font = Enum.Font.Gotham
shootLabel.Text = "Auto Shoot"
shootLabel.TextColor3 = Color3.fromRGB(220,220,220)
shootLabel.TextSize = 16
shootLabel.TextXAlignment = Enum.TextXAlignment.Left

local shootButton = toggleButton:Clone()
shootButton.Parent = shootFrame
shootButton.Position = UDim2.new(1,0,0.5,0)

local shootCircle = shootButton:FindFirstChildOfClass("Frame")

----------------------------------------------------
-- SMOOTHNESS LABEL
----------------------------------------------------

local smoothLabel = Instance.new("TextLabel")
smoothLabel.Parent = main
smoothLabel.BackgroundTransparency = 1
smoothLabel.Position = UDim2.new(0,20,0,170)
smoothLabel.Size = UDim2.new(1,-40,0,20)
smoothLabel.Font = Enum.Font.Gotham
smoothLabel.Text = "Smoothness: 0.10"
smoothLabel.TextColor3 = Color3.fromRGB(220,220,220)
smoothLabel.TextSize = 15
smoothLabel.TextXAlignment = Enum.TextXAlignment.Left

----------------------------------------------------
-- SLIDER
----------------------------------------------------

local sliderBar = Instance.new("Frame")
sliderBar.Parent = main
sliderBar.Position = UDim2.new(0,20,0,200)
sliderBar.Size = UDim2.new(1,-40,0,6)
sliderBar.BackgroundColor3 = Color3.fromRGB(40,40,40)
sliderBar.BorderSizePixel = 0

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(1,0)
sliderCorner.Parent = sliderBar

local sliderFill = Instance.new("Frame")
sliderFill.Parent = sliderBar
sliderFill.Size = UDim2.new(0.3,0,1,0)
sliderFill.BackgroundColor3 = Color3.fromRGB(0,170,255)
sliderFill.BorderSizePixel = 0

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1,0)
fillCorner.Parent = sliderFill

local sliderKnob = Instance.new("Frame")
sliderKnob.Parent = sliderBar
sliderKnob.AnchorPoint = Vector2.new(0.5,0.5)
sliderKnob.Position = UDim2.new(0.3,0,0.5,0)
sliderKnob.Size = UDim2.new(0,14,0,14)
sliderKnob.BackgroundColor3 = Color3.fromRGB(255,255,255)
sliderKnob.BorderSizePixel = 0

local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1,0)
knobCorner.Parent = sliderKnob

----------------------------------------------------
-- REAL ROBLOX FOV
----------------------------------------------------

local fovCircle = Instance.new("Frame")
fovCircle.Parent = gui
fovCircle.Size = UDim2.new(0,FOV_RADIUS * 2,0,FOV_RADIUS * 2)
fovCircle.AnchorPoint = Vector2.new(0.5,0.5)
fovCircle.BackgroundTransparency = 0.9
fovCircle.BackgroundColor3 = Color3.fromRGB(0,170,255)
fovCircle.BorderSizePixel = 0

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1,0)
fovCorner.Parent = fovCircle

local fovStroke = Instance.new("UIStroke")
fovStroke.Parent = fovCircle
fovStroke.Color = Color3.fromRGB(0,170,255)
fovStroke.Thickness = 1.5

----------------------------------------------------
-- TOGGLE ANIMATION
----------------------------------------------------

local function animateToggle(button,circle,state)

	if state then

		TweenService:Create(
			circle,
			TweenInfo.new(0.2),
			{Position = UDim2.new(1,-22,0.5,-10)}
		):Play()

		TweenService:Create(
			button,
			TweenInfo.new(0.2),
			{BackgroundColor3 = Color3.fromRGB(0,170,255)}
		):Play()

	else

		TweenService:Create(
			circle,
			TweenInfo.new(0.2),
			{Position = UDim2.new(0,2,0.5,-10)}
		):Play()

		TweenService:Create(
			button,
			TweenInfo.new(0.2),
			{BackgroundColor3 = Color3.fromRGB(50,50,50)}
		):Play()
	end
end

----------------------------------------------------
-- BUTTON EVENTS
----------------------------------------------------

toggleFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		AIM_ENABLED = not AIM_ENABLED
		animateToggle(toggleButton,toggleCircle,AIM_ENABLED)
	end
end)

shootFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		AUTO_SHOOT = not AUTO_SHOOT
		animateToggle(shootButton,shootCircle,AUTO_SHOOT)
	end
end)

----------------------------------------------------
-- SLIDER
----------------------------------------------------

local sliding = false

sliderKnob.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		sliding = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		sliding = false
	end
end)

UserInputService.InputChanged:Connect(function(input)

	if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then

		local percent = math.clamp(
			(input.Position.X - sliderBar.AbsolutePosition.X)
			/ sliderBar.AbsoluteSize.X,
			0,
			1
		)

		sliderFill.Size = UDim2.new(percent,0,1,0)
		sliderKnob.Position = UDim2.new(percent,0,0.5,0)

		AIM_SMOOTHNESS = math.floor(percent * 100) / 100

		if AIM_SMOOTHNESS < 0.02 then
			AIM_SMOOTHNESS = 0.02
		end

		smoothLabel.Text =
			"Smoothness: "..string.format("%.2f", AIM_SMOOTHNESS)
	end
end)

----------------------------------------------------
-- K KEY GUI TOGGLE
----------------------------------------------------

UserInputService.InputBegan:Connect(function(input,gp)

	if gp then return end

	if input.KeyCode == Enum.KeyCode.K then
		GUI_VISIBLE = not GUI_VISIBLE
		main.Visible = GUI_VISIBLE
	end
end)

----------------------------------------------------
-- VISIBILITY CHECK
----------------------------------------------------

local function isVisible(part)

	local origin = camera.CFrame.Position
	local direction = (part.Position - origin)

	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {player.Character}
	params.FilterType = Enum.RaycastFilterType.Blacklist

	local result = workspace:Raycast(origin,direction,params)

	if result then
		return result.Instance:IsDescendantOf(part.Parent)
	end

	return false
end

----------------------------------------------------
-- TARGET FINDER
----------------------------------------------------

local function getClosestTarget()

	local myCharacter = player.Character
	if not myCharacter then return nil end

	local myRoot = myCharacter:FindFirstChild("HumanoidRootPart")
	if not myRoot then return nil end

	local closest = nil
	local shortest = FOV_RADIUS

	for _,plr in pairs(Players:GetPlayers()) do

		if plr ~= player and plr.Team ~= player.Team then

			local char = plr.Character

			if char
			and char:FindFirstChild("Humanoid")
			and char:FindFirstChild("Head")
			and char:FindFirstChild("HumanoidRootPart")
			and char.Humanoid.Health > 0 then

				local distance =
					(myRoot.Position - char.HumanoidRootPart.Position).Magnitude

				if distance <= MAX_DISTANCE then

					local pos,visible =
						camera:WorldToViewportPoint(char.Head.Position)

					if visible then

						local dist = (
							Vector2.new(pos.X,pos.Y)
							- Vector2.new(mouse.X,mouse.Y)
						).Magnitude

						if dist < shortest then

							if isVisible(char.Head) then
								shortest = dist
								closest = char
							end
						end
					end
				end
			end
		end
	end

	return closest
end

----------------------------------------------------
-- AUTO SHOOT
----------------------------------------------------

local function autoShoot(target)

	if not AUTO_SHOOT then return end

	if tick() - lastShot < SHOOT_DELAY then
		return
	end

	lastShot = tick()

	local character = player.Character
	if not character then return end

	local tool = character:FindFirstChildOfClass("Tool")

	if tool then
		tool:Activate()

		local remote = tool:FindFirstChild("ShootRemote")

		if remote and remote:IsA("RemoteEvent") then
			remote:FireServer(target.Head.Position)
		end
	end
end

----------------------------------------------------
-- MAIN LOOP
----------------------------------------------------

RunService.RenderStepped:Connect(function()

	fovCircle.Position = UDim2.new(0,mouse.X,0,mouse.Y)

	if not AIM_ENABLED then
		return
	end

	local target = getClosestTarget()

	if target and target:FindFirstChild("Head") then

		local camCF = camera.CFrame

		local aimCF = CFrame.new(
			camCF.Position,
			target.Head.Position
		)

		camera.CFrame = camCF:Lerp(
			aimCF,
			AIM_SMOOTHNESS
		)

		autoShoot(target)
	end
end)
