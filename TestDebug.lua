-- ULTRA MINIMAL TEST
pcall(function()
	warn("=== RAGDOLL SPAWNER STARTED ===")
end)

-- Try direct workspace modification
pcall(function()
	local part = Instance.new("Part")
	part.Name = "TestRagdoll"
	part.Size = Vector3.new(1, 1, 1)
	part.Color = Color3.fromRGB(255, 0, 0)
	part.Parent = workspace
	warn("PART CREATED")
end)

-- Try getting player
pcall(function()
	local player = game:GetService("Players").LocalPlayer
	warn("PLAYER: " .. tostring(player.Name))
end)

-- Simple ragdoll creator
pcall(function()
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	
	if player and player.Character then
		local hrp = player.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			local ragdoll = Instance.new("Model")
			ragdoll.Name = "SimpleRagdoll"
			ragdoll.Parent = workspace
			
			local head = Instance.new("Part")
			head.Name = "Head"
			head.Shape = Enum.PartType.Ball
			head.Size = Vector3.new(2, 2, 2)
			head.CFrame = hrp.CFrame + Vector3.new(0, 5, 0)
			head.Anchored = true
			head.CanCollide = false
			head.Color = Color3.fromRGB(255, 200, 100)
			head.Parent = ragdoll
			
			warn("RAGDOLL CREATED!")
		end
	end
end)

warn("=== SCRIPT COMPLETE ===")
