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
    QuestReaderAddonDB.showMinimapButton = QuestReaderAddonDB.showMinimapButton ~= nil and QuestReaderAddonDB.showMinimapButton or true
    QuestReaderAddonDB.autoPlayEnabled = QuestReaderAddonDB.autoPlayEnabled
end

-- Create a frame to listen for the ADDON_LOADED event
local loadingFrame = CreateFrame("Frame")
loadingFrame:RegisterEvent("ADDON_LOADED")
loadingFrame:SetScript("OnEvent", function(self, event, loadedAddonName)
    if loadedAddonName == addonName then
        InitializeAddonDB()
        loadingFrame:UnregisterEvent("ADDON_LOADED")
    end
end)

-- Create the LDB launcher
local questReaderLauncher = LDB:NewDataObject("QuestReaderAddon", {
    type = "launcher",
    icon = "Interface\\Icons\\INV_Misc_Book_09",
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


function addon:OpenSettings()
    InterfaceOptionsFrame_OpenToCategory("Quest Reader")
    InterfaceOptionsFrame_OpenToCategory("Quest Reader") -- Call twice to ensure it opens
end

function LogQuestData()
    if GetTitleText() ~= "" then
        title = GetTitleText() or ""
        description = GetQuestText() or ""
        progress = GetProgressText() or ""
        completion = GetRewardText() or ""
        targetName = UnitName("npc") or ""
    end

    questData = {
        questTitle = title,
        questDescription = description,
        questProgress = progress,
        questComplete = completion,
        npcName = targetName
    }
    QuestReaderData = {}
    table.insert(QuestReaderData, questData)

--    print("Quest data logged successfully!")
end

function PlayQuestAudio()
    local questID = GetQuestID()
    local textType = ""

    if QuestFrameDetailPanel:IsVisible() then
        textType = "description"
    elseif QuestFrameProgressPanel:IsVisible() then
        textType = "progress"
    elseif QuestFrameRewardPanel:IsVisible() then
        textType = "completion"
    elseif GossipFrame:IsVisible() then
        textType = "gossip"
    else
--        print("No relevant quest frame is open")
        return
    end

    local soundFile = questID .. "_" .. textType .. ".wav"
    local soundPath = "Interface\\AddOns\\QuestReaderAddon\\Sounds\\" .. soundFile

    if PlaySoundFile(soundPath, "Dialog") then
--        print("Playing audio: " .. soundFile)
--        print("textType: " .. textType)
    else
        print("Audio file not found: " .. soundFile)
    end
end

-- Function to log gossip data - WIP will add back in later
-- function LogGossipData()
--     if C_GossipInfo.GetText() ~= "" then
--         targetName = UnitName("npc") or ""
--         gossipText = C_GossipInfo.GetText()
--         gossipData = {
--             npcName = targetName,
--             questDescription = gossipText
--         }
--     end
--     QuestReaderData = {}
--     table.insert(QuestReaderData, gossipData)
-- 
--     print("Gossip data logged successfully!")
-- end

-- Create the button for the QuestFrame
local questFrameButton = CreateFrame("Button", "QuestReaderButtonFrame", QuestFrame, "UIPanelButtonTemplate")
questFrameButton:SetSize(90, 21) -- Adjusted size to match the working file
questFrameButton:SetText("Read Quest") -- Set the text on the button
questFrameButton:SetPoint("BOTTOMRIGHT", QuestFrame, "BOTTOMRIGHT", -120, 4) -- Adjusted position to match the working file

questFrameButton:SetScript("OnClick", function()
    PlayQuestAudio()
end)

-- Create the button for the GossipFrame - WIP will add back in later
-- local gossipFrameButton = CreateFrame("Button", "GossipReaderButtonFrame", GossipFrame, "UIPanelButtonTemplate")
-- gossipFrameButton:SetSize(90, 21) -- Adjusted size to match the working file
-- gossipFrameButton:SetText("Read Gossip") -- Set the text on the button
-- gossipFrameButton:SetPoint("BOTTOMRIGHT", GossipFrame, "BOTTOMRIGHT", -120, 4) -- Adjusted position to match the working file

-- gossipFrameButton:SetScript("OnClick", function()
--     LogGossipData()
-- end)

local function UpdateMinimapButtonVisibility()
    if QuestReaderAddonDB.showMinimapButton then
        icon:Show("QuestReaderAddon")
    else
        icon:Hide("QuestReaderAddon")
    end
end

addon.UpdateMinimapButtonVisibility = UpdateMinimapButtonVisibility

-- Register the icon with LibDBIcon
icon:Register("QuestReaderAddon", questReaderLauncher, QuestReaderAddonDB.minimapButton)

UpdateMinimapButtonVisibility()

-- Function to automatically play quest audio
local function AutoPlayQuestAudio()
    if QuestReaderAddonDB.autoPlayEnabled then
        PlayQuestAudio()
    end
end

-- Hook the QuestFrame's OnShow event
QuestFrame:HookScript("OnShow", AutoPlayQuestAudio)

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

-- Slash command to manually print the saved data for debugging
SLASH_QUESTREADER1 = '/questreaddata'
SlashCmdList["QUESTREADER"] = function()
    print("Quest Reader Data:")
    print("Auto-Play: " .. (QuestReaderAddonDB.autoPlayEnabled and "Enabled" or "Disabled"))
    if #QuestReaderData == 0 then
        print("No data has been logged yet.")
    else
        for i, data in ipairs(QuestReaderData) do
            print(i, "Title:", data.questTitle or "N/A", "Target:", data.targetName, "Gossip:", data.gossipText or "N/A")
        end
    end
end

SLASH_QUESTREADER2 = '/qrsettings'
SlashCmdList["QUESTREADER"] = function(msg)
    if msg == "settings" then
        addon:OpenSettings()
    else
        -- Your existing slash command functionality
    end
end

SLASH_QRTOGGLE1 = '/qrtoggle'
SlashCmdList["QRTOGGLE"] = function()
    QuestReaderAddonDB.showMinimapButton = not QuestReaderAddonDB.showMinimapButton
    QuestReaderAddonDB.minimapButton.hide = not QuestReaderAddonDB.showMinimapButton
    UpdateMinimapButtonVisibility()
    print("Minimap button visibility: " .. tostring(QuestReaderAddonDB.showMinimapButton))
end