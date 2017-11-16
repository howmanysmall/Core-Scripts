--[[
		// Filename: ServerStarterScript.lua
		// Version: 1.0
		// Description: Server core script that handles core script server side logic.
]]--

local game = game
local wait = wait
local typeof = typeof
local pcall = pcall
local type = type
local require = require
local Instance = Instance local Instance_new = Instance.new

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Chat = game:GetService("Chat")
local runService = game:GetService("RunService")

-- Prevent server script from running in Studio when not in run mode
while not runService:IsRunning() do wait() end
--[[ Services ]]--
local RobloxReplicatedStorage = game:GetService("RobloxReplicatedStorage")
local ScriptContext = game:GetService("ScriptContext")

--[[ Add Server CoreScript ]]--
ScriptContext:AddCoreScriptLocal("ServerCoreScripts/ServerSocialScript", script.Parent)

--[[ Remote Events ]]--
local RemoteEvent_SetDialogInUse = Instance_new("RemoteEvent")
RemoteEvent_SetDialogInUse.Name = "SetDialogInUse"
RemoteEvent_SetDialogInUse.Parent = RobloxReplicatedStorage

local RemoteFunction_GetServerVersion = Instance_new("RemoteFunction")
RemoteFunction_GetServerVersion.Name = "GetServerVersion"
RemoteFunction_GetServerVersion.Parent = RobloxReplicatedStorage

--[[ Event Connections ]]--
local playerDialogMap = { }

local dialogInUseFixFlagSuccess, dialogInUseFixValue = pcall(function() return settings():GetFFlag("DialogInUseFix") end)
local dialogInUseFixFlag = (dialogInUseFixFlagSuccess and dialogInUseFixValue)

local dialogMultiplePlayersFlagSuccess, dialogMultiplePlayersFlagValue = pcall(function() return settings():GetFFlag("DialogMultiplePlayers") end)
local dialogMultiplePlayersFlag = (dialogMultiplePlayersFlagSuccess and dialogMultiplePlayersFlagValue)

local freeCameraFlagSuccess, freeCameraFlagValue = pcall(function() return settings():GetFFlag("FreeCameraForAdmins") end)
local freeCameraFlag = (freeCameraFlagSuccess and freeCameraFlagValue)

local displayServerVersionSuccess, displayServerVersionValue = pcall(function() return settings():GetFFlag("DisplayVersionInformation") end)
local displayServerVersionFlag = (displayServerVersionSuccess and displayServerVersionValue)

local function setDialogInUse(player, dialog, value, waitTime)
	if typeof(dialog) ~= "Instance" or not dialog:IsA("Dialog") then return end
	if type(value) ~= "boolean" then return end
	if type(waitTime) ~= "number" and type(waitTime) ~= "nil" then return end
	if typeof(player) ~= "Instance" or not player:IsA("Player") then return end
	if waitTime and waitTime ~= 0 then wait(waitTime) end
	if dialog ~= nil then
		if dialogMultiplePlayersFlag then
			dialog:SetPlayerIsUsing(player, value)
		else
			dialog.InUse = value
		end
		if dialogInUseFixFlag then
			if value == true then
				playerDialogMap[player] = dialog
			else
				playerDialogMap[player] = nil
			end
		end
	end
end
RemoteEvent_SetDialogInUse.OnServerEvent:Connect(setDialogInUse)

local function getServerVersion()
	local rawVersion = runService:GetRobloxVersion()
	local displayVersion
	if rawVersion == "?" then
		displayVersion = "DEBUG_SERVER"
	else
		if runService:IsStudio() then
			displayVersion = "ROBLOX Studio"
		else
			displayVersion = rawVersion
		end
	end
	return displayVersion
end

RemoteFunction_GetServerVersion.OnServerInvoke = displayServerVersionFlag and getServerVersion or function() return "" end

Players.PlayerRemoving:Connect(function(player)
	if dialogInUseFixFlag then
		if player then
			local dialog = playerDialogMap[player]
			if dialog then
				if dialogMultiplePlayersFlag then
					dialog:SetPlayerIsUsing(player, false)
				else
					dialog.InUse = false
				end
				playerDialogMap[player] = nil
			end
		end
	end
end)

if Chat.LoadDefaultChat then
	require(CoreGui.RobloxGui.Modules.Server.ClientChat.ChatWindowInstaller)()
	require(CoreGui.RobloxGui.Modules.Server.ServerChat.ChatServiceInstaller)()
end

if freeCameraFlag then
	require(CoreGui.RobloxGui.Modules.Server.FreeCamera.FreeCameraInstaller)()
end
