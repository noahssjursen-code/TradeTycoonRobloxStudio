-- GameUI: Main game interface with grid

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BuildingManager = require(ReplicatedStorage.Shared.BuildingManager)
local ProductionManager = require(ReplicatedStorage.Shared.ProductionManager)

-- Define BuildingProduction functions inline to avoid require issues
local BuildingProduction = {}
BuildingProduction.activeProductionTasks = {} -- Track active production loops to prevent duplicates

function BuildingProduction.startProduction(cellId: number, buildingData: any)
	-- Check if already running
	if BuildingProduction.activeProductionTasks[cellId] then
		print("Production already running for cell", cellId)
		return
	end
	
	local building = BuildingManager.getBuilding(buildingData.buildingId)
	if not building or not building.produces then return end
	
	local cycleTime = building.cycleTime or 10 -- Default 10 seconds
	
	-- Start first production cycle immediately with visual feedback
	local function runProductionCycle()
		-- Show and animate progress bar
		BuildingProduction.showProductionProgress(cellId, cycleTime)
		
		-- Produce one unit at a time
		for resourceId, _ in pairs(building.produces) do
			ProductionManager.receiveProduction(resourceId, 1)
		end
	end
	
	-- Run first cycle immediately
	runProductionCycle()
	
	-- Then run continuously
	local task = task.spawn(function()
		while true do
			task.wait(cycleTime)
			runProductionCycle()
		end
	end)
	
	-- Track this task
	BuildingProduction.activeProductionTasks[cellId] = task
	print("Started production for building:", building.name, "on cell", cellId, "cycle:", (building.cycleTime or 10) .. "s")
end

