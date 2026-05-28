-- ╔══════════════════════════════════════════╗
-- ║  TIOO BETA V1 — MELE HITBOX + ESP        ║
-- ║  Fake Part melee + Drawing ESP box       ║
-- ║  Respawn-safe: CharacterAdded listener   ║
-- ╚══════════════════════════════════════════╝

local function init(page, THEME, tween, corner, stroke, mainGui)

    local Players          = game:GetService("Players")
    local RunService       = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")

    local player = Players.LocalPlayer
    local camera = workspace.CurrentCamera

    local ORANGE = THEME.ORANGE or Color3.fromRGB(255, 160, 50)
    local WHITE  = Color3.fromRGB(255, 255, 255)
    local RED    = THEME.RED    or Color3.fromRGB(255, 70, 70)

    -- ═══════════════════════════════
    -- STATE
    -- ═══════════════════════════════
    local meleEnabled  = false
    local meleSize     = 6
    local fakeBoxCache = {}   -- { [player] = fakePart }
    local espCache     = {}   -- { [player] = { box = Drawing } }
    local renderConn   = nil

    -- ═══════════════════════════════
    -- WARNA BERDASARKAN SIZE
    -- ═══════════════════════════════
    local function getColor(val)
        if val <= 3 then return WHITE
        elseif val <= 8 then return ORANGE
        else return RED end
    end

    -- ═══════════════════════════════
    -- ESP DRAWING
    -- ═══════════════════════════════
    local function createESP(p)
        if p == player then return end
        if espCache[p] then return end

        local box = Drawing.new("Square")
        box.Thickness = 2
        box.Filled    = false
        box.Visible   = false

        espCache[p] = { box = box }
    end

    local function removeESP(p)
        if espCache[p] then
            espCache[p].box:Remove()
            espCache[p] = nil
        end
    end

    -- ═══════════════════════════════════════════════════════════════
    -- FAKE HITBOX PART
    -- ═══════════════════════════════════════════════════════════════
    local function spawnFakeBox(p)
        if p == player then return end
        if fakeBoxCache[p] and fakeBoxCache[p].Parent then
            fakeBoxCache[p]:Destroy()
        end
        fakeBoxCache[p] = nil

        local char = p.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local part = Instance.new("Part")
        part.Name         = "MeleHitbox_" .. p.Name
        part.Size         = Vector3.new(meleSize, meleSize, meleSize)
        part.Transparency = 0.6
        part.Color        = getColor(meleSize)
        part.Material     = Enum.Material.Neon
        part.Anchored     = true
        part.CanCollide   = false
        part.CastShadow   = false
        part.Parent       = char

        fakeBoxCache[p] = part
    end

    local function removeFakeBox(p)
        if fakeBoxCache[p] then
            pcall(function() fakeBoxCache[p]:Destroy() end)
            fakeBoxCache[p] = nil
        end
    end

    local function removeAllBoxes()
        for p in pairs(fakeBoxCache) do
            removeFakeBox(p)
        end
    end

    local function updateAllSizes()
        local col = getColor(meleSize)
        for _, part in pairs(fakeBoxCache) do
            if part and part.Parent then
                part.Size  = Vector3.new(meleSize, meleSize, meleSize)
                part.Color = col
            end
        end
    end

    -- ═══════════════════════════════════════════════════════════════
    -- RENDER LOOP — Heartbeat (ringan) + ESP Drawing
    -- ═══════════════════════════════════════════════════════════════
    local MOVE_THRESHOLD = 0.1

    local function startRender()
        if renderConn then renderConn:Disconnect() end

        renderConn = RunService.Heartbeat:Connect(function()
            if not meleEnabled then return end

            local col = getColor(meleSize)

            for p, fakePart in pairs(fakeBoxCache) do
                -- Guard: part hancur saat respawn
                if not fakePart or not fakePart.Parent then
                    if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        spawnFakeBox(p)
                    end
                    continue
                end

                local char = p.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                local hum  = char and char:FindFirstChild("Humanoid")

                if hrp and hum and hum.Health > 0 then
                    -- Update fake part position (throttled)
                    local diff = (fakePart.Position - hrp.Position).Magnitude
                    if diff > MOVE_THRESHOLD then
                        fakePart.CFrame = hrp.CFrame
                    end
                    fakePart.Visible = true

                    -- ESP Drawing
                    local esp = espCache[p]
                    if esp then
                        local pos, vis = camera:WorldToViewportPoint(hrp.Position)
                        if vis then
                            local offset       = meleSize / 2
                            local topScreen    = camera:WorldToViewportPoint(hrp.Position + Vector3.new(0,  offset, 0))
                            local bottomScreen = camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, -offset, 0))

                            local boxH = math.abs(topScreen.Y - bottomScreen.Y)
                            local boxW = boxH

                            esp.box.Size     = Vector2.new(math.clamp(boxW, 10, 500), math.clamp(boxH, 10, 500))
                            esp.box.Position = Vector2.new(pos.X - esp.box.Size.X / 2, topScreen.Y)
                            esp.box.Color    = col
                            esp.box.Visible  = true
                        else
                            esp.box.Visible = false
                        end
                    end
                else
                    fakePart.Visible = false
                    if espCache[p] then espCache[p].box.Visible = false end
                end
            end
        end)
    end

    local function stopRender()
        if renderConn then
            renderConn:Disconnect()
            renderConn = nil
        end
        -- Sembunyikan semua ESP
        for _, esp in pairs(espCache) do
            esp.box.Visible = false
        end
        removeAllBoxes()
    end

    -- ═══════════════════════════════════════════════════════════════
    -- PLAYER SETUP — Respawn-safe
    -- ═══════════════════════════════════════════════════════════════
    local charConnections = {}

    local function setupPlayer(p)
        if p == player then return end

        createESP(p)

        if charConnections[p] then charConnections[p]:Disconnect() end
        charConnections[p] = p.CharacterAdded:Connect(function()
            task.wait(0.1)
            if meleEnabled then spawnFakeBox(p) end
        end)

        if meleEnabled and p.Character then spawnFakeBox(p) end
    end

    local function cleanupPlayer(p)
        if charConnections[p] then
            charConnections[p]:Disconnect()
            charConnections[p] = nil
        end
        removeFakeBox(p)
        removeESP(p)
    end

    for _, p in ipairs(Players:GetPlayers()) do setupPlayer(p) end
    Players.PlayerAdded:Connect(setupPlayer)
    Players.PlayerRemoving:Connect(cleanupPlayer)

    -- ═══════════════════════════════
    -- UI
    -- ═══════════════════════════════
    local secLabel = Instance.new("TextLabel")
    secLabel.Size               = UDim2.new(1, 0, 0, 18)
    secLabel.BackgroundTransparency = 1
    secLabel.Text               = "  MELE HITBOX (BOXING / JARAK DEKAT)"
    secLabel.TextColor3         = ORANGE
    secLabel.Font               = Enum.Font.GothamBold
    secLabel.TextSize           = 9
    secLabel.TextXAlignment     = Enum.TextXAlignment.Left
    secLabel.Parent             = page

    local card = Instance.new("Frame")
    card.Size             = UDim2.new(1, 0, 0, 100)
    card.BackgroundColor3 = THEME.BG_CARD
    card.BorderSizePixel  = 0
    card.Parent           = page
    corner(card, 10)
    stroke(card, THEME.BORDER, 1, 0)

    local accentBar = Instance.new("Frame")
    accentBar.Size             = UDim2.new(0, 4, 0.8, 0)
    accentBar.Position         = UDim2.new(0, 0, 0.1, 0)
    accentBar.BackgroundColor3 = THEME.TEXT_MUTED
    accentBar.BorderSizePixel  = 0
    accentBar.Parent           = card
    corner(accentBar, 2)

    local iconL = Instance.new("TextLabel")
    iconL.Size               = UDim2.new(0, 26, 0, 26)
    iconL.Position           = UDim2.new(0, 10, 0, 8)
    iconL.BackgroundTransparency = 1
    iconL.Text               = "🥊"
    iconL.TextSize           = 18
    iconL.Font               = Enum.Font.Gotham
    iconL.Parent             = card

    local nameL = Instance.new("TextLabel")
    nameL.Size               = UDim2.new(1, -110, 0, 16)
    nameL.Position           = UDim2.new(0, 42, 0, 8)
    nameL.BackgroundTransparency = 1
    nameL.Text               = "MeleHitbox + ESP"
    nameL.TextColor3         = THEME.TEXT_PRIMARY
    nameL.Font               = Enum.Font.GothamBold
    nameL.TextSize           = 11
    nameL.TextXAlignment     = Enum.TextXAlignment.Left
    nameL.Parent             = card

    local descL = Instance.new("TextLabel")
    descL.Size               = UDim2.new(1, -110, 0, 11)
    descL.Position           = UDim2.new(0, 42, 0, 26)
    descL.BackgroundTransparency = 1
    descL.Text               = "Fake Part + ESP Box — Melee jarak dekat"
    descL.TextColor3         = THEME.TEXT_MUTED
    descL.Font               = Enum.Font.Gotham
    descL.TextSize           = 7
    descL.TextXAlignment     = Enum.TextXAlignment.Left
    descL.Parent             = card

    local badge = Instance.new("TextButton")
    badge.Size             = UDim2.new(0, 42, 0, 20)
    badge.Position         = UDim2.new(1, -50, 0, 10)
    badge.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    badge.Text             = "OFF"
    badge.TextColor3       = THEME.TEXT_MUTED
    badge.Font             = Enum.Font.GothamBold
    badge.TextSize         = 9
    badge.BorderSizePixel  = 0
    badge.AutoButtonColor  = false
    badge.Parent           = card
    corner(badge, 10)

    local valueL = Instance.new("TextLabel")
    valueL.Size               = UDim2.new(0, 50, 0, 14)
    valueL.Position           = UDim2.new(1, -58, 0, 34)
    valueL.BackgroundTransparency = 1
    valueL.Text               = "x6"
    valueL.TextColor3         = ORANGE
    valueL.Font               = Enum.Font.GothamBold
    valueL.TextSize           = 10
    valueL.TextXAlignment     = Enum.TextXAlignment.Center
    valueL.Parent             = card

    local track = Instance.new("Frame")
    track.Size             = UDim2.new(1, -22, 0, 5)
    track.Position         = UDim2.new(0, 10, 0, 56)
    track.BackgroundColor3 = THEME.BG_HOVER
    track.BorderSizePixel  = 0
    track.Parent           = card
    corner(track, 3)

    local fill = Instance.new("Frame")
    fill.Size             = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = ORANGE
    fill.BorderSizePixel  = 0
    fill.Parent           = track
    corner(fill, 3)

    local knob = Instance.new("TextButton")
    knob.Size             = UDim2.new(0, 16, 0, 16)
    knob.Position         = UDim2.new(0, -8, 0.5, -8)
    knob.BackgroundColor3 = WHITE
    knob.Text             = ""
    knob.BorderSizePixel  = 0
    knob.AutoButtonColor  = false
    knob.Parent           = track
    corner(knob, 8)
    stroke(knob, ORANGE, 2, 0)

    local minL = Instance.new("TextLabel")
    minL.Size               = UDim2.new(0, 15, 0, 12)
    minL.Position           = UDim2.new(0, 10, 0, 68)
    minL.BackgroundTransparency = 1
    minL.Text               = "1"
    minL.TextColor3         = THEME.TEXT_MUTED
    minL.Font               = Enum.Font.Gotham
    minL.TextSize           = 8
    minL.TextXAlignment     = Enum.TextXAlignment.Left
    minL.Parent             = card

    local maxL = Instance.new("TextLabel")
    maxL.Size               = UDim2.new(0, 20, 0, 12)
    maxL.Position           = UDim2.new(1, -30, 0, 68)
    maxL.BackgroundTransparency = 1
    maxL.Text               = "20"
    maxL.TextColor3         = THEME.TEXT_MUTED
    maxL.Font               = Enum.Font.Gotham
    maxL.TextSize           = 8
    maxL.TextXAlignment     = Enum.TextXAlignment.Right
    maxL.Parent             = card

    -- ═══════════════════════════════
    -- SLIDER LOGIC
    -- ═══════════════════════════════
    local sliderDrag = false

    local function applySlider(val)
        val = math.clamp(math.floor(val + 0.5), 1, 20)
        meleSize = val
        local pct = (val - 1) / 19
        fill.Size         = UDim2.new(pct, 0, 1, 0)
        knob.Position     = UDim2.new(pct, -8, 0.5, -8)
        valueL.Text       = "x" .. val
        valueL.TextColor3 = getColor(val)
        if meleEnabled then updateAllSizes() end
    end

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
        ) then
            sliderFromInput(i)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            sliderDrag = false
        end
    end)

    -- ═══════════════════════════════
    -- BADGE TOGGLE
    -- ═══════════════════════════════
    local function updateBadge()
        if meleEnabled then
            tween(card,      0.2,  {BackgroundColor3 = Color3.fromRGB(40, 22, 5)}):Play()
            tween(accentBar, 0.2,  {BackgroundColor3 = ORANGE}):Play()
            tween(badge,     0.2,  {BackgroundColor3 = ORANGE}):Play()
            tween(knob,      0.15, {BackgroundColor3 = ORANGE}):Play()
            badge.Text       = "ON"
            badge.TextColor3 = WHITE
            stroke(card, ORANGE, 1, 0.3)
        else
            tween(card,      0.2,  {BackgroundColor3 = THEME.BG_CARD}):Play()
            tween(accentBar, 0.2,  {BackgroundColor3 = THEME.TEXT_MUTED}):Play()
            tween(badge,     0.2,  {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}):Play()
            tween(knob,      0.15, {BackgroundColor3 = WHITE}):Play()
            badge.Text       = "OFF"
            badge.TextColor3 = THEME.TEXT_MUTED
            stroke(card, THEME.BORDER, 1, 0)
        end
    end

    badge.MouseButton1Click:Connect(function()
        meleEnabled = not meleEnabled
        updateBadge()
        if meleEnabled then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    spawnFakeBox(p)
                end
            end
            updateAllSizes()
            startRender()
        else
            stopRender()
        end
    end)

    applySlider(6)
end

return { init = init }
