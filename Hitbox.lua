-- ╔══════════════════════════════════════════╗
-- ║     TIOO BETA V1 — HITBOX TAB            ║
-- ║   Hitbox Size 1 (Normal) to 20 (Huge)    ║
-- ╚══════════════════════════════════════════╝

local function init(page, THEME, tween, corner, stroke, mainGui)

    local Players    = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local player     = Players.LocalPlayer

    local ORANGE = THEME.ORANGE or Color3.fromRGB(255, 160, 50)

    -- ═══════════════════════════════
    -- State
    -- ═══════════════════════════════
    getgenv().HitboxEnabled = false
    getgenv().HitboxSize    = 1   -- 1 = normal, 2-20 = membesar

    local connections = {}
    local originalSizes = {}   -- simpan ukuran asli tiap part

    -- ═══════════════════════════════
    -- HELPER: Terapkan hitbox ke semua player lain
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
                    local mult = size
                    part.Size = Vector3.new(orig.X * mult, orig.Y * mult, orig.Z * mult)
                end
            end
        end
    end

    local function restoreHitbox(targetPlayer)
        local char = targetPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                local key = tostring(targetPlayer.UserId) .. "_" .. part.Name
                if originalSizes[key] then
                    part.Size = originalSizes[key]
                end
            end
        end
    end

    local function restoreAll()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                pcall(function() restoreHitbox(p) end)
            end
        end
        originalSizes = {}
    end

    local function runHitboxLoop()
        -- Disconnect loop lama
        for _, c in ipairs(connections) do c:Disconnect() end
        connections = {}

        if not getgenv().HitboxEnabled then
            restoreAll()
            return
        end

        local conn = RunService.Heartbeat:Connect(function()
            if not getgenv().HitboxEnabled then return end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player then
                    pcall(function() applyHitbox(p, getgenv().HitboxSize) end)
                end
            end
        end)
        table.insert(connections, conn)
    end

    -- ═══════════════════════════════
    -- SECTION: HITBOX
    -- ═══════════════════════════════
    local sec = Instance.new("TextLabel")
    sec.Size = UDim2.new(1, 0, 0, 22)
    sec.BackgroundTransparency = 1
    sec.Text = "  HITBOX EXPANDER"
    sec.TextColor3 = ORANGE
    sec.Font = Enum.Font.GothamBold
    sec.TextSize = 10
    sec.TextXAlignment = Enum.TextXAlignment.Left
    sec.Parent = page

    -- ═══════════════════════════════
    -- INFO CARD: Penjelasan
    -- ═══════════════════════════════
    local infoCard = Instance.new("Frame")
    infoCard.Size = UDim2.new(1, 0, 0, 38)
    infoCard.BackgroundColor3 = Color3.fromRGB(30, 22, 10)
    infoCard.BorderSizePixel = 0
    infoCard.Parent = page
    corner(infoCard, 8)
    stroke(infoCard, ORANGE, 1, 0.5)

    local infoIcon = Instance.new("TextLabel")
    infoIcon.Size = UDim2.new(0, 22, 1, 0)
    infoIcon.Position = UDim2.new(0, 8, 0, 0)
    infoIcon.BackgroundTransparency = 1
    infoIcon.Text = "⚠️"
    infoIcon.TextSize = 14
    infoIcon.Font = Enum.Font.Gotham
    infoIcon.Parent = infoCard

    local infoText = Instance.new("TextLabel")
    infoText.Size = UDim2.new(1, -36, 1, 0)
    infoText.Position = UDim2.new(0, 32, 0, 0)
    infoText.BackgroundTransparency = 1
    infoText.Text = "Size 1 = Normal Hitbox\nSize 2–20 = Hitbox membesar (makin gampang kena)"
    infoText.TextColor3 = ORANGE
    infoText.Font = Enum.Font.Gotham
    infoText.TextSize = 9
    infoText.TextXAlignment = Enum.TextXAlignment.Left
    infoText.TextWrapped = true
    infoText.Parent = infoCard

    -- ═══════════════════════════════
    -- TOGGLE CARD
    -- ═══════════════════════════════
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 90)
    card.BackgroundColor3 = THEME.BG_CARD
    card.BorderSizePixel = 0
    card.Parent = page
    corner(card, 10)
    stroke(card, THEME.BORDER, 1, 0)

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 4, 0.85, 0)
    accentBar.Position = UDim2.new(0, 0, 0.075, 0)
    accentBar.BackgroundColor3 = THEME.TEXT_MUTED
    accentBar.BorderSizePixel = 0
    accentBar.Parent = card
    corner(accentBar, 2)

    local iconL = Instance.new("TextLabel")
    iconL.Size = UDim2.new(0, 26, 0, 26)
    iconL.Position = UDim2.new(0, 12, 0, 10)
    iconL.BackgroundTransparency = 1
    iconL.Text = "🎯"
    iconL.TextSize = 18
    iconL.Parent = card

    local nameL = Instance.new("TextLabel")
    nameL.Size = UDim2.new(1, -110, 0, 18)
    nameL.Position = UDim2.new(0, 44, 0, 10)
    nameL.BackgroundTransparency = 1
    nameL.Text = "Hitbox Size"
    nameL.TextColor3 = THEME.TEXT_PRIMARY
    nameL.Font = Enum.Font.GothamBold
    nameL.TextSize = 12
    nameL.TextXAlignment = Enum.TextXAlignment.Left
    nameL.Parent = card

    -- Badge ON/OFF
    local badge = Instance.new("Frame")
    badge.Size = UDim2.new(0, 44, 0, 22)
    badge.Position = UDim2.new(1, -54, 0, 10)
    badge.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    badge.BorderSizePixel = 0
    badge.Parent = card
    corner(badge, 11)

    local badgeText = Instance.new("TextLabel")
    badgeText.Size = UDim2.new(1, 0, 1, 0)
    badgeText.BackgroundTransparency = 1
    badgeText.Text = "OFF"
    badgeText.TextColor3 = THEME.TEXT_MUTED
    badgeText.Font = Enum.Font.GothamBold
    badgeText.TextSize = 10
    badgeText.Parent = badge

    -- Value label (ukuran saat ini)
    local valueL = Instance.new("TextLabel")
    valueL.Size = UDim2.new(0, 40, 0, 16)
    valueL.Position = UDim2.new(1, -54, 0, 36)
    valueL.BackgroundTransparency = 1
    valueL.Text = "x1"
    valueL.TextColor3 = ORANGE
    valueL.Font = Enum.Font.GothamBold
    valueL.TextSize = 11
    valueL.TextXAlignment = Enum.TextXAlignment.Center
    valueL.Parent = card

    -- Slider track
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -24, 0, 5)
    track.Position = UDim2.new(0, 12, 0, 58)
    track.BackgroundColor3 = THEME.BG_HOVER
    track.BorderSizePixel = 0
    track.Parent = card
    corner(track, 3)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)   -- awal di 0 (size 1)
    fill.BackgroundColor3 = ORANGE
    fill.BorderSizePixel = 0
    fill.Parent = track
    corner(fill, 3)

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(0, -9, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Text = ""
    knob.BorderSizePixel = 0
    knob.AutoButtonColor = false
    knob.Parent = track
    corner(knob, 9)
    stroke(knob, ORANGE, 2, 0)

    -- Min/max label
    local minL = Instance.new("TextLabel")
    minL.Size = UDim2.new(0, 20, 0, 14)
    minL.Position = UDim2.new(0, 12, 0, 70)
    minL.BackgroundTransparency = 1
    minL.Text = "1"
    minL.TextColor3 = THEME.TEXT_MUTED
    minL.Font = Enum.Font.Gotham
    minL.TextSize = 9
    minL.TextXAlignment = Enum.TextXAlignment.Left
    minL.Parent = card

    local maxL = Instance.new("TextLabel")
    maxL.Size = UDim2.new(0, 30, 0, 14)
    maxL.Position = UDim2.new(1, -42, 0, 70)
    maxL.BackgroundTransparency = 1
    maxL.Text = "20"
    maxL.TextColor3 = THEME.TEXT_MUTED
    maxL.Font = Enum.Font.Gotham
    maxL.TextSize = 9
    maxL.TextXAlignment = Enum.TextXAlignment.Right
    maxL.Parent = card

    -- ═══════════════════════════════
    -- SLIDER LOGIC
    -- ═══════════════════════════════
    local dragging = false
    local UserInputService = game:GetService("UserInputService")

    local function applySlider(val)
        val = math.clamp(math.floor(val), 1, 20)
        getgenv().HitboxSize = val
        -- pct: size 1 = 0%, size 20 = 100%
        local pct = (val - 1) / 19
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, -9, 0.5, -9)
        valueL.Text = "x" .. val
        if val == 1 then
            valueL.TextColor3 = THEME.GREEN
        elseif val <= 5 then
            valueL.TextColor3 = ORANGE
        else
            valueL.TextColor3 = THEME.RED
        end
    end

    local function sliderFromInput(input)
        local pct = math.clamp(
            (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X,
            0, 1
        )
        local val = math.floor(pct * 19) + 1
        applySlider(val)
    end

    knob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            sliderFromInput(i)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (
            i.UserInputType == Enum.UserInputType.MouseMovement or
            i.UserInputType == Enum.UserInputType.Touch
        ) then sliderFromInput(i) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- ═══════════════════════════════
    -- BADGE TOGGLE
    -- ═══════════════════════════════
    badge.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            getgenv().HitboxEnabled = not getgenv().HitboxEnabled
            if getgenv().HitboxEnabled then
                tween(card, 0.2, {BackgroundColor3 = Color3.fromRGB(40, 22, 5)}):Play()
                tween(accentBar, 0.2, {BackgroundColor3 = ORANGE}):Play()
                tween(badge, 0.2, {BackgroundColor3 = ORANGE}):Play()
                tween(knob, 0.15, {BackgroundColor3 = ORANGE}):Play()
                badgeText.Text = "ON"
                badgeText.TextColor3 = Color3.fromRGB(255, 255, 255)
                stroke(card, ORANGE, 1, 0.4)
                runHitboxLoop()
            else
                tween(card, 0.2, {BackgroundColor3 = THEME.BG_CARD}):Play()
                tween(accentBar, 0.2, {BackgroundColor3 = THEME.TEXT_MUTED}):Play()
                tween(badge, 0.2, {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}):Play()
                tween(knob, 0.15, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                badgeText.Text = "OFF"
                badgeText.TextColor3 = THEME.TEXT_MUTED
                stroke(card, THEME.BORDER, 1, 0)
                runHitboxLoop()
            end
        end
    end)

    -- ═══════════════════════════════
    -- TOMBOL PRESET (Quick Select)
    -- ═══════════════════════════════
    local secPreset = Instance.new("TextLabel")
    secPreset.Size = UDim2.new(1, 0, 0, 22)
    secPreset.BackgroundTransparency = 1
    secPreset.Text = "  QUICK PRESET"
    secPreset.TextColor3 = ORANGE
    secPreset.Font = Enum.Font.GothamBold
    secPreset.TextSize = 10
    secPreset.TextXAlignment = Enum.TextXAlignment.Left
    secPreset.Parent = page

    local presets = {
        { label = "Normal",  value = 1  },
        { label = "Small",   value = 3  },
        { label = "Medium",  value = 8  },
        { label = "Large",   value = 15 },
        { label = "MAX",     value = 20 },
    }

    -- Grid container
    local presetGrid = Instance.new("Frame")
    presetGrid.Size = UDim2.new(1, 0, 0, 60)
    presetGrid.BackgroundTransparency = 1
    presetGrid.Parent = page

    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0.18, -2, 1, -6)
    gridLayout.CellPadding = UDim2.new(0, 4, 0, 4)
    gridLayout.Parent = presetGrid

    for _, preset in ipairs(presets) do
        local btn = Instance.new("TextButton")
        btn.BackgroundColor3 = THEME.BG_CARD
        btn.Text = preset.label .. "\n(" .. preset.value .. ")"
        btn.TextColor3 = THEME.TEXT_MUTED
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 8
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Parent = presetGrid
        corner(btn, 8)
        stroke(btn, THEME.BORDER, 1, 0)

        btn.Activated:Connect(function()
            applySlider(preset.value)
            -- flash effect
            tween(btn, 0.1, {BackgroundColor3 = ORANGE}):Play()
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            task.wait(0.3)
            tween(btn, 0.2, {BackgroundColor3 = THEME.BG_CARD}):Play()
            btn.TextColor3 = THEME.TEXT_MUTED
        end)
    end

    -- ═══════════════════════════════
    -- Status live info
    -- ═══════════════════════════════
    local statusCard = Instance.new("Frame")
    statusCard.Size = UDim2.new(1, 0, 0, 36)
    statusCard.BackgroundColor3 = THEME.BG_CARD
    statusCard.BorderSizePixel = 0
    statusCard.Parent = page
    corner(statusCard, 8)
    stroke(statusCard, THEME.BORDER, 1, 0)

    local statusL = Instance.new("TextLabel")
    statusL.Size = UDim2.new(1, -10, 1, 0)
    statusL.Position = UDim2.new(0, 10, 0, 0)
    statusL.BackgroundTransparency = 1
    statusL.Text = "🎯 Hitbox: OFF  |  Size: x1  |  Target: semua player"
    statusL.TextColor3 = THEME.TEXT_MUTED
    statusL.Font = Enum.Font.Gotham
    statusL.TextSize = 9
    statusL.TextXAlignment = Enum.TextXAlignment.Left
    statusL.TextWrapped = true
    statusL.Parent = statusCard

    -- Update status tiap detik
    task.spawn(function()
        while true do
            task.wait(0.5)
            local sz = getgenv().HitboxSize or 1
            local en = getgenv().HitboxEnabled
            local playerCount = 0
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player then playerCount += 1 end
            end
            statusL.Text = string.format(
                "🎯 Hitbox: %s  |  Size: x%d  |  Target: %d player",
                en and "ON" or "OFF", sz, playerCount
            )
            statusL.TextColor3 = en and ORANGE or THEME.TEXT_MUTED
        end
    end)

    -- Reset saat karakter respawn
    player.CharacterAdded:Connect(function()
        if getgenv().HitboxEnabled then
            task.wait(1)
            runHitboxLoop()
        end
    end)

    -- Restore saat player lain leave
    Players.PlayerRemoving:Connect(function(p)
        local key_prefix = tostring(p.UserId) .. "_"
        for k in pairs(originalSizes) do
            if k:sub(1, #key_prefix) == key_prefix then
                originalSizes[k] = nil
            end
        end
    end)

    -- Init slider ke posisi 1
    applySlider(1)

end

return { init = init }
