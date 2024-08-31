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

    -- Collect all unique quest IDs
    for soundFile, _ in pairs(QuestReaderSoundLengths) do
        local questID = soundFile:match("(%d+)_")
        if questID and not questIDs[questID] then
            questIDs[questID] = true
        end
    end

    -- Sort quest IDs numerically
    local sortedQuestIDs = {}
    for questID in pairs(questIDs) do
        table.insert(sortedQuestIDs, tonumber(questID))
    end
    table.sort(sortedQuestIDs)

    -- Create a frame for each quest ID
    for _, questID in ipairs(sortedQuestIDs) do
        local questFrame = CreateFrame("Frame", nil, self.content)
        questFrame:SetSize(260, 30)
        questFrame:SetPoint("TOPLEFT", 0, -yOffset)

        local text = questFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", 5, 0)
        text:SetText("Quest ID: " .. questID)

        local playButton = CreateFrame("Button", nil, questFrame, "UIPanelButtonTemplate")
        playButton:SetSize(60, 20)
        playButton:SetPoint("RIGHT", -5, 0)
        playButton:SetText("Play")
        playButton:SetScript("OnClick", function()
            self:PlayQuestAudio(questID)
        end)

        yOffset = yOffset + 30
    end

    self.content:SetHeight(math.max(330, yOffset))
end

-- Function to play all audio files for a quest ID
function QuestAudioLibraryUI:PlayQuestAudio(questID)
    local audioTypes = {"description", "progress", "completion"}
    for _, audioType in ipairs(audioTypes) do
        local soundFile = questID .. "_" .. audioType .. ".wav"
        if QuestReaderSoundLengths[soundFile] then
            addon.SoundQueue:AddSoundToQueue(questID, audioType)
        end
    end
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

-- Create a button to open the Quest Audio Library from the main addon UI
local libraryButton = CreateFrame("Button", nil, QuestReaderSoundQueueUI, "UIPanelButtonTemplate")
libraryButton:SetSize(100, 25)
libraryButton:SetPoint("BOTTOM", 0, 40)
libraryButton:SetText("Audio Library")
libraryButton:SetScript("OnClick", function()
    QuestAudioLibraryUI:ToggleVisibility()
end)