function BuildingProduction.showProductionProgress(cellId: number, cycleTime: number)
	-- Find cell directly from PlayerGui (don't rely on GameUI.centerPanel reference)
	local gameGui = Players.LocalPlayer.PlayerGui:FindFirstChild("GameUI")
	if not gameGui then 
		print("No GameUI found")
		return 
	end
	
	local frame = gameGui:FindFirstChild("Frame")
	if not frame then 
		print("No Frame found")
		return 
	end
	
	local contentArea = frame:FindFirstChild("ContentArea")
	if not contentArea then 
		print("No ContentArea found")
		return 
	end
	
	local centerPanel = contentArea:FindFirstChild("CenterPanel")
	if not centerPanel then
		print("Could not find CenterPanel for cell", cellId)
		return
	end
	
	local cell = centerPanel:FindFirstChild("Cell_" .. cellId)
	if not cell then 
		print("Could not find cell", cellId)
		return
	end
	
	-- Remove old progress bar
	local oldBar = cell:FindFirstChild("ProductionProgress")
	if oldBar then
		oldBar:Destroy()
	end
	
	-- Create progress bar
	local progressBar = Instance.new("Frame")
	progressBar.Name = "ProductionProgress"
	progressBar.Size = UDim2.new(0, 0, 0, 4)
	progressBar.Position = UDim2.new(0, 0, 1, 0)
	progressBar.AnchorPoint = Vector2.new(0, 1)
	progressBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	progressBar.BorderSizePixel = 0
	progressBar.Parent = cell
	
	-- Animate progress bar
	task.spawn(function()
		local elapsed = 0
		while elapsed < cycleTime do
			task.wait(0.1)
			elapsed = elapsed + 0.1
			progressBar.Size = UDim2.new(elapsed / cycleTime, 0, 0, 4)
		end
		progressBar:Destroy()
	end)
end

function BuildingProduction.startLoadedBuildings(saveData: any)
	if not saveData or not saveData.GridCells then return end
	
	-- Clear any existing production tasks
	for cellId, task in pairs(BuildingProduction.activeProductionTasks) do
		task.cancel(task)
	end
	BuildingProduction.activeProductionTasks = {}
	
	-- Start production for all buildings
	for cellId, buildingData in pairs(saveData.GridCells) do
		if buildingData.buildingId then
			local numericCellId = tonumber(cellId) or cellId
			BuildingProduction.startProduction(numericCellId, buildingData)
		end
	end
end

local GameUI = {}

GameUI.currentSave = nil
GameUI.buildingsList = nil

function GameUI.create()
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	
	local gameGui = Instance.new("ScreenGui")
	gameGui.Name = "GameUI"
	gameGui.ResetOnSpawn = false
	gameGui.IgnoreGuiInset = true
	gameGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gameGui.Parent = playerGui
	gameGui.Enabled = false
	
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.Position = UDim2.new(0, 0, 0, 0)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BorderSizePixel = 0
	frame.Parent = gameGui
	
	-- Top bar (header)
	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(1, 0, 0, 80)
	topBar.Position = UDim2.new(0, 0, 0, 0)
	topBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	topBar.BorderSizePixel = 0
	topBar.Parent = frame
	
	-- Industry type (loaded from save)
	local industryTypeLabel = Instance.new("TextLabel")
	industryTypeLabel.Name = "IndustryType"
	industryTypeLabel.Size = UDim2.new(0, 300, 1, 0)
	industryTypeLabel.Position = UDim2.new(0, 20, 0, 0)
	industryTypeLabel.BackgroundTransparency = 1
	industryTypeLabel.Text = "Industry: -"
	industryTypeLabel.Font = Enum.Font.GothamBold
	industryTypeLabel.TextSize = 24
	industryTypeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	industryTypeLabel.TextXAlignment = Enum.TextXAlignment.Left
	industryTypeLabel.Parent = topBar
	
	-- Money display
	local moneyLabel = Instance.new("TextLabel")
	moneyLabel.Name = "MoneyLabel"
	moneyLabel.Size = UDim2.new(0, 300, 1, 0)
	moneyLabel.Position = UDim2.new(1, -320, 0, 0)
	moneyLabel.AnchorPoint = Vector2.new(1, 0)
	moneyLabel.BackgroundTransparency = 1
	moneyLabel.Text = "Money: 0"
	moneyLabel.Font = Enum.Font.GothamBold
	moneyLabel.TextSize = 20
	moneyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	moneyLabel.TextXAlignment = Enum.TextXAlignment.Right
	moneyLabel.Parent = topBar
	
	-- Main content area with 3 panels
	local contentArea = Instance.new("Frame")
	contentArea.Name = "ContentArea"
	contentArea.Size = UDim2.new(1, -40, 1, -90)
	contentArea.Position = UDim2.new(0, 20, 0, 90)
	contentArea.BackgroundTransparency = 1
	contentArea.Parent = frame
	
	-- Left panel - Empty (will show "Click a cell to build")
	local leftPanel = Instance.new("Frame")
	leftPanel.Size = UDim2.new(0.25, -10, 1, 0)
	leftPanel.Position = UDim2.new(0, 0, 0, 0)
	leftPanel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	leftPanel.BorderSizePixel = 2
	leftPanel.BorderColor3 = Color3.fromRGB(60, 60, 70)
	leftPanel.Parent = contentArea
	
	local infoLabel = Instance.new("TextLabel")
	infoLabel.Size = UDim2.new(1, -20, 1, 0)
	infoLabel.Position = UDim2.new(0, 10, 0, 10)
	infoLabel.BackgroundTransparency = 1
	infoLabel.Text = "Click a cell to place a building"
	infoLabel.Font = Enum.Font.Gotham
	infoLabel.TextSize = 16
	infoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	infoLabel.TextWrapped = true
	infoLabel.TextXAlignment = Enum.TextXAlignment.Center
	infoLabel.TextYAlignment = Enum.TextYAlignment.Center
	infoLabel.Parent = leftPanel
	
	-- Buildings scrollable list
	local buildingsList = Instance.new("ScrollingFrame")
	buildingsList.Name = "BuildingsList"
	buildingsList.Size = UDim2.new(1, -20, 1, -70)
	buildingsList.Position = UDim2.new(0, 10, 0, 60)
	buildingsList.BackgroundTransparency = 1
	buildingsList.BorderSizePixel = 0
	buildingsList.ScrollBarThickness = 8
	buildingsList.CanvasSize = UDim2.new(0, 0, 0, 0)
	buildingsList.Parent = leftPanel
	
	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 10)
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = buildingsList
	
	local function updateCanvasSize()
		buildingsList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
	end
	
	listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
	
	-- Store reference
	GameUI.buildingsList = buildingsList
	
	-- Buildings modal (hidden by default)
	local buildingsModal = Instance.new("Frame")
	buildingsModal.Name = "BuildingsModal"
	buildingsModal.Size = UDim2.new(0.9, 0, 0.7, 0)
	buildingsModal.Position = UDim2.new(0.5, 0, 0.5, 0)
	buildingsModal.AnchorPoint = Vector2.new(0.5, 0.5)
	buildingsModal.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	buildingsModal.BorderSizePixel = 2
	buildingsModal.BorderColor3 = Color3.fromRGB(80, 80, 90)
	buildingsModal.Visible = false
	buildingsModal.Parent = frame
	
	local modalTitle = Instance.new("TextLabel")
	modalTitle.Size = UDim2.new(1, -20, 0, 50)
	modalTitle.Position = UDim2.new(0, 10, 0, 10)
	modalTitle.BackgroundTransparency = 1
	modalTitle.Text = "Select Building"
	modalTitle.Font = Enum.Font.GothamBold
	modalTitle.TextSize = 28
	modalTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	modalTitle.TextXAlignment = Enum.TextXAlignment.Left
	modalTitle.Parent = buildingsModal
	
	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0, 50, 0, 50)
	closeButton.Position = UDim2.new(1, -60, 0, 0)
	closeButton.AnchorPoint = Vector2.new(1, 0)
	closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closeButton.Text = "X"
	closeButton.Font = Enum.Font.GothamBold
	closeButton.TextSize = 20
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.BorderSizePixel = 0
	closeButton.Parent = buildingsModal
	
	closeButton.MouseEnter:Connect(function()
		closeButton.BackgroundColor3 = Color3.fromRGB(220, 70, 70)
	end)
	
	closeButton.MouseLeave:Connect(function()
		closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	end)
	
	closeButton.MouseButton1Click:Connect(function()
		buildingsModal.Visible = false
		GameUI.selectedCell = nil
	end)
	
	-- Buildings modal content area
	local modalContent = Instance.new("Frame")
	modalContent.Size = UDim2.new(1, -20, 1, -70)
	modalContent.Position = UDim2.new(0, 10, 0, 60)
	modalContent.BackgroundTransparency = 1
	modalContent.Parent = buildingsModal
	
	-- Buildings scrollable list inside modal
	local buildingsList = Instance.new("ScrollingFrame")
	buildingsList.Name = "BuildingsList"
	buildingsList.Size = UDim2.new(1, 0, 1, 0)
	buildingsList.Position = UDim2.new(0, 0, 0, 0)
	buildingsList.BackgroundTransparency = 1
	buildingsList.BorderSizePixel = 0
	buildingsList.ScrollBarThickness = 8
	buildingsList.CanvasSize = UDim2.new(0, 0, 0, 0)
	buildingsList.Parent = modalContent
	
	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 15)
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = buildingsList
	
	local function updateCanvasSize()
		buildingsList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
	end
	
	listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
	
	-- Building info modal (for viewing placed buildings)
	local buildingInfoModal = Instance.new("Frame")
	buildingInfoModal.Name = "BuildingInfoModal"
	buildingInfoModal.Size = UDim2.new(0.5, 0, 0.4, 0)
	buildingInfoModal.Position = UDim2.new(0.5, 0, 0.5, 0)
	buildingInfoModal.AnchorPoint = Vector2.new(0.5, 0.5)
	buildingInfoModal.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	buildingInfoModal.BorderSizePixel = 2
	buildingInfoModal.BorderColor3 = Color3.fromRGB(80, 80, 90)
	buildingInfoModal.Visible = false
	buildingInfoModal.Parent = frame
	
	local infoTitle = Instance.new("TextLabel")
	infoTitle.Size = UDim2.new(1, -20, 0, 50)
	infoTitle.Position = UDim2.new(0, 10, 0, 10)
	infoTitle.BackgroundTransparency = 1
	infoTitle.Text = "Building Info"
	infoTitle.Font = Enum.Font.GothamBold
	infoTitle.TextSize = 28
	infoTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	infoTitle.TextXAlignment = Enum.TextXAlignment.Left
	infoTitle.Parent = buildingInfoModal
	
	local infoCloseButton = Instance.new("TextButton")
	infoCloseButton.Size = UDim2.new(0, 50, 0, 50)
	infoCloseButton.Position = UDim2.new(1, -60, 0, 0)
	infoCloseButton.AnchorPoint = Vector2.new(1, 0)
	infoCloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	infoCloseButton.Text = "X"
	infoCloseButton.Font = Enum.Font.GothamBold
	infoCloseButton.TextSize = 20
	infoCloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	infoCloseButton.BorderSizePixel = 0
	infoCloseButton.Parent = buildingInfoModal
	
	infoCloseButton.MouseEnter:Connect(function()
		infoCloseButton.BackgroundColor3 = Color3.fromRGB(220, 70, 70)
	end)
	
	infoCloseButton.MouseLeave:Connect(function()
		infoCloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	end)
	
	infoCloseButton.MouseButton1Click:Connect(function()
		buildingInfoModal.Visible = false
	end)
	
	-- Info content area
	local infoContent = Instance.new("ScrollingFrame")
	infoContent.Name = "InfoContent"
	infoContent.Size = UDim2.new(1, -20, 1, -70)
	infoContent.Position = UDim2.new(0, 10, 0, 60)
	infoContent.BackgroundTransparency = 1
	infoContent.BorderSizePixel = 0
	infoContent.ScrollBarThickness = 8
	infoContent.CanvasSize = UDim2.new(0, 0, 0, 0)
	infoContent.Parent = buildingInfoModal
	
	local infoLayout = Instance.new("UIListLayout")
	infoLayout.Padding = UDim.new(0, 10)
	infoLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	infoLayout.SortOrder = Enum.SortOrder.LayoutOrder
	infoLayout.Parent = infoContent
	
	local function updateInfoCanvasSize()
		infoContent.CanvasSize = UDim2.new(0, 0, 0, infoLayout.AbsoluteContentSize.Y + 20)
	end
	
	infoLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateInfoCanvasSize)
	
	-- Store references
	GameUI.buildingsList = buildingsList
	GameUI.buildingsModal = buildingsModal
	GameUI.buildingInfoModal = buildingInfoModal
	GameUI.buildingInfoContent = infoContent
	GameUI.selectedCell = nil
	
	-- Center panel - Game grid
	local centerPanel = Instance.new("Frame")
	centerPanel.Name = "CenterPanel"
	centerPanel.Size = UDim2.new(0.5, -10, 1, 0)
	centerPanel.Position = UDim2.new(0.25, 5, 0, 0)
	centerPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	centerPanel.BorderSizePixel = 2
	centerPanel.BorderColor3 = Color3.fromRGB(60, 60, 70)
	centerPanel.Parent = contentArea
	
	-- Store reference for building placement and production
	GameUI.centerPanel = centerPanel
	print("Stored GameUI.centerPanel reference")
	
	-- Grid layout
	local gridSize = 10
	local spacing = 2
	
	-- UIGridLayout to handle responsive cell sizing
	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new((1 / gridSize) - (spacing / 100), 0, (1 / gridSize) - (spacing / 100), 0)
	gridLayout.CellPadding = UDim2.new(0, spacing, 0, spacing)
	gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	gridLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	gridLayout.FillDirectionMaxCells = gridSize
	gridLayout.Parent = centerPanel
	
	-- Create grid cells with IDs
	local cellId = 0
	for row = 0, gridSize - 1 do
		for col = 0, gridSize - 1 do
		local cell = Instance.new("TextButton")
		cell.Name = "Cell_" .. cellId
		cell.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		cell.BorderSizePixel = 2
		cell.BorderColor3 = Color3.fromRGB(30, 30, 35)
		cell.Text = ""
		cell.Parent = centerPanel
			
			-- Assign unique ID
			cell:SetAttribute("CellID", cellId)
			cell:SetAttribute("Row", row)
			cell:SetAttribute("Col", col)
			
			-- Track cell
			cell.Name = "Cell_" .. cellId
			
			-- No hover effect - visual feedback only from building color
			
			-- Click handler (capture cellId in closure)
			local capturedCellId = cellId
			local capturedRow = row
			local capturedCol = col
			
			cell.MouseButton1Click:Connect(function()
				-- Check if cell is empty (check dynamically, not using closure)
				local hasBuilding = false
				if GameUI.currentSave and GameUI.currentSave.GridCells then
					-- Try both string and number keys
					local cellData = GameUI.currentSave.GridCells[capturedCellId] or GameUI.currentSave.GridCells[tostring(capturedCellId)]
					hasBuilding = cellData ~= nil and cellData.buildingId ~= nil
					if hasBuilding then
						print("Cell", capturedCellId, "HAS building:", cellData)
					else
						print("Cell", capturedCellId, "is EMPTY")
					end
				else
					print("No save or GridCells!")
				end
				
			-- Building detection is done above
				
				if not hasBuilding then
					-- Show building selection modal
					GameUI.selectedCell = {id = capturedCellId, row = capturedRow, col = capturedCol, instance = cell}
					GameUI.showBuildingsModal()
				else
					-- Show building info modal
					GameUI.showBuildingInfoModal(capturedCellId)
				end
			end)
			
			cellId = cellId + 1
		end
	end
	
	-- Right panel - Resources
	local rightPanel = Instance.new("Frame")
	rightPanel.Size = UDim2.new(0.25, -10, 1, 0)
	rightPanel.Position = UDim2.new(1, -0.25, 0, 0)
	rightPanel.AnchorPoint = Vector2.new(1, 0)
	rightPanel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	rightPanel.BorderSizePixel = 2
	rightPanel.BorderColor3 = Color3.fromRGB(60, 60, 70)
	rightPanel.Parent = contentArea
	
	local resourcesTitle = Instance.new("TextLabel")
	resourcesTitle.Size = UDim2.new(1, -20, 0, 50)
	resourcesTitle.Position = UDim2.new(0, 10, 0, 10)
	resourcesTitle.BackgroundTransparency = 1
	resourcesTitle.Text = "Resources"
	resourcesTitle.Font = Enum.Font.GothamBold
	resourcesTitle.TextSize = 24
	resourcesTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	resourcesTitle.TextXAlignment = Enum.TextXAlignment.Left
	resourcesTitle.Parent = rightPanel
	
	-- Resources list
	local resourcesList = Instance.new("ScrollingFrame")
	resourcesList.Name = "ResourcesList"
	resourcesList.Size = UDim2.new(1, -20, 1, -70)
	resourcesList.Position = UDim2.new(0, 10, 0, 60)
	resourcesList.BackgroundTransparency = 1
	resourcesList.BorderSizePixel = 0
	resourcesList.ScrollBarThickness = 8
	resourcesList.CanvasSize = UDim2.new(0, 0, 0, 0)
	resourcesList.Parent = rightPanel
	
	-- Store reference
	GameUI.resourcesList = resourcesList
	
	-- Layout for resources
	local resourcesLayout = Instance.new("UIListLayout")
	resourcesLayout.Padding = UDim.new(0, 5)
	resourcesLayout.SortOrder = Enum.SortOrder.LayoutOrder
	resourcesLayout.Parent = resourcesList
	
	local function updateResourcesCanvasSize()
		resourcesList.CanvasSize = UDim2.new(0, 0, 0, resourcesLayout.AbsoluteContentSize.Y + 10)
	end
	
	resourcesLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateResourcesCanvasSize)
	
	-- Store reference
	gameGui:SetAttribute("CenterPanel", true)
	
	return gameGui
