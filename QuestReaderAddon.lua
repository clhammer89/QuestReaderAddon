local addonName, addon = ...
local LDB = LibStub("LibDataBroker-1.1")
local icon = LibStub("LibDBIcon-1.0")

-- Initialize the saved variable if it doesn't exist
QuestReaderAddonDB = QuestReaderAddonDB or {}
QuestReaderAddonDB.minimapButton = QuestReaderAddonDB.minimapButton or { hide = false }
QuestReaderAddonDB.showMinimapButton = QuestReaderAddonDB.showMinimapButton ~= nil and QuestReaderAddonDB.showMinimapButton or true
QuestReaderAddonDB.autoPlayEnabled = QuestReaderAddonDB.autoPlayEnabled

local function InitializeAddonDB()
    QuestReaderAddonDB = QuestReaderAddonDB or {}
    QuestReaderAddonDB.minimapButton = QuestReaderAddonDB.minimapButton or { hide = false }
    if QuestReaderAddonDB.showMinimapButton == nil then
        QuestReaderAddonDB.showMinimapButton = true
    end
    if QuestReaderAddonDB.minimapIconPosition == nil then
        QuestReaderAddonDB.minimapIconPosition = {}
    end
    QuestReaderAddonDB.autoPlayEnabled = QuestReaderAddonDB.autoPlayEnabled
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
loadingFrame:SetScript("OnEvent", function(self, event, loadedAddonName)
    if loadedAddonName == addonName then
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
    end
end)
-- Create the button for the QuestFrame
local questFrameButton = CreateFrame("Button", "QuestReaderButtonFrame", QuestFrame, "UIPanelButtonTemplate")
questFrameButton:SetSize(90, 21) -- Adjusted size to match the working file
questFrameButton:SetText("Read Quest") -- Set the text on the button
questFrameButton:SetPoint("BOTTOMRIGHT", QuestFrame, "BOTTOMRIGHT", -120, 4)

questFrameButton:SetScript("OnClick", function()
    PlayQuestAudio()
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
        PlayQuestAudio()
    end)

    -- Create the Play/Stop button for the QuestFrame
    --local questFramePlayStopButton = CreateFrame("Button", "QuestReaderPlayStopButtonFrame", QuestFrame)
    --questFramePlayStopButton:SetSize(21, 21)
    --questFramePlayStopButton:SetPoint("LEFT", questFrameButton, "RIGHT", 5, 0)

    -- Create textures for play and stop icons
    --local playTexture = questFramePlayStopButton:CreateTexture(nil, "ARTWORK")
    --playTexture:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
    --playTexture:SetAllPoints(questFramePlayStopButton)

    --local stopTexture = questFramePlayStopButton:CreateTexture(nil, "ARTWORK")
    --stopTexture:SetTexture("Interface\\Buttons\\UI-StopButton")
    --stopTexture:SetAllPoints(questFramePlayStopButton)

    --local function UpdatePlayStopButton()
    --    if addon.SoundQueue and addon.SoundQueue:IsPlaying() then
    --        playTexture:Hide()
    --        stopTexture:Show()
    --    else
    --        playTexture:Show()
    --        stopTexture:Hide()
    --    end
    --end

    --questFramePlayStopButton:SetScript("OnClick", function()
    --    if addon.SoundQueue then
    --        if addon.SoundQueue:IsPlaying() then
     --           addon.SoundQueue:StopCurrentSound()
   --         else
    --            PlayQuestAudio()
    --        end
     --       UpdatePlayStopButton()
    --        if QuestReaderSoundQueueUI and QuestReaderSoundQueueUI.UpdateDisplay then
    --            QuestReaderSoundQueueUI:UpdateDisplay()
    --        end
    --    end
    --end)

    -- Initial setup
    --UpdatePlayStopButton()

    -- Make UpdatePlayStopButton accessible to the addon
    --addon.UpdatePlayStopButton = UpdatePlayStopButton

    -- Hook the SoundQueue methods to update the button state
    --local function HookSoundQueueMethod(methodName)
    --    if addon.SoundQueue and addon.SoundQueue[methodName] then
    --        local originalMethod = addon.SoundQueue[methodName]
     --       addon.SoundQueue[methodName] = function(self, ...)
     --           originalMethod(self, ...)
     --           UpdatePlayStopButton()
     --       end
    --    end
    --end

    --HookSoundQueueMethod("PlaySound")
    --HookSoundQueueMethod("StopCurrentSound")
