-- the saved variable
WhisperShield_SavedVariables = WhisperShield_SavedVariables or {}

local loginMessageFrame = CreateFrame("Frame")
loginMessageFrame:RegisterEvent("PLAYER_LOGIN")
loginMessageFrame:SetScript("OnEvent", function(self, event, ...)
    print("|cffffff00Check your settings before your adventure. |cff00ff00Type |cffffff00/WhisperShield|cffff0000QUIET|cffffff00 for more options.")
end)

local function InitializeSavedVariables()
    if not WhisperShield_SavedVariables then
        WhisperShield_SavedVariables = {}
    end
    if not WhisperShield_SavedVariables.filters then
        WhisperShield_SavedVariables.filters = {
            channel = true,
            say = true,
            yell = true,
            whisper = true,
            party = true,
            partyLeader = true,
            raid = true,
            raidLeader = true,
            guild = true,
            officer = true,
            emote = true,
            battleground = true,
            battlegroundLeader = true,
            bnet = false,
            autoRespond = false
        }
    end
    if not WhisperShield_SavedVariables.iconPoint then
        WhisperShield_SavedVariables.iconPoint = "CENTER"
        WhisperShield_SavedVariables.iconRelativePoint = "CENTER"
        WhisperShield_SavedVariables.iconXOfs = 0
        WhisperShield_SavedVariables.iconYOfs = 0
    end
    if not WhisperShield_SavedVariables.iconScale then
        WhisperShield_SavedVariables.iconScale = 2
    end
    if not WhisperShield_SavedVariables.iconAlpha then
        WhisperShield_SavedVariables.iconAlpha = 1
    end
end

-- Initialize saved variables
InitializeSavedVariables()

-- Create a frame for the WhisperShield options
local WhisperShieldFrame = CreateFrame("Frame", "WhisperShieldFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
WhisperShieldFrame:SetSize(250, 400)
WhisperShieldFrame:SetPoint("CENTER")
WhisperShieldFrame:SetMovable(true)
WhisperShieldFrame:EnableMouse(true)
WhisperShieldFrame:RegisterForDrag("LeftButton")
WhisperShieldFrame:SetScript("OnDragStart", WhisperShieldFrame.StartMoving)
WhisperShieldFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    -- Save the frame position
    local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
    WhisperShield_SavedVariables.point = point
    WhisperShield_SavedVariables.relativePoint = relativePoint
    WhisperShield_SavedVariables.xOfs = xOfs
    WhisperShield_SavedVariables.yOfs = yOfs
end)

-- Create a backdrop for the frame
WhisperShieldFrame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",  -- Background texture
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",    -- Border texture
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
WhisperShieldFrame:SetBackdropColor(0, 0, 0, 0.8)  -- Background color (black with transparency)
WhisperShieldFrame:SetBackdropBorderColor(0, 0, 0)  -- Border color (black)

-- Create title text
local titleText = WhisperShieldFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
titleText:SetPoint("TOP", WhisperShieldFrame, "TOP", 0, -10)
titleText:SetText("|cffff66ccWhisper|r |cff00ff00Shield|r |cffffffff|r")

-- Create explanatory text
local infoText = WhisperShieldFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
infoText:SetPoint("TOPLEFT", WhisperShieldFrame, "TOPLEFT", 10, -40)
infoText:SetText("Uncheck to hide messages")

-- Create minimize button
local minimizeButton = CreateFrame("Button", nil, WhisperShieldFrame, "UIPanelButtonTemplate")
minimizeButton:SetSize(24, 24)
minimizeButton:SetPoint("TOPRIGHT", WhisperShieldFrame, "TOPRIGHT", -5, -5)
minimizeButton:SetText("-")
minimizeButton:SetScript("OnClick", function()
    WhisperShieldFrame:Hide()
    WhisperShieldIconFrame:Show()
end)

-- Hide the frame initially on start up
WhisperShieldFrame:Hide()

