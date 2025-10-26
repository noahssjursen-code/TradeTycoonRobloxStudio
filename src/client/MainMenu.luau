-- MainMenu: Main menu screen

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modal = require(ReplicatedStorage.Shared.Modal)

local MainMenu = {}

function MainMenu.create(onStartCallback: () -> ())
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	
	-- Create main menu ScreenGui
	local mainMenuGui = Instance.new("ScreenGui")
	mainMenuGui.Name = "MainMenu"
	mainMenuGui.ResetOnSpawn = false
	mainMenuGui.IgnoreGuiInset = true
	mainMenuGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	mainMenuGui.Parent = playerGui
	
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.Position = UDim2.new(0, 0, 0, 0)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BorderSizePixel = 0
	frame.Parent = mainMenuGui
	
	-- Grid background pattern (responsive)
	local function createGrid(cellSize)
		local cols = math.ceil(1400 / cellSize)
		local rows = math.ceil(800 / cellSize)
		for row = 0, rows do
			for col = 0, cols do
				local cell = Instance.new("Frame")
				cell.Size = UDim2.new(0, cellSize - 1, 0, cellSize - 1)
				cell.Position = UDim2.new(0, col * cellSize, 0, row * cellSize)
				cell.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
				cell.BorderSizePixel = 1
				cell.BorderColor3 = Color3.fromRGB(50, 50, 60)
				cell.BackgroundTransparency = 0
				cell.Parent = frame
			end
		end
	end
	createGrid(50)
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 120)
	title.Position = UDim2.new(0, 0, 0, 50)
	title.BackgroundTransparency = 1
	title.Text = "Trade Tycoon"
	title.Font = Enum.Font.GothamBold
	title.TextSize = 48
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Parent = frame
	
	-- Buttons container
	local buttonsContainer = Instance.new("Frame")
	buttonsContainer.Size = UDim2.new(0, 300, 0, 150)
	buttonsContainer.Position = UDim2.new(0.5, 0, 0, 220)
	buttonsContainer.AnchorPoint = Vector2.new(0.5, 0)
	buttonsContainer.BackgroundTransparency = 1
	buttonsContainer.Parent = frame
	
	-- Start button
	local startButton = Instance.new("TextButton")
	startButton.Size = UDim2.new(1, 0, 0, 70)
	startButton.Position = UDim2.new(0, 0, 0, 0)
	startButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
	startButton.Text = "START GAME"
	startButton.Font = Enum.Font.GothamBold
	startButton.TextSize = 24
	startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	startButton.BorderSizePixel = 0
	startButton.Parent = buttonsContainer
	
	-- Button hover effect
	startButton.MouseEnter:Connect(function()
		startButton.BackgroundColor3 = Color3.fromRGB(90, 150, 200)
	end)
	
	startButton.MouseLeave:Connect(function()
		startButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
	end)
	
	startButton.MouseButton1Click:Connect(function()
		if onStartCallback then
			onStartCallback()
		end
	end)
	
	-- Save games button
	local saveButton = Instance.new("TextButton")
	saveButton.Size = UDim2.new(1, 0, 0, 60)
	saveButton.Position = UDim2.new(0, 0, 0, 80)
	saveButton.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
	saveButton.Text = "SAVE GAMES"
	saveButton.Font = Enum.Font.GothamBold
	saveButton.TextSize = 20
	saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	saveButton.BorderSizePixel = 0
	saveButton.Parent = buttonsContainer
	
	-- Button hover effect
	saveButton.MouseEnter:Connect(function()
		saveButton.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
	end)
	
	saveButton.MouseLeave:Connect(function()
		saveButton.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
	end)
	
	saveButton.MouseButton1Click:Connect(function()
		Modal.show(playerGui, function()
			local content = Instance.new("Frame")
			content.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
			content.BorderSizePixel = 0
			return content
		end)
	end)
	
	return mainMenuGui
end

return MainMenu

