-- Services 
local InputService  = game:GetService("UserInputService")
local HttpService   = game:GetService("HttpService")
local GuiService    = game:GetService("GuiService")
local RunService    = game:GetService("RunService")
local CoreGui       = game:GetService("CoreGui")
local TweenService  = game:GetService("TweenService")
local Workspace     = game:GetService("Workspace")
local Players       = game:GetService("Players")

local lp            = Players.LocalPlayer
local mouse         = lp:GetMouse()

-- Short aliases
local vec2          = Vector2.new
local dim2          = UDim2.new
local dim           = UDim.new
local rect          = Rect.new
local dim_offset    = UDim2.fromOffset
local rgb           = Color3.fromRGB
local hex           = Color3.fromHex

-- Library init / globals
getgenv().Bypass = getgenv().Bypass or {}
local Bypass = getgenv().Bypass

Bypass.Directory    = "Bypass.gg"
Bypass.Folders      = {"/configs"}
Bypass.Flags        = {}
Bypass.ConfigFlags  = {}
Bypass.Connections  = {}
Bypass.Notifications= {Notifs = {}}
Bypass.__index      = Bypass

local Flags          = Bypass.Flags
local ConfigFlags    = Bypass.ConfigFlags
local Notifications  = Bypass.Notifications

local themes = {
    preset = {
        accent       = rgb(236, 104, 255),
        glow         = rgb(184, 94, 255),
        
        background   = rgb(25, 18, 35),
        section      = rgb(34, 24, 46),
        element      = rgb(52, 36, 71),
        control_dark = rgb(42, 27, 58),
        
        outline      = rgb(96, 69, 127),
        text         = rgb(245, 245, 245),   
        subtext      = rgb(198, 176, 220),
        
        tab_active   = rgb(222, 111, 255),
        tab_inactive = rgb(44, 30, 60),
    },
    utility = {}
}

for property, _ in themes.preset do
    themes.utility[property] = {
        BackgroundColor3 = {}, TextColor3 = {}, ImageColor3 = {}, Color = {}, ScrollBarImageColor3 = {}
    }
end

local Keys = {
    [Enum.KeyCode.LeftShift] = "LS", [Enum.KeyCode.RightShift] = "RS",
    [Enum.KeyCode.LeftControl] = "LC", [Enum.KeyCode.RightControl] = "RC",
    [Enum.KeyCode.Insert] = "INS", [Enum.KeyCode.Backspace] = "BS",
    [Enum.KeyCode.Return] = "Ent", [Enum.KeyCode.Escape] = "ESC",
    [Enum.KeyCode.Space] = "SPC", [Enum.UserInputType.MouseButton1] = "MB1",
    [Enum.UserInputType.MouseButton2] = "MB2", [Enum.UserInputType.MouseButton3] = "MB3"
}

local STREAMER_MASK_NAME = "Hidden User"
local STREAMER_MASK_DISPLAY = "Hidden Display"
local STREAMER_AVATAR = "rbxthumb://type=AvatarHeadShot&id=1&w=48&h=48"

-- Streamer mode removed: no global text masking cache required
Bypass.StreamerRoots = Bypass.StreamerRoots or setmetatable({}, { __mode = "k" })

local function getViewportSize()
    local camera = Workspace.CurrentCamera
    if camera then
        return camera.ViewportSize
    end

    return vec2(1280, 720)
end

local function getIdentityText()
    if lp.DisplayName and lp.DisplayName ~= lp.Name then
        return string.format("%s (@%s)", lp.DisplayName, lp.Name)
    end

    return lp.Name
end

local function escapePattern(text)
    return tostring(text):gsub("([^%w])", "%%%1")
end

local function maskIdentityText(text)
    if type(text) ~= "string" or text == "" then
        return text
    end

    local masked = text
    if lp.DisplayName and lp.DisplayName ~= "" then
        masked = masked:gsub(escapePattern(lp.DisplayName), STREAMER_MASK_DISPLAY)
    end
    if lp.Name and lp.Name ~= "" then
        masked = masked:gsub(escapePattern(lp.Name), STREAMER_MASK_NAME)
    end

    return masked
end

function Bypass:GetDeviceProfile()
    local viewport = getViewportSize()
    local shortest = math.min(viewport.X, viewport.Y)
    local touchOnly = InputService.TouchEnabled and not InputService.KeyboardEnabled
    local isPhone = touchOnly and shortest <= 820

    return {
        viewport = viewport,
        isPhone = isPhone,
        isTablet = touchOnly and not isPhone,
        isDesktop = not touchOnly,
    }
end

function Bypass:GetResponsiveWindowBounds(profile)
    profile = profile or self:GetDeviceProfile()

    local marginX = profile.isPhone and 20 or 90
    local marginY = profile.isPhone and 28 or 100
    local rawMaxWidth = math.max(300, math.floor(profile.viewport.X - marginX))
    local rawMaxHeight = math.max(320, math.floor(profile.viewport.Y - marginY))
    local minWidth = math.min(profile.isPhone and 300 or 320, rawMaxWidth)
    local minHeight = math.min(profile.isPhone and 390 or 400, rawMaxHeight)

    return {
        min = vec2(minWidth, minHeight),
        max = vec2(rawMaxWidth, rawMaxHeight),
    }
end

function Bypass:GetResponsiveWindowSize(requestedSize)
    local profile = self:GetDeviceProfile()
    local bounds = self:GetResponsiveWindowBounds(profile)
    local requestedWidth = requestedSize and requestedSize.X.Offset or 0
    local requestedHeight = requestedSize and requestedSize.Y.Offset or 0
    local baseWidth = profile.isPhone and 300 or 320
    local baseHeight = profile.isPhone and 390 or 400
    local width = math.clamp(requestedWidth > 0 and requestedWidth or baseWidth, bounds.min.X, bounds.max.X)
    local height = math.clamp(requestedHeight > 0 and requestedHeight or baseHeight, bounds.min.Y, bounds.max.Y)

    return dim_offset(width, height), profile, bounds
end

function Bypass:ClampFrameToViewport(frame)
    if not frame then return end

    local viewport = getViewportSize()
    local size = frame.AbsoluteSize
    local maxX = math.max(12, viewport.X - size.X - 12)
    local maxY = math.max(12, viewport.Y - size.Y - 12)

    frame.Position = dim_offset(
        math.clamp(frame.Position.X.Offset, 12, maxX),
        math.clamp(frame.Position.Y.Offset, 12, maxY)
    )
end

function Bypass:CenterFrame(frame)
    if not frame then return end

    local viewport = getViewportSize()
    local size = frame.AbsoluteSize
    frame.Position = dim_offset(
        math.floor((viewport.X - size.X) * 0.5),
        math.floor((viewport.Y - size.Y) * 0.5)
    )
end

-- Streamer root registration removed (feature deprecated)

-- Streamer mode removed: ApplyStreamerMode is no longer used

for _, path in Bypass.Folders do
    pcall(function() makefolder(Bypass.Directory .. path) end)
end

-- misc helpers ok 
function Bypass:Tween(Object, Properties, Info)
    if not Object then return end
    local tween = TweenService:Create(Object, Info or TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), Properties)
    tween:Play()
    return tween
end

function Bypass:Create(instance, options)
    local ins = Instance.new(instance)
    for prop, value in options do ins[prop] = value end
    if ins:IsA("TextButton") or ins:IsA("ImageButton") then ins.AutoButtonColor = false end
    return ins
end

-- Much stronger contrast so gradients are very visible on tiny sliders/toggles
local function AddSubtleGradient(parent, rotation)
    return Bypass:Create("UIGradient", {
        Parent = parent,
        Rotation = rotation or 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, rgb(255, 255, 255)),
            ColorSequenceKeypoint.new(1, rgb(110, 110, 110)) -- Darker bottom for highly visible 3D shading
        })
    })
end

function Bypass:Themify(instance, theme, property)
    if not themes.utility[theme] then return end
    table.insert(themes.utility[theme][property], instance)
    instance[property] = themes.preset[theme]
end

function Bypass:RefreshTheme(theme, color3)
    themes.preset[theme] = color3
    for property, instances in themes.utility[theme] do
        for _, object in instances do
            object[property] = color3
        end
    end
end

function Bypass:Resizify(Parent, getSizeLimits)
    local UIS = game:GetService("UserInputService")
    local Resizing = Bypass:Create("TextButton", {
        AnchorPoint = vec2(1, 1), Position = dim2(1, 0, 1, 0), Size = dim2(0, 34, 0, 34),
        BorderSizePixel = 0, BackgroundTransparency = 1, Text = "", Parent = Parent, ZIndex = 999,
    })
    
    local grip = Bypass:Create("ImageLabel", {
        Parent = Resizing,
        AnchorPoint = vec2(1, 1),
        Position = dim2(1, -4, 1, -4),
        Size = dim2(0, 20, 0, 20),
        BackgroundTransparency = 1,
        Image = "rbxassetid://110733736723338",
        ImageColor3 = themes.preset.accent,
        ImageTransparency = 0.5
    })
    
    Bypass:Themify(grip, "accent", "ImageColor3")

    local IsResizing, StartInputPos, StartSize = false, nil, nil

    local function getLimits()
        if getSizeLimits then
            return getSizeLimits()
        end

        return vec2(600, 450), vec2(1000, 800), Bypass:GetDeviceProfile()
    end

    local function refreshGripState()
        local _, _, profile = getLimits()
        Resizing.Visible = not (profile and profile.isPhone)
    end

    refreshGripState()

    Resizing.InputBegan:Connect(function(input)
        local MIN_SIZE, MAX_SIZE, profile = getLimits()
        if profile and profile.isPhone then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            IsResizing = true
            StartInputPos = input.Position
            StartSize = Parent.AbsoluteSize
        end
    end)

    Resizing.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            IsResizing = false
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if not IsResizing then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local MIN_SIZE, MAX_SIZE = getLimits()
            local delta = input.Position - StartInputPos
            Parent.Size = UDim2.fromOffset(
                math.clamp(StartSize.X + delta.X, MIN_SIZE.X, MAX_SIZE.X),
                math.clamp(StartSize.Y + delta.Y, MIN_SIZE.Y, MAX_SIZE.Y)
            )
            Bypass:ClampFrameToViewport(Parent)
        end
    end)

    return Resizing
