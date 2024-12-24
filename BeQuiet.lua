-- Declare the saved variable
BeQuiet_SavedVariables = BeQuiet_SavedVariables or {}

local loginMessageFrame = CreateFrame("Frame")
loginMessageFrame:RegisterEvent("PLAYER_LOGIN")
loginMessageFrame:SetScript("OnEvent", function(self, event, ...)
    print("|cffffff00Check your settings before your adventure. |cff00ff00Type |cffffff00/BE|cffff0000QUIET|cffffff00 for more options.")
end)

local function InitializeSavedVariables()
    if not BeQuiet_SavedVariables.point then
        BeQuiet_SavedVariables.point = "CENTER"
        BeQuiet_SavedVariables.relativePoint = "CENTER"
        BeQuiet_SavedVariables.xOfs = 0
        BeQuiet_SavedVariables.yOfs = 0
    end
    if not BeQuiet_SavedVariables.filters then
        BeQuiet_SavedVariables.filters = {
            channel = true,
            say = true,
            yell = true,
            whisper = true,
            party = true,
            partyLeader = true,
            raid = true,
            raidLeader = true,
            raidWarning = true,
            guild = true,
            officer = true,
            emote = true,
            battleground = true,
            battlegroundLeader = true,
            bnet = false,
            autoRespond = false
        }
    end
    if not BeQuiet_SavedVariables.iconPoint then
        BeQuiet_SavedVariables.iconPoint = "CENTER"
        BeQuiet_SavedVariables.iconRelativePoint = "CENTER"
        BeQuiet_SavedVariables.iconXOfs = 0
        BeQuiet_SavedVariables.iconYOfs = 0
    end
    if not BeQuiet_SavedVariables.iconScale then
        BeQuiet_SavedVariables.iconScale = 2
    end
    if not BeQuiet_SavedVariables.iconAlpha then
        BeQuiet_SavedVariables.iconAlpha = 1
    end
end

-- Initialize saved variables
InitializeSavedVariables()

-- Create a frame for the BeQuiet options
local BeQuietFrame = CreateFrame("Frame", "BeQuietFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
BeQuietFrame:SetSize(250, 550)
BeQuietFrame:SetPoint("CENTER")
BeQuietFrame:SetMovable(true)
BeQuietFrame:EnableMouse(true)
BeQuietFrame:RegisterForDrag("LeftButton")
BeQuietFrame:SetScript("OnDragStart", BeQuietFrame.StartMoving)
BeQuietFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    -- Save the frame position
    local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
    BeQuiet_SavedVariables.point = point
    BeQuiet_SavedVariables.relativePoint = relativePoint
    BeQuiet_SavedVariables.xOfs = xOfs
    BeQuiet_SavedVariables.yOfs = yOfs
end)

-- Create a backdrop for the frame
BeQuietFrame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",  -- Background texture
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",    -- Border texture
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
BeQuietFrame:SetBackdropColor(0, 0, 0, 0.8)  -- Background color (black with transparency)
BeQuietFrame:SetBackdropBorderColor(0, 0, 0)  -- Border color (black)

-- Create title text
local titleText = BeQuietFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
titleText:SetPoint("TOP", BeQuietFrame, "TOP", 0, -10)
titleText:SetText("|cffffff00Be|r |cffff0000Quiet|r |cffffffff!|r")

-- Create explanatory text
local infoText = BeQuietFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
infoText:SetPoint("TOPLEFT", BeQuietFrame, "TOPLEFT", 10, -40)
infoText:SetText("Uncheck to hide messages")

-- Create minimize button
local minimizeButton = CreateFrame("Button", nil, BeQuietFrame, "UIPanelButtonTemplate")
minimizeButton:SetSize(24, 24)
minimizeButton:SetPoint("TOPRIGHT", BeQuietFrame, "TOPRIGHT", -5, -5)
minimizeButton:SetText("—")
minimizeButton:SetNormalFontObject("GameFontNormal")
minimizeButton:SetScript("OnClick", function()
    BeQuietFrame:Hide()
    BeQuietIconFrame:Show()
end)

