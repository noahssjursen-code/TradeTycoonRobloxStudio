-- Client: Main entry point for Trade Tycoon

-- Initialize RemoteEvents first
game.ReplicatedStorage:WaitForChild("Shared")
require(game.ReplicatedStorage.Shared.RemoteEvents)

local MainMenu = require(script.MainMenu)
local SelectSave = require(script.SelectSave)
local IndustrySelection = require(script.IndustrySelection)
local GameUI = require(script.GameUI)

-- Screen manager - handles navigation between screens
local ScreenManager = {}

function ScreenManager.showMainMenu()
	ScreenManager.mainMenuGui.Enabled = false
	ScreenManager.selectSaveGui.Enabled = false
	ScreenManager.industryGui.Enabled = false
	ScreenManager.gameGui.Enabled = false
	ScreenManager.mainMenuGui.Enabled = true
end

function ScreenManager.showSelectSave()
	ScreenManager.mainMenuGui.Enabled = false
	ScreenManager.selectSaveGui.Enabled = false
	ScreenManager.industryGui.Enabled = false
	ScreenManager.gameGui.Enabled = false
	ScreenManager.selectSaveGui.Enabled = true
end

function ScreenManager.showIndustrySelection()
	ScreenManager.mainMenuGui.Enabled = false
	ScreenManager.selectSaveGui.Enabled = false
	ScreenManager.industryGui.Enabled = false
	ScreenManager.gameGui.Enabled = false
	ScreenManager.industryGui.Enabled = true
end

function ScreenManager.showGame()
	ScreenManager.mainMenuGui.Enabled = false
	ScreenManager.selectSaveGui.Enabled = false
	ScreenManager.industryGui.Enabled = false
	ScreenManager.gameGui.Enabled = false
	ScreenManager.gameGui.Enabled = true
end

-- Create all screens with callbacks
ScreenManager.mainMenuGui = MainMenu.create(function()
	ScreenManager.showSelectSave()
end)

ScreenManager.selectSaveGui = SelectSave.create(function(saveData)
	if saveData then
		-- Loading existing save - go straight to game
		print("Loading save:", saveData.Type)
		print("Save money:", saveData.Money)
		print("Save grid cells:", saveData.GridCells)
		
		-- Show game first, then load save data
		ScreenManager.showGame()
		
		-- Wait a frame for game to be visible, then load save
		task.wait()
		GameUI.loadSave(saveData)
	else
		-- Creating new save - go to industry selection
		ScreenManager.showIndustrySelection()
	end
end, function()
	ScreenManager.showMainMenu()
end)

ScreenManager.industryGui = IndustrySelection.create(function(industryName: string)
	print("Selected industry:", industryName)
	
	-- Create save
	local RemoteEvents = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents")
	local CreateSaveEvent = RemoteEvents:WaitForChild("CreateSave")
	CreateSaveEvent:FireServer(industryName)
	
	-- Wait for server to create save, then load actual data
	-- Load save data into game (properly initialized structure)
	local saveData = {
		Type = industryName,
		Money = 500,
		Resources = {},
		GridCells = {},  -- Initialize GridCells!
		PlayerId = 0,
		CreatedAt = os.time(),
		LastPlayed = os.time()
	}
	GameUI.loadSave(saveData)
	
	ScreenManager.showGame()
end)

ScreenManager.gameGui = GameUI.create()

-- Start with main menu
ScreenManager.showMainMenu()

print("Trade Tycoon initialized")
