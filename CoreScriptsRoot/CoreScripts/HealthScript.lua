--[[ 
	This script controls the gui the player sees in regards to his or her health.
	Can be turned with Game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health,false)
	Copyright ROBLOX 2014. Written by Ben Tkacheff.
--]]
local game = game
local wait = wait
local pcall = pcall

local Instance = Instance local Instance_new = Instance.new
local Color3 = Color3 local Color3_new = Color3.new local RGB = Color3.fromRGB
local UDim2 = UDim2 local UDim2_new = UDim2.new

local math = math
	local max, min = math.max, math.min
	local abs = math.abs
local Enum = Enum
	local EasingDirection, EasingStyle = Enum.EasingDirection, Enum.EasingStyle
	local CoreGuiType = Enum.CoreGuiType

local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

---------------------------------------------------------------------
-- Initialize/Variables
while not game do
	wait(1 / 60)
end
while not Players do
	wait(1 / 60)
end

local useCoreHealthBar = false
local success = pcall(function() useCoreHealthBar = Players:GetUseCoreScriptHealthBar() end)
if not success or not useCoreHealthBar then
	return
end

local currentHumanoid = nil

local HealthGui = nil
local lastHealth = 100
local HealthPercentageForOverlay = 5
local maxBarTweenTime = 0.3
local greenColor = Color3_new(0.2, 1, 0.2)
local redColor = Color3_new(1, 0.2, 0.2)
local yellowColor = Color3_new(1, 1, 0.2)

local guiEnabled = false
local healthChangedConnection = nil
local humanoidDiedConnection = nil
local characterAddedConnection = nil

local greenBarImage = "rbxasset://textures/ui/Health-BKG-Center.png"
local greenBarImageLeft = "rbxasset://textures/ui/Health-BKG-Left-Cap.png"
local greenBarImageRight = "rbxasset://textures/ui/Health-BKG-Right-Cap.png"
local hurtOverlayImage = "rbxassetid://34854607"

ContentProvider:Preload(greenBarImage)
ContentProvider:Preload(hurtOverlayImage)

while not Players.LocalPlayer do
	wait(1 / 60)
end

---------------------------------------------------------------------
-- Functions

local capHeight = 15
local capWidth = 7

