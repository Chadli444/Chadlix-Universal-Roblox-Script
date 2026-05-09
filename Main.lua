--// AIM ASSIST + REACTION TRIGGERBOT
--// Put this LocalScript inside:
--// StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-------------------------------------------------
-- SETTINGS
-------------------------------------------------

local AIM_ENABLED = false

local FOV_RADIUS = 140
local AIM_SMOOTHNESS = 0.12
local MAX_DISTANCE = 120

local AUTO_SHOOT = true
local SHOOT_DELAY = 0.12

local lastShot = 0

-------------------------------------------------
-- GUI
-------------------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

-------------------------------------------------
-- MAIN FRAME
-------------------------------------------------

local main = Instance.new("Frame")
main.Parent = screenGui
main.Size = UDim2.new(0,220,0,70)
main.Position = UDim2.new(0,20,0.5,-35)
main.BackgroundColor3 = Color3.fromRGB(24,24,24)
main.BorderSizePixel = 0

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0,10)
mainCorner.Parent = main

-------------------------------------------------
-- TITLE
-------------------------------------------------

local title = Instance.new("TextLabel")
title.Parent = main
title.BackgroundTransparency = 1
title.Size = UDim2.new(1,0,0,30)
title.Font = Enum.Font.GothamBold
title.Text = "Aim Assist Trainer"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextSize = 18

-------------------------------------------------
-- TOGGLE BUTTON
-------------------------------------------------

local button = Instance.new("TextButton")
button.Parent = main
button.Size = UDim2.new(0,180,0,30)
button.Position = UDim2.new(0.5,-90,0,35)

button.BackgroundColor3 = Color3.fromRGB(170,0,0)
button.TextColor3 = Color3.fromRGB(255,255,255)
button.Font = Enum.Font.GothamBold
button.TextSize = 15
button.Text = "Aim Assist: OFF"
button.BorderSizePixel = 0

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0,8)
buttonCorner.Parent = button

-------------------------------------------------
-- TOGGLE
-------------------------------------------------

button.MouseButton1Click:Connect(function()

	AIM_ENABLED = not AIM_ENABLED

	if AIM_ENABLED then
		button.Text = "Aim Assist: ON"
		button.BackgroundColor3 = Color3.fromRGB(0,170,0)
	else
		button.Text = "Aim Assist: OFF"
		button.BackgroundColor3 = Color3.fromRGB(170,0,0)
	end
end)

-------------------------------------------------
-- K KEY GUI TOGGLE
-------------------------------------------------

UserInputService.InputBegan:Connect(function(input,gp)

	if gp then return end

	if input.KeyCode == Enum.KeyCode.K then
		main.Visible = not main.Visible
	end
end)

-------------------------------------------------
-- FOV CIRCLE
-------------------------------------------------

local circle = Instance.new("Frame")
circle.Parent = screenGui
circle.Size = UDim2.new(0,FOV_RADIUS * 2,0,FOV_RADIUS * 2)
circle.AnchorPoint = Vector2.new(0.5,0.5)
circle.BackgroundTransparency = 0.85
circle.BackgroundColor3 = Color3.fromRGB(255,255,255)
circle.BorderSizePixel = 0

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1,0)
corner.Parent = circle

local stroke = Instance.new("UIStroke")
stroke.Parent = circle
stroke.Color = Color3.fromRGB(0,170,255)
stroke.Thickness = 1.5

-------------------------------------------------
-- VISIBILITY CHECK
-------------------------------------------------

local function isVisible(targetPart)

	local origin = Camera.CFrame.Position
	local direction = (targetPart.Position - origin)

	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {player.Character}
	params.FilterType = Enum.RaycastFilterType.Blacklist

	local result = workspace:Raycast(origin,direction,params)

	if result then
		return result.Instance:IsDescendantOf(targetPart.Parent)
	end

	return false
end

-------------------------------------------------
-- TARGET FINDER
-------------------------------------------------

local function getClosestTarget()

	local myCharacter = player.Character
	if not myCharacter then return nil end

	local myRoot = myCharacter:FindFirstChild("HumanoidRootPart")
	if not myRoot then return nil end

	local closest = nil
	local shortest = FOV_RADIUS

	for _,otherPlayer in pairs(Players:GetPlayers()) do

		if otherPlayer ~= player
		and otherPlayer.Team ~= player.Team then

			local character = otherPlayer.Character

			if character
			and character:FindFirstChild("Humanoid")
			and character:FindFirstChild("Head")
			and character:FindFirstChild("HumanoidRootPart")
			and character.Humanoid.Health > 0 then

				local distance =
					(myRoot.Position -
					character.HumanoidRootPart.Position).Magnitude

				if distance <= MAX_DISTANCE then

					local screenPos,onScreen =
						Camera:WorldToViewportPoint(character.Head.Position)

					if onScreen then

						local mousePos =
							Vector2.new(mouse.X,mouse.Y)

						local targetPos =
							Vector2.new(screenPos.X,screenPos.Y)

						local magnitude =
							(mousePos - targetPos).Magnitude

						if magnitude < shortest then

							if isVisible(character.Head) then
								shortest = magnitude
								closest = character
							end
						end
					end
				end
			end
		end
	end

	return closest
end

-------------------------------------------------
-- TRIGGERBOT
-------------------------------------------------

local function getMouseTarget()

	local target = mouse.Target
	if not target then
		return nil
	end

	local character =
		target:FindFirstAncestorOfClass("Model")

	if character
	and character:FindFirstChild("Humanoid")
	and character:FindFirstChild("Head") then

		local targetPlayer =
			Players:GetPlayerFromCharacter(character)

		if targetPlayer
		and targetPlayer ~= player
		and targetPlayer.Team ~= player.Team then

			return character
		end
	end

	return nil
end

-------------------------------------------------
-- AUTO SHOOT
-------------------------------------------------

local function autoShoot(target)

	if not AUTO_SHOOT then
		return
	end

	if tick() - lastShot < SHOOT_DELAY then
		return
	end

	lastShot = tick()

	local character = player.Character
	if not character then
		return
	end

	local tool =
		character:FindFirstChildOfClass("Tool")

	if tool then

		tool:Activate()

		local remote =
			tool:FindFirstChild("ShootRemote")

		if remote and remote:IsA("RemoteEvent") then
			remote:FireServer(target.Head.Position)
		end
	end
end

-------------------------------------------------
-- MAIN LOOP
-------------------------------------------------

RunService.RenderStepped:Connect(function()

	circle.Position =
		UDim2.new(0,mouse.X,0,mouse.Y)

	if not AIM_ENABLED then
		return
	end

	-------------------------------------------------
	-- AIM ASSIST
	-------------------------------------------------

	local target = getClosestTarget()

	if target and target:FindFirstChild("Head") then

		local headPos = target.Head.Position
		local camCF = Camera.CFrame

		local newCF = CFrame.new(
			camCF.Position,
			headPos
		)

		Camera.CFrame =
			camCF:Lerp(newCF,AIM_SMOOTHNESS)
	end

	-------------------------------------------------
	-- REACTION TRIGGERBOT
	-------------------------------------------------

	local mouseTarget = getMouseTarget()

	if mouseTarget then
		autoShoot(mouseTarget)
	end
end)
