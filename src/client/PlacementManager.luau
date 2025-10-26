-- PlacementManager: Handles building placement on the grid

local PlacementManager = {}

PlacementManager.selectedBuilding = nil
PlacementManager.gridCells = {}

-- Set selected building for placement
function PlacementManager.selectBuilding(buildingId: string, buildingData: any)
	PlacementManager.selectedBuilding = {
		id = buildingId,
		data = buildingData
	}
	
	-- TODO: Highlight valid placement cells
end

-- Place building on grid
function PlacementManager.placeBuilding(cellId: number, buildingId: string)
	if not PlacementManager.selectedBuilding then
		return false
	end
	
	-- Check if player has enough money
	-- TODO: Check from save data
	
	-- Place on server
	local RemoteEvents = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents")
	local PlaceBuildingEvent = RemoteEvents:FindFirstChild("PlaceBuilding")
	
	if PlaceBuildingEvent then
		PlaceBuildingEvent:FireServer(cellId, buildingId)
	end
	
	return true
end

-- Clear selection
function PlacementManager.clearSelection()
	PlacementManager.selectedBuilding = nil
	-- TODO: Un-highlight cells
end

return PlacementManager

