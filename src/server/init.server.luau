-- Server: Main entry point for Trade Tycoon

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Initialize RemoteEvents first
require(ReplicatedStorage.Shared.RemoteEvents)

local DataStoreManager = require(script.DataStoreManager)
local SaveGame = require(ReplicatedStorage.Shared.SaveGame)

-- Wait for RemoteEvents to be created
local RemoteEvents = ReplicatedStorage.RemoteEvents

-- Handle load saves request
local LoadSavesEvent = RemoteEvents:WaitForChild("LoadSaves")
LoadSavesEvent.OnServerEvent:Connect(function(player)
	local saves = DataStoreManager.getSaveList(player)
	LoadSavesEvent:FireClient(player, saves)
end)

-- Handle create save request
local CreateSaveEvent = RemoteEvents:WaitForChild("CreateSave")
CreateSaveEvent.OnServerEvent:Connect(function(player, industryType: string)
	local newSave = SaveGame.new(player.UserId, industryType)
	SaveGame.initResources(newSave)
	
	local success, err = DataStoreManager.saveGame(player, newSave)
	if success then
		print("Created save for player:", player.Name, "Industry:", industryType)
	end
end)

-- Handle delete save request
local DeleteSaveEvent = RemoteEvents:WaitForChild("DeleteSave")
DeleteSaveEvent.OnServerEvent:Connect(function(player)
	local success, err = DataStoreManager.deleteSave(player)
	if success then
		print("Deleted save for player:", player.Name)
	end
end)

-- Handle update save request
local UpdateSaveEvent = RemoteEvents:WaitForChild("UpdateSave")
UpdateSaveEvent.OnServerEvent:Connect(function(player, saveData: any)
	print("Received update save request from:", player.Name)
	print("Save data:", saveData and saveData.Type or "nil", saveData and saveData.Money or "nil")
	local success, err = DataStoreManager.saveGame(player, saveData)
	if success then
		print("Updated save for player:", player.Name)
	else
		warn("Failed to update save:", err)
	end
end)

print("Trade Tycoon server initialized")
