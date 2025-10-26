-- ProductionManager: Handles resource production from buildings

local ProductionManager = {}

ProductionManager.productionCycle = 10 -- seconds per cycle
ProductionManager.activeBuildings = {} -- {[cellId] = {buildingType, productionData}}

-- Start production for a building
function ProductionManager.startProduction(cellId: number, buildingId: string)
	-- Get building definition
	local BuildingManager = require(game.ReplicatedStorage.Shared.BuildingManager)
	local building = BuildingManager.getBuilding(buildingId)
	
	if not building then return end
	
	-- Add to active buildings
	ProductionManager.activeBuildings[cellId] = {
		buildingId = buildingId,
		lastProduction = os.time(),
		cycleStart = os.time(),
	}
end

-- Stop production for a building
function ProductionManager.stopProduction(cellId: number)
	ProductionManager.activeBuildings[cellId] = nil
end

-- Process production cycle (called periodically)
function ProductionManager.processCycle()
	local currentTime = os.time()
	
	for cellId, productionData in pairs(ProductionManager.activeBuildings) do
		local timeSinceLastProduction = currentTime - productionData.lastProduction
		
		if timeSinceLastProduction >= ProductionManager.productionCycle then
			-- Produce resources
			ProductionManager.produceResources(cellId, productionData.buildingId)
			
			-- Update last production time
			productionData.lastProduction = currentTime
		end
	end
end

-- Produce resources from a building
function ProductionManager.produceResources(cellId: number, buildingId: string)
	local BuildingManager = require(game.ReplicatedStorage.Shared.BuildingManager)
	local building = BuildingManager.getBuilding(buildingId)
	
	if not building or not building.produces then return end
	
	-- Fire event to update client resources
	local RemoteEvents = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents")
	local UpdateResourcesEvent = RemoteEvents:FindFirstChild("UpdateResources")
	
	if UpdateResourcesEvent then
		UpdateResourcesEvent:FireAllClients(cellId, building.produces)
	end
end

-- Run production cycles
task.spawn(function()
	while true do
		task.wait(1) -- Check every second
		ProductionManager.processCycle()
	end
end)

return ProductionManager

