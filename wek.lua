local FluentHub = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

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
    Target = "rbxassetid://10723434711"
}

local Colors = {
    Background = Color3.fromRGB(24, 24, 27),
    Surface = Color3.fromRGB(39, 39, 42),
    SurfaceHover = Color3.fromRGB(52, 52, 56),
    Primary = Color3.fromRGB(139, 92, 246),
    PrimaryHover = Color3.fromRGB(167, 139, 250),
    Text = Color3.fromRGB(250, 250, 250),
    TextSecondary = Color3.fromRGB(161, 161, 170),
    TextTertiary = Color3.fromRGB(113, 113, 122),
    Border = Color3.fromRGB(63, 63, 70),
    Success = Color3.fromRGB(34, 197, 94),
    Warning = Color3.fromRGB(251, 146, 60),
    Error = Color3.fromRGB(239, 68, 68),
    Info = Color3.fromRGB(59, 130, 246)
}

local Utility = {}

function Utility:Tween(instance, properties, duration, style, direction)
    local info = TweenInfo.new(
        duration or 0.25,
        style or Enum.EasingStyle.Quart,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

function Utility:CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
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

function Utility:CreateIcon(parent, iconId)
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(1, 0, 1, 0)
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

function Utility:CreateListLayout(parent, padding, alignment)
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, padding or 8)
    if alignment then layout.VerticalAlignment = alignment end
    layout.Parent = parent
    return layout
end

