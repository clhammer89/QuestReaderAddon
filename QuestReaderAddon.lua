local addonName, addon = ...
local LDB = LibStub("LibDataBroker-1.1")
local icon = LibStub("LibDBIcon-1.0")

local optionalSoundPacks = {
    "QuestReaderPackWW"
}

-- Initialize the saved variable if it doesn't exist
QuestReaderAddonDB = QuestReaderAddonDB or {}
QuestReaderAddonDB.minimapButton = QuestReaderAddonDB.minimapButton or { hide = false }
QuestReaderAddonDB.showMinimapButton = QuestReaderAddonDB.showMinimapButton ~= nil and QuestReaderAddonDB.showMinimapButton or true
if QuestReaderAddonDB.autoPlayEnabled == nil then
    QuestReaderAddonDB.autoPlayEnabled = true
else
    QuestReaderAddonDB.autoPlayEnabled = QuestReaderAddonDB.autoPlayEnabled
end
 QuestReaderAddonDB.muteGossip = QuestReaderAddonDB.muteGossip

local function InitializeAddonDB()
    QuestReaderAddonDB = QuestReaderAddonDB or {}
    QuestReaderAddonDB.minimapButton = QuestReaderAddonDB.minimapButton or { hide = false }
    if QuestReaderAddonDB.showMinimapButton == nil then
        QuestReaderAddonDB.showMinimapButton = true
    end
    if QuestReaderAddonDB.minimapIconPosition == nil then
        QuestReaderAddonDB.minimapIconPosition = {}
    end
    if QuestReaderAddonDB.autoPlayEnabled == nil then
        QuestReaderAddonDB.autoPlayEnabled = true
    else
        QuestReaderAddonDB.autoPlayEnabled = QuestReaderAddonDB.autoPlayEnabled
    end
    QuestReaderAddonDB.muteGossip = QuestReaderAddonDB.muteGossip
    QuestReaderAddonDB.IsPaused = false
    QuestReaderAddonDB.IsSoundPaused = false
end

-- Create the LDB launcher
local questReaderLauncher = LDB:NewDataObject("QuestReaderAddon", {
    type = "launcher",
    icon = "Interface\\AddOns\\" .. addonName .. "\\cs_icon",  -- Adjusted icon path
    OnClick = function(_, button)
        if button == "LeftButton" then
            addon:OpenSettings()
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("Quest Reader")
        tooltip:AddLine("Click to open settings", 1, 1, 1)
    end,
})

local function UpdateMinimapButtonVisibility()
    if QuestReaderAddonDB.showMinimapButton then
        icon:Show("QuestReaderAddon")
        C_Timer.After(0.1, function()
            local minimapButton = icon:GetMinimapButton("QuestReaderAddon")
            if minimapButton and QuestReaderAddonDB.minimapIconPosition.point then
                minimapButton:ClearAllPoints()
                minimapButton:SetPoint(
                    QuestReaderAddonDB.minimapIconPosition.point,
                    Minimap,
                    QuestReaderAddonDB.minimapIconPosition.relPoint,
                    QuestReaderAddonDB.minimapIconPosition.x,
                    QuestReaderAddonDB.minimapIconPosition.y
                )
            end
        end)
    else
        icon:Hide("QuestReaderAddon")
    end
end
addon.UpdateMinimapButtonVisibility = UpdateMinimapButtonVisibility

-- Create a frame to listen for the ADDON_LOADED event
local loadingFrame = CreateFrame("Frame")
loadingFrame:RegisterEvent("ADDON_LOADED")
loadingFrame:RegisterEvent("PLAYER_LOGIN")
loadingFrame:SetScript("OnEvent", function(self, event, loadedAddonName)
    if event == "ADDON_LOADED" and loadedAddonName == addonName then
        InitializeAddonDB()
        if questReaderLauncher then
            icon:Register("QuestReaderAddon", questReaderLauncher, {
                hide = not QuestReaderAddonDB.showMinimapButton,
                position = QuestReaderAddonDB.minimapIconPosition
            })
            C_Timer.After(0.5, function()
                UpdateMinimapButtonVisibility()
                local minimapButton = icon:GetMinimapButton("QuestReaderAddon")
                if minimapButton then
                    minimapButton:HookScript("OnDragStop", function()
                        local point, _, relPoint, x, y = minimapButton:GetPoint()
                        QuestReaderAddonDB.minimapIconPosition = {
                            point = point,
                            relPoint = relPoint,
                            x = x,
                            y = y
                        }
                    end)
                end
            end)
        else
            print("Error: questReaderLauncher is nil")
        end
        loadingFrame:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_LOGIN" then
        -- All addons should now be loaded, call DetectSoundPacks safely here
        DetectSoundPacks()
    end
end)
-- Create the button for the QuestFrame
local questFrameButton = CreateFrame("Button", "QuestReaderButtonFrame", QuestFrame, "UIPanelButtonTemplate")
questFrameButton:SetSize(90, 21) -- Adjusted size to match the working file
questFrameButton:SetText("Read Quest") -- Set the text on the button
questFrameButton:SetPoint("BOTTOMRIGHT", QuestFrame, "BOTTOMRIGHT", -120, 4)

