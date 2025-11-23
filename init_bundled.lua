-- UIULib bundled — all modules in one file, ready for loadstring from GitHub
-- No external requires; everything self-contained.

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- =============================================================================
-- STYLES
-- =============================================================================
local Styles = {}
local light = {
	Background = Color3.fromRGB(245, 245, 247),
	Primary = Color3.fromRGB(16, 111, 255),
	Accent = Color3.fromRGB(100, 116, 255),
	Text = Color3.fromRGB(20, 20, 20),
	Muted = Color3.fromRGB(120, 120, 130),
	Transparency = 0.06
}
local dark = {
	Background = Color3.fromRGB(22, 24, 29),
	Primary = Color3.fromRGB(66, 133, 244),
	Accent = Color3.fromRGB(100, 116, 255),
	Text = Color3.fromRGB(230, 230, 235),
	Muted = Color3.fromRGB(160, 160, 170),
	Transparency = 0.12
}
local current = dark

function Styles.SetTheme(name)
	current = name == "Light" and light or dark
end

function Styles.Get(name)
	return current[name]
end

-- =============================================================================
-- UTIL
-- =============================================================================
local Util = {}

function Util.New(class, props)
	props = props or {}
	local ins = Instance.new(class)
	for k, v in pairs(props) do
		pcall(function() ins[k] = v end)
	end
	return ins
end

function Util.Tween(instance, props, opts)
	opts = opts or {Time = 0.25, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out}
	local info = TweenInfo.new(opts.Time, opts.Style, opts.Direction, 0, false, 0)
	local t = TweenService:Create(instance, info, props)
	t:Play()
	return t
end

