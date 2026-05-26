-- ╔══════════════════════════════════════════╗
-- ║     TIOO BETA V1 — HITBOX TAB            ║
-- ║   Hitbox Size 1 (Normal) to 20 (Huge)    ║
-- ╚══════════════════════════════════════════╝

local function init(page, THEME, tween, corner, stroke, mainGui)

    local Players          = game:GetService("Players")
    local RunService       = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local player           = Players.LocalPlayer

    local ORANGE = THEME.ORANGE or Color3.fromRGB(255, 160, 50)
    local GREEN  = THEME.GREEN  or Color3.fromRGB(50, 210, 120)
    local RED    = THEME.RED    or Color3.fromRGB(255, 70, 70)

    -- ═══════════════════════════════
    -- State
    -- ═══════════════════════════════
    local hitboxEnabled = false
    local hitboxSize    = 1
    local connections   = {}
    local originalSizes = {}

    -- ═══════════════════════════════
    -- Core Logic
    -- ═══════════════════════════════
    local function applyHitbox(targetPlayer, size)
        local char = targetPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                local key = tostring(targetPlayer.UserId) .. "_" .. part.Name
                if not originalSizes[key] then
                    originalSizes[key] = part.Size
                end
                if size <= 1 then
                    part.Size = originalSizes[key]
                else
                    local orig = originalSizes[key]
                    part.Size = Vector3.new(orig.X * size, orig.Y * size, orig.Z * size)
                end
            end
        end
    end

    local function restoreAll()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                pcall(function()
                    local char = p.Character
                    if not char then return end
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            local key = tostring(p.UserId) .. "_" .. part.Name
                            if originalSizes[key] then
                                part.Size = originalSizes[key]
                            end
                        end
                    end
                end)
            end
        end
        originalSizes = {}
    end

    local function runLoop()
        for _, c in ipairs(connections) do c:Disconnect() end
        connections = {}
        if not hitboxEnabled then
            restoreAll()
            return
        end
        local conn = RunService.Heartbeat:Connect(function()
            if not hitboxEnabled then return end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player then
                    pcall(function() applyHitbox(p, hitboxSize) end)
                end
            end
        end)
        table.insert(connections, conn)
    end

    -- ═══════════════════════════════
    -- SECTION HEADER
    -- ═══════════════════════════════
    local secLabel = Instance.new("TextLabel")
    secLabel.Size = UDim2.new(1, 0, 0, 18)
    secLabel.BackgroundTransparency = 1
    secLabel.Text = "  HITBOX EXPANDER"
    secLabel.TextColor3 = ORANGE
    secLabel.Font = Enum.Font.GothamBold
    secLabel.TextSize = 9
    secLabel.TextXAlignment = Enum.TextXAlignment.Left
    secLabel.Parent = page

    -- ═══════════════════════════════
    -- MAIN CARD
    -- ═══════════════════════════════
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 100)
    card.BackgroundColor3 = THEME.BG_CARD
    card.BorderSizePixel = 0
    card.Parent = page
    corner(card, 10)
    stroke(card, THEME.BORDER, 1, 0)

    -- Accent bar kiri
    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 4, 0.8, 0)
    accentBar.Position = UDim2.new(0, 0, 0.1, 0)
    accentBar.BackgroundColor3 = THEME.TEXT_MUTED
    accentBar.BorderSizePixel = 0
    accentBar.Parent = card
    corner(accentBar, 2)

    -- Icon
    local iconL = Instance.new("TextLabel")
    iconL.Size = UDim2.new(0, 26, 0, 26)
    iconL.Position = UDim2.new(0, 10, 0, 8)
    iconL.BackgroundTransparency = 1
    iconL.Text = "🎯"
    iconL.TextSize = 18
    iconL.Font = Enum.Font.Gotham
    iconL.Parent = card

    -- Nama fitur
    local nameL = Instance.new("TextLabel")
    nameL.Size = UDim2.new(1, -110, 0, 16)
    nameL.Position = UDim2.new(0, 42, 0, 8)
    nameL.BackgroundTransparency = 1
    nameL.Text = "Hitbox Size"
    nameL.TextColor3 = THEME.TEXT_PRIMARY
    nameL.Font = Enum.Font.GothamBold
    nameL.TextSize = 11
    nameL.TextXAlignment = Enum.TextXAlignment.Left
    nameL.Parent = card

    -- Badge ON/OFF
    local badge = Instance.new("TextButton")
    badge.Size = UDim2.new(0, 42, 0, 20)
    badge.Position = UDim2.new(1, -50, 0, 10)
    badge.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    badge.Text = "OFF"
    badge.TextColor3 = THEME.TEXT_MUTED
    badge.Font = Enum.Font.GothamBold
    badge.TextSize = 9
    badge.BorderSizePixel = 0
    badge.AutoButtonColor = false
    badge.Parent = card
    corner(badge, 10)

    -- Value label (xN)
    local valueL = Instance.new("TextLabel")
    valueL.Size = UDim2.new(0, 50, 0, 14)
    valueL.Position = UDim2.new(1, -58, 0, 34)
    valueL.BackgroundTransparency = 1
    valueL.Text = "x1"
    valueL.TextColor3 = GREEN
    valueL.Font = Enum.Font.GothamBold
    valueL.TextSize = 10
    valueL.TextXAlignment = Enum.TextXAlignment.Center
    valueL.Parent = card

    -- Slider track
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -22, 0, 5)
    track.Position = UDim2.new(0, 10, 0, 56)
    track.BackgroundColor3 = THEME.BG_HOVER
    track.BorderSizePixel = 0
    track.Parent = card
    corner(track, 3)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = ORANGE
    fill.BorderSizePixel = 0
    fill.Parent = track
    corner(fill, 3)

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, -8, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Text = ""
    knob.BorderSizePixel = 0
    knob.AutoButtonColor = false
    knob.Parent = track
    corner(knob, 8)
    stroke(knob, ORANGE, 2, 0)

    -- Min / max label
    local minL = Instance.new("TextLabel")
    minL.Size = UDim2.new(0, 15, 0, 12)
    minL.Position = UDim2.new(0, 10, 0, 68)
    minL.BackgroundTransparency = 1
    minL.Text = "1"
    minL.TextColor3 = THEME.TEXT_MUTED
    minL.Font = Enum.Font.Gotham
    minL.TextSize = 8
    minL.TextXAlignment = Enum.TextXAlignment.Left
    minL.Parent = card

    local maxL = Instance.new("TextLabel")
    maxL.Size = UDim2.new(0, 20, 0, 12)
    maxL.Position = UDim2.new(1, -30, 0, 68)
    maxL.BackgroundTransparency = 1
    maxL.Text = "20"
    maxL.TextColor3 = THEME.TEXT_MUTED
    maxL.Font = Enum.Font.Gotham
    maxL.TextSize = 8
    maxL.TextXAlignment = Enum.TextXAlignment.Right
    maxL.Parent = card

    -- ═══════════════════════════════
    -- Slider logic
    -- ═══════════════════════════════
    local function applySlider(val)
        val = math.clamp(math.floor(val + 0.5), 1, 20)
        hitboxSize = val
        local pct = (val - 1) / 19
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, -8, 0.5, -8)
        valueL.Text = "x" .. val
        if val == 1 then
            valueL.TextColor3 = GREEN
        elseif val <= 7 then
            valueL.TextColor3 = ORANGE
        else
            valueL.TextColor3 = RED
        end
    end

    local sliderDrag = false

    local function sliderFromInput(input)
        local pct = math.clamp(
            (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X,
            0, 1
        )
        applySlider(pct * 19 + 1)
    end

    knob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            sliderDrag = true
        end
    end)
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            sliderDrag = true
            sliderFromInput(i)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sliderDrag and (
            i.UserInputType == Enum.UserInputType.MouseMovement or
            i.UserInputType == Enum.UserInputType.Touch
        ) then sliderFromInput(i) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            sliderDrag = false
        end
    end)

    -- ═══════════════════════════════
    -- Toggle ON/OFF
    -- ═══════════════════════════════
    local function updateBadge()
        if hitboxEnabled then
            tween(card, 0.2, {BackgroundColor3 = Color3.fromRGB(40, 22, 5)}):Play()
            tween(accentBar, 0.2, {BackgroundColor3 = ORANGE}):Play()
            tween(badge, 0.2, {BackgroundColor3 = ORANGE}):Play()
            tween(knob, 0.15, {BackgroundColor3 = ORANGE}):Play()
            badge.Text = "ON"
            badge.TextColor3 = Color3.fromRGB(255, 255, 255)
            stroke(card, ORANGE, 1, 0.3)
        else
            tween(card, 0.2, {BackgroundColor3 = THEME.BG_CARD}):Play()
            tween(accentBar, 0.2, {BackgroundColor3 = THEME.TEXT_MUTED}):Play()
            tween(badge, 0.2, {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}):Play()
            tween(knob, 0.15, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            badge.Text = "OFF"
            badge.TextColor3 = THEME.TEXT_MUTED
            stroke(card, THEME.BORDER, 1, 0)
        end
    end

    badge.MouseButton1Click:Connect(function()
        hitboxEnabled = not hitboxEnabled
        updateBadge()
        runLoop()
    end)

    -- ═══════════════════════════════
    -- QUICK PRESET
    -- ═══════════════════════════════
    local secPreset = Instance.new("TextLabel")
    secPreset.Size = UDim2.new(1, 0, 0, 18)
    secPreset.BackgroundTransparency = 1
    secPreset.Text = "  QUICK PRESET"
    secPreset.TextColor3 = ORANGE
    secPreset.Font = Enum.Font.GothamBold
    secPreset.TextSize = 9
    secPreset.TextXAlignment = Enum.TextXAlignment.Left
    secPreset.Parent = page

    local presets = {
        { label = "Normal", value = 1  },
        { label = "Small",  value = 3  },
        { label = "Med",    value = 8  },
        { label = "Large",  value = 15 },
        { label = "MAX",    value = 20 },
    }

    local presetGrid = Instance.new("Frame")
    presetGrid.Size = UDim2.new(1, 0, 0, 28)
    presetGrid.BackgroundTransparency = 1
    presetGrid.Parent = page

    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0.18, -3, 1, 0)
    gridLayout.CellPadding = UDim2.new(0, 4, 0, 0)
    gridLayout.Parent = presetGrid

    for _, preset in ipairs(presets) do
        local btn = Instance.new("TextButton")
        btn.BackgroundColor3 = THEME.BG_CARD
        btn.Text = preset.label
        btn.TextColor3 = THEME.TEXT_MUTED
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 8
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Parent = presetGrid
        corner(btn, 6)
        stroke(btn, THEME.BORDER, 1, 0.3)

        btn.MouseButton1Click:Connect(function()
            applySlider(preset.value)
            tween(btn, 0.1, {BackgroundColor3 = ORANGE}):Play()
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            task.wait(0.25)
            tween(btn, 0.2, {BackgroundColor3 = THEME.BG_CARD}):Play()
            btn.TextColor3 = THEME.TEXT_MUTED
        end)
    end

    -- ═══════════════════════════════
    -- STATUS CARD
    -- ═══════════════════════════════
    local statusCard = Instance.new("Frame")
    statusCard.Size = UDim2.new(1, 0, 0, 30)
    statusCard.BackgroundColor3 = THEME.BG_CARD
    statusCard.BorderSizePixel = 0
    statusCard.Parent = page
    corner(statusCard, 8)
    stroke(statusCard, THEME.BORDER, 1, 0.3)

    local statusL = Instance.new("TextLabel")
    statusL.Size = UDim2.new(1, -10, 1, 0)
    statusL.Position = UDim2.new(0, 10, 0, 0)
    statusL.BackgroundTransparency = 1
    statusL.Text = "🎯 OFF  |  Size: x1  |  0 target"
    statusL.TextColor3 = THEME.TEXT_MUTED
    statusL.Font = Enum.Font.Gotham
    statusL.TextSize = 8
    statusL.TextXAlignment = Enum.TextXAlignment.Left
    statusL.TextWrapped = true
    statusL.Parent = statusCard

    task.spawn(function()
        while true do
            task.wait(0.5)
            local count = 0
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player then count += 1 end
            end
            statusL.Text = string.format(
                "🎯 %s  |  Size: x%d  |  %d target",
                hitboxEnabled and "ON" or "OFF",
                hitboxSize,
                count
            )
            statusL.TextColor3 = hitboxEnabled and ORANGE or THEME.TEXT_MUTED
        end
    end)

    -- Cleanup saat player lain leave
    Players.PlayerRemoving:Connect(function(p)
        local prefix = tostring(p.UserId) .. "_"
        for k in pairs(originalSizes) do
            if k:sub(1, #prefix) == prefix then
                originalSizes[k] = nil
            end
        end
    end)

    -- Respawn handling
    player.CharacterAdded:Connect(function()
        if hitboxEnabled then
            task.wait(1)
            runLoop()
        end
    end)

    -- Init
    applySlider(1)

end

return { init = init }
