--[[
    TiooHub V2.1 — FastSpeed Module
    Tab    : Main
    Author : Tiooprime2
]]

local Players = game:GetService("Players")
local RunSvc  = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local CONFIG = {
    MIN_SPEED = 80,
    MAX_SPEED = 110,
    DEFAULT   = 80,
}

local isEnabled = false
local currentSpeed = CONFIG.DEFAULT
local _speedConn = nil

local function stopSpeedLoop()
    if _speedConn then _speedConn:Disconnect(); _speedConn = nil end
end

local function startSpeedLoop()
    stopSpeedLoop()
    _speedConn = RunSvc.Heartbeat:Connect(function()
        if not isEnabled then return end
        local char = player.Character
        if not char then return end
        local hum  = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not hum or not root then return end
        if hum.Health <= 0 then return end
        if hum.Sit then return end
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude <= 0.01 then return end
        local flatDir = Vector3.new(moveDir.X, 0, moveDir.Z)
        if flatDir.Magnitude <= 0.01 then return end
        local curVel = root.AssemblyLinearVelocity
        local targetFlat = flatDir.Unit * currentSpeed
        root.AssemblyLinearVelocity = Vector3.new(targetFlat.X, curVel.Y, targetFlat.Z)
    end)
end

local FastSpeed = {}

