local FluentHub = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local Icons = {
    Home = "🏠", Settings = "⚙️", User = "👤", Search = "🔍",
    Bell = "🔔", Star = "⭐", Lock = "🔒", Unlock = "🔓",
    Check = "✓", X = "✕", Menu = "☰", ChevronRight = "›",
    ChevronDown = "⌄", Info = "ℹ", Success = "✓", Warning = "⚠", Error = "✕"
}

local Colors = {
    Background = Color3.fromRGB(17, 17, 17),
    Surface = Color3.fromRGB(25, 25, 25),
    SurfaceHover = Color3.fromRGB(35, 35, 35),
    SurfaceActive = Color3.fromRGB(40, 40, 40),
    Primary = Color3.fromRGB(100, 100, 255),
    PrimaryHover = Color3.fromRGB(120, 120, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(150, 150, 150),
    TextTertiary = Color3.fromRGB(100, 100, 100),
    Border = Color3.fromRGB(45, 45, 45),
    Success = Color3.fromRGB(50, 200, 100),
    Warning = Color3.fromRGB(255, 180, 50),
    Error = Color3.fromRGB(255, 80, 80),
    Info = Color3.fromRGB(80, 150, 255)
}

local Utility = {}

function Utility:Tween(instance, properties, duration, easingStyle, easingDirection)
    local info = TweenInfo.new(
        duration or 0.2,
        easingStyle or Enum.EasingStyle.Quad,
        easingDirection or Enum.EasingDirection.Out
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

function Utility:CreatePadding(parent, all)
    local padding = Instance.new("UIPadding")
    if type(all) == "number" then
        padding.PaddingTop = UDim.new(0, all)
        padding.PaddingBottom = UDim.new(0, all)
        padding.PaddingLeft = UDim.new(0, all)
        padding.PaddingRight = UDim.new(0, all)
    elseif type(all) == "table" then
        padding.PaddingTop = UDim.new(0, all.Top or 0)
        padding.PaddingBottom = UDim.new(0, all.Bottom or 0)
        padding.PaddingLeft = UDim.new(0, all.Left or 0)
        padding.PaddingRight = UDim.new(0, all.Right or 0)
    end
    padding.Parent = parent
    return padding
end

function Utility:CreateListLayout(parent, padding, alignment)
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, padding or 4)
    if alignment then
        layout.VerticalAlignment = alignment
    end
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
            Utility:Tween(frame, {
                Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            }, 0.1)
        end
    end)
end

