-- Simple Cast Bar Addon
local addonName = "SimpleCastBar"
local addon = {}
_G[addonName] = addon

-- Enhanced Configuration
local config = {
    enabled = true,
    showSeduction = true,
    barWidth = 200,
    barHeight = 20,
    position = { x = 0, y = -100 },
    -- New styling options
    backgroundColor = { r = 0, g = 0, b = 0, a = 0.8 },
    borderColor = { r = 1, g = 1, b = 1, a = 1 },
    textColor = { r = 1, g = 1, b = 1, a = 1 },
    scale = 1.0,
    locked = false, -- Lock position and size
    showBorder = true,
    borderSize = 2,
    font = "Fonts\\FRIZQT__.TTF",
    fontSize = 12
}

-- Spell database (Portuguese removed)
local importantSpells = {
    ["Seduction"] = { duration = 1.5, color = {1, 0, 1} }, -- Purple for Seduction
    ["Polymorph"] = { duration = 1.5, color = {0, 0.5, 1} }, -- Blue
    ["Fear"] = { duration = 1.5, color = {0.5, 0, 0.5} }, -- Dark purple
    
    -- Channeled spells
    ["Mind Control"] = { duration = 8, color = {0.5, 0, 1} }, -- Purple
    ["Drain Soul"] = { duration = 5, color = {0.3, 0, 0.3} }, -- Dark purple
    ["Banish"] = { duration = 1.5, color = {1, 0.5, 0} }, -- Orange
    ["Enslave Demon"] = { duration = 3, color = {1, 0, 0} }, -- Red
}

-- Enhanced Frame creation with better styling
local function CreateCastBar()
    local frame = CreateFrame("Frame", "SimpleCastBarFrame", UIParent)
    frame:SetSize(config.barWidth, config.barHeight)
    frame:SetPoint("CENTER", UIParent, "CENTER", config.position.x, config.position.y)
    frame:SetScale(config.scale)
    frame:SetFrameStrata("MEDIUM")
    frame:SetFrameLevel(10)
    
    -- Background with gradient effect
    frame.bg = frame:CreateTexture(nil, "BACKGROUND")
    frame.bg:SetAllPoints()
    frame.bg:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
    frame.bg:SetVertexColor(config.backgroundColor.r, config.backgroundColor.g, config.backgroundColor.b, config.backgroundColor.a)
    
    -- Cast bar with improved texture
    frame.bar = CreateFrame("StatusBar", nil, frame)
    frame.bar:SetPoint("TOPLEFT", frame, "TOPLEFT", config.borderSize, -config.borderSize)
    frame.bar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -config.borderSize, config.borderSize)
    frame.bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    frame.bar:SetMinMaxValues(0, 1)
    frame.bar:SetValue(0)
    
    -- Spell text with custom font
    frame.text = frame:CreateFontString(nil, "OVERLAY")
    frame.text:SetFont(config.font, config.fontSize, "OUTLINE")
    frame.text:SetPoint("LEFT", frame, "LEFT", 8, 0)
    frame.text:SetTextColor(config.textColor.r, config.textColor.g, config.textColor.b, config.textColor.a)
    frame.text:SetJustifyH("LEFT")
    
    -- Timer text
    frame.timer = frame:CreateFontString(nil, "OVERLAY")
    frame.timer:SetFont(config.font, config.fontSize, "OUTLINE")
    frame.timer:SetPoint("RIGHT", frame, "RIGHT", -8, 0)
    frame.timer:SetTextColor(config.textColor.r, config.textColor.g, config.textColor.b, config.textColor.a)
    frame.timer:SetJustifyH("RIGHT")
    
    -- Enhanced border
    if config.showBorder then
        frame.border = CreateFrame("Frame", nil, frame)
        frame.border:SetAllPoints()
        frame.border:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = config.borderSize * 8,
            insets = { left = config.borderSize, right = config.borderSize, top = config.borderSize, bottom = config.borderSize }
        })
        frame.border:SetBackdropBorderColor(config.borderColor.r, config.borderColor.g, config.borderColor.b, config.borderColor.a)
    end
    
    -- Resize handles (corners)
    frame.resizeHandles = {}
    local handleSize = 8
    local corners = {
        {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 0, "BOTTOMRIGHT"},
        {"BOTTOMLEFT", "BOTTOMLEFT", 0, 0, "BOTTOMLEFT"},
        {"TOPRIGHT", "TOPRIGHT", 0, 0, "TOPRIGHT"},
        {"TOPLEFT", "TOPLEFT", 0, 0, "TOPLEFT"}
    }
    
    for i, corner in ipairs(corners) do
        local handle = CreateFrame("Frame", nil, frame)
        handle:SetSize(handleSize, handleSize)
        handle:SetPoint(corner[1], frame, corner[2], corner[3], corner[4])
        handle:EnableMouse(true)
        handle:SetScript("OnEnter", function(self)
            SetCursor("Interface\\CURSOR\\UI-Cursor-SizeAll")
        end)
        handle:SetScript("OnLeave", function(self)
            ResetCursor()
        end)
        
        -- Visual indicator for resize handle
        handle.texture = handle:CreateTexture(nil, "OVERLAY")
        handle.texture:SetAllPoints()
        handle.texture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
        handle.texture:SetAlpha(0.5)
        
        handle.corner = corner[5]
        frame.resizeHandles[i] = handle
    end
    
    frame:Hide()
    return frame
