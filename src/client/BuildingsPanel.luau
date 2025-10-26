-- BuildingsPanel: Manages the left panel showing available buildings

local BuildingsPanel = {}

function BuildingsPanel.create(parent: Frame)
	-- The panel already exists in GameUI.luau, just populate it with buildings
	
	return {
		updateBuildings = function(buildings: any)
			-- Will populate buildings here
		end
	}
end

return BuildingsPanel