questFrameButton:SetScript("OnClick", function()
    PlayQuestAudio(nil, true)
end)

local loadingFrame = CreateFrame("Frame")
loadingFrame:RegisterEvent("ADDON_LOADED")

local function InitializeQuestFrameButtons()
    -- Create the button for the QuestFrame (existing code)
    local questFrameButton = CreateFrame("Button", "QuestReaderButtonFrame", QuestFrame, "UIPanelButtonTemplate")
    questFrameButton:SetSize(90, 21)
    questFrameButton:SetText("Read Quest")
    questFrameButton:SetPoint("BOTTOMRIGHT", QuestFrame, "BOTTOMRIGHT", -120, 4)

    questFrameButton:SetScript("OnClick", function()
        PlayQuestAudio(nil, true)
    end)
end

loadingFrame:SetScript("OnEvent", function(self, event, loadedAddonName)
    if loadedAddonName == addonName then
        InitializeQuestFrameButtons()
        loadingFrame:UnregisterEvent("ADDON_LOADED")
    end
end)

-- Slash command to toggle minimap button
SLASH_QRTOGGLE1 = '/qrtoggle'
SlashCmdList["QRTOGGLE"] = function()
    QuestReaderAddonDB.showMinimapButton = not QuestReaderAddonDB.showMinimapButton
    UpdateMinimapButtonVisibility()
    print("Minimap button visibility: " .. tostring(QuestReaderAddonDB.showMinimapButton))
end

-- Function to automatically play quest audio
local function AutoPlayQuestAudio()
    if QuestReaderAddonDB.autoPlayEnabled then
        PlayQuestAudio()
    end
end

-- Hook the QuestFrame's OnShow event
-- QuestFrame:HookScript("OnShow", AutoPlayQuestAudio)

local function LoadSoundPackIfAvailable(addonName)
    local name, title, _, loadable = C_AddOns.GetAddOnInfo(addonName)
    if name and loadable then
        if not C_AddOns.IsAddOnLoaded(addonName) then
            local loaded, reason = C_AddOns.LoadAddOn(addonName)
            if not loaded then
                return nil
            end
        end

        return _G[addonName]  -- Return the global table for the addon
    end
    return nil
end

addon.soundSources = {}
addon.soundSources["QuestReaderAddon"] = QuestReaderSoundLengths
addon.activeSound = nil

-- Function to detect available sound packs
function DetectSoundPacks()
    local hasEntries = false
    
    for _, depName in ipairs(optionalSoundPacks) do
        if depName then
            local name, _, _, loadable = C_AddOns.GetAddOnInfo(depName)
            if loadable then
                local pack = LoadSoundPackIfAvailable(depName)
                if pack then
                    addon.soundSources[name] = pack
                end
            end
        end
    end

    -- Count the entries in this sound pack
    for key, sources in pairs(addon.soundSources) do
        if not (next(sources) == nil) then
            hasEntries = true
            break
        end
    end

    -- If no entries were found, create the popup dialog
    if not hasEntries then
        ShowNoSoundPacksDialog()
    end
end

function ShowNoSoundPacksDialog()
    -- Define the static popup dialog
    StaticPopupDialogs["NO_SOUND_PACKS"] = {
        text = "You're using Quest Reader Addon but you've not installed any Quest Reader sound packs.",
        button1 = "OK",
        timeout = 0,  -- No timeout
        whileDead = true,  -- Allow showing while dead
        hideOnEscape = true,  -- Allow closing by pressing the Escape key
        preferredIndex = 3,  -- Prevents interference with other dialogs
    }

    -- Show the popup dialog
    StaticPopup_Show("NO_SOUND_PACKS")
end

function GetCurrentSound()
    return addon.activeSound
end

function DoPlaySound()
    soundData = GetCurrentSound()
    if not soundData then
        -- This can fire when a sound was canceled while in timer
        return
    end

    local audioChannel = "Dialog"
    if QuestReaderAddonDB.muteGossip then
        MuteDialogChannel()
        audioChannel = "Master"
    end

    soundData.isPlaying = true
    soundData.isPlaying, soundData.soundHandle = PlaySoundFile(soundData.soundPath, audioChannel)

    if soundData.soundHandle then
        --print("Playing audio: " .. soundData.soundPath)
    else
        print("Failed to play audio: " .. soundData.soundFile)
        soundData.isPlaying = false
    end
    addon.currentSound = soundData
end

function IsPlaying()
    local currentSound = GetCurrentSound()
    return currentSound and currentSound.isPlaying
end

function StopCurrentSound()
    local currentSound = GetCurrentSound()

    if not currentSound then
        return
    end
    
    if currentSound.nextSoundTimer then
        currentSound.nextSoundTimer:Cancel()
    end

    if currentSound.soundHandle then
        StopSound(currentSound.soundHandle)
    else
        -- print("No sound currently playing")
    end

    if QuestReaderAddonDB.muteGossip then
        UnmuteDialogChannel()
    end

    addon.activeSound = nil