end

-- window hahaa
function Bypass:Window(properties)
    local requestedSize = properties.Size or properties.size or dim2(0, 720, 0, 500)
    local responsiveSize, deviceProfile, responsiveBounds = Bypass:GetResponsiveWindowSize(requestedSize)
    local Cfg = {
        Title = properties.Title or properties.title or properties.Prefix or "Bypass", 
        Subtitle = properties.Subtitle or properties.subtitle or properties.Suffix or ".cc",
        Size = responsiveSize,
        RequestedSize = requestedSize,
        DeviceProfile = deviceProfile,
        ResponsiveBounds = responsiveBounds,
        TabInfo = nil, Items = {}, Tweening = false, IsSwitchingTab = false;
    }

    if Bypass.Gui then Bypass.Gui:Destroy() end
    if Bypass.Other then Bypass.Other:Destroy() end
    if Bypass.ToggleGui then Bypass.ToggleGui:Destroy() end

    Bypass.Gui = Bypass:Create("ScreenGui", { Parent = CoreGui, Name = "BypassGG", Enabled = true, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
    Bypass.Other = Bypass:Create("ScreenGui", { Parent = CoreGui, Name = "BypassOther", Enabled = false, IgnoreGuiInset = true })
    
    local Items = Cfg.Items
    local uiVisible = true
    local minimizedHeight = 68

    Items.Wrapper = Bypass:Create("Frame", {
        Parent = Bypass.Gui, Position = dim_offset(0, 0),
        Size = Cfg.Size, BackgroundTransparency = 1, BorderSizePixel = 0
    })
    
    Items.Glow = Bypass:Create("ImageLabel", {
        ImageColor3 = themes.preset.glow,
        ScaleType = Enum.ScaleType.Slice,
        ImageTransparency = 0.6499999761581421,
        BorderColor3 = rgb(0, 0, 0),
        Parent = Items.Wrapper,
        Name = "\0",
        Size = dim2(1, 40, 1, 40),
        Image = "rbxassetid://18245826428",
        BackgroundTransparency = 1,
        Position = dim2(0, -20, 0, -20),
        BackgroundColor3 = rgb(255, 255, 255),
        BorderSizePixel = 0,
        SliceCenter = rect(vec2(21, 21), vec2(79, 79)),
        ZIndex = 0
    })
    Bypass:Themify(Items.Glow, "glow", "ImageColor3")

    Items.Window = Bypass:Create("Frame", {
        Parent = Items.Wrapper, Position = dim2(0, 0, 0, 0), Size = dim2(1, 0, 1, 0),
        BackgroundColor3 = themes.preset.background, BorderSizePixel = 0, ZIndex = 1, ClipsDescendants = true
    })
    Bypass:Themify(Items.Window, "background", "BackgroundColor3")
    Bypass:Create("UICorner", { Parent = Items.Window, CornerRadius = dim(0, 6) })
    Bypass:Themify(Bypass:Create("UIStroke", { Parent = Items.Window, Color = themes.preset.outline, Thickness = 1 }), "outline", "Color")
    Bypass:Create("UIGradient", {
        Parent = Items.Window,
        Rotation = 115,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, rgb(46, 31, 64)),
            ColorSequenceKeypoint.new(1, rgb(25, 18, 35))
        })
    })

    Items.Header = Bypass:Create("Frame", { Parent = Items.Window, Size = dim2(1, 0, 0, 56), BackgroundTransparency = 1, Active = true, ZIndex = 2 })

    Items.HeaderLine = Bypass:Create("Frame", {
        Parent = Items.Header,
        AnchorPoint = vec2(0.5, 1),
        Position = dim2(0.5, 0, 1, 0),
        Size = dim2(1, -20, 0, 1),
        BackgroundColor3 = themes.preset.outline,
        BorderSizePixel = 0,
        ZIndex = 2
    })
    Bypass:Themify(Items.HeaderLine, "outline", "BackgroundColor3")

    Items.LogoBlock = Bypass:Create("Frame", {
        Parent = Items.Header, 
        AnchorPoint = vec2(0, 0), 
        Position = dim2(0, 18, 0, 16), 
        Size = dim2(0, 18, 0, 18),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ZIndex = 4
    })
    Bypass:Create("UICorner", { Parent = Items.LogoBlock, CornerRadius = dim(0, 4) })
    Bypass:Themify(Items.LogoBlock, "accent", "BackgroundColor3")
    -- small logo icon (match toggle/open-close image)
    Items.LogoIcon = Bypass:Create("ImageLabel", {
        Parent = Items.LogoBlock,
        AnchorPoint = vec2(0.5, 0.5),
        Position = dim2(0.5, 0.5, 0, 0),
        Size = dim2(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://89870805889915",
        ZIndex = 5
    })

    Items.LogoText = Bypass:Create("TextLabel", {
        Parent = Items.Header, Text = Cfg.Title, TextColor3 = themes.preset.text,
        AnchorPoint = vec2(0, 0), Position = dim2(0, 44, 0, 12), 
        Size = dim2(0, 150, 0, 14),
        BackgroundTransparency = 1, FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4
    })
    Bypass:Themify(Items.LogoText, "text", "TextColor3")

    Items.SubLogoText = Bypass:Create("TextLabel", {
        Parent = Items.Header, Text = Cfg.Subtitle, TextColor3 = themes.preset.subtext,
        AnchorPoint = vec2(0, 0), Position = dim2(0, 44, 0, 28), 
        Size = dim2(0, 170, 0, 12),
        BackgroundTransparency = 1, FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium), TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4
    })
    Bypass:Themify(Items.SubLogoText, "subtext", "TextColor3")

    Items.TabHolder = Bypass:Create("Frame", { 
        Parent = Items.Header, AnchorPoint = vec2(0.5, 0.5), Position = dim2(0.5, 0, 0.5, 0),
        Size = dim2(1, -280, 1, 0), BackgroundTransparency = 1, ZIndex = 4
    })
    Items.TabLayout = Bypass:Create("UIListLayout", { Parent = Items.TabHolder, FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = dim(0, 8) })

    Items.ControlHolder = Bypass:Create("Frame", {
        Parent = Items.Header,
        AnchorPoint = vec2(1, 0.5),
        Position = dim2(1, -18, 0.5, 0),
        Size = dim2(0, 54, 0, 20),
        BackgroundTransparency = 1,
        ZIndex = 5
    })
    Bypass:Create("UIListLayout", {
        Parent = Items.ControlHolder,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = dim(0, 8)
    })

    local function createHeaderCircle(name)
        local button = Bypass:Create("TextButton", {
            Parent = Items.ControlHolder,
            Name = name,
            Size = dim2(0, 18, 0, 18),
            BackgroundColor3 = themes.preset.control_dark,
            BorderSizePixel = 0,
            Text = "",
            ZIndex = 6,
        })
        Bypass:Themify(button, "control_dark", "BackgroundColor3")
        Bypass:Create("UICorner", { Parent = button, CornerRadius = dim(1, 0) })
        Bypass:Themify(Bypass:Create("UIStroke", { Parent = button, Color = themes.preset.outline, Thickness = 1 }), "outline", "Color")
        return button
    end

    Items.MinimizeBtn = createHeaderCircle("Minimize")
    Items.CloseBtn = createHeaderCircle("Close")

    Items.Footer = Bypass:Create("Frame", { 
        Parent = Items.Window, AnchorPoint = vec2(0, 1), Position = dim2(0, 0, 1, 0), 
        Size = dim2(1, 0, 0, 60), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 2 
    })
    -- footer remains for controls; user identity moved to header center
    Items.Status = Bypass:Create("TextLabel", {
        Parent = Items.Footer, Text = "Status : Premium", TextColor3 = themes.preset.subtext,
        AnchorPoint = vec2(0, 0), Position = dim2(0, 58, 0, 28), Size = dim2(0, 200, 0, 12),
        BackgroundTransparency = 1, FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium), TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5
    })
    Bypass:Themify(Items.Status, "subtext", "TextColor3")

    Items.SettingsBtn = Bypass:Create("ImageButton", {
        Parent = Items.Footer, AnchorPoint = vec2(1, 0.5), Position = dim2(1, -22, 0.5, 0),
        Size = dim2(0, 18, 0, 18), BackgroundTransparency = 1, Image = "rbxassetid://11293977610", ImageColor3 = themes.preset.subtext, ZIndex = 5
    })
    Bypass:Themify(Items.SettingsBtn, "subtext", "ImageColor3")
    
    Items.SettingsBtn.MouseButton1Click:Connect(function()
        if Cfg.SettingsTabOpen then Cfg.SettingsTabOpen() end
    end)

    Items.PageHolder = Bypass:Create("Frame", { 
        Parent = Items.Window, Position = dim2(0, 0, 0, 56), Size = dim2(1, 0, 1, -116), 
        BackgroundTransparency = 1, ClipsDescendants = true 
    })

    -- Create centered user info in header (avatar, display name, username)
    local headshot = "rbxthumb://type=AvatarHeadShot&id="..lp.UserId.."&w=48&h=48"
    Items.CenterInfo = Bypass:Create("Frame", {
        Parent = Items.Header, AnchorPoint = vec2(0.5, 0), Position = dim2(0.5, 0, 0, 6),
        Size = dim2(0, 220, 0, 36), BackgroundTransparency = 1, ZIndex = 5
    })

    Items.AvatarFrame = Bypass:Create("Frame", {
        Parent = Items.CenterInfo, AnchorPoint = vec2(0, 0.5), Position = dim2(0, 0, 0.5, 0),
        Size = dim2(0, 28, 0, 28), BackgroundColor3 = themes.preset.element, BorderSizePixel = 0, ZIndex = 6
    })
    Bypass:Themify(Items.AvatarFrame, "element", "BackgroundColor3")
    Bypass:Create("UICorner", { Parent = Items.AvatarFrame, CornerRadius = dim(0, 6) })

    Items.Avatar = Bypass:Create("ImageLabel", {
        Parent = Items.AvatarFrame, AnchorPoint = vec2(0.5, 0.5), Position = dim2(0.5, 0, 0.5, 0),
        Size = dim2(1, 0, 1, 0), BackgroundTransparency = 1, Image = headshot, ZIndex = 7
    })
    Bypass:Create("UICorner", { Parent = Items.Avatar, CornerRadius = dim(0, 6) })

    Items.Username = Bypass:Create("TextLabel", {
        Parent = Items.CenterInfo, Text = getIdentityText(), TextColor3 = themes.preset.text,
        AnchorPoint = vec2(0, 0), Position = dim2(0, 44, 0, 4), Size = dim2(1, -44, 0, 12),
        BackgroundTransparency = 1, FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium), TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6
    })
    Bypass:Themify(Items.Username, "text", "TextColor3")

    Items.Status = Bypass:Create("TextLabel", {
        Parent = Items.CenterInfo, Text = "Status: Premium", TextColor3 = themes.preset.subtext,
        AnchorPoint = vec2(0, 0), Position = dim2(0, 44, 0, 18), Size = dim2(1, -44, 0, 10),
        BackgroundTransparency = 1, FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium), TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6
    })
    Bypass:Themify(Items.Status, "subtext", "TextColor3")

    -- Streamer mode now only affects the header username/display name.
    -- No automatic registration of external GUIs to avoid masking unrelated text.

    -- Dragging Logic
    local Dragging, DragInput, DragStart, StartPos
    Items.Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true; DragStart = input.Position; StartPos = Items.Wrapper.Position
        end
    end)
    Items.Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then Dragging = false end
    end)
    InputService.InputChanged:Connect(function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - DragStart
            Items.Wrapper.Position = dim_offset(StartPos.X.Offset + delta.X, StartPos.Y.Offset + delta.Y)
            Bypass:ClampFrameToViewport(Items.Wrapper)
        end
    end)

    local resizeHandle = Bypass:Resizify(Items.Wrapper, function()
        local profile = Bypass:GetDeviceProfile()
        local bounds = Bypass:GetResponsiveWindowBounds(profile)
        return bounds.min, bounds.max, profile
    end)
    Items.ResizeHandle = resizeHandle

    function Cfg.SetMinimized(state)
        if Cfg.IsMinimized == state then return end
        Cfg.IsMinimized = state

        if state then
            Cfg.RestoreSize = dim_offset(Items.Wrapper.AbsoluteSize.X, Items.Wrapper.AbsoluteSize.Y)
            Items.PageHolder.Visible = false
            Items.Footer.Visible = false
            if Items.ResizeHandle then
                Items.ResizeHandle.Visible = false
            end
            Bypass:Tween(Items.Wrapper, {Size = dim_offset(Items.Wrapper.AbsoluteSize.X, minimizedHeight)}, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
        else
            local targetSize = Cfg.RestoreSize or Cfg.Size
            Items.PageHolder.Visible = true
            Items.Footer.Visible = true
            if Items.ResizeHandle then
                Items.ResizeHandle.Visible = not Cfg.DeviceProfile.isPhone
            end
            Bypass:Tween(Items.Wrapper, {Size = targetSize}, TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
        end
    end

    function Cfg.ToggleMenu(bool)
        if Cfg.Tweening then return end
        if bool == nil then uiVisible = not uiVisible else uiVisible = bool end
        if uiVisible and Cfg.IsMinimized then
            Cfg.SetMinimized(false)
        end
        Items.Wrapper.Visible = uiVisible
        if Items.ToggleButton then
            Items.ToggleButton.Visible = true
        end
    end

    Bypass.ToggleGui = Bypass:Create("ScreenGui", { Parent = CoreGui, Name = "BypassToggle", IgnoreGuiInset = true })
    local toggleSize = Cfg.DeviceProfile.isPhone and 48 or 52
    local ToggleButton = Bypass:Create("ImageButton", {
        Name = "ToggleButton",
        Parent = Bypass.ToggleGui,
        Position = dim_offset(Cfg.DeviceProfile.viewport.X - toggleSize - 18, Cfg.DeviceProfile.isPhone and 110 or 130),
        Size = dim_offset(toggleSize, toggleSize),
        BackgroundTransparency = 0,
        BackgroundColor3 = themes.preset.control_dark,
        Image = "rbxassetid://89870805889915",
        Visible = true,
        ZIndex = 10000,
    })
    Items.ToggleButton = ToggleButton
    Bypass:Create("UICorner", { Parent = ToggleButton, CornerRadius = dim(0, 14) })
    Bypass:Themify(ToggleButton, "control_dark", "BackgroundColor3")
    Bypass:Themify(Bypass:Create("UIStroke", { Parent = ToggleButton, Color = themes.preset.outline, Thickness = 1.5 }), "outline", "Color")

    local isTDrag, tDragStart, tStartPos, hasTDragged = false, nil, nil, false
    ToggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isTDrag = true
            hasTDragged = false
            tDragStart = input.Position
            tStartPos = ToggleButton.Position
        end
    end)
    ToggleButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isTDrag = false
            if not hasTDragged then
                Cfg.ToggleMenu(true)
            end
        end
    end)
    InputService.InputChanged:Connect(function(input)
        if isTDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - tDragStart
            if delta.Magnitude > 5 then
                hasTDragged = true
                ToggleButton.Position = dim_offset(tStartPos.X.Offset + delta.X, tStartPos.Y.Offset + delta.Y)
                Bypass:ClampFrameToViewport(ToggleButton)
            end
        end
    end)

    Items.MinimizeBtn.MouseButton1Click:Connect(function()
        Cfg.SetMinimized(not Cfg.IsMinimized)
    end)

    Items.CloseBtn.MouseButton1Click:Connect(function()
        Cfg.ToggleMenu(false)
    end)

    task.defer(function()
        Bypass:CenterFrame(Items.Wrapper)
        Bypass:ClampFrameToViewport(Items.Wrapper)
    end)

    return setmetatable(Cfg, Bypass)
