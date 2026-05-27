-- ╔══════════════════════════════════════════╗
-- ║        TIOO BETA V1 — MAIN LOADER        ║
-- ╚══════════════════════════════════════════╝

local BASE_URL = "https://raw.githubusercontent.com/Tiooprime2/war1/refs/heads/main/"

local UI        = loadstring(game:HttpGet(BASE_URL .. "ui.lua"))()
local Hitbox    = loadstring(game:HttpGet(BASE_URL .. "hitbox.lua"))()
local FastSpeed = loadstring(game:HttpGet(BASE_URL .. "FastSpeed.lua"))()

Hitbox.init(UI.hitboxPage, UI.THEME, UI.tween, UI.corner, UI.stroke, UI.mainGui)
FastSpeed.build(UI.mainPage, UI)  -- ← pakai mainPage
