-- CEK loadstring dulu
if not loadstring then
    warn("loadstring TIDAK tersedia di executor ini!")
    return
end

local BASE_URL = "https://raw.githubusercontent.com/Tiooprime2/war1/main/"

-- CEK HttpGet
local ok0, testGet = pcall(function()
    return game:HttpGet(BASE_URL .. "ui.lua")
end)
if not ok0 then
    warn("HttpGet gagal:", testGet)
    return
end

local ok1, UI = pcall(function()
    return loadstring(game:HttpGet(BASE_URL .. "ui.lua"))()
end)
if not ok1 then warn("❌ ui.lua:", UI) return end

local ok2, Hitbox = pcall(function()
    return loadstring(game:HttpGet(BASE_URL .. "hitbox.lua"))()
end)
if not ok2 then warn("❌ hitbox.lua:", Hitbox) return end

local ok3, FastSpeed = pcall(function()
    return loadstring(game:HttpGet(BASE_URL .. "Fastspeed.lua"))()
end)
if not ok3 then warn("❌ Fastspeed.lua:", FastSpeed) return end

task.wait(0.1)

Hitbox.init(UI.hitboxPage, UI.THEME, UI.tween, UI.corner, UI.stroke, UI.mainGui)
FastSpeed.build(UI.mainPage, UI)