end

-- Load buildings from save (restore grid state)
function GameUI.loadGridBuildings()
	if not GameUI.currentSave then 
		print("No current save in loadGridBuildings!")
		return 
	end
	if not GameUI.currentSave.GridCells then 
		print("No GridCells in current save!")
		return 
	end
	if not GameUI.centerPanel then 
		print("No center panel!")
		return 
	end
	
	-- Count buildings properly
	local buildingCount = 0
	for _ in pairs(GameUI.currentSave.GridCells) do
		buildingCount = buildingCount + 1
	end
	print("Loading grid buildings, GridCells count:", buildingCount)
	
	for cellId, buildingData in pairs(GameUI.currentSave.GridCells) do
		print("Found building data for cell", cellId, ":", buildingData)
		local cell = GameUI.centerPanel:FindFirstChild("Cell_" .. cellId)
		if cell and buildingData and buildingData.buildingId then
			local BuildingManager = require(ReplicatedStorage.Shared.BuildingManager)
			local building = BuildingManager.getBuilding(buildingData.buildingId)
			
			if building then
				print("✓ Loading building on cell", cellId)
				-- Apply building color
				cell.BackgroundColor3 = building.color
				cell.BorderColor3 = Color3.fromRGB(math.max(0, building.color.R * 255 - 30), math.max(0, building.color.G * 255 - 30), math.max(0, building.color.B * 255 - 30))
				
				-- Remove old icon if exists
				local oldIcon = cell:FindFirstChild("BuildingIcon")
				if oldIcon then
					oldIcon:Destroy()
				end
				
				-- Add icon
				local buildingIcon = Instance.new("TextLabel")
				buildingIcon.Name = "BuildingIcon"
				buildingIcon.Size = UDim2.new(1, 0, 1, 0)
				buildingIcon.Position = UDim2.new(0, 0, 0, 0)
				buildingIcon.BackgroundTransparency = 1
				buildingIcon.Text = building.icon
				buildingIcon.Font = Enum.Font.SourceSansBold
				buildingIcon.TextSize = 35
				buildingIcon.Parent = cell
				
				-- Don't disable cell - we want to allow viewing info!
			else
				print("✗ Building not found for ID:", buildingData.buildingId)
			end
		else
			if not cell then print("✗ Cell not found:", cellId) end
			if not buildingData then print("✗ Building data is nil") end
			if buildingData and not buildingData.buildingId then print("✗ No buildingId in data") end
		end
	end
