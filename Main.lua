-- ╔══════════════════════════════════════════╗
-- ║        TIOO BETA V1 — MAIN LOADER        ║
-- ╚══════════════════════════════════════════╝

local BASE_URL = "https://raw.githubusercontent.com/Tiooprime2/war1/main/"

-- ═══════════════════════════════════════════
-- LOAD UI
-- ═══════════════════════════════════════════
local ok1, UI = pcall(function()
    return loadstring(game:HttpGet(BASE_URL .. "ui.lua"))()
end)
if not ok1 then
    warn("❌ Gagal load ui.lua:", UI)
    return
end

-- ═══════════════════════════════════════════
-- LOAD HITBOX
-- ═══════════════════════════════════════════
local ok2, Hitbox = pcall(function()
    return loadstring(game:HttpGet(BASE_URL .. "hitbox.lua"))()
end)
if not ok2 then
    warn("❌ Gagal load hitbox.lua:", Hitbox)
    return
end

-- ═══════════════════════════════════════════
-- LOAD FASTSPEED
-- ═══════════════════════════════════════════
local ok3, FastSpeed = pcall(function()
    return loadstring(game:HttpGet(BASE_URL .. "Fastspeed.lua"))()
end)
if not ok3 then
    warn("❌ Gagal load Fastspeed.lua:", FastSpeed)
    return
end

-- ═══════════════════════════════════════════
-- LOAD MELE HITBOX
-- ═══════════════════════════════════════════
local ok4, MeleHitbox = pcall(function()
    return loadstring(game:HttpGet(BASE_URL .. "MeleHitbox.lua"))()
end)
if not ok4 then
    warn("❌ Gagal load mele_hitbox.lua:", MeleHitbox)
    return
end

-- ═══════════════════════════════════════════
-- INIT SEMUA MODULE
-- ═══════════════════════════════════════════
task.wait(0.1)

-- Hitbox FPS → masuk hitboxPage
Hitbox.init(
    UI.hitboxPage,
    UI.THEME,
    UI.tween,
    UI.corner,
    UI.stroke,
    UI.mainGui
)

-- MeleHitbox → masuk hitboxPage juga (di bawah hitbox FPS)
MeleHitbox.init(
    UI.hitboxPage,
    UI.THEME,
    UI.tween,
    UI.corner,
    UI.stroke,
    UI.mainGui
)

-- FastSpeed → masuk mainPage
FastSpeed.build(UI.mainPage, UI)
