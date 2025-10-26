-- DataStoreManager: Manages save games using DataStoreService

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local SaveGame = require(game.ReplicatedStorage.Shared.SaveGame)

local DataStoreManager = {}

local SAVES_DATASTORE_NAME = "TradeTycoonSaves"
local savesDataStore = DataStoreService:GetDataStore(SAVES_DATASTORE_NAME)

-- Save a player's game
function DataStoreManager.saveGame(player: Player, saveData: any): (boolean, string?)
	local success, err = pcall(function()
		local key = tostring(player.UserId)
		savesDataStore:SetAsync(key, saveData)
	end)
	
	if not success then
		warn("Failed to save game for player", player.Name, ":", err)
		return false, tostring(err)
	end
	
	return true, nil
end

-- Load a player's game
function DataStoreManager.loadGame(player: Player): (SaveGame.SaveGameData?, string?)
	local success, saveData = pcall(function()
		local key = tostring(player.UserId)
		return savesDataStore:GetAsync(key)
	end)
	
	if not success then
		warn("Failed to load game for player", player.Name, ":", saveData)
		return nil, tostring(saveData)
	end
	
	if not saveData then
		return nil, "No save data found"
	end
	
	-- Fill in PlayerId if missing (for backward compatibility)
	if not saveData.PlayerId then
		saveData.PlayerId = player.UserId
	end
	
	-- Validate the loaded data
	if SaveGame.validate(saveData) then
		-- Ensure all optional fields exist for backward compatibility
		saveData = SaveGame.ensureDefaults(saveData)
		return saveData, nil
	else
		return nil, "Invalid save data"
	end
end

-- Get a list of all saves (for a future feature)
function DataStoreManager.getSaveList(player: Player): {SaveGame.SaveGameData}
	-- This would list all saves for a player
	-- For now, just returns their main save
	print("Getting save list for player:", player.Name)
	local saveData, err = DataStoreManager.loadGame(player)
	
	print("Load result:", saveData and "found" or "not found", err)
	
	if saveData then
		print("Save data:", saveData.Type, saveData.Money)
		return {saveData}
	else
		print("No save data found")
		return {}
	end
end

-- Auto-save (call periodically)
function DataStoreManager.autoSave(player: Player, saveData: SaveGame.SaveGameData)
	local success, err = DataStoreManager.saveGame(player, saveData)
	
	if success then
		print("Auto-saved game for player:", player.Name)
	else
		warn("Failed to auto-save:", err)
	end
end

-- Delete a player's save
function DataStoreManager.deleteSave(player: Player): (boolean, string?)
	local success, err = pcall(function()
		local key = tostring(player.UserId)
		savesDataStore:RemoveAsync(key)
	end)
	
	if not success then
		warn("Failed to delete save for player", player.Name, ":", err)
		return false, tostring(err)
	end
	
	return true, nil
end

return DataStoreManager

