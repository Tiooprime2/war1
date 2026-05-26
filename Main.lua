-- ╔══════════════════════════════════════════╗
-- ║        TIOO BETA V1 — MAIN LOADER        ║
-- ╚══════════════════════════════════════════╝

local BASE_URL = "https://raw.githubusercontent.com/Tiooprime2/Ninja-legend/refs/heads/main/"

local UI      = loadstring(game:HttpGet(BASE_URL .. "SemuaUI/ui.lua"))()
local Main    = loadstring(game:HttpGet(BASE_URL .. "MainFeat/main_tab.lua"))()
local Island  = loadstring(game:HttpGet(BASE_URL .. "MainFeat/island.lua"))()
local Element = loadstring(game:HttpGet(BASE_URL .. "MainFeat/element.lua"))()
local Misc    = loadstring(game:HttpGet(BASE_URL .. "MainFeat/misc_tab.lua"))()
local Hitbox  = loadstring(game:HttpGet(BASE_URL .. "MainFeat/hitbox.lua"))()   -- ← BARU

Main.init(UI.mainPage,    UI.THEME, UI.tween, UI.corner, UI.stroke, UI.mainGui, UI.onClose)
Island.init(UI.islandPage,  UI.THEME, UI.tween, UI.corner, UI.stroke, UI.mainGui)
Element.init(UI.elementPage, UI.THEME, UI.tween, UI.corner, UI.stroke, UI.mainGui)
Misc.init(UI.miscPage,    UI.THEME, UI.tween, UI.corner, UI.stroke, UI.mainGui)
Hitbox.init(UI.hitboxPage,  UI.THEME, UI.tween, UI.corner, UI.stroke, UI.mainGui)  -- ← BARU