function CreateGui()
	if HealthGui and #HealthGui:GetChildren() > 0 then 
		HealthGui.Parent = CoreGui.RobloxGui
		return 
	end

	local hurtOverlay = Instance_new("ImageLabel")
	hurtOverlay.Name = "HurtOverlay"
	hurtOverlay.BackgroundTransparency = 1
	hurtOverlay.Image = hurtOverlayImage
	hurtOverlay.Position = UDim2_new(-10, 0, -10, 0)
	hurtOverlay.Size = UDim2_new(20, 0, 20, 0)
	hurtOverlay.Visible = false
	hurtOverlay.Parent = HealthGui
	
	local healthFrame = Instance_new("Frame")
	healthFrame.Name = "HealthFrame"
	healthFrame.BackgroundTransparency = 1
	healthFrame.BackgroundColor3 = Color3_new(1, 1, 1)
	healthFrame.BorderColor3 = Color3_new(0, 0, 0)
	healthFrame.BorderSizePixel = 0
	healthFrame.Position = UDim2_new(0.5, -85, 1, -20)
	healthFrame.Size = UDim2_new(0, 170, 0, capHeight)
	healthFrame.Parent = HealthGui


	local healthBarBackCenter = Instance_new("ImageLabel")
	healthBarBackCenter.Name = "healthBarBackCenter"
	healthBarBackCenter.BackgroundTransparency = 1
	healthBarBackCenter.Image = greenBarImage
	healthBarBackCenter.Size = UDim2_new(1,-capWidth * 2,1,0)
	healthBarBackCenter.Position = UDim2_new(0,capWidth,0,0)
	healthBarBackCenter.Parent = healthFrame
	healthBarBackCenter.ImageColor3 = Color3_new(1,1,1)

	local healthBarBackLeft = Instance_new("ImageLabel")
	healthBarBackLeft.Name = "healthBarBackLeft"
	healthBarBackLeft.BackgroundTransparency = 1
	healthBarBackLeft.Image = greenBarImageLeft
	healthBarBackLeft.Size = UDim2_new(0, capWidth, 1, 0)
	healthBarBackLeft.Position = UDim2_new(0, 0, 0, 0)
	healthBarBackLeft.Parent = healthFrame
	healthBarBackLeft.ImageColor3 = Color3_new(1, 1, 1)

	local healthBarBackRight = Instance_new("ImageLabel")
	healthBarBackRight.Name = "healthBarBackRight"
	healthBarBackRight.BackgroundTransparency = 1
	healthBarBackRight.Image = greenBarImageRight
	healthBarBackRight.Size = UDim2_new(0, capWidth, 1, 0)
	healthBarBackRight.Position = UDim2_new(1, -capWidth, 0, 0)
	healthBarBackRight.Parent = healthFrame
	healthBarBackRight.ImageColor3 = Color3_new(1, 1, 1)


	local healthBar = Instance_new("Frame")
	healthBar.Name = "HealthBar"
	healthBar.BackgroundTransparency = 1
	healthBar.BackgroundColor3 = Color3_new(1, 1, 1)
	healthBar.BorderColor3 = Color3_new(0, 0, 0)
	healthBar.BorderSizePixel = 0
	healthBar.ClipsDescendants = true
	healthBar.Position = UDim2_new(0, 0, 0, 0)
	healthBar.Size = UDim2_new(1, 0, 1, 0)
	healthBar.Parent = healthFrame


	local healthBarCenter = Instance_new("ImageLabel")
	healthBarCenter.Name = "healthBarCenter"
	healthBarCenter.BackgroundTransparency = 1
	healthBarCenter.Image = greenBarImage
	healthBarCenter.Size = UDim2_new(1, -capWidth * 2, 1, 0)
	healthBarCenter.Position = UDim2_new(0, capWidth, 0, 0)
	healthBarCenter.Parent = healthBar
	healthBarCenter.ImageColor3 = greenColor

	local healthBarLeft = Instance_new("ImageLabel")
	healthBarLeft.Name = "healthBarLeft"
	healthBarLeft.BackgroundTransparency = 1
	healthBarLeft.Image = greenBarImageLeft
	healthBarLeft.Size = UDim2_new(0, capWidth, 1, 0)
	healthBarLeft.Position = UDim2_new(0, 0, 0, 0)
	healthBarLeft.Parent = healthBar
	healthBarLeft.ImageColor3 = greenColor

	local healthBarRight = Instance_new("ImageLabel")
	healthBarRight.Name = "healthBarRight"
	healthBarRight.BackgroundTransparency = 1
	healthBarRight.Image = greenBarImageRight
	healthBarRight.Size = UDim2_new(0, capWidth, 1, 0)
	healthBarRight.Position = UDim2_new(1, -capWidth, 0, 0)
	healthBarRight.Parent = healthBar
	healthBarRight.ImageColor3 = greenColor

	HealthGui.Parent = CoreGui.RobloxGui
end

function UpdateGui(health)
	if not HealthGui then return end
	
	local healthFrame = HealthGui:FindFirstChild("HealthFrame")
	if not healthFrame then return end
	
	local healthBar = healthFrame:FindFirstChild("HealthBar")
	if not healthBar then return end
	
	-- If more than 1/4 health, bar = green.  Else, bar = red.
	local percentHealth = (health / currentHumanoid.MaxHealth)
	if percentHealth ~= percentHealth then
		percentHealth = 1
		healthBar.healthBarCenter.ImageColor3 = yellowColor
		healthBar.healthBarRight.ImageColor3 = yellowColor
		healthBar.healthBarLeft.ImageColor3 = yellowColor
	elseif percentHealth > 0.25  then		
		healthBar.healthBarCenter.ImageColor3 = greenColor
		healthBar.healthBarRight.ImageColor3 = greenColor
		healthBar.healthBarLeft.ImageColor3 = greenColor
	else
		healthBar.healthBarCenter.ImageColor3 = redColor
		healthBar.healthBarRight.ImageColor3 = redColor
		healthBar.healthBarLeft.ImageColor3 = redColor
	end
		
	local width = (health / currentHumanoid.MaxHealth)
 	width = max(min(width, 1), 0) -- make sure width is between 0 and 1
 	if width ~= width then width = 1 end
	local healthDelta = lastHealth - health
	lastHealth = health
	local percentOfTotalHealth = abs(healthDelta / currentHumanoid.MaxHealth)
	percentOfTotalHealth = max(min(percentOfTotalHealth, 1), 0) -- make sure percentOfTotalHealth is between 0 and 1
	if percentOfTotalHealth ~= percentOfTotalHealth then percentOfTotalHealth = 1 end
	local newHealthSize = UDim2_new(width, 0, 1, 0)
	healthBar.Size = newHealthSize
	local sizeX = healthBar.AbsoluteSize.X
	if sizeX < capWidth then
		healthBar.healthBarCenter.Visible = false
		healthBar.healthBarRight.Visible = false
	elseif sizeX < (2 * capWidth + 1) then
		healthBar.healthBarCenter.Visible = true
		healthBar.healthBarCenter.Size = UDim2_new(0, sizeX - capWidth, 1, 0)
		healthBar.healthBarRight.Visible = false
	else
		healthBar.healthBarCenter.Visible = true
		healthBar.healthBarCenter.Size = UDim2_new(1, -capWidth * 2, 1, 0)
		healthBar.healthBarRight.Visible = true
	end
	local thresholdForHurtOverlay = currentHumanoid.MaxHealth * (HealthPercentageForOverlay * 0.01)
	--local thresholdForHurtOverlay = currentHumanoid.MaxHealth * (HealthPercentageForOverlay / 100)
	if healthDelta >= thresholdForHurtOverlay and guiEnabled then AnimateHurtOverlay() end
