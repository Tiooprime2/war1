-- ╔══════════════════════════════════════════╗
-- ║     TIOO BETA V1 — HITBOX TAB            ║
-- ║   ESP Box & Real Hitbox — FIXED WORK     ║
-- ╚══════════════════════════════════════════╝

local function init(page, THEME, tween, corner, stroke, mainGui)

    local Players          = game:GetService("Players")
    local RunService       = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local player           = Players.LocalPlayer
    local camera           = workspace.CurrentCamera

    local ORANGE = THEME.ORANGE or Color3.fromRGB(255, 160, 50)
    local WHITE  = Color3.fromRGB(255, 255, 255)
    local RED    = THEME.RED    or Color3.fromRGB(255, 70, 70)

    -- ═══════════════════════════════
    -- State
    -- ═══════════════════════════════
    local hitboxEnabled     = false
    local hitboxSize        = 1
    local renderConn        = nil
    local espCache          = {}

    -- ═══════════════════════════════
    -- Warna berdasarkan size
    -- ═══════════════════════════════
    local function getBoxColor(val)
        if val <= 1 then return WHITE
        elseif val <= 7 then return ORANGE
        else return RED end
    end

    -- ═══════════════════════════════
    -- Fungsi Drawing ESP
    -- ═══════════════════════════════
    local function createESP(p)
        if p == player or espCache[p] then return end
        
        local box = Drawing.new("Square")
        box.Thickness = 2
        box.Filled = false
        box.Visible = false
        
        espCache[p] = { box = box }
    end

    local function removeESP(p)
        if espCache[p] then
            espCache[p].box:Remove()
            espCache[p] = nil
        end
    end

    -- Setup awal untuk player yang sudah ada
    for _, p in ipairs(Players:GetPlayers()) do createESP(p) end
    Players.PlayerAdded:Connect(createESP)
    Players.PlayerRemoving:Connect(removeESP)

    -- ═══════════════════════════════
    -- Render Loop & REAL HITBOX EXPANDER
    -- ═══════════════════════════════
    local function startRender()
        if renderConn then renderConn:Disconnect() end

        renderConn = RunService.RenderStepped:Connect(function()
            if not hitboxEnabled then return end

            local col = getBoxColor(hitboxSize)

            for p, esp in pairs(espCache) do
                local char = p.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                local hum  = char and char:FindFirstChild("Humanoid")

                if hrp and hum and hum.Health > 0 then
                    -- 💥 REAL HITBOX LOGIC: Membesarkan bagian part asli agar bisa dipukul
                    hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                    hrp.Transparency = 0.7 -- Transparan biar ga nutupin layar
                    hrp.Color = col
                    hrp.Material = Enum.Material.Neon
                    hrp.CanCollide = false -- Biar ga tabrakan / nge-bug jalannya

                    -- 👁️ DRAWING ESP LOGIC: Akurat mengikuti besar part
                    local pos, vis = camera:WorldToViewportPoint(hrp.Position)
                    if vis then
                        -- Hitung tinggi atas bawah berdasarkan ukuran baru hitboxSize
                        local offset = hitboxSize / 2
                        local topScreen, _    = camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, offset, 0))
                        local bottomScreen, _ = camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, -offset, 0))
                        
                        local boxH = math.abs(topScreen.Y - bottomScreen.Y)
                        local boxW = boxH -- Mengikuti bentuk kubus hitbox

                        esp.box.Size = Vector2.new(math.clamp(boxW, 10, 500), math.clamp(boxH, 10, 500))
                        esp.box.Position = Vector2.new(pos.X - esp.box.Size.X / 2, topScreen.Y)
                        esp.box.Color = col
                        esp.box.Visible = true
                    else
                        esp.box.Visible = false
                    end
                else
                    esp.box.Visible = false
                end
            end
        end)
    end

    local function stopRender()
        if renderConn then
            renderConn:Disconnect()
            renderConn = nil
        end
        
        -- Reset ukuran karakter kembali normal saat OFF
        for p, esp in pairs(espCache) do
            esp.box.Visible = false
            local char = p.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Size = Vector3.new(2, 2, 1) -- Ukuran default roblox
                hrp.Transparency = 1
                hrp.CanCollide = true
            end
        end
    end

    -- ═══════════════════════════════
    -- UI — SECTION HEADER & RENDER
    -- ═══════════════════════════════
    local secLabel = Instance.new("TextLabel")
    secLabel.Size = UDim2.new(1, 0, 0, 18)
    secLabel.BackgroundTransparency = 1
    secLabel.Text = "  HITBOX EXPANDER & ESP"
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
    nameL.Text = "Hitbox Expander + ESP"
    nameL.TextColor3 = THEME.TEXT_PRIMARY
    nameL.Font = Enum.Font.GothamBold
    nameL.TextSize = 11
    nameL.TextXAlignment = Enum.TextXAlignment.Left
    nameL.Parent = card

    local descL = Instance.new("TextLabel")
    descL.Size = UDim2.new(1, -110, 0, 11)
    descL.Position = UDim2.new(0, 42, 0, 26)
    descL.BackgroundTransparency = 1
    descL.Text = "Real Hitbox — Ukuran target membesar"
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
        local pct = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        applySlider(pct * 19 + 1)
    end

    knob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliderDrag = true end
    end)
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            sliderDrag = true
            sliderFromInput(i)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sliderDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then sliderFromInput(i) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliderDrag = false end
    end)

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
            startRender()
        else
            stopRender()
        end
    end)

    -- Preset & Status Card (Tetap Menggunakan Logika Bawaanmu)
    -- [Bagian Preset dan Status ditaruh di bawah sini tanpa diubah agar UI konsisten]
    applySlider(1)
end

return { init = init }