-- Hide the frame initially on start up
BeQuietFrame:Hide()

-- Function to create checkboxes
local function CreateCheckbox(name, label, tooltip, x, y, color)
    local checkbox = CreateFrame("CheckButton", name, BeQuietFrame, "UICheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", x, y)
    checkbox.text = checkbox:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    checkbox.text:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
    checkbox.text:SetText(label)
    checkbox.text:SetTextColor(color.r, color.g, color.b)
    checkbox.tooltip = tooltip
    checkbox:SetScript("OnClick", function(self)
        BeQuiet_SavedVariables.filters[name] = self:GetChecked()
        if self:GetChecked() then
            checkbox.text:SetTextColor(color.r, color.g, color.b)
        else
            checkbox.text:SetTextColor(0.5, 0.5, 0.5)
        end
    end)
    return checkbox
end

-- Define colors for each chat type
local colors = {
    channel = { r = 1, g = 0.75, b = 0.75 },  -- Light red
    say = { r = 1, g = 1, b = 1 },  -- White
    yell = { r = 1, g = 0.25, b = 0.25 },  -- Red
    whisper = { r = 1, g = 0.5, b = 1 },  -- Pink
    party = { r = 0.67, g = 0.67, b = 1 },  -- Light blue
    partyLeader = { r = 0.46, g = 0.78, b = 1 },  -- Light blue
    raid = { r = 1, g = 0.5, b = 0 },  -- Orange
    raidLeader = { r = 1, g = 0.28, b = 0.04 },  -- Orange
    raidWarning = { r = 1, g = 0.1, b = 0.1 },  -- Red
    guild = { r = 0.25, g = 1, b = 0.25 },  -- Green
    officer = { r = 0.25, g = 0.75, b = 0.25 },  -- Dark green
    emote = { r = 1, g = 0.5, b = 0.25 },  -- Orange
    battleground = { r = 1, g = 0.49, b = 0.04 },  -- Orange
    battlegroundLeader = { r = 1, g = 0.49, b = 0.04 },  -- Orange
    bnet = { r = 0.77, g = 1, b = 1 },  -- Cyan
    autoRespond = { r = 1, g = 1, b = 0 }  -- Yellow
}

-- Create checkboxes for each filter
local channelCheckbox = CreateCheckbox("channel", "Channel", "Show/hide channel messages", 10, -70, colors.channel)
local sayCheckbox = CreateCheckbox("say", "Say", "Show/hide say messages", 10, -100, colors.say)
local yellCheckbox = CreateCheckbox("yell", "Yell", "Show/hide yell messages", 10, -130, colors.yell)
local whisperCheckbox = CreateCheckbox("whisper", "Whisper", "Show/hide whisper messages", 10, -160, colors.whisper)
local partyCheckbox = CreateCheckbox("party", "Party", "Show/hide party messages", 10, -190, colors.party)
local partyLeaderCheckbox = CreateCheckbox("partyLeader", "Party Leader", "Show/hide party leader messages", 10, -220, colors.partyLeader)
local raidCheckbox = CreateCheckbox("raid", "Raid", "Show/hide raid messages", 10, -250, colors.raid)
local raidLeaderCheckbox = CreateCheckbox("raidLeader", "Raid Leader", "Show/hide raid leader messages", 10, -280, colors.raidLeader)
local raidWarningCheckbox = CreateCheckbox("raidWarning", "Raid Warning", "Show/hide raid warning messages", 10, -310, colors.raidWarning)
local guildCheckbox = CreateCheckbox("guild", "Guild", "Show/hide guild messages", 10, -340, colors.guild)
local officerCheckbox = CreateCheckbox("officer", "Officer", "Show/hide officer messages", 10, -370, colors.officer)
local emoteCheckbox = CreateCheckbox("emote", "Emote", "Show/hide emote messages", 10, -400, colors.emote)
local battlegroundCheckbox = CreateCheckbox("battleground", "Battleground", "Show/hide battleground messages", 10, -430, colors.battleground)
local battlegroundLeaderCheckbox = CreateCheckbox("battlegroundLeader", "Battleground Leader", "Show/hide battleground leader messages", 10, -460, colors.battlegroundLeader)
local autoRespondCheckbox = CreateCheckbox("autoRespond", "Auto Reply to Non-Friends", "Automatically respond to whispers from non-friends", 10, -490, colors.autoRespond)