end

function AnimateHurtOverlay()
	if not HealthGui then return end
	local overlay = HealthGui:FindFirstChild("HurtOverlay")
	if not overlay then return end
	local newSize = UDim2_new(20, 0, 20, 0)
	local newPos = UDim2_new(-10, 0, -10, 0)
	if overlay:IsDescendantOf(game) then
		-- stop any tweens on overlay
		overlay:TweenSizeAndPosition(newSize, newPos, EasingDirection.Out, EasingStyle.Linear, 0, true, function()
			-- show the gui
			overlay.Size = UDim2_new(1, 0, 1, 0)
			overlay.Position = UDim2_new(0, 0, 0, 0)
			overlay.Visible = true
			-- now tween the hide
			if overlay:IsDescendantOf(game) then
				overlay:TweenSizeAndPosition(newSize, newPos, EasingDirection.Out, EasingStyle.Quad, 10, false, function()
					overlay.Visible = false
				end)
			else
				overlay.Size = newSize
				overlay.Position = newPos
			end
		end)
	else
		overlay.Size = newSize
		overlay.Position = newPos
	end
end

function humanoidDied() UpdateGui(0) end
function disconnectPlayerConnections()
	if characterAddedConnection then characterAddedConnection:Disconnect() end
	if humanoidDiedConnection then humanoidDiedConnection:Disconnect() end
	if healthChangedConnection then healthChangedConnection:Disconnect() end
end

function newPlayerCharacter()
	disconnectPlayerConnections()
	startGui()
end

function startGui()
	characterAddedConnection = Players.LocalPlayer.CharacterAdded:Connect(newPlayerCharacter)
	local character = Players.LocalPlayer.Character
	if not character then return end
	currentHumanoid = character:WaitForChild("Humanoid")
	if not currentHumanoid then return end
	if not StarterGui:GetCoreGuiEnabled(CoreGuiType.Health) then return end
	healthChangedConnection = currentHumanoid.HealthChanged:Connect(UpdateGui)
	humanoidDiedConnection = currentHumanoid.Died:Connect(humanoidDied)
	UpdateGui(currentHumanoid.Health)
	CreateGui()
end



---------------------------------------------------------------------
-- Start Script

HealthGui = Instance_new("Frame")
HealthGui.Name = "HealthGui"
HealthGui.BackgroundTransparency = 1
HealthGui.Size = UDim2_new(1, 0, 1, 0)

StarterGui.CoreGuiChangedSignal:Connect(function(coreGuiType, enabled)
	if coreGuiType == CoreGuiType.Health or coreGuiType == CoreGuiType.All then
		if guiEnabled and not enabled then
			if HealthGui then
				HealthGui.Parent = nil
			end
			disconnectPlayerConnections()
		elseif not guiEnabled and enabled then
			startGui()
		end
		
		guiEnabled = enabled
	end
end)

if StarterGui:GetCoreGuiEnabled(CoreGuiType.Health) then
	guiEnabled = true
	startGui()
end
