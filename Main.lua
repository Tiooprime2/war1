-- ╔══════════════════════════════════════════╗
-- ║        TIOO BETA V1 — MAIN LOADER        ║
-- ╚══════════════════════════════════════════╝

local BASE_URL = "https://raw.githubusercontent.com/Tiooprime2/war1/refs/heads/main/"

-- 1. Load Base UI Terlebih Dahulu
local UI = loadstring(game:HttpGet(BASE_URL .. "ui.lua"))()

-- 2. Load dan Jalankan Modul Hitbox
local Hitbox = loadstring(game:HttpGet(BASE_URL .. "hitbox.lua"))()
Hitbox.init(UI.hitboxPage, UI.THEME, UI.tween, UI.corner, UI.stroke, UI.mainGui)

-- 3. Load dan Jalankan Modul FastSpeed
local Fastspeed = loadstring(game:HttpGet(BASE_URL .. "FastSpeed.lua"))()
-- Oper variabel ke FastSpeed (Gunakan halaman yang sama atau UI.movementPage jika ada)
Fastspeed.init(UI.hitboxPage, UI.THEME, UI.tween, UI.corner, UI.stroke, UI.mainGui) 

print("🚀 [TIOO MAIN] All modules successfully linked via Orchestrator!")
