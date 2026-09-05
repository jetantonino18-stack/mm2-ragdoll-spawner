local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Variables
local ragdollFolder = Instance.new("Folder")
ragdollFolder.Name = "RagdollSpawner_Ragdolls"
ragdollFolder.Parent = workspace

local currentRagdoll = nil
local spawnPosition = nil

-- ===== CUSTOM UI LIBRARY (Simple) =====
local UILib = {}

function UILib:CreateWindow(title)
	local window = {}
	
	-- Create main container (using Part-based UI instead of GUI)
	local container = Instance.new("Part")
	container.Name = "UIWindow_" .. title
	container.Shape = Enum.PartType.Ball
	container.Material = Enum.Material.Neon
	container.Color = Color3.fromRGB(40, 40, 40)
	container.Size = Vector3.new(4, 5, 0.1)
	container.CanCollide = false
	container.CFrame = workspace.Camera.CFrame + workspace.Camera.CFrame.LookVector * 10
	container.Parent = workspace
	
	window.container = container
	window.buttons = {}
	
	return window
end

function UILib:AddButton(window, buttonText, callback)
	local button = Instance.new("Part")
	button.Name = "Button_" .. buttonText
	button.Shape = Enum.PartType.Block
	button.Color = Color3.fromRGB(0, 150, 136)
	button.Material = Enum.Material.Neon
	button.Size = Vector3.new(3, 0.8, 0.1)
	button.CanCollide = false
	button.Parent = workspace
	
	local offset = #window.buttons * 1.2
	button.CFrame = window.container.CFrame + Vector3.new(0, -2 + offset, 0)
	
	-- Click detection
	local debounce = false
	button.Touched:Connect(function(hit)
		if not debounce and hit.Parent == player.Character then
			debounce = true
			callback()
			wait(0.5)
			debounce = false
		end
	})
	
	table.insert(window.buttons, button)
end

function UILib:MakeWindowDraggable(window)
	local dragging = false
	local dragStart = nil
	local startCFrame = nil
	
	window.container.Touched:Connect(function(hit)
		if hit.Parent == player.Character then
			dragging = true
			dragStart = mouse.Hit.Position
			startCFrame = window.container.CFrame
		end
	})
	
	RunService.RenderStepped:Connect(function()
		if dragging then
			local delta = mouse.Hit.Position - dragStart
			window.container.CFrame = startCFrame * CFrame.new(delta)
			
			for i, button in ipairs(window.buttons) do
				local offset = (i - 1) * 1.2
				button.CFrame = window.container.CFrame + Vector3.new(0, -2 + offset, 0)
			end
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

-- ===== CREATE RAGDOLL FUNCTION =====
local function createRagdoll()
	-- Delete previous ragdoll
	if currentRagdoll then
		currentRagdoll:Destroy()
		currentRagdoll = nil
	end

	-- Get spawn position (where player is when spawning)
	local playerHRP = player.Character:FindFirstChild("HumanoidRootPart")
	if not playerHRP then return end
	
	spawnPosition = playerHRP.CFrame + Vector3.new(0, 5, 0)

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
	hrp.CFrame = spawnPosition
	hrp.Anchored = true
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
		part.Anchored = true
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

	-- Create Welds for T-Pose
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

	-- Make all parts non-collidable
	for _, part in pairs(ragdoll:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
			part.Anchored = true
		end
	end

	currentRagdoll = ragdoll
	print("✅ Ragdoll spawned!")
end

-- ===== DELETE RAGDOLL FUNCTION =====
local function deleteRagdoll()
	if currentRagdoll then
		currentRagdoll:Destroy()
		currentRagdoll = nil
		print("❌ Ragdoll deleted!")
	end
end

-- ===== CREATE WINDOW =====
local window = UILib:CreateWindow("Ragdoll Spawner")

UILib:AddButton(window, "Spawn", function()
	createRagdoll()
end)

UILib:AddButton(window, "Delete", function()
	deleteRagdoll()
end)

UILib:MakeWindowDraggable(window)

print("🎮 Ragdoll Spawner Loaded!")