end

-- tabs okk :joy:
function Bypass:Tab(properties)
    local Cfg = { 
        Name = properties.Name or properties.name or "Tab", 
        Icon = properties.Icon or properties.icon or "rbxassetid://11293977610", 
        Hidden = properties.Hidden or properties.hidden or false, 
        Items = {} 
    }
    if tonumber(Cfg.Icon) then Cfg.Icon = "rbxassetid://" .. tostring(Cfg.Icon) end
    local Items = Cfg.Items

    if not Cfg.Hidden then
        local isPhone = Bypass:GetDeviceProfile().isPhone
        Items.Button = Bypass:Create("TextButton", { 
            Parent = self.Items.TabHolder, Size = dim2(0, 0, 0, isPhone and 28 or 30), 
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = themes.preset.tab_inactive,
            BackgroundTransparency = 0, 
            Text = "", AutoButtonColor = false, ZIndex = 5 
        })
        Bypass:Create("UICorner", { Parent = Items.Button, CornerRadius = dim(0, 999) })
        Bypass:Themify(Bypass:Create("UIStroke", { Parent = Items.Button, Color = themes.preset.outline, Thickness = 1 }), "outline", "Color")
        Bypass:Create("UIPadding", {
            Parent = Items.Button,
            PaddingLeft = dim(0, 10),
            PaddingRight = dim(0, 12)
        })
        
        Bypass:Create("UIGradient", {
            Parent = Items.Button,
            Rotation = 25,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.2),
                NumberSequenceKeypoint.new(1, 0.7)
            }),
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, rgb(255, 255, 255)),
                ColorSequenceKeypoint.new(1, rgb(182, 138, 218))
            })
        })
        
        Items.IconImg = Bypass:Create("ImageLabel", { 
            Parent = Items.Button, AnchorPoint = vec2(0, 0.5), Position = dim2(0, 0, 0.5, 0),
            Size = dim2(0, 14, 0, 14), BackgroundTransparency = 1, 
            Image = Cfg.Icon, ImageColor3 = themes.preset.subtext, ZIndex = 6 
        })
        Bypass:Themify(Items.IconImg, "subtext", "ImageColor3")

        Items.ButtonText = Bypass:Create("TextLabel", {
            Parent = Items.Button,
            AutomaticSize = Enum.AutomaticSize.X,
            Position = dim2(0, 20, 0.5, 0),
            AnchorPoint = vec2(0, 0.5),
            Size = dim2(0, 0, 0, 14),
            BackgroundTransparency = 1,
            Text = Cfg.Name,
            TextColor3 = themes.preset.subtext,
            TextSize = isPhone and 11 or 12,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 6
        })
        Bypass:Themify(Items.ButtonText, "subtext", "TextColor3")
    end

    Items.Pages = Bypass:Create("CanvasGroup", { Parent = Bypass.Other, Size = dim2(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, GroupTransparency = 1 })
    local isPhone = Bypass:GetDeviceProfile().isPhone
    Items.PageLayout = Bypass:Create("UIListLayout", { Parent = Items.Pages, FillDirection = isPhone and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal, Padding = dim(0, 14) })
    Bypass:Create("UIPadding", { Parent = Items.Pages, PaddingTop = dim(0, 10), PaddingBottom = dim(0, 10), PaddingRight = dim(0, 20), PaddingLeft = dim(0, 20) })

    Items.Left = Bypass:Create("ScrollingFrame", { 
        Parent = Items.Pages, Size = isPhone and dim2(1, 0, 0.5, -7) or dim2(0.5, -7, 1, 0), BackgroundTransparency = 1, 
        ScrollBarThickness = 0, CanvasSize = dim2(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    Bypass:Create("UIListLayout", { Parent = Items.Left, Padding = dim(0, 14) })
    Bypass:Create("UIPadding", { Parent = Items.Left, PaddingBottom = dim(0, 10) })

    Items.Right = Bypass:Create("ScrollingFrame", { 
        Parent = Items.Pages, Size = isPhone and dim2(1, 0, 0.5, -7) or dim2(0.5, -7, 1, 0), BackgroundTransparency = 1, 
        ScrollBarThickness = 0, CanvasSize = dim2(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    Bypass:Create("UIListLayout", { Parent = Items.Right, Padding = dim(0, 14) })
    Bypass:Create("UIPadding", { Parent = Items.Right, PaddingBottom = dim(0, 10) })

    function Cfg.OpenTab()
        if self.IsSwitchingTab or self.TabInfo == Cfg.Items then return end
        local oldTab = self.TabInfo
        self.IsSwitchingTab = true
        self.TabInfo = Cfg.Items

        local buttonTween = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

        if oldTab and oldTab.Button then
            Bypass:Tween(oldTab.Button, {BackgroundColor3 = themes.preset.tab_inactive}, buttonTween)
            Bypass:Tween(oldTab.IconImg, {ImageColor3 = themes.preset.subtext}, buttonTween)
            if oldTab.ButtonText then
                Bypass:Tween(oldTab.ButtonText, {TextColor3 = themes.preset.subtext}, buttonTween)
            end
        end

        if Items.Button then 
            Bypass:Tween(Items.Button, {BackgroundColor3 = themes.preset.tab_active}, buttonTween)
            Bypass:Tween(Items.IconImg, {ImageColor3 = rgb(255, 255, 255)}, buttonTween)
            if Items.ButtonText then
                Bypass:Tween(Items.ButtonText, {TextColor3 = rgb(255, 255, 255)}, buttonTween)
            end
        end
        
        task.spawn(function()
            if oldTab then
                Bypass:Tween(oldTab.Pages, {GroupTransparency = 1, Position = dim2(0, 0, 0, 10)}, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
                task.wait(0.2)
                oldTab.Pages.Visible = false
                oldTab.Pages.Parent = Bypass.Other
            end

            Items.Pages.Position = dim2(0, 0, 0, 10) 
            Items.Pages.GroupTransparency = 1
            Items.Pages.Parent = self.Items.PageHolder
            Items.Pages.Visible = true

            Bypass:Tween(Items.Pages, {GroupTransparency = 0, Position = dim2(0, 0, 0, 0)}, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
            task.wait(0.35)
            
            Items.Pages.GroupTransparency = 0 
            self.IsSwitchingTab = false
        end)
    end

    if Items.Button then Items.Button.MouseButton1Down:Connect(Cfg.OpenTab) end
    if not self.TabInfo and not Cfg.Hidden then Cfg.OpenTab() end
    return setmetatable(Cfg, Bypass)
end

-- sections okk
function Bypass:Section(properties)
    local Cfg = { 
        Name = properties.Name or properties.name or "Section", 
        Side = properties.Side or properties.side or "Left", 
        RightIcon = properties.RightIcon or properties.righticon or "rbxassetid://12338898398",
        Items = {} 
    }
    Cfg.Side = (Cfg.Side:lower() == "right") and "Right" or "Left"
    local Items = Cfg.Items

    Items.Section = Bypass:Create("Frame", { 
        Parent = self.Items[Cfg.Side], Size = dim2(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, 
        BackgroundColor3 = themes.preset.section, BorderSizePixel = 0, ClipsDescendants = true 
    })
    Bypass:Themify(Items.Section, "section", "BackgroundColor3")
    Bypass:Create("UICorner", { Parent = Items.Section, CornerRadius = dim(0, 6) })
    
    -- Gradient for Section background
    Bypass:Create("UIGradient", {
        Parent = Items.Section, Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, rgb(255, 255, 255)),
            ColorSequenceKeypoint.new(1, rgb(225, 225, 225))
        })
    })

    -- THE RED LINE ACCENT ON LEFT SIDE
    Items.AccentLine = Bypass:Create("Frame", {
        Parent = Items.Section, Size = dim2(0, 2, 1, 0), Position = dim2(0, 0, 0, 0),
        BackgroundColor3 = themes.preset.accent, BorderSizePixel = 0, ZIndex = 2
    })
    Bypass:Themify(Items.AccentLine, "accent", "BackgroundColor3")

    -- Gradient fade for AccentLine
    Bypass:Create("UIGradient", {
        Parent = Items.AccentLine, Rotation = 90,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.6, 0),
            NumberSequenceKeypoint.new(1, 1) -- Fades out completely at bottom
        })
    })

    Items.Header = Bypass:Create("Frame", { Parent = Items.Section, Size = dim2(1, 0, 0, 36), BackgroundTransparency = 1 })
    
    -- Section Title (Shifted left since there's no icon anymore)
    Items.Title = Bypass:Create("TextLabel", { 
        Parent = Items.Header, Position = dim2(0, 14, 0.5, 0), AnchorPoint = vec2(0, 0.5), Size = dim2(1, -46, 0, 14), 
        BackgroundTransparency = 1, Text = Cfg.Name, TextColor3 = themes.preset.text, FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left 
    })
    Bypass:Themify(Items.Title, "text", "TextColor3")

    Items.Chevron = Bypass:Create("ImageLabel", {
        Parent = Items.Header, Position = dim2(1, -14, 0.5, 0), AnchorPoint = vec2(1, 0.5), Size = dim2(0, 12, 0, 12),
        BackgroundTransparency = 1, Image = Cfg.RightIcon, ImageColor3 = themes.preset.subtext, 
        Rotation = 0
    })
    Bypass:Themify(Items.Chevron, "subtext", "ImageColor3")

    Items.Container = Bypass:Create("Frame", { 
        Parent = Items.Section, Position = dim2(0, 0, 0, 36), Size = dim2(1, 0, 0, 0), 
        AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 
    })
    Bypass:Create("UIListLayout", { Parent = Items.Container, Padding = dim(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })
    Bypass:Create("UIPadding", { Parent = Items.Container, PaddingBottom = dim(0, 12), PaddingLeft = dim(0, 14), PaddingRight = dim(0, 14) })

    return setmetatable(Cfg, Bypass)
end

-- elements okk
function Bypass:Toggle(properties)
    local Cfg = { 
        Name = properties.Name or properties.name or "Toggle", 
        Flag = properties.Flag or properties.flag, 
        Default = properties.Default or properties.default or false, 
        Callback = properties.Callback or properties.callback or function() end, 
        Items = {} 
    }
    local Items = Cfg.Items

    Items.Button = Bypass:Create("TextButton", { Parent = self.Items.Container, Size = dim2(1, 0, 0, 22), BackgroundTransparency = 1, Text = "" })
    
    Items.Checkbox = Bypass:Create("Frame", { 
        Parent = Items.Button, AnchorPoint = vec2(0, 0.5), Position = dim2(0, 6, 0.5, 0), Size = dim2(0, 14, 0, 14), 
        BackgroundColor3 = themes.preset.element, BorderSizePixel = 0 
    })
    Bypass:Themify(Items.Checkbox, "element", "BackgroundColor3")
    Bypass:Create("UICorner", { Parent = Items.Checkbox, CornerRadius = dim(0, 3) })
    AddSubtleGradient(Items.Checkbox, 90) -- ADDED: Gradient to the empty background box

    Items.CheckFill = Bypass:Create("Frame", {
        Parent = Items.Checkbox, Size = dim2(1, 0, 1, 0),
        BackgroundColor3 = themes.preset.accent, BorderSizePixel = 0,
        BackgroundTransparency = 1
    })
    Bypass:Themify(Items.CheckFill, "accent", "BackgroundColor3")
    Bypass:Create("UICorner", { Parent = Items.CheckFill, CornerRadius = dim(0, 3) })
    AddSubtleGradient(Items.CheckFill, 90) -- Toggle gradient on the filled box

    Items.Title = Bypass:Create("TextLabel", { 
        Parent = Items.Button, Position = dim2(0, 30, 0.5, 0), AnchorPoint = vec2(0, 0.5), Size = dim2(1, -26, 1, 0), 
        BackgroundTransparency = 1, Text = Cfg.Name, TextColor3 = themes.preset.subtext, TextSize = 13, FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium), TextXAlignment = Enum.TextXAlignment.Left 
    })
    Bypass:Themify(Items.Title, "subtext", "TextColor3")

    local State = false
    function Cfg.set(bool)
        State = bool
        Bypass:Tween(Items.CheckFill, {BackgroundTransparency = State and 0 or 1}, TweenInfo.new(0.2))
        Bypass:Tween(Items.Title, {TextColor3 = State and themes.preset.text or themes.preset.subtext}, TweenInfo.new(0.2))
        if Cfg.Flag then Flags[Cfg.Flag] = State end
        Cfg.Callback(State)
    end

    Items.Button.MouseButton1Click:Connect(function() Cfg.set(not State) end)
    if Cfg.Default then Cfg.set(true) end
    if Cfg.Flag then ConfigFlags[Cfg.Flag] = Cfg.set end

    return setmetatable(Cfg, Bypass)
end

function Bypass:Button(properties)
    local Cfg = { 
        Name = properties.Name or properties.name or "Button", 
        Callback = properties.Callback or properties.callback or function() end, 
        Items = {} 
    }
    local Items = Cfg.Items

    Items.Button = Bypass:Create("TextButton", { 
        Parent = self.Items.Container, Size = dim2(1, 0, 0, 30), BackgroundColor3 = themes.preset.element, 
        Text = Cfg.Name, TextColor3 = themes.preset.subtext, TextSize = 13, FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium), AutoButtonColor = false 
    })
    Bypass:Themify(Items.Button, "element", "BackgroundColor3")
    Bypass:Themify(Items.Button, "subtext", "TextColor3")
    Bypass:Create("UICorner", { Parent = Items.Button, CornerRadius = dim(0, 4) })
    AddSubtleGradient(Items.Button, 90) -- Button Gradient

    Items.Button.MouseButton1Click:Connect(function()
        Bypass:Tween(Items.Button, {BackgroundColor3 = themes.preset.outline, TextColor3 = themes.preset.text}, TweenInfo.new(0.1))
        task.wait(0.1)
        Bypass:Tween(Items.Button, {BackgroundColor3 = themes.preset.element, TextColor3 = themes.preset.subtext}, TweenInfo.new(0.2))
        Cfg.Callback()
    end)
    return setmetatable(Cfg, Bypass)
end

function Bypass:Slider(properties)
    local Cfg = { 
        Name = properties.Name or properties.name or "Slider", 
        Flag = properties.Flag or properties.flag, 
        Min = properties.Min or properties.min or 0, 
        Max = properties.Max or properties.max or 100, 
        Default = properties.Default or properties.default or properties.Value or properties.value or 0, 
        Increment = properties.Increment or properties.increment or 1, 
        Suffix = properties.Suffix or properties.suffix or "", 
        Callback = properties.Callback or properties.callback or function() end, 
        Items = {} 
    }
    local Items = Cfg.Items

    Items.Container = Bypass:Create("Frame", { Parent = self.Items.Container, Size = dim2(1, 0, 0, 38), BackgroundTransparency = 1 })
    Items.Title = Bypass:Create("TextLabel", { Parent = Items.Container, Size = dim2(1, 0, 0, 20), BackgroundTransparency = 1, Text = "  " .. Cfg.Name, TextColor3 = themes.preset.subtext, TextSize = 13, FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium), TextXAlignment = Enum.TextXAlignment.Left })
    Bypass:Themify(Items.Title, "subtext", "TextColor3")

    Items.Val = Bypass:Create("TextLabel", { Parent = Items.Container, Size = dim2(1, 0, 0, 20), BackgroundTransparency = 1, Text = tostring(Cfg.Default)..Cfg.Suffix, TextColor3 = themes.preset.subtext, TextSize = 13, FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium), TextXAlignment = Enum.TextXAlignment.Right })
    Bypass:Themify(Items.Val, "subtext", "TextColor3")

    Items.Track = Bypass:Create("TextButton", { Parent = Items.Container, Position = dim2(0, 4, 0, 24), Size = dim2(1, -8, 0, 6), BackgroundColor3 = themes.preset.element, Text = "", AutoButtonColor = false })
    Bypass:Themify(Items.Track, "element", "BackgroundColor3")
    Bypass:Create("UICorner", { Parent = Items.Track, CornerRadius = dim(1, 0) })
    AddSubtleGradient(Items.Track, 90) -- Slider Track Gradient

    Items.Fill = Bypass:Create("Frame", { Parent = Items.Track, Size = dim2(0, 0, 1, 0), BackgroundColor3 = themes.preset.accent })
    Bypass:Themify(Items.Fill, "accent", "BackgroundColor3")
    Bypass:Create("UICorner", { Parent = Items.Fill, CornerRadius = dim(1, 0) })
    AddSubtleGradient(Items.Fill, 90) -- Slider Fill Gradient
    
    Items.Knob = Bypass:Create("Frame", { Parent = Items.Fill, AnchorPoint = vec2(0.5, 0.5), Position = dim2(1, 0, 0.5, 0), Size = dim2(0, 12, 0, 12), BackgroundColor3 = themes.preset.accent })
    Bypass:Create("UICorner", { Parent = Items.Knob, CornerRadius = dim(1, 0) })
    Bypass:Themify(Items.Knob, "accent", "BackgroundColor3")
    AddSubtleGradient(Items.Knob, 90) -- ADDED: Gradient on the circular knob itself

    local Value = Cfg.Default
    function Cfg.set(val)
        Value = math.clamp(math.round(val / Cfg.Increment) * Cfg.Increment, Cfg.Min, Cfg.Max)
        Items.Val.Text = tostring(Value) .. Cfg.Suffix
        Bypass:Tween(Items.Fill, {Size = dim2((Value - Cfg.Min) / (Cfg.Max - Cfg.Min), 0, 1, 0)}, TweenInfo.new(0.15))
        if Cfg.Flag then Flags[Cfg.Flag] = Value end
        Cfg.Callback(Value)
    end

    local Dragging = false
    Items.Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then Dragging = true; Cfg.set(Cfg.Min + (Cfg.Max - Cfg.Min) * math.clamp((input.Position.X - Items.Track.AbsolutePosition.X) / Items.Track.AbsoluteSize.X, 0, 1)) end
    end)
    InputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then Dragging = false end
    end)
    InputService.InputChanged:Connect(function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            Cfg.set(Cfg.Min + (Cfg.Max - Cfg.Min) * math.clamp((input.Position.X - Items.Track.AbsolutePosition.X) / Items.Track.AbsoluteSize.X, 0, 1))
        end
    end)

    Cfg.set(Cfg.Default)
    if Cfg.Flag then ConfigFlags[Cfg.Flag] = Cfg.set end
    return setmetatable(Cfg, Bypass)
