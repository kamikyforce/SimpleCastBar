-- Simple Cast Bar Addon - Optimized Version
local addonName = "SimpleCastBar"
local addon = {}
_G[addonName] = addon

-- Performance: Cache player name to avoid repeated UnitName() calls - O(1) vs O(n)
local playerName = nil

-- Enhanced Configuration
local config = {
    enabled = true,
    showSeduction = true,
    barWidth = 200,
    barHeight = 20,
    position = { x = 0, y = -100 },
    backgroundColor = { r = 0, g = 0, b = 0, a = 0.8 },
    borderColor = { r = 1, g = 1, b = 1, a = 1 },
    textColor = { r = 1, g = 1, b = 1, a = 1 },
    scale = 1.0,
    locked = false,
    showBorder = true,
    borderSize = 2,
    font = "Fonts\\FRIZQT__.TTF",
    fontSize = 12
}

-- Optimized spell database with hash table lookup - O(1) performance
local importantSpells = {
    ["Seduction"] = { duration = 1.5, color = { 1, 0, 1 } },
    ["Polymorph"] = { duration = 1.5, color = { 0, 0.5, 1 } },
    ["Fear"] = { duration = 1.5, color = { 0.5, 0, 0.5 } },
    ["Mind Control"] = { duration = 8, color = { 0.5, 0, 1 } },
    ["Drain Soul"] = { duration = 5, color = { 0.3, 0, 0.3 } },
    ["Banish"] = { duration = 1.5, color = { 1, 0.5, 0 } },
    ["Enslave Demon"] = { duration = 3, color = { 1, 0, 0 } },
    ["Hex"] = { duration = 1.7, color = { 0.8, 0.4, 0 } }
}

-- Optimized spell ID lookup table - O(1) hash table instead of multiple if statements
local spellIdToName = {
    [6358] = "Seduction",
    [118] = "Polymorph", [12824] = "Polymorph", [12825] = "Polymorph", [28272] = "Polymorph", [28271] = "Polymorph",
    [5782] = "Fear", [6213] = "Fear", [6215] = "Fear",
    [51514] = "Hex",
    [605] = "Mind Control", [10911] = "Mind Control", [10912] = "Mind Control",
    [710] = "Banish", [18647] = "Banish",
    [1098] = "Enslave Demon", [11725] = "Enslave Demon", [11726] = "Enslave Demon"
}

-- Combat log handled spells set for O(1) lookup
local combatLogSpells = {
    ["Seduction"] = true,
    ["Polymorph"] = true,
    ["Fear"] = true,
    ["Hex"] = true,
    ["Mind Control"] = true,
    ["Banish"] = true,
    ["Enslave Demon"] = true
}

