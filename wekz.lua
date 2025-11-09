local FluentHub = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local LucideIcons = {
    Home = "rbxassetid://10723434711",
    Settings = "rbxassetid://10734950309",
    User = "rbxassetid://10734929157",
    Search = "rbxassetid://10734898629",
    Bell = "rbxassetid://10709790948",
    Star = "rbxassetid://10734896629",
    Lock = "rbxassetid://10747372992",
    Unlock = "rbxassetid://10747384394",
    Check = "rbxassetid://10709813281",
    X = "rbxassetid://10747384394",
    Menu = "rbxassetid://10723407389",
    ChevronRight = "rbxassetid://10709818534",
    ChevronDown = "rbxassetid://10709818534",
    Info = "rbxassetid://10723434711",
    CheckCircle = "rbxassetid://10709814152",
    AlertTriangle = "rbxassetid://10709761369",
    XCircle = "rbxassetid://10734896853",
    Box = "rbxassetid://10723340592",
    Zap = "rbxassetid://10747372992",
    Target = "rbxassetid://10723434711",
    Shield = "rbxassetid://10723407389",
    Eye = "rbxassetid://10734896629",
    Crosshair = "rbxassetid://10723434711",
    Grid = "rbxassetid://10723407389"
}

local Colors = {
    Background = Color3.fromRGB(26, 26, 26),
    Surface = Color3.fromRGB(35, 35, 35),
    SurfaceHover = Color3.fromRGB(45, 45, 45),
    Primary = Color3.fromRGB(88, 101, 242),
    PrimaryHover = Color3.fromRGB(108, 121, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    TextTertiary = Color3.fromRGB(120, 120, 120),
    Border = Color3.fromRGB(50, 50, 50),
    Success = Color3.fromRGB(67, 181, 129),
    Warning = Color3.fromRGB(250, 166, 26),
    Error = Color3.fromRGB(237, 66, 69),
    Info = Color3.fromRGB(88, 101, 242)
}

local Utility = {}
local ConnectionTracker = {}

function ConnectionTracker:New()
    local tracker = {_connections = {}}
    setmetatable(tracker, {__index = self})
    return tracker
end

function ConnectionTracker:Add(connection)
    table.insert(self._connections, connection)
    return connection
end

function ConnectionTracker:DisconnectAll()
    for _, conn in ipairs(self._connections) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end
    self._connections = {}
end

function Utility:Tween(instance, properties, duration, style, direction)
    local info = TweenInfo.new(
        duration or 0.2,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

function Utility:CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 4)
    corner.Parent = parent
    return corner
end

function Utility:CreateStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Colors.Border
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

function Utility:CreateIcon(parent, iconId, size)
    local icon = Instance.new("ImageLabel")
    icon.Size = size or UDim2.new(1, 0, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Image = iconId
    icon.ImageColor3 = Colors.TextSecondary
    icon.Parent = parent
    return icon
end

function Utility:CreatePadding(parent, values)
    local padding = Instance.new("UIPadding")
    if type(values) == "number" then
        padding.PaddingTop = UDim.new(0, values)
        padding.PaddingBottom = UDim.new(0, values)
        padding.PaddingLeft = UDim.new(0, values)
        padding.PaddingRight = UDim.new(0, values)
    else
        padding.PaddingTop = UDim.new(0, values.Top or 0)
        padding.PaddingBottom = UDim.new(0, values.Bottom or 0)
        padding.PaddingLeft = UDim.new(0, values.Left or 0)
        padding.PaddingRight = UDim.new(0, values.Right or 0)
    end
    padding.Parent = parent
    return padding
end

function Utility:CreateListLayout(parent, padding, alignment, direction)
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, padding or 6)
    layout.FillDirection = direction or Enum.FillDirection.Vertical
    if alignment then layout.VerticalAlignment = alignment end
    layout.Parent = parent
    return layout
end

function Utility:CreateGridLayout(parent, cellSize, cellPadding)
    local grid = Instance.new("UIGridLayout")
    grid.CellSize = cellSize or UDim2.new(0.48, 0, 0, 40)
    grid.CellPadding = cellPadding or UDim2.new(0.02, 0, 0, 8)
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.Parent = parent
    return grid
end

function Utility:MakeDraggable(frame, connections)
    local dragging, dragInput, dragStart, startPos
    
    connections:Add(frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end))
    
    connections:Add(frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end))
    
    connections:Add(UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end))
end