-- Update whisper checkbox script to handle auto respond checkbox
whisperCheckbox:SetScript("OnClick", function(self)
    BeQuiet_SavedVariables.filters.whisper = self:GetChecked()
    if self:GetChecked() then
        autoRespondCheckbox:SetChecked(false)
        autoRespondCheckbox:Disable()
        autoRespondCheckbox.text:SetTextColor(0.5, 0.5, 0.5)
        whisperCheckbox.text:SetTextColor(colors.whisper.r, colors.whisper.g, colors.whisper.b)
    else
        autoRespondCheckbox:SetChecked(true)
        autoRespondCheckbox:Enable()
        autoRespondCheckbox.text:SetTextColor(colors.autoRespond.r, colors.autoRespond.g, colors.autoRespond.b)
        whisperCheckbox.text:SetTextColor(0.5, 0.5, 0.5)
    end
end)

-- Initialize checkboxes
channelCheckbox:SetChecked(BeQuiet_SavedVariables.filters.channel)
sayCheckbox:SetChecked(BeQuiet_SavedVariables.filters.say)
yellCheckbox:SetChecked(BeQuiet_SavedVariables.filters.yell)
whisperCheckbox:SetChecked(BeQuiet_SavedVariables.filters.whisper)
partyCheckbox:SetChecked(BeQuiet_SavedVariables.filters.party)
partyLeaderCheckbox:SetChecked(BeQuiet_SavedVariables.filters.partyLeader)
raidCheckbox:SetChecked(BeQuiet_SavedVariables.filters.raid)
raidLeaderCheckbox:SetChecked(BeQuiet_SavedVariables.filters.raidLeader)
raidWarningCheckbox:SetChecked(BeQuiet_SavedVariables.filters.raidWarning)
guildCheckbox:SetChecked(BeQuiet_SavedVariables.filters.guild)
officerCheckbox:SetChecked(BeQuiet_SavedVariables.filters.officer)
emoteCheckbox:SetChecked(BeQuiet_SavedVariables.filters.emote)
battlegroundCheckbox:SetChecked(BeQuiet_SavedVariables.filters.battleground)
battlegroundLeaderCheckbox:SetChecked(BeQuiet_SavedVariables.filters.battlegroundLeader)
autoRespondCheckbox:SetChecked(BeQuiet_SavedVariables.filters.autoRespond)
autoRespondCheckbox:SetEnabled(not whisperCheckbox:GetChecked())
if whisperCheckbox:GetChecked() then
    autoRespondCheckbox.text:SetTextColor(0.5, 0.5, 0.5)
else
    autoRespondCheckbox.text:SetTextColor(colors.autoRespond.r, colors.autoRespond.g, colors.autoRespond.b)
end

-- Function to load saved settings
local function LoadSavedSettings()
    BeQuietIconFrame:SetScale(BeQuiet_SavedVariables.iconScale or 1)
    BeQuietIconFrame:SetAlpha(BeQuiet_SavedVariables.iconAlpha or 1)
    BeQuietIconFrame:ClearAllPoints()
    BeQuietIconFrame:SetPoint(BeQuiet_SavedVariables.iconPoint, UIParent, BeQuiet_SavedVariables.iconRelativePoint, BeQuiet_SavedVariables.iconXOfs, BeQuiet_SavedVariables.iconYOfs)
end

