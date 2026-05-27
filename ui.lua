-- ╔══════════════════════════════════════════╗
-- ║        TIOO BETA V1 — UI MODULE          ║
-- ║         Sidebar Navigation System        ║
-- ╚══════════════════════════════════════════╝

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")

local player = Players.LocalPlayer
local pGui   = player:WaitForChild("PlayerGui")

if pGui:FindFirstChild("TiooBetaV1") then
    pGui.TiooBetaV1:Destroy()
end

-- ═══════════════════════════════════════════
-- THEME
-- ═══════════════════════════════════════════
local THEME = {
    BG_DARK       = Color3.fromRGB(8, 8, 12),
    BG_PANEL      = Color3.fromRGB(14, 14, 20),
    BG_CARD       = Color3.fromRGB(20, 20, 30),
    BG_HOVER      = Color3.fromRGB(28, 28, 42),
    BG_ACTIVE     = Color3.fromRGB(35, 55, 85),
    ACCENT        = Color3.fromRGB(80, 140, 255),
    ACCENT_GLOW   = Color3.fromRGB(60, 100, 220),
    GREEN         = Color3.fromRGB(50, 210, 120),
    RED           = Color3.fromRGB(255, 70, 70),
    ORANGE        = Color3.fromRGB(255, 160, 50),
    TEXT_PRIMARY  = Color3.fromRGB(235, 235, 245),
    TEXT_MUTED    = Color3.fromRGB(130, 130, 160),
    BORDER        = Color3.fromRGB(40, 40, 60),
    SIDEBAR       = Color3.fromRGB(11, 11, 17),
}

-- ═══════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════
local function corner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = obj
    return c
end

local function stroke(obj, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or THEME.BORDER
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = obj
    return s
end

local function gradient(obj, c0, c1, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c0, c1)
    g.Rotation = rotation or 90
    g.Parent = obj
    return g
end

local function tween(obj, time, props)
    return TweenService:Create(
        obj,
        TweenInfo.new(time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        props
    )
end

local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement or
            input.UserInputType == Enum.UserInputType.Touch
        ) then
            local delta = input.Position - dragStart
            tween(frame, 0.08, {
                Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            }):Play()
        end
    end)
end

-- ═══════════════════════════════════════════
-- MAIN GUI
-- ═══════════════════════════════════════════
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "TiooBetaV1"
mainGui.ResetOnSpawn = false
mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mainGui.Parent = pGui

-- Main Window (300x220)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainWindow"
mainFrame.Size = UDim2.new(0, 300, 0, 220)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -110)
mainFrame.BackgroundColor3 = THEME.BG_DARK
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.ClipsDescendants = false
mainFrame.Parent = mainGui
corner(mainFrame, 14)
stroke(mainFrame, THEME.BORDER, 1, 0)

-- Top accent glow
local topGlow = Instance.new("Frame")
topGlow.Size = UDim2.new(0.5, 0, 0, 2)
topGlow.Position = UDim2.new(0.25, 0, 0, 0)
topGlow.BackgroundColor3 = THEME.ACCENT
topGlow.BorderSizePixel = 0
topGlow.Parent = mainFrame
corner(topGlow, 2)

-- ═══════════════════════════════════════════
-- HEADER
-- ═══════════════════════════════════════════
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = THEME.BG_PANEL
header.BorderSizePixel = 0
header.Parent = mainFrame
corner(header, 14)

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 10)
headerFix.Position = UDim2.new(0, 0, 1, -10)
headerFix.BackgroundColor3 = THEME.BG_PANEL
headerFix.BorderSizePixel = 0
headerFix.Parent = header

-- Logo
local logoBox = Instance.new("Frame")
logoBox.Size = UDim2.new(0, 20, 0, 20)
logoBox.Position = UDim2.new(0, 8, 0.5, -10)
logoBox.BackgroundColor3 = THEME.ACCENT
logoBox.BorderSizePixel = 0
logoBox.Parent = header
corner(logoBox, 8)
gradient(logoBox, THEME.ACCENT, THEME.ACCENT_GLOW, 135)

local logoText = Instance.new("TextLabel")
logoText.Size = UDim2.new(1, 0, 1, 0)
logoText.BackgroundTransparency = 1
logoText.Text = "T"
logoText.TextColor3 = Color3.fromRGB(255, 255, 255)
logoText.Font = Enum.Font.GothamBold
logoText.TextSize = 11
logoText.Parent = logoBox