end

-- Main cast bar frame
local castBar = CreateCastBar()
local currentCast = nil
local castEndTime = 0

-- Test mode variables
local testMode = false
local testTimer = nil

-- Enhanced frame movement and resizing
local function SetupFrameInteraction(frame)
    -- Make frame movable
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    
    -- Moving functionality
    frame:SetScript("OnDragStart", function(self)
        if not config.locked then
            self:StartMoving()
        end
    end)
    
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, _, x, y = self:GetPoint()
        config.position.x = x
        config.position.y = y
        if testMode then
            print("|cff00ff00Simple Cast Bar:|r Position updated (" .. math.floor(x) .. ", " .. math.floor(y) .. ")")
        end
    end)
    
    -- Resizing functionality
    local isResizing = false
    local resizeCorner = nil
    
    for _, handle in ipairs(frame.resizeHandles) do
        handle:RegisterForDrag("LeftButton")
        handle:SetScript("OnDragStart", function(self)
            if not config.locked then
                isResizing = true
                resizeCorner = self.corner
                frame:StartSizing(resizeCorner)
            end
        end)
        
        handle:SetScript("OnDragStop", function(self)
            if isResizing then
                frame:StopMovingOrSizing()
                local width, height = frame:GetSize()
                config.barWidth = math.max(100, math.min(500, width)) -- Clamp between 100-500
                config.barHeight = math.max(15, math.min(50, height)) -- Clamp between 15-50
                frame:SetSize(config.barWidth, config.barHeight)
                if testMode then
                    print("|cff00ff00Simple Cast Bar:|r Size updated (" .. config.barWidth .. "x" .. config.barHeight .. ")")
                end
                isResizing = false
                resizeCorner = nil
            end
        end)
    end
    
    -- Show/hide resize handles based on lock status
    local function UpdateHandleVisibility()
        for _, handle in ipairs(frame.resizeHandles) do
            if config.locked then
                handle:Hide()
            else
                handle:Show()
            end
        end
    end
    
    frame.UpdateHandleVisibility = UpdateHandleVisibility
    UpdateHandleVisibility()
end

-- Apply interaction setup to cast bar
SetupFrameInteraction(castBar)

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

-- Enhanced test cast bar function
local function ShowTestCastBar(duration)
    if not config.enabled then 
        print("|cffFF0000Simple Cast Bar:|r Addon is disabled. Use /scb toggle to enable.")
        return 
    end
    
    -- Enter test mode
    testMode = true
    duration = duration or 15 -- Default 15 seconds for positioning
    
    currentCast = {
        spell = "Test Positioning",
        duration = duration,
        caster = "Drag to Move",
        startTime = GetTime()
    }
    
    castEndTime = currentCast.startTime + currentCast.duration
    
    -- Set test colors (bright yellow for visibility)
    castBar.bar:SetStatusBarColor(1, 1, 0, 0.8)
    
    -- Set instructional text
    castBar.text:SetText("DRAG TO MOVE - RESIZE WITH CORNERS")
    
    -- Unlock for positioning during test
    local wasLocked = config.locked
    config.locked = false
    castBar.UpdateHandleVisibility()
    
    -- Show the cast bar
    castBar:Show()
    
    -- Set up test timer (3.3.5a compatible)
    if testTimer then
        testTimer = nil
    end
    
    -- Create a frame-based timer for 3.3.5a compatibility
    local timerFrame = CreateFrame("Frame")
    local endTime = GetTime() + duration
    timerFrame:SetScript("OnUpdate", function(self)
        if GetTime() >= endTime then
            self:SetScript("OnUpdate", nil)
            HideTestCastBar()
            if wasLocked then
                config.locked = true
                castBar.UpdateHandleVisibility()
            end
        end
    end)
    testTimer = timerFrame
    
    print("|cff00ff00Simple Cast Bar:|r Test mode active for " .. duration .. " seconds")
    print("|cffFFFF00Instructions:|r")
    print("• Left-click and drag to move the cast bar")
    print("• Drag corner handles to resize")
    print("• Use /scb lock when you're satisfied with position")
    print("• Use /scb test stop to end test early")
end

-- Hide test cast bar
local function HideTestCastBar()
    if testMode then
        testMode = false
        if testTimer then
            testTimer:SetScript("OnUpdate", nil)
            testTimer = nil
        end
        HideCastBar()
        print("|cff00ff00Simple Cast Bar:|r Test mode ended. Position saved!")
    end
end

-- Hide cast bar
local function HideCastBar()
    castBar:Hide()
    currentCast = nil
end