-- Function to create checkboxes
local function CreateCheckbox(name, label, tooltip, x, y, color)
    local checkbox = CreateFrame("CheckButton", name, WhisperShieldFrame, "UICheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", x, y)
    checkbox.text = checkbox:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    checkbox.text:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
    checkbox.text:SetText(label)
    checkbox.text:SetTextColor(color.r, color.g, color.b)
    checkbox.tooltip = tooltip
    checkbox:SetScript("OnClick", function(self)
        WhisperShield_SavedVariables.filters[name] = self:GetChecked()
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
local guildCheckbox = CreateCheckbox("guild", "Guild", "Show/hide guild messages", 10, -310, colors.guild)
local emoteCheckbox = CreateCheckbox("emote", "Emote", "Show/hide emote messages", 10, -340, colors.emote)

-- Update whisper checkbox script to handle whisper filtering and response logic
whisperCheckbox:SetScript("OnClick", function(self)
    local isChecked = self:GetChecked()
    WhisperShield_SavedVariables.filters.whisper = isChecked

    if isChecked then
        -- Allow all whispers without filtering or auto-responding
        whisperCheckbox.text:SetTextColor(colors.whisper.r, colors.whisper.g, colors.whisper.b)
    else
        -- Enable whisper filtering and auto-response
        whisperCheckbox.text:SetTextColor(0.5, 0.5, 0.5)
    end
end)

-- Initialize whisper checkbox
whisperCheckbox:SetChecked(WhisperShield_SavedVariables.filters.whisper)
if whisperCheckbox:GetChecked() then
    whisperCheckbox.text:SetTextColor(colors.whisper.r, colors.whisper.g, colors.whisper.b)
else
    whisperCheckbox.text:SetTextColor(0.5, 0.5, 0.5)
end


-- Initialize checkboxes
channelCheckbox:SetChecked(WhisperShield_SavedVariables.filters.channel)
sayCheckbox:SetChecked(WhisperShield_SavedVariables.filters.say)
yellCheckbox:SetChecked(WhisperShield_SavedVariables.filters.yell)
whisperCheckbox:SetChecked(WhisperShield_SavedVariables.filters.whisper)
partyCheckbox:SetChecked(WhisperShield_SavedVariables.filters.party)
partyLeaderCheckbox:SetChecked(WhisperShield_SavedVariables.filters.partyLeader)
raidCheckbox:SetChecked(WhisperShield_SavedVariables.filters.raid)
raidLeaderCheckbox:SetChecked(WhisperShield_SavedVariables.filters.raidLeader)
guildCheckbox:SetChecked(WhisperShield_SavedVariables.filters.guild)
emoteCheckbox:SetChecked(WhisperShield_SavedVariables.filters.emote)

-- Function to load saved settings
local function LoadSavedSettings()
    WhisperShieldIconFrame:SetScale(WhisperShield_SavedVariables.iconScale or 1)
    WhisperShieldIconFrame:SetAlpha(WhisperShield_SavedVariables.iconAlpha or 1)
    WhisperShieldIconFrame:ClearAllPoints()
    WhisperShieldIconFrame:SetPoint(WhisperShield_SavedVariables.iconPoint, UIParent, WhisperShield_SavedVariables.iconRelativePoint, WhisperShield_SavedVariables.iconXOfs, WhisperShield_SavedVariables.iconYOfs)
end

-- Create icon frame
local WhisperShieldIconFrame = CreateFrame("Frame", "WhisperShieldIconFrame", UIParent)
WhisperShieldIconFrame:SetSize(25, 25)
WhisperShieldIconFrame:EnableMouse(true)
WhisperShieldIconFrame:SetMovable(true)
WhisperShieldIconFrame:RegisterForDrag("LeftButton")
WhisperShieldIconFrame:SetScript("OnDragStart", WhisperShieldIconFrame.StartMoving)
WhisperShieldIconFrame:SetScript("OnDragStop", function(self)
    WhisperShieldIconFrame:StopMovingOrSizing()
    -- Save the icon frame position
    local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
    WhisperShield_SavedVariables.iconPoint = point
    WhisperShield_SavedVariables.iconRelativePoint = relativePoint
    WhisperShield_SavedVariables.iconXOfs = xOfs
    WhisperShield_SavedVariables.iconYOfs = yOfs
end)
WhisperShieldIconFrame:SetScript("OnMouseUp", function(self, button)
    if button == "RightButton" then
        WhisperShieldFrame:Show()
        WhisperShieldIconFrame:Hide()
    end
end)
WhisperShieldIconFrame:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Left-click to move\nRight-click to open ", nil, nil, nil, nil, true)
    GameTooltip:Show()
end)
WhisperShieldIconFrame:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

