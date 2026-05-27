--[[
    TiooHub V2.1 — FastSpeed Module
    Tab    : Combat
    Author : Tiooprime2
]]

local Players = game:GetService("Players")
local RunSvc  = game:GetService("RunService")

local player = Players.LocalPlayer

local CONFIG = {
    SPEED = 80,
}

local isEnabled = false
local _speedConn = nil

local function stopSpeedLoop()
    if _speedConn then
        _speedConn:Disconnect()
        _speedConn = nil
    end
end

local function startSpeedLoop()
    stopSpeedLoop()

    _speedConn = RunSvc.Heartbeat:Connect(function()
        if not isEnabled then return end

        local char = player.Character
        if not char then return end

        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not hum or not root then return end
        if hum.Health <= 0 then return end
        if hum.Sit then return end

        local moveDir = hum.MoveDirection
        if moveDir.Magnitude <= 0.01 then return end

        local flatDir = Vector3.new(moveDir.X, 0, moveDir.Z)
        if flatDir.Magnitude <= 0.01 then return end

        local curVel = root.AssemblyLinearVelocity
        local targetFlat = flatDir.Unit * CONFIG.SPEED
        root.AssemblyLinearVelocity = Vector3.new(targetFlat.X, curVel.Y, targetFlat.Z)
    end)
end

local FastSpeed = {}

function FastSpeed.build(page, UI)
    UI.createSection(page, "Movement")

    UI.createToggle(
        page,
        "Fast Speed",
        string.format("Lock speed ke %d (stabil walau ada bonus %% accessories)", CONFIG.SPEED),
        false,
        function(state)
            isEnabled = state
            if state then
                startSpeedLoop()
            else
                stopSpeedLoop()
            end
        end
    )

    player.CharacterRemoving:Connect(function()
        stopSpeedLoop()
    end)
end

return FastSpeed

