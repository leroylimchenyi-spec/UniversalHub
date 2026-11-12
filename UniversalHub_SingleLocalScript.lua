--[[
Universal Hub - Single LocalScript edition
For Roblox Studio only:
Place this LocalScript in StarterPlayer > StarterPlayerScripts.

This is a merged version of UIComponents.lua, HubFramework.lua,
and HubLoader.client.lua. It is not designed for executor injection.
]]

--[[
	UIComponents.lua (ModuleScript)
	Reusable, styled UI component factory for the Universal Hub.
	Path suggestion: ReplicatedStorage/HubModules/UIComponents

	Every function returns the created Instance (plus, where useful, an API
	table with :Set()/:Get()/:OnChanged() so other code can drive the widget
	programmatically).
]]

local TweenService = game:GetService("TweenService")

local UIComponents = {}

-- ======================= THEME ===================================

UIComponents.Theme = {
	Background     = Color3.fromRGB(18, 18, 20),
	Surface        = Color3.fromRGB(26, 26, 29),
	SurfaceAlt     = Color3.fromRGB(32, 32, 36),
	Border         = Color3.fromRGB(44, 44, 48),
	Accent         = Color3.fromRGB(120, 130, 255),
	AccentDim      = Color3.fromRGB(70, 75, 140),
	TextPrimary    = Color3.fromRGB(235, 235, 240),
	TextSecondary  = Color3.fromRGB(150, 150, 158),
	Success        = Color3.fromRGB(90, 200, 130),
	Danger         = Color3.fromRGB(220, 90, 90),
	Font           = Enum.Font.Gotham,
	FontBold       = Enum.Font.GothamBold,
	FontMedium     = Enum.Font.GothamMedium,
	CornerRadius   = UDim.new(0, 8),
	AnimTime       = 0.18,
}

local Theme = UIComponents.Theme

-- ======================= HELPERS ==================================

local function tween(obj, props, time, style, dir)
	local info = TweenInfo.new(
		time or Theme.AnimTime,
		style or Enum.EasingStyle.Quad,
		dir or Enum.EasingDirection.Out
	)
	local t = TweenService:Create(obj, info, props)
	t:Play()
	return t
end
UIComponents.Tween = tween

local function addCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = radius or Theme.CornerRadius
	c.Parent = parent
	return c
end
UIComponents.AddCorner = addCorner

local function addStroke(parent, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color or Theme.Border
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end
UIComponents.AddStroke = addStroke

local function addPadding(parent, px)
	px = px or 10
	local p = Instance.new("UIPadding")
	p.PaddingTop = UDim.new(0, px)
	p.PaddingBottom = UDim.new(0, px)
	p.PaddingLeft = UDim.new(0, px)
	p.PaddingRight = UDim.new(0, px)
	p.Parent = parent
	return p
end
UIComponents.AddPadding = addPadding

local function safeConnect(signal, fn)
	-- Error handling wrapper: never let a UI callback crash the whole hub
	return signal:Connect(function(...)
		local ok, err = pcall(fn, ...)
		if not ok then
			warn("[UniversalHub] UI callback error: " .. tostring(err))
		end
	end)
end
UIComponents.SafeConnect = safeConnect

-- ======================= SECTION HEADER ============================

function UIComponents.SectionHeader(parent, text)
	local label = Instance.new("TextLabel")
	label.Name = "SectionHeader"
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 0, 26)
	label.Font = Theme.FontBold
	label.TextSize = 14
	label.TextColor3 = Theme.TextSecondary
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = string.upper(text)
	label.Parent = parent
	return label
end

-- ======================= INFO CARD =================================

function UIComponents.InfoCard(parent, titleText, bodyText)
	local card = Instance.new("Frame")
	card.Name = "InfoCard"
	card.BackgroundColor3 = Theme.Surface
	card.Size = UDim2.new(1, 0, 0, 72)
	card.AutomaticSize = Enum.AutomaticSize.Y
	card.Parent = parent
	addCorner(card)
	addStroke(card)
	addPadding(card, 12)

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 4)
	layout.Parent = card

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Font = Theme.FontBold
	title.TextSize = 15
	title.TextColor3 = Theme.TextPrimary
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Size = UDim2.new(1, 0, 0, 20)
	title.Text = titleText
	title.LayoutOrder = 1
	title.Parent = card

	local body = Instance.new("TextLabel")
	body.BackgroundTransparency = 1
	body.Font = Theme.Font
	body.TextSize = 13
	body.TextColor3 = Theme.TextSecondary
	body.TextXAlignment = Enum.TextXAlignment.Left
	body.TextYAlignment = Enum.TextYAlignment.Top
	body.TextWrapped = true
	body.Size = UDim2.new(1, 0, 0, 0)
	body.AutomaticSize = Enum.AutomaticSize.Y
	body.Text = bodyText
	body.LayoutOrder = 2
	body.Parent = card

	return card
end

-- ======================= BUTTON =====================================