-- Function to load saved settings
local function LoadSavedSettings()
    WhisperShieldIconFrame:SetScale(WhisperShield_SavedVariables.iconScale or 1)
    WhisperShieldIconFrame:SetAlpha(WhisperShield_SavedVariables.iconAlpha or 1)
    WhisperShieldIconFrame:ClearAllPoints()
    WhisperShieldIconFrame:SetPoint(WhisperShield_SavedVariables.iconPoint, UIParent, WhisperShield_SavedVariables.iconRelativePoint, WhisperShield_SavedVariables.iconXOfs, WhisperShield_SavedVariables.iconYOfs)
end

-- Load saved settings after creating the icon frame & show it
C_Timer.After(0, function()
    LoadSavedSettings()
    WhisperShieldIconFrame:Show()
end)

-- texture for icon frame
local iconTexture = WhisperShieldIconFrame:CreateTexture(nil, "BACKGROUND")
iconTexture:SetAllPoints()
iconTexture:SetTexture("Interface\\AddOns\\WhisperShield\\monkey.png")  --  texture

-- Create slash command to show Options 
SLASH_WhisperShield1 = "/WhisperShield"
SlashCmdList["WhisperShield"] = function(msg)
    if msg == "show" then
        WhisperShieldFrame:Show()
        WhisperShieldIconFrame:Hide()
    elseif msg == "hide" then
        WhisperShieldFrame:Hide()
        WhisperShieldIconFrame:Show()
    elseif msg:match("^scale %d*%.?%d+$") then
        local scale = tonumber(msg:match("%d*%.?%d+"))
        if scale and scale >= 0.1 and scale <= 10 then
            WhisperShieldIconFrame:SetScale(scale)
            WhisperShield_SavedVariables.iconScale = scale
            WhisperShieldIconFrame:ClearAllPoints()
            WhisperShieldIconFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
            WhisperShield_SavedVariables.iconPoint = "CENTER"
            WhisperShield_SavedVariables.iconRelativePoint = "CENTER"
            WhisperShield_SavedVariables.iconXOfs = 0
            WhisperShield_SavedVariables.iconYOfs = 0
            print("|cffff66ccWhisper|r|cff00ff00Shield|r |cffffffff!|r|cffffffffhas been changed to|r |cff00ff00" .. scale .. "|r (|cffffffffscale)|r.")
        else
            print("|cffff66ccWhisper|r|cff00ff00Shield|r |cffffffff!|r usage: /WhisperShield scale 1 to 10")
        end
    elseif msg:match("^fade %d*%.?%d+$") then
        local fade = tonumber(msg:match("%d*%.?%d+"))
        if fade and fade >= 1 and fade <= 10 then
            WhisperShieldIconFrame:SetAlpha(fade / 10)
            WhisperShield_SavedVariables.iconAlpha = fade / 10
            WhisperShieldIconFrame:ClearAllPoints()
            WhisperShieldIconFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
            WhisperShield_SavedVariables.iconPoint = "CENTER"
            WhisperShield_SavedVariables.iconRelativePoint = "CENTER"
            WhisperShield_SavedVariables.iconXOfs = 0
            WhisperShield_SavedVariables.iconYOfs = 0
            print("|cffffff00WhisperShield|r |cffffffffhas been changed to|r |cff00ff00" .. fade .. "|r (|cfffffffffade)|r.")
        else
            print("|cffff66ccWhisper|r|cff00ff00Shield|r |cffffffff!|rusage: /WhisperShield fade 1 to 10")
        end
    elseif msg == "center" then
        WhisperShieldIconFrame:ClearAllPoints()
        WhisperShieldIconFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        WhisperShield_SavedVariables.iconPoint = "CENTER"
        WhisperShield_SavedVariables.iconRelativePoint = "CENTER"
        WhisperShield_SavedVariables.iconXOfs = 0
        WhisperShield_SavedVariables.iconYOfs = 0
        print("|cffff66ccWhisper|r|cff00ff00Shield|r |cffffffff!|r Icon frame centered.")
    else
        print("|cffffff00/WhisperShield|r usage:")
        print("|cff00FFFF/WhisperShield|r show - Show options frame")
        print("|cff00FFFF/WhisperShield|r hide - Hide options frame")
        print("|cff00FFFF/WhisperShield|r scale 1 to 10 - Adjust the icon size")
        print("|cff00FFFF/WhisperShield|r fade 1 to 10 - Adjust the icon transparency")
        print("|cff00FFFF/WhisperShield|r center - Center the icon frame on the screen")
    end