-- Enhanced update function for test mode
local function UpdateTestCastBar()
    if not currentCast or not testMode then return end
    
    local currentTime = GetTime()
    local elapsed = currentTime - currentCast.startTime
    local remaining = castEndTime - currentTime
    
    if remaining <= 0 then
        HideTestCastBar()
        return
    end
    
    -- Update progress (slow animation for positioning)
    local progress = elapsed / currentCast.duration
    castBar.bar:SetValue(progress)
    
    -- Update timer with positioning info
    local x, y = config.position.x, config.position.y
    castBar.timer:SetText(string.format("%.0fs (%.0f,%.0f)", remaining, x, y))
end

-- Enhanced update cast bar function
local function UpdateCastBar()
    if testMode then
        UpdateTestCastBar()
        return
    end
    
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
eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
eventFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
eventFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
eventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_INTERRUPTED")

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
        local unit, spell = ...
        if unit and (string.find(unit, "target") or string.find(unit, "focus") or spell == GetSpellInfo(6358)) then
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
        if currentCast and not testMode then
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

-- Enhanced slash commands
SLASH_SIMPLECASTBAR1 = "/scb"
SLASH_SIMPLECASTBAR2 = "/simplecastbar"
SlashCmdList["SIMPLECASTBAR"] = function(msg)
    local cmd, arg = string.match(msg, "^(%S*)%s*(.-)$")
    cmd = string.lower(cmd or "")
    
    if cmd == "toggle" then
        config.enabled = not config.enabled
        print("|cff00ff00Simple Cast Bar:|r " .. (config.enabled and "Enabled" or "Disabled"))
        
    elseif cmd == "test" then
        if arg == "stop" then
            HideTestCastBar()
        else
            local duration = tonumber(arg) or 15
            if duration < 5 then duration = 5 end
            if duration > 60 then duration = 60 end
            ShowTestCastBar(duration)
        end
        
    elseif cmd == "position" then
        -- Quick positioning mode
        ShowTestCastBar(30)
        print("|cffFFFF00Quick Position Mode:|r 30 seconds to adjust position")
        
    elseif cmd == "hide" then
        if testMode then
            HideTestCastBar()
        else
            HideCastBar()
            print("|cff00ff00Simple Cast Bar:|r Cast bar hidden")
        end
        
    elseif cmd == "lock" then
        config.locked = not config.locked
        castBar.UpdateHandleVisibility()
        print("|cff00ff00Simple Cast Bar:|r " .. (config.locked and "Locked" or "Unlocked"))
        if config.locked then
            print("|cffFFFF00Tip:|r Use /scb test to temporarily unlock for positioning")
        end
        
    elseif cmd == "reset" then
        config.position.x = 0
        config.position.y = -100
        config.barWidth = 200
        config.barHeight = 20
        config.scale = 1.0
        castBar:ClearAllPoints()
        castBar:SetPoint("CENTER", UIParent, "CENTER", config.position.x, config.position.y)
        castBar:SetSize(config.barWidth, config.barHeight)
        castBar:SetScale(config.scale)
        print("|cff00ff00Simple Cast Bar:|r Position and size reset")
        
    elseif cmd == "scale" and arg ~= "" then
        local scale = tonumber(arg)
        if scale and scale >= 0.5 and scale <= 2.0 then
            config.scale = scale
            castBar:SetScale(config.scale)
            print("|cff00ff00Simple Cast Bar:|r Scale set to " .. scale)
        else
            print("|cff00ff00Simple Cast Bar:|r Invalid scale (0.5-2.0)")
        end
        
    elseif cmd == "width" and arg ~= "" then
        local width = tonumber(arg)
        if width and width >= 100 and width <= 500 then
            config.barWidth = width
            castBar:SetSize(config.barWidth, config.barHeight)
            print("|cff00ff00Simple Cast Bar:|r Width set to " .. width)
        else
            print("|cff00ff00Simple Cast Bar:|r Invalid width (100-500)")
        end
        
    elseif cmd == "height" and arg ~= "" then
        local height = tonumber(arg)
        if height and height >= 15 and height <= 50 then
            config.barHeight = height
            castBar:SetSize(config.barWidth, config.barHeight)
            print("|cff00ff00Simple Cast Bar:|r Height set to " .. height)
        else
            print("|cff00ff00Simple Cast Bar:|r Invalid height (15-50)")
        end
        
    else
        print("|cff00ff00Simple Cast Bar Commands:|r")
        print("/scb toggle - Enable/disable the addon")
        print("/scb test [seconds] - Interactive positioning mode (5-60s, default 15s)")
        print("/scb test stop - End test mode early")
        print("/scb position - Quick 30-second positioning mode")
        print("/scb hide - Hide current cast bar")
        print("/scb lock - Lock/unlock position and resizing")
        print("/scb reset - Reset position and size")
        print("/scb scale <0.5-2.0> - Set cast bar scale")
        print("/scb width <100-500> - Set cast bar width")
        print("/scb height <15-50> - Set cast bar height")
        print("")
        print("|cffFFFF00Interactive Positioning:|r")
        print("• Use /scb test to enter positioning mode")
        print("• Drag the cast bar to move it")
        print("• Drag corner handles to resize")
        print("• Position is automatically saved")
        print("• Use /scb lock when satisfied")
    end
end