local titleMain = Instance.new("TextLabel")
titleMain.Size = UDim2.new(1, -110, 0, 13)
titleMain.Position = UDim2.new(0, 34, 0, 5)
titleMain.BackgroundTransparency = 1
titleMain.Text = "TIOO BETA V1"
titleMain.TextColor3 = THEME.TEXT_PRIMARY
titleMain.Font = Enum.Font.GothamBold
titleMain.TextSize = 9
titleMain.TextXAlignment = Enum.TextXAlignment.Left
titleMain.Parent = header

local titleSub = Instance.new("TextLabel")
titleSub.Size = UDim2.new(1, -110, 0, 10)
titleSub.Position = UDim2.new(0, 34, 0, 18)
titleSub.BackgroundTransparency = 1
titleSub.Text = "Ninja Legends  •  by Tiooprime2"
titleSub.TextColor3 = THEME.TEXT_MUTED
titleSub.Font = Enum.Font.Gotham
titleSub.TextSize = 7
titleSub.TextXAlignment = Enum.TextXAlignment.Left
titleSub.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 20, 0, 20)
closeBtn.Position = UDim2.new(1, -28, 0.5, -10)
closeBtn.BackgroundColor3 = Color3.fromRGB(45, 20, 20)
closeBtn.Text = "✕"
closeBtn.TextColor3 = THEME.RED
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 9
closeBtn.BorderSizePixel = 0
closeBtn.Parent = header
corner(closeBtn, 8)
stroke(closeBtn, THEME.RED, 1, 0.6)

closeBtn.MouseEnter:Connect(function()
    tween(closeBtn, 0.15, {BackgroundColor3 = THEME.RED, TextColor3 = Color3.fromRGB(255,255,255)}):Play()
end)
closeBtn.MouseLeave:Connect(function()
    tween(closeBtn, 0.15, {BackgroundColor3 = Color3.fromRGB(45,20,20), TextColor3 = THEME.RED}):Play()
end)

makeDraggable(mainFrame, header)

-- ═══════════════════════════════════════════
-- BODY (sidebar + content)
-- ═══════════════════════════════════════════
local body = Instance.new("Frame")
body.Size = UDim2.new(1, -10, 1, -38)
body.Position = UDim2.new(0, 5, 0, 34)
body.BackgroundTransparency = 1
body.BorderSizePixel = 0
body.Parent = mainFrame

-- ═══════════════════════════════════════════
-- SIDEBAR (kiri) — lebih kecil karena cuma 2 tab
-- ═══════════════════════════════════════════
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 60, 1, 0)
sidebar.BackgroundColor3 = THEME.SIDEBAR
sidebar.BorderSizePixel = 0
sidebar.Parent = body
corner(sidebar, 10)
stroke(sidebar, THEME.BORDER, 1, 0.5)

local sideLayout = Instance.new("UIListLayout")
sideLayout.Padding = UDim.new(0, 4)
sideLayout.Parent = sidebar

local sidePad = Instance.new("UIPadding")
sidePad.PaddingTop = UDim.new(0, 5)
sidePad.PaddingBottom = UDim.new(0, 5)
sidePad.PaddingLeft = UDim.new(0, 4)
sidePad.PaddingRight = UDim.new(0, 4)
sidePad.Parent = sidebar

-- ═══════════════════════════════════════════
-- CONTENT PANEL (kanan)
-- ═══════════════════════════════════════════
local contentPanel = Instance.new("Frame")
contentPanel.Size = UDim2.new(1, -66, 1, 0)
contentPanel.Position = UDim2.new(0, 66, 0, 0)
contentPanel.BackgroundColor3 = THEME.BG_PANEL
contentPanel.BorderSizePixel = 0
contentPanel.ClipsDescendants = true
contentPanel.Parent = body
corner(contentPanel, 10)
stroke(contentPanel, THEME.BORDER, 1, 0.5)

-- Page title
local pageTitle = Instance.new("TextLabel")
pageTitle.Size = UDim2.new(1, -10, 0, 22)
pageTitle.Position = UDim2.new(0, 8, 0, 4)
pageTitle.BackgroundTransparency = 1
pageTitle.Text = "Main"
pageTitle.TextColor3 = THEME.TEXT_PRIMARY
pageTitle.Font = Enum.Font.GothamBold
pageTitle.TextSize = 10
pageTitle.TextXAlignment = Enum.TextXAlignment.Left
pageTitle.Parent = contentPanel

local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -10, 0, 1)
divider.Position = UDim2.new(0, 5, 0, 26)
divider.BackgroundColor3 = THEME.BORDER
divider.BorderSizePixel = 0
divider.Parent = contentPanel