end

-- Update UI with save data
function GameUI.loadSave(saveData: any)
	GameUI.currentSave = saveData
	
	-- Update industry type
	local gameGui = Players.LocalPlayer.PlayerGui:WaitForChild("GameUI")
	local frame = gameGui:FindFirstChild("Frame")
	local topBar = frame and frame:FindFirstChild("TopBar")
	
	if topBar and saveData then
		local industryLabel = topBar:FindFirstChild("IndustryType")
		local moneyLabel = topBar:FindFirstChild("MoneyLabel")
		
		if industryLabel then
			industryLabel.Text = "Industry: " .. saveData.Type
		end
		
		if moneyLabel then
			moneyLabel.Text = "Money: " .. saveData.Money
		end
	end
	
	-- GridCells data loaded successfully
	
	-- Load grid buildings from save
	GameUI.loadGridBuildings()
	
	-- Load and display resources
	GameUI.updateResourcesDisplay()
	
	-- Connect production manager to resource updates (immediate UI update)
	ProductionManager.setResourceUpdateCallback(function(resourceId, amount)
		GameUI.addResource(resourceId, amount)
	end)
	
	-- Connect production manager to save callback (periodic aggregate save)
	ProductionManager.setSaveCallback(function(aggregateResources)
		-- Add aggregated resources to save WITHOUT triggering individual saves
		for resourceId, amount in pairs(aggregateResources) do
			if not GameUI.currentSave.Resources then
				GameUI.currentSave.Resources = {}
			end
			GameUI.currentSave.Resources[resourceId] = (GameUI.currentSave.Resources[resourceId] or 0) + amount
		end
		-- Update display
		GameUI.updateResourcesDisplay()
		-- Save once at the end
		GameUI.saveToDatastore()
	end)
	
	-- Start production system
	if not ProductionManager.isRunning then
		ProductionManager.start()
	end
	
	-- Start production for loaded buildings (after a short delay to ensure UI is ready)
	task.wait(0.5)
	BuildingProduction.startLoadedBuildings(GameUI.currentSave)
