--[[
		// Filename: VehicleHud.lua
		// Version 1.0
		// Written by: jmargh
		// Description: Implementation of the VehicleSeat HUD

		// TODO:
			Once this is live and stable, move to PlayerScripts as module
]]
local game = game
local script = script
local wait = wait
local require = require
local pairs = pairs
local tostring = tostring
--*.new stuff
local Color3 = Color3 local RGB = Color3.fromRGB
local Instance = Instance local Instance_new = Instance.new
local UDim2 = UDim2 local UDim2_new = UDim2.new
--@enums, math, tables, etc.
local math = math
	local min = math.min
	local floor = math.floor
local Enum = Enum
	local Font = Enum.Font
	local TextXAlignment, TextYAlignment = Enum.TextXAlignment, Enum.TextYAlignment
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
while not Players.LocalPlayer do wait() end
local LocalPlayer = Players.LocalPlayer
local RobloxGui = script.Parent
local CurrentVehicleSeat = nil
local VehicleSeatHeartbeatCn = nil
local VehicleSeatHUDChangedCn = nil

local RobloxGui = game:GetService("CoreGui"):WaitForChild("RobloxGui")
RobloxGui:WaitForChild("Modules"):WaitForChild("TenFootInterface")
local isTenFootInterface = require(RobloxGui.Modules.TenFootInterface):IsEnabled()


--[[ Images ]]--
local VEHICLE_HUD_BG = "rbxasset://textures/ui/Vehicle/SpeedBarBKG.png"
local SPEED_BAR_EMPTY = "rbxasset://textures/ui/Vehicle/SpeedBarEmpty.png"
local SPEED_BAR = "rbxasset://textures/ui/Vehicle/SpeedBar.png"

--[[ Constants ]]--
local BOTTOM_OFFSET = (isTenFootInterface and 100 or 70)

--[[ Gui Creation ]]--
local function createImageLabel(name, size, position, image, parent)
	local imageLabel = Instance_new("ImageLabel")
	imageLabel.Name = name
	imageLabel.Size = size
	imageLabel.Position = position
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = image
	imageLabel.Parent = parent

	return imageLabel
end

local function createTextLabel(name, alignment, text, parent)
	local textLabel = Instance_new("TextLabel")
	textLabel.Name = name
	textLabel.Size = UDim2_new(1, -4, 0, (isTenFootInterface and 50 or 20))
	textLabel.Position = UDim2_new(0, 2, 0, (isTenFootInterface and -50 or -20))
	textLabel.BackgroundTransparency = 1
	textLabel.TextXAlignment = alignment
	textLabel.Font = Font.SourceSans
	textLabel.TextSize = (isTenFootInterface and 48 or 18)
	textLabel.TextColor3 = RGB(255, 255, 255)
	textLabel.TextStrokeTransparency = 0.5
	textLabel.TextStrokeColor3 = RGB(49, 49, 49)
	textLabel.Text = text
	textLabel.Parent = parent

	return textLabel
end

local VehicleHudFrame = Instance_new("Frame")
VehicleHudFrame.Name = "VehicleHudFrame"
VehicleHudFrame.Size = UDim2_new(0, (isTenFootInterface and 316 or 158), 0, (isTenFootInterface and 50 or 14))
VehicleHudFrame.Position = UDim2_new(0.5, -(VehicleHudFrame.Size.X.Offset * 0.5), 1, -BOTTOM_OFFSET - VehicleHudFrame.Size.Y.Offset)
VehicleHudFrame.BackgroundTransparency = 1
VehicleHudFrame.Visible = false
VehicleHudFrame.Parent = RobloxGui

local speedBarClippingFrame = Instance_new("Frame")
speedBarClippingFrame.Name = "SpeedBarClippingFrame"
speedBarClippingFrame.Size = UDim2_new(0, 0, 0, (isTenFootInterface and 24 or 4))
speedBarClippingFrame.Position = UDim2_new(0.5, (isTenFootInterface and -142 or -71), 0.5, (isTenFootInterface and -13 or -2))
speedBarClippingFrame.BackgroundTransparency = 1
speedBarClippingFrame.ClipsDescendants = true
speedBarClippingFrame.Parent = VehicleHudFrame

local HudBG = createImageLabel("HudBG", UDim2_new(1, 0, 1, 0), UDim2_new(0, 0, 0, 1), VEHICLE_HUD_BG, VehicleHudFrame)
local SpeedBG = createImageLabel("SpeedBG", UDim2_new(0, (isTenFootInterface and 284 or 142), 0, (isTenFootInterface and 24 or 4)), UDim2_new(0.5, (isTenFootInterface and -142 or -71), 0.5, (isTenFootInterface and -13 or -2)), SPEED_BAR_EMPTY, VehicleHudFrame)
local SpeedBarImage = createImageLabel("SpeedBarImage", UDim2_new(0, (isTenFootInterface and 284 or 142), 1, 0), UDim2_new(0, 0, 0, 0), SPEED_BAR, speedBarClippingFrame)
SpeedBarImage.ZIndex = 2

local SpeedLabel = createTextLabel("SpeedLabel", TextXAlignment.Left, "Speed", VehicleHudFrame)
local SpeedText = createTextLabel("SpeedText", TextXAlignment.Right, "0", VehicleHudFrame)

--[[ Local Functions ]]--
local function getHumanoid()
	local character = LocalPlayer and LocalPlayer.Character
	if character then
		for _, child in pairs(character:GetChildren()) do
			if child:IsA("Humanoid") then
				return child
			end
		end
	end
end

local function onHeartbeat()
	if CurrentVehicleSeat then
		local speed = CurrentVehicleSeat.Velocity.magnitude
		SpeedText.Text = tostring(min(floor(speed), 9999))
		local drawSize = floor((speed / CurrentVehicleSeat.MaxSpeed) * SpeedBG.Size.X.Offset)
		drawSize = min(drawSize, SpeedBG.Size.X.Offset)
		speedBarClippingFrame.Size = UDim2_new(0, drawSize, 0, (isTenFootInterface and 24 or 4))
	end
end

local function onVehicleSeatChanged(property)
	if property == "HeadsUpDisplay" then
		VehicleHudFrame.Visible = not VehicleHudFrame.Visible
	end
end

local function onSeated(active, currentSeatPart)
	if active then
		if currentSeatPart and currentSeatPart:IsA("VehicleSeat") then
			CurrentVehicleSeat = currentSeatPart
			VehicleHudFrame.Visible = CurrentVehicleSeat.HeadsUpDisplay
			VehicleSeatHeartbeatCn = RunService.Heartbeat:Connect(onHeartbeat)
			VehicleSeatHUDChangedCn = CurrentVehicleSeat.Changed:Connect(onVehicleSeatChanged)
		end
	else
		if CurrentVehicleSeat then
			VehicleHudFrame.Visible = false
			CurrentVehicleSeat = nil
			if VehicleSeatHeartbeatCn then
				VehicleSeatHeartbeatCn:Disconnect()
				VehicleSeatHeartbeatCn = nil
			end
			if VehicleSeatHUDChangedCn then
				VehicleSeatHUDChangedCn:Disconnect()
				VehicleSeatHUDChangedCn = nil
			end
		end
	end
end

local function connectSeated()
	local humanoid = getHumanoid()
	while not humanoid do
		wait()
		humanoid = getHumanoid()
	end
	humanoid.Seated:Connect(onSeated)
end
if LocalPlayer.Character then
	connectSeated()
end
LocalPlayer.CharacterAdded:Connect(function(character)
	onSeated(false)
	connectSeated()
end)
