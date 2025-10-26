-- SelectSave: Save selection screen

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SelectSave = {}

SelectSave.backCallback = nil
SelectSave.onSaveSelected = nil

function SelectSave.create(onSaveSelected: () -> (), onBack: () -> ())
	SelectSave.backCallback = onBack
	SelectSave.onSaveSelected = onSaveSelected
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	
	-- Create select save ScreenGui
	local selectSaveGui = Instance.new("ScreenGui")
	selectSaveGui.Name = "SelectSave"
	selectSaveGui.ResetOnSpawn = false
	selectSaveGui.IgnoreGuiInset = true
	selectSaveGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	selectSaveGui.Parent = playerGui
	selectSaveGui.Enabled = false
	
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.Position = UDim2.new(0, 0, 0, 0)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BorderSizePixel = 0
	frame.Parent = selectSaveGui
	
	-- Grid background (responsive)
	local function createGrid(cellSize)
		for row = 0, math.ceil(800 / cellSize) do
			for col = 0, math.ceil(1400 / cellSize) do
				local cell = Instance.new("Frame")
				cell.Size = UDim2.new(0, cellSize - 1, 0, cellSize - 1)
				cell.Position = UDim2.new(0, col * cellSize, 0, row * cellSize)
				cell.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
				cell.BorderSizePixel = 1
				cell.BorderColor3 = Color3.fromRGB(40, 40, 45)
				cell.BackgroundTransparency = 0
				cell.Parent = frame
			end
		end
	end
	createGrid(60)
	
	-- Top bar
	local topBar = Instance.new("Frame")
	topBar.Size = UDim2.new(1, 0, 0, 100)
	topBar.Position = UDim2.new(0, 0, 0, 0)
	topBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	topBar.BorderSizePixel = 0
	topBar.Parent = frame
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 60)
	title.Position = UDim2.new(0, 0, 0, 20)
	title.BackgroundTransparency = 1
	title.Text = "SELECT SAVE"
	title.Font = Enum.Font.GothamBold
	title.TextSize = 32
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Parent = topBar
	
	-- Back button
	local backButton = Instance.new("TextButton")
	backButton.Size = UDim2.new(0, 120, 0, 40)
	backButton.Position = UDim2.new(1, -130, 0, 5)
	backButton.AnchorPoint = Vector2.new(1, 0)
	backButton.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
	backButton.Text = "BACK"
	backButton.Font = Enum.Font.GothamBold
	backButton.TextSize = 16
	backButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	backButton.BorderSizePixel = 0
	backButton.Parent = topBar
	
	backButton.MouseEnter:Connect(function()
		backButton.BackgroundColor3 = Color3.fromRGB(90, 90, 100)
	end)
	
	backButton.MouseLeave:Connect(function()
		backButton.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
	end)
	
	backButton.MouseButton1Click:Connect(function()
		if SelectSave.backCallback then
			SelectSave.backCallback()
		end
	end)
	
	-- Content area
	local contentArea = Instance.new("Frame")
	contentArea.Size = UDim2.new(1, -40, 1, -110)
	contentArea.Position = UDim2.new(0.5, 0, 0, 110)
	contentArea.AnchorPoint = Vector2.new(0.5, 0)
	contentArea.BackgroundTransparency = 1
	contentArea.Parent = frame
	
	-- Create saves list area (will be populated when loading saves)
	
	-- Create the event connection once (not inside loadSaves)
	local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
	local loadSavesEvent = RemoteEvents:WaitForChild("LoadSaves")
	
	-- Load saves on screen show
	local function loadSaves()
		print("Requesting saves from server...")
		loadSavesEvent:FireServer()
	end
	
	loadSavesEvent.OnClientEvent:Connect(function(saves: any)
		print("Received saves from server:", saves and #saves or 0, "saves")
		if saves then
			print("First save:", saves[1])
		end
		
		-- Clear existing content
		for _, child in pairs(contentArea:GetChildren()) do
			if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextButton") then
				child:Destroy()
			end
		end
		
	if not saves or #saves == 0 then
		-- No saves message
		local placeholder = Instance.new("TextLabel")
		placeholder.Size = UDim2.new(1, 0, 0, 40)
		placeholder.Position = UDim2.new(0, 0, 0.3, 0)
		placeholder.AnchorPoint = Vector2.new(0, 0.5)
		placeholder.BackgroundTransparency = 1
		placeholder.Text = "No saves found. Create new save?"
		placeholder.Font = Enum.Font.Gotham
		placeholder.TextSize = 24
		placeholder.TextColor3 = Color3.fromRGB(200, 200, 200)
		placeholder.Parent = contentArea
		
		-- Create new save button
		local newSaveButton = Instance.new("TextButton")
		newSaveButton.Size = UDim2.new(0, 250, 0, 70)
		newSaveButton.Position = UDim2.new(0.5, 0, 0, 50)
		newSaveButton.AnchorPoint = Vector2.new(0.5, 0)
		newSaveButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
		newSaveButton.Text = "CREATE NEW SAVE"
		newSaveButton.Font = Enum.Font.GothamBold
		newSaveButton.TextSize = 20
		newSaveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		newSaveButton.BorderSizePixel = 0
		newSaveButton.Parent = contentArea
		
		newSaveButton.MouseEnter:Connect(function()
			newSaveButton.BackgroundColor3 = Color3.fromRGB(90, 150, 200)
		end)
		
		newSaveButton.MouseLeave:Connect(function()
			newSaveButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
		end)
		
		newSaveButton.MouseButton1Click:Connect(function()
			if SelectSave.onSaveSelected then
				SelectSave.onSaveSelected()
			end
		end)
	else
		-- Display saves (max 3)
		for i, save in ipairs(saves) do
			if i > 3 then break end
			
			local saveCard = Instance.new("TextButton")
			saveCard.Size = UDim2.new(1, 0, 0, 100)
			saveCard.Position = UDim2.new(0, 0, 0, (i-1) * 120)
			saveCard.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
			saveCard.BorderSizePixel = 2
			saveCard.BorderColor3 = Color3.fromRGB(70, 70, 80)
			saveCard.Text = ""
			saveCard.Parent = contentArea
			
			saveCard.MouseEnter:Connect(function()
				saveCard.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
			end)
			
			saveCard.MouseLeave:Connect(function()
				saveCard.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
			end)
			
			saveCard.MouseButton1Click:Connect(function()
				if SelectSave.onSaveSelected then
					SelectSave.onSaveSelected(save)
				end
			end)
			
			-- Save info
			local saveName = Instance.new("TextLabel")
			saveName.Size = UDim2.new(1, -100, 0, 40)
			saveName.Position = UDim2.new(0, 20, 0, 10)
			saveName.BackgroundTransparency = 1
			saveName.Text = "Save " .. i .. " - " .. save.Type
			saveName.Font = Enum.Font.GothamBold
			saveName.TextSize = 22
			saveName.TextColor3 = Color3.fromRGB(255, 255, 255)
			saveName.TextXAlignment = Enum.TextXAlignment.Left
			saveName.Parent = saveCard
			
			local moneyLabel = Instance.new("TextLabel")
			moneyLabel.Size = UDim2.new(1, -100, 0, 30)
			moneyLabel.Position = UDim2.new(0, 20, 0, 50)
			moneyLabel.BackgroundTransparency = 1
			moneyLabel.Text = "Money: " .. save.Money
			moneyLabel.Font = Enum.Font.Gotham
			moneyLabel.TextSize = 16
			moneyLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
			moneyLabel.TextXAlignment = Enum.TextXAlignment.Left
			moneyLabel.Parent = saveCard
			
			-- Delete button
			local deleteButton = Instance.new("TextButton")
			deleteButton.Size = UDim2.new(0, 50, 0, 50)
			deleteButton.Position = UDim2.new(1, -60, 0, 20)
			deleteButton.AnchorPoint = Vector2.new(1, 0)
			deleteButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
			deleteButton.Text = "X"
			deleteButton.Font = Enum.Font.GothamBold
			deleteButton.TextSize = 20
			deleteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			deleteButton.BorderSizePixel = 0
			deleteButton.Parent = saveCard
			
			deleteButton.MouseEnter:Connect(function()
				deleteButton.BackgroundColor3 = Color3.fromRGB(220, 70, 70)
			end)
			
			deleteButton.MouseLeave:Connect(function()
				deleteButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
			end)
			
			deleteButton.MouseButton1Click:Connect(function()
				-- Delete save
				local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
				local DeleteSaveEvent = RemoteEvents:WaitForChild("DeleteSave")
				DeleteSaveEvent:FireServer()
				
				-- Reload saves
				loadSaves()
			end)
		end
	end
	end)
	
	-- Load saves when screen is enabled
	selectSaveGui:GetPropertyChangedSignal("Enabled"):Connect(function()
		if selectSaveGui.Enabled then
			loadSaves()
		end
	end)
	
	return selectSaveGui
end

return SelectSave

