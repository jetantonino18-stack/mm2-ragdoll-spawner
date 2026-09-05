print("TEST 1: Script started")

local Players = game:GetService("Players")
print("TEST 2: Got Players service")

local player = Players.LocalPlayer
print("TEST 3: Got local player: " .. tostring(player))

if not player.Character then
	print("TEST 4: No character, waiting...")
	player.Character:WaitForChild("HumanoidRootPart")
end

print("TEST 5: Character ready")

-- Create a simple test part
local testPart = Instance.new("Part")
testPart.Name = "RagdollSpawner_TestPart"
testPart.Shape = Enum.PartType.Ball
testPart.Size = Vector3.new(2, 2, 2)
testPart.Color = Color3.fromRGB(0, 255, 0)
testPart.Material = Enum.Material.Neon
testPart.CanCollide = false
testPart.CFrame = player.Character:FindFirstChild("HumanoidRootPart").CFrame + Vector3.new(0, 10, 0)
testPart.Parent = workspace

print("TEST 6: Test part created - should see GREEN NEON SPHERE in front of you!")
print("If you see this message but no sphere, MM2 is blocking part creation")
