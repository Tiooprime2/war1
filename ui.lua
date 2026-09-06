-- ╔══════════════════════════════════════════╗
-- ║        TIOO BETA V1 — UI MODULE          ║
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
-- THEME — deep slate, aksen biru-violet tenang
-- Tidak neon, tidak kacau. Satu warna dominan.
-- ═══════════════════════════════════════════
local THEME = {
    BG_DARK      = Color3.fromRGB(9,  11, 17),
    BG_PANEL     = Color3.fromRGB(13, 15, 22),
    BG_CARD      = Color3.fromRGB(17, 20, 30),
    BG_HOVER     = Color3.fromRGB(24, 28, 42),
    BG_ACTIVE    = Color3.fromRGB(28, 32, 52),
    ACCENT       = Color3.fromRGB(110, 140, 255),   -- biru periwinkle, tidak mencolok
    ACCENT_SOFT  = Color3.fromRGB(60,  80, 180),
    ACCENT_GLOW  = Color3.fromRGB(80, 105, 220),
    GREEN        = Color3.fromRGB(80,  210, 140),
    RED          = Color3.fromRGB(230,  75,  75),
    ORANGE       = Color3.fromRGB(240, 155,  50),
    TEXT_PRIMARY = Color3.fromRGB(220, 222, 235),
    TEXT_DIM     = Color3.fromRGB(140, 143, 165),
    TEXT_MUTED   = Color3.fromRGB(70,  73,  95),
    BORDER       = Color3.fromRGB(28,  31,  46),
    BORDER_LIGHT = Color3.fromRGB(38,  42,  62),
    SIDEBAR      = Color3.fromRGB(10,  12,  19),
}

-- ═══════════════════════════════════════════
-- UTILITY
-- ═══════════════════════════════════════════
local function corner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = obj
    return c
end

local function stroke(obj, color, thickness, transparency)
    -- Hapus stroke lama dulu supaya tidak numpuk
    local old = obj:FindFirstChildOfClass("UIStroke")
    if old then old:Destroy() end
    local s = Instance.new("UIStroke")
    s.Color        = color or THEME.BORDER
    s.Thickness    = thickness or 1
    s.Transparency = transparency or 0
    s.Parent       = obj
    return s
end

local function gradient(obj, c0, c1, rotation)
    local g = Instance.new("UIGradient")
    g.Color    = ColorSequence.new(c0, c1)
    g.Rotation = rotation or 90
    g.Parent   = obj
    return g
end