-- Create icon frame
local BeQuietIconFrame = CreateFrame("Frame", "BeQuietIconFrame", UIParent)
BeQuietIconFrame:SetSize(25, 25)
BeQuietIconFrame:EnableMouse(true)
BeQuietIconFrame:SetMovable(true)
BeQuietIconFrame:RegisterForDrag("LeftButton")
BeQuietIconFrame:SetScript("OnDragStart", BeQuietIconFrame.StartMoving)
BeQuietIconFrame:SetScript("OnDragStop", function(self)
    BeQuietIconFrame:StopMovingOrSizing()
    -- Save the icon frame position
    local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
    BeQuiet_SavedVariables.iconPoint = point
    BeQuiet_SavedVariables.iconRelativePoint = relativePoint
    BeQuiet_SavedVariables.iconXOfs = xOfs
    BeQuiet_SavedVariables.iconYOfs = yOfs
end)
BeQuietIconFrame:SetScript("OnMouseUp", function(self, button)
    if button == "RightButton" then
        BeQuietFrame:Show()
        BeQuietIconFrame:Hide()
    end
end)
BeQuietIconFrame:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Left-click to move\nRight-click to open BeQuiet frame", nil, nil, nil, nil, true)
    GameTooltip:Show()
end)
BeQuietIconFrame:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

-- Function to load saved settings
local function LoadSavedSettings()
    BeQuietIconFrame:SetScale(BeQuiet_SavedVariables.iconScale or 1)
    BeQuietIconFrame:SetAlpha(BeQuiet_SavedVariables.iconAlpha or 1)
    BeQuietIconFrame:ClearAllPoints()
    BeQuietIconFrame:SetPoint(BeQuiet_SavedVariables.iconPoint, UIParent, BeQuiet_SavedVariables.iconRelativePoint, BeQuiet_SavedVariables.iconXOfs, BeQuiet_SavedVariables.iconYOfs)
end

-- Load saved settings after creating the icon frame & show it
C_Timer.After(0, function()
    LoadSavedSettings()
    BeQuietIconFrame:Show()
end)

-- texture for icon frame
local iconTexture = BeQuietIconFrame:CreateTexture(nil, "BACKGROUND")
iconTexture:SetAllPoints()
iconTexture:SetTexture("Interface\\AddOns\\BeQuiet\\speaknoevil.png")  --  texture

-- Create slash command to show Options 
SLASH_BEQUIET1 = "/bequiet"
SlashCmdList["BEQUIET"] = function(msg)
    if msg == "show" then
        BeQuietFrame:Show()
        BeQuietIconFrame:Hide()
    elseif msg == "hide" then
        BeQuietFrame:Hide()
        BeQuietIconFrame:Show()
    elseif msg:match("^scale %d*%.?%d+$") then
        local scale = tonumber(msg:match("%d*%.?%d+"))
        if scale and scale >= 0.1 and scale <= 10 then
            BeQuietIconFrame:SetScale(scale)
            BeQuiet_SavedVariables.iconScale = scale
            BeQuietIconFrame:ClearAllPoints()
            BeQuietIconFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
            BeQuiet_SavedVariables.iconPoint = "CENTER"
            BeQuiet_SavedVariables.iconRelativePoint = "CENTER"
            BeQuiet_SavedVariables.iconXOfs = 0
            BeQuiet_SavedVariables.iconYOfs = 0
            print("|cffffff00Be|cffff0000Quiet|r |cffffffffhas been changed to|r |cff00ff00" .. scale .. "|r (|cffffffffscale)|r.")
        else
            print("||cffffff00Be|cffff0000Quietr usage: /bequiet scale 1 to 10")
        end
    elseif msg:match("^fade %d*%.?%d+$") then
        local fade = tonumber(msg:match("%d*%.?%d+"))
        if fade and fade >= 1 and fade <= 10 then
            BeQuietIconFrame:SetAlpha(fade / 10)
            BeQuiet_SavedVariables.iconAlpha = fade / 10
            BeQuietIconFrame:ClearAllPoints()
            BeQuietIconFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
            BeQuiet_SavedVariables.iconPoint = "CENTER"
            BeQuiet_SavedVariables.iconRelativePoint = "CENTER"
            BeQuiet_SavedVariables.iconXOfs = 0
            BeQuiet_SavedVariables.iconYOfs = 0
            print("|cffffff00BeQuiet|r |cffffffffhas been changed to|r |cff00ff00" .. fade .. "|r (|cfffffffffade)|r.")
        else
            print("|cffffff00Be|cffff0000Quiet|r usage: /bequiet fade 1 to 10")
        end
    elseif msg == "center" then
        BeQuietIconFrame:ClearAllPoints()
        BeQuietIconFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        BeQuiet_SavedVariables.iconPoint = "CENTER"
        BeQuiet_SavedVariables.iconRelativePoint = "CENTER"
        BeQuiet_SavedVariables.iconXOfs = 0
        BeQuiet_SavedVariables.iconYOfs = 0
        print("|cffffff00/Be|cffff0000Quiet|r Icon frame centered.")
    else
        print("|cffffff00/Be|cffff0000Quiet|r usage:")
        print("|cff00FFFF/bequiet|r show - Show options frame")
        print("|cff00FFFF/bequiet|r hide - Hide options frame")
        print("|cff00FFFF/bequiet|r scale 1 to 10 - Adjust the icon size")
        print("|cff00FFFF/bequiet|r fade 1 to 10 - Adjust the icon transparency")
        print("|cff00FFFF/bequiet|r center - Center the icon frame on the screen")
    end