end

--local function UpdatePlayStopButton()
--    if addon.SoundQueue and addon.SoundQueue:IsPlaying() then
--        playTexture:Hide()
 --       stopTexture:Show()
 --   else
--        playTexture:Show()
--        stopTexture:Hide()
--    end
--end

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
QuestFrame:HookScript("OnShow", AutoPlayQuestAudio)

addon.SoundQueue = {
    soundIdCounter = 0,
    sounds = {},
}

function addon.SoundQueue:GetQueueSize()
    return #self.sounds
end

function addon.SoundQueue:IsEmpty()
    return self:GetQueueSize() == 0
end

function addon.SoundQueue:GetCurrentSound()
    return self.sounds[1]
end

function addon.SoundQueue:GetNextSound()
    return self.sounds[2]
end

function addon.SoundQueue:Contains(soundData)
    for _, queuedSound in ipairs(self.sounds) do
        if queuedSound == soundData then
            return true
        end
    end
    return false
end

function addon.SoundQueue:AddSoundToQueue(questID, textType)
    local soundFile = questID .. "_" .. textType .. ".wav"
    local soundPath = "Interface\\AddOns\\QuestReaderAddon\\Sounds\\" .. soundFile

    local soundLength = QuestReaderSoundLengths[soundFile]
    if not soundLength then
        print("Sound file length not found: " .. soundFile)
        return
    end

    local soundData = {
        questID = questID,
        textType = textType,
        soundFile = soundFile,
        soundPath = soundPath,
        length = soundLength,
    }

    -- Check if the sound is already in the queue
    for _, queuedSound in ipairs(self.sounds) do
        if queuedSound.soundFile == soundData.soundFile then
            return
        end
    end

    self.soundIdCounter = self.soundIdCounter + 1
    soundData.id = self.soundIdCounter

    table.insert(self.sounds, soundData)

    -- If the sound queue only contains one sound, play it immediately
    if self:GetQueueSize() == 1 and not QuestReaderAddonDB.IsPaused and not self:IsPlaying() and not QuestReaderAddonDB.IsSoundPaused then
        -- Delay shortly to account for greeting audio
        C_Timer.After(2, function()
            self:PlaySound(soundData)
        end)
    end

    -- You might want to update UI here
    -- SoundQueueUI:UpdateSoundQueueDisplay()
end

function addon.SoundQueue:PlaySound(soundData)
    soundData.isPlaying = true
    soundData.isPlaying, soundData.soundHandle = PlaySoundFile(soundData.soundPath, "Dialog")

    if soundData.soundHandle then
        print("Playing audio: " .. soundData.soundFile)
        
        soundData.nextSoundTimer = C_Timer.NewTimer(soundData.length, function()
            self:RemoveSoundFromQueue(soundData, true)
            self:PlayNextSound()  -- Add this line to play the next sound
            --addon.UpdatePlayStopButton()
        end)
    else
        print("Failed to play audio: " .. soundData.soundFile)
        soundData.isPlaying = false
        self:RemoveSoundFromQueue(soundData, true)
        self:PlayNextSound()
    end
end

function addon.SoundQueue:PlayNextSound()
    local nextSound = self:GetCurrentSound()
    if nextSound and not QuestReaderAddonDB.IsPaused and not QuestReaderAddonDB.IsSoundPaused and not self:IsPlaying() then
        self:PlaySound(nextSound)
    end
end

function addon.SoundQueue:IsPlaying()
    local currentSound = self:GetCurrentSound()
    return currentSound and currentSound.isPlaying
end

function addon.SoundQueue:CanBePaused()
    return self:IsPlaying()
end

function addon.SoundQueue:PauseQueue()
    if QuestReaderAddonDB.IsPaused then
        return
    end

    QuestReaderAddonDB.IsPaused = true

    local currentSound = self:GetCurrentSound()
    if currentSound and self:CanBePaused() then
        StopMusic()  -- This will stop all sounds playing in the "Dialog" channel
        if currentSound.nextSoundTimer then
            currentSound.nextSoundTimer:Cancel()
            currentSound.nextSoundTimer = nil
        end
        currentSound.isPlaying = false
    end

    -- You might want to update UI here
    -- SoundQueueUI:UpdatePauseDisplay()