end

function PlayQuestAudio(textType, skipDelay)
    questID = GetQuestID()
    if not textType then
        -- Initialize textType based on visible panels
        if QuestFrameDetailPanel:IsVisible() then
            textType = "description"
        elseif QuestFrameProgressPanel:IsVisible() then
            textType = "progress"
        elseif QuestFrameRewardPanel:IsVisible() then
            textType = "completion"
        elseif GossipFrame:IsVisible() then
            textType = "gossip"
        else
            return
        end
    end

    -- Debug: Ensure questID and textType are valid
    if questID and textType ~= "" then
        -- Stop any sound that is currently playing
        if IsPlaying() then
            StopCurrentSound()
        end

        local soundFile = questID .. "_" .. textType .. ".wav"
        local soundPath = nil
        
        for packName, soundLengths in pairs(addon.soundSources) do
            -- Check if the sound file exists in the soundLengths table
            if soundLengths[soundFile] then
                soundPath = "Interface\\AddOns\\" .. packName .. "\\Sounds\\" .. soundFile
                break
            end
        end
        
        if not soundPath then
            addon.activeSound = nil
            return
        end
        
        addon.activeSound = {
            questID = questID,
            textType = textType,
            soundFile = soundFile,
            soundPath = soundPath,
        }
        
        -- Delay shortly to account for greeting audio when using autoplay
        if QuestReaderAddonDB.autoPlayEnabled and not skipDelay and not QuestReaderAddonDB.muteGossip then
            addon.activeSound.nextSoundTimer = C_Timer.After(2, function()
                DoPlaySound()
            end)
        else
            DoPlaySound()
        end
    end
end

local function OnPlayerLogout()
    local currentSound = GetCurrentSound()
    if currentSound and currentSound.nextSoundTimer then
        currentSound.nextSoundTimer:Cancel()
    end
    UnmuteDialogChannel()
end

-- Event Handling for Quest Dialog Events
local questEventFrame = CreateFrame("Frame")
questEventFrame:RegisterEvent("QUEST_DETAIL")
questEventFrame:RegisterEvent("QUEST_PROGRESS")
questEventFrame:RegisterEvent("QUEST_COMPLETE")
questEventFrame:RegisterEvent("QUEST_FINISHED")

questEventFrame:SetScript("OnEvent", function(self, event, ...)
    -- Map event to appropriate textType
    local textType = ""
    if event == "QUEST_DETAIL" then
        textType = "description"
    elseif event == "QUEST_PROGRESS" then
        textType = "progress"
    elseif event == "QUEST_COMPLETE" then
        textType = "completion"
    end

    if textType ~= "" and QuestReaderAddonDB.autoPlayEnabled then
        PlayQuestAudio(textType)  -- Call PlayQuestAudio with textType from event
    elseif event == "QUEST_FINISHED" then
        StopCurrentSound() -- Stop sound when the quest dialog finishes
    end
end)

local logoutFrame = CreateFrame("Frame")
logoutFrame:RegisterEvent("PLAYER_LOGOUT")
logoutFrame:SetScript("OnEvent", OnPlayerLogout)

-- Slash command to toggle auto-play
SLASH_QUESTREADERAUTO1 = '/qrauto'
SlashCmdList["QUESTREADERAUTO"] = function(msg)
    if msg == "on" then
        QuestReaderAddonDB.autoPlayEnabled = true
    elseif msg == "off" then
        QuestReaderAddonDB.autoPlayEnabled = false
    else
        QuestReaderAddonDB.autoPlayEnabled = not QuestReaderAddonDB.autoPlayEnabled
    end
    print("Quest Reader Auto-Play: " .. (QuestReaderAddonDB.autoPlayEnabled and "Enabled" or "Disabled"))
end

local function SaveMinimapIconPosition()
    local position = icon:GetMinimapButton("QuestReaderAddon"):GetPoint()
    QuestReaderAddonDB.minimapIconPosition.point, _, QuestReaderAddonDB.minimapIconPosition.relPoint, QuestReaderAddonDB.minimapIconPosition.x, QuestReaderAddonDB.minimapIconPosition.y = position
end

local minimapIcon = icon:GetMinimapButton("QuestReaderAddon")
if minimapIcon then
    minimapIcon:HookScript("OnDragStop", SaveMinimapIconPosition)
    minimapIcon:HookScript("OnMouseUp", SaveMinimapIconPosition)
end

-- Function to mute the dialog channel
function MuteDialogChannel()
    -- Check if the original volume has already been saved
    if not originalDialogVolume then
        -- Get the current dialog volume and store it
        originalDialogVolume = GetCVar("Sound_DialogVolume")
    end
    
    -- Set the dialog volume to 0 (mute)
    SetCVar("Sound_DialogVolume", 0)
end

-- Function to unmute the dialog channel
function UnmuteDialogChannel()
    if originalDialogVolume then
        -- Restore the original dialog volume
        SetCVar("Sound_DialogVolume", originalDialogVolume)
        
        -- Clear the original volume to avoid accidental overwriting in future
        originalDialogVolume = nil
    end
end
