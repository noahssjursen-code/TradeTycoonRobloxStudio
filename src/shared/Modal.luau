-- Modal: Reusable modal component for overlays
-- Usage:
-- local Modal = require(ReplicatedStorage.Shared.Modal)
-- 
-- Modal.show(game.Players.LocalPlayer.PlayerGui, function()
--     local content = Instance.new("Frame")
--     content.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
--     
--     local label = Instance.new("TextLabel")
--     label.Text = "Hello World"
--     label.Parent = content
--     
--     return content
-- end)

local Modal = {}

function Modal.create(parent: Instance, contentCallback: () -> Instance?)
	local modalGui = Instance.new("ScreenGui")
	modalGui.Name = "Modal"
	modalGui.ResetOnSpawn = false
	modalGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	modalGui.Parent = parent
	
	-- Modal container
	local modalContainer = Instance.new("Frame")
	modalContainer.Size = UDim2.new(0, 500, 0, 400)
	modalContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
	modalContainer.AnchorPoint = Vector2.new(0.5, 0.5)
	modalContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	modalContainer.BorderSizePixel = 2
	modalContainer.BorderColor3 = Color3.fromRGB(70, 70, 80)
	modalContainer.Parent = modalGui
	
	-- Close button
	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0, 40, 0, 40)
	closeButton.Position = UDim2.new(1, -5, 0, 5)
	closeButton.AnchorPoint = Vector2.new(1, 0)
	closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closeButton.BorderSizePixel = 0
	closeButton.Text = "X"
	closeButton.Font = Enum.Font.GothamBold
	closeButton.TextSize = 20
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.Parent = modalContainer
	
	closeButton.MouseButton1Click:Connect(function()
		modalGui:Destroy()
	end)
	
	-- Hover effect
	closeButton.MouseEnter:Connect(function()
		closeButton.BackgroundColor3 = Color3.fromRGB(220, 70, 70)
	end)
	
	closeButton.MouseLeave:Connect(function()
		closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	end)
	
	-- Content area (below close button)
	local contentArea = Instance.new("Frame")
	contentArea.Size = UDim2.new(1, 0, 1, -50)
	contentArea.Position = UDim2.new(0, 0, 0, 50)
	contentArea.BackgroundTransparency = 1
	contentArea.Parent = modalContainer
	
	-- Call the content callback to get the content
	if contentCallback then
		local content = contentCallback()
		if content then
			content.Position = UDim2.new(0, 0, 0, 0)
			content.Size = UDim2.new(1, 0, 1, 0)
			content.Parent = contentArea
		end
	end
	
	return modalGui
end

function Modal.show(parent: Instance, contentCallback: () -> Instance?)
	return Modal.create(parent, contentCallback)
end

function Modal.hide(modalGui: ScreenGui)
	if modalGui then
		modalGui:Destroy()
	end
end

return Modal

