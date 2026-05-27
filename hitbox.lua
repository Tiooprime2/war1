-- ╔══════════════════════════════════════════╗
-- ║     TIOO BETA V1 — HITBOX TAB            ║
-- ║   ESP Box — Fixed accurate bounding box  ║
-- ╚══════════════════════════════════════════╝

local function init(page, THEME, tween, corner, stroke, mainGui)

    local Players          = game:GetService("Players")
    local RunService       = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local player           = Players.LocalPlayer
    local camera           = workspace.CurrentCamera

    local ORANGE = THEME.ORANGE or Color3.fromRGB(255, 160, 50)
    local GREEN  = THEME.GREEN  or Color3.fromRGB(50, 210, 120)
    local RED    = THEME.RED    or Color3.fromRGB(255, 70, 70)
    local WHITE  = Color3.fromRGB(255, 255, 255)

    -- ═══════════════════════════════
    -- State
    -- ═══════════════════════════════
    local hitboxEnabled     = false
    local hitboxSize        = 1
    local renderConn        = nil
    local espBoxes          = {}
    local playerConns       = {}

    -- ═══════════════════════════════
    -- Warna berdasarkan size
    -- ═══════════════════════════════
    local function getBoxColor(val)
        if val <= 1 then return WHITE
        elseif val <= 7 then return ORANGE
        else return RED end
    end

    -- ═══════════════════════════════
    -- Buat / hapus ESP box
    -- ═══════════════════════════════
    local function createBox(uid)
        if espBoxes[uid] then return end

        local container = Instance.new("Frame")
        container.Name = "HitboxESP_" .. uid
        container.BackgroundTransparency = 1
        container.BorderSizePixel = 0
        container.Size = UDim2.new(0, 0, 0, 0)
        container.Visible = false
        container.ZIndex = 10
        container.Parent = mainGui

        local function line(name)
            local f = Instance.new("Frame")
            f.Name = name
            f.BackgroundColor3 = WHITE
            f.BorderSizePixel = 0
            f.ZIndex = 10
            f.Parent = container
            return f
        end

        espBoxes[uid] = {
            container = container,
            top    = line("Top"),
            bottom = line("Bottom"),
            left   = line("Left"),
            right  = line("Right"),
        }
    end

    local function destroyBox(uid)
        local b = espBoxes[uid]
        if b then
            b.container:Destroy()
            espBoxes[uid] = nil
        end
    end

    local function destroyAllBoxes()
        for uid in pairs(espBoxes) do
            destroyBox(uid)
        end
    end

    -- ═══════════════════════════════════════════════════════
    -- FIXED: Hitung bounding box dari HumanoidRootPart
    -- Karakter Roblox standar: lebar ~2 stud, tinggi ~5 stud
    -- HumanoidRootPart ada di tengah badan (~2.5 stud dari kaki)
    -- sizeMultiplier hanya memperbesar kotak visual, BUKAN karakter
    -- ═══════════════════════════════════════════════════════
    local function getScreenBox(char, sizeMultiplier)
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum  = char:FindFirstChildOfClass("Humanoid")
        if not root then return nil end

        -- Ukuran bounding box dasar karakter
        local baseWidth  = 2.2   -- lebar & depth stud
        local baseHeight = 5.5   -- tinggi total stud

        -- Skala: sizeMultiplier=1 → ukuran normal
        -- sizeMultiplier lebih besar → kotak makin besar
        local halfW = (baseWidth  * sizeMultiplier) * 0.5
        local halfH = (baseHeight * sizeMultiplier) * 0.5

        -- Root berada ~di tengah tinggi karakter
        -- Offset atas dan bawah dari root
        local rootCF = root.CFrame

        -- 8 sudut bounding box dalam world space
        -- Kotak tidak ikut rotasi karakter (axis-aligned di dunia)
        -- supaya box ESP selalu tegak lurus screen
        local rootPos = root.Position
        local corners = {
            rootPos + Vector3.new( halfW,  halfH,  halfW),
            rootPos + Vector3.new(-halfW,  halfH,  halfW),
            rootPos + Vector3.new( halfW, -halfH,  halfW),
            rootPos + Vector3.new(-halfW, -halfH,  halfW),
            rootPos + Vector3.new( halfW,  halfH, -halfW),
            rootPos + Vector3.new(-halfW,  halfH, -halfW),
            rootPos + Vector3.new( halfW, -halfH, -halfW),
            rootPos + Vector3.new(-halfW, -halfH, -halfW),
        }

        local minX, minY =  math.huge,  math.huge
        local maxX, maxY = -math.huge, -math.huge
        local anyOn = false

        for _, wp in ipairs(corners) do
            local sp, onScreen = camera:WorldToViewportPoint(wp)
            if onScreen and sp.Z > 0 then
                anyOn = true
                if sp.X < minX then minX = sp.X end
                if sp.X > maxX then maxX = sp.X end
                if sp.Y < minY then minY = sp.Y end
                if sp.Y > maxY then maxY = sp.Y end
            end
        end

        if not anyOn then return nil end

        local vp = camera.ViewportSize
        minX = math.clamp(minX, 0, vp.X)
        minY = math.clamp(minY, 0, vp.Y)
        maxX = math.clamp(maxX, 0, vp.X)
        maxY = math.clamp(maxY, 0, vp.Y)

        return minX, minY, maxX, maxY
    end

    -- ═══════════════════════════════
    -- Render loop
    -- ═══════════════════════════════
    local function startRender()
        if renderConn then renderConn:Disconnect() end

        renderConn = RunService.RenderStepped:Connect(function()
            if not hitboxEnabled then return end

            local col = getBoxColor(hitboxSize)
            local T = 2  -- tebal garis px

            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player then
                    local uid  = p.UserId
                    local char = p.Character

                    if not espBoxes[uid] then createBox(uid) end
                    local b = espBoxes[uid]
                    if not b then continue end

                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local minX, minY, maxX, maxY = getScreenBox(char, hitboxSize)

                        if minX then
                            local w = math.max(maxX - minX, 4)
                            local h = math.max(maxY - minY, 4)

                            b.container.Visible  = true
                            b.container.Position = UDim2.new(0, minX, 0, minY)
                            b.container.Size     = UDim2.new(0, w, 0, h)

                            b.top.BackgroundColor3    = col
                            b.bottom.BackgroundColor3 = col
                            b.left.BackgroundColor3   = col
                            b.right.BackgroundColor3  = col

                            b.top.Size      = UDim2.new(1, 0, 0, T)
                            b.top.Position  = UDim2.new(0, 0, 0, 0)

                            b.bottom.Size     = UDim2.new(1, 0, 0, T)
                            b.bottom.Position = UDim2.new(0, 0, 1, -T)

                            b.left.Size     = UDim2.new(0, T, 1, 0)
                            b.left.Position = UDim2.new(0, 0, 0, 0)

                            b.right.Size     = UDim2.new(0, T, 1, 0)
                            b.right.Position = UDim2.new(1, -T, 0, 0)
                        else
                            b.container.Visible = false
                        end
                    else
                        b.container.Visible = false
                    end
                end
            end
        end)
    end

    local function stopRender()
        if renderConn then
            renderConn:Disconnect()
            renderConn = nil
        end
        destroyAllBoxes()
    end

    -- ═══════════════════════════════
    -- Track setiap player (termasuk respawn)
    -- ═══════════════════════════════
    local function setupPlayer(p)
        if p == player then return end
        local uid = p.UserId

        if p.Character then
            createBox(uid)
        end

        if playerConns[uid] then
            playerConns[uid]:Disconnect()
        end

        playerConns[uid] = p.CharacterAdded:Connect(function()
            destroyBox(uid)
            task.wait(0.3)
            if hitboxEnabled then
                createBox(uid)
            end
        end)
    end

    local function cleanupPlayer(p)
        local uid = p.UserId
        if playerConns[uid] then
            playerConns[uid]:Disconnect()
            playerConns[uid] = nil
        end
        destroyBox(uid)
    end

    for _, p in ipairs(Players:GetPlayers()) do
        setupPlayer(p)
    end

    Players.PlayerAdded:Connect(function(p)
        setupPlayer(p)
    end)

    Players.PlayerRemoving:Connect(function(p)
        cleanupPlayer(p)
    end)

    player.CharacterAdded:Connect(function()
        if hitboxEnabled then
            task.wait(0.5)
            startRender()
        end
    end)

    -- ═══════════════════════════════
    -- UI — SECTION HEADER
    -- ═══════════════════════════════
    local secLabel = Instance.new("TextLabel")
    secLabel.Size = UDim2.new(1, 0, 0, 18)
    secLabel.BackgroundTransparency = 1
    secLabel.Text = "  HITBOX ESP BOX"
    secLabel.TextColor3 = ORANGE
    secLabel.Font = Enum.Font.GothamBold
    secLabel.TextSize = 9
    secLabel.TextXAlignment = Enum.TextXAlignment.Left
    secLabel.Parent = page

    -- MAIN CARD
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 100)
    card.BackgroundColor3 = THEME.BG_CARD
    card.BorderSizePixel = 0
    card.Parent = page
    corner(card, 10)
    stroke(card, THEME.BORDER, 1, 0)

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 4, 0.8, 0)
    accentBar.Position = UDim2.new(0, 0, 0.1, 0)
    accentBar.BackgroundColor3 = THEME.TEXT_MUTED
    accentBar.BorderSizePixel = 0
    accentBar.Parent = card
    corner(accentBar, 2)

    local iconL = Instance.new("TextLabel")
    iconL.Size = UDim2.new(0, 26, 0, 26)
    iconL.Position = UDim2.new(0, 10, 0, 8)
    iconL.BackgroundTransparency = 1
    iconL.Text = "🎯"
    iconL.TextSize = 18
    iconL.Font = Enum.Font.Gotham
    iconL.Parent = card

    local nameL = Instance.new("TextLabel")
    nameL.Size = UDim2.new(1, -110, 0, 16)
    nameL.Position = UDim2.new(0, 42, 0, 8)
    nameL.BackgroundTransparency = 1
    nameL.Text = "Hitbox ESP Box"
    nameL.TextColor3 = THEME.TEXT_PRIMARY
    nameL.Font = Enum.Font.GothamBold
    nameL.TextSize = 11
    nameL.TextXAlignment = Enum.TextXAlignment.Left
    nameL.Parent = card

    local descL = Instance.new("TextLabel")
    descL.Size = UDim2.new(1, -110, 0, 11)
    descL.Position = UDim2.new(0, 42, 0, 26)
    descL.BackgroundTransparency = 1
    descL.Text = "Visual only — player tidak membesar"
    descL.TextColor3 = THEME.TEXT_MUTED
    descL.Font = Enum.Font.Gotham
    descL.TextSize = 7
    descL.TextXAlignment = Enum.TextXAlignment.Left
    descL.Parent = card

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

    local valueL = Instance.new("TextLabel")
    valueL.Size = UDim2.new(0, 50, 0, 14)
    valueL.Position = UDim2.new(1, -58, 0, 34)
    valueL.BackgroundTransparency = 1
    valueL.Text = "x1"
    valueL.TextColor3 = WHITE
    valueL.Font = Enum.Font.GothamBold
    valueL.TextSize = 10
    valueL.TextXAlignment = Enum.TextXAlignment.Center
    valueL.Parent = card

    -- Slider
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
    knob.BackgroundColor3 = WHITE
    knob.Text = ""
    knob.BorderSizePixel = 0
    knob.AutoButtonColor = false
    knob.Parent = track
    corner(knob, 8)
    stroke(knob, ORANGE, 2, 0)

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

    -- Slider logic
    local function applySlider(val)
        val = math.clamp(math.floor(val + 0.5), 1, 20)
        hitboxSize = val
        local pct = (val - 1) / 19
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, -8, 0.5, -8)
        valueL.Text = "x" .. val
        valueL.TextColor3 = getBoxColor(val)
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

    -- Toggle ON/OFF
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
            tween(knob, 0.15, {BackgroundColor3 = WHITE}):Play()
            badge.Text = "OFF"
            badge.TextColor3 = THEME.TEXT_MUTED
            stroke(card, THEME.BORDER, 1, 0)
        end
    end

    badge.MouseButton1Click:Connect(function()
        hitboxEnabled = not hitboxEnabled
        updateBadge()
        if hitboxEnabled then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    createBox(p.UserId)
                end
            end
            startRender()
        else
            stopRender()
        end
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
    gridLayout.CellSize    = UDim2.new(0.18, -3, 1, 0)
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
                "🎯 %s  |  Box: x%d  |  %d target",
                hitboxEnabled and "ON" or "OFF",
                hitboxSize,
                count
            )
            statusL.TextColor3 = hitboxEnabled and ORANGE or THEME.TEXT_MUTED
        end
    end)

    -- Init
    applySlider(1)

end

return { init = init }