end

function Bypass:Textbox(properties)
    local Cfg = { 
        Name = properties.Name or properties.name or "", 
        Placeholder = properties.Placeholder or properties.placeholder or "Enter text...", 
        Default = properties.Default or properties.default or "", 
        Flag = properties.Flag or properties.flag, 
        Numeric = properties.Numeric or properties.numeric or false, 
        Callback = properties.Callback or properties.callback or function() end, 
        Items = {} 
    }
    local Items = Cfg.Items

    Items.Container = Bypass:Create("Frame", { Parent = self.Items.Container, Size = dim2(1, 0, 0, 32), BackgroundTransparency = 1 })
    Items.Bg = Bypass:Create("Frame", { Parent = Items.Container, Size = dim2(1, 0, 1, 0), BackgroundColor3 = themes.preset.element })
    Bypass:Themify(Items.Bg, "element", "BackgroundColor3")
    Bypass:Create("UICorner", { Parent = Items.Bg, CornerRadius = dim(0, 4) })
    AddSubtleGradient(Items.Bg, 90) -- Textbox Gradient

    Items.Input = Bypass:Create("TextBox", { 
        Parent = Items.Bg, Position = dim2(0, 12, 0, 0), Size = dim2(1, -24, 1, 0), BackgroundTransparency = 1, 
        Text = Cfg.Default, PlaceholderText = Cfg.Placeholder, TextColor3 = themes.preset.text, PlaceholderColor3 = themes.preset.subtext, 
        TextSize = 13, FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium), TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false 
    })
    Bypass:Themify(Items.Input, "text", "TextColor3")

    function Cfg.set(val)
        if Cfg.Numeric and tonumber(val) == nil and val ~= "" then return end
        Items.Input.Text = tostring(val)
        if Cfg.Flag then Flags[Cfg.Flag] = val end
        Cfg.Callback(val)
    end
    
    Items.Input.FocusLost:Connect(function() Cfg.set(Items.Input.Text) end)
    if Cfg.Default ~= "" then Cfg.set(Cfg.Default) end
    if Cfg.Flag then ConfigFlags[Cfg.Flag] = Cfg.set end

    return setmetatable(Cfg, Bypass)