end

-- Show buildings modal
function GameUI.showBuildingsModal()
	if not GameUI.buildingsModal then return end
	GameUI.buildingsModal.Visible = true
	
	-- Populate with buildings for current industry
	if GameUI.currentSave then
		GameUI.populateBuildings(GameUI.currentSave.Type)
	end
end

-- Populate buildings modal with available buildings
function GameUI.populateBuildings(industryType: string)
	if not GameUI.buildingsList then return end
	
	-- Clear existing
	for _, child in pairs(GameUI.buildingsList:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	
	-- Get available buildings
	local buildings = BuildingManager.getBuildings(industryType)
	
	-- Create building buttons
	for i, building in ipairs(buildings) do
		local buildingButton = Instance.new("TextButton")
		buildingButton.Size = UDim2.new(0.9, 0, 0, 80)
		buildingButton.LayoutOrder = i
		buildingButton.BackgroundColor3 = building.color
		buildingButton.BorderSizePixel = 2
		buildingButton.BorderColor3 = Color3.fromRGB(70, 70, 80)
		buildingButton.Text = ""
		buildingButton.Parent = GameUI.buildingsList
		
		-- Icon
		local icon = Instance.new("TextLabel")
		icon.Size = UDim2.new(0, 60, 1, 0)
		icon.Position = UDim2.new(0, 10, 0, 0)
		icon.BackgroundTransparency = 1
		icon.Text = building.icon
		icon.Font = Enum.Font.SourceSansBold
		icon.TextSize = 40
		icon.Parent = buildingButton
		
		-- Name
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, -90, 0, 40)
		nameLabel.Position = UDim2.new(0, 80, 0, 10)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = building.name
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 18
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = buildingButton
		
		-- Price
		local priceLabel = Instance.new("TextLabel")
		priceLabel.Size = UDim2.new(1, -90, 0, 30)
		priceLabel.Position = UDim2.new(0, 80, 0, 45)
		priceLabel.BackgroundTransparency = 1
		priceLabel.Text = building.price .. " gold"
		priceLabel.Font = Enum.Font.Gotham
		priceLabel.TextSize = 14
		priceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		priceLabel.TextXAlignment = Enum.TextXAlignment.Left
		priceLabel.Parent = buildingButton
		
		-- Check if player can afford
		local canAfford = GameUI.currentSave and GameUI.currentSave.Money >= building.price
		if not canAfford then
			buildingButton.BackgroundTransparency = 0.7
			buildingButton.Active = false
		end
		
		-- Hover effect
		buildingButton.MouseEnter:Connect(function()
			if canAfford then
				buildingButton.BorderColor3 = Color3.fromRGB(100, 100, 110)
			end
		end)
		
		buildingButton.MouseLeave:Connect(function()
			buildingButton.BorderColor3 = Color3.fromRGB(70, 70, 80)
		end)
		
		-- Click to place building
		buildingButton.MouseButton1Click:Connect(function()
			if canAfford and GameUI.selectedCell then
				-- Place building
				GameUI.placeBuilding(GameUI.selectedCell.id, building.id, building)
				
				-- Hide modal
				GameUI.buildingsModal.Visible = false
				GameUI.selectedCell = nil
			elseif not canAfford then
				print("Not enough money!")
			end
		end)
	end