function FluentHub:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Title or "Fluent Hub"
    local windowSubtitle = config.Subtitle or "UI Library"
    local windowSize = config.Size or UDim2.new(0, 700, 0, 500)
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FluentHubUI_" .. math.random(1000, 9999)
    screenGui.Parent = CoreGui
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = windowSize
    mainFrame.Position = UDim2.new(0.5, -windowSize.X.Offset/2, 0.5, -windowSize.Y.Offset/2)
    mainFrame.BackgroundColor3 = Colors.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    Utility:CreateCorner(mainFrame, 12)
    Utility:CreateStroke(mainFrame, Colors.Border, 1)
    
    Utility:MakeDraggable(mainFrame)
    
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundTransparency = 1
    header.Parent = mainFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0, 200, 0, 25)
    titleLabel.Position = UDim2.new(0, 20, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = windowTitle
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextColor3 = Colors.Text
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header
    
    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Size = UDim2.new(0, 200, 0, 20)
    subtitleLabel.Position = UDim2.new(0, 20, 0, 28)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Text = windowSubtitle
    subtitleLabel.Font = Enum.Font.Gotham
    subtitleLabel.TextSize = 12
    subtitleLabel.TextColor3 = Colors.TextSecondary
    subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    subtitleLabel.Parent = header
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 10)
    closeButton.BackgroundColor3 = Colors.Surface
    closeButton.Text = Icons.X
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 16
    closeButton.TextColor3 = Colors.Text
    closeButton.AutoButtonColor = false
    closeButton.Parent = header
    Utility:CreateCorner(closeButton, 6)
    
    closeButton.MouseButton1Click:Connect(function()
        Utility:Tween(mainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back)
        wait(0.3)
        screenGui:Destroy()
    end)
    
    closeButton.MouseEnter:Connect(function()
        Utility:Tween(closeButton, {BackgroundColor3 = Colors.Error})
    end)
    
    closeButton.MouseLeave:Connect(function()
        Utility:Tween(closeButton, {BackgroundColor3 = Colors.Surface})
    end)
    
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Size = UDim2.new(0, 30, 0, 30)
    minimizeButton.Position = UDim2.new(1, -75, 0, 10)
    minimizeButton.BackgroundColor3 = Colors.Surface
    minimizeButton.Text = "−"
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.TextSize = 20
    minimizeButton.TextColor3 = Colors.Text
    minimizeButton.AutoButtonColor = false
    minimizeButton.Parent = header
    Utility:CreateCorner(minimizeButton, 6)
    
    local isMinimized = false
    local originalSize = mainFrame.Size
    
    minimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        Utility:Tween(mainFrame, {
            Size = isMinimized and UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 50) or originalSize
        }, 0.3, Enum.EasingStyle.Quint)
    end)
    
    minimizeButton.MouseEnter:Connect(function()
        Utility:Tween(minimizeButton, {BackgroundColor3 = Colors.SurfaceHover})
    end)
    
    minimizeButton.MouseLeave:Connect(function()
        Utility:Tween(minimizeButton, {BackgroundColor3 = Colors.Surface})
    end)
    
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(1, 0, 1, -50)
    container.Position = UDim2.new(0, 0, 0, 50)
    container.BackgroundTransparency = 1
    container.Parent = mainFrame
    
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 180, 1, 0)
    sidebar.BackgroundColor3 = Colors.Surface
    sidebar.BorderSizePixel = 0
    sidebar.Parent = container
    
    Utility:CreateListLayout(sidebar, 4)
    Utility:CreatePadding(sidebar, 10)
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -180, 1, 0)
    contentFrame.Position = UDim2.new(0, 180, 0, 0)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = container
    
    local tabs = {}
    local currentTab = nil
    
    local Window = {}
    
    local notificationContainer = Instance.new("Frame")
    notificationContainer.Name = "NotificationContainer"
    notificationContainer.Size = UDim2.new(0, 320, 1, 0)
    notificationContainer.Position = UDim2.new(1, -340, 0, 20)
    notificationContainer.BackgroundTransparency = 1
    notificationContainer.Parent = screenGui
    notificationContainer.ZIndex = 10
    
    Utility:CreateListLayout(notificationContainer, 10, Enum.VerticalAlignment.Top)
    
    function Window:CreateNotification(config)
        config = config or {}
        local title = config.Title or "Notification"
        local message = config.Message or ""
        local duration = config.Duration or 3
        local notifType = config.Type or "Info"
        
        local typeConfig = {
            Info = {Color = Colors.Info, Icon = Icons.Info},
            Success = {Color = Colors.Success, Icon = Icons.Success},
            Warning = {Color = Colors.Warning, Icon = Icons.Warning},
            Error = {Color = Colors.Error, Icon = Icons.Error}
        }
        
        local cfg = typeConfig[notifType] or typeConfig.Info
        
        local notification = Instance.new("Frame")
        notification.Size = UDim2.new(1, 0, 0, 0)
        notification.BackgroundColor3 = Colors.Surface
        notification.BorderSizePixel = 0
        notification.ClipsDescendants = true
        notification.Parent = notificationContainer
        Utility:CreateCorner(notification, 8)
        Utility:CreateStroke(notification, cfg.Color, 1)
        
        local iconFrame = Instance.new("Frame")
        iconFrame.Size = UDim2.new(0, 40, 0, 40)
        iconFrame.Position = UDim2.new(0, 10, 0, 10)
        iconFrame.BackgroundColor3 = cfg.Color
        iconFrame.BackgroundTransparency = 0.9
        iconFrame.BorderSizePixel = 0
        iconFrame.Parent = notification
        Utility:CreateCorner(iconFrame, 8)
        
        local icon = Instance.new("TextLabel")
        icon.Size = UDim2.new(1, 0, 1, 0)
        icon.BackgroundTransparency = 1
        icon.Text = cfg.Icon
        icon.Font = Enum.Font.GothamBold
        icon.TextSize = 18
        icon.TextColor3 = cfg.Color
        icon.Parent = iconFrame
        
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -110, 0, 20)
        titleLabel.Position = UDim2.new(0, 60, 0, 10)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextSize = 14
        titleLabel.TextColor3 = Colors.Text
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
        titleLabel.Parent = notification
        
        local messageLabel = Instance.new("TextLabel")
        messageLabel.Size = UDim2.new(1, -110, 0, 20)
        messageLabel.Position = UDim2.new(0, 60, 0, 30)
        messageLabel.BackgroundTransparency = 1
        messageLabel.Text = message
        messageLabel.Font = Enum.Font.Gotham
        messageLabel.TextSize = 12
        messageLabel.TextColor3 = Colors.TextSecondary
        messageLabel.TextXAlignment = Enum.TextXAlignment.Left
        messageLabel.TextWrapped = true
        messageLabel.TextTruncate = Enum.TextTruncate.AtEnd
        messageLabel.Parent = notification
        
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 30, 0, 30)
        closeBtn.Position = UDim2.new(1, -40, 0, 10)
        closeBtn.BackgroundColor3 = Colors.Background
        closeBtn.BackgroundTransparency = 0.5
        closeBtn.Text = Icons.X
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 14
        closeBtn.TextColor3 = Colors.TextSecondary
        closeBtn.AutoButtonColor = false
        closeBtn.Parent = notification
        Utility:CreateCorner(closeBtn, 6)
        
        local progressBar = Instance.new("Frame")
        progressBar.Size = UDim2.new(1, 0, 0, 3)
        progressBar.Position = UDim2.new(0, 0, 1, -3)
        progressBar.BackgroundColor3 = cfg.Color
        progressBar.BorderSizePixel = 0
        progressBar.Parent = notification
        
        Utility:Tween(notification, {Size = UDim2.new(1, 0, 0, 60)}, 0.3, Enum.EasingStyle.Back)
        
        local function closeNotification()
            Utility:Tween(notification, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
            wait(0.2)
            notification:Destroy()
        end
        
        closeBtn.MouseButton1Click:Connect(closeNotification)
        
        closeBtn.MouseEnter:Connect(function()
            Utility:Tween(closeBtn, {BackgroundTransparency = 0})
        end)
        
        closeBtn.MouseLeave:Connect(function()
            Utility:Tween(closeBtn, {BackgroundTransparency = 0.5})
        end)
        
        spawn(function()
            wait(0.1)
            Utility:Tween(progressBar, {Size = UDim2.new(0, 0, 0, 3)}, duration)
            wait(duration)
            closeNotification()
        end)
    end
    
    function Window:CreateTab(config)
        config = config or {}
        local tabName = config.Name or "Tab"
        local tabIcon = config.Icon or Icons.Home
        
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tabName
        tabButton.Size = UDim2.new(1, 0, 0, 40)
        tabButton.BackgroundColor3 = Colors.Background
        tabButton.BackgroundTransparency = 1
        tabButton.Text = ""
        tabButton.AutoButtonColor = false
        tabButton.Parent = sidebar
        Utility:CreateCorner(tabButton, 6)
        
        local tabIconLabel = Instance.new("TextLabel")
        tabIconLabel.Size = UDim2.new(0, 20, 0, 20)
        tabIconLabel.Position = UDim2.new(0, 10, 0.5, -10)
        tabIconLabel.BackgroundTransparency = 1
        tabIconLabel.Text = tabIcon
        tabIconLabel.Font = Enum.Font.GothamBold
        tabIconLabel.TextSize = 18
        tabIconLabel.TextColor3 = Colors.TextSecondary
        tabIconLabel.Parent = tabButton
        
        local tabLabel = Instance.new("TextLabel")
        tabLabel.Size = UDim2.new(1, -45, 1, 0)
        tabLabel.Position = UDim2.new(0, 40, 0, 0)
        tabLabel.BackgroundTransparency = 1
        tabLabel.Text = tabName
        tabLabel.Font = Enum.Font.Gotham
        tabLabel.TextSize = 14
        tabLabel.TextColor3 = Colors.TextSecondary
        tabLabel.TextXAlignment = Enum.TextXAlignment.Left
        tabLabel.Parent = tabButton
        
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = tabName .. "Content"
        tabContent.Size = UDim2.new(1, -20, 1, -20)
        tabContent.Position = UDim2.new(0, 10, 0, 10)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 4
        tabContent.ScrollBarImageColor3 = Colors.Primary
        tabContent.Visible = false
        tabContent.Parent = contentFrame
        
        local contentList = Utility:CreateListLayout(tabContent, 10)
        
        contentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentList.AbsoluteContentSize.Y + 20)
        end)
        
        local function SelectTab()
            for _, tab in pairs(tabs) do
                tab.Button.BackgroundTransparency = 1
                tab.Label.TextColor3 = Colors.TextSecondary
                tab.Icon.TextColor3 = Colors.TextSecondary
                tab.Content.Visible = false
            end
            
            tabButton.BackgroundTransparency = 0
            tabLabel.TextColor3 = Colors.Text
            tabIconLabel.TextColor3 = Colors.Primary
            tabContent.Visible = true
            currentTab = tabContent
        end
        
        tabButton.MouseButton1Click:Connect(SelectTab)
        
        tabButton.MouseEnter:Connect(function()
            if tabButton.BackgroundTransparency == 1 then
                Utility:Tween(tabButton, {BackgroundTransparency = 0.5})
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
            Icon = tabIconLabel,
            Content = tabContent
        }
        
        table.insert(tabs, Tab)
        
        if #tabs == 1 then
            SelectTab()
        end
        
        function Tab:CreateButton(config)
            config = config or {}
            local buttonName = config.Name or "Button"
            local buttonCallback = config.Callback or function() end
            local isLocked = config.Locked or false
            
            local buttonFrame = Instance.new("Frame")
            buttonFrame.Size = UDim2.new(1, 0, 0, 45)
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
            buttonLabel.Size = UDim2.new(1, -100, 1, 0)
            buttonLabel.Position = UDim2.new(0, 15, 0, 0)
            buttonLabel.BackgroundTransparency = 1
            buttonLabel.Text = buttonName
            buttonLabel.Font = Enum.Font.Gotham
            buttonLabel.TextSize = 14
            buttonLabel.TextColor3 = isLocked and Colors.TextSecondary or Colors.Text
            buttonLabel.TextXAlignment = Enum.TextXAlignment.Left
            buttonLabel.Parent = buttonFrame
            
            if isLocked then
                local lockIcon = Instance.new("TextLabel")
                lockIcon.Size = UDim2.new(0, 30, 0, 30)
                lockIcon.Position = UDim2.new(1, -40, 0.5, -15)
                lockIcon.BackgroundColor3 = Colors.Background
                lockIcon.Text = Icons.Lock
                lockIcon.Font = Enum.Font.GothamBold
                lockIcon.TextSize = 14
                lockIcon.TextColor3 = Colors.TextSecondary
                lockIcon.Parent = buttonFrame
                Utility:CreateCorner(lockIcon, 6)
                
                local lockLabel = Instance.new("TextLabel")
                lockLabel.Size = UDim2.new(0, 60, 0, 20)
                lockLabel.Position = UDim2.new(1, -100, 0.5, -10)
                lockLabel.BackgroundTransparency = 1
                lockLabel.Text = "Locked"
                lockLabel.Font = Enum.Font.Gotham
                lockLabel.TextSize = 12
                lockLabel.TextColor3 = Colors.TextSecondary
                lockLabel.TextXAlignment = Enum.TextXAlignment.Right
                lockLabel.Parent = buttonFrame
            else
                local arrowIcon = Instance.new("TextLabel")
                arrowIcon.Size = UDim2.new(0, 30, 0, 30)
                arrowIcon.Position = UDim2.new(1, -35, 0.5, -15)
                arrowIcon.BackgroundTransparency = 1
                arrowIcon.Text = Icons.ChevronRight
                arrowIcon.Font = Enum.Font.GothamBold
                arrowIcon.TextSize = 20
                arrowIcon.TextColor3 = Colors.TextSecondary
                arrowIcon.Parent = buttonFrame
                
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
            toggleFrame.Size = UDim2.new(1, 0, 0, 45)
            toggleFrame.BackgroundColor3 = Colors.Surface
            toggleFrame.BorderSizePixel = 0
            toggleFrame.Parent = tabContent
            Utility:CreateCorner(toggleFrame, 8)
            
            local toggleLabel = Instance.new("TextLabel")
            toggleLabel.Size = UDim2.new(1, -70, 1, 0)
            toggleLabel.Position = UDim2.new(0, 15, 0, 0)
            toggleLabel.BackgroundTransparency = 1
            toggleLabel.Text = toggleName
            toggleLabel.Font = Enum.Font.Gotham
            toggleLabel.TextSize = 14
            toggleLabel.TextColor3 = Colors.Text
            toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            toggleLabel.Parent = toggleFrame
            
            local toggleButton = Instance.new("TextButton")
            toggleButton.Size = UDim2.new(0, 50, 0, 26)
            toggleButton.Position = UDim2.new(1, -60, 0.5, -13)
            toggleButton.BackgroundColor3 = Colors.Background
            toggleButton.Text = ""
            toggleButton.AutoButtonColor = false
            toggleButton.Parent = toggleFrame
            Utility:CreateCorner(toggleButton, 13)
            
            local toggleCircle = Instance.new("Frame")
            toggleCircle.Size = UDim2.new(0, 20, 0, 20)
            toggleCircle.Position = UDim2.new(0, 3, 0.5, -10)
            toggleCircle.BackgroundColor3 = Colors.TextSecondary
            toggleCircle.BorderSizePixel = 0
            toggleCircle.Parent = toggleButton
            Utility:CreateCorner(toggleCircle, 10)
            
            local isToggled = toggleDefault
            
            local function UpdateToggle(instant)
                local duration = instant and 0 or 0.2
                if isToggled then
                    Utility:Tween(toggleButton, {BackgroundColor3 = Colors.Primary}, duration)
                    Utility:Tween(toggleCircle, {
                        Position = UDim2.new(0, 27, 0.5, -10),
                        BackgroundColor3 = Colors.Text
                    }, duration)
                else
                    Utility:Tween(toggleButton, {BackgroundColor3 = Colors.Background}, duration)
                    Utility:Tween(toggleCircle, {
                        Position = UDim2.new(0, 3, 0.5, -10),
                        BackgroundColor3 = Colors.TextSecondary
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
            sliderFrame.Size = UDim2.new(1, 0, 0, 60)
            sliderFrame.BackgroundColor3 = Colors.Surface
            sliderFrame.BorderSizePixel = 0
            sliderFrame.Parent = tabContent
            Utility:CreateCorner(sliderFrame, 8)
            
            local sliderLabel = Instance.new("TextLabel")
            sliderLabel.Size = UDim2.new(0.7, 0, 0, 25)
            sliderLabel.Position = UDim2.new(0, 15, 0, 8)
            sliderLabel.BackgroundTransparency = 1
            sliderLabel.Text = sliderName
            sliderLabel.Font = Enum.Font.Gotham
            sliderLabel.TextSize = 14
            sliderLabel.TextColor3 = Colors.Text
            sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            sliderLabel.Parent = sliderFrame
            
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(0, 60, 0, 25)
            valueLabel.Position = UDim2.new(1, -70, 0, 8)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = tostring(sliderDefault)
            valueLabel.Font = Enum.Font.GothamBold
            valueLabel.TextSize = 14
            valueLabel.TextColor3 = Colors.Primary
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Parent = sliderFrame
            
            local sliderTrack = Instance.new("Frame")
            sliderTrack.Size = UDim2.new(1, -30, 0, 4)
            sliderTrack.Position = UDim2.new(0, 15, 1, -20)
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
            
            local sliderButton = Instance.new("TextButton")
            sliderButton.Size = UDim2.new(1, 0, 1, 0)
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
                valueLabel.Text = tostring(value)
                task.spawn(sliderCallback, value)
            end
            
            sliderButton.MouseButton1Down:Connect(function()
                draggingSlider = true
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                    UpdateSlider(input)
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
            
            local dropdownFrame = Instance.new("Frame")
            dropdownFrame.Size = UDim2.new(1, 0, 0, 45)
            dropdownFrame.BackgroundColor3 = Colors.Surface
            dropdownFrame.BorderSizePixel = 0
            dropdownFrame.Parent = tabContent
            dropdownFrame.ClipsDescendants = false
            dropdownFrame.ZIndex = 2
            Utility:CreateCorner(dropdownFrame, 8)
            
            local dropdownLabel = Instance.new("TextLabel")
            dropdownLabel.Size = UDim2.new(1, -30, 0, 20)
            dropdownLabel.Position = UDim2.new(0, 15, 0, 5)
            dropdownLabel.BackgroundTransparency = 1
            dropdownLabel.Text = dropdownName
            dropdownLabel.Font = Enum.Font.Gotham
            dropdownLabel.TextSize = 12
            dropdownLabel.TextColor3 = Colors.TextSecondary
            dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
            dropdownLabel.Parent = dropdownFrame
            
            local dropdownButton = Instance.new("TextButton")
            dropdownButton.Size = UDim2.new(1, -30, 0, 20)
            dropdownButton.Position = UDim2.new(0, 15, 0, 20)
            dropdownButton.BackgroundColor3 = Colors.Background
            dropdownButton.Text = ""
            dropdownButton.AutoButtonColor = false
            dropdownButton.Parent = dropdownFrame
            Utility:CreateCorner(dropdownButton, 6)
            
            local selectedLabel = Instance.new("TextLabel")
            selectedLabel.Size = UDim2.new(1, -30, 1, 0)
            selectedLabel.Position = UDim2.new(0, 10, 0, 0)
            selectedLabel.BackgroundTransparency = 1
            selectedLabel.Text = dropdownDefault
            selectedLabel.Font = Enum.Font.Gotham
            selectedLabel.TextSize = 13
            selectedLabel.TextColor3 = Colors.Text
            selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
            selectedLabel.TextTruncate = Enum.TextTruncate.AtEnd
            selectedLabel.Parent = dropdownButton
            
            local chevronIcon = Instance.new("TextLabel")
            chevronIcon.Size = UDim2.new(0, 20, 1, 0)
            chevronIcon.Position = UDim2.new(1, -20, 0, 0)
            chevronIcon.BackgroundTransparency = 1
            chevronIcon.Text = Icons.ChevronDown
            chevronIcon.Font = Enum.Font.GothamBold
            chevronIcon.TextSize = 16
            chevronIcon.TextColor3 = Colors.TextSecondary
            chevronIcon.Parent = dropdownButton
            
            local optionsFrame = Instance.new("Frame")
            optionsFrame.Size = UDim2.new(1, -30, 0, 0)
            optionsFrame.Position = UDim2.new(0, 15, 0, 45)
            optionsFrame.BackgroundColor3 = Colors.SurfaceHover
            optionsFrame.BorderSizePixel = 0
            optionsFrame.Visible = false
            optionsFrame.ClipsDescendants = true
            optionsFrame.ZIndex = 3
            optionsFrame.Parent = dropdownFrame
            Utility:CreateCorner(optionsFrame, 6)
            Utility:CreateStroke(optionsFrame, Colors.Border, 1)
            
            local optionsList = Utility:CreateListLayout(optionsFrame, 2)
            Utility:CreatePadding(optionsFrame, 4)
            
            local isOpen = false
            local currentValue = dropdownDefault
            
            for _, option in ipairs(dropdownOptions) do
                local optionButton = Instance.new("TextButton")
                optionButton.Size = UDim2.new(1, 0, 0, 30)
                optionButton.BackgroundColor3 = option == currentValue and Colors.Primary or Colors.Surface
                optionButton.BackgroundTransparency = option == currentValue and 0.8 or 1
                optionButton.Text = ""
                optionButton.AutoButtonColor = false
                optionButton.Parent = optionsFrame
                Utility:CreateCorner(optionButton, 4)
                
                local optionLabel = Instance.new("TextLabel")
                optionLabel.Size = UDim2.new(1, -20, 1, 0)
                optionLabel.Position = UDim2.new(0, 10, 0, 0)
                optionLabel.BackgroundTransparency = 1
                optionLabel.Text = option
                optionLabel.Font = Enum.Font.Gotham
                optionLabel.TextSize = 13
                optionLabel.TextColor3 = Colors.Text
                optionLabel.TextXAlignment = Enum.TextXAlignment.Left
                optionLabel.Parent = optionButton
                
                optionButton.MouseButton1Click:Connect(function()
                    currentValue = option
                    selectedLabel.Text = option
                    
                    for _, child in ipairs(optionsFrame:GetChildren()) do
                        if child:IsA("TextButton") then
                            Utility:Tween(child, {
                                BackgroundTransparency = 1,
                                BackgroundColor3 = Colors.Surface
                            })
                        end
                    end
                    
                    Utility:Tween(optionButton, {
                        BackgroundTransparency = 0.8,
                        BackgroundColor3 = Colors.Primary
                    })
                    
                    isOpen = false
                    Utility:Tween(optionsFrame, {Size = UDim2.new(1, -30, 0, 0)}, 0.2)
                    Utility:Tween(chevronIcon, {Rotation = 0}, 0.2)
                    task.wait(0.2)
                    optionsFrame.Visible = false
                    
                    task.spawn(dropdownCallback, option)
                end)
                
                optionButton.MouseEnter:Connect(function()
                    if option ~= currentValue then
                        Utility:Tween(optionButton, {BackgroundTransparency = 0.5})
                    end
                end)
                
                optionButton.MouseLeave:Connect(function()
                    if option ~= currentValue then
                        Utility:Tween(optionButton, {BackgroundTransparency = 1})
                    end
                end)
            end
            
            optionsList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if isOpen then
                    local targetSize = math.min(optionsList.AbsoluteContentSize.Y + 8, 150)
                    optionsFrame.Size = UDim2.new(1, -30, 0, targetSize)
                end
            end)
            
            dropdownButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                
                if isOpen then
                    optionsFrame.Visible = true
                    local targetSize = math.min(optionsList.AbsoluteContentSize.Y + 8, 150)
                    Utility:Tween(optionsFrame, {Size = UDim2.new(1, -30, 0, targetSize)}, 0.2)
                    Utility:Tween(chevronIcon, {Rotation = 180}, 0.2)
                    Utility:Tween(dropdownFrame, {Size = UDim2.new(1, 0, 0, 45 + targetSize + 5)}, 0.2)
                else
                    Utility:Tween(optionsFrame, {Size = UDim2.new(1, -30, 0, 0)}, 0.2)
                    Utility:Tween(chevronIcon, {Rotation = 0}, 0.2)
                    Utility:Tween(dropdownFrame, {Size = UDim2.new(1, 0, 0, 45)}, 0.2)
                    task.wait(0.2)
                    optionsFrame.Visible = false
                end
            end)
            
            dropdownButton.MouseEnter:Connect(function()
                Utility:Tween(dropdownButton, {BackgroundColor3 = Colors.SurfaceHover})
            end)
            
            dropdownButton.MouseLeave:Connect(function()
                Utility:Tween(dropdownButton, {BackgroundColor3 = Colors.Background})
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
            inputFrame.Size = UDim2.new(1, 0, 0, 80)
            inputFrame.BackgroundColor3 = Colors.Surface
            inputFrame.BorderSizePixel = 0
            inputFrame.Parent = tabContent
            Utility:CreateCorner(inputFrame, 8)
            
            local inputLabel = Instance.new("TextLabel")
            inputLabel.Size = UDim2.new(1, -30, 0, 25)
            inputLabel.Position = UDim2.new(0, 15, 0, 8)
            inputLabel.BackgroundTransparency = 1
            inputLabel.Text = inputName
            inputLabel.Font = Enum.Font.Gotham
            inputLabel.TextSize = 14
            inputLabel.TextColor3 = Colors.Text
            inputLabel.TextXAlignment = Enum.TextXAlignment.Left
            inputLabel.Parent = inputFrame
            
            local inputBox = Instance.new("TextBox")
            inputBox.Size = UDim2.new(1, -30, 0, 35)
            inputBox.Position = UDim2.new(0, 15, 0, 38)
            inputBox.BackgroundColor3 = Colors.Background
            inputBox.PlaceholderText = inputPlaceholder
            inputBox.PlaceholderColor3 = Colors.TextSecondary
            inputBox.Text = inputDefault
            inputBox.Font = Enum.Font.Gotham
            inputBox.TextSize = 13
            inputBox.TextColor3 = Colors.Text
            inputBox.TextXAlignment = Enum.TextXAlignment.Left
            inputBox.ClearTextOnFocus = false
            inputBox.Parent = inputFrame
            Utility:CreateCorner(inputBox, 6)
            Utility:CreatePadding(inputBox, {Left = 10, Right = 10})
            
            inputBox.Focused:Connect(function()
                Utility:CreateStroke(inputBox, Colors.Primary, 2)
            end)
            
            inputBox.FocusLost:Connect(function(enterPressed)
                for _, child in ipairs(inputBox:GetChildren()) do
                    if child:IsA("UIStroke") then
                        child:Destroy()
                    end
                end
                if enterPressed then
                    task.spawn(inputCallback, inputBox.Text)
                end
            end)
            
            return inputFrame
        end
        
        function Tab:CreateLabel(text)
            local labelFrame = Instance.new("Frame")
            labelFrame.Size = UDim2.new(1, 0, 0, 35)
            labelFrame.BackgroundColor3 = Colors.Surface
            labelFrame.BorderSizePixel = 0
            labelFrame.Parent = tabContent
            Utility:CreateCorner(labelFrame, 8)
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -30, 1, 0)
            label.Position = UDim2.new(0, 15, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = text
            label.Font = Enum.Font.Gotham
            label.TextSize = 14
            label.TextColor3 = Colors.Text
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextWrapped = true
            label.Parent = labelFrame
            
            return labelFrame
        end
        
        function Tab:CreateSection(title)
            local sectionFrame = Instance.new("Frame")
            sectionFrame.Size = UDim2.new(1, 0, 0, 30)
            sectionFrame.BackgroundTransparency = 1
            sectionFrame.Parent = tabContent
            
            local sectionLabel = Instance.new("TextLabel")
            sectionLabel.Size = UDim2.new(1, -30, 1, 0)
            sectionLabel.Position = UDim2.new(0, 15, 0, 0)
            sectionLabel.BackgroundTransparency = 1
            sectionLabel.Text = title
            sectionLabel.Font = Enum.Font.GothamBold
            sectionLabel.TextSize = 16
            sectionLabel.TextColor3 = Colors.Text
            sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            sectionLabel.Parent = sectionFrame
            
            local divider = Instance.new("Frame")
            divider.Size = UDim2.new(1, -30, 0, 1)
            divider.Position = UDim2.new(0, 15, 1, -5)
            divider.BackgroundColor3 = Colors.Border
            divider.BorderSizePixel = 0
            divider.Parent = sectionFrame
            
            return sectionFrame
        end
        
        return Tab
    end
    
    Utility:Tween(mainFrame, {Size = windowSize}, 0.3, Enum.EasingStyle.Back)
    
    return Window
end

return FluentHub