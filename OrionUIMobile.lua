-- ===== ORION UI MOBILE - COMPLETE READY-TO-RUN EXAMPLE =====
-- Optimized for mobile with touch input and simplified UI

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

if not player then
	warn("No player found!")
	return
end

local OrionLib = {}
OrionLib.Windows = {}
OrionLib.Config = {
	Accent = Color3.fromRGB(0, 170, 255),
	Dark = Color3.fromRGB(25, 25, 25),
	Darker = Color3.fromRGB(15, 15, 15),
	TextColor = Color3.fromRGB(255, 255, 255),
	TextDark = Color3.fromRGB(180, 180, 180),
}

-- Tweening helper
local function Tween(object, properties, duration)
	local tweenInfo = TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(object, tweenInfo, properties)
	tween:Play()
	return tween
end

-- ===== WINDOW CLASS =====
function OrionLib:CreateWindow(config)
	config = config or {}
	local windowName = config.Name or "Orion Window"
	local windowSize = config.Size or UDim2.new(1, -20, 0, 600)
	
	local window = {
		Name = windowName,
		Tabs = {},
		CurrentTab = nil,
		IsExpanded = true,
		ScreenGui = nil,
		MainFrame = nil,
	}
	
	-- Create main screen GUI
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "OrionUI_Mobile_" .. windowName
	screenGui.ResetOnSpawn = false
	screenGui.ZIndex = 999
	screenGui.Parent = player:WaitForChild("PlayerGui")
	
	window.ScreenGui = screenGui
	
	-- Main window frame
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainWindow"
	mainFrame.Size = windowSize
	mainFrame.Position = UDim2.new(0.5, -windowSize.X.Offset / 2, 0.1, 0)
	mainFrame.BackgroundColor3 = OrionLib.Config.Dark
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screenGui
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = mainFrame
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = OrionLib.Config.Accent
	stroke.Thickness = 2
	stroke.Parent = mainFrame
	
	window.MainFrame = mainFrame
	
	-- ===== TOP BAR =====
	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(1, 0, 0, 45)
	topBar.BackgroundColor3 = OrionLib.Config.Darker
	topBar.BorderSizePixel = 0
	topBar.Parent = mainFrame
	
	local topBarCorner = Instance.new("UICorner")
	topBarCorner.CornerRadius = UDim.new(0, 8)
	topBarCorner.Parent = topBar
	
	-- Title label
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, -50, 1, 0)
	titleLabel.Position = UDim2.new(0, 10, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextColor3 = OrionLib.Config.TextColor
	titleLabel.TextSize = 16
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = windowName
	titleLabel.Parent = topBar
	
	-- Close button (larger for mobile)
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 45, 1, 0)
	closeButton.Position = UDim2.new(1, -45, 0, 0)
	closeButton.BackgroundTransparency = 1
	closeButton.TextColor3 = Color3.fromRGB(255, 85, 85)
	closeButton.TextSize = 20
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Text = "✕"
	closeButton.Parent = topBar
	
	-- ===== CONTAINER FRAME (Sidebar + Content) =====
	local containerFrame = Instance.new("Frame")
	containerFrame.Name = "Container"
	containerFrame.Size = UDim2.new(1, 0, 1, -45)
	containerFrame.Position = UDim2.new(0, 0, 0, 45)
	containerFrame.BackgroundTransparency = 1
	containerFrame.Parent = mainFrame
	
	-- ===== SIDEBAR (Horizontal for mobile) =====
	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(1, 0, 0, 60)
	sidebar.BackgroundColor3 = OrionLib.Config.Darker
	sidebar.BorderSizePixel = 0
	sidebar.Parent = containerFrame
	
	local sidebarLayout = Instance.new("UIListLayout")
	sidebarLayout.Padding = UDim.new(0, 5)
	sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	sidebarLayout.FillDirection = Enum.FillDirection.Horizontal
	sidebarLayout.Parent = sidebar
	
	local sidebarPadding = Instance.new("UIPadding")
	sidebarPadding.PaddingLeft = UDim.new(0, 5)
	sidebarPadding.PaddingRight = UDim.new(0, 5)
	sidebarPadding.PaddingTop = UDim.new(0, 5)
	sidebarPadding.PaddingBottom = UDim.new(0, 5)
	sidebarPadding.Parent = sidebar
	
	-- ===== CONTENT AREA =====
	local contentArea = Instance.new("Frame")
	contentArea.Name = "ContentArea"
	contentArea.Size = UDim2.new(1, 0, 1, -60)
	contentArea.Position = UDim2.new(0, 0, 0, 60)
	contentArea.BackgroundColor3 = OrionLib.Config.Dark
	contentArea.BorderSizePixel = 0
	contentArea.Parent = containerFrame
	
	local contentPadding = Instance.new("UIPadding")
	contentPadding.PaddingTop = UDim.new(0, 10)
	contentPadding.PaddingBottom = UDim.new(0, 10)
	contentPadding.PaddingLeft = UDim.new(0, 10)
	contentPadding.PaddingRight = UDim.new(0, 10)
	contentPadding.Parent = contentArea
	
	local contentLayout = Instance.new("UIListLayout")
	contentLayout.Padding = UDim.new(0, 8)
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	contentLayout.Parent = contentArea
	
	-- ===== WINDOW METHODS =====
	
	function window:CreateTab(tabName)
		local tab = {
			Name = tabName,
			Sections = {},
			TabButton = nil,
			TabContent = nil,
		}
		
		-- Create tab button (larger for mobile touch)
		local tabButton = Instance.new("TextButton")
		tabButton.Name = "Tab_" .. tabName
		tabButton.Size = UDim2.new(0, 100, 0, 50)
		tabButton.BackgroundColor3 = OrionLib.Config.Darker
		tabButton.TextColor3 = OrionLib.Config.TextDark
		tabButton.TextSize = 12
		tabButton.Font = Enum.Font.Gotham
		tabButton.Text = tabName
		tabButton.TextWrapped = true
		tabButton.BorderSizePixel = 0
		tabButton.Parent = sidebar
		
		local tabButtonCorner = Instance.new("UICorner")
		tabButtonCorner.CornerRadius = UDim.new(0, 6)
		tabButtonCorner.Parent = tabButton
		
		-- Create tab content frame
		local tabContent = Instance.new("Frame")
		tabContent.Name = "TabContent_" .. tabName
		tabContent.Size = UDim2.new(1, 0, 1, 0)
		tabContent.BackgroundTransparency = 1
		tabContent.Visible = false
		tabContent.Parent = contentArea
		
		local tabScroll = Instance.new("ScrollingFrame")
		tabScroll.Name = "ScrollingFrame"
		tabScroll.Size = UDim2.new(1, 0, 1, 0)
		tabScroll.BackgroundTransparency = 1
		tabScroll.ScrollBarThickness = 6
		tabScroll.ScrollBarImageColor3 = OrionLib.Config.Accent
		tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		tabScroll.Parent = tabContent
		
		local scrollLayout = Instance.new("UIListLayout")
		scrollLayout.Padding = UDim.new(0, 8)
		scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
		scrollLayout.Parent = tabScroll
		
		scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			tabScroll.CanvasSize = UDim2.new(0, 0, 0, scrollLayout.AbsoluteContentSize.Y)
		end)
		
		tab.TabButton = tabButton
		tab.TabContent = tabContent
		tab.ScrollingFrame = tabScroll
		tab.LayoutOrder = #window.Tabs + 1
		
		-- Tab button click event (mobile-friendly)
		local function selectTab()
			window:SelectTab(tabName)
		end
		
		tabButton.TouchTap:Connect(selectTab)
		tabButton.MouseButton1Click:Connect(selectTab)
		
		table.insert(window.Tabs, tab)
		
		if #window.Tabs == 1 then
			window:SelectTab(tabName)
		end
		
		return tab
	end
	
	function window:SelectTab(tabName)
		for _, tab in ipairs(window.Tabs) do
			if tab.Name == tabName then
				tab.TabContent.Visible = true
				Tween(tab.TabButton, {BackgroundColor3 = OrionLib.Config.Accent, TextColor3 = OrionLib.Config.Dark}, 0.2)
				window.CurrentTab = tab
			else
				tab.TabContent.Visible = false
				Tween(tab.TabButton, {BackgroundColor3 = OrionLib.Config.Darker, TextColor3 = OrionLib.Config.TextDark}, 0.2)
			end
		end
	end
	
	function window:CreateSection(tabName, sectionName)
		local tab = nil
		for _, t in ipairs(window.Tabs) do
			if t.Name == tabName then
				tab = t
				break
			end
		end
		
		if not tab then return nil end
		
		local section = {
			Name = sectionName,
			Elements = {},
			SectionFrame = nil,
		}
		
		local sectionFrame = Instance.new("Frame")
		sectionFrame.Name = "Section_" .. sectionName
		sectionFrame.Size = UDim2.new(1, 0, 0, 0)
		sectionFrame.BackgroundColor3 = OrionLib.Config.Darker
		sectionFrame.BorderSizePixel = 0
		sectionFrame.Parent = tab.ScrollingFrame
		
		local sectionCorner = Instance.new("UICorner")
		sectionCorner.CornerRadius = UDim.new(0, 6)
		sectionCorner.Parent = sectionFrame
		
		local headerLabel = Instance.new("TextLabel")
		headerLabel.Name = "Header"
		headerLabel.Size = UDim2.new(1, 0, 0, 25)
		headerLabel.BackgroundTransparency = 1
		headerLabel.TextColor3 = OrionLib.Config.Accent
		headerLabel.TextSize = 13
		headerLabel.Font = Enum.Font.GothamBold
		headerLabel.Text = sectionName:upper()
		headerLabel.TextXAlignment = Enum.TextXAlignment.Left
		headerLabel.Parent = sectionFrame
		
		local headerPadding = Instance.new("UIPadding")
		headerPadding.PaddingLeft = UDim.new(0, 10)
		headerPadding.PaddingTop = UDim.new(0, 5)
		headerPadding.Parent = headerLabel
		
		local contentContainer = Instance.new("Frame")
		contentContainer.Name = "ContentContainer"
		contentContainer.Size = UDim2.new(1, 0, 1, -25)
		contentContainer.Position = UDim2.new(0, 0, 0, 25)
		contentContainer.BackgroundTransparency = 1
		contentContainer.Parent = sectionFrame
		
		local contentPadding = Instance.new("UIPadding")
		contentPadding.PaddingLeft = UDim.new(0, 10)
		contentPadding.PaddingRight = UDim.new(0, 10)
		contentPadding.PaddingBottom = UDim.new(0, 10)
		contentPadding.PaddingTop = UDim.new(0, 5)
		contentPadding.Parent = contentContainer
		
		local contentLayout = Instance.new("UIListLayout")
		contentLayout.Padding = UDim.new(0, 8)
		contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
		contentLayout.Parent = contentContainer
		
		contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			sectionFrame.Size = UDim2.new(1, 0, 0, 25 + contentLayout.AbsoluteContentSize.Y + 15)
		end)
		
		section.SectionFrame = sectionFrame
		section.ContentContainer = contentContainer
		table.insert(tab.Sections, section)
		
		return section
	end
	
	function window:AddButton(section, buttonConfig)
		buttonConfig = buttonConfig or {}
		local buttonText = buttonConfig.Name or "Button"
		local callback = buttonConfig.Callback or function() end
		
		local buttonFrame = Instance.new("Frame")
		buttonFrame.Name = "Button_" .. buttonText
		buttonFrame.Size = UDim2.new(1, 0, 0, 40)
		buttonFrame.BackgroundColor3 = OrionLib.Config.Dark
		buttonFrame.BorderSizePixel = 0
		buttonFrame.Parent = section.ContentContainer
		
		local buttonCorner = Instance.new("UICorner")
		buttonCorner.CornerRadius = UDim.new(0, 6)
		buttonCorner.Parent = buttonFrame
		
		local buttonStroke = Instance.new("UIStroke")
		buttonStroke.Color = OrionLib.Config.Accent
		buttonStroke.Thickness = 2
		buttonStroke.Transparency = 0.5
		buttonStroke.Parent = buttonFrame
		
		local buttonButton = Instance.new("TextButton")
		buttonButton.Name = "Button"
		buttonButton.Size = UDim2.new(1, 0, 1, 0)
		buttonButton.BackgroundTransparency = 1
		buttonButton.TextColor3 = OrionLib.Config.TextColor
		buttonButton.TextSize = 14
		buttonButton.Font = Enum.Font.Gotham
		buttonButton.Text = buttonText
		buttonButton.Parent = buttonFrame
		
		local function onButtonClick()
			Tween(buttonFrame, {BackgroundColor3 = OrionLib.Config.Accent}, 0.1)
			callback()
			wait(0.1)
			Tween(buttonFrame, {BackgroundColor3 = OrionLib.Config.Dark}, 0.1)
		end
		
		buttonButton.MouseButton1Click:Connect(onButtonClick)
		buttonButton.TouchTap:Connect(onButtonClick)
		
		return buttonFrame
	end
	
	function window:AddToggle(section, toggleConfig)
		toggleConfig = toggleConfig or {}
		local toggleName = toggleConfig.Name or "Toggle"
		local defaultState = toggleConfig.Default or false
		local callback = toggleConfig.Callback or function() end
		
		local state = defaultState
		
		local toggleFrame = Instance.new("Frame")
		toggleFrame.Name = "Toggle_" .. toggleName
		toggleFrame.Size = UDim2.new(1, 0, 0, 40)
		toggleFrame.BackgroundTransparency = 1
		toggleFrame.Parent = section.ContentContainer
		
		local toggleLabel = Instance.new("TextLabel")
		toggleLabel.Name = "Label"
		toggleLabel.Size = UDim2.new(1, -50, 1, 0)
		toggleLabel.BackgroundTransparency = 1
		toggleLabel.TextColor3 = OrionLib.Config.TextColor
		toggleLabel.TextSize = 13
		toggleLabel.Font = Enum.Font.Gotham
		toggleLabel.Text = toggleName
		toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
		toggleLabel.Parent = toggleFrame
		
		local toggleBox = Instance.new("Frame")
		toggleBox.Name = "ToggleBox"
		toggleBox.Size = UDim2.new(0, 45, 0, 25)
		toggleBox.Position = UDim2.new(1, -45, 0.5, -12.5)
		toggleBox.BackgroundColor3 = OrionLib.Config.Dark
		toggleBox.BorderSizePixel = 0
		toggleBox.Parent = toggleFrame
		
		local toggleBoxCorner = Instance.new("UICorner")
		toggleBoxCorner.CornerRadius = UDim.new(0, 6)
		toggleBoxCorner.Parent = toggleBox
		
		local toggleBoxStroke = Instance.new("UIStroke")
		toggleBoxStroke.Color = OrionLib.Config.Accent
		toggleBoxStroke.Thickness = 2
		toggleBoxStroke.Transparency = 0.5
		toggleBoxStroke.Parent = toggleBox
		
		local toggleCircle = Instance.new("Frame")
		toggleCircle.Name = "Circle"
		toggleCircle.Size = UDim2.new(0, 18, 0, 18)
		toggleCircle.Position = UDim2.new(0, 3.5, 0.5, -9)
		toggleCircle.BackgroundColor3 = OrionLib.Config.TextDark
		toggleCircle.BorderSizePixel = 0
		toggleCircle.Parent = toggleBox
		
		local circleCorner = Instance.new("UICorner")
		circleCorner.CornerRadius = UDim.new(1, 0)
		circleCorner.Parent = toggleCircle
		
		local function updateToggle()
			if state then
				Tween(toggleCircle, {Position = UDim2.new(0, 24, 0.5, -9)}, 0.2)
				Tween(toggleBox, {BackgroundColor3 = OrionLib.Config.Accent}, 0.2)
				Tween(toggleCircle, {BackgroundColor3 = OrionLib.Config.Dark}, 0.2)
			else
				Tween(toggleCircle, {Position = UDim2.new(0, 3.5, 0.5, -9)}, 0.2)
				Tween(toggleBox, {BackgroundColor3 = OrionLib.Config.Dark}, 0.2)
				Tween(toggleCircle, {BackgroundColor3 = OrionLib.Config.TextDark}, 0.2)
			end
		end
		
		local function toggleClick()
			state = not state
			updateToggle()
			callback(state)
		end
		
		toggleBox.MouseButton1Click:Connect(toggleClick)
		toggleBox.TouchTap:Connect(toggleClick)
		
		if defaultState then
			updateToggle()
		end
		
		return toggleFrame
	end
	
	function window:AddSlider(section, sliderConfig)
		sliderConfig = sliderConfig or {}
		local sliderName = sliderConfig.Name or "Slider"
		local minValue = sliderConfig.Min or 0
		local maxValue = sliderConfig.Max or 100
		local defaultValue = sliderConfig.Default or minValue
		local callback = sliderConfig.Callback or function() end
		
		local currentValue = defaultValue
		local isDragging = false
		
		local sliderFrame = Instance.new("Frame")
		sliderFrame.Name = "Slider_" .. sliderName
		sliderFrame.Size = UDim2.new(1, 0, 0, 55)
		sliderFrame.BackgroundTransparency = 1
		sliderFrame.Parent = section.ContentContainer
		
		local sliderLabel = Instance.new("TextLabel")
		sliderLabel.Name = "Label"
		sliderLabel.Size = UDim2.new(1, 0, 0, 20)
		sliderLabel.BackgroundTransparency = 1
		sliderLabel.TextColor3 = OrionLib.Config.TextColor
		sliderLabel.TextSize = 13
		sliderLabel.Font = Enum.Font.Gotham
		sliderLabel.Text = sliderName .. ": " .. defaultValue
		sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
		sliderLabel.Parent = sliderFrame
		
		local sliderBar = Instance.new("Frame")
		sliderBar.Name = "Bar"
		sliderBar.Size = UDim2.new(1, 0, 0, 8)
		sliderBar.Position = UDim2.new(0, 0, 0, 25)
		sliderBar.BackgroundColor3 = OrionLib.Config.Dark
		sliderBar.BorderSizePixel = 0
		sliderBar.Parent = sliderFrame
		
		local sliderBarCorner = Instance.new("UICorner")
		sliderBarCorner.CornerRadius = UDim.new(1, 0)
		sliderBarCorner.Parent = sliderBar
		
		local sliderFill = Instance.new("Frame")
		sliderFill.Name = "Fill"
		sliderFill.Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0)
		sliderFill.BackgroundColor3 = OrionLib.Config.Accent
		sliderFill.BorderSizePixel = 0
		sliderFill.Parent = sliderBar
		
		local fillCorner = Instance.new("UICorner")
		fillCorner.CornerRadius = UDim.new(1, 0)
		fillCorner.Parent = sliderFill
		
		local sliderButton = Instance.new("TextButton")
		sliderButton.Name = "SliderButton"
		sliderButton.Size = UDim2.new(1, 0, 1, 0)
		sliderButton.BackgroundTransparency = 1
		sliderButton.Text = ""
		sliderButton.Parent = sliderBar
		
		local function updateSlider(input)
			local mouse = game:GetService("Players").LocalPlayer:GetMouse()
			local barPosition = sliderBar.AbsolutePosition.X
			local barSize = sliderBar.AbsoluteSize.X
			local mousePosition = math.clamp(mouse.X - barPosition, 0, barSize)
			local percentage = mousePosition / barSize
			currentValue = math.round(minValue + (maxValue - minValue) * percentage)
			sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
			sliderLabel.Text = sliderName .. ": " .. currentValue
			callback(currentValue)
		end
		
		sliderButton.InputBegan:Connect(function(input, gameProcessed)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				isDragging = true
				updateSlider(input)
			end
		end)
		
		UserInputService.InputEnded:Connect(function(input, gameProcessed)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				isDragging = false
			end
		end)
		
		UserInputService.InputChanged:Connect(function(input, gameProcessed)
			if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				updateSlider(input)
			end
		end)
		
		return sliderFrame
	end
	
	-- Close button
	closeButton.MouseButton1Click:Connect(function()
		Tween(mainFrame, {BackgroundTransparency = 1}, 0.2)
		wait(0.2)
		screenGui:Destroy()
	end)
	
	closeButton.TouchTap:Connect(function()
		Tween(mainFrame, {BackgroundTransparency = 1}, 0.2)
		wait(0.2)
		screenGui:Destroy()
	end)
	
	table.insert(OrionLib.Windows, window)
	return window