function Util.MakeDraggable(frame, handle)
	handle = handle or frame
	local dragging, dragStart, startPos
	local conn1, conn2

	local function onInputBegan(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			conn2 = UserInputService.InputChanged:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseMovement and dragging then
					local delta = i.Position - dragStart
					frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
				end
			end)
		end
	end

	local function onInputEnded(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
			if conn2 then conn2:Disconnect(); conn2 = nil end
		end
	end

	conn1 = handle.InputBegan:Connect(onInputBegan)
	handle.InputEnded:Connect(onInputEnded)

	return function()
		if conn1 then conn1:Disconnect(); conn1 = nil end
		if conn2 then conn2:Disconnect(); conn2 = nil end
	end
end

function Util.AddCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = radius or UDim.new(0, 8)
	c.Parent = parent
	return c
end

-- =============================================================================
-- BUTTON
-- =============================================================================
local Button = {}
Button.__index = Button

local function newButton(text, parent)
	local frame = Util.New("Frame", {Parent = parent, Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1})
	local btn = Util.New("TextButton", {Parent = frame, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Styles.Get("Primary"), AutoButtonColor = false, BorderSizePixel = 0, Text = text, TextColor3 = Styles.Get("Text"), Font = Enum.Font.GothamSemibold, TextSize = 14})
	Util.AddCorner(btn, UDim.new(0, 8))
	btn.BackgroundTransparency = 0.05

	local callbacks = {}
	btn.MouseEnter:Connect(function() Util.Tween(btn, {BackgroundTransparency = 0}, {Time = 0.18}) end)
	btn.MouseLeave:Connect(function() Util.Tween(btn, {BackgroundTransparency = 0.05}, {Time = 0.18}) end)
	btn.MouseButton1Click:Connect(function() for _, fn in pairs(callbacks) do pcall(fn) end end)

	local self = setmetatable({}, Button)
	self._frame = frame
	function self:Set(text) btn.Text = text end
	function self:OnChanged(fn) table.insert(callbacks, fn) end
	function self:SetVisible(v) frame.Visible = v and true or false end
	function self:Destroy() frame:Destroy() end
	return self
end

-- =============================================================================
-- TOGGLE
-- =============================================================================
local Toggle = {}
Toggle.__index = Toggle

local function newToggle(label, parent)
	local frame = Util.New("Frame", {Parent = parent, Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1})
	Util.New("TextLabel", {Parent = frame, Size = UDim2.new(1, -60, 1, 0), BackgroundTransparency = 1, Text = label, TextColor3 = Styles.Get("Text"), Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
	local holder = Util.New("Frame", {Parent = frame, Size = UDim2.new(0, 44, 0, 24), Position = UDim2.new(1, -52, 0, 6), BackgroundColor3 = Styles.Get("Background"), BorderSizePixel = 0})
	Util.AddCorner(holder, UDim.new(0, 12))
	local thumb = Util.New("Frame", {Parent = holder, Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0, 3, 0, 3), BackgroundColor3 = Styles.Get("Primary")})
	Util.AddCorner(thumb, UDim.new(0, 9))

	local state = false
	local callbacks = {}

	local function update()
		if state then
			Util.Tween(thumb, {Position = UDim2.new(1, -21, 0, 3)}, {Time = 0.16})
			Util.Tween(holder, {BackgroundTransparency = 0.2}, {Time = 0.16})
		else
			Util.Tween(thumb, {Position = UDim2.new(0, 3, 0, 3)}, {Time = 0.16})
			Util.Tween(holder, {BackgroundTransparency = 0}, {Time = 0.16})
		end
		for _, c in pairs(callbacks) do pcall(c, state) end
	end

	holder.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then state = not state; update() end
	end)

	local self = setmetatable({}, Toggle)
	self._frame = frame
	function self:Set(v) state = not not v; update() end
	function self:OnChanged(fn) table.insert(callbacks, fn) end
	function self:SetVisible(v) frame.Visible = v and true or false end
	function self:Destroy() frame:Destroy() end
	return self
end

-- =============================================================================
-- SLIDER
-- =============================================================================
local Slider = {}
Slider.__index = Slider

local function newSlider(label, parent, min, max)
	min, max = min or 0, max or 100
	local frame = Util.New("Frame", {Parent = parent, Size = UDim2.new(1, 0, 0, 48), BackgroundTransparency = 1})
	Util.New("TextLabel", {Parent = frame, Size = UDim2.new(1, -8, 0, 18), BackgroundTransparency = 1, Text = label, TextColor3 = Styles.Get("Text"), Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
	local bar = Util.New("Frame", {Parent = frame, Size = UDim2.new(1, -8, 0, 8), Position = UDim2.new(0, 8, 0, 28), BackgroundColor3 = Styles.Get("Background"), BorderSizePixel = 0})
	Util.AddCorner(bar, UDim.new(0, 6))
	local fill = Util.New("Frame", {Parent = bar, Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Styles.Get("Primary"), BorderSizePixel = 0})
	Util.AddCorner(fill, UDim.new(0, 6))
	local knob = Util.New("Frame", {Parent = bar, Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, -8, 0.5, -8), BackgroundColor3 = Styles.Get("Accent"), BorderSizePixel = 0})
	Util.AddCorner(knob, UDim.new(0, 8))

	local dragging = false
	local value = min
	local callbacks = {}

	local function setFromX(x)
		local relative = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		value = min + (max - min) * relative
		fill.Size = UDim2.new(relative, 0, 1, 0)
		knob.Position = UDim2.new(relative, -8, 0.5, -8)
		for _, c in pairs(callbacks) do pcall(c, value) end
	end

	knob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
	UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then setFromX(input.Position.X) end end)
	UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
	bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then setFromX(input.Position.X) end end)

	local self = setmetatable({}, Slider)
	self._frame = frame
	function self:Set(v) value = math.clamp(v, min, max); local rel = (value - min) / (max - min); fill.Size = UDim2.new(rel, 0, 1, 0); knob.Position = UDim2.new(rel, -8, 0.5, -8) end
	function self:OnChanged(fn) table.insert(callbacks, fn) end
	function self:SetVisible(v) frame.Visible = v and true or false end
	function self:Destroy() frame:Destroy() end
	return self
end

-- =============================================================================
-- DROPDOWN
-- =============================================================================
local Dropdown = {}
Dropdown.__index = Dropdown