function UIComponents.Button(parent, text, callback)
	local btn = Instance.new("TextButton")
	btn.Name = "Button"
	btn.AutoButtonColor = false
	btn.BackgroundColor3 = Theme.SurfaceAlt
	btn.Size = UDim2.new(1, 0, 0, 34)
	btn.Font = Theme.FontMedium
	btn.TextSize = 14
	btn.TextColor3 = Theme.TextPrimary
	btn.Text = text
	btn.Parent = parent
	addCorner(btn, UDim.new(0, 6))
	addStroke(btn)

	safeConnect(btn.MouseEnter, function()
		tween(btn, {BackgroundColor3 = Theme.Accent})
	end)
	safeConnect(btn.MouseLeave, function()
		tween(btn, {BackgroundColor3 = Theme.SurfaceAlt})
	end)
	safeConnect(btn.MouseButton1Down, function()
		tween(btn, {Size = UDim2.new(1, 0, 0, 32)}, 0.08)
	end)
	safeConnect(btn.MouseButton1Up, function()
		tween(btn, {Size = UDim2.new(1, 0, 0, 34)}, 0.08)
	end)
	safeConnect(btn.MouseButton1Click, function()
		if callback then callback() end
	end)

	return btn
end

-- ======================= TOGGLE =====================================

function UIComponents.Toggle(parent, text, default, callback)
	default = (default == true)

	local row = Instance.new("Frame")
	row.Name = "Toggle"
	row.BackgroundColor3 = Theme.Surface
	row.Size = UDim2.new(1, 0, 0, 40)
	row.Parent = parent
	addCorner(row)
	addStroke(row)

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.new(0, 12, 0, 0)
	label.Size = UDim2.new(1, -70, 1, 0)
	label.Font = Theme.Font
	label.TextSize = 14
	label.TextColor3 = Theme.TextPrimary
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = text
	label.Parent = row

	local track = Instance.new("Frame")
	track.Name = "Track"
	track.AnchorPoint = Vector2.new(1, 0.5)
	track.Position = UDim2.new(1, -12, 0.5, 0)
	track.Size = UDim2.new(0, 42, 0, 22)
	track.BackgroundColor3 = default and Theme.Accent or Theme.SurfaceAlt
	track.Parent = row
	addCorner(track, UDim.new(1, 0))

	local knob = Instance.new("Frame")
	knob.Name = "Knob"
	knob.Size = UDim2.new(0, 18, 0, 18)
	knob.Position = default and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
	knob.AnchorPoint = Vector2.new(0, 0.5)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.Parent = track
	addCorner(knob, UDim.new(1, 0))

	local clickArea = Instance.new("TextButton")
	clickArea.BackgroundTransparency = 1
	clickArea.Text = ""
	clickArea.Size = UDim2.new(1, 0, 1, 0)
	clickArea.Parent = row

	local state = default
	local api = {}

	local function render(animated)
		local trackColor = state and Theme.Accent or Theme.SurfaceAlt
		local knobPos = state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
		if animated then
			tween(track, {BackgroundColor3 = trackColor})
			tween(knob, {Position = knobPos})
		else
			track.BackgroundColor3 = trackColor
			knob.Position = knobPos
		end
	end

	function api:Set(value, silent)
		state = value and true or false
		render(true)
		if not silent and callback then callback(state) end
	end

	function api:Get()
		return state
	end

	safeConnect(clickArea.MouseButton1Click, function()
		api:Set(not state)
	end)

	return row, api
end

-- ======================= SLIDER =====================================

