local addonName, addon = ...
local QuestReader = {}

EventUtil.ContinueOnAddOnLoaded(addonName, function()
    QuestReaderAddonDB = QuestReaderAddonDB or {}
    QuestReader:CreateSettings()
end)

function QuestReader:CreateSettings()
    local optionsFrame
    optionsFrame = CreateFrame("Frame", nil, nil, "VerticalLayoutFrame")
    optionsFrame.spacing = 4
    local category, layout = Settings.RegisterCanvasLayoutCategory(optionsFrame, "Quest Reader |T" .. addonName .. "\\cs_icon:18:18:0:0|t")
    category.ID = "Quest Reader"
    Settings.RegisterAddOnCategory(category)

    local layoutIndex = 0
    local function GetLayoutIndex()
        layoutIndex = layoutIndex + 1
        return layoutIndex
    end

    -- Header
    local Header = CreateFrame("Frame", nil, optionsFrame)
    Header:SetSize(150, 50)
    local headerText = Header:CreateFontString(nil, "ARTWORK", "GameFontHighlightHuge")
    headerText:SetPoint("TOPLEFT", 7, -22)
    headerText:SetText("Quest Reader")
    local divider = Header:CreateTexture(nil, "ARTWORK")
    divider:SetAtlas("Options_HorizontalDivider", true)
    divider:SetPoint("BOTTOMLEFT", -50)
    Header.layoutIndex = GetLayoutIndex()
    Header.bottomPadding = 10

    local function makeCheckButton(text)
        local checkButton = CreateFrame("CheckButton", addonName.."CheckBox", optionsFrame, "SettingsCheckBoxTemplate")
        checkButton.text = checkButton:CreateFontString(addonName.."CheckBoxText", "ARTWORK", "GameFontNormal")
        checkButton.text:SetText(text)
        checkButton.text:SetPoint("LEFT", checkButton, "RIGHT", 4, 0)
        checkButton:SetSize(21,20)
        return checkButton
    end

    local settingsInfo = {
        { option = "autoPlayEnabled", detail = "Auto-play quest audio" },
        { option = "showMinimapButton", detail = "Show minimap button" },
    }

    for _, keyInfo in ipairs(settingsInfo) do
        local checkButton = makeCheckButton(keyInfo.detail)
        checkButton.layoutIndex = GetLayoutIndex()
        checkButton:SetHitRectInsets(0, -checkButton.text:GetWidth(), 0, 0)
        checkButton.HoverBackground = nil
        checkButton:SetChecked(QuestReaderAddonDB[keyInfo.option])
        checkButton:SetScript("OnClick", function()
            QuestReaderAddonDB[keyInfo.option] = checkButton:GetChecked()
            checkButton:SetChecked(QuestReaderAddonDB[keyInfo.option])
            
            -- Handle specific actions for certain options
            if keyInfo.option == "showMinimapButton" then
                QuestReaderAddonDB.showMinimapButton = not QuestReaderAddonDB.showMinimapButton
                QuestReaderAddonDB.minimapButton.hide = not QuestReaderAddonDB.showMinimapButton
                addon.UpdateMinimapButtonVisibility()
                
            end
        end)
    end

    optionsFrame:Layout()
end

-- Function to open settings
function addon:OpenSettings()
    Settings.OpenToCategory("Quest Reader")
end

SLASH_QUESTREADER1, SLASH_QUESTREADER2 = '/qr', '/questreader'
SlashCmdList.QUESTREADER = function(msg)
    Settings.OpenToCategory("Quest Reader")
end