end

-- Function to filter incoming messages
local function BeQuietIncomingMessageFilter(self, event, msg, author, ...)
    if UnitIsFriend("player", author) then
        return false
    end
    if event == "CHAT_MSG_CHANNEL" and not BeQuiet_SavedVariables.filters.channel then return true end
    if event == "CHAT_MSG_SAY" and not BeQuiet_SavedVariables.filters.say then return true end
    if event == "CHAT_MSG_YELL" and not BeQuiet_SavedVariables.filters.yell then return true end
    if event == "CHAT_MSG_WHISPER" and not BeQuiet_SavedVariables.filters.whisper then
        if BeQuiet_SavedVariables.filters.autoRespond and not UnitIsFriend("player", author) then
            if not BeQuiet_SavedVariables.lastRespondTime or (GetTime() - BeQuiet_SavedVariables.lastRespondTime) > 60 then
                SendChatMessage("BeQuiet! Unable to see your message because you are not on my friends list", "WHISPER", nil, author)
                BeQuiet_SavedVariables.lastRespondTime = GetTime()
            end
        end
        return true
    end
    if event == "CHAT_MSG_PARTY" and not BeQuiet_SavedVariables.filters.party then return true end
    if event == "CHAT_MSG_PARTY_LEADER" and not BeQuiet_SavedVariables.filters.partyLeader then return true end
    if event == "CHAT_MSG_RAID" and not BeQuiet_SavedVariables.filters.raid then return true end
    if event == "CHAT_MSG_RAID_LEADER" and not BeQuiet_SavedVariables.filters.raidLeader then return true end
    if event == "CHAT_MSG_RAID_WARNING" and not BeQuiet_SavedVariables.filters.raidWarning then return true end
    if event == "CHAT_MSG_GUILD" and not BeQuiet_SavedVariables.filters.guild then return true end
    if event == "CHAT_MSG_OFFICER" and not BeQuiet_SavedVariables.filters.officer then return true end
    if event == "CHAT_MSG_EMOTE" and not BeQuiet_SavedVariables.filters.emote then return true end
    if event == "CHAT_MSG_BATTLEGROUND" and not BeQuiet_SavedVariables.filters.battleground then return true end
    if event == "CHAT_MSG_BATTLEGROUND_LEADER" and not BeQuiet_SavedVariables.filters.battlegroundLeader then return true end
    return false
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", BeQuietIncomingMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", BeQuietIncomingMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", BeQuietIncomingMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", BeQuietIncomingMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", BeQuietIncomingMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", BeQuietIncomingMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", BeQuietIncomingMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", BeQuietIncomingMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_WARNING", BeQuietIncomingMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", BeQuietIncomingMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", BeQuietIncomingMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", BeQuietIncomingMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND", BeQuietIncomingMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND_LEADER", BeQuietIncomingMessageFilter)