-- ===== RAGDOLL SPAWNER - STANDALONE VERSION =====
local success, err = pcall(function()
	local Players = game:GetService("Players")
	local UserInputService = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")

	local player = Players.LocalPlayer
	if not player then return end
	
	local mouse = player:GetMouse()

	-- Create folder for ragdolls
	local ragdollFolder = Instance.new("Folder")
	ragdollFolder.Name = "RagdollSpawner_Ragdolls"
	ragdollFolder.Parent = workspace

	local currentRagdoll = nil

	-- ===== CREATE RAGDOLL FUNCTION =====
	local function createRagdoll()
		-- Delete previous ragdoll
		if currentRagdoll then
			pcall(function() currentRagdoll:Destroy() end)
			currentRagdoll = nil
		end

		-- Get spawn position
		local playerHRP = player.Character:FindFirstChild("HumanoidRootPart")
		if not playerHRP then 
			warn("No HRP found!")
			return 
		end
		
		local spawnPos = playerHRP.CFrame + Vector3.new(0, 5, 0)

		-- Create ragdoll model
		local ragdoll = Instance.new("Model")
		ragdoll.Name = "Ragdoll_" .. tick()
		ragdoll.Parent = ragdollFolder

		-- Create HRP
		local hrp = Instance.new("Part")
		hrp.Name = "HumanoidRootPart"
		hrp.Shape = Enum.PartType.Ball
		hrp.Size = Vector3.new(2, 2, 1)
		hrp.CanCollide = false
		hrp.CFrame = spawnPos
		hrp.Anchored = true
		hrp.Color = Color3.fromRGB(100, 100, 100)
		hrp.Material = Enum.Material.SmoothPlastic
		hrp.Parent = ragdoll

		-- Create humanoid
		local humanoid = Instance.new("Humanoid")
		humanoid.Parent = ragdoll

		-- Function to create body parts
		local function createPart(name, size, offset, color)
			local part = Instance.new("Part")
			part.Name = name
			part.Shape = Enum.PartType.Ball
			part.Size = size
			part.CanCollide = false
			part.CFrame = hrp.CFrame + offset
			part.Anchored = true
			part.TopSurface = Enum.SurfaceType.Smooth
			part.BottomSurface = Enum.SurfaceType.Smooth
			part.Color = color or Color3.fromRGB(200, 200, 200)
			part.Material = Enum.Material.SmoothPlastic
			part.Parent = ragdoll
			return part
		end

		-- Create R15 body parts
		local torso = createPart("Torso", Vector3.new(2, 2, 1), Vector3.new(0, 0, 0), Color3.fromRGB(50, 100, 150))
		local head = createPart("Head", Vector3.new(1.25, 1.25, 1.25), Vector3.new(0, 2, 0), Color3.fromRGB(255, 200, 150))

		-- Arms
		local leftArm = createPart("LeftUpperArm", Vector3.new(1, 2, 1), Vector3.new(-2.5, 1, 0))
		local rightArm = createPart("RightUpperArm", Vector3.new(1, 2, 1), Vector3.new(2.5, 1, 0))

		-- Legs
		local leftLeg = createPart("LeftUpperLeg", Vector3.new(1, 2, 1), Vector3.new(-1, -2, 0))
		local rightLeg = createPart("RightUpperLeg", Vector3.new(1, 2, 1), Vector3.new(1, -2, 0))

		-- Create Welds for T-Pose
		local function createWeld(part0, part1)
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = part0
			weld.Part1 = part1
			weld.Parent = part0
			return weld
		end

		-- Weld parts together
		createWeld(hrp, torso)
		createWeld(torso, head)
		createWeld(torso, leftArm)
		createWeld(torso, rightArm)
		createWeld(torso, leftLeg)
		createWeld(torso, rightLeg)

		-- Anchor all parts
		for _, part in pairs(ragdoll:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
				part.Anchored = true
			end
		end

		currentRagdoll = ragdoll
		print("✅ Ragdoll spawned at position: " .. tostring(spawnPos.Position))
	end

	-- ===== DELETE RAGDOLL FUNCTION =====
	local function deleteRagdoll()
		if currentRagdoll then
			pcall(function() currentRagdoll:Destroy() end)
			currentRagdoll = nil
			print("❌ Ragdoll deleted!")
		else
			print("⚠️ No ragdoll to delete")
		end
	end

	-- ===== CREATE 3D UI BUTTONS =====
	local uiFolder = Instance.new("Folder")
	uiFolder.Name = "RagdollUI"
	uiFolder.Parent = workspace

	-- Title
	local title = Instance.new("Part")
	title.Name = "Title"
	title.Shape = Enum.PartType.Block
	title.Size = Vector3.new(3, 0.5, 0.1)
	title.Color = Color3.fromRGB(30, 30, 30)
	title.Material = Enum.Material.SmoothPlastic
	title.CanCollide = false
	title.CFrame = CFrame.new(0, 5, -15)
	title.Parent = uiFolder

	-- Spawn Button
	local spawnBtn = Instance.new("Part")
	spawnBtn.Name = "SpawnButton"
	spawnBtn.Shape = Enum.PartType.Block
	spawnBtn.Size = Vector3.new(1.4, 0.4, 0.1)
	spawnBtn.Color = Color3.fromRGB(0, 150, 136)
	spawnBtn.Material = Enum.Material.Neon
	spawnBtn.CanCollide = false
	spawnBtn.CFrame = CFrame.new(-0.8, 4.3, -15)
	spawnBtn.Parent = uiFolder

	-- Delete Button
	local deleteBtn = Instance.new("Part")
	deleteBtn.Name = "DeleteButton"
	deleteBtn.Shape = Enum.PartType.Block
	deleteBtn.Size = Vector3.new(1.4, 0.4, 0.1)
	deleteBtn.Color = Color3.fromRGB(244, 67, 54)
	deleteBtn.Material = Enum.Material.Neon
	deleteBtn.CanCollide = false
	deleteBtn.CFrame = CFrame.new(0.8, 4.3, -15)
	deleteBtn.Parent = uiFolder

	-- ===== BUTTON CLICK DETECTION =====
	local debounce = false

	spawnBtn.Touched:Connect(function(hit)
		if not debounce and hit.Parent == player.Character then
			debounce = true
			createRagdoll()
			wait(0.5)
			debounce = false
		end
	end)

	deleteBtn.Touched:Connect(function(hit)
		if not debounce and hit.Parent == player.Character then
			debounce = true
			deleteRagdoll()
			wait(0.5)
			debounce = false
		end
	end)

	-- ===== DRAGGABLE UI =====
	local dragging = false
	local dragStart = nil
	local uiStartPos = nil

	title.Touched:Connect(function(hit)
		if hit.Parent == player.Character then
			dragging = true
			dragStart = mouse.Hit.Position
			uiStartPos = uiFolder:FindFirstChild("Title").CFrame
		end
	end)

	RunService.RenderStepped:Connect(function()
		if dragging and dragStart then
			local delta = mouse.Hit.Position - dragStart
			for _, part in pairs(uiFolder:GetChildren()) do
				part.CFrame = part.CFrame + delta
			end
			dragStart = mouse.Hit.Position
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	-- Cleanup on death
	player.CharacterAdded:Connect(function()
		if currentRagdoll then
			pcall(function() currentRagdoll:Destroy() end)
			currentRagdoll = nil
		end
	end)

	print("🎮 Ragdoll Spawner Loaded! Look in front of you for the UI buttons.")
end)

if not success then
	warn("Error loading Ragdoll Spawner: " .. tostring(err))
end
