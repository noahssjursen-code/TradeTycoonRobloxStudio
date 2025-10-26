-- SaveGame: Save game data structure

local SaveGame = {}

-- Resource identifiers (global constants)
SaveGame.ResourceIDs = {
	-- Raw materials
	COAL = "coal",
	IRON = "iron",
	IRON_ORE = "iron_ore",
	COPPER = "copper",
	COPPER_ORE = "copper_ore",
	WOOD = "wood",
	WOOD_LOG = "wood_log",
	STONE = "stone",
	GOLD = "gold",
	GOLD_ORE = "gold_ore",
	
	-- Processed materials
	IRON_BAR = "iron_bar",
	IRON_PLATE = "iron_plate",
	COPPER_WIRE = "copper_wire",
	COPPER_BAR = "copper_bar",
	WOOD_PLANK = "wood_plank",
	ENERGY = "energy",
	
	-- Currency
	MONEY = "gold",
}

-- Save game data structure
export type SaveGameData = {
	Type: string,  -- Industry type (e.g. "logging", "coal mining")
	Money: number,
	Resources: {[string]: number},  -- Dictionary of resource ID -> amount
	ResourceIdentifiers: {[string]: string}?, -- Maps resource display names to IDs
	PlayerId: number,
	CreatedAt: number,  -- Timestamp
	LastPlayed: number, -- Timestamp
	GridCells: {[number]: any}?, -- Store building data per cell ID
}

function SaveGame.new(playerId: number, industryType: string): SaveGameData
	return {
		Type = industryType,
		Money = 500,  -- Starting money
		Resources = {},  -- Empty resources, will be populated based on industry
		PlayerId = playerId,
		CreatedAt = os.time(),
		LastPlayed = os.time(),
	}
end

-- Get default starting resources based on industry (with IDs)
function SaveGame.getStartingResources(industryType: string): {[string]: number}
	local startingResources = {
		["logging"] = {
			[SaveGame.ResourceIDs.WOOD_LOG] = 0,
		},
		["coal mining"] = {
			[SaveGame.ResourceIDs.COAL] = 0,
		},
		["iron mining"] = {
			[SaveGame.ResourceIDs.IRON_ORE] = 0,
		},
		["copper mining"] = {
			[SaveGame.ResourceIDs.COPPER_ORE] = 0,
		},
		["stone quarrying"] = {
			[SaveGame.ResourceIDs.STONE] = 0,
		},
		["gold mining"] = {
			[SaveGame.ResourceIDs.GOLD_ORE] = 0,
		},
	}
	
	return startingResources[string.lower(industryType)] or {}
end

-- Get resource identifier mapping
function SaveGame.getResourceIdentifiers(): {[string]: string}
	return {
		["Wood Log"] = SaveGame.ResourceIDs.WOOD_LOG,
		["Coal"] = SaveGame.ResourceIDs.COAL,
		["Iron Ore"] = SaveGame.ResourceIDs.IRON_ORE,
		["Copper Ore"] = SaveGame.ResourceIDs.COPPER_ORE,
		["Stone"] = SaveGame.ResourceIDs.STONE,
		["Gold Ore"] = SaveGame.ResourceIDs.GOLD_ORE,
		["Iron Bar"] = SaveGame.ResourceIDs.IRON_BAR,
		["Iron Plate"] = SaveGame.ResourceIDs.IRON_PLATE,
		["Copper Wire"] = SaveGame.ResourceIDs.COPPER_WIRE,
		["Wood Plank"] = SaveGame.ResourceIDs.WOOD_PLANK,
		["Energy"] = SaveGame.ResourceIDs.ENERGY,
	}
end

-- Initialize starting resources for a save game
function SaveGame.initResources(saveGame: SaveGameData)
	local industryType = saveGame.Type
	local resources = SaveGame.getStartingResources(industryType)
	
	for resourceName, amount in pairs(resources) do
		saveGame.Resources[resourceName] = amount
	end
	
	-- Initialize grid cells data structure
	saveGame.GridCells = {}
	
	-- Initialize resource identifiers
	saveGame.ResourceIdentifiers = SaveGame.getResourceIdentifiers()
end

-- Ensure save has all required fields, add defaults if missing
function SaveGame.ensureDefaults(saveGame: any): SaveGameData
	if not saveGame then return nil end
	
	-- Ensure optional fields exist
	if not saveGame.ResourceIdentifiers then
		saveGame.ResourceIdentifiers = {}
	end
	
	if not saveGame.GridCells then
		saveGame.GridCells = {}
	end
	
	if not saveGame.CreatedAt then
		saveGame.CreatedAt = os.time()
	end
	
	if not saveGame.LastPlayed then
		saveGame.LastPlayed = os.time()
	end
	
	return saveGame
end

-- Validate save game data (lenient validation - only check essential fields)
function SaveGame.validate(saveGame: any): boolean
	print("Validating save data...")
	print("  Type:", saveGame.Type)
	print("  Money:", saveGame.Money)
	print("  Resources:", saveGame.Resources)
	
	-- Only require absolutely essential fields
	if not saveGame.Type then 
		print("  Missing Type - FAILED")
		return false 
	end
	if saveGame.Money == nil then 
		print("  Missing Money - FAILED")
		return false 
	end
	
	-- Resources can be optional (initialize to empty if missing)
	if not saveGame.Resources then
		saveGame.Resources = {}
	end
	
	-- PlayerId can be missing (will be filled by context)
	if not saveGame.PlayerId then
		saveGame.PlayerId = 0 -- Use 0 as placeholder
	end
	
	print("  Validation passed!")
	return true
end

return SaveGame