function Utility:MakeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    
    frame.InputBegan:Connect(function(input)
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
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function FluentHub:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Title or "Fluent Hub"
    local windowSize = config.Size or UDim2.new(0, 580, 0, 460)
    
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
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    Utility:CreateCorner(mainFrame, 12)
    Utility:CreateStroke(mainFrame, Colors.Border, 1)
    
    Utility:MakeDraggable(mainFrame)
    
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 48)
    header.BackgroundTransparency = 1
    header.Parent = mainFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0, 200, 1, 0)
    titleLabel.Position = UDim2.new(0, 56, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = windowTitle
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 15
    titleLabel.TextColor3 = Colors.Text
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header
    
    local logoFrame = Instance.new("Frame")
    logoFrame.Size = UDim2.new(0, 32, 0, 32)
    logoFrame.Position = UDim2.new(0, 12, 0.5, -16)
    logoFrame.BackgroundColor3 = Colors.Primary
    logoFrame.BackgroundTransparency = 0.9
    logoFrame.BorderSizePixel = 0
    logoFrame.Parent = header
    Utility:CreateCorner(logoFrame, 8)
    
    local logoIcon = Utility:CreateIcon(logoFrame, LucideIcons.Box)
    logoIcon.ImageColor3 = Colors.Primary
    Utility:CreatePadding(logoFrame, 6)
    
    local headerDivider = Instance.new("Frame")
    headerDivider.Size = UDim2.new(1, 0, 0, 1)
    headerDivider.Position = UDim2.new(0, 0, 1, 0)
    headerDivider.BackgroundColor3 = Colors.Border
    headerDivider.BorderSizePixel = 0
    headerDivider.Parent = header
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 32, 0, 32)
    closeButton.Position = UDim2.new(1, -44, 0.5, -16)
    closeButton.BackgroundColor3 = Colors.Surface
    closeButton.BackgroundTransparency = 1
    closeButton.Text = ""
    closeButton.AutoButtonColor = false
    closeButton.Parent = header
    Utility:CreateCorner(closeButton, 6)
    
    local closeIcon = Utility:CreateIcon(closeButton, LucideIcons.X)
    Utility:CreatePadding(closeButton, 8)
    
    closeButton.MouseButton1Click:Connect(function()
        Utility:Tween(mainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
        task.wait(0.2)
        screenGui:Destroy()
    end)
    
    closeButton.MouseEnter:Connect(function()
        Utility:Tween(closeButton, {BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(220, 38, 38)})
        closeIcon.ImageColor3 = Colors.Text
    end)
    
    closeButton.MouseLeave:Connect(function()
        Utility:Tween(closeButton, {BackgroundTransparency = 1})
        closeIcon.ImageColor3 = Colors.TextSecondary
    end)
    
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(1, 0, 1, -48)
    container.Position = UDim2.new(0, 0, 0, 48)
    container.BackgroundTransparency = 1
    container.Parent = mainFrame
    
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 200, 1, 0)
    sidebar.BackgroundTransparency = 1
    sidebar.BorderSizePixel = 0
    sidebar.Parent = container
    
    Utility:CreateListLayout(sidebar, 4)
    Utility:CreatePadding(sidebar, {Top = 12, Bottom = 12, Left = 12, Right = 12})
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -200, 1, 0)
    contentFrame.Position = UDim2.new(0, 200, 0, 0)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = container
    
    local sidebarDivider = Instance.new("Frame")
    sidebarDivider.Size = UDim2.new(0, 1, 1, 0)
    sidebarDivider.Position = UDim2.new(0, 200, 0, 0)
    sidebarDivider.BackgroundColor3 = Colors.Border
    sidebarDivider.BorderSizePixel = 0
    sidebarDivider.Parent = container
    
    local tabs = {}
    local currentTab = nil
    
    local Window = {}
    
    local notificationContainer = Instance.new("Frame")
    notificationContainer.Name = "Notifications"
    notificationContainer.Size = UDim2.new(0, 340, 1, -20)
    notificationContainer.Position = UDim2.new(1, -360, 0, 20)
    notificationContainer.BackgroundTransparency = 1
    notificationContainer.Parent = screenGui
    notificationContainer.ZIndex = 100
    
    Utility:CreateListLayout(notificationContainer, 12, Enum.VerticalAlignment.Bottom)
    
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
        notification.Size = UDim2.new(1, 0, 0, 72)
        notification.BackgroundColor3 = Colors.Surface
        notification.BorderSizePixel = 0
        notification.Parent = notificationContainer
        Utility:CreateCorner(notification, 10)
        
        local accentBar = Instance.new("Frame")
        accentBar.Size = UDim2.new(0, 4, 1, 0)
        accentBar.BackgroundColor3 = cfg.Color
        accentBar.BorderSizePixel = 0
        accentBar.Parent = notification
        Utility:CreateCorner(accentBar, 10)
        
        local iconFrame = Instance.new("Frame")
        iconFrame.Size = UDim2.new(0, 40, 0, 40)
        iconFrame.Position = UDim2.new(0, 16, 0, 16)
        iconFrame.BackgroundColor3 = cfg.Color
        iconFrame.BackgroundTransparency = 0.9
        iconFrame.BorderSizePixel = 0
        iconFrame.Parent = notification
        Utility:CreateCorner(iconFrame, 8)
        
        local icon = Utility:CreateIcon(iconFrame, cfg.Icon)
        icon.ImageColor3 = cfg.Color
        Utility:CreatePadding(iconFrame, 8)
        
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -108, 0, 20)
        titleLabel.Position = UDim2.new(0, 64, 0, 16)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextSize = 14
        titleLabel.TextColor3 = Colors.Text
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
        titleLabel.Parent = notification
        
        local messageLabel = Instance.new("TextLabel")
        messageLabel.Size = UDim2.new(1, -108, 0, 16)
        messageLabel.Position = UDim2.new(0, 64, 0, 38)
        messageLabel.BackgroundTransparency = 1
        messageLabel.Text = message
        messageLabel.Font = Enum.Font.Gotham
        messageLabel.TextSize = 12
        messageLabel.TextColor3 = Colors.TextSecondary
        messageLabel.TextXAlignment = Enum.TextXAlignment.Left
        messageLabel.TextTruncate = Enum.TextTruncate.AtEnd
        messageLabel.Parent = notification
        
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 28, 0, 28)
        closeBtn.Position = UDim2.new(1, -38, 0, 10)
        closeBtn.BackgroundTransparency = 1
        closeBtn.Text = ""
        closeBtn.AutoButtonColor = false
        closeBtn.Parent = notification
        Utility:CreateCorner(closeBtn, 6)
        
        local closeIcon = Utility:CreateIcon(closeBtn, LucideIcons.X)
        Utility:CreatePadding(closeBtn, 6)
        
        local progressBar = Instance.new("Frame")
        progressBar.Size = UDim2.new(1, 0, 0, 2)
        progressBar.Position = UDim2.new(0, 0, 1, -2)
        progressBar.BackgroundColor3 = cfg.Color
        progressBar.BorderSizePixel = 0
        progressBar.Parent = notification
        
        local function closeNotification()
            Utility:Tween(notification, {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1
            }, 0.2)
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
        
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tabName
        tabButton.Size = UDim2.new(1, 0, 0, 36)
        tabButton.BackgroundColor3 = Colors.Surface
        tabButton.BackgroundTransparency = 1
        tabButton.Text = ""
        tabButton.AutoButtonColor = false
        tabButton.Parent = sidebar
        Utility:CreateCorner(tabButton, 8)
        
        local iconFrame = Instance.new("Frame")
        iconFrame.Size = UDim2.new(0, 20, 0, 20)
        iconFrame.Position = UDim2.new(0, 10, 0.5, -10)
        iconFrame.BackgroundTransparency = 1
        iconFrame.Parent = tabButton
        
        local tabIconImg = Utility:CreateIcon(iconFrame, tabIcon)
        
        local tabLabel = Instance.new("TextLabel")
        tabLabel.Size = UDim2.new(1, -45, 1, 0)
        tabLabel.Position = UDim2.new(0, 38, 0, 0)
        tabLabel.BackgroundTransparency = 1
        tabLabel.Text = tabName
        tabLabel.Font = Enum.Font.GothamMedium
        tabLabel.TextSize = 13
        tabLabel.TextColor3 = Colors.TextSecondary
        tabLabel.TextXAlignment = Enum.TextXAlignment.Left
        tabLabel.Parent = tabButton
        
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = tabName .. "Content"
        tabContent.Size = UDim2.new(1, -24, 1, -24)
        tabContent.Position = UDim2.new(0, 12, 0, 12)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 4
        tabContent.ScrollBarImageColor3 = Colors.Border
        tabContent.Visible = false
        tabContent.Parent = contentFrame
        
        local contentList = Utility:CreateListLayout(tabContent, 8)
        
        contentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentList.AbsoluteContentSize.Y + 12)
        end)
        
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
        
        tabButton.MouseButton1Click:Connect(SelectTab)
        
        tabButton.MouseEnter:Connect(function()
            if currentTab ~= tabContent then
                Utility:Tween(tabButton, {BackgroundTransparency = 0.7})
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if currentTab ~= tabContent then
                Utility:Tween(tabButton, {BackgroundTransparency = 1})
            end
        end)
        
        local Tab = {
            Button = tabButton,
            Label = tabLabel,
            Icon = tabIconImg,
            Content = tabContent
        }
        
        table.insert(tabs, Tab)
        
        if #tabs == 1 then
            SelectTab()
        end
        
        function Tab:CreateSection(title)
            local sectionFrame = Instance.new("Frame")
            sectionFrame.Size = UDim2.new(1, 0, 0, 32)
            sectionFrame.BackgroundTransparency = 1
            sectionFrame.Parent = tabContent
            
            local sectionLabel = Instance.new("TextLabel")
            sectionLabel.Size = UDim2.new(1, 0, 1, 0)
            sectionLabel.BackgroundTransparency = 1
            sectionLabel.Text = title
            sectionLabel.Font = Enum.Font.GothamBold
            sectionLabel.TextSize = 13
            sectionLabel.TextColor3 = Colors.Text
            sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            sectionLabel.TextYAlignment = Enum.TextYAlignment.Center
            sectionLabel.Parent = sectionFrame
            
            return sectionFrame
        end
        
        function Tab:CreateButton(config)
            config = config or {}
            local buttonName = config.Name or "Button"
            local buttonCallback = config.Callback or function() end
            local isLocked = config.Locked or false
            
            local buttonFrame = Instance.new("Frame")
            buttonFrame.Size = UDim2.new(1, 0, 0, 40)
            buttonFrame.BackgroundColor3 = Colors.Surface
            buttonFrame.BorderSizePixel = 0
            buttonFrame.Parent = tabContent
            Utility:CreateCorner(buttonFrame, 8)
            
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(1, 0, 1, 0)
            button.BackgroundTransparency = 1
            button.Text = ""
            button.AutoButtonColor = false
            button.Parent = buttonFrame
            
            local buttonLabel = Instance.new("TextLabel")
            buttonLabel.Size = UDim2.new(1, -80, 1, 0)
            buttonLabel.Position = UDim2.new(0, 12, 0, 0)
            buttonLabel.BackgroundTransparency = 1
            buttonLabel.Text = buttonName
            buttonLabel.Font = Enum.Font.GothamMedium
            buttonLabel.TextSize = 13
            buttonLabel.TextColor3 = isLocked and Colors.TextTertiary or Colors.Text
            buttonLabel.TextXAlignment = Enum.TextXAlignment.Left
            buttonLabel.Parent = buttonFrame
            
            if isLocked then
                local lockFrame = Instance.new("Frame")
                lockFrame.Size = UDim2.new(0, 64, 0, 24)
                lockFrame.Position = UDim2.new(1, -76, 0.5, -12)
                lockFrame.BackgroundColor3 = Colors.Background
                lockFrame.BorderSizePixel = 0
                lockFrame.Parent = buttonFrame
                Utility:CreateCorner(lockFrame, 6)
                
                local lockIcon = Instance.new("Frame")
                lockIcon.Size = UDim2.new(0, 16, 0, 16)
                lockIcon.Position = UDim2.new(0, 6, 0.5, -8)
                lockIcon.BackgroundTransparency = 1
                lockIcon.Parent = lockFrame
                
                local lockImg = Utility:CreateIcon(lockIcon, LucideIcons.Lock)
                lockImg.ImageColor3 = Colors.TextTertiary
                
                local lockLabel = Instance.new("TextLabel")
                lockLabel.Size = UDim2.new(0, 36, 1, 0)
                lockLabel.Position = UDim2.new(0, 26, 0, 0)
                lockLabel.BackgroundTransparency = 1
                lockLabel.Text = "Locked"
                lockLabel.Font = Enum.Font.GothamMedium
                lockLabel.TextSize = 11
                lockLabel.TextColor3 = Colors.TextTertiary
                lockLabel.TextXAlignment = Enum.TextXAlignment.Left
                lockLabel.Parent = lockFrame
            else
                local chevronFrame = Instance.new("Frame")
                chevronFrame.Size = UDim2.new(0, 16, 0, 16)
                chevronFrame.Position = UDim2.new(1, -28, 0.5, -8)
                chevronFrame.BackgroundTransparency = 1
                chevronFrame.Parent = buttonFrame
                
                local chevronIcon = Utility:CreateIcon(chevronFrame, LucideIcons.ChevronRight)
                
                button.MouseButton1Click:Connect(function()
                    Utility:Tween(buttonFrame, {BackgroundColor3 = Colors.Primary}, 0.1)
                    task.wait(0.1)
                    Utility:Tween(buttonFrame, {BackgroundColor3 = Colors.Surface}, 0.1)
                    task.spawn(buttonCallback)
                end)
                
                button.MouseEnter:Connect(function()
                    Utility:Tween(buttonFrame, {BackgroundColor3 = Colors.SurfaceHover})
                end)
                
                button.MouseLeave:Connect(function()
                    Utility:Tween(buttonFrame, {BackgroundColor3 = Colors.Surface})
                end)
            end
            
            return buttonFrame
        end
        
        function Tab:CreateToggle(config)
            config = config or {}
            local toggleName = config.Name or "Toggle"
            local toggleDefault = config.Default or false
            local toggleCallback = config.Callback or function() end
            
            local toggleFrame = Instance.new("Frame")
            toggleFrame.Size = UDim2.new(1, 0, 0, 40)
            toggleFrame.BackgroundColor3 = Colors.Surface
            toggleFrame.BorderSizePixel = 0
            toggleFrame.Parent = tabContent
            Utility:CreateCorner(toggleFrame, 8)
            
            local toggleLabel = Instance.new("TextLabel")
            toggleLabel.Size = UDim2.new(1, -68, 1, 0)
            toggleLabel.Position = UDim2.new(0, 12, 0, 0)
            toggleLabel.BackgroundTransparency = 1
            toggleLabel.Text = toggleName
            toggleLabel.Font = Enum.Font.GothamMedium
            toggleLabel.TextSize = 13
            toggleLabel.TextColor3 = Colors.Text
            toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            toggleLabel.Parent = toggleFrame
            
            local toggleButton = Instance.new("TextButton")
            toggleButton.Size = UDim2.new(0, 44, 0, 24)
            toggleButton.Position = UDim2.new(1, -56, 0.5, -12)
            toggleButton.BackgroundColor3 = Colors.Background
            toggleButton.Text = ""
            toggleButton.AutoButtonColor = false
            toggleButton.Parent = toggleFrame
            Utility:CreateCorner(toggleButton, 12)
            
            local toggleCircle = Instance.new("Frame")
            toggleCircle.Size = UDim2.new(0, 18, 0, 18)
            toggleCircle.Position = UDim2.new(0, 3, 0.5, -9)
            toggleCircle.BackgroundColor3 = Colors.TextTertiary
            toggleCircle.BorderSizePixel = 0
            toggleCircle.Parent = toggleButton
            Utility:CreateCorner(toggleCircle, 9)
            
            local isToggled = toggleDefault
            
            local function UpdateToggle(instant)
                local duration = instant and 0 or 0.2
                if isToggled then
                    Utility:Tween(toggleButton, {BackgroundColor3 = Colors.Primary}, duration)
                    Utility:Tween(toggleCircle, {
                        Position = UDim2.new(0, 23, 0.5, -9),
                        BackgroundColor3 = Colors.Text
                    }, duration)
                else
                    Utility:Tween(toggleButton, {BackgroundColor3 = Colors.Background}, duration)
                    Utility:Tween(toggleCircle, {
                        Position = UDim2.new(0, 3, 0.5, -9),
                        BackgroundColor3 = Colors.TextTertiary
                    }, duration)
                end
                task.spawn(toggleCallback, isToggled)
            end
            
            toggleButton.MouseButton1Click:Connect(function()
                isToggled = not isToggled
                UpdateToggle()
            end)
            
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
            
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Size = UDim2.new(1, 0, 0, 52)
            sliderFrame.BackgroundColor3 = Colors.Surface
            sliderFrame.BorderSizePixel = 0
            sliderFrame.Parent = tabContent
            Utility:CreateCorner(sliderFrame, 8)
            
            local sliderLabel = Instance.new("TextLabel")
            sliderLabel.Size = UDim2.new(0.6, 0, 0, 20)
            sliderLabel.Position = UDim2.new(0, 12, 0, 10)
            sliderLabel.BackgroundTransparency = 1
            sliderLabel.Text = sliderName
            sliderLabel.Font = Enum.Font.GothamMedium
            sliderLabel.TextSize = 13
            sliderLabel.TextColor3 = Colors.Text
            sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            sliderLabel.Parent = sliderFrame
            
            local valueDisplay = Instance.new("Frame")
            valueDisplay.Size = UDim2.new(0, 48, 0, 20)
            valueDisplay.Position = UDim2.new(1, -60, 0, 10)
            valueDisplay.BackgroundColor3 = Colors.Background
            valueDisplay.BorderSizePixel = 0
            valueDisplay.Parent = sliderFrame
            Utility:CreateCorner(valueDisplay, 6)
            
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(1, 0, 1, 0)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = tostring(sliderDefault)
            valueLabel.Font = Enum.Font.GothamBold
            valueLabel.TextSize = 12
            valueLabel.TextColor3 = Colors.Primary
            valueLabel.Parent = valueDisplay
            
            local sliderTrack = Instance.new("Frame")
            sliderTrack.Size = UDim2.new(1, -24, 0, 4)
            sliderTrack.Position = UDim2.new(0, 12, 1, -16)
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
            sliderThumb.Size = UDim2.new(0, 12, 0, 12)
            sliderThumb.Position = UDim2.new((sliderDefault - sliderMin) / (sliderMax - sliderMin), -6, 0.5, -6)
            sliderThumb.BackgroundColor3 = Colors.Text
            sliderThumb.BorderSizePixel = 0
            sliderThumb.ZIndex = 2
            sliderThumb.Parent = sliderTrack
            Utility:CreateCorner(sliderThumb, 6)
            
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
                sliderThumb.Position = UDim2.new((value - sliderMin) / (sliderMax - sliderMin), -6, 0.5, -6)
                valueLabel.Text = tostring(value)
                task.spawn(sliderCallback, value)
            end
            
            sliderButton.MouseButton1Down:Connect(function()
                draggingSlider = true
                Utility:Tween(sliderThumb, {Size = UDim2.new(0, 14, 0, 14)}, 0.1)
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = false
                    Utility:Tween(sliderThumb, {Size = UDim2.new(0, 12, 0, 12)}, 0.1)
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                    UpdateSlider(input)
                end
            end)
            
            sliderButton.MouseEnter:Connect(function()
                if not draggingSlider then
                    Utility:Tween(sliderThumb, {Size = UDim2.new(0, 14, 0, 14)}, 0.1)
                end
            end)
            
            sliderButton.MouseLeave:Connect(function()
                if not draggingSlider then
                    Utility:Tween(sliderThumb, {Size = UDim2.new(0, 12, 0, 12)}, 0.1)
                end
            end)
            
            return sliderFrame
        end
        
        function Tab:CreateDropdown(config)
            config = config or {}
            local dropdownName = config.Name or "Dropdown"
            local dropdownOptions = config.Options or {"Option 1", "Option 2", "Option 3"}
            local dropdownDefault = config.Default or dropdownOptions[1]
            local dropdownCallback = config.Callback or function() end
            
            local isOpen = false
            local currentValue = dropdownDefault
            
            local dropdownFrame = Instance.new("Frame")
            dropdownFrame.Size = UDim2.new(1, 0, 0, 40)
            dropdownFrame.BackgroundColor3 = Colors.Surface
            dropdownFrame.BorderSizePixel = 0
            dropdownFrame.Parent = tabContent
            dropdownFrame.ClipsDescendants = false
            dropdownFrame.ZIndex = 2
            Utility:CreateCorner(dropdownFrame, 8)
            
            local dropdownButton = Instance.new("TextButton")
            dropdownButton.Size = UDim2.new(1, 0, 0, 40)
            dropdownButton.BackgroundTransparency = 1
            dropdownButton.Text = ""
            dropdownButton.AutoButtonColor = false
            dropdownButton.ZIndex = 3
            dropdownButton.Parent = dropdownFrame
            
            local dropdownLabel = Instance.new("TextLabel")
            dropdownLabel.Size = UDim2.new(1, -48, 0, 16)
            dropdownLabel.Position = UDim2.new(0, 12, 0, 6)
            dropdownLabel.BackgroundTransparency = 1
            dropdownLabel.Text = dropdownName
            dropdownLabel.Font = Enum.Font.GothamMedium
            dropdownLabel.TextSize = 11
            dropdownLabel.TextColor3 = Colors.TextSecondary
            dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
            dropdownLabel.ZIndex = 3
            dropdownLabel.Parent = dropdownFrame
            
            local selectedLabel = Instance.new("TextLabel")
            selectedLabel.Size = UDim2.new(1, -48, 0, 16)
            selectedLabel.Position = UDim2.new(0, 12, 0, 20)
            selectedLabel.BackgroundTransparency = 1
            selectedLabel.Text = currentValue
            selectedLabel.Font = Enum.Font.GothamMedium
            selectedLabel.TextSize = 13
            selectedLabel.TextColor3 = Colors.Text
            selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
            selectedLabel.TextTruncate = Enum.TextTruncate.AtEnd
            selectedLabel.ZIndex = 3
            selectedLabel.Parent = dropdownFrame
            
            local chevronFrame = Instance.new("Frame")
            chevronFrame.Size = UDim2.new(0, 16, 0, 16)
            chevronFrame.Position = UDim2.new(1, -28, 0.5, -8)
            chevronFrame.BackgroundTransparency = 1
            chevronFrame.ZIndex = 3
            chevronFrame.Parent = dropdownFrame
            
            local chevronIcon = Utility:CreateIcon(chevronFrame, LucideIcons.ChevronDown)
            chevronIcon.ZIndex = 3
            
            local optionsContainer = Instance.new("Frame")
            optionsContainer.Size = UDim2.new(1, 0, 0, 0)
            optionsContainer.Position = UDim2.new(0, 0, 0, 44)
            optionsContainer.BackgroundColor3 = Colors.SurfaceHover
            optionsContainer.BorderSizePixel = 0
            optionsContainer.Visible = false
            optionsContainer.ClipsDescendants = true
            optionsContainer.ZIndex = 10
            optionsContainer.Parent = dropdownFrame
            Utility:CreateCorner(optionsContainer, 8)
            Utility:CreateStroke(optionsContainer, Colors.Border, 1)
            
            local optionsScroll = Instance.new("ScrollingFrame")
            optionsScroll.Size = UDim2.new(1, 0, 1, 0)
            optionsScroll.BackgroundTransparency = 1
            optionsScroll.BorderSizePixel = 0
            optionsScroll.ScrollBarThickness = 4
            optionsScroll.ScrollBarImageColor3 = Colors.Border
            optionsScroll.ZIndex = 10
            optionsScroll.Parent = optionsContainer
            
            local optionsList = Utility:CreateListLayout(optionsScroll, 2)
            Utility:CreatePadding(optionsScroll, 4)
            
            for _, option in ipairs(dropdownOptions) do
                local optionButton = Instance.new("TextButton")
                optionButton.Size = UDim2.new(1, 0, 0, 32)
                optionButton.BackgroundColor3 = option == currentValue and Colors.Primary or Colors.Surface
                optionButton.BackgroundTransparency = option == currentValue and 0.85 or 1
                optionButton.Text = ""
                optionButton.AutoButtonColor = false
                optionButton.ZIndex = 10
                optionButton.Parent = optionsScroll
                Utility:CreateCorner(optionButton, 6)
                
                local optionLabel = Instance.new("TextLabel")
                optionLabel.Size = UDim2.new(1, -20, 1, 0)
                optionLabel.Position = UDim2.new(0, 10, 0, 0)
                optionLabel.BackgroundTransparency = 1
                optionLabel.Text = option
                optionLabel.Font = Enum.Font.GothamMedium
                optionLabel.TextSize = 12
                optionLabel.TextColor3 = Colors.Text
                optionLabel.TextXAlignment = Enum.TextXAlignment.Left
                optionLabel.ZIndex = 10
                optionLabel.Parent = optionButton
                
                if option == currentValue then
                    local checkFrame = Instance.new("Frame")
                    checkFrame.Size = UDim2.new(0, 14, 0, 14)
                    checkFrame.Position = UDim2.new(1, -22, 0.5, -7)
                    checkFrame.BackgroundTransparency = 1
                    checkFrame.ZIndex = 10
                    checkFrame.Parent = optionButton
                    
                    local checkIcon = Utility:CreateIcon(checkFrame, LucideIcons.Check)
                    checkIcon.ImageColor3 = Colors.Primary
                    checkIcon.ZIndex = 10
                end
                
                optionButton.MouseButton1Click:Connect(function()
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
                    checkFrame.Size = UDim2.new(0, 14, 0, 14)
                    checkFrame.Position = UDim2.new(1, -22, 0.5, -7)
                    checkFrame.BackgroundTransparency = 1
                    checkFrame.ZIndex = 10
                    checkFrame.Parent = optionButton
                    
                    local checkIcon = Utility:CreateIcon(checkFrame, LucideIcons.Check)
                    checkIcon.ImageColor3 = Colors.Primary
                    checkIcon.ZIndex = 10
                    
                    isOpen = false
                    Utility:Tween(chevronIcon, {Rotation = 0}, 0.2)
                    Utility:Tween(optionsContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                    Utility:Tween(dropdownFrame, {Size = UDim2.new(1, 0, 0, 40)}, 0.2)
                    task.wait(0.2)
                    optionsContainer.Visible = false
                    
                    task.spawn(dropdownCallback, option)
                end)
                
                optionButton.MouseEnter:Connect(function()
                    if option ~= currentValue then
                        Utility:Tween(optionButton, {BackgroundTransparency = 0.5, BackgroundColor3 = Colors.Surface})
                    end
                end)
                
                optionButton.MouseLeave:Connect(function()
                    if option ~= currentValue then
                        Utility:Tween(optionButton, {BackgroundTransparency = 1})
                    end
                end)
            end
            
            optionsList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                optionsScroll.CanvasSize = UDim2.new(0, 0, 0, optionsList.AbsoluteContentSize.Y + 8)
            end)
            
            dropdownButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                
                if isOpen then
                    optionsContainer.Visible = true
                    local targetHeight = math.min(#dropdownOptions * 34 + 8, 140)
                    Utility:Tween(chevronIcon, {Rotation = 180}, 0.2)
                    Utility:Tween(optionsContainer, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.2)
                    Utility:Tween(dropdownFrame, {Size = UDim2.new(1, 0, 0, 40 + targetHeight + 4)}, 0.2)
                else
                    Utility:Tween(chevronIcon, {Rotation = 0}, 0.2)
                    Utility:Tween(optionsContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                    Utility:Tween(dropdownFrame, {Size = UDim2.new(1, 0, 0, 40)}, 0.2)
                    task.wait(0.2)
                    optionsContainer.Visible = false
                end
            end)
            
            dropdownButton.MouseEnter:Connect(function()
                Utility:Tween(dropdownFrame, {BackgroundColor3 = Colors.SurfaceHover})
            end)
            
            dropdownButton.MouseLeave:Connect(function()
                Utility:Tween(dropdownFrame, {BackgroundColor3 = Colors.Surface})
            end)
            
            return dropdownFrame
        end
        
        function Tab:CreateInput(config)
            config = config or {}
            local inputName = config.Name or "Input"
            local inputPlaceholder = config.Placeholder or "Enter text..."
            local inputDefault = config.Default or ""
            local inputCallback = config.Callback or function() end
            
            local inputFrame = Instance.new("Frame")
            inputFrame.Size = UDim2.new(1, 0, 0, 64)
            inputFrame.BackgroundColor3 = Colors.Surface
            inputFrame.BorderSizePixel = 0
            inputFrame.Parent = tabContent
            Utility:CreateCorner(inputFrame, 8)
            
            local inputLabel = Instance.new("TextLabel")
            inputLabel.Size = UDim2.new(1, -24, 0, 16)
            inputLabel.Position = UDim2.new(0, 12, 0, 8)
            inputLabel.BackgroundTransparency = 1
            inputLabel.Text = inputName
            inputLabel.Font = Enum.Font.GothamMedium
            inputLabel.TextSize = 11
            inputLabel.TextColor3 = Colors.TextSecondary
            inputLabel.TextXAlignment = Enum.TextXAlignment.Left
            inputLabel.Parent = inputFrame
            
            local inputBox = Instance.new("TextBox")
            inputBox.Size = UDim2.new(1, -24, 0, 32)
            inputBox.Position = UDim2.new(0, 12, 0, 26)
            inputBox.BackgroundColor3 = Colors.Background
            inputBox.PlaceholderText = inputPlaceholder
            inputBox.PlaceholderColor3 = Colors.TextTertiary
            inputBox.Text = inputDefault
            inputBox.Font = Enum.Font.GothamMedium
            inputBox.TextSize = 13
            inputBox.TextColor3 = Colors.Text
            inputBox.TextXAlignment = Enum.TextXAlignment.Left
            inputBox.ClearTextOnFocus = false
            inputBox.Parent = inputFrame
            Utility:CreateCorner(inputBox, 6)
            Utility:CreatePadding(inputBox, {Left = 10, Right = 10})
            
            inputBox.Focused:Connect(function()
                Utility:CreateStroke(inputBox, Colors.Primary, 2)
                Utility:Tween(inputLabel, {TextColor3 = Colors.Primary})
            end)
            
            inputBox.FocusLost:Connect(function(enterPressed)
                for _, child in ipairs(inputBox:GetChildren()) do
                    if child:IsA("UIStroke") then
                        child:Destroy()
                    end
                end
                Utility:Tween(inputLabel, {TextColor3 = Colors.TextSecondary})
                if enterPressed then
                    task.spawn(inputCallback, inputBox.Text)
                end
            end)
            
            return inputFrame
        end
        
        function Tab:CreateLabel(text)
            local labelFrame = Instance.new("Frame")
            labelFrame.Size = UDim2.new(1, 0, 0, 32)
            labelFrame.BackgroundColor3 = Colors.Surface
            labelFrame.BorderSizePixel = 0
            labelFrame.Parent = tabContent
            Utility:CreateCorner(labelFrame, 8)
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -24, 1, 0)
            label.Position = UDim2.new(0, 12, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = text
            label.Font = Enum.Font.GothamMedium
            label.TextSize = 13
            label.TextColor3 = Colors.Text
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextWrapped = true
            label.Parent = labelFrame
            
            return labelFrame
        end
        
        return Tab
    end
    
    Utility:Tween(mainFrame, {Size = windowSize}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    return Window
end

return FluentHub