function UIComponents.Slider(parent, text, min, max, default, decimals, callback)
	min, max = min or 0, max or 100
	default = math.clamp(default or min, min, max)
	decimals = decimals or 0

	local container = Instance.new("Frame")
	container.Name = "Slider"
	container.BackgroundColor3 = Theme.Surface
	container.Size = UDim2.new(1, 0, 0, 52)
	container.Parent = parent
	addCorner(container)
	addStroke(container)
	addPadding(container, 10)

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, -50, 0, 18)
	label.Font = Theme.Font
	label.TextSize = 13
	label.TextColor3 = Theme.TextPrimary
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = text
	label.Parent = container

	local valueLabel = Instance.new("TextLabel")
	valueLabel.BackgroundTransparency = 1
	valueLabel.AnchorPoint = Vector2.new(1, 0)
	valueLabel.Position = UDim2.new(1, 0, 0, 0)
	valueLabel.Size = UDim2.new(0, 50, 0, 18)
	valueLabel.Font = Theme.FontBold
	valueLabel.TextSize = 13
	valueLabel.TextColor3 = Theme.Accent
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = container

	local bar = Instance.new("Frame")
	bar.Name = "Bar"
	bar.Position = UDim2.new(0, 0, 0, 30)
	bar.Size = UDim2.new(1, 0, 0, 6)
	bar.BackgroundColor3 = Theme.SurfaceAlt
	bar.Parent = container
	addCorner(bar, UDim.new(1, 0))

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.BackgroundColor3 = Theme.Accent
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.Parent = bar
	addCorner(fill, UDim.new(1, 0))

	local knob = Instance.new("Frame")
	knob.Name = "Knob"
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Size = UDim2.new(0, 14, 0, 14)
	knob.Position = UDim2.new(0, 0, 0.5, 0)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.ZIndex = 2
	knob.Parent = bar
	addCorner(knob, UDim.new(1, 0))

	local dragging = false
	local value = default

	local function formatValue(v)
		if decimals <= 0 then
			return tostring(math.floor(v + 0.5))
		end
		return string.format("%." .. decimals .. "f", v)
	end

	local function renderFromValue(animated)
		local alpha = (value - min) / (max - min)
		alpha = math.clamp(alpha, 0, 1)
		valueLabel.Text = formatValue(value)
		if animated then
			tween(fill, {Size = UDim2.new(alpha, 0, 1, 0)}, 0.08)
			tween(knob, {Position = UDim2.new(alpha, 0, 0.5, 0)}, 0.08)
		else
			fill.Size = UDim2.new(alpha, 0, 1, 0)
			knob.Position = UDim2.new(alpha, 0, 0.5, 0)
		end
	end

	local api = {}

	function api:Set(v, silent)
		value = math.clamp(v, min, max)
		renderFromValue(true)
		if not silent and callback then callback(value) end
	end

	function api:Get()
		return value
	end

	local function updateFromInputX(inputX)
		local relative = (inputX - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
		relative = math.clamp(relative, 0, 1)
		local raw = min + (max - min) * relative
		if decimals <= 0 then
			raw = math.floor(raw + 0.5)
		else
			local mult = 10 ^ decimals
			raw = math.floor(raw * mult + 0.5) / mult
		end
		api:Set(raw)
	end

	safeConnect(bar.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			updateFromInputX(input.Position.X)
		end
	end)

	safeConnect(game:GetService("UserInputService").InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			updateFromInputX(input.Position.X)
		end
	end)

	safeConnect(game:GetService("UserInputService").InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	renderFromValue(false)

	return container, api
end

-- ======================= DROPDOWN ===================================

function UIComponents.Dropdown(parent, text, options, default, callback)
	options = options or {}
	default = default or options[1]

	local container = Instance.new("Frame")
	container.Name = "Dropdown"
	container.BackgroundColor3 = Theme.Surface
	container.Size = UDim2.new(1, 0, 0, 40)
	container.ClipsDescendants = false
	container.ZIndex = 2
	container.Parent = parent
	addCorner(container)
	addStroke(container)

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.new(0, 12, 0, 0)
	label.Size = UDim2.new(0.5, 0, 1, 0)
	label.Font = Theme.Font
	label.TextSize = 13
	label.TextColor3 = Theme.TextSecondary
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = text
	label.Parent = container

	local selected = Instance.new("TextButton")
	selected.Name = "Selected"
	selected.AnchorPoint = Vector2.new(1, 0.5)
	selected.Position = UDim2.new(1, -10, 0.5, 0)
	selected.Size = UDim2.new(0.45, 0, 0, 28)
	selected.BackgroundColor3 = Theme.SurfaceAlt
	selected.Font = Theme.FontMedium
	selected.TextSize = 13
	selected.TextColor3 = Theme.TextPrimary
	selected.Text = tostring(default) .. "  ▾"
	selected.AutoButtonColor = false
	selected.ZIndex = 2
	selected.Parent = container
	addCorner(selected, UDim.new(0, 6))

	local list = Instance.new("Frame")
	list.Name = "OptionList"
	list.BackgroundColor3 = Theme.SurfaceAlt
	list.Position = UDim2.new(1, -10, 1, 4)
	list.AnchorPoint = Vector2.new(1, 0)
	list.Size = UDim2.new(0.45, 0, 0, 0)
	list.ClipsDescendants = true
	list.Visible = false
	list.ZIndex = 5
	list.Parent = container
	addCorner(list, UDim.new(0, 6))
	addStroke(list)

	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = list

	local api = {}
	local open = false
	local value = default

	local function close()
		open = false
		tween(list, {Size = UDim2.new(0.45, 0, 0, 0)}, 0.12)
		task.delay(0.12, function()
			if not open then list.Visible = false end
		end)
	end

	local function setValue(v, silent)
		value = v
		selected.Text = tostring(v) .. "  ▾"
		if not silent and callback then callback(v) end
	end

	function api:Set(v, silent) setValue(v, silent) end
	function api:Get() return value end

	for i, opt in ipairs(options) do
		local optBtn = Instance.new("TextButton")
		optBtn.BackgroundTransparency = 1
		optBtn.Size = UDim2.new(1, 0, 0, 28)
		optBtn.Font = Theme.Font
		optBtn.TextSize = 13
		optBtn.TextColor3 = Theme.TextPrimary
		optBtn.Text = tostring(opt)
		optBtn.LayoutOrder = i
		optBtn.ZIndex = 6
		optBtn.Parent = list

		safeConnect(optBtn.MouseEnter, function()
			tween(optBtn, {TextColor3 = Theme.Accent}, 0.1)
		end)
		safeConnect(optBtn.MouseLeave, function()
			tween(optBtn, {TextColor3 = Theme.TextPrimary}, 0.1)
		end)
		safeConnect(optBtn.MouseButton1Click, function()
			setValue(opt)
			close()
		end)
	end

	safeConnect(selected.MouseButton1Click, function()
		open = not open
		if open then
			list.Visible = true
			tween(list, {Size = UDim2.new(0.45, 0, 0, #options * 28)}, 0.12)
		else
			close()
		end
	end)

	return container, api
end

-- ======================= TEXT INPUT =================================

function UIComponents.TextInput(parent, placeholder, default, callback)
	local box = Instance.new("TextBox")
	box.Name = "TextInput"
	box.BackgroundColor3 = Theme.Surface
	box.Size = UDim2.new(1, 0, 0, 34)
	box.Font = Theme.Font
	box.TextSize = 14
	box.TextColor3 = Theme.TextPrimary
	box.PlaceholderText = placeholder or ""
	box.PlaceholderColor3 = Theme.TextSecondary
	box.Text = default or ""
	box.ClearTextOnFocus = false
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.Parent = parent
	addCorner(box, UDim.new(0, 6))
	addStroke(box)
	addPadding(box, 8)

	local stroke = box:FindFirstChildOfClass("UIStroke")
	safeConnect(box.Focused, function()
		if stroke then tween(stroke, {Color = Theme.Accent}) end
	end)
	safeConnect(box.FocusLost, function(enterPressed)
		if stroke then tween(stroke, {Color = Theme.Border}) end
		if callback then callback(box.Text, enterPressed) end
	end)

	return box
end



--[[
	HubFramework.lua (ModuleScript)
	Path suggestion: ReplicatedStorage/HubModules/HubFramework

	Builds the draggable main window, sidebar navigation and tab content
	area. Returns an API object used by the LocalScript to register tabs
	and mount content.
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Theme = UIComponents.Theme
local addCorner = UIComponents.AddCorner
local addStroke = UIComponents.AddStroke
local addPadding = UIComponents.AddPadding
local tween = UIComponents.Tween
local safeConnect = UIComponents.SafeConnect

local HubFramework = {}
HubFramework.__index = HubFramework

-- ======================= WINDOW CONSTRUCTION ========================

function HubFramework.new(config)
	config = config or {}
	local self = setmetatable({}, HubFramework)

	self.Name = config.Name or "Universal Hub"
	self.Version = config.Version or "v1.0.0"
	self.Tabs = {}          -- ordered list {Id=, Name=, Icon=, Page=}
	self.TabsById = {}
	self.ActiveTabId = nil

	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	-- Remove any previous instance of this hub (hot-reload safety)
	local existing = playerGui:FindFirstChild("UniversalHubGui")
	if existing then existing:Destroy() end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "UniversalHubGui"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = 100
	screenGui.Parent = playerGui
	self.ScreenGui = screenGui

	-- ---- Main window ----
	local main = Instance.new("Frame")
	main.Name = "MainWindow"
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.Position = UDim2.new(0.5, 0, 0.5, 0)
	main.Size = UDim2.new(0, 620, 0, 420)
	main.BackgroundColor3 = Theme.Background
	main.ClipsDescendants = true
	main.Parent = screenGui
	addCorner(main, UDim.new(0, 12))
	addStroke(main, Theme.Border, 1)
	self.MainWindow = main

	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxassetid://1316045217" -- generic soft shadow asset
	shadow.ImageColor3 = Color3.new(0, 0, 0)
	shadow.ImageTransparency = 0.5
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(10, 10, 118, 118)
	shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	shadow.Position = UDim2.new(0.5, 0, 0.5, 6)
	shadow.Size = UDim2.new(1, 40, 1, 40)
	shadow.ZIndex = main.ZIndex - 1
	shadow.Parent = main

	-- ---- Title bar ----
	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.BackgroundColor3 = Theme.Surface
	titleBar.Size = UDim2.new(1, 0, 0, 40)
	titleBar.Parent = main
	addCorner(titleBar, UDim.new(0, 12))
	-- mask the bottom corners of the title bar so only the top is rounded
	local titleMask = Instance.new("Frame")
	titleMask.BackgroundColor3 = Theme.Surface
	titleMask.BorderSizePixel = 0
	titleMask.Position = UDim2.new(0, 0, 1, -12)
	titleMask.Size = UDim2.new(1, 0, 0, 12)
	titleMask.Parent = titleBar

	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Position = UDim2.new(0, 14, 0, 0)
	titleLabel.Size = UDim2.new(1, -120, 1, 0)
	titleLabel.Font = Theme.FontBold
	titleLabel.TextSize = 15
	titleLabel.TextColor3 = Theme.TextPrimary
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = self.Name .. "  " .. self.Version
	titleLabel.Parent = titleBar

	-- Minimize / close buttons
	local function topButton(offsetX, glyph, hoverColor)
		local b = Instance.new("TextButton")
		b.AnchorPoint = Vector2.new(1, 0.5)
		b.Position = UDim2.new(1, offsetX, 0.5, 0)
		b.Size = UDim2.new(0, 26, 0, 26)
		b.BackgroundColor3 = Theme.SurfaceAlt
		b.AutoButtonColor = false
		b.Font = Theme.FontBold
		b.TextSize = 14
		b.TextColor3 = Theme.TextSecondary
		b.Text = glyph
		b.Parent = titleBar
		addCorner(b, UDim.new(0, 6))
		safeConnect(b.MouseEnter, function() tween(b, {BackgroundColor3 = hoverColor}) end)
		safeConnect(b.MouseLeave, function() tween(b, {BackgroundColor3 = Theme.SurfaceAlt}) end)
		return b
	end

	local closeBtn = topButton(-12, "✕", Theme.Danger)
	local minimizeBtn = topButton(-46, "—", Theme.AccentDim)

	-- ---- Body: sidebar + content ----
	local body = Instance.new("Frame")
	body.Name = "Body"
	body.BackgroundTransparency = 1
	body.Position = UDim2.new(0, 0, 0, 40)
	body.Size = UDim2.new(1, 0, 1, -40)
	body.Parent = main

	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.BackgroundColor3 = Theme.Surface
	sidebar.Size = UDim2.new(0, 150, 1, 0)
	sidebar.Parent = body
	addPadding(sidebar, 10)

	local sideLayout = Instance.new("UIListLayout")
	sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
	sideLayout.Padding = UDim.new(0, 6)
	sideLayout.Parent = sidebar
	self.Sidebar = sidebar

	local contentArea = Instance.new("Frame")
	contentArea.Name = "ContentArea"
	contentArea.BackgroundTransparency = 1
	contentArea.Position = UDim2.new(0, 150, 0, 0)
	contentArea.Size = UDim2.new(1, -150, 1, 0)
	contentArea.Parent = body
	self.ContentArea = contentArea

	-- ---- Dragging ----
	do
		local dragging, dragStart, startPos
		safeConnect(titleBar.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = main.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		safeConnect(UserInputService.InputChanged, function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - dragStart
				main.Position = UDim2.new(
					startPos.X.Scale, startPos.X.Offset + delta.X,
					startPos.Y.Scale, startPos.Y.Offset + delta.Y
				)
			end
		end)
	end

	-- ---- Minimize / close behaviour ----
	local minimized = false
	local fullSize = main.Size
	safeConnect(minimizeBtn.MouseButton1Click, function()
		minimized = not minimized
		if minimized then
			tween(main, {Size = UDim2.new(0, fullSize.X.Offset, 0, 40)}, 0.2)
			body.Visible = false
		else
			body.Visible = true
			tween(main, {Size = fullSize}, 0.2)
		end
	end)

	safeConnect(closeBtn.MouseButton1Click, function()
		tween(main, {Size = UDim2.new(0, 0, 0, 0)}, 0.18)
		task.delay(0.18, function()
			screenGui.Enabled = false
		end)
	end)

	self.Toggle = function()
		screenGui.Enabled = not screenGui.Enabled
	end

	return self
end

-- ======================= TAB MANAGEMENT =============================

function HubFramework:AddTab(id, name)
	assert(id and name, "AddTab requires an id and a display name")
	assert(not self.TabsById[id], "Tab id '" .. id .. "' already exists")

	local index = #self.Tabs + 1

	-- Sidebar button
	local tabBtn = Instance.new("TextButton")
	tabBtn.Name = "Tab_" .. id
	tabBtn.AutoButtonColor = false
	tabBtn.BackgroundColor3 = Theme.Surface
	tabBtn.BackgroundTransparency = 1
	tabBtn.Size = UDim2.new(1, 0, 0, 34)
	tabBtn.Font = Theme.FontMedium
	tabBtn.TextSize = 14
	tabBtn.TextColor3 = Theme.TextSecondary
	tabBtn.TextXAlignment = Enum.TextXAlignment.Left
	tabBtn.Text = "   " .. name
	tabBtn.LayoutOrder = index
	tabBtn.Parent = self.Sidebar
	addCorner(tabBtn, UDim.new(0, 6))

	-- Page (scrolling content frame)
	local page = Instance.new("ScrollingFrame")
	page.Name = "Page_" .. id
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.Size = UDim2.new(1, 0, 1, 0)
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.ScrollBarThickness = 4
	page.ScrollBarImageColor3 = Theme.Border
	page.Visible = false
	page.Parent = self.ContentArea
	addPadding(page, 18)

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 10)
	layout.Parent = page

	local tabData = {Id = id, Name = name, Button = tabBtn, Page = page}
	table.insert(self.Tabs, tabData)
	self.TabsById[id] = tabData

	safeConnect(tabBtn.MouseButton1Click, function()
		self:SelectTab(id)
	end)

	safeConnect(tabBtn.MouseEnter, function()
		if self.ActiveTabId ~= id then
			tween(tabBtn, {BackgroundTransparency = 0.6, TextColor3 = Theme.TextPrimary})
		end
	end)
	safeConnect(tabBtn.MouseLeave, function()
		if self.ActiveTabId ~= id then
			tween(tabBtn, {BackgroundTransparency = 1, TextColor3 = Theme.TextSecondary})
		end
	end)

	-- First tab added becomes active by default
	if not self.ActiveTabId then
		self:SelectTab(id)
	end

	return page
end

function HubFramework:SelectTab(id)
	local tab = self.TabsById[id]
	if not tab then
		warn("[UniversalHub] Attempted to select unknown tab: " .. tostring(id))
		return
	end

	for _, t in ipairs(self.Tabs) do
		local isActive = (t.Id == id)
		t.Page.Visible = isActive
		if isActive then
			tween(t.Button, {BackgroundTransparency = 0, TextColor3 = Theme.TextPrimary, BackgroundColor3 = Theme.SurfaceAlt})
		else
			tween(t.Button, {BackgroundTransparency = 1, TextColor3 = Theme.TextSecondary})
		end
	end

	self.ActiveTabId = id
end



--[[
	HubLoader.client.lua (LocalScript)
	Path suggestion: StarterPlayer/StarterPlayerScripts/HubLoader

	Entry point. Requires the framework + component modules, builds the
	window, registers all six tabs, and wires every control to real
	(local, client-side) behaviour for an experience you own.

	NOTE ON SCOPE: every control below only affects the LocalPlayer's own
	character/camera or purely cosmetic client UI state. There is no
	remote exploitation, no third-party game manipulation, and no
	anti-cheat bypass logic anywhere in this script, per the brief.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- UIComponents and HubFramework are embedded above in this single LocalScript.
local Theme = UIComponents.Theme

-- ======================= BUILD WINDOW ===============================

local Hub = HubFramework.new({
	Name = "Universal Hub",
	Version = "v1.0.0",
})

-- ======================= SETTINGS STATE =============================
-- Centralized, persisted-in-memory settings table. Swap SaveSettings /
-- LoadSettings for DataStore calls if you want cross-session persistence.

local Settings = {
	UIScale = 1,
	AnimationsEnabled = true,
	Theme = "Dark",
	Keybind = "RightControl",
}

local uiScaleInstance = Instance.new("UIScale")
uiScaleInstance.Scale = Settings.UIScale
uiScaleInstance.Parent = Hub.MainWindow

-- ======================= HOME TAB ====================================

do
	local page = Hub:AddTab("home", "Home")

	UIComponents.SectionHeader(page, "Welcome")
	local welcome = UIComponents.InfoCard(
		page,
		"Welcome back, " .. player.Name .. "!",
		"This is your Universal Hub control panel. Use the sidebar to jump between Player, Movement, Visuals, World and Settings."
	)
	welcome.LayoutOrder = 1

	UIComponents.SectionHeader(page, "Status").LayoutOrder = 2

	local statusCard = UIComponents.InfoCard(
		page,
		"Hub Status",
		"All systems operational."
	)
	statusCard.LayoutOrder = 3

	UIComponents.SectionHeader(page, "Features").LayoutOrder = 4

	local features = {
		{"Player Tools", "Walk speed, jump power, health and god mode controls."},
		{"Movement Suite", "Noclip, fly mode, speed presets and jump multiplier."},
		{"Visual Customization", "Fullbright, FOV, fog removal and camera settings."},
		{"World Options", "Time of day, custom skybox tint and render distance."},
	}
	for i, f in ipairs(features) do
		local c = UIComponents.InfoCard(page, f[1], f[2])
		c.LayoutOrder = 4 + i
	end
end

-- ======================= PLAYER TAB ==================================

do
	local page = Hub:AddTab("player", "Player")
	local character, humanoid

	local function getHumanoid()
		character = player.Character or player.CharacterAdded:Wait()
		humanoid = character:WaitForChild("Humanoid")
		return humanoid
	end

	UIComponents.SectionHeader(page, "Movement Stats")

	local walkSpeedRow, walkSpeedApi = UIComponents.Slider(page, "Walk Speed", 16, 200, 16, 0, function(v)
		local hum = getHumanoid()
		hum.WalkSpeed = v
	end)

	local jumpRow, jumpApi = UIComponents.Slider(page, "Jump Power", 50, 300, 50, 0, function(v)
		local hum = getHumanoid()
		hum.UseJumpPower = true
		hum.JumpPower = v
	end)

	-- Keep these sliders honest after a respawn (Humanoid resets to defaults)
	player.CharacterAdded:Connect(function()
		task.wait(1)
		local hum = getHumanoid()
		hum.WalkSpeed = walkSpeedApi:Get()
		hum.UseJumpPower = true
		hum.JumpPower = jumpApi:Get()
	end)

	UIComponents.SectionHeader(page, "Survivability")

	UIComponents.Toggle(page, "God Mode (Max Health + No Fall Damage)", false, function(enabled)
		local hum = getHumanoid()
		if enabled then
			hum.MaxHealth = math.huge
			hum.Health = math.huge
			hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		else
			hum.MaxHealth = 100
			hum.Health = 100
			hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
		end
	end)

	UIComponents.Button(page, "Reset Character", function()
		player:LoadCharacter()
	end)

	UIComponents.SectionHeader(page, "Identity").LayoutOrder = 6
	UIComponents.InfoCard(page, "Player", player.Name .. "  (UserId " .. player.UserId .. ")")
end

-- ======================= MOVEMENT TAB ================================

do
	local page = Hub:AddTab("movement", "Movement")

	local noclipEnabled = false
	local noclipConnection

	local function setNoclip(enabled)
		noclipEnabled = enabled
		if noclipConnection then
			noclipConnection:Disconnect()
			noclipConnection = nil
		end
		if enabled then
			local RunService = game:GetService("RunService")
			-- Stepped (not RenderStepped) covers the physics step even if the
			-- player isn't producing render frames, and re-scanning every
			-- step catches parts added later (tools, accessories, R15 layers).
			noclipConnection = RunService.Stepped:Connect(function()
				local character = player.Character
				if not character then return end
				for _, part in ipairs(character:GetDescendants()) do
					if part:IsA("BasePart") and part.CanCollide then
						part.CanCollide = false
					end
				end
			end)
		else
			local character = player.Character
			if character then
				for _, part in ipairs(character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = true
					end
				end
			end
		end
	end

	UIComponents.SectionHeader(page, "Traversal")

	UIComponents.Toggle(page, "Noclip", false, function(enabled)
		setNoclip(enabled)
	end)

	local flyEnabled = false
	local flyConn, bodyVelocity, bodyGyro

	local function setFly(enabled)
		flyEnabled = enabled
		local character = player.Character
		if not character then return end
		local root = character:FindFirstChild("HumanoidRootPart")
		if not root then return end

		if enabled then
			bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.MaxForce = Vector3.new(1, 1, 1) * math.huge
			bodyVelocity.Velocity = Vector3.new(0, 0, 0)
			bodyVelocity.Parent = root

			local RunService = game:GetService("RunService")
			flyConn = RunService.RenderStepped:Connect(function()
				local camera = workspace.CurrentCamera
				local moveDir = Vector3.new()
				if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += camera.CFrame.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= camera.CFrame.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= camera.CFrame.RightVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += camera.CFrame.RightVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
				if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0, 1, 0) end

				if moveDir.Magnitude > 0 then
					bodyVelocity.Velocity = moveDir.Unit * 60
				else
					bodyVelocity.Velocity = Vector3.new(0, 0, 0)
				end
			end)
		else
			if flyConn then flyConn:Disconnect(); flyConn = nil end
			if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
		end
	end

	UIComponents.Toggle(page, "Fly Mode", false, function(enabled)
		setFly(enabled)
	end)

	UIComponents.SectionHeader(page, "Presets")

	UIComponents.Dropdown(page, "Speed Preset", {"Normal", "Fast", "Very Fast", "Sprint"}, "Normal", function(choice)
		local presets = {Normal = 16, Fast = 32, ["Very Fast"] = 60, Sprint = 100}
		local character = player.Character
		local hum = character and character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = presets[choice] or 16
		end
	end)

	UIComponents.Slider(page, "Jump Multiplier", 1, 5, 1, 1, function(v)
		local character = player.Character
		local hum = character and character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.UseJumpPower = true
			hum.JumpPower = 50 * v
		end
	end)

	-- Keep noclip state correct across respawns
	player.CharacterAdded:Connect(function()
		if noclipEnabled then
			task.wait(0.5)
			setNoclip(true)
		end
	end)
end

-- ======================= VISUALS TAB =================================

do
	local page = Hub:AddTab("visuals", "Visuals")
	local camera = workspace.CurrentCamera

	UIComponents.SectionHeader(page, "Lighting")

	UIComponents.Toggle(page, "Fullbright", false, function(enabled)
		if enabled then
			Lighting.Brightness = 2
			Lighting.ClockTime = 14
			Lighting.FogEnd = 1e9
			Lighting.GlobalShadows = false
		else
			Lighting.Brightness = 1
			Lighting.GlobalShadows = true
		end
	end)

	UIComponents.Toggle(page, "Remove Fog", false, function(enabled)
		Lighting.FogEnd = enabled and 1e9 or 100000
	end)

	UIComponents.SectionHeader(page, "Camera")

	UIComponents.Slider(page, "Field of View", 50, 120, 70, 0, function(v)
		camera.FieldOfView = v
	end)

	-- Roblox's player.CameraMode enum only has two real values: Classic and
	-- LockFirstPerson. There's no built-in "Follow" or "Orbital" camera mode
	-- to switch to, so rather than fake it with a dropdown that silently
	-- does nothing, this is a single honest toggle. A real orbit/follow
	-- camera requires writing your own CameraModule and binding it with
	-- RunService:BindToRenderStep — a legitimate next step if you want one.
	UIComponents.Toggle(page, "First Person Lock", false, function(enabled)
		player.CameraMode = enabled and Enum.CameraMode.LockFirstPerson or Enum.CameraMode.Classic
	end)

	UIComponents.SectionHeader(page, "Effects")
	UIComponents.Toggle(page, "Shift-Lock Enabled", true, function(enabled)
		-- DevEnableMouseLock controls whether the player can use Roblox's
		-- built-in shift-lock camera mode at all.
		player.DevEnableMouseLock = enabled
	end)
end

-- ======================= WORLD TAB ===================================

do
	local page = Hub:AddTab("world", "World")

	UIComponents.SectionHeader(page, "Environment")

	UIComponents.Slider(page, "Time of Day", 0, 24, Lighting.ClockTime, 1, function(v)
		Lighting.ClockTime = v
	end)

	UIComponents.Dropdown(page, "Weather Preset", {"Clear", "Overcast", "Night"}, "Clear", function(choice)
		if choice == "Clear" then
			Lighting.ClockTime = 14
			Lighting.FogEnd = 100000
		elseif choice == "Overcast" then
			Lighting.ClockTime = 13
			Lighting.FogEnd = 500
		elseif choice == "Night" then
			Lighting.ClockTime = 0
			Lighting.FogEnd = 100000
		end
	end)

	UIComponents.SectionHeader(page, "Rendering")

	-- NOTE: StreamingTargetRadius only has an effect if StreamingEnabled is
	-- on for this place (set in Game Settings > Compatibility, or here).
	-- Roblox does not expose a client-side "render distance" beyond streaming
	-- radius; there's no legitimate way to extend draw distance past that.
	UIComponents.Toggle(page, "Enable Streaming", workspace.StreamingEnabled, function(enabled)
		workspace.StreamingEnabled = enabled
	end)

	UIComponents.Slider(page, "Streaming Radius (studs)", 128, 8192, workspace.StreamingTargetRadius or 1024, 0, function(v)
		workspace.StreamingEnabled = true
		workspace.StreamingTargetRadius = v
	end)
end

-- ======================= SETTINGS TAB ================================

do
	local page = Hub:AddTab("settings", "Settings")

	UIComponents.SectionHeader(page, "Appearance")

	UIComponents.Dropdown(page, "UI Theme", {"Dark", "Darker", "Midnight Blue"}, Settings.Theme, function(choice)
		Settings.Theme = choice
		local palettes = {
			Dark = Color3.fromRGB(18, 18, 20),
			Darker = Color3.fromRGB(10, 10, 11),
			["Midnight Blue"] = Color3.fromRGB(14, 16, 26),
		}
		TweenService:Create(Hub.MainWindow, TweenInfo.new(0.2), {
			BackgroundColor3 = palettes[choice] or palettes.Dark
		}):Play()
	end)

	UIComponents.Slider(page, "UI Scale", 0.7, 1.3, 1, 2, function(v)
		Settings.UIScale = v
		uiScaleInstance.Scale = v
	end)

	UIComponents.SectionHeader(page, "Controls")

	local keybindBox = UIComponents.TextInput(page, "e.g. RightControl", Settings.Keybind, function(text)
		local keyEnum = Enum.KeyCode[text]
		if keyEnum then
			Settings.Keybind = text
		else
			warn("[UniversalHub] '" .. text .. "' is not a valid KeyCode name; keybind unchanged.")
		end
	end)

	UIComponents.Toggle(page, "Enable Animations", true, function(enabled)
		Settings.AnimationsEnabled = enabled
		Theme.AnimTime = enabled and 0.18 or 0
	end)

	UIComponents.SectionHeader(page, "Reset")

	UIComponents.Button(page, "Reset UI to Defaults", function()
		Settings.UIScale = 1
		Settings.AnimationsEnabled = true
		Settings.Theme = "Dark"
		Settings.Keybind = "RightControl"
		uiScaleInstance.Scale = 1
		Theme.AnimTime = 0.18
		TweenService:Create(Hub.MainWindow, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(18, 18, 20)
		}):Play()
	end)
end

-- ======================= GLOBAL KEYBIND TOGGLE =======================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	local keyEnum = Enum.KeyCode[Settings.Keybind]
	if keyEnum and input.KeyCode == keyEnum then
		Hub.Toggle()
	end
end)

print("[UniversalHub] Loaded successfully.")