end

-- Function to check if the sender is a friend
local function IsFriend(author)
    for i = 1, C_FriendList.GetNumFriends() do
        local friendName = C_FriendList.GetFriendInfoByIndex(i).name
        if friendName == author then
            return true
        end
    end
    return false
end

-- Function to check if the sender is in the same guild
local function IsGuildMember(author)
    for i = 1, GetNumGuildMembers() do
        local guildMemberName = GetGuildRosterInfo(i)
        if guildMemberName == author then
            return true
        end
    end
    return false
end

-- Function to filter incoming messages
local function WhisperShieldIncomingMessageFilter(self, event, msg, author, ...)
    local isFriend = IsFriend(author)
    local isGuildMember = IsGuildMember(author)

    -- Case: Whisper unchecked
    if not WhisperShield_SavedVariables.filters.whisper then
        if not (isFriend or isGuildMember) then
            if event == "CHAT_MSG_WHISPER" then
                if not WhisperShield_SavedVariables.lastRespondTime or (GetTime() - WhisperShield_SavedVariables.lastRespondTime) > 60 then
                    SendChatMessage("WhisperShield!: Unable to see your message because you are not on my friends list or guild", "WHISPER", nil, author)
                    WhisperShield_SavedVariables.lastRespondTime = GetTime()
                end
            end
            return true -- Filter messages from others
        else
            return false -- Do not filter friends/guild members
        end
    end

    -- Case: Whisper checked
    if WhisperShield_SavedVariables.filters.whisper then
        return false -- Accept all incoming messages
    end

    -- Default message filtering logic
    if event == "CHAT_MSG_CHANNEL" and not WhisperShield_SavedVariables.filters.channel then return true end
    if event == "CHAT_MSG_SAY" and not WhisperShield_SavedVariables.filters.say then return true end
    if event == "CHAT_MSG_YELL" and not WhisperShield_SavedVariables.filters.yell then return true end
    if event == "CHAT_MSG_PARTY" and not WhisperShield_SavedVariables.filters.party then return true end
    if event == "CHAT_MSG_PARTY_LEADER" and not WhisperShield_SavedVariables.filters.partyLeader then return true end
    if event == "CHAT_MSG_RAID" and not WhisperShield_SavedVariables.filters.raid then return true end
    if event == "CHAT_MSG_RAID_LEADER" and not WhisperShield_SavedVariables.filters.raidLeader then return true end
    if event == "CHAT_MSG_RAID_WARNING" and not WhisperShield_SavedVariables.filters.raidWarning then return true end
    if event == "CHAT_MSG_GUILD" and not WhisperShield_SavedVariables.filters.guild then return true end
    if event == "CHAT_MSG_OFFICER" and not WhisperShield_SavedVariables.filters.officer then return true end
    if event == "CHAT_MSG_EMOTE" and not WhisperShield_SavedVariables.filters.emote then return true end
    if event == "CHAT_MSG_BATTLEGROUND" and not WhisperShield_SavedVariables.filters.battleground then return true end
    if event == "CHAT_MSG_BATTLEGROUND_LEADER" and not WhisperShield_SavedVariables.filters.battlegroundLeader then return true end
    
    return false
end


-- Register the filter
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", WhisperShieldIncomingMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", WhisperShieldIncomingMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", WhisperShieldIncomingMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", WhisperShieldIncomingMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", WhisperShieldIncomingMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", WhisperShieldIncomingMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", WhisperShieldIncomingMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", WhisperShieldIncomingMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", WhisperShieldIncomingMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", WhisperShieldIncomingMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", WhisperShieldIncomingMessageFilter)