-- ═══════════════════════════════════════════
-- SIDEBAR PAGES SYSTEM
-- ═══════════════════════════════════════════
local pages = {}
local activeTab = nil

local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -8, 1, -48)
    page.Position = UDim2.new(0, 4, 0, 44)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = THEME.ACCENT
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.ClipsDescendants = false
    page.Visible = false
    page.Parent = contentPanel

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.Parent = page

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingLeft = UDim.new(0, 4)
    pad.PaddingRight = UDim.new(0, 8)
    pad.Parent = page

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
    end)

    pages[name] = page
    return page
end

local function switchTab(name, tabBtn, icon)
    for _, p in pairs(pages) do p.Visible = false end
    if pages[name] then pages[name].Visible = true end
    pageTitle.Text = icon .. "  " .. name

    for _, child in pairs(sidebar:GetChildren()) do
        if child:IsA("TextButton") then
            tween(child, 0.15, {BackgroundColor3 = Color3.fromRGB(0,0,0)}):Play()
            child.BackgroundTransparency = 1
            local lbl = child:FindFirstChildOfClass("TextLabel")
            if lbl then lbl.TextColor3 = THEME.TEXT_MUTED end
        end
    end

    if tabBtn then
        tabBtn.BackgroundTransparency = 0
        tween(tabBtn, 0.15, {BackgroundColor3 = THEME.BG_ACTIVE}):Play()
        local lbl = tabBtn:FindFirstChildOfClass("TextLabel")
        if lbl then lbl.TextColor3 = THEME.TEXT_PRIMARY end
    end

    activeTab = name
end

local function createTab(icon, name)
    createPage(name)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundTransparency = 1
    btn.BackgroundColor3 = THEME.BG_ACTIVE
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.Parent = sidebar
    corner(btn, 8)

    local iconLbl = Instance.new("TextLabel")
    iconLbl.Size = UDim2.new(1, 0, 0, 20)
    iconLbl.Position = UDim2.new(0, 0, 0, 6)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text = icon
    iconLbl.TextSize = 16
    iconLbl.Font = Enum.Font.GothamBold
    iconLbl.TextXAlignment = Enum.TextXAlignment.Center
    iconLbl.Parent = btn

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, 0, 0, 12)
    nameLbl.Position = UDim2.new(0, 0, 0, 24)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = name
    nameLbl.TextColor3 = THEME.TEXT_MUTED
    nameLbl.Font = Enum.Font.GothamSemibold
    nameLbl.TextSize = 7
    nameLbl.TextXAlignment = Enum.TextXAlignment.Center
    nameLbl.Parent = btn

    btn.MouseButton1Click:Connect(function()
        switchTab(name, btn, icon)
    end)

    btn.MouseEnter:Connect(function()
        if activeTab ~= name then
            tween(btn, 0.1, {BackgroundTransparency = 0, BackgroundColor3 = THEME.BG_HOVER}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if activeTab ~= name then
            tween(btn, 0.1, {BackgroundTransparency = 1}):Play()
        end
    end)

    return btn, pages[name]
end

-- ═══════════════════════════════════════════
-- BUAT 2 TAB SAJA
-- ═══════════════════════════════════════════
local mainTabBtn,   mainPage   = createTab("🏠", "Main")
local hitboxTabBtn, hitboxPage = createTab("🎯", "Hitbox")

-- Aktifkan Main secara default
switchTab("Main", mainTabBtn, "🏠")

-- ═══════════════════════════════════════════
-- OPEN BUTTON (minimized)
-- ═══════════════════════════════════════════
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 46, 0, 46)
openBtn.Position = UDim2.new(0.02, 0, 0.45, 0)
openBtn.BackgroundColor3 = THEME.BG_DARK
openBtn.Text = "T"
openBtn.TextColor3 = THEME.ACCENT
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 22
openBtn.Visible = false
openBtn.BorderSizePixel = 0
openBtn.Parent = mainGui
corner(openBtn, 14)
stroke(openBtn, THEME.ACCENT, 2, 0.3)
makeDraggable(openBtn)

-- ═══════════════════════════════════════════
-- OPEN / CLOSE LOGIC
-- ═══════════════════════════════════════════
local isOpen = true
local closeListeners = {}

local function onClose(fn)
    table.insert(closeListeners, fn)
end

local function closeUI()
    isOpen = false
    for _, fn in pairs(closeListeners) do pcall(fn) end
    tween(mainFrame, 0.2, {Size = UDim2.new(0, 300, 0, 0)}):Play()
    task.delay(0.2, function()
        mainFrame.Visible = false
        openBtn.Visible = true
    end)