end

-- animated dropdown lolz with search
function Bypass:Dropdown(properties)
    local Cfg = { 
        Name = properties.Name or properties.name or "Dropdown", 
        Flag = properties.Flag or properties.flag, 
        Options = properties.Options or properties.options or properties.items or {}, 
        Default = properties.Default or properties.default, 
        Callback = properties.Callback or properties.callback or function() end, 
        Items = {} 
    }
    local Items = Cfg.Items
    
    Items.Container = Bypass:Create("Frame", { Parent = self.Items.Container, Size = dim2(1, 0, 0, 46), BackgroundTransparency = 1 })
    Items.Title = Bypass:Create("TextLabel", { Parent = Items.Container, Size = dim2(1, 0, 0, 16), BackgroundTransparency = 1, Text = "  " .. Cfg.Name, TextColor3 = themes.preset.subtext, TextSize = 13, FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium), TextXAlignment = Enum.TextXAlignment.Left })
    Bypass:Themify(Items.Title, "subtext", "TextColor3")

    Items.Main = Bypass:Create("TextButton", { 
        Parent = Items.Container, Position = dim2(0, 0, 0, 20), Size = dim2(1, 0, 0, 26), 
        BackgroundColor3 = themes.preset.element, Text = "", AutoButtonColor = false 
    })
    Bypass:Themify(Items.Main, "element", "BackgroundColor3")
    Bypass:Create("UICorner", { Parent = Items.Main, CornerRadius = dim(0, 4) })
    AddSubtleGradient(Items.Main, 90) -- Dropdown Main Gradient

    Items.SelectedText = Bypass:Create("TextLabel", { Parent = Items.Main, Position = dim2(0, 12, 0, 0), Size = dim2(1, -24, 1, 0), BackgroundTransparency = 1, Text = "...", TextColor3 = themes.preset.subtext, TextSize = 13, FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium), TextXAlignment = Enum.TextXAlignment.Left })
    Bypass:Themify(Items.SelectedText, "subtext", "TextColor3")
    
    Items.Icon = Bypass:Create("ImageLabel", { Parent = Items.Main, Position = dim2(1, -20, 0.5, 0), AnchorPoint = vec2(0, 0.5), Size = dim2(0, 10, 0, 10), BackgroundTransparency = 1, Image = "rbxassetid://12338898398", ImageColor3 = themes.preset.subtext, Rotation = 0 })

    Items.DropFrame = Bypass:Create("Frame", { 
        Parent = Bypass.Gui, Size = dim2(1, 0, 0, 0), Position = dim2(0, 0, 0, 0), 
        BackgroundColor3 = themes.preset.element, Visible = false, ZIndex = 200, ClipsDescendants = true 
    })
    Bypass:Themify(Items.DropFrame, "element", "BackgroundColor3")
    Bypass:Create("UICorner", { Parent = Items.DropFrame, CornerRadius = dim(0, 4) })

    -- Search implementation inside dropdown
    Items.SearchBg = Bypass:Create("Frame", { Parent = Items.DropFrame, Size = dim2(1, -12, 0, 24), Position = dim2(0, 6, 0, 6), BackgroundColor3 = themes.preset.background, BorderSizePixel = 0, BackgroundTransparency = 1, ZIndex = 201 })
    Bypass:Themify(Items.SearchBg, "background", "BackgroundColor3")
    Bypass:Create("UICorner", { Parent = Items.SearchBg, CornerRadius = dim(0, 4) })
    AddSubtleGradient(Items.SearchBg, 90) -- Search Input Gradient

    Items.SearchInput = Bypass:Create("TextBox", {
        Parent = Items.SearchBg, Size = dim2(1, -16, 1, 0), Position = dim2(0, 8, 0, -4), BackgroundTransparency = 1, 
        Text = "", PlaceholderText = "Search...", TextColor3 = themes.preset.text, PlaceholderColor3 = themes.preset.subtext, 
        TextSize = 12, FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium), TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, TextTransparency = 1, ZIndex = 202
    })
    Bypass:Themify(Items.SearchInput, "text", "TextColor3")

    Items.Scroll = Bypass:Create("ScrollingFrame", { 
        Parent = Items.DropFrame, Size = dim2(1, 0, 1, -36), Position = dim2(0, 0, 0, 32), 
        BackgroundTransparency = 1, ScrollBarThickness = 0, BorderSizePixel = 0, ZIndex = 201 
    })
    Bypass:Create("UIListLayout", { Parent = Items.Scroll, SortOrder = Enum.SortOrder.LayoutOrder })

    local Open = false
    local isTweening = false
    local OptionBtns = {}

    function Cfg.UpdatePosition()
        local absPos = Items.Main.AbsolutePosition
        local absSize = Items.Main.AbsoluteSize
        Items.DropFrame.Position = dim2(0, absPos.X, 0, absPos.Y + absSize.Y + 4)
        local visibleCount = 0
        for _, data in ipairs(OptionBtns) do
            if data.btn.Size.Y.Offset > 0 then visibleCount += 1 end
        end
        Items.Scroll.CanvasSize = dim2(0, 0, 0, visibleCount * 24)
    end

    local function FilterOptions()
        local text = Items.SearchInput.Text:lower()
        local visibleCount = 0
        
        for _, data in ipairs(OptionBtns) do
            local btn = data.btn
            local optText = data.text:lower()
            
            if text == "" or optText:find(text) then
                visibleCount += 1
                Bypass:Tween(btn, {Size = dim2(1, 0, 0, 24), TextTransparency = 0}, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
            else
                Bypass:Tween(btn, {Size = dim2(1, 0, 0, 0), TextTransparency = 1}, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
            end
        end
        
        if Open and not isTweening then
            local targetHeight = math.clamp(visibleCount * 24 + 38, 38, 180)
            Bypass:Tween(Items.DropFrame, {Size = dim2(0, Items.Main.AbsoluteSize.X, 0, targetHeight)}, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
            Items.Scroll.CanvasSize = dim2(0, 0, 0, visibleCount * 24)
        end
    end
    Items.SearchInput:GetPropertyChangedSignal("Text"):Connect(FilterOptions)

    local function ToggleDropdown()
        if isTweening then return end
        isTweening = true

        if not Open then
            Items.SearchInput.Text = "" -- Reset before setting Open to true
            Open = true
            
            Items.DropFrame.Visible = true
            Cfg.UpdatePosition()
            Items.DropFrame.Size = dim2(0, Items.Main.AbsoluteSize.X, 0, 0)
            
            local visibleCount = #Cfg.Options
            local targetHeight = math.clamp(visibleCount * 24 + 38, 38, 180)
            
            Bypass:Tween(Items.Icon, {Rotation = 180}, TweenInfo.new(0.3))
            
            -- Tuff Search Animation (Fade & Slide in)
            Items.SearchBg.BackgroundTransparency = 1
            Items.SearchInput.TextTransparency = 1
            Items.SearchInput.Position = dim2(0, 8, 0, -4)
            Bypass:Tween(Items.SearchBg, {BackgroundTransparency = 0}, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
            Bypass:Tween(Items.SearchInput, {TextTransparency = 0, Position = dim2(0, 8, 0, 0)}, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
            
            local tw = Bypass:Tween(Items.DropFrame, {Size = dim2(0, Items.Main.AbsoluteSize.X, 0, targetHeight)}, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
            tw.Completed:Wait()
        else
            Open = false
            Bypass:Tween(Items.Icon, {Rotation = 0}, TweenInfo.new(0.3))
            
            -- Reverse Search Animation
            Bypass:Tween(Items.SearchBg, {BackgroundTransparency = 1}, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In))
            Bypass:Tween(Items.SearchInput, {TextTransparency = 1, Position = dim2(0, 8, 0, -4)}, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In))
            
            local tw = Bypass:Tween(Items.DropFrame, {Size = dim2(0, Items.Main.AbsoluteSize.X, 0, 0)}, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
            tw.Completed:Wait()
            Items.DropFrame.Visible = false
        end
        isTweening = false
    end
    Items.Main.MouseButton1Click:Connect(ToggleDropdown)

    InputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if Open and not isTweening then
                local mx, my = input.Position.X, input.Position.Y
                local p0, s0 = Items.DropFrame.AbsolutePosition, Items.DropFrame.AbsoluteSize
                local p1, s1 = Items.Main.AbsolutePosition, Items.Main.AbsoluteSize
                
                if not (mx >= p0.X and mx <= p0.X + s0.X and my >= p0.Y and my <= p0.Y + s0.Y) and 
                   not (mx >= p1.X and mx <= p1.X + s1.X and my >= p1.Y and my <= p1.Y + s1.Y) then
                    ToggleDropdown()
                end
            end
        end
    end)

    function Cfg.RefreshOptions(newList)
        Cfg.Options = newList or Cfg.Options
        for _, data in ipairs(OptionBtns) do data.btn:Destroy() end
        table.clear(OptionBtns)
        for _, opt in ipairs(Cfg.Options) do
            local btn = Bypass:Create("TextButton", { 
                Parent = Items.Scroll, Size = dim2(1, 0, 0, 24), BackgroundTransparency = 1, 
                Text = "   " .. tostring(opt), TextColor3 = themes.preset.subtext, TextSize = 13, 
                FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 202,
                ClipsDescendants = true -- Required for "tuff" filtering animation
            })
            Bypass:Themify(btn, "subtext", "TextColor3")
            btn.MouseButton1Click:Connect(function() Cfg.set(opt); ToggleDropdown() end)
            table.insert(OptionBtns, {btn = btn, text = tostring(opt)})
        end
        FilterOptions()
    end

    function Cfg.set(val)
        Items.SelectedText.Text = tostring(val)
        if Cfg.Flag then Flags[Cfg.Flag] = val end
        Cfg.Callback(val)
    end

    Cfg.RefreshOptions(Cfg.Options)
    if Cfg.Default then Cfg.set(Cfg.Default) end
    if Cfg.Flag then ConfigFlags[Cfg.Flag] = Cfg.set end

    RunService.RenderStepped:Connect(function() 
        if Open or isTweening then 
            Items.DropFrame.Position = dim2(0, Items.Main.AbsolutePosition.X, 0, Items.Main.AbsolutePosition.Y + Items.Main.AbsoluteSize.Y + 4)
        end 
    end)
    return setmetatable(Cfg, Bypass)
end

function Bypass:Label(properties)
    local Cfg = { 
        Name = properties.Name or properties.name or "Label", 
        Wrapped = properties.Wrapped or properties.wrapped or false, 
        Items = {} 
    }
    local Items = Cfg.Items
    Items.Title = Bypass:Create("TextLabel", { 
        Parent = self.Items.Container, Size = dim2(1, 0, 0, Cfg.Wrapped and 26 or 18), BackgroundTransparency = 1, 
        Text = "  " .. Cfg.Name, TextColor3 = themes.preset.subtext, TextSize = 13, TextWrapped = Cfg.Wrapped, 
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium), TextXAlignment = Enum.TextXAlignment.Left, 
        TextYAlignment = Cfg.Wrapped and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center 
    })
    Bypass:Themify(Items.Title, "subtext", "TextColor3")
    
    function Cfg.set(val) Items.Title.Text = "  " .. tostring(val) end
    return setmetatable(Cfg, Bypass)
end

-- animated colorpicker so sexy 
function Bypass:Colorpicker(properties)
    local Cfg = { 
        Color = properties.Color or properties.color or rgb(255, 255, 255), 
        Callback = properties.Callback or properties.callback or function() end, 
        Flag = properties.Flag or properties.flag, 
        Items = {} 
    }
    local Items = Cfg.Items

    local btn = Bypass:Create("TextButton", { Parent = self.Items.Title or self.Items.Button or self.Items.Container, AnchorPoint = vec2(1, 0.5), Position = dim2(1, -6, 0.5, 0), Size = dim2(0, 30, 0, 14), BackgroundColor3 = Cfg.Color, Text = "" })
    Bypass:Create("UICorner", {Parent = btn, CornerRadius = dim(0, 4)})
    AddSubtleGradient(btn, 90) -- ADDED: Gradient on the color preview box

    local h, s, v = Color3.toHSV(Cfg.Color)
    
    Items.DropFrame = Bypass:Create("Frame", { Parent = Bypass.Gui, Size = dim2(0, 150, 0, 0), BackgroundColor3 = themes.preset.element, Visible = false, ZIndex = 200, ClipsDescendants = true })
    Bypass:Themify(Items.DropFrame, "element", "BackgroundColor3")
    Bypass:Create("UICorner", { Parent = Items.DropFrame, CornerRadius = dim(0, 4) })

    Items.SVMap = Bypass:Create("TextButton", { Parent = Items.DropFrame, Position = dim2(0, 8, 0, 8), Size = dim2(1, -16, 1, -38), AutoButtonColor = false, Text = "", BackgroundColor3 = Color3.fromHSV(h, 1, 1), ZIndex = 201 })
    Bypass:Create("UICorner", { Parent = Items.SVMap, CornerRadius = dim(0, 3) })
    Items.SVImage = Bypass:Create("ImageLabel", { Parent = Items.SVMap, Size = dim2(1, 0, 1, 0), Image = "rbxassetid://4155801252", BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 202 })
    Bypass:Create("UICorner", { Parent = Items.SVImage, CornerRadius = dim(0, 3) })
    
    Items.SVKnob = Bypass:Create("Frame", { Parent = Items.SVMap, AnchorPoint = vec2(0.5, 0.5), Size = dim2(0, 4, 0, 4), BackgroundColor3 = rgb(255,255,255), ZIndex = 203 })
    Bypass:Create("UICorner", { Parent = Items.SVKnob, CornerRadius = dim(1, 0) })
    Bypass:Create("UIStroke", { Parent = Items.SVKnob, Color = rgb(0,0,0) })

    Items.HueBar = Bypass:Create("TextButton", { Parent = Items.DropFrame, Position = dim2(0, 8, 1, -22), Size = dim2(1, -16, 0, 14), AutoButtonColor = false, Text = "", BorderSizePixel = 0, BackgroundColor3 = rgb(255, 255, 255), ZIndex = 201 })
    Bypass:Create("UICorner", { Parent = Items.HueBar, CornerRadius = dim(0, 3) })
    Bypass:Create("UIGradient", { Parent = Items.HueBar, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, rgb(255,0,0)), ColorSequenceKeypoint.new(0.167, rgb(255,0,255)), ColorSequenceKeypoint.new(0.333, rgb(0,0,255)), ColorSequenceKeypoint.new(0.5, rgb(0,255,255)), ColorSequenceKeypoint.new(0.667, rgb(0,255,0)), ColorSequenceKeypoint.new(0.833, rgb(255,255,0)), ColorSequenceKeypoint.new(1, rgb(255,0,0))}) })
    
    Items.HueKnob = Bypass:Create("Frame", { Parent = Items.HueBar, AnchorPoint = vec2(0.5, 0.5), Size = dim2(0, 2, 1, 4), BackgroundColor3 = rgb(255,255,255), ZIndex = 203 })
    Bypass:Create("UIStroke", { Parent = Items.HueKnob, Color = rgb(0,0,0) })

    local Open = false
    local isTweening = false

    local function Toggle() 
        if isTweening then return end
        Open = not Open
        isTweening = true
        
        if Open then
            Items.DropFrame.Visible = true
            local tw = Bypass:Tween(Items.DropFrame, {Size = dim2(0, 150, 0, 140)}, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
            tw.Completed:Wait()
        else
            local tw = Bypass:Tween(Items.DropFrame, {Size = dim2(0, 150, 0, 0)}, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
            tw.Completed:Wait()
            Items.DropFrame.Visible = false
        end
        isTweening = false
    end
    btn.MouseButton1Click:Connect(Toggle)

    InputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if Open and not isTweening then
                local mx, my = input.Position.X, input.Position.Y
                local p0, s0 = Items.DropFrame.AbsolutePosition, dim2(0, 150, 0, 140)
                local p1, s1 = btn.AbsolutePosition, btn.AbsoluteSize
                if not (mx >= p0.X and mx <= p0.X + s0.X.Offset and my >= p0.Y and my <= p0.Y + s0.Y.Offset) and not (mx >= p1.X and mx <= p1.X + s1.X and my >= p1.Y and my <= p1.Y + s1.Y) then
                    Toggle()
                end
            end
        end
    end)

    function Cfg.set(color3)
        Cfg.Color = color3
        btn.BackgroundColor3 = color3
        if Cfg.Flag then Flags[Cfg.Flag] = color3 end
        Cfg.Callback(color3)
    end

    local svDragging, hueDragging = false, false
    Items.SVMap.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then svDragging = true end end)
    Items.HueBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then hueDragging = true end end)
    InputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then svDragging = false; hueDragging = false end end)

    InputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if svDragging then
                local x = math.clamp((input.Position.X - Items.SVMap.AbsolutePosition.X) / Items.SVMap.AbsoluteSize.X, 0, 1)
                local y = math.clamp((input.Position.Y - Items.SVMap.AbsolutePosition.Y) / Items.SVMap.AbsoluteSize.Y, 0, 1)
                s, v = x, 1 - y
                Items.SVKnob.Position = dim2(x, 0, y, 0)
                Cfg.set(Color3.fromHSV(h, s, v))
            elseif hueDragging then
                local x = math.clamp((input.Position.X - Items.HueBar.AbsolutePosition.X) / Items.HueBar.AbsoluteSize.X, 0, 1)
                h = 1 - x
                Items.HueKnob.Position = dim2(x, 0, 0.5, 0)
                Items.SVMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                Cfg.set(Color3.fromHSV(h, s, v))
            end
        end
    end)

    RunService.RenderStepped:Connect(function()
        if Open or isTweening then Items.DropFrame.Position = dim2(0, btn.AbsolutePosition.X - 150 + btn.AbsoluteSize.X, 0, btn.AbsolutePosition.Y + btn.AbsoluteSize.Y + 2) end
    end)
    
    Items.SVKnob.Position = dim2(s, 0, 1 - v, 0)
    Items.HueKnob.Position = dim2(1 - h, 0, 0.5, 0)
    
    Cfg.set(Cfg.Color)
    if Cfg.Flag then ConfigFlags[Cfg.Flag] = Cfg.set end
    return setmetatable(Cfg, Bypass)