-- Frame creation with optimized structure
local function CreateCastBar()
    local frame = CreateFrame("Frame", "SimpleCastBarFrame", UIParent)
    frame:SetSize(config.barWidth, config.barHeight)
    frame:SetPoint("CENTER", UIParent, "CENTER", config.position.x, config.position.y)
    frame:SetScale(config.scale)
    frame:SetFrameStrata("MEDIUM")
    frame:SetFrameLevel(10)

    -- Background
    frame.bg = frame:CreateTexture(nil, "BACKGROUND")
    frame.bg:SetAllPoints()
    frame.bg:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
    frame.bg:SetVertexColor(
        config.backgroundColor.r,
        config.backgroundColor.g,
        config.backgroundColor.b,
        config.backgroundColor.a
    )

    -- Status bar
    frame.bar = CreateFrame("StatusBar", nil, frame)
    frame.bar:SetPoint("TOPLEFT", frame, "TOPLEFT", config.borderSize, -config.borderSize)
    frame.bar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -config.borderSize, config.borderSize)
    frame.bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    frame.bar:SetMinMaxValues(0, 1)
    frame.bar:SetValue(0)

    -- Text elements
    frame.text = frame:CreateFontString(nil, "OVERLAY")
    frame.text:SetFont(config.font, config.fontSize, "OUTLINE")
    frame.text:SetPoint("LEFT", frame, "LEFT", 8, 0)
    frame.text:SetTextColor(
        config.textColor.r,
        config.textColor.g,
        config.textColor.b,
        config.textColor.a
    )
    frame.text:SetJustifyH("LEFT")

    frame.timer = frame:CreateFontString(nil, "OVERLAY")
    frame.timer:SetFont(config.font, config.fontSize, "OUTLINE")
    frame.timer:SetPoint("RIGHT", frame, "RIGHT", -8, 0)
    frame.timer:SetTextColor(
        config.textColor.r,
        config.textColor.g,
        config.textColor.b,
        config.textColor.a
    )
    frame.timer:SetJustifyH("RIGHT")

    -- Border
    if config.showBorder then
        frame.border = CreateFrame("Frame", nil, frame)
        frame.border:SetAllPoints()
        frame.border:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = config.borderSize * 8,
            insets = {
                left = config.borderSize,
                right = config.borderSize,
                top = config.borderSize,
                bottom = config.borderSize
            }
        })
        frame.border:SetBackdropBorderColor(
            config.borderColor.r,
            config.borderColor.g,
            config.borderColor.b,
            config.borderColor.a
        )
    end

    -- Resize handles
    frame.resizeHandles = {}
    local handleSize = 8
    local corners = {
        { "BOTTOMRIGHT", "BOTTOMRIGHT", 0, 0, "BOTTOMRIGHT" },
        { "BOTTOMLEFT", "BOTTOMLEFT", 0, 0, "BOTTOMLEFT" },
        { "TOPRIGHT", "TOPRIGHT", 0, 0, "TOPRIGHT" },
        { "TOPLEFT", "TOPLEFT", 0, 0, "TOPLEFT" }
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

-- Global variables
local castBar = CreateCastBar()
local currentCast = nil
local castEndTime = 0
local testMode = false
local testTimer = nil

-- Optimized frame interaction setup
local function SetupFrameInteraction(frame)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")

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
                config.barWidth = math.max(100, math.min(500, width))
                config.barHeight = math.max(15, math.min(50, height))
                frame:SetSize(config.barWidth, config.barHeight)
                if testMode then
                    print("|cff00ff00Simple Cast Bar:|r Size updated (" .. config.barWidth .. "x" .. config.barHeight .. ")")
                end
                isResizing = false
                resizeCorner = nil
            end
        end)
    end

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

SetupFrameInteraction(castBar)

-- Optimized cast bar functions
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

    local color = spellData.color
    castBar.bar:SetStatusBarColor(color[1], color[2], color[3], 0.8)
    castBar.text:SetText(spellName .. (caster and (" (" .. caster .. ")") or ""))
    castBar:Show()
end

local function HideCastBar()
    castBar:Hide()
    currentCast = nil
end

local function ShowTestCastBar(duration)
    if not config.enabled then
        print("|cffFF0000Simple Cast Bar:|r Addon is disabled. Use /scb toggle to enable.")
        return
    end

    testMode = true
    duration = duration or 15

    currentCast = {
        spell = "Test Positioning",
        duration = duration,
        caster = "Drag to Move",
        startTime = GetTime()
    }

    castEndTime = currentCast.startTime + currentCast.duration
    castBar.bar:SetStatusBarColor(1, 1, 0, 0.8)
    castBar.text:SetText("DRAG TO MOVE - RESIZE WITH CORNERS")

    local wasLocked = config.locked
    config.locked = false
    castBar.UpdateHandleVisibility()
    castBar:Show()

    if testTimer then
        testTimer = nil
    end

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