end

local function openUI()
    isOpen = true
    mainFrame.Visible = true
    mainFrame.Size = UDim2.new(0, 300, 0, 0)
    tween(mainFrame, 0.25, {Size = UDim2.new(0, 300, 0, 220)}):Play()
    openBtn.Visible = false
end

closeBtn.MouseButton1Click:Connect(closeUI)
openBtn.MouseButton1Click:Connect(openUI)

-- Animasi pertama kali
mainFrame.Size = UDim2.new(0, 300, 0, 0)
tween(mainFrame, 0.35, {Size = UDim2.new(0, 300, 0, 220)}):Play()

-- ═══════════════════════════════════════════
-- ITEM BUILDER
-- ═══════════════════════════════════════════
local function createToggle(page, name, desc, defaultState, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = THEME.BG_CARD
    row.BorderSizePixel = 0
    row.Parent = page
    corner(row, 8)
    stroke(row, THEME.BORDER, 1, 0.5)

    local nameL = Instance.new("TextLabel")
    nameL.Size = UDim2.new(1, -50, 0, 14)
    nameL.Position = UDim2.new(0, 8, 0, 6)
    nameL.BackgroundTransparency = 1
    nameL.Text = name
    nameL.TextColor3 = THEME.TEXT_PRIMARY
    nameL.Font = Enum.Font.GothamSemibold
    nameL.TextSize = 9
    nameL.TextXAlignment = Enum.TextXAlignment.Left
    nameL.Parent = row

    local descL = Instance.new("TextLabel")
    descL.Size = UDim2.new(1, -50, 0, 11)
    descL.Position = UDim2.new(0, 8, 0, 20)
    descL.BackgroundTransparency = 1
    descL.Text = desc or ""
    descL.TextColor3 = THEME.TEXT_MUTED
    descL.Font = Enum.Font.Gotham
    descL.TextSize = 7
    descL.TextXAlignment = Enum.TextXAlignment.Left
    descL.Parent = row

    local switch = Instance.new("Frame")
    switch.Size = UDim2.new(0, 30, 0, 16)
    switch.Position = UDim2.new(1, -38, 0.5, -8)
    switch.BackgroundColor3 = defaultState and THEME.GREEN or THEME.BG_HOVER
    switch.BorderSizePixel = 0
    switch.Parent = row
    corner(switch, 8)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = defaultState and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = switch
    corner(knob, 6)

    local state = defaultState or false

    local function toggle()
        state = not state
        if state then
            tween(switch, 0.2, {BackgroundColor3 = THEME.GREEN}):Play()
            tween(knob, 0.2, {Position = UDim2.new(1, -14, 0.5, -6)}):Play()
            tween(row, 0.2, {BackgroundColor3 = Color3.fromRGB(15, 35, 20)}):Play()
        else
            tween(switch, 0.2, {BackgroundColor3 = THEME.BG_HOVER}):Play()
            tween(knob, 0.2, {Position = UDim2.new(0, 2, 0.5, -6)}):Play()
            tween(row, 0.2, {BackgroundColor3 = THEME.BG_CARD}):Play()
        end
        if callback then callback(state) end
    end

    row.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            toggle()
        end
    end)

    return { getState = function() return state end, descLabel = descL }
end

local function createSection(page, title)
    local sec = Instance.new("TextLabel")
    sec.Size = UDim2.new(1, 0, 0, 15)
    sec.BackgroundTransparency = 1
    sec.Text = "  " .. title:upper()
    sec.TextColor3 = THEME.ACCENT
    sec.Font = Enum.Font.GothamBold
    sec.TextSize = 7
    sec.TextXAlignment = Enum.TextXAlignment.Left
    sec.Parent = page
end

-- ═══════════════════════════════════════════
-- EXPORTS
-- ═══════════════════════════════════════════
return {
    THEME         = THEME,
    corner        = corner,
    stroke        = stroke,
    gradient      = gradient,
    tween         = tween,
    makeDraggable = makeDraggable,
    mainGui       = mainGui,
    mainFrame     = mainFrame,
    mainPage      = mainPage,
    hitboxPage    = hitboxPage,
    createToggle  = createToggle,
    createSection = createSection,
    closeBtn      = closeBtn,
    openBtn       = openBtn,
    isOpen        = function() return isOpen end,
    closeUI       = closeUI,
    openUI        = openUI,
    onClose       = onClose,
}