end

function Bypass:Keybind(properties)
    local Cfg = { 
        Name = properties.Name or properties.name or "Keybind", 
        Flag = properties.Flag or properties.flag, 
        Default = properties.Default or properties.default or Enum.KeyCode.Unknown, 
        Callback = properties.Callback or properties.callback or function() end, 
        Items = {} 
    }
    local KeyBtn = Bypass:Create("TextButton", { Parent = self.Items.Title or self.Items.Container, AnchorPoint = vec2(1, 0.5), Position = dim2(1, -6, 0.5, 0), Size = dim2(0, 40, 0, 16), BackgroundColor3 = themes.preset.element, TextColor3 = themes.preset.subtext, Text = Keys[Cfg.Default] or "None", TextSize = 12, FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium), })
    Bypass:Themify(KeyBtn, "element", "BackgroundColor3")
    Bypass:Themify(KeyBtn, "subtext", "TextColor3")

    Bypass:Create("UICorner", {Parent = KeyBtn, CornerRadius = dim(0, 4)})
    AddSubtleGradient(KeyBtn, 90) -- ADDED: Gradient on the keybind button

    local binding = false
    KeyBtn.MouseButton1Click:Connect(function() binding = true; KeyBtn.Text = "..." end)
    
    InputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed and not binding then return end
        if binding then
            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
                binding = false; Cfg.set(input.KeyCode)
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
                binding = false; Cfg.set(input.UserInputType)
            end
        elseif (input.KeyCode == Cfg.Default or input.UserInputType == Cfg.Default) and not binding then
            Cfg.Callback()
        end
    end)
    
    function Cfg.set(val)
        if not val or type(val) == "boolean" then return end
        Cfg.Default = val
        local keyName = Keys[val] or (typeof(val) == "EnumItem" and val.Name) or tostring(val)
        KeyBtn.Text = keyName
        if Cfg.Flag then Flags[Cfg.Flag] = val end
    end
    
    Cfg.set(Cfg.Default)
    if Cfg.Flag then ConfigFlags[Cfg.Flag] = Cfg.set end
    return setmetatable(Cfg, Bypass)