end

function addon.SoundQueue:ResumeQueue()
    if not QuestReaderAddonDB.IsPaused and not QuestReaderAddonDB.IsSoundPaused then
        return
    end

    QuestReaderAddonDB.IsPaused = false
    QuestReaderAddonDB.IsSoundPaused = false

    local currentSound = self:GetCurrentSound()
    if currentSound then
        self:PlaySound(currentSound)
    end

    -- You might want to update UI here
    -- SoundQueueUI:UpdateSoundQueueDisplay()
end

function addon.SoundQueue:StopCurrentSound()
    local currentSound = self:GetCurrentSound()
    if currentSound and currentSound.isPlaying then        
        -- Mute the dialog channel
        StopSound(currentSound.soundHandle)
        
        if currentSound.nextSoundTimer then
            currentSound.nextSoundTimer:Cancel()
        end
        
        currentSound.isPlaying = false
        table.remove(self.sounds, 1)
    else
        print("No sound currently playing")
    end
    if QuestReaderSoundQueueUI and QuestReaderSoundQueueUI.UpdateDisplay then
        QuestReaderSoundQueueUI:UpdateDisplay()
    end
    --addon.UpdatePlayStopButton()
end

function addon.SoundQueue:RemoveSoundFromQueue(soundData, finishedPlaying)
    local removedIndex = nil
    for index, queuedSound in ipairs(self.sounds) do
        if queuedSound.id == soundData.id then
            if index == 1 and not self:CanBePaused() and not finishedPlaying then
                return
            end

            removedIndex = index
            table.remove(self.sounds, index)
            break
        end
    end

    if not removedIndex then
        return
    end

    if soundData.isPlaying then
        StopMusic()  -- This will stop all sounds playing in the "Dialog" channel
        soundData.isPlaying = false
    end
    if soundData.nextSoundTimer then
        soundData.nextSoundTimer:Cancel()
    end

    if removedIndex == 1 and not QuestReaderAddonDB.IsPaused then
        local nextSoundData = self:GetCurrentSound()
        if nextSoundData then
            self:PlaySound(nextSoundData)
        end
    end

    -- You might want to update UI here
    -- SoundQueueUI:UpdateSoundQueueDisplay()
end

function addon.SoundQueue:RemoveAllSoundsFromQueue()
    for i = self:GetQueueSize(), 1, -1 do
        local queuedSound = self.sounds[i]
        if queuedSound then
            if i == 1 and not self:CanBePaused() then
                return
            end

            self:RemoveSoundFromQueue(queuedSound)
        end
    end
end

function PlayQuestAudio(textType)
    questID = GetQuestID()
    if not textType then
        print("No questID provided. Using default GetQuestID(). Quest ID: ", questID)

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

    -- Debug: Ensure questID and textType are valid before adding to the queue
    if questID and textType ~= "" then
        addon.SoundQueue:AddSoundToQueue(questID, textType)
    end
end

local function OnPlayerLogout()
    if addon.SoundQueue then
        local currentSound = addon.SoundQueue:GetCurrentSound()
        if currentSound and currentSound.nextSoundTimer then
            currentSound.nextSoundTimer:Cancel()
        end
    end
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

    if textType ~= "" then
        PlayQuestAudio(textType)  -- Call PlayQuestAudio with questID and textType from event
    elseif event == "QUEST_FINISHED" then
        addon.SoundQueue:StopCurrentSound() -- Stop sound when the quest dialog finishes
        addon.SoundQueue:RemoveAllSoundsFromQueue()
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

SLASH_QRPAUSE1 = '/qrpause'
SlashCmdList["QRPAUSE"] = function()
    addon.SoundQueue:PauseQueue()
end

SLASH_QRRESUME1 = '/qrresume'
SlashCmdList["QRRESUME"] = function()
    addon.SoundQueue:ResumeQueue()
end

SLASH_QRTOGGLEPAUSE1 = '/qrtogglepause'
SlashCmdList["QRTOGGLEPAUSE"] = function()
    addon.SoundQueue:TogglePauseQueue()
end

SLASH_QRCLEAR1 = '/qrclear'
SlashCmdList["QRCLEAR"] = function()
    addon.SoundQueue:RemoveAllSoundsFromQueue()
    print("Quest Reader sound queue cleared.")
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