-- Optimized update functions
local function UpdateTestCastBar()
    if not currentCast or not testMode then return end

    local currentTime = GetTime()
    local elapsed = currentTime - currentCast.startTime
    local remaining = castEndTime - currentTime

    if remaining <= 0 then
        HideTestCastBar()
        return
    end

    local progress = elapsed / currentCast.duration
    castBar.bar:SetValue(progress)

    local x, y = config.position.x, config.position.y
    castBar.timer:SetText(string.format("%.0fs (%.0f,%.0f)", remaining, x, y))
end

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

    local progress = elapsed / currentCast.duration
    castBar.bar:SetValue(progress)
    castBar.timer:SetText(string.format("%.1f", remaining))
end

-- Optimized spell detection function - O(1) lookup
local function DetectSpellFromCombatLog(spellId, spellName, sourceName)
    -- Primary detection by spell ID (most reliable)
    local detectedSpell = spellIdToName[spellId]
    if detectedSpell then
        local spellData = importantSpells[detectedSpell]
        if spellData then
            ShowCastBar(detectedSpell, spellData.duration, sourceName or "Unknown")
            return true
        end
    end

    -- Fallback to spell name detection
    if spellName and importantSpells[spellName] then
        local spellData = importantSpells[spellName]
        ShowCastBar(spellName, spellData.duration, sourceName or "Unknown")
        return true
    end

    return false
end

-- Event frame setup
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

-- Optimized event handler with early returns and O(1) lookups
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonLoaded = ...
        if addonLoaded == addonName then
            playerName = UnitName("player") -- Cache player name
            print("|cff00ff00Simple Cast Bar|r loaded! Type /scb for options.")
        end
        return
    end

    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local timestamp, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellId, spellName, spellSchool = ...

        if eventType == "SPELL_CAST_START" then
            -- Early return if spell detected and handled
            if DetectSpellFromCombatLog(spellId, spellName, sourceName) then
                return
            end

            -- Handle other spells targeting the player
            if destName == playerName then
                local spellInfo = importantSpells[spellName]
                if spellInfo then
                    ShowCastBar(spellName, spellInfo.duration, sourceName)
                end
            end
        end
        return
    end

    if event == "UNIT_SPELLCAST_START" then
        local unit = ...
        if unit == "target" or unit == "focus" then
            local spellName = UnitCastingInfo(unit)
            -- O(1) lookup to skip combat log handled spells
            if combatLogSpells[spellName] then
                return
            end

            local spellInfo = importantSpells[spellName]
            if spellInfo then
                local unitName = UnitName(unit)
                ShowCastBar(spellName, spellInfo.duration, unitName)
            end
        end
        return
    end

    if event == "UNIT_SPELLCAST_CHANNEL_START" then
        local unit = ...
        if unit == "target" or unit == "focus" then
            local spellName = UnitChannelInfo(unit)
            local spellInfo = importantSpells[spellName]
            if spellInfo then
                local unitName = UnitName(unit)
                ShowCastBar(spellName, spellInfo.duration, unitName)
            end
        end
        return
    end

    if event == "UNIT_SPELLCAST_STOP" or 
       event == "UNIT_SPELLCAST_FAILED" or 
       event == "UNIT_SPELLCAST_INTERRUPTED" or 
       event == "UNIT_SPELLCAST_CHANNEL_STOP" or 
       event == "UNIT_SPELLCAST_CHANNEL_INTERRUPTED" then
        local unit = ...
        if unit == "target" or unit == "focus" then
            HideCastBar()
        end
    end
end)

-- Optimized update timer with reduced frequency
local updateFrame = CreateFrame("Frame")
local lastUpdate = 0
local UPDATE_FREQUENCY = 0.1 -- 10 FPS instead of every frame

updateFrame:SetScript("OnUpdate", function(self, elapsed)
    lastUpdate = lastUpdate + elapsed
    if lastUpdate >= UPDATE_FREQUENCY then
        UpdateCastBar()
        lastUpdate = 0
    end
end)

-- Slash commands
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
            duration = math.max(5, math.min(60, duration))
            ShowTestCastBar(duration)
        end
    elseif cmd == "position" then
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