-- Tween dengan kurva yang terasa lebih "tangan" — Cubic bukan Quart
local function tween(obj, time, props)
    return TweenService:Create(
        obj,
        TweenInfo.new(time, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
        props
    )
end

-- Tween untuk elemen masuk — sedikit bounce halus
local function tweenIn(obj, time, props)
    return TweenService:Create(
        obj,
        TweenInfo.new(time, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
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
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            tween(frame, 0.05, {
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
mainGui.Name           = "TiooBetaV1"
mainGui.ResetOnSpawn   = false
mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mainGui.IgnoreGuiInset = true
mainGui.Parent         = pGui

local clipWrapper = Instance.new("Frame")
clipWrapper.Name                   = "ClipWrapper"
clipWrapper.Size                   = UDim2.new(0, 310, 0, 230)
clipWrapper.Position               = UDim2.new(0.5, -155, 0.5, -115)
clipWrapper.BackgroundTransparency = 1
clipWrapper.ClipsDescendants       = true
clipWrapper.BorderSizePixel        = 0
clipWrapper.Parent                 = mainGui

local mainFrame = Instance.new("Frame")
mainFrame.Name             = "MainWindow"
mainFrame.Size             = UDim2.new(1, 0, 1, 0)
mainFrame.Position         = UDim2.new(0, 0, 0, 0)
mainFrame.BackgroundColor3 = THEME.BG_DARK
mainFrame.BorderSizePixel  = 0
mainFrame.ClipsDescendants = false
mainFrame.Parent           = clipWrapper
corner(mainFrame, 12)
stroke(mainFrame, THEME.BORDER_LIGHT, 1, 0)

-- Subtle top shimmer — hanya satu garis tipis, tidak berlebihan
local shimmer = Instance.new("Frame")
shimmer.Size             = UDim2.new(0.3, 0, 0, 1)
shimmer.Position         = UDim2.new(0.35, 0, 0, 0)
shimmer.BackgroundColor3 = THEME.ACCENT
shimmer.BackgroundTransparency = 0.4
shimmer.BorderSizePixel  = 0
shimmer.Parent           = mainFrame
corner(shimmer, 1)

-- ═══════════════════════════════════════════
-- HEADER — minimal, bersih
-- ═══════════════════════════════════════════
local header = Instance.new("Frame")
header.Size             = UDim2.new(1, 0, 0, 34)
header.BackgroundColor3 = THEME.BG_PANEL
header.BorderSizePixel  = 0
header.Parent           = mainFrame
corner(header, 12)

-- Fix bawah header agar tidak double-radius
local headerFix = Instance.new("Frame")
headerFix.Size             = UDim2.new(1, 0, 0, 12)
headerFix.Position         = UDim2.new(0, 0, 1, -12)
headerFix.BackgroundColor3 = THEME.BG_PANEL
headerFix.BorderSizePixel  = 0
headerFix.Parent           = header

stroke(header, THEME.BORDER, 1, 0.6)

-- Logo — kotak kecil, warna accent, bukan icon tebal
local logoBox = Instance.new("Frame")
logoBox.Size             = UDim2.new(0, 18, 0, 18)
logoBox.Position         = UDim2.new(0, 10, 0.5, -9)
logoBox.BackgroundColor3 = THEME.ACCENT_SOFT
logoBox.BorderSizePixel  = 0
logoBox.Parent           = header
corner(logoBox, 5)

-- Aksen kecil di sudut logo (detail halus)
local logoDot = Instance.new("Frame")
logoDot.Size             = UDim2.new(0, 5, 0, 5)
logoDot.Position         = UDim2.new(1, -7, 0, -2)
logoDot.BackgroundColor3 = THEME.ACCENT
logoDot.BackgroundTransparency = 0
logoDot.BorderSizePixel  = 0
logoDot.Parent           = logoBox
corner(logoDot, 3)

local logoText = Instance.new("TextLabel")
logoText.Size                 = UDim2.new(1, 0, 1, 0)
logoText.BackgroundTransparency = 1
logoText.Text                 = "t"
logoText.TextColor3           = THEME.TEXT_PRIMARY
logoText.Font                 = Enum.Font.GothamBold
logoText.TextSize             = 10
logoText.Parent               = logoBox

-- Title group
local titleMain = Instance.new("TextLabel")
titleMain.Size               = UDim2.new(0, 120, 0, 14)
titleMain.Position           = UDim2.new(0, 34, 0, 7)
titleMain.BackgroundTransparency = 1
titleMain.Text               = "Tioo Beta"
titleMain.TextColor3         = THEME.TEXT_PRIMARY
titleMain.Font               = Enum.Font.GothamBold
titleMain.TextSize           = 10
titleMain.TextXAlignment     = Enum.TextXAlignment.Left
titleMain.Parent             = header

local titleSub = Instance.new("TextLabel")
titleSub.Size               = UDim2.new(0, 120, 0, 10)
titleSub.Position           = UDim2.new(0, 34, 0, 21)
titleSub.BackgroundTransparency = 1
titleSub.Text               = "Ninja Legends"
titleSub.TextColor3         = THEME.TEXT_MUTED
titleSub.Font               = Enum.Font.Gotham
titleSub.TextSize            = 7
titleSub.TextXAlignment     = Enum.TextXAlignment.Left
titleSub.Parent             = header

-- Tombol close — clean, tidak ada stroke berlebihan
local closeBtn = Instance.new("TextButton")
closeBtn.Size             = UDim2.new(0, 22, 0, 22)
closeBtn.Position         = UDim2.new(1, -30, 0.5, -11)
closeBtn.BackgroundColor3 = THEME.BG_HOVER
closeBtn.Text             = "✕"
closeBtn.TextColor3       = THEME.TEXT_MUTED
closeBtn.Font             = Enum.Font.GothamBold
closeBtn.TextSize         = 8
closeBtn.BorderSizePixel  = 0
closeBtn.AutoButtonColor  = false
closeBtn.Parent           = header
corner(closeBtn, 6)

closeBtn.MouseEnter:Connect(function()
    tween(closeBtn, 0.12, {BackgroundColor3 = THEME.RED, TextColor3 = Color3.fromRGB(255,255,255)}):Play()
end)
closeBtn.MouseLeave:Connect(function()
    tween(closeBtn, 0.12, {BackgroundColor3 = THEME.BG_HOVER, TextColor3 = THEME.TEXT_MUTED}):Play()
end)

makeDraggable(clipWrapper, header)

-- ═══════════════════════════════════════════
-- BODY
-- ═══════════════════════════════════════════
local body = Instance.new("Frame")
body.Size               = UDim2.new(1, -10, 1, -42)
body.Position           = UDim2.new(0, 5, 0, 38)
body.BackgroundTransparency = 1
body.BorderSizePixel    = 0
body.Parent             = mainFrame

-- ═══════════════════════════════════════════
-- SIDEBAR — sangat slim, icon-only
-- ═══════════════════════════════════════════
local sidebar = Instance.new("Frame")
sidebar.Size             = UDim2.new(0, 52, 1, 0)
sidebar.BackgroundColor3 = THEME.SIDEBAR
sidebar.BorderSizePixel  = 0
sidebar.Parent           = body
corner(sidebar, 9)
stroke(sidebar, THEME.BORDER, 1, 0.5)

local sideLayout = Instance.new("UIListLayout")
sideLayout.Padding         = UDim.new(0, 3)
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sideLayout.Parent          = sidebar

local sidePad = Instance.new("UIPadding")
sidePad.PaddingTop    = UDim.new(0, 6)
sidePad.PaddingBottom = UDim.new(0, 6)
sidePad.PaddingLeft   = UDim.new(0, 5)
sidePad.PaddingRight  = UDim.new(0, 5)
sidePad.Parent        = sidebar

-- ═══════════════════════════════════════════
-- CONTENT PANEL
-- ═══════════════════════════════════════════
local contentPanel = Instance.new("Frame")
contentPanel.Size             = UDim2.new(1, -58, 1, 0)
contentPanel.Position         = UDim2.new(0, 58, 0, 0)
contentPanel.BackgroundColor3 = THEME.BG_PANEL
contentPanel.BorderSizePixel  = 0
contentPanel.ClipsDescendants = true
contentPanel.Parent           = body
corner(contentPanel, 9)
stroke(contentPanel, THEME.BORDER, 1, 0.5)

-- Page title — nama tab aktif, warna flat bukan gradient
local pageTitle = Instance.new("TextLabel")
pageTitle.Size               = UDim2.new(1, -12, 0, 20)
pageTitle.Position           = UDim2.new(0, 10, 0, 5)
pageTitle.BackgroundTransparency = 1
pageTitle.Text               = "Main"
pageTitle.TextColor3         = THEME.TEXT_PRIMARY
pageTitle.Font               = Enum.Font.GothamSemibold
pageTitle.TextSize           = 9
pageTitle.TextXAlignment     = Enum.TextXAlignment.Left
pageTitle.Parent             = contentPanel

local divider = Instance.new("Frame")
divider.Size             = UDim2.new(1, -12, 0, 1)
divider.Position         = UDim2.new(0, 6, 0, 25)
divider.BackgroundColor3 = THEME.BORDER
divider.BackgroundTransparency = 0.3
divider.BorderSizePixel  = 0
divider.Parent           = contentPanel

-- ═══════════════════════════════════════════
-- PAGE SYSTEM
-- ═══════════════════════════════════════════
local pages     = {}
local activeTab = nil

local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Size                   = UDim2.new(1, -6, 1, -44)
    page.Position               = UDim2.new(0, 3, 0, 40)
    page.BackgroundTransparency = 1
    page.BorderSizePixel        = 0
    page.ScrollBarThickness     = 2
    page.ScrollBarImageColor3   = THEME.ACCENT_SOFT
    page.CanvasSize             = UDim2.new(0, 0, 0, 0)
    page.ClipsDescendants       = false
    page.Visible                = false
    page.Parent                 = contentPanel

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent  = page

    local pad = Instance.new("UIPadding")
    pad.PaddingTop   = UDim.new(0, 4)
    pad.PaddingLeft  = UDim.new(0, 4)
    pad.PaddingRight = UDim.new(0, 6)
    pad.Parent       = page

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 14)
    end)

    pages[name] = page
    return page
end

local function switchTab(name, tabBtn, icon)
    for _, p in pairs(pages) do p.Visible = false end
    if pages[name] then pages[name].Visible = true end

    -- Update judul — icon emoji + nama, format bersih
    pageTitle.Text = name

    -- Reset semua tab button
    for _, child in pairs(sidebar:GetChildren()) do
        if child:IsA("Frame") and child.Name:sub(1, 4) == "Tab_" then
            local inner = child:FindFirstChild("Btn")
            if inner then
                tween(inner, 0.14, {BackgroundTransparency = 1}):Play()
            end
            local dot = child:FindFirstChild("ActiveDot")
            if dot then tween(dot, 0.14, {BackgroundTransparency = 1}):Play() end
            local lbl = child:FindFirstChild("IconLbl")
            if lbl then tween(lbl, 0.14, {TextTransparency = 0.5}):Play() end
            local nl  = child:FindFirstChild("NameLbl")
            if nl  then tween(nl, 0.14, {TextColor3 = THEME.TEXT_MUTED}):Play() end
        end
    end

    -- Aktifkan tab yang dipilih
    if tabBtn then
        local parent = tabBtn.Parent
        tween(tabBtn, 0.16, {BackgroundTransparency = 0, BackgroundColor3 = THEME.BG_ACTIVE}):Play()
        local dot = parent:FindFirstChild("ActiveDot")
        if dot then tween(dot, 0.16, {BackgroundTransparency = 0}):Play() end
        local lbl = parent:FindFirstChild("IconLbl")
        if lbl then tween(lbl, 0.14, {TextTransparency = 0}):Play() end
        local nl = parent:FindFirstChild("NameLbl")
        if nl then tween(nl, 0.14, {TextColor3 = THEME.ACCENT}):Play() end
    end

    activeTab = name
end

local function createTab(icon, name)
    createPage(name)

    -- Wrapper frame per tab (untuk dot indicator)
    local wrapper = Instance.new("Frame")
    wrapper.Name             = "Tab_" .. name
    wrapper.Size             = UDim2.new(1, 0, 0, 44)
    wrapper.BackgroundTransparency = 1
    wrapper.BorderSizePixel  = 0
    wrapper.Parent           = sidebar

    -- Dot indicator aktif — garis kiri tipis
    local dot = Instance.new("Frame")
    dot.Name                 = "ActiveDot"
    dot.Size                 = UDim2.new(0, 2, 0, 22)
    dot.Position             = UDim2.new(0, -4, 0.5, -11)
    dot.BackgroundColor3     = THEME.ACCENT
    dot.BackgroundTransparency = 1
    dot.BorderSizePixel      = 0
    dot.Parent               = wrapper
    corner(dot, 1)

    local btn = Instance.new("TextButton")
    btn.Name                   = "Btn"
    btn.Size                   = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.BackgroundColor3       = THEME.BG_ACTIVE
    btn.Text                   = ""
    btn.BorderSizePixel        = 0
    btn.AutoButtonColor        = false
    btn.Parent                 = wrapper
    corner(btn, 8)

    local iconLbl = Instance.new("TextLabel")
    iconLbl.Name               = "IconLbl"
    iconLbl.Size               = UDim2.new(1, 0, 0, 20)
    iconLbl.Position           = UDim2.new(0, 0, 0, 6)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text               = icon
    iconLbl.TextSize           = 16
    iconLbl.TextTransparency   = 0.5
    iconLbl.Font               = Enum.Font.GothamBold
    iconLbl.TextXAlignment     = Enum.TextXAlignment.Center
    iconLbl.Parent             = wrapper

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Name               = "NameLbl"
    nameLbl.Size               = UDim2.new(1, 0, 0, 10)
    nameLbl.Position           = UDim2.new(0, 0, 0, 26)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text               = name
    nameLbl.TextColor3         = THEME.TEXT_MUTED
    nameLbl.Font               = Enum.Font.GothamSemibold
    nameLbl.TextSize           = 6
    nameLbl.TextXAlignment     = Enum.TextXAlignment.Center
    nameLbl.Parent             = wrapper

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
-- TABS
-- ═══════════════════════════════════════════
local mainTabBtn,   mainPage   = createTab("🏠", "Main")
local hitboxTabBtn, hitboxPage = createTab("🎯", "Hitbox")

switchTab("Main", mainTabBtn, "🏠")

-- ═══════════════════════════════════════════
-- OPEN BUTTON — minimalis, tidak ramai
-- ═══════════════════════════════════════════
local openBtn = Instance.new("TextButton")
openBtn.Size             = UDim2.new(0, 40, 0, 40)
openBtn.Position         = UDim2.new(0.02, 0, 0.45, 0)
openBtn.BackgroundColor3 = THEME.BG_PANEL
openBtn.Text             = "T"
openBtn.TextColor3       = THEME.ACCENT
openBtn.Font             = Enum.Font.GothamBold
openBtn.TextSize         = 18
openBtn.Visible          = false
openBtn.BorderSizePixel  = 0
openBtn.AutoButtonColor  = false
openBtn.Parent           = mainGui
corner(openBtn, 12)
stroke(openBtn, THEME.BORDER_LIGHT, 1, 0)
makeDraggable(openBtn)

openBtn.MouseEnter:Connect(function()
    tween(openBtn, 0.12, {BackgroundColor3 = THEME.BG_ACTIVE}):Play()
end)
openBtn.MouseLeave:Connect(function()
    tween(openBtn, 0.12, {BackgroundColor3 = THEME.BG_PANEL}):Play()
end)

-- ═══════════════════════════════════════════
-- OPEN / CLOSE — animasi rapi, tidak melompat
-- ═══════════════════════════════════════════
local isOpen    = true
local animLock  = false
local closeListeners = {}

local function onClose(fn)
    table.insert(closeListeners, fn)
end

local function closeUI()
    if animLock then return end
    animLock = true
    isOpen   = false
    for _, fn in pairs(closeListeners) do pcall(fn) end

    tween(clipWrapper, 0.22, {
        Size     = UDim2.new(0, 310, 0, 0),
        Position = UDim2.new(0.5, -155, 0.5, 0),
    }):Play()

    task.delay(0.23, function()
        clipWrapper.Visible = false
        openBtn.Visible     = true
        animLock            = false
    end)
end

local function openUI()
    if animLock then return end
    animLock            = true
    isOpen              = true
    clipWrapper.Visible = true
    openBtn.Visible     = false

    clipWrapper.Size     = UDim2.new(0, 310, 0, 0)
    clipWrapper.Position = UDim2.new(0.5, -155, 0.5, 0)

    tween(clipWrapper, 0.28, {
        Size     = UDim2.new(0, 310, 0, 230),
        Position = UDim2.new(0.5, -155, 0.5, -115),
    }):Play()

    task.delay(0.29, function() animLock = false end)
end

closeBtn.MouseButton1Click:Connect(closeUI)
openBtn.MouseButton1Click:Connect(openUI)

-- Intro animation — sedikit lebih cepat, tidak dramatis
clipWrapper.Size     = UDim2.new(0, 310, 0, 0)
clipWrapper.Position = UDim2.new(0.5, -155, 0.5, 0)
tween(clipWrapper, 0.30, {
    Size     = UDim2.new(0, 310, 0, 230),
    Position = UDim2.new(0.5, -155, 0.5, -115),
}):Play()

-- ═══════════════════════════════════════════
-- TOGGLE — clean, tidak terlalu banyak efek
-- ═══════════════════════════════════════════
local function createToggle(page, name, desc, defaultState, callback)
    local state = defaultState or false

    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, 0, 0, 38)
    row.BackgroundColor3 = state and THEME.BG_ACTIVE or THEME.BG_CARD
    row.BorderSizePixel  = 0
    row.Parent           = page
    corner(row, 8)

    local rowStroke = stroke(row, state and THEME.BORDER_LIGHT or THEME.BORDER, 1, 0.2)

    local nameL = Instance.new("TextLabel")
    nameL.Size               = UDim2.new(1, -54, 0, 15)
    nameL.Position           = UDim2.new(0, 10, 0, 7)
    nameL.BackgroundTransparency = 1
    nameL.Text               = name
    nameL.TextColor3         = THEME.TEXT_PRIMARY
    nameL.Font               = Enum.Font.GothamSemibold
    nameL.TextSize           = 9
    nameL.TextXAlignment     = Enum.TextXAlignment.Left
    nameL.Parent             = row

    local descL = Instance.new("TextLabel")
    descL.Size               = UDim2.new(1, -54, 0, 11)
    descL.Position           = UDim2.new(0, 10, 0, 22)
    descL.BackgroundTransparency = 1
    descL.Text               = desc or ""
    descL.TextColor3         = THEME.TEXT_MUTED
    descL.Font               = Enum.Font.Gotham
    descL.TextSize           = 7
    descL.TextXAlignment     = Enum.TextXAlignment.Left
    descL.Parent             = row

    -- Switch track — sedikit lebih kecil, lebih elegan
    local switch = Instance.new("Frame")
    switch.Size             = UDim2.new(0, 28, 0, 15)
    switch.Position         = UDim2.new(1, -36, 0.5, -7)
    switch.BackgroundColor3 = state and THEME.ACCENT_GLOW or THEME.BG_HOVER
    switch.BorderSizePixel  = 0
    switch.Parent           = row
    corner(switch, 8)

    local knob = Instance.new("Frame")
    knob.Size             = UDim2.new(0, 11, 0, 11)
    knob.Position         = state and UDim2.new(1, -13, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel  = 0
    knob.Parent           = switch
    corner(knob, 6)

    local function doToggle()
        state = not state
        if state then
            tween(switch, 0.16, {BackgroundColor3 = THEME.ACCENT_GLOW}):Play()
            tween(knob,   0.16, {Position = UDim2.new(1, -13, 0.5, -5)}):Play()
            tween(row,    0.16, {BackgroundColor3 = THEME.BG_ACTIVE}):Play()
            rowStroke.Color = THEME.BORDER_LIGHT
        else
            tween(switch, 0.16, {BackgroundColor3 = THEME.BG_HOVER}):Play()
            tween(knob,   0.16, {Position = UDim2.new(0, 2, 0.5, -5)}):Play()
            tween(row,    0.16, {BackgroundColor3 = THEME.BG_CARD}):Play()
            rowStroke.Color = THEME.BORDER
        end
        if callback then pcall(callback, state) end
    end

    local dragThreshold = 5
    local startInputPos = nil

    row.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            startInputPos = input.Position
        end
    end)
    row.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            if not startInputPos then return end
            if (input.Position - startInputPos).Magnitude < dragThreshold then doToggle() end
            startInputPos = nil
        end
    end)

    return {
        getState  = function() return state end,
        setState  = function(v) if v ~= state then doToggle() end end,
        descLabel = descL,
    }
end

-- ═══════════════════════════════════════════
-- SECTION HEADER — tipis, tidak nge-bomb
-- ═══════════════════════════════════════════
local function createSection(page, title)
    local wrapper = Instance.new("Frame")
    wrapper.Size               = UDim2.new(1, 0, 0, 18)
    wrapper.BackgroundTransparency = 1
    wrapper.BorderSizePixel    = 0
    wrapper.Parent             = page

    local line = Instance.new("Frame")
    line.Size             = UDim2.new(1, -4, 0, 1)
    line.Position         = UDim2.new(0, 2, 0.5, 0)
    line.BackgroundColor3 = THEME.BORDER
    line.BackgroundTransparency = 0.3
    line.BorderSizePixel  = 0
    line.Parent           = wrapper

    local label = Instance.new("TextLabel")
    label.Size               = UDim2.new(0, 0, 1, 0)
    label.AutomaticSize      = Enum.AutomaticSize.X
    label.Position           = UDim2.new(0, 0, 0, 0)
    label.BackgroundColor3   = THEME.BG_PANEL
    label.BackgroundTransparency = 0
    label.Text               = " " .. title .. " "
    label.TextColor3         = THEME.TEXT_DIM
    label.Font               = Enum.Font.GothamSemibold
    label.TextSize           = 7
    label.TextXAlignment     = Enum.TextXAlignment.Left
    label.Parent             = wrapper
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
