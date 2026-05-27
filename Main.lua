-- ╔══════════════════════════════════════════╗
-- ║       TIOO BETA V1 — DEBUG LOADER        ║
-- ╚══════════════════════════════════════════╝

local BASE_URL = "https://raw.githubusercontent.com/Tiooprime2/war1/refs/heads/main/"

print("🔍 [TIOO] Starting Main Loader...")

-- 1. Load UI
local uiSuccess, UI = pcall(function()
    return loadstring(game:HttpGet(BASE_URL .. "ui.lua"))()
end)

if not uiSuccess or not UI then
    warn("❌ [TIOO ERROR] Gagal load ui.lua atau ui.lua tidak me-return tabel! Detail:", UI)
    return
end

print("✅ [TIOO] ui.lua loaded. Checking variables...")
print("-> hitboxPage:", UI.hitboxPage)
print("-> THEME:", UI.THEME)

-- 2. Load Hitbox
local hitboxSuccess, Hitbox = pcall(function()
    return loadstring(game:HttpGet(BASE_URL .. "hitbox.lua"))()
end)

if hitboxSuccess and Hitbox then
    local runHitbox, err = pcall(function()
        Hitbox.init(UI.hitboxPage, UI.THEME, UI.tween, UI.corner, UI.stroke, UI.mainGui)
    end)
    if not runHitbox then
        warn("❌ [TIOO ERROR] Gagal menjalankan Hitbox.init! Detail:", err)
    end
else
    warn("❌ [TIOO ERROR] Gagal download hitbox.lua! Detail:", Hitbox)
end

-- 3. Load FastSpeed
local speedSuccess, Fastspeed = pcall(function()
    return loadstring(game:HttpGet(BASE_URL .. "FastSpeed.lua"))()
end)

if speedSuccess and Fastspeed then
    local runSpeed, err = pcall(function()
        Fastspeed.init(UI.hitboxPage, UI.THEME, UI.tween, UI.corner, UI.stroke, UI.mainGui)
    end)
    if not runSpeed then
        warn("❌ [TIOO ERROR] Gagal menjalankan Fastspeed.init! Detail:", err)
    end
else
    warn("❌ [TIOO ERROR] Gagal download FastSpeed.lua! Detail:", Fastspeed)
end

print("🚀 [TIOO] Debug Loader Finished Execution!")