local function newDropdown(label, parent, options)
	options = options or {}
	local frame = Util.New("Frame", {Parent = parent, Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1})
	Util.New("TextLabel", {Parent = frame, Size = UDim2.new(1, -8, 1, 0), BackgroundTransparency = 1, Text = label, TextColor3 = Styles.Get("Text"), Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
	local container = Util.New("Frame", {Parent = frame, Size = UDim2.new(0, 180, 0, 28), Position = UDim2.new(1, -188, 0, 4), BackgroundColor3 = Styles.Get("Background"), BorderSizePixel = 0})
	Util.AddCorner(container, UDim.new(0, 8))
	local title = Util.New("TextLabel", {Parent = container, Size = UDim2.new(1, -28, 1, 0), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1, Text = options[1] or "Select", TextColor3 = Styles.Get("Text"), Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
	local list = Util.New("Frame", {Parent = container, Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 1, 4), BackgroundColor3 = Styles.Get("Background"), BorderSizePixel = 0, ClipsDescendants = true, Visible = false})
	Util.AddCorner(list, UDim.new(0, 8))
	local layout = Util.New("UIListLayout", {Parent = list})
	layout.SortOrder = Enum.SortOrder.LayoutOrder

	local expanded = false
	local callbacks = {}

	local function expand(to)
		expanded = to
		list.Visible = to
		if to then
			Util.Tween(list, {Size = UDim2.new(1, 0, 0, #options * 28)}, {Time = 0.18})
		else
			Util.Tween(list, {Size = UDim2.new(1, 0, 0, 0)}, {Time = 0.12})
			delay(0.18, function() if list then list.Visible = false end end)
		end
	end

	container.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then expand(not expanded) end end)

	for i, opt in ipairs(options) do
		local row = Util.New("TextButton", {Parent = list, Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Text = opt, TextColor3 = Styles.Get("Text"), Font = Enum.Font.Gotham, TextSize = 13})
		row.MouseButton1Click:Connect(function() title.Text = opt; expand(false); for _, c in pairs(callbacks) do pcall(c, opt) end end)
	end

	local self = setmetatable({}, Dropdown)
	self._frame = frame
	function self:Set(v) title.Text = v end
	function self:OnChanged(fn) table.insert(callbacks, fn) end
	function self:SetVisible(v) frame.Visible = v and true or false end
	function self:Destroy() frame:Destroy() end
	return self
end

-- =============================================================================
-- TEXTBOX
-- =============================================================================
local Textbox = {}
Textbox.__index = Textbox

local function newTextbox(label, parent, placeholder)
	local frame = Util.New("Frame", {Parent = parent, Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1})
	Util.New("TextLabel", {Parent = frame, Size = UDim2.new(1, -8, 0, 14), BackgroundTransparency = 1, Text = label, TextColor3 = Styles.Get("Text"), Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
	local box = Util.New("TextBox", {Parent = frame, Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, 16), BackgroundColor3 = Styles.Get("Background"), Text = "", PlaceholderText = placeholder or "", TextColor3 = Styles.Get("Text"), Font = Enum.Font.Gotham, TextSize = 14, ClearTextOnFocus = false})
	Util.AddCorner(box, UDim.new(0, 6))

	local callbacks = {}
	box.FocusLost:Connect(function() for _, c in pairs(callbacks) do pcall(c, box.Text) end end)

	local self = setmetatable({}, Textbox)
	self._frame = frame
	function self:Set(v) box.Text = v end
	function self:OnChanged(fn) table.insert(callbacks, fn) end
	function self:SetVisible(v) frame.Visible = v and true or false end
	function self:Destroy() frame:Destroy() end
	return self
end

-- =============================================================================
-- LABEL
-- =============================================================================
local Label = {}
Label.__index = Label

local function newLabel(text, parent)
	local frame = Util.New("Frame", {Parent = parent, Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1})
	local lbl = Util.New("TextLabel", {Parent = frame, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = text, TextColor3 = Styles.Get("Muted"), Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
	local self = setmetatable({}, Label)
	self._frame = frame
	function self:Set(v) lbl.Text = v end
	function self:OnChanged() end
	function self:SetVisible(v) frame.Visible = v and true or false end
	function self:Destroy() frame:Destroy() end
	return self
end

-- =============================================================================
-- KEYBIND
-- =============================================================================
local Keybind = {}
Keybind.__index = Keybind

local function newKeybind(label, default, parent)
	local frame = Util.New("Frame", {Parent = parent, Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1})
	Util.New("TextLabel", {Parent = frame, Size = UDim2.new(1, -140, 1, 0), BackgroundTransparency = 1, Text = label, TextColor3 = Styles.Get("Text"), Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
	local btn = Util.New("TextButton", {Parent = frame, Size = UDim2.new(0, 120, 0, 28), Position = UDim2.new(1, -124, 0, 4), BackgroundColor3 = Styles.Get("Background"), Text = tostring(default), BorderSizePixel = 0})
	Util.AddCorner(btn, UDim.new(0, 8))

	local bound = default
	local listening = false
	local callbacks = {}

	btn.MouseButton1Click:Connect(function() listening = true; btn.Text = "Press a key..." end)

	local conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if listening and not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
			bound = input.KeyCode.Name
			btn.Text = bound
			for _, c in pairs(callbacks) do pcall(c, bound) end
			listening = false
		end
	end)

	local self = setmetatable({}, Keybind)
	self._frame = frame
	function self:Set(v) bound = v; btn.Text = tostring(v) end
	function self:OnChanged(fn) table.insert(callbacks, fn) end
	function self:SetVisible(v) frame.Visible = v and true or false end
	function self:Destroy() conn:Disconnect(); frame:Destroy() end
	return self
end

-- =============================================================================
-- TAB
-- =============================================================================
local Tab = {}
Tab.__index = Tab

local function newTab(name, tabsHolder, pagesHolder)
	local btn = Util.New("TextButton", {Parent = tabsHolder, Size = UDim2.new(1, -12, 0, 36), BackgroundColor3 = Styles.Get("Background"), BackgroundTransparency = 0.04, BorderSizePixel = 0, Text = name, TextColor3 = Styles.Get("Text"), Font = Enum.Font.Gotham, TextSize = 14})
	Util.AddCorner(btn, UDim.new(0, 8))

	local page = Util.New("Frame", {Parent = pagesHolder, Size = UDim2.new(1, 1, 1, 0), BackgroundTransparency = 1, Visible = false})
	local layout = Util.New("UIListLayout", {Parent = page})
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 8)
	Util.New("UIPadding", {Parent = page, PaddingTop = UDim.new(0, 6), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)})

	btn.MouseButton1Click:Connect(function()
		for _, v in pairs(pagesHolder:GetChildren()) do
			if v:IsA("Frame") and v ~= page then v.Visible = false end
		end
		page.Visible = true
	end)

	local self = setmetatable({}, Tab)
	self._page = page
	self._children = {}

	function self:CreateButton(text, callback) local b = newButton(text, page); if callback then b:OnChanged(callback) end; table.insert(self._children, b); return b end
	function self:CreateToggle(label, init, callback) local c = newToggle(label, page); c:Set(init); if callback then c:OnChanged(callback) end; table.insert(self._children, c); return c end
	function self:CreateSlider(label, min, max, init, callback) local s = newSlider(label, page, min, max); s:Set(init); if callback then s:OnChanged(callback) end; table.insert(self._children, s); return s end
	function self:CreateDropdown(label, options, callback) local d = newDropdown(label, page, options); if callback then d:OnChanged(callback) end; table.insert(self._children, d); return d end
	function self:CreateTextbox(label, placeholder, callback) local t = newTextbox(label, page, placeholder); if callback then t:OnChanged(callback) end; table.insert(self._children, t); return t end
	function self:CreateLabel(text) local l = newLabel(text, page); table.insert(self._children, l); return l end
	function self:CreateKeybind(label, defaultKey, callback) local k = newKeybind(label, defaultKey, page); if callback then k:OnChanged(callback) end; table.insert(self._children, k); return k end

	function self:SetVisible(v) self._page.Visible = v and true or false end
	function self:Destroy() for _, c in pairs(self._children) do pcall(function() c:Destroy() end) end; btn:Destroy(); page:Destroy() end

	return self
end

-- =============================================================================
-- WINDOW
-- =============================================================================
local Window = {}
Window.__index = Window

local function makeWindow(parent, opts)
	opts = opts or {}
	local title = opts.Title or "Window"
	local size = opts.Size or UDim2.fromOffset(600, 420)
	local pos = opts.Position or UDim2.new(0.5, -size.X.Offset / 2, 0.4, -size.Y.Offset / 2)

	local frame = Util.New("Frame", {Name = "UIULib_Window", Parent = parent, Size = size, Position = pos, BackgroundTransparency = 1})
	local bg = Util.New("Frame", {Parent = frame, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Styles.Get("Background"), BackgroundTransparency = Styles.Get("Transparency"), BorderSizePixel = 0, ClipsDescendants = true})
	Util.AddCorner(bg, UDim.new(0, 12))
	local header = Util.New("Frame", {Parent = bg, Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1})
	local titleLabel = Util.New("TextLabel", {Parent = header, Size = UDim2.new(1, -80, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, Text = title, TextColor3 = Styles.Get("Text"), Font = Enum.Font.GothamSemibold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left})
	local btnClose = Util.New("TextButton", {Parent = header, Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, -40, 0, 6), BackgroundTransparency = 1, Text = "✕", TextColor3 = Styles.Get("Muted"), Font = Enum.Font.Gotham, TextSize = 18})
	local container = Util.New("Frame", {Parent = bg, Size = UDim2.new(1, -24, 1, -52), Position = UDim2.new(0, 12, 0, 44), BackgroundTransparency = 1})
	local tabsHolder = Util.New("Frame", {Parent = container, Size = UDim2.new(0, 160, 1, 0), BackgroundTransparency = 1})
	local pagesHolder = Util.New("Frame", {Parent = container, Size = UDim2.new(1, -160, 1, 0), Position = UDim2.new(0, 160, 0, 0), BackgroundTransparency = 1})

	local tabsList = Util.New("UIListLayout", {Parent = tabsHolder})
	tabsList.SortOrder = Enum.SortOrder.LayoutOrder
	tabsList.Padding = UDim.new(0, 6)

	local cleanupDrag = Util.MakeDraggable(frame, header)
	btnClose.MouseButton1Click:Connect(function() frame:Destroy() end)

	local self = setmetatable({}, Window)
	self._frame = frame
	self._tabs = {}
	self._pages = pagesHolder
	self._tabsHolder = tabsHolder

	function self:CreateTab(name) local tab = newTab(name, tabsHolder, pagesHolder); table.insert(self._tabs, tab); return tab end
	function self:SetVisible(v) frame.Visible = v and true or false end
	function self:Destroy() cleanupDrag(); frame:Destroy() end
	function self:SetTitle(t) titleLabel.Text = t end

	return self
end

-- =============================================================================
-- NOTIFICATION
-- =============================================================================
local Notification = {}

local function newNotification(parent)
	local holder = Instance.new("Frame", parent)
	holder.Name = "UIULib_Notifications"
	holder.AnchorPoint = Vector2.new(1, 0)
	holder.Position = UDim2.new(1, -12, 0, 12)
	holder.Size = UDim2.new(0, 300, 0, 100)
	holder.BackgroundTransparency = 1
	holder.ClipsDescendants = true

	local list = Instance.new("UIListLayout", holder)
	list.VerticalAlignment = Enum.VerticalAlignment.Top
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, 8)

	local function notify(text, time)
		time = time or 4
		local card = Instance.new("Frame", holder)
		card.Size = UDim2.new(1, 0, 0, 64)
		card.BackgroundColor3 = Styles.Get("Background")
		card.BackgroundTransparency = Styles.Get("Transparency")
		card.BorderSizePixel = 0
		card.ClipsDescendants = true
		Util.AddCorner(card, UDim.new(0, 8))
		local lbl = Instance.new("TextLabel", card)
		lbl.Size = UDim2.new(1, -12, 1, 0)
		lbl.Position = UDim2.new(0, 8, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = text
		lbl.TextColor3 = Styles.Get("Text")
		lbl.Font = Enum.Font.Gotham
		lbl.TextSize = 14
		card.Position = UDim2.new(1, 320, 0, 0)
		Util.Tween(card, {Position = UDim2.new(0, 0, 0, 0)}, {Time = 0.28})
		delay(time, function()
			pcall(function()
				Util.Tween(card, {Position = UDim2.new(1, 320, 0, 0)}, {Time = 0.22})
				delay(0.25, function() card:Destroy() end)
			end)
		end)
	end

	return {Notify = notify}
end

-- =============================================================================
-- LOADER
-- =============================================================================
local Loader = {}

local function newLoader(parent)
	local frame = Instance.new("Frame", parent)
	frame.Name = "UIULib_Loader"
	frame.AnchorPoint = Vector2.new(0, 1)
	frame.Position = UDim2.new(0, 12, 1, -12)
	frame.Size = UDim2.new(0, 220, 0, 36)
	frame.BackgroundTransparency = 1

	local bg = Instance.new("Frame", frame)
	bg.Size = UDim2.fromScale(1, 1)
	bg.BackgroundColor3 = Styles.Get("Background")
	bg.BackgroundTransparency = Styles.Get("Transparency")
	bg.BorderSizePixel = 0
	Util.AddCorner(bg, UDim.new(0, 8))

	local text = Instance.new("TextLabel", bg)
	text.Size = UDim2.new(1, -12, 1, 0)
	text.Position = UDim2.new(0, 8, 0, 0)
	text.BackgroundTransparency = 1
	text.Text = "UIULib"
	text.Font = Enum.Font.GothamSemibold
	text.TextSize = 14
	text.TextColor3 = Styles.Get("Text")

	return {
		SetVisible = function(v) frame.Visible = v and true or false end,
		SetText = function(t) text.Text = t end,
		Destroy = function() frame:Destroy() end
	}
end

-- =============================================================================
-- MAIN UI EXPORT
-- =============================================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UIULib_ScreenGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 50

local player = Players.LocalPlayer
local parentTarget = player and player:FindFirstChildOfClass("PlayerGui") or game:GetService("CoreGui")
screenGui.Parent = parentTarget

Styles.SetTheme("Dark")

local UI = {}

function UI.SetTheme(name)
	Styles.SetTheme(name)
end

function UI.GetTheme()
	return "Dark"
end

function UI.CreateWindow(opts)
	return makeWindow(screenGui, opts)
end

UI.Notify = newNotification(screenGui)
UI.Loader = newLoader(screenGui)

return UI