function FluentHub:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Title or "Karpinware"
    local windowSize = config.Size or UDim2.new(0, 700, 0, 500)
    local windowConnections = ConnectionTracker:New()
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FluentHub_" .. HttpService:GenerateGUID(false)
    screenGui.Parent = CoreGui
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Colors.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = false
    mainFrame.Parent = screenGui
    Utility:CreateCorner(mainFrame, 8)
    Utility:CreateStroke(mainFrame, Colors.Border, 1)
    
    Utility:MakeDraggable(mainFrame, windowConnections)
    
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = Colors.Surface
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    Utility:CreateCorner(header, 8)
    
    local headerMask = Instance.new("Frame")
    headerMask.Size = UDim2.new(1, 0, 0, 20)
    headerMask.Position = UDim2.new(0, 0, 1, -20)
    headerMask.BackgroundColor3 = Colors.Surface
    headerMask.BorderSizePixel = 0
    headerMask.Parent = header
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0, 200, 1, 0)
    titleLabel.Position = UDim2.new(0, 45, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = windowTitle
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextColor3 = Colors.Text
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header
    
    local versionLabel = Instance.new("TextLabel")
    versionLabel.Size = UDim2.new(0, 100, 1, 0)
    versionLabel.Position = UDim2.new(0, 145, 0, 0)
    versionLabel.BackgroundTransparency = 1
    versionLabel.Text = "6.1.0"
    versionLabel.Font = Enum.Font.Gotham
    versionLabel.TextSize = 12
    versionLabel.TextColor3 = Colors.TextTertiary
    versionLabel.TextXAlignment = Enum.TextXAlignment.Left
    versionLabel.Parent = header
    
    local logoFrame = Instance.new("Frame")
    logoFrame.Size = UDim2.new(0, 24, 0, 24)
    logoFrame.Position = UDim2.new(0, 12, 0.5, -12)
    logoFrame.BackgroundColor3 = Colors.Primary
    logoFrame.BackgroundTransparency = 0.85
    logoFrame.BorderSizePixel = 0
    logoFrame.Parent = header
    Utility:CreateCorner(logoFrame, 6)
    
    local logoIcon = Utility:CreateIcon(logoFrame, LucideIcons.Box)
    logoIcon.ImageColor3 = Colors.Primary
    Utility:CreatePadding(logoFrame, 4)
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 28, 0, 28)
    closeButton.Position = UDim2.new(1, -38, 0.5, -14)
    closeButton.BackgroundColor3 = Colors.Surface
    closeButton.BackgroundTransparency = 1
    closeButton.Text = ""
    closeButton.AutoButtonColor = false
    closeButton.Parent = header
    Utility:CreateCorner(closeButton, 4)
    
    local closeIcon = Utility:CreateIcon(closeButton, LucideIcons.X)
    Utility:CreatePadding(closeButton, 6)
    
    windowConnections:Add(closeButton.MouseButton1Click:Connect(function()
        Utility:Tween(mainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
        task.wait(0.2)
        windowConnections:DisconnectAll()
        screenGui:Destroy()
    end))
    
    windowConnections:Add(closeButton.MouseEnter:Connect(function()
        Utility:Tween(closeButton, {BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(237, 66, 69)})
        closeIcon.ImageColor3 = Colors.Text
    end))
    
    windowConnections:Add(closeButton.MouseLeave:Connect(function()
        Utility:Tween(closeButton, {BackgroundTransparency = 1})
        closeIcon.ImageColor3 = Colors.TextSecondary
    end))
    
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(1, 0, 1, -40)
    container.Position = UDim2.new(0, 0, 0, 40)
    container.BackgroundTransparency = 1
    container.Parent = mainFrame
    
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 180, 1, 0)
    sidebar.BackgroundColor3 = Colors.Surface
    sidebar.BorderSizePixel = 0
    sidebar.Parent = container
    
    local sidebarContent = Instance.new("Frame")
    sidebarContent.Size = UDim2.new(1, 0, 1, -60)
    sidebarContent.BackgroundTransparency = 1
    sidebarContent.Parent = sidebar
    
    Utility:CreateListLayout(sidebarContent, 2)
    Utility:CreatePadding(sidebarContent, {Top = 8, Bottom = 8, Left = 8, Right = 8})
    
    local userProfile = Instance.new("Frame")
    userProfile.Name = "UserProfile"
    userProfile.Size = UDim2.new(1, 0, 0, 50)
    userProfile.Position = UDim2.new(0, 0, 1, -50)
    userProfile.BackgroundColor3 = Colors.Background
    userProfile.BorderSizePixel = 0
    userProfile.Parent = sidebar
    
    local profileDivider = Instance.new("Frame")
    profileDivider.Size = UDim2.new(1, 0, 0, 1)
    profileDivider.BackgroundColor3 = Colors.Border
    profileDivider.BorderSizePixel = 0
    profileDivider.Parent = userProfile
    
    local profileIcon = Instance.new("Frame")
    profileIcon.Size = UDim2.new(0, 32, 0, 32)
    profileIcon.Position = UDim2.new(0, 10, 0.5, -16)
    profileIcon.BackgroundColor3 = Colors.Primary
    profileIcon.BorderSizePixel = 0
    profileIcon.Parent = userProfile
    Utility:CreateCorner(profileIcon, 16)
    
    local profileImage = Utility:CreateIcon(profileIcon, LucideIcons.User)
    profileImage.ImageColor3 = Colors.Text
    Utility:CreatePadding(profileIcon, 6)
    
    local localPlayer = Players.LocalPlayer
    local profileName = Instance.new("TextLabel")
    profileName.Size = UDim2.new(1, -90, 0, 14)
    profileName.Position = UDim2.new(0, 48, 0.5, -7)
    profileName.BackgroundTransparency = 1
    profileName.Text = localPlayer and localPlayer.Name or "Player"
    profileName.Font = Enum.Font.GothamMedium
    profileName.TextSize = 12
    profileName.TextColor3 = Colors.Text
    profileName.TextXAlignment = Enum.TextXAlignment.Left
    profileName.TextTruncate = Enum.TextTruncate.AtEnd
    profileName.Parent = userProfile
    
    local profileSettings = Instance.new("TextButton")
    profileSettings.Size = UDim2.new(0, 24, 0, 24)
    profileSettings.Position = UDim2.new(1, -34, 0.5, -12)
    profileSettings.BackgroundTransparency = 1
    profileSettings.Text = ""
    profileSettings.AutoButtonColor = false
    profileSettings.Parent = userProfile
    Utility:CreateCorner(profileSettings, 4)
    
    local settingsIcon = Utility:CreateIcon(profileSettings, LucideIcons.Settings, UDim2.new(0, 16, 0, 16))
    settingsIcon.Position = UDim2.new(0.5, -8, 0.5, -8)
    
    windowConnections:Add(profileSettings.MouseEnter:Connect(function()
        Utility:Tween(profileSettings, {BackgroundTransparency = 0, BackgroundColor3 = Colors.SurfaceHover})
    end))
    
    windowConnections:Add(profileSettings.MouseLeave:Connect(function()
        Utility:Tween(profileSettings, {BackgroundTransparency = 1})
    end))
    
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -180, 1, 0)
    contentFrame.Position = UDim2.new(0, 180, 0, 0)
    contentFrame.BackgroundColor3 = Colors.Background
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = 4
    contentFrame.ScrollBarImageColor3 = Colors.Border
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentFrame.Parent = container
    
    Utility:CreatePadding(contentFrame, {Top = 12, Bottom = 12, Left = 12, Right = 12})
    
    local tabs = {}
    local currentTab = nil
    
    local Window = {}
    
    local notificationContainer = Instance.new("Frame")
    notificationContainer.Name = "Notifications"
    notificationContainer.Size = UDim2.new(0, 320, 1, -20)
    notificationContainer.Position = UDim2.new(1, -340, 0, 20)
    notificationContainer.BackgroundTransparency = 1
    notificationContainer.Parent = screenGui
    notificationContainer.ZIndex = 100
    
    Utility:CreateListLayout(notificationContainer, 10, Enum.VerticalAlignment.Bottom)
    
    function Window:CreateNotification(config)
        config = config or {}
        local title = config.Title or "Notification"
        local message = config.Message or ""
        local duration = config.Duration or 4
        local notifType = config.Type or "Info"
        
        local typeConfig = {
            Info = {Color = Colors.Info, Icon = LucideIcons.Info},
            Success = {Color = Colors.Success, Icon = LucideIcons.CheckCircle},
            Warning = {Color = Colors.Warning, Icon = LucideIcons.AlertTriangle},
            Error = {Color = Colors.Error, Icon = LucideIcons.XCircle}
        }
        
        local cfg = typeConfig[notifType] or typeConfig.Info
        
        local notification = Instance.new("Frame")
        notification.Size = UDim2.new(1, 0, 0, 68)
        notification.BackgroundColor3 = Colors.Surface
        notification.BorderSizePixel = 0
        notification.Parent = notificationContainer
        Utility:CreateCorner(notification, 6)
        Utility:CreateStroke(notification, Colors.Border, 1)
        
        local accentBar = Instance.new("Frame")
        accentBar.Size = UDim2.new(0, 3, 1, 0)
        accentBar.BackgroundColor3 = cfg.Color
        accentBar.BorderSizePixel = 0
        accentBar.Parent = notification
        
        local iconFrame = Instance.new("Frame")
        iconFrame.Size = UDim2.new(0, 36, 0, 36)
        iconFrame.Position = UDim2.new(0, 14, 0, 16)
        iconFrame.BackgroundColor3 = cfg.Color
        iconFrame.BackgroundTransparency = 0.9
        iconFrame.BorderSizePixel = 0
        iconFrame.Parent = notification
        Utility:CreateCorner(iconFrame, 6)
        
        local icon = Utility:CreateIcon(iconFrame, cfg.Icon)
        icon.ImageColor3 = cfg.Color
        Utility:CreatePadding(iconFrame, 8)
        
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -98, 0, 18)
        titleLabel.Position = UDim2.new(0, 58, 0, 14)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextSize = 13
        titleLabel.TextColor3 = Colors.Text
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
        titleLabel.Parent = notification
        
        local messageLabel = Instance.new("TextLabel")
        messageLabel.Size = UDim2.new(1, -98, 0, 16)
        messageLabel.Position = UDim2.new(0, 58, 0, 34)
        messageLabel.BackgroundTransparency = 1
        messageLabel.Text = message
        messageLabel.Font = Enum.Font.Gotham
        messageLabel.TextSize = 11
        messageLabel.TextColor3 = Colors.TextSecondary
        messageLabel.TextXAlignment = Enum.TextXAlignment.Left
        messageLabel.TextTruncate = Enum.TextTruncate.AtEnd
        messageLabel.Parent = notification
        
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 24, 0, 24)
        closeBtn.Position = UDim2.new(1, -32, 0, 8)
        closeBtn.BackgroundTransparency = 1
        closeBtn.Text = ""
        closeBtn.AutoButtonColor = false
        closeBtn.Parent = notification
        Utility:CreateCorner(closeBtn, 4)
        
        local closeIcon = Utility:CreateIcon(closeBtn, LucideIcons.X, UDim2.new(0, 14, 0, 14))
        closeIcon.Position = UDim2.new(0.5, -7, 0.5, -7)
        
        local progressBar = Instance.new("Frame")
        progressBar.Size = UDim2.new(1, 0, 0, 2)
        progressBar.Position = UDim2.new(0, 0, 1, -2)
        progressBar.BackgroundColor3 = cfg.Color
        progressBar.BorderSizePixel = 0
        progressBar.Parent = notification
        
        local function closeNotification()
            Utility:Tween(notification, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, 0.2)
            task.wait(0.2)
            notification:Destroy()
        end
        
        closeBtn.MouseButton1Click:Connect(closeNotification)
        
        closeBtn.MouseEnter:Connect(function()
            Utility:Tween(closeBtn, {BackgroundTransparency = 0, BackgroundColor3 = Colors.SurfaceHover})
        end)
        
        closeBtn.MouseLeave:Connect(function()
            Utility:Tween(closeBtn, {BackgroundTransparency = 1})
        end)
        
        task.spawn(function()
            Utility:Tween(progressBar, {Size = UDim2.new(0, 0, 0, 2)}, duration, Enum.EasingStyle.Linear)
            task.wait(duration)
            closeNotification()
        end)
    end
    
    function Window:CreateTab(config)
        config = config or {}
        local tabName = config.Name or "Tab"
        local tabIcon = config.Icon or LucideIcons.Home
        local tabConnections = ConnectionTracker:New()
        
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tabName
        tabButton.Size = UDim2.new(1, 0, 0, 32)
        tabButton.BackgroundColor3 = Colors.Background
        tabButton.BackgroundTransparency = 1
        tabButton.Text = ""
        tabButton.AutoButtonColor = false
        tabButton.Parent = sidebarContent
        Utility:CreateCorner(tabButton, 4)
        
        local iconFrame = Instance.new("Frame")
        iconFrame.Size = UDim2.new(0, 18, 0, 18)
        iconFrame.Position = UDim2.new(0, 8, 0.5, -9)
        iconFrame.BackgroundTransparency = 1
        iconFrame.Parent = tabButton
        
        local tabIconImg = Utility:CreateIcon(iconFrame, tabIcon)
        
        local tabLabel = Instance.new("TextLabel")
        tabLabel.Size = UDim2.new(1, -34, 1, 0)
        tabLabel.Position = UDim2.new(0, 32, 0, 0)
        tabLabel.BackgroundTransparency = 1
        tabLabel.Text = tabName
        tabLabel.Font = Enum.Font.GothamMedium
        tabLabel.TextSize = 12
        tabLabel.TextColor3 = Colors.TextSecondary
        tabLabel.TextXAlignment = Enum.TextXAlignment.Left
        tabLabel.Parent = tabButton
        
        local tabContent = Instance.new("Frame")
        tabContent.Name = tabName .. "Content"
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.Visible = false
        tabContent.Parent = contentFrame
        
        local contentList = Utility:CreateGridLayout(tabContent, UDim2.new(0.48, 0, 0, 40), UDim2.new(0.02, 0, 0, 8))
        
        local function SelectTab()
            for _, tab in pairs(tabs) do
                Utility:Tween(tab.Button, {BackgroundTransparency = 1})
                Utility:Tween(tab.Label, {TextColor3 = Colors.TextSecondary})
                tab.Icon.ImageColor3 = Colors.TextSecondary
                tab.Content.Visible = false
            end
            
            Utility:Tween(tabButton, {BackgroundTransparency = 0})
            Utility:Tween(tabLabel, {TextColor3 = Colors.Text})
            tabIconImg.ImageColor3 = Colors.Primary
            tabContent.Visible = true
            currentTab = tabContent
        end
        
        tabConnections:Add(tabButton.MouseButton1Click:Connect(SelectTab))
        
        tabConnections:Add(tabButton.MouseEnter:Connect(function()
            if currentTab ~= tabContent then
                Utility:Tween(tabButton, {BackgroundTransparency = 0.5})
            end
        end))
        
        tabConnections:Add(tabButton.MouseLeave:Connect(function()
            if currentTab ~= tabContent then
                Utility:Tween(tabButton, {BackgroundTransparency = 1})
            end
        end))
        
        local Tab = {
            Button = tabButton,
            Label = tabLabel,
            Icon = tabIconImg,
            Content = tabContent,
            Connections = tabConnections
        }
        
        table.insert(tabs, Tab)
        
        if #tabs == 1 then
            SelectTab()
        end
        
        function Tab:CreateSection(title)
            local sectionFrame = Instance.new("Frame")
            sectionFrame.Size = UDim2.new(1, 0, 0, 28)
            sectionFrame.BackgroundTransparency = 1
            sectionFrame.LayoutOrder = -1000
            sectionFrame.Parent = tabContent
            
            local sectionLabel = Instance.new("TextLabel")
            sectionLabel.Size = UDim2.new(1, 0, 1, 0)
            sectionLabel.BackgroundTransparency = 1
            sectionLabel.Text = title
            sectionLabel.Font = Enum.Font.GothamBold
            sectionLabel.TextSize = 12
            sectionLabel.TextColor3 = Colors.TextSecondary
            sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            sectionLabel.TextYAlignment = Enum.TextYAlignment.Bottom
            sectionLabel.Parent = sectionFrame
            
            return sectionFrame
        end
        
        function Tab:CreateButton(config)
            config = config or {}
            local buttonName = config.Name or "Button"
            local buttonCallback = config.Callback or function() end
            
            local buttonFrame = Instance.new("Frame")
            buttonFrame.Size = UDim2.new(0, 0, 0, 36)
            buttonFrame.BackgroundColor3 = Colors.Surface
            buttonFrame.BorderSizePixel = 0
            buttonFrame.Parent = tabContent
            Utility:CreateCorner(buttonFrame, 4)
            
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(1, 0, 1, 0)
            button.BackgroundTransparency = 1
            button.Text = ""
            button.AutoButtonColor = false
            button.Parent = buttonFrame
            
            local buttonLabel = Instance.new("TextLabel")
            buttonLabel.Size = UDim2.new(1, -40, 1, 0)
            buttonLabel.Position = UDim2.new(0, 10, 0, 0)
            buttonLabel.BackgroundTransparency = 1
            buttonLabel.Text = buttonName
            buttonLabel.Font = Enum.Font.GothamMedium
            buttonLabel.TextSize = 12
            buttonLabel.TextColor3 = Colors.Text
            buttonLabel.TextXAlignment = Enum.TextXAlignment.Left
            buttonLabel.Parent = buttonFrame
            
            local chevronFrame = Instance.new("Frame")
            chevronFrame.Size = UDim2.new(0, 14, 0, 14)
            chevronFrame.Position = UDim2.new(1, -22, 0.5, -7)
            chevronFrame.BackgroundTransparency = 1
            chevronFrame.Parent = buttonFrame
            
            local chevronIcon = Utility:CreateIcon(chevronFrame, LucideIcons.ChevronRight)
            
            tabConnections:Add(button.MouseButton1Click:Connect(function()
                Utility:Tween(buttonFrame, {BackgroundColor3 = Colors.Primary}, 0.1)
                task.wait(0.1)
                Utility:Tween(buttonFrame, {BackgroundColor3 = Colors.Surface}, 0.1)
                task.spawn(buttonCallback)
            end))
            
            tabConnections:Add(button.MouseEnter:Connect(function()
                Utility:Tween(buttonFrame, {BackgroundColor3 = Colors.SurfaceHover})
            end))
            
            tabConnections:Add(button.MouseLeave:Connect(function()
                Utility:Tween(buttonFrame, {BackgroundColor3 = Colors.Surface})
            end))
            
            return buttonFrame
        end
        
        function Tab:CreateToggle(config)
            config = config or {}
            local toggleName = config.Name or "Toggle"
            local toggleDefault = config.Default or false
            local toggleCallback = config.Callback or function() end
            
            local toggleFrame = Instance.new("Frame")
            toggleFrame.Size = UDim2.new(0, 0, 0, 36)
            toggleFrame.BackgroundColor3 = Colors.Surface
            toggleFrame.BorderSizePixel = 0
            toggleFrame.Parent = tabContent
            Utility:CreateCorner(toggleFrame, 4)
            
            local toggleLabel = Instance.new("TextLabel")
            toggleLabel.Size = UDim2.new(1, -58, 1, 0)
            toggleLabel.Position = UDim2.new(0, 10, 0, 0)
            toggleLabel.BackgroundTransparency = 1
            toggleLabel.Text = toggleName
            toggleLabel.Font = Enum.Font.GothamMedium
            toggleLabel.TextSize = 12
            toggleLabel.TextColor3 = Colors.Text
            toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            toggleLabel.Parent = toggleFrame
            
            local toggleButton = Instance.new("TextButton")
            toggleButton.Size = UDim2.new(0, 40, 0, 20)
            toggleButton.Position = UDim2.new(1, -48, 0.5, -10)
            toggleButton.BackgroundColor3 = Colors.Background
            toggleButton.Text = ""
            toggleButton.AutoButtonColor = false
            toggleButton.Parent = toggleFrame
            Utility:CreateCorner(toggleButton, 10)
            
            local toggleCircle = Instance.new("Frame")
            toggleCircle.Size = UDim2.new(0, 16, 0, 16)
            toggleCircle.Position = UDim2.new(0, 2, 0.5, -8)
            toggleCircle.BackgroundColor3 = Colors.TextTertiary
            toggleCircle.BorderSizePixel = 0
            toggleCircle.Parent = toggleButton
            Utility:CreateCorner(toggleCircle, 8)
            
            local isToggled = toggleDefault
            
            local function UpdateToggle(instant)
                local duration = instant and 0 or 0.2
                if isToggled then
                    Utility:Tween(toggleButton, {BackgroundColor3 = Colors.Primary}, duration)
                    Utility:Tween(toggleCircle, {
                        Position = UDim2.new(0, 22, 0.5, -8),
                        BackgroundColor3 = Colors.Text
                    }, duration)
                else
                    Utility:Tween(toggleButton, {BackgroundColor3 = Colors.Background}, duration)
                    Utility:Tween(toggleCircle, {
                        Position = UDim2.new(0, 2, 0.5, -8),
                        BackgroundColor3 = Colors.TextTertiary
                    }, duration)
                end
                task.spawn(toggleCallback, isToggled)
            end
            
            tabConnections:Add(toggleButton.MouseButton1Click:Connect(function()
                isToggled = not isToggled
                UpdateToggle()
            end))
            
            UpdateToggle(true)
            
            return toggleFrame
        end
        
        function Tab:CreateSlider(config)
            config = config or {}
            local sliderName = config.Name or "Slider"
            local sliderMin = config.Min or 0
            local sliderMax = config.Max or 100
            local sliderDefault = config.Default or 50
            local sliderIncrement = config.Increment or 1
            local sliderCallback = config.Callback or function() end
            local sliderSuffix = config.Suffix or "%"
            
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Size = UDim2.new(0, 0, 0, 48)
            sliderFrame.BackgroundColor3 = Colors.Surface
            sliderFrame.BorderSizePixel = 0
            sliderFrame.Parent = tabContent
            Utility:CreateCorner(sliderFrame, 4)
            
            local sliderLabel = Instance.new("TextLabel")
            sliderLabel.Size = UDim2.new(0.6, 0, 0, 18)
            sliderLabel.Position = UDim2.new(0, 10, 0, 8)
            sliderLabel.BackgroundTransparency = 1
            sliderLabel.Text = sliderName
            sliderLabel.Font = Enum.Font.GothamMedium
            sliderLabel.TextSize = 12
            sliderLabel.TextColor3 = Colors.Text
            sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            sliderLabel.Parent = sliderFrame
            
            local valueDisplay = Instance.new("Frame")
            valueDisplay.Size = UDim2.new(0, 44, 0, 18)
            valueDisplay.Position = UDim2.new(1, -52, 0, 8)
            valueDisplay.BackgroundColor3 = Colors.Background
            valueDisplay.BorderSizePixel = 0
            valueDisplay.Parent = sliderFrame
            Utility:CreateCorner(valueDisplay, 4)
            
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(1, 0, 1, 0)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = tostring(sliderDefault) .. sliderSuffix
            valueLabel.Font = Enum.Font.GothamBold
            valueLabel.TextSize = 11
            valueLabel.TextColor3 = Colors.TextSecondary
            valueLabel.Parent = valueDisplay
            
            local sliderTrack = Instance.new("Frame")
            sliderTrack.Size = UDim2.new(1, -20, 0, 4)
            sliderTrack.Position = UDim2.new(0, 10, 1, -14)
            sliderTrack.BackgroundColor3 = Colors.Background
            sliderTrack.BorderSizePixel = 0
            sliderTrack.Parent = sliderFrame
            Utility:CreateCorner(sliderTrack, 2)
            
            local sliderFill = Instance.new("Frame")
            sliderFill.Size = UDim2.new((sliderDefault - sliderMin) / (sliderMax - sliderMin), 0, 1, 0)
            sliderFill.BackgroundColor3 = Colors.Primary
            sliderFill.BorderSizePixel = 0
            sliderFill.Parent = sliderTrack
            Utility:CreateCorner(sliderFill, 2)
            
            local sliderThumb = Instance.new("Frame")
            sliderThumb.Size = UDim2.new(0, 10, 0, 10)
            sliderThumb.Position = UDim2.new((sliderDefault - sliderMin) / (sliderMax - sliderMin), -5, 0.5, -5)
            sliderThumb.BackgroundColor3 = Colors.Text
            sliderThumb.BorderSizePixel = 0
            sliderThumb.ZIndex = 2
            sliderThumb.Parent = sliderTrack
            Utility:CreateCorner(sliderThumb, 5)
            
            local sliderButton = Instance.new("TextButton")
            sliderButton.Size = UDim2.new(1, 0, 1, 8)
            sliderButton.Position = UDim2.new(0, 0, 0, -4)
            sliderButton.BackgroundTransparency = 1
            sliderButton.Text = ""
            sliderButton.AutoButtonColor = false
            sliderButton.Parent = sliderTrack
            
            local draggingSlider = false
            
            local function UpdateSlider(input)
                local pos = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
                local rawValue = sliderMin + (sliderMax - sliderMin) * pos
                local value = math.floor(rawValue / sliderIncrement + 0.5) * sliderIncrement
                value = math.clamp(value, sliderMin, sliderMax)
                
                sliderFill.Size = UDim2.new((value - sliderMin) / (sliderMax - sliderMin), 0, 1, 0)
                sliderThumb.Position = UDim2.new((value - sliderMin) / (sliderMax - sliderMin), -5, 0.5, -5)
                valueLabel.Text = tostring(value) .. sliderSuffix
                task.spawn(sliderCallback, value)
            end
            
            tabConnections:Add(sliderButton.MouseButton1Down:Connect(function()
                draggingSlider = true
                Utility:Tween(sliderThumb, {Size = UDim2.new(0, 12, 0, 12)}, 0.1)
            end))
            
            tabConnections:Add(UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = false
                    Utility:Tween(sliderThumb, {Size = UDim2.new(0, 10, 0, 10)}, 0.1)
                end
            end))
            
            tabConnections:Add(UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                    UpdateSlider(input)
                end
            end))
            
            tabConnections:Add(sliderButton.MouseEnter:Connect(function()
                if not draggingSlider then
                    Utility:Tween(sliderThumb, {Size = UDim2.new(0, 12, 0, 12)}, 0.1)
                end
            end))
            
            tabConnections:Add(sliderButton.MouseLeave:Connect(function()
                if not draggingSlider then
                    Utility:Tween(sliderThumb, {Size = UDim2.new(0, 10, 0, 10)}, 0.1)
                end
            end))
            
            return sliderFrame
        end
        
        function Tab:CreateDropdown(config)
            config = config or {}
            local dropdownName = config.Name or "Dropdown"
            local dropdownOptions = config.Options or {"Option 1", "Option 2", "Option 3"}
            local dropdownDefault = config.Default or dropdownOptions[1]
            local dropdownCallback = config.Callback or function() end
            local dropdownIcon = config.Icon
            
            local isOpen = false
            local currentValue = dropdownDefault
            
            local dropdownFrame = Instance.new("Frame")
            dropdownFrame.Size = UDim2.new(0, 0, 0, 36)
            dropdownFrame.BackgroundColor3 = Colors.Surface
            dropdownFrame.BorderSizePixel = 0
            dropdownFrame.Parent = tabContent
            dropdownFrame.ClipsDescendants = false
            dropdownFrame.ZIndex = 2
            Utility:CreateCorner(dropdownFrame, 4)
            
            local dropdownButton = Instance.new("TextButton")
            dropdownButton.Size = UDim2.new(1, 0, 0, 36)
            dropdownButton.BackgroundTransparency = 1
            dropdownButton.Text = ""
            dropdownButton.AutoButtonColor = false
            dropdownButton.ZIndex = 3
            dropdownButton.Parent = dropdownFrame
            
            local dropdownLabel = Instance.new("TextLabel")
            dropdownLabel.Size = UDim2.new(1, -40, 0, 14)
            dropdownLabel.Position = UDim2.new(0, 10, 0, 4)
            dropdownLabel.BackgroundTransparency = 1
            dropdownLabel.Text = dropdownName
            dropdownLabel.Font = Enum.Font.Gotham
            dropdownLabel.TextSize = 10
            dropdownLabel.TextColor3 = Colors.TextTertiary
            dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
            dropdownLabel.ZIndex = 3
            dropdownLabel.Parent = dropdownFrame
            
            local selectedLabel = Instance.new("TextLabel")
            selectedLabel.Size = UDim2.new(1, -40, 0, 14)
            selectedLabel.Position = UDim2.new(0, 10, 0, 18)
            selectedLabel.BackgroundTransparency = 1
            selectedLabel.Text = currentValue
            selectedLabel.Font = Enum.Font.GothamMedium
            selectedLabel.TextSize = 12
            selectedLabel.TextColor3 = Colors.Text
            selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
            selectedLabel.TextTruncate = Enum.TextTruncate.AtEnd
            selectedLabel.ZIndex = 3
            selectedLabel.Parent = dropdownFrame
            
            local chevronFrame = Instance.new("Frame")
            chevronFrame.Size = UDim2.new(0, 14, 0, 14)
            chevronFrame.Position = UDim2.new(1, -22, 0.5, -7)
            chevronFrame.BackgroundTransparency = 1
            chevronFrame.ZIndex = 3
            chevronFrame.Parent = dropdownFrame
            
            local chevronIcon = Utility:CreateIcon(chevronFrame, LucideIcons.ChevronDown)
            chevronIcon.ZIndex = 3
            
            local optionsContainer = Instance.new("Frame")
            optionsContainer.Size = UDim2.new(1, 0, 0, 0)
            optionsContainer.Position = UDim2.new(0, 0, 0, 40)
            optionsContainer.BackgroundColor3 = Colors.SurfaceHover
            optionsContainer.BorderSizePixel = 0
            optionsContainer.Visible = false
            optionsContainer.ClipsDescendants = true
            optionsContainer.ZIndex = 50
            optionsContainer.Parent = dropdownFrame
            Utility:CreateCorner(optionsContainer, 4)
            Utility:CreateStroke(optionsContainer, Colors.Border, 1)
            
            local optionsScroll = Instance.new("ScrollingFrame")
            optionsScroll.Size = UDim2.new(1, 0, 1, 0)
            optionsScroll.BackgroundTransparency = 1
            optionsScroll.BorderSizePixel = 0
            optionsScroll.ScrollBarThickness = 3
            optionsScroll.ScrollBarImageColor3 = Colors.Border
            optionsScroll.ZIndex = 50
            optionsScroll.Parent = optionsContainer
            
            local optionsList = Utility:CreateListLayout(optionsScroll, 2)
            Utility:CreatePadding(optionsScroll, 4)
            
            for _, option in ipairs(dropdownOptions) do
                local optionButton = Instance.new("TextButton")
                optionButton.Size = UDim2.new(1, 0, 0, 28)
                optionButton.BackgroundColor3 = option == currentValue and Colors.Primary or Colors.Surface
                optionButton.BackgroundTransparency = option == currentValue and 0.85 or 1
                optionButton.Text = ""
                optionButton.AutoButtonColor = false
                optionButton.ZIndex = 50
                optionButton.Parent = optionsScroll
                Utility:CreateCorner(optionButton, 4)
                
                local optionLabel = Instance.new("TextLabel")
                optionLabel.Size = UDim2.new(1, -36, 1, 0)
                optionLabel.Position = UDim2.new(0, 8, 0, 0)
                optionLabel.BackgroundTransparency = 1
                optionLabel.Text = option
                optionLabel.Font = Enum.Font.GothamMedium
                optionLabel.TextSize = 11
                optionLabel.TextColor3 = Colors.Text
                optionLabel.TextXAlignment = Enum.TextXAlignment.Left
                optionLabel.ZIndex = 50
                optionLabel.Parent = optionButton
                
                if option == currentValue then
                    local checkFrame = Instance.new("Frame")
                    checkFrame.Size = UDim2.new(0, 12, 0, 12)
                    checkFrame.Position = UDim2.new(1, -20, 0.5, -6)
                    checkFrame.BackgroundTransparency = 1
                    checkFrame.ZIndex = 50
                    checkFrame.Parent = optionButton
                    
                    local checkIcon = Utility:CreateIcon(checkFrame, LucideIcons.Check)
                    checkIcon.ImageColor3 = Colors.Primary
                    checkIcon.ZIndex = 50
                end
                
                tabConnections:Add(optionButton.MouseButton1Click:Connect(function()
                    currentValue = option
                    selectedLabel.Text = option
                    
                    for _, child in ipairs(optionsScroll:GetChildren()) do
                        if child:IsA("TextButton") then
                            Utility:Tween(child, {BackgroundTransparency = 1})
                            for _, subChild in ipairs(child:GetChildren()) do
                                if subChild.Name == "Frame" and subChild:FindFirstChild("ImageLabel") then
                                    subChild:Destroy()
                                end
                            end
                        end
                    end
                    
                    Utility:Tween(optionButton, {BackgroundTransparency = 0.85, BackgroundColor3 = Colors.Primary})
                    
                    local checkFrame = Instance.new("Frame")
                    checkFrame.Size = UDim2.new(0, 12, 0, 12)
                    checkFrame.Position = UDim2.new(1, -20, 0.5, -6)
                    checkFrame.BackgroundTransparency = 1
                    checkFrame.ZIndex = 50
                    checkFrame.Parent = optionButton
                    
                    local checkIcon = Utility:CreateIcon(checkFrame, LucideIcons.Check)
                    checkIcon.ImageColor3 = Colors.Primary
                    checkIcon.ZIndex = 50
                    
                    isOpen = false
                    Utility:Tween(chevronIcon, {Rotation = 0}, 0.2)
                    Utility:Tween(optionsContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                    Utility:Tween(dropdownFrame, {Size = UDim2.new(0, 0, 0, 36)}, 0.2)
                    task.wait(0.2)
                    optionsContainer.Visible = false
                    
                    task.spawn(dropdownCallback, option)
                end))
                
                tabConnections:Add(optionButton.MouseEnter:Connect(function()
                    if option ~= currentValue then
                        Utility:Tween(optionButton, {BackgroundTransparency = 0.5, BackgroundColor3 = Colors.Surface})
                    end
                end))
                
                tabConnections:Add(optionButton.MouseLeave:Connect(function()
                    if option ~= currentValue then
                        Utility:Tween(optionButton, {BackgroundTransparency = 1})
                    end
                end))
            end
            
            optionsList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                optionsScroll.CanvasSize = UDim2.new(0, 0, 0, optionsList.AbsoluteContentSize.Y + 8)
            end)
            
            tabConnections:Add(dropdownButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                
                if isOpen then
                    optionsContainer.Visible = true
                    local targetHeight = math.min(#dropdownOptions * 30 + 8, 120)
                    Utility:Tween(chevronIcon, {Rotation = 180}, 0.2)
                    Utility:Tween(optionsContainer, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.2)
                    Utility:Tween(dropdownFrame, {Size = UDim2.new(0, 0, 0, 36 + targetHeight + 4)}, 0.2)
                else
                    Utility:Tween(chevronIcon, {Rotation = 0}, 0.2)
                    Utility:Tween(optionsContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                    Utility:Tween(dropdownFrame, {Size = UDim2.new(0, 0, 0, 36)}, 0.2)
                    task.wait(0.2)
                    optionsContainer.Visible = false
                end
            end))
            
            tabConnections:Add(dropdownButton.MouseEnter:Connect(function()
                Utility:Tween(dropdownFrame, {BackgroundColor3 = Colors.SurfaceHover})
            end))
            
            tabConnections:Add(dropdownButton.MouseLeave:Connect(function()
                Utility:Tween(dropdownFrame, {BackgroundColor3 = Colors.Surface})
            end))
            
            return dropdownFrame
        end
        
        function Tab:CreateInput(config)
            config = config or {}
            local inputName = config.Name or "Input"
            local inputPlaceholder = config.Placeholder or "Enter text..."
            local inputDefault = config.Default or ""
            local inputCallback = config.Callback or function() end
            
            local inputFrame = Instance.new("Frame")
            inputFrame.Size = UDim2.new(0, 0, 0, 58)
            inputFrame.BackgroundColor3 = Colors.Surface
            inputFrame.BorderSizePixel = 0
            inputFrame.Parent = tabContent
            Utility:CreateCorner(inputFrame, 4)
            
            local inputLabel = Instance.new("TextLabel")
            inputLabel.Size = UDim2.new(1, -20, 0, 14)
            inputLabel.Position = UDim2.new(0, 10, 0, 6)
            inputLabel.BackgroundTransparency = 1
            inputLabel.Text = inputName
            inputLabel.Font = Enum.Font.Gotham
            inputLabel.TextSize = 10
            inputLabel.TextColor3 = Colors.TextTertiary
            inputLabel.TextXAlignment = Enum.TextXAlignment.Left
            inputLabel.Parent = inputFrame
            
            local inputBox = Instance.new("TextBox")
            inputBox.Size = UDim2.new(1, -20, 0, 28)
            inputBox.Position = UDim2.new(0, 10, 0, 24)
            inputBox.BackgroundColor3 = Colors.Background
            inputBox.PlaceholderText = inputPlaceholder
            inputBox.PlaceholderColor3 = Colors.TextTertiary
            inputBox.Text = inputDefault
            inputBox.Font = Enum.Font.GothamMedium
            inputBox.TextSize = 12
            inputBox.TextColor3 = Colors.Text
            inputBox.TextXAlignment = Enum.TextXAlignment.Left
            inputBox.ClearTextOnFocus = false
            inputBox.Parent = inputFrame
            Utility:CreateCorner(inputBox, 4)
            Utility:CreatePadding(inputBox, {Left = 8, Right = 8})
            
            tabConnections:Add(inputBox.Focused:Connect(function()
                Utility:CreateStroke(inputBox, Colors.Primary, 2)
                Utility:Tween(inputLabel, {TextColor3 = Colors.Primary})
            end))
            
            tabConnections:Add(inputBox.FocusLost:Connect(function(enterPressed)
                for _, child in ipairs(inputBox:GetChildren()) do
                    if child:IsA("UIStroke") then
                        child:Destroy()
                    end
                end
                Utility:Tween(inputLabel, {TextColor3 = Colors.TextTertiary})
                if enterPressed then
                    task.spawn(inputCallback, inputBox.Text)
                end
            end))
            
            return inputFrame
        end
        
        function Tab:CreateLabel(text)
            local labelFrame = Instance.new("Frame")
            labelFrame.Size = UDim2.new(0, 0, 0, 28)
            labelFrame.BackgroundColor3 = Colors.Surface
            labelFrame.BorderSizePixel = 0
            labelFrame.Parent = tabContent
            Utility:CreateCorner(labelFrame, 4)
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -20, 1, 0)
            label.Position = UDim2.new(0, 10, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = text
            label.Font = Enum.Font.GothamMedium
            label.TextSize = 12
            label.TextColor3 = Colors.Text
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextWrapped = true
            label.Parent = labelFrame
            
            return labelFrame
        end
        
        return Tab
    end
    
    Utility:Tween(mainFrame, {Size = windowSize}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    Window.Destroy = function()
        windowConnections:DisconnectAll()
        for _, tab in pairs(tabs) do
            if tab.Connections then
                tab.Connections:DisconnectAll()
            end
        end
        screenGui:Destroy()
    end
    
    return Window
end

return FluentHub