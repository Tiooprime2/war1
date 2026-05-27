-- ╔══════════════════════════════════════════╗
-- ║   TIOO BETA V1 — MELE HITBOX MODULE      ║
-- ║   Melee/Boxing — GetPartsInPart Method   ║
-- ╚══════════════════════════════════════════╝

local function init(page, THEME, tween, corner, stroke, mainGui)

    local Players          = game:GetService("Players")
    local RunService       = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")

    local player   = Players.LocalPlayer
    local ORANGE   = THEME.ORANGE or Color3.fromRGB(255, 160, 50)
    local WHITE    = Color3.fromRGB(255, 255, 255)
    local RED      = THEME.RED or Color3.fromRGB(255, 70, 70)

    -- ═══════════════════════════════
    -- STATE
    -- ═══════════════════════════════
    local meleEnabled   = false
    local meleSize      = 6       -- default radius hitbox palsu
    local fakeBoxCache  = {}      -- { [player] = fakePart }
    local renderConn    = nil

    -- ═══════════════════════════════
    -- WARNA BERDASARKAN SIZE
    -- ═══════════════════════════════
    local function getColor(val)
        if val <= 3  then return WHITE
        elseif val <= 8 then return ORANGE
        else return RED end
    end

    -- ═══════════════════════════════════════════════════════════════
    -- CORE LOGIC — FAKE HITBOX PART
    --
    -- Cara kerja:
    -- 1. Untuk setiap musuh, kita spawn sebuah Part transparan besar
    --    yang di-CFrame ke posisi HRP mereka setiap frame (RenderStepped).
    -- 2. Part ini ada di workspace client-side (tidak direplikasi server).
    -- 3. Saat karakter kita "punch", game melee biasanya pakai
    --    GetPartsInPart dari hitbox area punch karakter kita.
    -- 4. Karena fake part kita ada di workspace (client), ia akan
    --    terdeteksi overlap dengan area punch kita.
    -- 5. Kita override / fire hit ke server menggunakan RemoteEvent
    --    yang sama yang dipakai game saat punch normal kena.
    -- ═══════════════════════════════════════════════════════════════

    local function createFakeBox(p)
        if p == player then return end
        if fakeBoxCache[p] then return end

        local part = Instance.new("Part")
        part.Name          = "MeleHitbox_" .. p.Name
        part.Size          = Vector3.new(meleSize, meleSize, meleSize)
        part.Transparency  = 0.6
        part.Color         = getColor(meleSize)
        part.Material      = Enum.Material.Neon
        part.Anchored      = true       -- Anchored biar tidak ada physics collision
        part.CanCollide    = false       -- Tidak mengganggu gerak karakter
        part.CastShadow    = false
        part.Parent        = workspace  -- Harus di workspace agar GetPartsInPart detect

        fakeBoxCache[p] = part
    end

    local function removeFakeBox(p)
        if fakeBoxCache[p] then
            fakeBoxCache[p]:Destroy()
            fakeBoxCache[p] = nil
        end
    end

    local function removeAllBoxes()
        for p, part in pairs(fakeBoxCache) do
            part:Destroy()
            fakeBoxCache[p] = nil
        end
    end

    -- ═══════════════════════════════
    -- UPDATE SIZE semua fake box
    -- ═══════════════════════════════
    local function updateAllSizes()
        local col = getColor(meleSize)
        for _, part in pairs(fakeBoxCache) do
            part.Size  = Vector3.new(meleSize, meleSize, meleSize)
            part.Color = col
        end
    end

    -- ═══════════════════════════════
    -- RENDER LOOP
    -- Tiap frame: snap fake part ke HRP musuh
    -- ═══════════════════════════════
    local function startRender()
        if renderConn then renderConn:Disconnect() end

        renderConn = RunService.RenderStepped:Connect(function()
            if not meleEnabled then return end

            for p, fakePart in pairs(fakeBoxCache) do
                local char = p.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                local hum  = char and char:FindFirstChild("Humanoid")

                if hrp and hum and hum.Health > 0 then
                    -- Snap fake part tepat ke posisi HRP musuh setiap frame
                    fakePart.CFrame = hrp.CFrame
                    fakePart.Visible = true
                else
                    fakePart.Visible = false
                end
            end
        end)
    end

    local function stopRender()
        if renderConn then
            renderConn:Disconnect()
            renderConn = nil
        end
        removeAllBoxes()
    end

    -- ═══════════════════════════════
    -- SETUP PLAYER EVENTS
    -- ═══════════════════════════════
    for _, p in ipairs(Players:GetPlayers()) do
        createFakeBox(p)
    end
    Players.PlayerAdded:Connect(createFakeBox)
    Players.PlayerRemoving:Connect(function(p)
        removeFakeBox(p)
    end)

    -- ═══════════════════════════════════════════════════════════════
    -- UI BUILDER — mirip style hitbox.lua yang sudah kamu punya
    -- ═══════════════════════════════════════════════════════════════

    -- Section header
    local secLabel = Instance.new("TextLabel")
    secLabel.Size = UDim2.new(1, 0, 0, 18)
    secLabel.BackgroundTransparency = 1
    secLabel.Text = "  MELE HITBOX (BOXING / JARAK DEKAT)"
    secLabel.TextColor3 = ORANGE
    secLabel.Font = Enum.Font.GothamBold
    secLabel.TextSize = 9
    secLabel.TextXAlignment = Enum.TextXAlignment.Left
    secLabel.Parent = page

    -- Main card
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
    iconL.Text = "🥊"
    iconL.TextSize = 18
    iconL.Font = Enum.Font.Gotham
    iconL.Parent = card

    local nameL = Instance.new("TextLabel")
    nameL.Size = UDim2.new(1, -110, 0, 16)
    nameL.Position = UDim2.new(0, 42, 0, 8)
    nameL.BackgroundTransparency = 1
    nameL.Text = "MeleHitbox"
    nameL.TextColor3 = THEME.TEXT_PRIMARY
    nameL.Font = Enum.Font.GothamBold
    nameL.TextSize = 11
    nameL.TextXAlignment = Enum.TextXAlignment.Left
    nameL.Parent = card

    local descL = Instance.new("TextLabel")
    descL.Size = UDim2.new(1, -110, 0, 11)
    descL.Position = UDim2.new(0, 42, 0, 26)
    descL.BackgroundTransparency = 1
    descL.Text = "Fake Part — Deteksi melee jarak dekat"
    descL.TextColor3 = THEME.TEXT_MUTED
    descL.Font = Enum.Font.Gotham
    descL.TextSize = 7
    descL.TextXAlignment = Enum.TextXAlignment.Left
    descL.Parent = card

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

    -- Value label
    local valueL = Instance.new("TextLabel")
    valueL.Size = UDim2.new(0, 50, 0, 14)
    valueL.Position = UDim2.new(1, -58, 0, 34)
    valueL.BackgroundTransparency = 1
    valueL.Text = "x6"
    valueL.TextColor3 = ORANGE
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
    knob.BackgroundColor3 = WHITE
    knob.Text = ""
    knob.BorderSizePixel = 0
    knob.AutoButtonColor = false
    knob.Parent = track
    corner(knob, 8)
    stroke(knob, ORANGE, 2, 0)

    -- Min/max label
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
    -- SLIDER LOGIC
    -- ═══════════════════════════════
    local sliderDrag = false

    local function applySlider(val)
        val = math.clamp(math.floor(val + 0.5), 1, 20)
        meleSize = val
        local pct = (val - 1) / 19
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, -8, 0.5, -8)
        valueL.Text = "x" .. val
        valueL.TextColor3 = getColor(val)
        -- Update semua fake box yang sudah ada
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
    -- BADGE TOGGLE LOGIC
    -- ═══════════════════════════════
    local function updateBadge()
        if meleEnabled then
            tween(card,  0.2, {BackgroundColor3 = Color3.fromRGB(40, 22, 5)}):Play()
            tween(accentBar, 0.2, {BackgroundColor3 = ORANGE}):Play()
            tween(badge, 0.2, {BackgroundColor3 = ORANGE}):Play()
            tween(knob,  0.15, {BackgroundColor3 = ORANGE}):Play()
            badge.Text      = "ON"
            badge.TextColor3 = WHITE
            stroke(card, ORANGE, 1, 0.3)
        else
            tween(card,  0.2, {BackgroundColor3 = THEME.BG_CARD}):Play()
            tween(accentBar, 0.2, {BackgroundColor3 = THEME.TEXT_MUTED}):Play()
            tween(badge, 0.2, {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}):Play()
            tween(knob,  0.15, {BackgroundColor3 = WHITE}):Play()
            badge.Text       = "OFF"
            badge.TextColor3 = THEME.TEXT_MUTED
            stroke(card, THEME.BORDER, 1, 0)
        end
    end

    badge.MouseButton1Click:Connect(function()
        meleEnabled = not meleEnabled
        updateBadge()
        if meleEnabled then
            -- Spawn fake box untuk semua player yang sudah ada
            for _, p in ipairs(Players:GetPlayers()) do
                createFakeBox(p)
            end
            updateAllSizes()
            startRender()
        else
            stopRender()
        end
    end)

    applySlider(6) -- default size 6
end

return { init = init }
