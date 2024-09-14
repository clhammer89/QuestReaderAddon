local addonName, addon = ...

-- Create the main frame for the Quest Audio Library UI
local QuestAudioLibraryUI = CreateFrame("Frame", "QuestReaderAudioLibraryUI", UIParent, "BasicFrameTemplateWithInset")
QuestAudioLibraryUI:SetSize(300, 400)
QuestAudioLibraryUI:SetPoint("CENTER")
QuestAudioLibraryUI:SetMovable(true)
QuestAudioLibraryUI:EnableMouse(true)
QuestAudioLibraryUI:RegisterForDrag("LeftButton")
QuestAudioLibraryUI:SetScript("OnDragStart", QuestAudioLibraryUI.StartMoving)
QuestAudioLibraryUI:SetScript("OnDragStop", QuestAudioLibraryUI.StopMovingOrSizing)
QuestAudioLibraryUI:Hide()

QuestAudioLibraryUI.title = QuestAudioLibraryUI:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
QuestAudioLibraryUI.title:SetPoint("TOP", QuestAudioLibraryUI, "TOP", 0, -5)
QuestAudioLibraryUI.title:SetText("Quest Audio Library")

-- Create a scrollframe to contain the list of quest IDs
QuestAudioLibraryUI.scrollFrame = CreateFrame("ScrollFrame", nil, QuestAudioLibraryUI, "UIPanelScrollFrameTemplate")
QuestAudioLibraryUI.scrollFrame:SetPoint("TOPLEFT", 10, -30)
QuestAudioLibraryUI.scrollFrame:SetPoint("BOTTOMRIGHT", -30, 40)

QuestAudioLibraryUI.content = CreateFrame("Frame", nil, QuestAudioLibraryUI.scrollFrame)
QuestAudioLibraryUI.content:SetSize(260, 330)
QuestAudioLibraryUI.scrollFrame:SetScrollChild(QuestAudioLibraryUI.content)

-- Function to populate the list of quest IDs
function QuestAudioLibraryUI:PopulateList()
    -- Clear existing content
    for _, child in pairs({self.content:GetChildren()}) do
        child:Hide()
    end

    local yOffset = 0
    local questIDs = {}

    -- Collect all unique quest IDs from all sound sources
    for packName, soundLengths in pairs(addon.soundSources) do
        for soundFile, _ in pairs(soundLengths) do
            local questID = soundFile:match("(%d+)_")
            if questID then
                questIDs[questID] = questIDs[questID] or {}
                local audioType = soundFile:match("_([a-z]+)%.wav$")
                if audioType then
                    questIDs[questID][audioType] = true  -- Mark this audio type as available for the questID
                end
            end
        end
    end

    -- Sort quest IDs numerically
    local sortedQuestIDs = {}
    for questID in pairs(questIDs) do
        table.insert(sortedQuestIDs, tonumber(questID))
    end
    table.sort(sortedQuestIDs)

    -- Create a frame for each quest ID with buttons for available audio types
    for _, questID in ipairs(sortedQuestIDs) do
        local questFrame = CreateFrame("Frame", nil, self.content)
        questFrame:SetSize(260, 30)
        questFrame:SetPoint("TOPLEFT", 0, -yOffset)

        -- Quest ID text
        local text = questFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", 5, 0)
        text:SetText("Quest ID: " .. questID)

        local availableTypes = questIDs[tostring(questID)]  -- Get the available types for this questID
        local rightOffset = -5

        -- Add buttons only for the available audio types
        if availableTypes["completion"] then
            local completionButton = CreateFrame("Button", nil, questFrame, "UIPanelButtonTemplate")
            completionButton:SetSize(40, 20)
            completionButton:SetPoint("RIGHT", rightOffset, 0)
            completionButton:SetText("Comp")
            completionButton:SetScript("OnClick", function()
                self:PlaySpecificAudio(questID, "completion")
            end)
            rightOffset = rightOffset - 45
        end

        if availableTypes["progress"] then
            local progressButton = CreateFrame("Button", nil, questFrame, "UIPanelButtonTemplate")
            progressButton:SetSize(40, 20)
            progressButton:SetPoint("RIGHT", rightOffset, 0)
            progressButton:SetText("Prog")
            progressButton:SetScript("OnClick", function()
                self:PlaySpecificAudio(questID, "progress")
            end)
            rightOffset = rightOffset - 45
        end

        if availableTypes["description"] then
            local descriptionButton = CreateFrame("Button", nil, questFrame, "UIPanelButtonTemplate")
            descriptionButton:SetSize(40, 20)
            descriptionButton:SetPoint("RIGHT", rightOffset, 0)
            descriptionButton:SetText("Desc")
            descriptionButton:SetScript("OnClick", function()
                self:PlaySpecificAudio(questID, "description")
            end)
            rightOffset = rightOffset - 45
        end

        yOffset = yOffset + 30
    end

    self.content:SetHeight(math.max(330, yOffset))
end

-- Function to play a specific audio file for a quest ID
function QuestAudioLibraryUI:PlaySpecificAudio(questID, audioType)
    if activeDebugSound then
        StopSound(activeDebugSound)
        activeDebugSound = nil
    end

    local soundFile = questID .. "_" .. audioType .. ".wav"
    -- Search through each addon in addon.soundSources
    for packName, soundLengths in pairs(addon.soundSources) do
        -- Check if the sound file exists in the soundLengths table
        if soundLengths[soundFile] then
            -- Construct the path to the sound file
            local soundPath = "Interface\\AddOns\\" .. packName .. "\\Sounds\\" .. soundFile
            local isPlaying, activeDebugSound = PlaySoundFile(soundPath, "Dialog")
            return  -- Stop after playing the first valid sound file
        end
    end

    print("Audio not found for Quest ID: " .. questID .. " and type: " .. audioType)
end

-- Function to toggle the UI visibility
function QuestAudioLibraryUI:ToggleVisibility()
    if self:IsVisible() then
        self:Hide()
    else
        self:Show()
        self:PopulateList()
    end
end

-- Add a slash command to toggle the UI
SLASH_QRLIBRARY1 = '/qrlibrary'
SlashCmdList["QRLIBRARY"] = function()
    QuestAudioLibraryUI:ToggleVisibility()
end
