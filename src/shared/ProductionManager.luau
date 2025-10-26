-- ProductionManager: Centralized resource aggregation service
-- Buildings send production messages: {resource: "iron_ore", amount: 1}
-- Service aggregates all production and periodically saves to datastore

local ProductionManager = {}

ProductionManager.isRunning = false
ProductionManager.aggregateResources = {} -- {[resourceId] = totalAmount}
ProductionManager.autoSaveTask = nil
ProductionManager.autoSaveInterval = 30 -- Save every 30 seconds

-- Callback for when resources need to be saved
ProductionManager.onResourcesReadyToSave = nil

-- Start the service
function ProductionManager.start()
	if ProductionManager.isRunning then
		warn("ProductionManager is already running!")
		return
	end
	
	ProductionManager.isRunning = true
	
	-- Start auto-save task
	ProductionManager.autoSaveTask = task.spawn(function()
		while ProductionManager.isRunning do
			task.wait(ProductionManager.autoSaveInterval)
			ProductionManager.saveResources()
		end
	end)
	
	print("ProductionManager started - aggregating and saving every", ProductionManager.autoSaveInterval, "seconds")
end

-- Stop the service
function ProductionManager.stop()
	ProductionManager.isRunning = false
	if ProductionManager.autoSaveTask then
		task.cancel(ProductionManager.autoSaveTask)
	end
	
	-- Save before stopping
	ProductionManager.saveResources()
	
	print("ProductionManager stopped")
end

-- Receive production from a building (called by buildings)
function ProductionManager.receiveProduction(resourceId: string, amount: number)
	if not ProductionManager.isRunning then return end
	
	-- Add to aggregate
	ProductionManager.aggregateResources[resourceId] = (ProductionManager.aggregateResources[resourceId] or 0) + amount
	
	print("Received production:", resourceId, "+", amount, "Total:", ProductionManager.aggregateResources[resourceId])
	
	-- Call UI callback immediately for display
	if ProductionManager.onResourceUpdate then
		ProductionManager.onResourceUpdate(resourceId, amount)
	end
end

-- Save aggregated resources periodically
function ProductionManager.saveResources()
	local resourcesToSave = {}
	for k, v in pairs(ProductionManager.aggregateResources) do
		resourcesToSave[k] = v
	end
	
	-- Clear aggregate
	ProductionManager.aggregateResources = {}
	
	-- Call save callback
	if ProductionManager.onResourcesReadyToSave and resourcesToSave then
		ProductionManager.onResourcesReadyToSave(resourcesToSave)
	end
end

-- Get current aggregated resources
function ProductionManager.getResources()
	return ProductionManager.aggregateResources
end

-- Set callbacks
function ProductionManager.setResourceUpdateCallback(callback: (string, number) -> ())
	ProductionManager.onResourceUpdate = callback
end

function ProductionManager.setSaveCallback(callback: (any) -> ())
	ProductionManager.onResourcesReadyToSave = callback
end

return ProductionManager
