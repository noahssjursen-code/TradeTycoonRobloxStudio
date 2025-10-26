-- RemoteEvents: Shared remote events for client-server communication

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create RemoteEvent folder
local remoteEventsFolder = Instance.new("Folder")
remoteEventsFolder.Name = "RemoteEvents"
remoteEventsFolder.Parent = ReplicatedStorage

-- CreateRemote function helper
local function createRemote(name: string)
	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = remoteEventsFolder
	return remote
end

-- Define all remote events
local RemoteEvents = {
	-- Save management
	LoadSaves = createRemote("LoadSaves"),
	CreateSave = createRemote("CreateSave"),
	DeleteSave = createRemote("DeleteSave"),
	UpdateSave = createRemote("UpdateSave"),
	
	-- Game data
	UpdateResources = createRemote("UpdateResources"),
	PlaceBuilding = createRemote("PlaceBuilding"),
}

-- Helper to get all remotes
function RemoteEvents.getRemotesFolder()
	return remoteEventsFolder
end

return RemoteEvents

