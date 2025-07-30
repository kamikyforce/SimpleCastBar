-- Simple Cast Bar Addon
local addonName = "SimpleCastBar"
local addon = {}
_G[addonName] = addon

-- Configuration
local config = {
    enabled = true,
    showSeduction = true,
    barWidth = 200,
    barHeight = 20,
    position = { x = 0, y = -100 }
}

-- Spell database
local importantSpells = {
    ["Seduction"] = { duration = 1.5, color = {1, 0, 1} }, -- Purple for Seduction
    ["Sedução"] = { duration = 1.5, color = {1, 0, 1} }, -- Portuguese
    ["Polymorph"] = { duration = 1.5, color = {0, 0.5, 1} }, -- Blue
    ["Fear"] = { duration = 1.5, color = {0.5, 0, 0.5} }, -- Dark purple
    
    -- Channeled spells
    ["Mind Control"] = { duration = 8, color = {0.5, 0, 1} }, -- Purple
    ["Drain Soul"] = { duration = 5, color = {0.3, 0, 0.3} }, -- Dark purple
    ["Banish"] = { duration = 1.5, color = {1, 0.5, 0} }, -- Orange
    ["Enslave Demon"] = { duration = 3, color = {1, 0, 0} }, -- Red
}

-- Frame creation
local function CreateCastBar()
    local frame = CreateFrame("Frame", "SimpleCastBarFrame", UIParent)
    frame:SetSize(config.barWidth, config.barHeight)
    frame:SetPoint("CENTER", UIParent, "CENTER", config.position.x, config.position.y)
    
    -- Background
    frame.bg = frame:CreateTexture(nil, "BACKGROUND")
    frame.bg:SetAllPoints()
    frame.bg:SetTexture(0, 0, 0, 0.8)
    
    -- Cast bar
    frame.bar = CreateFrame("StatusBar", nil, frame)
    frame.bar:SetAllPoints()
    frame.bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    frame.bar:SetMinMaxValues(0, 1)
    frame.bar:SetValue(0)
    
    -- Spell text
    frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.text:SetPoint("CENTER")
    frame.text:SetTextColor(1, 1, 1)
    
    -- Timer text
    frame.timer = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.timer:SetPoint("RIGHT", frame, "RIGHT", -5, 0)
    frame.timer:SetTextColor(1, 1, 1)
    
    -- Border
    frame.border = CreateFrame("Frame", nil, frame)
    frame.border:SetAllPoints()
    frame.border:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    
    frame:Hide()
    return frame
end

-- Main cast bar frame
local castBar = CreateCastBar()
local currentCast = nil
local castEndTime = 0

-- Show cast bar
local function ShowCastBar(spellName, duration, caster)
    if not config.enabled then return end
    
    local spellData = importantSpells[spellName]
    if not spellData then return end
    
    currentCast = {
        spell = spellName,
        duration = duration or spellData.duration,
        caster = caster or "Unknown",
        startTime = GetTime()
    }
    
    castEndTime = currentCast.startTime + currentCast.duration
    
    -- Set colors
    local color = spellData.color
    castBar.bar:SetStatusBarColor(color[1], color[2], color[3], 0.8)
    
    -- Set text
    castBar.text:SetText(spellName .. (caster and (" (" .. caster .. ")") or ""))
    
    castBar:Show()
end

-- Hide cast bar
local function HideCastBar()
    castBar:Hide()
    currentCast = nil
end

-- Update cast bar
local function UpdateCastBar()
    if not currentCast then return end
    
    local currentTime = GetTime()
    local elapsed = currentTime - currentCast.startTime
    local remaining = castEndTime - currentTime
    
    if remaining <= 0 then
        HideCastBar()
        return
    end
    
    -- Update progress
    local progress = elapsed / currentCast.duration
    castBar.bar:SetValue(progress)
    
    -- Update timer
    castBar.timer:SetText(string.format("%.1f", remaining))
end

-- Event frame
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
eventFrame:RegisterEvent("UNIT_SPELLCAST_START")
eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")  -- Add this line
eventFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")   -- Add this line
eventFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
eventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_INTERRUPTED")  -- Add this line

-- Event handler
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonLoaded = ...
        if addonLoaded == addonName then
            print("|cff00ff00Simple Cast Bar|r loaded! Type /scb for options.")
        end
        
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        -- 3.3.5a compatible combat log parsing
        local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13 = ...
        local eventType = arg2
        local sourceName = arg5
        local destName = arg9
        
        if eventType == "SPELL_CAST_START" then
            local spellName = arg13 or arg12
            
            -- Check if it's targeting the player
            if destName == UnitName("player") and spellName and importantSpells[spellName] then
                ShowCastBar(spellName, nil, sourceName)
            end
        end
        
    elseif event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" then
        local unit = ...
        if unit and (string.find(unit, "target") or string.find(unit, "focus")) then
            local spellName
            if event == "UNIT_SPELLCAST_START" then
                spellName = UnitCastingInfo(unit)
            else  -- UNIT_SPELLCAST_CHANNEL_START
                spellName = UnitChannelInfo(unit)
            end
            
            if spellName and importantSpells[spellName] then
                local casterName = UnitName(unit)
                ShowCastBar(spellName, nil, casterName)
            end
        end
        
    elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" or 
           event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" or 
           event == "UNIT_SPELLCAST_CHANNEL_INTERRUPTED" then
        if currentCast then
            HideCastBar()
        end
    end
end)

-- Update timer - Use frame-based timer for 3.3.5a compatibility
local updateFrame = CreateFrame("Frame")
local lastUpdate = 0
updateFrame:SetScript("OnUpdate", function(self, elapsed)
    lastUpdate = lastUpdate + elapsed
    if lastUpdate >= 0.1 then
        UpdateCastBar()
        lastUpdate = 0
    end
end)

-- Slash commands
SLASH_SIMPLECASTBAR1 = "/scb"
SLASH_SIMPLECASTBAR2 = "/simplecastbar"
SlashCmdList["SIMPLECASTBAR"] = function(msg)
    local cmd = string.lower(msg or "")
    
    if cmd == "toggle" then
        config.enabled = not config.enabled
        print("|cff00ff00Simple Cast Bar:|r " .. (config.enabled and "Enabled" or "Disabled"))
    elseif cmd == "test" then
        ShowCastBar("Seduction", 1.5, "Test Warlock")
        print("|cff00ff00Simple Cast Bar:|r Test cast bar shown")
    elseif cmd == "hide" then
        HideCastBar()
        print("|cff00ff00Simple Cast Bar:|r Cast bar hidden")
    else
        print("|cff00ff00Simple Cast Bar Commands:|r")
        print("/scb toggle - Enable/disable the addon")
        print("/scb test - Show a test cast bar")
        print("/scb hide - Hide current cast bar")
    end
end

-- Make frame movable (drag to reposition)
castBar:SetMovable(true)
castBar:EnableMouse(true)
castBar:RegisterForDrag("LeftButton")
castBar:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
castBar:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, _, x, y = self:GetPoint()
    config.position.x = x
    config.position.y = y
end)