end

-- notifs
function Notifications:RefreshNotifications()
    local offset = 50
    for _, v in ipairs(Notifications.Notifs) do
        local ySize = math.max(v.AbsoluteSize.Y, 36)
        Bypass:Tween(v, {Position = dim_offset(20, offset)}, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
        offset += (ySize + 10)
    end
end

function Notifications:Create(properties)
    local Cfg = { 
        Name = properties.Name or properties.name or "Notification"; 
        Lifetime = properties.LifeTime or properties.lifetime or 2.5; 
        Items = {}; 
    }
    local Items = Cfg.Items
   
    Items.Outline = Bypass:Create("Frame", { Parent = Bypass.Gui; Position = dim_offset(-500, 50); Size = dim2(0, 300, 0, 0); AutomaticSize = Enum.AutomaticSize.Y; BackgroundColor3 = themes.preset.background; BorderSizePixel = 0; ZIndex = 300, ClipsDescendants = true })
    Bypass:Themify(Items.Outline, "background", "BackgroundColor3")
    Bypass:Create("UICorner", { Parent = Items.Outline, CornerRadius = dim(0, 4) })
   
    Items.Name = Bypass:Create("TextLabel", {
        Parent = Items.Outline; Text = Cfg.Name; TextColor3 = themes.preset.text; FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium);
        BackgroundTransparency = 1; Size = dim2(1, 0, 1, 0); AutomaticSize = Enum.AutomaticSize.None; TextWrapped = true; TextSize = 13; TextXAlignment = Enum.TextXAlignment.Left; ZIndex = 302
    })
    Bypass:Themify(Items.Name, "text", "TextColor3")
   
    Bypass:Create("UIPadding", { Parent = Items.Name; PaddingTop = dim(0, 10); PaddingBottom = dim(0, 10); PaddingRight = dim(0, 12); PaddingLeft = dim(0, 12); })
   
    Items.TimeBar = Bypass:Create("Frame", { Parent = Items.Outline, AnchorPoint = vec2(0, 1), Position = dim2(0, 0, 1, 0), Size = dim2(1, 0, 0, 2), BackgroundColor3 = themes.preset.accent, BorderSizePixel = 0, ZIndex = 303 })
    Bypass:Themify(Items.TimeBar, "accent", "BackgroundColor3")
    table.insert(Notifications.Notifs, Items.Outline)
   
    task.spawn(function()
        RunService.RenderStepped:Wait()
        Items.Outline.Position = dim_offset(-Items.Outline.AbsoluteSize.X - 20, 50)
        Notifications:RefreshNotifications()
        Bypass:Tween(Items.TimeBar, {Size = dim2(0, 0, 0, 2)}, TweenInfo.new(Cfg.Lifetime, Enum.EasingStyle.Linear))
        task.wait(Cfg.Lifetime)
        Bypass:Tween(Items.Outline, {Position = dim_offset(-Items.Outline.AbsoluteSize.X - 50, Items.Outline.Position.Y.Offset)}, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In))
        task.wait(0.4)
        local idx = table.find(Notifications.Notifs, Items.Outline)
        if idx then table.remove(Notifications.Notifs, idx) end
        Items.Outline:Destroy()
        task.wait(0.05)
        Notifications:RefreshNotifications()
    end)
