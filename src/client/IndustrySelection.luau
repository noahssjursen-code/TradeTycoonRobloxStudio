-- IndustrySelection: Industry selection menu

local Players = game:GetService("Players")

local IndustrySelection = {}

function IndustrySelection.create(onIndustrySelected: (string) -> ())
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	
	-- Create industry selection ScreenGui
	local industryGui = Instance.new("ScreenGui")
	industryGui.Name = "IndustrySelection"
	industryGui.ResetOnSpawn = false
	industryGui.IgnoreGuiInset = true
	industryGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	industryGui.Parent = playerGui
	industryGui.Enabled = false
	
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.Position = UDim2.new(0, 0, 0, 0)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BorderSizePixel = 0
	frame.Parent = industryGui
	
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
	title.Text = "CHOOSE YOUR INDUSTRY"
	title.Font = Enum.Font.GothamBold
	title.TextSize = 32
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Parent = topBar
	
	-- Subtitle
	local subtitle = Instance.new("TextLabel")
	subtitle.Size = UDim2.new(1, 0, 0, 30)
	subtitle.Position = UDim2.new(0, 0, 0, 55)
	subtitle.BackgroundTransparency = 1
	subtitle.Text = "Select your starting industry to begin"
	subtitle.Font = Enum.Font.Gotham
	subtitle.TextSize = 16
	subtitle.TextColor3 = Color3.fromRGB(180, 180, 180)
	subtitle.Parent = topBar
	
	-- Scroll frame for industries
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Size = UDim2.new(1, -40, 1, -110)
	scrollFrame.Position = UDim2.new(0.5, 0, 0, 110)
	scrollFrame.AnchorPoint = Vector2.new(0.5, 0)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 10
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollFrame.Parent = frame
	
	-- List layout (2 columns)
	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0, 380, 0, 110)
	gridLayout.CellPadding = UDim2.new(0, 20, 0, 20)
	gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	gridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	gridLayout.FillDirectionMaxCells = 2
	gridLayout.Parent = scrollFrame
	
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 20)
	padding.PaddingBottom = UDim.new(0, 20)
	padding.PaddingLeft = UDim.new(0, 20)
	padding.PaddingRight = UDim.new(0, 20)
	padding.Parent = scrollFrame
	
	-- Industries with icons
	local industries = {
		{name = "Coal Mining", color = Color3.fromRGB(40, 40, 40), icon = "⛏️"},
		{name = "Iron Mining", color = Color3.fromRGB(180, 100, 80), icon = "🔨"},
		{name = "Copper Mining", color = Color3.fromRGB(184, 115, 51), icon = "🔩"},
		{name = "Stone Quarrying", color = Color3.fromRGB(120, 120, 120), icon = "📦"},
		{name = "Logging", color = Color3.fromRGB(60, 120, 60), icon = "🪓"},
		{name = "Gold Mining", color = Color3.fromRGB(255, 215, 0), icon = "💰"},
	}
	
	for i, industry in ipairs(industries) do
		-- Industry card container
		local card = Instance.new("TextButton")
		card.Size = UDim2.new(0, 380, 0, 110)
		card.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
		card.BorderSizePixel = 2
		card.BorderColor3 = Color3.fromRGB(70, 70, 80)
		card.Text = ""
		card.Parent = scrollFrame
		
		-- Hover effect
		card.MouseEnter:Connect(function()
			card.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
			card.BorderColor3 = industry.color
		end)
		
		card.MouseLeave:Connect(function()
			card.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
			card.BorderColor3 = Color3.fromRGB(70, 70, 80)
		end)
		
		card.MouseButton1Click:Connect(function()
			if onIndustrySelected then
				onIndustrySelected(industry.name)
			end
		end)
		
		-- Icon
		local icon = Instance.new("TextLabel")
		icon.Size = UDim2.new(0, 70, 1, 0)
		icon.Position = UDim2.new(0, 20, 0, 0)
		icon.BackgroundTransparency = 1
		icon.Text = industry.icon
		icon.Font = Enum.Font.SourceSansBold
		icon.TextSize = 48
		icon.TextColor3 = industry.color
		icon.Parent = card
		
		-- Industry name
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, -120, 1, 0)
		nameLabel.Position = UDim2.new(0, 100, 0, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = industry.name
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 22
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = card
	end
	
	-- Update canvas size
	local function updateCanvasSize()
		scrollFrame.CanvasSize = UDim2.new(0, 0, 0, gridLayout.AbsoluteContentSize.Y + 40)
	end
	
	gridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
	updateCanvasSize()
	
	return industryGui
end

return IndustrySelection