end

-- Place a building on a cell
function GameUI.placeBuilding(cellId: number, buildingId: string, building: any)
	if not GameUI.currentSave then return end
	
	-- Deduct money
	GameUI.currentSave.Money = GameUI.currentSave.Money - building.price
	
	-- Update money display
	local gameGui = Players.LocalPlayer.PlayerGui:WaitForChild("GameUI")
	local frame = gameGui:FindFirstChild("Frame")
	local topBar = frame and frame:FindFirstChild("TopBar")
	local moneyLabel = topBar and topBar:FindFirstChild("MoneyLabel")
	
	if moneyLabel then
		moneyLabel.Text = "Money: " .. GameUI.currentSave.Money
	end
	
	-- Save building to grid cell with ALL building data
	if not GameUI.currentSave.GridCells then
		GameUI.currentSave.GridCells = {}
	end
	
	-- Store COMPLETE building data in the grid cell (use STRING key for compatibility)
	GameUI.currentSave.GridCells[tostring(cellId)] = {
		buildingId = buildingId,
		buildingType = building.type,
		buildingName = building.name,
		buildingIcon = building.icon,
		buildingColor = tostring(building.color), -- Convert Color3 to string for datastore
		production = building.production,
		upgradeLevel = 1, -- Start at level 1
		placedAt = os.time()
	}
	
	print("Saved building data to GridCells[" .. tostring(cellId) .. "]:", GameUI.currentSave.GridCells[tostring(cellId)])
	
	-- Update cell visual to show building
	local cell = GameUI.centerPanel and GameUI.centerPanel:FindFirstChild("Cell_" .. cellId)
	
	if cell then
				-- Show building in cell
				cell.BackgroundColor3 = building.color
				cell.BorderColor3 = Color3.fromRGB(math.max(0, building.color.R * 255 - 30), math.max(0, building.color.G * 255 - 30), math.max(0, building.color.B * 255 - 30))
		
		-- Remove old icon if exists
		local oldIcon = cell:FindFirstChild("BuildingIcon")
		if oldIcon then
			oldIcon:Destroy()
		end
		
		-- Add building icon to cell
		local buildingIcon = Instance.new("TextLabel")
		buildingIcon.Name = "BuildingIcon"
		buildingIcon.Size = UDim2.new(1, 0, 1, 0)
		buildingIcon.Position = UDim2.new(0, 0, 0, 0)
		buildingIcon.BackgroundTransparency = 1
		buildingIcon.Text = building.icon
		buildingIcon.Font = Enum.Font.SourceSansBold
		buildingIcon.TextSize = 35
		buildingIcon.Parent = cell
		
		-- Cell stays active to allow clicking for building info
	end
	
	-- Start building production (sends messages to ProductionManager)
	BuildingProduction.startProduction(cellId, {buildingId = buildingId})
	
	-- Save immediately when placing building
	GameUI.saveToDatastore()
	
	print("Placed building:", building.name, "on cell:", cellId)