end

-- save and load stuff yes
function Bypass:GetConfig()
    local g = {}
    for Idx, Value in Flags do g[Idx] = Value end
    return HttpService:JSONEncode(g)
end

function Bypass:LoadConfig(JSON)
    local g = HttpService:JSONDecode(JSON)
    for Idx, Value in g do
        if Idx == "config_Name_list" or Idx == "config_Name_text" then continue end
        local Function = ConfigFlags[Idx]
        if Function then Function(Value) end
    end
end

-- configs and server menu 
local ConfigHolder
function Bypass:UpdateConfigList()
    if not ConfigHolder then return end
    local List = {}
    for _, file in listfiles(Bypass.Directory .. "/configs") do
        local Name = file:gsub(Bypass.Directory .. "/configs\\", ""):gsub(".cfg", ""):gsub(Bypass.Directory .. "\\configs\\", "")
        List[#List + 1] = Name
    end
    ConfigHolder.RefreshOptions(List)
end

function Bypass:Configs(window)
    local Text

    local Tab = window:Tab({ Name = "", Hidden = true })
    window.SettingsTabOpen = Tab.OpenTab

    local Section = Tab:Section({Name = "Configs", Side = "Left"})

    ConfigHolder = Section:Dropdown({
        Name = "Available Configs",
        Options = {},
        Callback = function(option) if Text then Text.set(option) end end,
        Flag = "config_Name_list"
    })

    Bypass:UpdateConfigList()

    Text = Section:Textbox({ Name = "Config Name:", Flag = "config_Name_text", Default = "" })

    Section:Button({
        Name = "Save Config",
        Callback = function()
            if Flags["config_Name_text"] == "" then return end
            writefile(Bypass.Directory .. "/configs/" .. Flags["config_Name_text"] .. ".cfg", Bypass:GetConfig())
            Bypass:UpdateConfigList()
            Notifications:Create({Name = "Saved Config: " .. Flags["config_Name_text"]})
        end
    })

    Section:Button({
        Name = "Load Config",
        Callback = function()
            if Flags["config_Name_text"] == "" then return end
            Bypass:LoadConfig(readfile(Bypass.Directory .. "/configs/" .. Flags["config_Name_text"] .. ".cfg"))
            Bypass:UpdateConfigList()
            Notifications:Create({Name = "Loaded Config: " .. Flags["config_Name_text"]})
        end
    })

    Section:Button({
        Name = "Delete Config",
        Callback = function()
            if Flags["config_Name_text"] == "" then return end
            delfile(Bypass.Directory .. "/configs/" .. Flags["config_Name_text"] .. ".cfg")
            Bypass:UpdateConfigList()
            Notifications:Create({Name = "Deleted Config: " .. Flags["config_Name_text"]})
        end
    })

    local SectionRight = Tab:Section({Name = "Settings & Themes", Side = "Right"})


    SectionRight:Label({Name = "Accent Color"}):Colorpicker({ Callback = function(color3) Bypass:RefreshTheme("accent", color3) end, Color = themes.preset.accent })
    SectionRight:Label({Name = "Glow Color"}):Colorpicker({ Callback = function(color3) Bypass:RefreshTheme("glow", color3) end, Color = themes.preset.glow })
    SectionRight:Label({Name = "Background Color"}):Colorpicker({ Callback = function(color3) Bypass:RefreshTheme("background", color3) end, Color = themes.preset.background })
    SectionRight:Label({Name = "Section Color"}):Colorpicker({ Callback = function(color3) Bypass:RefreshTheme("section", color3) end, Color = themes.preset.section })
    SectionRight:Label({Name = "Element Color"}):Colorpicker({ Callback = function(color3) Bypass:RefreshTheme("element", color3) end, Color = themes.preset.element })
    SectionRight:Label({Name = "Text Color"}):Colorpicker({ Callback = function(color3) Bypass:RefreshTheme("text", color3) end, Color = themes.preset.text })

    window.Tweening = true
    SectionRight:Label({Name = "Menu Bind"}):Keybind({
        Name = "Menu Bind",
        Callback = function(bool) if window.Tweening then return end window.ToggleMenu(bool) end,
        Default = Enum.KeyCode.RightShift
    })

    task.delay(1, function() window.Tweening = false end)

    local ServerSection = Tab:Section({Name = "Server", Side = "Right"})

    ServerSection:Button({ Name = "Rejoin Server", Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId, Players.LocalPlayer) end })

    ServerSection:Button({
        Name = "Server Hop",
        Callback = function()
            local servers, cursor = {}, ""
            repeat
                local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100" .. (cursor ~= "" and "&cursor=" .. cursor or "")
                local data = HttpService:JSONDecode(game:HttpGet(url))
                for _, server in ipairs(data.data) do
                    if server.id ~= game.JobId and server.playing < server.maxPlayers then table.insert(servers, server) end
                end
                cursor = data.nextPageCursor
            until not cursor or #servers > 0
            if #servers > 0 then game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)].id, Players.LocalPlayer) end
        end
    })
end

return Bypass
