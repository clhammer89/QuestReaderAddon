local addonName, addon = ...

-- Create the main frame for the sound queue UI
local SoundQueueUI = CreateFrame("Frame", "QuestReaderSoundQueueUI", UIParent, "BasicFrameTemplateWithInset")
SoundQueueUI:SetSize(300, 400)
SoundQueueUI:SetPoint("CENTER")
SoundQueueUI:SetMovable(true)
SoundQueueUI:EnableMouse(true)
SoundQueueUI:RegisterForDrag("LeftButton")
SoundQueueUI:SetScript("OnDragStart", SoundQueueUI.StartMoving)
SoundQueueUI:SetScript("OnDragStop", SoundQueueUI.StopMovingOrSizing)
SoundQueueUI:Hide()

SoundQueueUI.title = SoundQueueUI:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
SoundQueueUI.title:SetPoint("TOP", SoundQueueUI, "TOP", 0, -5)
SoundQueueUI.title:SetText("Quest Reader Sound Queue")

-- Create a scrollframe to contain the list of sounds
SoundQueueUI.scrollFrame = CreateFrame("ScrollFrame", nil, SoundQueueUI, "UIPanelScrollFrameTemplate")
SoundQueueUI.scrollFrame:SetPoint("TOPLEFT", 10, -30)
SoundQueueUI.scrollFrame:SetPoint("BOTTOMRIGHT", -30, 40)

SoundQueueUI.content = CreateFrame("Frame", nil, SoundQueueUI.scrollFrame)
SoundQueueUI.content:SetSize(260, 330)
SoundQueueUI.scrollFrame:SetScrollChild(SoundQueueUI.content)

-- Create buttons for controls
SoundQueueUI.pauseResumeButton = CreateFrame("Button", nil, SoundQueueUI, "UIPanelButtonTemplate")
SoundQueueUI.pauseResumeButton:SetSize(100, 25)
SoundQueueUI.pauseResumeButton:SetPoint("BOTTOMLEFT", 10, 10)
SoundQueueUI.pauseResumeButton:SetText("Pause")
SoundQueueUI.pauseResumeButton:SetScript("OnClick", function()
    if QuestReaderAddonDB.IsPaused then
        addon.SoundQueue:ResumeQueue()
    else
        addon.SoundQueue:PauseQueue()
    end
    SoundQueueUI:UpdateDisplay()
end)

SoundQueueUI.clearButton = CreateFrame("Button", nil, SoundQueueUI, "UIPanelButtonTemplate")
SoundQueueUI.clearButton:SetSize(100, 25)
SoundQueueUI.clearButton:SetPoint("BOTTOMRIGHT", -10, 10)
SoundQueueUI.clearButton:SetText("Clear Queue")
SoundQueueUI.clearButton:SetScript("OnClick", function()
    addon.SoundQueue:RemoveAllSoundsFromQueue()
    SoundQueueUI:UpdateDisplay()
end)

SoundQueueUI.stopButton = CreateFrame("Button", nil, SoundQueueUI, "UIPanelButtonTemplate")
SoundQueueUI.stopButton:SetSize(80, 25)
SoundQueueUI.stopButton:SetPoint("BOTTOM", 0, 10)
SoundQueueUI.stopButton:SetText("Stop")
SoundQueueUI.stopButton:SetScript("OnClick", function()
    addon.SoundQueue:StopCurrentSound()
    SoundQueueUI:UpdateDisplay()
end)

function SoundQueueUI:UpdateDisplay()
    -- Clear existing content
    for _, child in pairs({SoundQueueUI.content:GetChildren()}) do
        child:Hide()
    end

    -- Update pause/resume button text
    self.pauseResumeButton:SetText(QuestReaderAddonDB.IsPaused and "Resume" or "Pause")

    -- Populate with current queue
    local yOffset = 0
    for i, soundData in ipairs(addon.SoundQueue.sounds) do
        local soundFrame = CreateFrame("Frame", nil, self.content)
        soundFrame:SetSize(260, 30)
        soundFrame:SetPoint("TOPLEFT", 0, -yOffset)

        local text = soundFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", 5, 0)
        text:SetText(i .. ". " .. soundData.soundFile)

        if i == 1 and soundData.isPlaying then
            text:SetTextColor(0, 1, 0)  -- Green for currently playing
        else
            text:SetTextColor(1, 1, 1)  -- White for queued or stopped sounds
        end

        -- Add a stop button for each sound
        local stopButton = CreateFrame("Button", nil, soundFrame, "UIPanelCloseButton")
        stopButton:SetSize(20, 20)
        stopButton:SetPoint("RIGHT", -5, 0)
        stopButton:SetScript("OnClick", function()
            if i == 1 and soundData.isPlaying then
                addon.SoundQueue:StopCurrentSound()
            else
                addon.SoundQueue:RemoveSoundFromQueue(soundData)
            end
            SoundQueueUI:UpdateDisplay()
        end)

        yOffset = yOffset + 30
    end

    self.content:SetHeight(math.max(330, yOffset))
end

-- Function to toggle the UI visibility
function SoundQueueUI:ToggleVisibility()
    if self:IsVisible() then
        self:Hide()
    else
        self:Show()
        self:UpdateDisplay()
    end
end

local function UpdateUI()
    if SoundQueueUI:IsVisible() then
        SoundQueueUI:UpdateDisplay()
    end
end

C_Timer.NewTicker(0.5, UpdateUI)

-- Add a slash command to toggle the UI
SLASH_QRQUEUE1 = '/qrqueue'
SlashCmdList["QRQUEUE"] = function()
    SoundQueueUI:ToggleVisibility()
end

local function HookSoundQueueMethod(methodName)
    if addon.SoundQueue[methodName] then
        local originalMethod = addon.SoundQueue[methodName]
        addon.SoundQueue[methodName] = function(self, ...)
            originalMethod(self, ...)
            if SoundQueueUI:IsVisible() then
                SoundQueueUI:UpdateDisplay()
            end
        end
    end
end

-- Hook methods
HookSoundQueueMethod("AddSoundToQueue")
HookSoundQueueMethod("RemoveSoundFromQueue")
HookSoundQueueMethod("RemoveAllSoundsFromQueue")
HookSoundQueueMethod("PauseQueue")
HookSoundQueueMethod("ResumeQueue")
HookSoundQueueMethod("StopCurrentSound")

-- Add a slash command to stop the current sound
SLASH_QRSTOP1 = '/qrstop'
SlashCmdList["QRSTOP"] = function()
    addon.SoundQueue:StopCurrentSound()
    print("Attempted to stop current sound.")
end