function FastSpeed.build(page, UI)
    local THEME = UI.THEME
    local tween = UI.tween
    local corner = UI.corner
    local stroke = UI.stroke

    local ORANGE = THEME.ORANGE or Color3.fromRGB(255, 160, 50)
    local WHITE  = Color3.fromRGB(255, 255, 255)
    local GREEN  = THEME.GREEN  or Color3.fromRGB(50, 210, 120)

    UI.createSection(page, "Movement")

    -- CARD
    local card = Instance.new("Frame")
    card.Size             = UDim2.new(1, 0, 0, 100)
    card.BackgroundColor3 = THEME.BG_CARD
    card.BorderSizePixel  = 0
    card.Parent           = page
    corner(card, 10); stroke(card, THEME.BORDER, 1, 0)

    local accentBar = Instance.new("Frame")
    accentBar.Size             = UDim2.new(0, 4, 0.8, 0)
    accentBar.Position         = UDim2.new(0, 0, 0.1, 0)
    accentBar.BackgroundColor3 = THEME.TEXT_MUTED
    accentBar.BorderSizePixel  = 0
    accentBar.Parent           = card; corner(accentBar, 2)

    local iconL = Instance.new("TextLabel")
    iconL.Size = UDim2.new(0, 26, 0, 26); iconL.Position = UDim2.new(0, 10, 0, 8)
    iconL.BackgroundTransparency = 1; iconL.Text = "⚡"
    iconL.TextSize = 18; iconL.Font = Enum.Font.Gotham; iconL.Parent = card

    local nameL = Instance.new("TextLabel")
    nameL.Size = UDim2.new(1, -110, 0, 16); nameL.Position = UDim2.new(0, 42, 0, 8)
    nameL.BackgroundTransparency = 1; nameL.Text = "Fast Speed"
    nameL.TextColor3 = THEME.TEXT_PRIMARY; nameL.Font = Enum.Font.GothamBold
    nameL.TextSize = 11; nameL.TextXAlignment = Enum.TextXAlignment.Left; nameL.Parent = card

    local descL = Instance.new("TextLabel")
    descL.Size = UDim2.new(1, -110, 0, 11); descL.Position = UDim2.new(0, 42, 0, 26)
    descL.BackgroundTransparency = 1; descL.Text = "Lock speed stabil walau ada bonus accessories"
    descL.TextColor3 = THEME.TEXT_MUTED; descL.Font = Enum.Font.Gotham
    descL.TextSize = 7; descL.TextXAlignment = Enum.TextXAlignment.Left; descL.Parent = card

    -- BADGE (ON/OFF)
    local badge = Instance.new("TextButton")
    badge.Size = UDim2.new(0, 42, 0, 20); badge.Position = UDim2.new(1, -50, 0, 10)
    badge.BackgroundColor3 = Color3.fromRGB(40, 40, 55); badge.Text = "OFF"
    badge.TextColor3 = THEME.TEXT_MUTED; badge.Font = Enum.Font.GothamBold
    badge.TextSize = 9; badge.BorderSizePixel = 0; badge.AutoButtonColor = false
    badge.Parent = card; corner(badge, 10)

    -- SPEED VALUE LABEL
    local valueL = Instance.new("TextLabel")
    valueL.Size = UDim2.new(0, 50, 0, 14); valueL.Position = UDim2.new(1, -58, 0, 34)
    valueL.BackgroundTransparency = 1; valueL.Text = tostring(CONFIG.DEFAULT)
    valueL.TextColor3 = GREEN; valueL.Font = Enum.Font.GothamBold
    valueL.TextSize = 10; valueL.TextXAlignment = Enum.TextXAlignment.Center; valueL.Parent = card

    -- TRACK
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -22, 0, 5); track.Position = UDim2.new(0, 10, 0, 56)
    track.BackgroundColor3 = THEME.BG_HOVER; track.BorderSizePixel = 0
    track.Parent = card; corner(track, 3)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0); fill.BackgroundColor3 = GREEN
    fill.BorderSizePixel = 0; fill.Parent = track; corner(fill, 3)

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 16, 0, 16); knob.Position = UDim2.new(0, -8, 0.5, -8)
    knob.BackgroundColor3 = WHITE; knob.Text = ""; knob.BorderSizePixel = 0
    knob.AutoButtonColor = false; knob.Parent = track
    corner(knob, 8); stroke(knob, GREEN, 2, 0)

    -- MIN / MAX LABELS
    local minL = Instance.new("TextLabel")
    minL.Size = UDim2.new(0, 20, 0, 12); minL.Position = UDim2.new(0, 10, 0, 68)
    minL.BackgroundTransparency = 1; minL.Text = "80"
    minL.TextColor3 = THEME.TEXT_MUTED; minL.Font = Enum.Font.Gotham
    minL.TextSize = 8; minL.TextXAlignment = Enum.TextXAlignment.Left; minL.Parent = card

    local maxL = Instance.new("TextLabel")
    maxL.Size = UDim2.new(0, 25, 0, 12); maxL.Position = UDim2.new(1, -33, 0, 68)
    maxL.BackgroundTransparency = 1; maxL.Text = "110"
    maxL.TextColor3 = THEME.TEXT_MUTED; maxL.Font = Enum.Font.Gotham
    maxL.TextSize = 8; maxL.TextXAlignment = Enum.TextXAlignment.Right; maxL.Parent = card

    -- SLIDER LOGIC — snap ke step 80/90/100/110
    local STEPS = {80, 90, 100, 110}

    local function snapToStep(raw)
        local closest, closestDist = STEPS[1], math.huge
        for _, v in ipairs(STEPS) do
            local d = math.abs(v - raw)
            if d < closestDist then closest = v; closestDist = d end
        end
        return closest
    end

    local function applySlider(speed)
        currentSpeed = speed
        local pct = (speed - CONFIG.MIN_SPEED) / (CONFIG.MAX_SPEED - CONFIG.MIN_SPEED)
        fill.Size     = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, -8, 0.5, -8)
        valueL.Text   = tostring(speed)
    end

    local sliderDrag = false
    local function sliderFromInput(input)
        local pct = math.clamp(
            (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X,
            0, 1
        )
        local rawSpeed = pct * (CONFIG.MAX_SPEED - CONFIG.MIN_SPEED) + CONFIG.MIN_SPEED
        applySlider(snapToStep(rawSpeed))
    end

    knob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            sliderDrag = true
        end
    end)
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            sliderDrag = true; sliderFromInput(i)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sliderDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            sliderFromInput(i)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            sliderDrag = false
        end
    end)

    -- BADGE TOGGLE
    local function updateBadge()
        if isEnabled then
            tween(card, 0.2, {BackgroundColor3 = Color3.fromRGB(10, 30, 15)}):Play()
            tween(accentBar, 0.2, {BackgroundColor3 = GREEN}):Play()
            tween(badge, 0.2, {BackgroundColor3 = GREEN}):Play()
            tween(knob, 0.15, {BackgroundColor3 = GREEN}):Play()
            badge.Text = "ON"; badge.TextColor3 = WHITE
            stroke(card, GREEN, 1, 0.3)
        else
            tween(card, 0.2, {BackgroundColor3 = THEME.BG_CARD}):Play()
            tween(accentBar, 0.2, {BackgroundColor3 = THEME.TEXT_MUTED}):Play()
            tween(badge, 0.2, {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}):Play()
            tween(knob, 0.15, {BackgroundColor3 = WHITE}):Play()
            badge.Text = "OFF"; badge.TextColor3 = THEME.TEXT_MUTED
            stroke(card, THEME.BORDER, 1, 0)
        end
    end

    badge.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        updateBadge()
        if isEnabled then startSpeedLoop() else stopSpeedLoop() end
    end)

    player.CharacterRemoving:Connect(stopSpeedLoop)

    applySlider(CONFIG.DEFAULT)
end

return FastSpeed