end

-- ===== MOBILE DEMO =====

print("📱 Creating Mobile Orion UI Demo...")

local window = OrionLib:CreateWindow({
	Name = "Mobile Demo",
	Size = UDim2.new(1, -20, 0, 650)
})

-- Create tabs
local tab1 = window:CreateTab("Home")
local tab2 = window:CreateTab("Settings")
local tab3 = window:CreateTab("Info")

-- ===== TAB 1: HOME =====
local section1 = window:CreateSection("Home", "Buttons")
window:AddButton(section1, {
	Name = "Tap Me!",
	Callback = function()
		print("✅ Button tapped!")
	end
})

window:AddButton(section1, {
	Name = "Another Button",
	Callback = function()
		print("✅ Another tap!")
	end
})

local section2 = window:CreateSection("Home", "Toggles")
window:AddToggle(section2, {
	Name = "Feature Toggle",
	Default = true,
	Callback = function(state)
		print("Toggle: " .. tostring(state))
	end
})

window:AddToggle(section2, {
	Name = "Another Feature",
	Default = false,
	Callback = function(state)
		print("Another toggle: " .. tostring(state))
	end
})

-- ===== TAB 2: SETTINGS =====
local section3 = window:CreateSection("Settings", "Sliders")
window:AddSlider(section3, {
	Name = "Speed",
	Min = 0,
	Max = 100,
	Default = 50,
	Callback = function(value)
		print("Speed: " .. value)
	end
})

window:AddSlider(section3, {
	Name = "Volume",
	Min = 0,
	Max = 100,
	Default = 75,
	Callback = function(value)
		print("Volume: " .. value)
	end
})

local section4 = window:CreateSection("Settings", "Actions")
window:AddButton(section4, {
	Name = "Save",
	Callback = function()
		print("✅ Saved!")
	end
})

window:AddButton(section4, {
	Name = "Reset",
	Callback = function()
		print("🔄 Reset!")
	end
})

-- ===== TAB 3: INFO =====
local section5 = window:CreateSection("Info", "Mobile Features")
window:AddToggle(section5, {
	Name = "Touch Optimized",
	Default = true,
	Callback = function(state)
		print("Touch optimized: " .. tostring(state))
	end
})

window:AddButton(section5, {
	Name = "Test Tap",
	Callback = function()
		print("📱 Mobile tap works!")
	end
})

print("✅ Mobile Orion UI loaded!")
print("📋 Features:")
print("  - Touch-optimized buttons (larger, easier to tap)")
print("  - Horizontal tabs for mobile")
print("  - Full width on mobile")
print("  - Smooth animations")
print("  - Swipe-friendly scrolling")