end

-- Show building info modal
function GameUI.showBuildingInfoModal(cellId: number)
	if not GameUI.buildingInfoModal or not GameUI.currentSave then 
		print("No modal or save data!")
		return 
	end
	-- Try both string and number keys
	local buildingData = GameUI.currentSave.GridCells and (GameUI.currentSave.GridCells[cellId] or GameUI.currentSave.GridCells[tostring(cellId)])
	if not buildingData then 
		print("No building data for cell", cellId)
		return 
	end
	
	print("Showing building info for cell", cellId)
	print("Building data:", buildingData)
	
	-- Check: Do we have a building here?
	if not buildingData.buildingId then
		print("No building ID in data!")
		return
	end
	
	GameUI.buildingInfoModal.Visible = true
	
	-- Clear old content
	for _, child in pairs(GameUI.buildingInfoContent:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end
	
	local layoutOrder = 1
	
	-- Building name and icon (from saved data)
	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(1, -20, 0, 60)
	header.Position = UDim2.new(0, 10, 0, 10)
	header.LayoutOrder = layoutOrder
	layoutOrder = layoutOrder + 1
	header.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	header.BorderSizePixel = 2
	header.BorderColor3 = Color3.fromRGB(80, 80, 90)
	header.Text = (buildingData.buildingIcon or "🏗️") .. "  " .. (buildingData.buildingName or "Unknown")
	header.Font = Enum.Font.GothamBold
	header.TextSize = 24
	header.TextColor3 = Color3.fromRGB(255, 255, 255)
	header.Parent = GameUI.buildingInfoContent
	
	-- Building type
	local typeLabel = Instance.new("TextLabel")
	typeLabel.Size = UDim2.new(1, -20, 0, 40)
	typeLabel.Position = UDim2.new(0, 10, 0, 10)
	typeLabel.LayoutOrder = layoutOrder
	layoutOrder = layoutOrder + 1
	typeLabel.BackgroundTransparency = 1
	typeLabel.Text = "Type: " .. (buildingData.buildingType or "Unknown")
	typeLabel.Font = Enum.Font.Gotham
	typeLabel.TextSize = 18
	typeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	typeLabel.TextXAlignment = Enum.TextXAlignment.Left
	typeLabel.Parent = GameUI.buildingInfoContent
	
	-- Production info
	if buildingData.production then
		local prodLabel = Instance.new("TextLabel")
		prodLabel.Size = UDim2.new(1, -20, 0, 40)
		prodLabel.Position = UDim2.new(0, 10, 0, 10)
		prodLabel.LayoutOrder = layoutOrder
		layoutOrder = layoutOrder + 1
		prodLabel.BackgroundTransparency = 1
		prodLabel.Text = "Produces: " .. buildingData.production
		prodLabel.Font = Enum.Font.Gotham
		prodLabel.TextSize = 18
		prodLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		prodLabel.TextXAlignment = Enum.TextXAlignment.Left
		prodLabel.Parent = GameUI.buildingInfoContent
	end
	
	-- Upgrade level
	local levelLabel = Instance.new("TextLabel")
	levelLabel.Size = UDim2.new(1, -20, 0, 40)
	levelLabel.Position = UDim2.new(0, 10, 0, 10)
	levelLabel.LayoutOrder = layoutOrder
	layoutOrder = layoutOrder + 1
	levelLabel.BackgroundTransparency = 1
	levelLabel.Text = "Level: " .. (buildingData.upgradeLevel or 1)
	levelLabel.Font = Enum.Font.Gotham
	levelLabel.TextSize = 18
	levelLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	levelLabel.TextXAlignment = Enum.TextXAlignment.Left
	levelLabel.Parent = GameUI.buildingInfoContent
	
	-- Cell location
	local cellLabel = Instance.new("TextLabel")
	cellLabel.Size = UDim2.new(1, -20, 0, 30)
	cellLabel.Position = UDim2.new(0, 10, 0, 10)
	cellLabel.LayoutOrder = layoutOrder
	layoutOrder = layoutOrder + 1
	cellLabel.BackgroundTransparency = 1
	cellLabel.Text = "Cell: " .. cellId
	cellLabel.Font = Enum.Font.Gotham
	cellLabel.TextSize = 14
	cellLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
	cellLabel.TextXAlignment = Enum.TextXAlignment.Left
	cellLabel.Parent = GameUI.buildingInfoContent
	
	-- Placed at timestamp
	if buildingData.placedAt then
		local timeLabel = Instance.new("TextLabel")
		timeLabel.Size = UDim2.new(1, -20, 0, 30)
		timeLabel.Position = UDim2.new(0, 10, 0, 10)
		timeLabel.LayoutOrder = layoutOrder
		layoutOrder = layoutOrder + 1
		timeLabel.BackgroundTransparency = 1
		timeLabel.Text = "Placed: " .. os.date("%H:%M:%S", buildingData.placedAt)
		timeLabel.Font = Enum.Font.Gotham
		timeLabel.TextSize = 14
		timeLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
		timeLabel.TextXAlignment = Enum.TextXAlignment.Left
		timeLabel.Parent = GameUI.buildingInfoContent
	end
end

-- Update resources display in right panel
function GameUI.updateResourcesDisplay()
	if not GameUI.resourcesList or not GameUI.currentSave then return end
	
	-- Clear existing resource labels
	for _, child in pairs(GameUI.resourcesList:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end
	
	-- Display resources
	local layoutOrder = 1
	for resourceId, amount in pairs(GameUI.currentSave.Resources or {}) do
		if amount > 0 then -- Only show resources with amount > 0
			local resourceLabel = Instance.new("TextLabel")
			resourceLabel.Size = UDim2.new(1, -10, 0, 40)
			resourceLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
			resourceLabel.BorderSizePixel = 1
			resourceLabel.BorderColor3 = Color3.fromRGB(60, 60, 70)
			resourceLabel.Text = resourceId .. ": " .. amount
			resourceLabel.Font = Enum.Font.Gotham
			resourceLabel.TextSize = 16
			resourceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			resourceLabel.LayoutOrder = layoutOrder
			layoutOrder = layoutOrder + 1
			resourceLabel.Parent = GameUI.resourcesList
		end
	end
	
	-- Show empty message if no resources
	if layoutOrder == 1 then
		local emptyLabel = Instance.new("TextLabel")
		emptyLabel.Size = UDim2.new(1, -10, 0, 40)
		emptyLabel.BackgroundTransparency = 1
		emptyLabel.Text = "No resources yet"
		emptyLabel.Font = Enum.Font.Gotham
		emptyLabel.TextSize = 14
		emptyLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
		emptyLabel.LayoutOrder = 1
		emptyLabel.Parent = GameUI.resourcesList
	end
end

-- Add resource (client-side only)
function GameUI.addResource(resourceId: string, amount: number)
	if not GameUI.currentSave then return end
	
	if not GameUI.currentSave.Resources then
		GameUI.currentSave.Resources = {}
	end
	
	GameUI.currentSave.Resources[resourceId] = (GameUI.currentSave.Resources[resourceId] or 0) + amount
	
	-- Update display
	GameUI.updateResourcesDisplay()
end

-- Get resource amount
function GameUI.getResource(resourceId: string): number
	if not GameUI.currentSave or not GameUI.currentSave.Resources then
		return 0
	end
	return GameUI.currentSave.Resources[resourceId] or 0
end

-- Auto-save to datastore periodically
function GameUI.startAutoSave()
	-- Cancel existing auto-save if running
	if GameUI.autoSaveTask then
		task.cancel(GameUI.autoSaveTask)
	end
	
	GameUI.autoSaveTask = task.spawn(function()
		while true do
			task.wait(GameUI.autoSaveInterval)
			
			if GameUI.currentSave then
				-- Save to datastore
				local RemoteEvents = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents")
				local UpdateSaveEvent = RemoteEvents:FindFirstChild("UpdateSave")
				if UpdateSaveEvent then
					UpdateSaveEvent:FireServer(GameUI.currentSave)
					print("Auto-saved game data")
				end
			end
		end
	end)
end

-- Manual save (call when important changes occur)
function GameUI.saveToDatastore()
	if not GameUI.currentSave then return end
	
	local RemoteEvents = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents")
	local UpdateSaveEvent = RemoteEvents:FindFirstChild("UpdateSave")
	if UpdateSaveEvent then
		UpdateSaveEvent:FireServer(GameUI.currentSave)
		print("Manually saved game data")
	end
end

return GameUI

