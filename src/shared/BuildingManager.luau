-- BuildingManager: Manages building definitions and types

local BuildingManager = {}

-- Building type definitions
BuildingManager.Types = {
	RawMaterialProducer = "RawMaterialProducer",
	Processor = "Processor",
	Storage = "Storage",
	Upgrade = "Upgrade",
}

-- Building data structure
export type Building = {
	id: string,
	name: string,
	type: string,
	category: string,
	price: number,
	produces: {[string]: number}?, -- Resource name -> amount
	requires: {[string]: number}?, -- Required input resources
	icon: string,
	color: Color3,
	size: {width: number, height: number},
	level: number,
	maxLevel: number,
	upgradeCost: {[number]: {[string]: number}}?, -- Level -> {resource -> amount}
}

-- Available buildings by industry
BuildingManager.buildings = {
	["Coal Mining"] = {
		{
			id = "coal_mine_basic",
			name = "Coal Mine",
			type = BuildingManager.Types.RawMaterialProducer,
			category = "Mining",
			price = 500,
			produces = { coal = 10 },
			icon = "⛏️",
			color = Color3.fromRGB(40, 40, 40),
			size = { width = 1, height = 1 },
			level = 1,
			maxLevel = 5,
			upgradeCost = {
				[2] = { gold = 200 },
				[3] = { gold = 500 },
				[4] = { gold = 1000 },
				[5] = { gold = 2500 },
			}
		},
	},
	
	["Iron Mining"] = {
		{
			id = "iron_mine_basic",
			name = "Iron Mine",
			type = BuildingManager.Types.RawMaterialProducer,
			category = "Mining",
			price = 500,
			produces = { iron = 10 },
			icon = "⛏️",
			color = Color3.fromRGB(180, 100, 80),
			size = { width = 1, height = 1 },
			level = 1,
			maxLevel = 5,
			upgradeCost = {
				[2] = { gold = 200 },
				[3] = { gold = 500 },
				[4] = { gold = 1000 },
				[5] = { gold = 2500 },
			}
		},
		{
			id = "smelting_station",
			name = "Smelting Station",
			type = BuildingManager.Types.Processor,
			category = "Processing",
			price = 1000,
			produces = { iron_bar = 5 },
			requires = { iron = 10 },
			icon = "🔥",
			color = Color3.fromRGB(200, 50, 50),
			size = { width = 1, height = 1 },
			level = 1,
			maxLevel = 3,
			upgradeCost = {
				[2] = { gold = 500 },
				[3] = { gold = 1500 },
			}
		},
	},
	
	["Copper Mining"] = {
		{
			id = "copper_mine_basic",
			name = "Copper Mine",
			type = BuildingManager.Types.RawMaterialProducer,
			category = "Mining",
			price = 500,
			produces = { copper = 10 },
			icon = "⛏️",
			color = Color3.fromRGB(184, 115, 51),
			size = { width = 1, height = 1 },
			level = 1,
			maxLevel = 5,
			upgradeCost = {
				[2] = { gold = 200 },
				[3] = { gold = 500 },
				[4] = { gold = 1000 },
				[5] = { gold = 2500 },
			}
		},
	},
	
	["Logging"] = {
		{
			id = "lumberjack_station",
			name = "Lumberjack Station",
			type = BuildingManager.Types.RawMaterialProducer,
			category = "Logging",
			price = 500,
			produces = { wood = 10 },
			icon = "🪓",
			color = Color3.fromRGB(60, 120, 60),
			size = { width = 1, height = 1 },
			level = 1,
			maxLevel = 5,
			upgradeCost = {
				[2] = { gold = 200 },
				[3] = { gold = 500 },
				[4] = { gold = 1000 },
				[5] = { gold = 2500 },
			}
		},
		{
			id = "sawmill",
			name = "Sawmill",
			type = BuildingManager.Types.Processor,
			category = "Processing",
			price = 1000,
			produces = { wood_plank = 5 },
			requires = { wood = 10 },
			icon = "🪚",
			color = Color3.fromRGB(100, 80, 60),
			size = { width = 1, height = 1 },
			level = 1,
			maxLevel = 3,
			upgradeCost = {
				[2] = { gold = 500 },
				[3] = { gold = 1500 },
			}
		},
	},
	
	["Stone Quarrying"] = {
		{
			id = "stone_quarry",
			name = "Stone Quarry",
			type = BuildingManager.Types.RawMaterialProducer,
			category = "Quarrying",
			price = 500,
			produces = { stone = 10 },
			icon = "📦",
			color = Color3.fromRGB(120, 120, 120),
			size = { width = 1, height = 1 },
			level = 1,
			maxLevel = 5,
			upgradeCost = {
				[2] = { gold = 200 },
				[3] = { gold = 500 },
				[4] = { gold = 1000 },
				[5] = { gold = 2500 },
			}
		},
	},
}

-- Get available buildings for an industry
function BuildingManager.getBuildings(industryType: string): {Building}
	return BuildingManager.buildings[industryType] or {}
end

-- Get building by ID
function BuildingManager.getBuilding(buildingId: string): Building?
	for _, buildings in pairs(BuildingManager.buildings) do
		for _, building in ipairs(buildings) do
			if building.id == buildingId then
				return building
			end
		end
	end
	return nil
end

return BuildingManager

