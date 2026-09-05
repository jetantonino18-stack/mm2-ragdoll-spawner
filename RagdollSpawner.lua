local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Variables
local ragdollFolder = Instance.new("Folder")
ragdollFolder.Name = "RagdollSpawner_Ragdolls"
ragdollFolder.Parent = workspace

local currentRagdoll = nil

-- ===== CREATE MOVABLE UI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RagdollSpawnerUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 250, 0, 150)
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -75)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Title Bar (for dragging)
local titleBar = Instance.new("TextLabel")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
titleBar.TextSize = 14
titleBar.Font = Enum.Font.GothamBold
titleBar.Text = "Ragdoll Spawner"
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

-- Spawn Button
local spawnButton = Instance.new("TextButton")
spawnButton.Name = "SpawnButton"
spawnButton.Size = UDim2.new(1, -10, 0, 40)
spawnButton.Position = UDim2.new(0, 5, 0, 35)
spawnButton.BackgroundColor3 = Color3.fromRGB(0, 150, 136)
spawnButton.TextColor3 = Color3.fromRGB(255, 255, 255)
spawnButton.TextSize = 12
spawnButton.Font = Enum.Font.Gotham
spawnButton.Text = "Spawn Ragdoll"
spawnButton.BorderSizePixel = 0
spawnButton.Parent = mainFrame

-- Delete Button
local deleteButton = Instance.new("TextButton")
deleteButton.Name = "DeleteButton"
deleteButton.Size = UDim2.new(1, -10, 0, 40)
deleteButton.Position = UDim2.new(0, 5, 0, 80)
deleteButton.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
deleteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
deleteButton.TextSize = 12
deleteButton.Font = Enum.Font.Gotham
deleteButton.Text = "Delete Ragdoll"
deleteButton.BorderSizePixel = 0
deleteButton.Parent = mainFrame

-- ===== DRAGGABLE UI FUNCTION =====
local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil

titleBar.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input, gameProcessed)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		mainFrame.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

-- ===== CREATE RAGDOLL FUNCTION =====
local function createRagdoll()
	-- Delete previous ragdoll
	if currentRagdoll then
		currentRagdoll:Destroy()
		currentRagdoll = nil
	end

	-- Create new ragdoll model
	local ragdoll = Instance.new("Model")
	ragdoll.Name = "Ragdoll_" .. tick()
	ragdoll.Parent = ragdollFolder

	-- Create humanoid root part (HRP)
	local hrp = Instance.new("Part")
	hrp.Name = "HumanoidRootPart"
	hrp.Shape = Enum.PartType.Ball
	hrp.Size = Vector3.new(2, 2, 1)
	hrp.CanCollide = false
	hrp.CFrame = player.Character:FindFirstChild("HumanoidRootPart").CFrame + Vector3.new(0, 5, 0)
	hrp.Parent = ragdoll

	-- Create humanoid
	local humanoid = Instance.new("Humanoid")
	humanoid.Parent = ragdoll

	-- Function to create body parts
	local function createPart(name, size, offset)
		local part = Instance.new("Part")
		part.Name = name
		part.Shape = Enum.PartType.Ball
		part.Size = size
		part.CanCollide = false
		part.CFrame = hrp.CFrame + offset
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		part.Parent = ragdoll
		return part
	end

	-- Create R15 body parts
	local torso = createPart("Torso", Vector3.new(2, 2, 1), Vector3.new(0, 0, 0))
	local head = createPart("Head", Vector3.new(1.25, 1.25, 1.25), Vector3.new(0, 2, 0))

	-- Arms
	local leftArm = createPart("LeftUpperArm", Vector3.new(1, 2, 1), Vector3.new(-2.5, 1, 0))
	local rightArm = createPart("RightUpperArm", Vector3.new(1, 2, 1), Vector3.new(2.5, 1, 0))

	-- Legs
	local leftLeg = createPart("LeftUpperLeg", Vector3.new(1, 2, 1), Vector3.new(-1, -2, 0))
	local rightLeg = createPart("RightUpperLeg", Vector3.new(1, 2, 1), Vector3.new(1, -2, 0))

	-- Create Welds for T-Pose (arms straight out, legs down)
	local function createWeld(part0, part1, c0, c1)
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = part0
		weld.Part1 = part1
		weld.Parent = part0
		return weld
	end

	-- Torso to HRP
	createWeld(hrp, torso, CFrame.new(), CFrame.new())

	-- Head to Torso
	createWeld(torso, head, CFrame.new(0, 1, 0), CFrame.new(0, -0.625, 0))

	-- Arms (T-pose: straight out)
	createWeld(torso, leftArm, CFrame.new(-1, 0, 0) * CFrame.Angles(0, 0, math.rad(90)), CFrame.new(0, 1, 0))
	createWeld(torso, rightArm, CFrame.new(1, 0, 0) * CFrame.Angles(0, 0, math.rad(90)), CFrame.new(0, 1, 0))

	-- Legs (straight down)
	createWeld(torso, leftLeg, CFrame.new(-0.5, -1, 0), CFrame.new(0, 1, 0))
	createWeld(torso, rightLeg, CFrame.new(0.5, -1, 0), CFrame.new(0, 1, 0))

	-- Make all parts non-collidable with each other
	for _, part in pairs(ragdoll:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end

	-- Store reference
	currentRagdoll = ragdoll
	print("✅ Ragdoll spawned successfully!")
end

-- ===== DELETE RAGDOLL FUNCTION =====
local function deleteRagdoll()
	if currentRagdoll then
		currentRagdoll:Destroy()
		currentRagdoll = nil
		print("❌ Ragdoll deleted!")
	else
		print("⚠️ No ragdoll to delete!")
	end
end

-- ===== BUTTON CONNECTIONS =====
spawnButton.MouseButton1Click:Connect(function()
	createRagdoll()
end)

deleteButton.MouseButton1Click:Connect(function()
	deleteRagdoll()
end)

-- Cleanup on death
player.CharacterAdded:Connect(function()
	if currentRagdoll then
		currentRagdoll:Destroy()
		currentRagdoll = nil
	end
end)

print("🎮 Ragdoll Spawner Loaded! Use the UI to spawn/delete ragdolls.")
