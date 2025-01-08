-- the saved variable
WhisperShield_SavedVariables = WhisperShield_SavedVariables or {}

local loginMessageFrame = CreateFrame("Frame")
loginMessageFrame:RegisterEvent("PLAYER_LOGIN")
loginMessageFrame:SetScript("OnEvent", function(self, event, ...)
    print("|cffff0000QCheck |cffffff00Cyour settings before your adventure. |cff00ff00Type |cffffff00/WhisperShield| |cffffff00 for more options.")
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
    if not WhisperShield_SavedVariables.lastRespondTimes then
        WhisperShield_SavedVariables.lastRespondTimes = {}
    end
end

-- Initialize saved variables
InitializeSavedVariables()

-- Create a frame for the WhisperShield options
local WhisperShieldFrame = CreateFrame("Frame", "WhisperShieldFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
WhisperShieldFrame:SetSize(250, 470)
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

-- Add small texture in front of the title text
local shieldIcon = WhisperShieldFrame:CreateTexture(nil, "OVERLAY")
shieldIcon:SetSize(16, 16)
shieldIcon:SetPoint("RIGHT", titleText, "LEFT", -5, 0)
shieldIcon:SetTexture("Interface\\AddOns\\WhisperShield\\shieldicon.png")

-- Create explanatory text
local infoText = WhisperShieldFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
infoText:SetPoint("TOPLEFT", WhisperShieldFrame, "TOPLEFT", 10, -40)
infoText:SetText("|cff808080 /whispershield for more options|r")

-- Create minimize button
local minimizeButton = CreateFrame("Button", nil, WhisperShieldFrame)
minimizeButton:SetSize(20, 20)
minimizeButton:SetPoint("TOPRIGHT", WhisperShieldFrame, "TOPRIGHT", -5, -5)
local minimizeButtonTexture = minimizeButton:CreateTexture(nil, "BACKGROUND")
minimizeButtonTexture:SetAllPoints()
minimizeButtonTexture:SetTexture("Interface\\AddOns\\WhisperShield\\closebutton.png")
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
    checkbox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(tooltip, nil, nil, nil, nil, true)
        GameTooltip:Show()
    end)
    checkbox:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
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
local whisperCheckbox = CreateCheckbox("whisper", "Whisper", "Show/hide whisper messages (blocks anyone not a friend)", 10, -160, colors.whisper)
local partyCheckbox = CreateCheckbox("party", "Party", "Show/hide party messages", 10, -190, colors.party)
local partyLeaderCheckbox = CreateCheckbox("partyLeader", "Party Leader", "Show/hide party leader messages", 10, -220, colors.partyLeader)
local raidCheckbox = CreateCheckbox("raid", "Raid", "Show/hide raid messages", 10, -250, colors.raid)
local raidLeaderCheckbox = CreateCheckbox("raidLeader", "Raid Leader", "Show/hide raid leader messages", 10, -280, colors.raidLeader)
local guildCheckbox = CreateCheckbox("guild", "Guild", "Show/hide guild messages", 10, -310, colors.guild)
local emoteCheckbox = CreateCheckbox("emote", "Emote", "Show/hide emote messages", 10, -340, colors.emote)

-- Function to mute whisper sound
local function MuteWhisperSound()
    if not WhisperShield_SavedVariables.filters.whisper then
        MuteSoundFile(567482) -- Mute the whisper sound file
    else
        UnmuteSoundFile(567482) -- Unmute the whisper sound file
    end
end

-- Update whisper checkbox script to handle whisper filtering, response logic, and muting sound
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

    -- Reset response timer
    WhisperShield_SavedVariables.lastRespondTimes = {}

    -- Mute or unmute whisper sound based on the checkbox state
    MuteWhisperSound()
end)

-- Initialize whisper checkbox and mute sound accordingly
whisperCheckbox:SetChecked(WhisperShield_SavedVariables.filters.whisper)
if whisperCheckbox:GetChecked() then
    whisperCheckbox.text:SetTextColor(colors.whisper.r, colors.whisper.g, colors.whisper.b)
else
    whisperCheckbox.text:SetTextColor(0.5, 0.5, 0.5)
end
MuteWhisperSound()

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

-- Create a frame to show the list of blocked players
local blockedListFrame = CreateFrame("Frame", "BlockedListFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
blockedListFrame:SetSize(300, 400)
blockedListFrame:SetPoint("CENTER")
blockedListFrame:SetMovable(true)
blockedListFrame:EnableMouse(true)
blockedListFrame:RegisterForDrag("LeftButton")
blockedListFrame:SetScript("OnDragStart", blockedListFrame.StartMoving)
blockedListFrame:SetScript("OnDragStop", blockedListFrame.StopMovingOrSizing)
blockedListFrame:Hide()

-- Style the blocked list frame similarly to WhisperShieldFrame
blockedListFrame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
blockedListFrame:SetBackdropColor(0, 0, 0, 0.8)
blockedListFrame:SetBackdropBorderColor(0, 0, 0)

-- Create a scroll frame for the blocked list
local scrollFrame = CreateFrame("ScrollFrame", nil, blockedListFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 10, -30)
scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

-- Create a content frame for the scroll frame
local contentFrame = CreateFrame("Frame", nil, scrollFrame)
contentFrame:SetSize(260, 370)
scrollFrame:SetScrollChild(contentFrame)

-- Create a font string to display the blocked list
local blockedListText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
blockedListText:SetPoint("TOPLEFT")
blockedListText:SetWidth(260)
blockedListText:SetJustifyH("LEFT")

-- Function to get player details
local function GetPlayerDetails(author)
    local details = author
    local numFriends = C_FriendList.GetNumFriends()
    for i = 1, numFriends do
        local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
        if friendInfo.name == author then
            details = "[" .. friendInfo.level .. "] " .. author .. " (" .. RAID_CLASS_COLORS[friendInfo.classFileName].colorStr .. ")"
            break
        end
    end
    return details
end

-- Function to update the blocked list text
local function UpdateBlockedList()
    local blockedList = ""
    for author, _ in pairs(WhisperShield_SavedVariables.lastRespondTimes) do
        blockedList = blockedList .. GetPlayerDetails(author) .. "\n"
    end
    blockedListText:SetText(blockedList)
end

-- Create a title for the blocked list frame
local blockedListTitle = blockedListFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
blockedListTitle:SetPoint("TOP", blockedListFrame, "TOP", 0, -10)
blockedListTitle:SetText("|cffff0000Shielded Messages|r")

-- Create a close button for the blocked list frame
local closeButton = CreateFrame("Button", nil, blockedListFrame)
closeButton:SetSize(20, 20)
closeButton:SetPoint("TOPRIGHT", blockedListFrame, "TOPRIGHT", -5, -5)
local closeButtonTexture = closeButton:CreateTexture(nil, "BACKGROUND")
closeButtonTexture:SetAllPoints()
closeButtonTexture:SetTexture("Interface\\AddOns\\WhisperShield\\closebutton.png")
closeButton:SetScript("OnClick", function()
    blockedListFrame:Hide()
end)

-- Create a Angry texture anchored to the icon frame
local angryTexture = WhisperShieldIconFrame:CreateTexture(nil, "OVERLAY")
angryTexture:SetSize(7, 7)
angryTexture:SetPoint("TOPRIGHT", iconTexture, "TOPRIGHT", -3, 2) --- (first digit is left right, second digit is up down)
angryTexture:SetTexture("Interface\\AddOns\\WhisperShield\\angry.png")
angryTexture:Hide()

-- Add tooltip and click handlers for the angry texture
angryTexture:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Left-click to clear blocked list\nRight-click to view blocked list", nil, nil, nil, nil, true)
    GameTooltip:Show()
end)
angryTexture:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)
angryTexture:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then
        WhisperShield_SavedVariables.lastRespondTimes = {}
        blockedListText:SetText("")
        angryTexture:Hide()
        print("Blocked list cleared.")
    elseif button == "RightButton" then
        UpdateBlockedList()
        blockedListFrame:Show()
    end
end)

-- Function to filter incoming messages
local function WhisperShieldIncomingMessageFilter(self, event, msg, author, ...)
    -- Ensure lastRespondTimes is initialized
    WhisperShield_SavedVariables.lastRespondTimes = WhisperShield_SavedVariables.lastRespondTimes or {}

    local isFriend = IsFriend(author)
    local isGuildMember = IsGuildMember(author)

    -- Case: Whisper unchecked
    if not WhisperShield_SavedVariables.filters.whisper then
        if not isFriend and not (isGuildMember and WhisperShield_SavedVariables.filters.guild) then
            if event == "CHAT_MSG_WHISPER" then
                local lastRespondTime = WhisperShield_SavedVariables.lastRespondTimes[author]
                if not lastRespondTime or (GetTime() - lastRespondTime) > 60 then
                    SendChatMessage("WhisperShield: Unable to see your message because you are not on my friends list or guild", "WHISPER", nil, author)
                    WhisperShield_SavedVariables.lastRespondTimes[author] = GetTime()
                    angryTexture:Show()
                    UpdateBlockedList() -- Update the blocked list when a new player is added
                end
                return true -- Filter the whisper message
            end
        end
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
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", WhisperShieldIncomingMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", WhisperShieldIncomingMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", WhisperShieldIncomingMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", WhisperShieldIncomingMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", WhisperShieldIncomingMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", WhisperShieldIncomingMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", WhisperShieldIncomingMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND", WhisperShieldIncomingMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND_LEADER", WhisperShieldIncomingMessageFilter)

-- Function to create sliders
local function CreateSlider(name, label, minVal, maxVal, step, y, defaultValue, onValueChanged)
    local slider = CreateFrame("Slider", name, WhisperShieldFrame, "OptionsSliderTemplate")
    slider:SetPoint("TOP", 0, y)
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(step)
    slider:SetValue(defaultValue)
    slider:SetObeyStepOnDrag(true)
    slider.text = _G[name .. "Text"]
    slider.text:SetText(label)
    slider.text:ClearAllPoints()
    slider.text:SetPoint("BOTTOM", slider, "TOP", 0, 0)
    slider.textLow = _G[name .. "Low"]
    slider.textLow:SetText(minVal)
    slider.textLow:ClearAllPoints()
    slider.textLow:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 0, 0)
    slider.textHigh = _G[name .. "High"]
    slider.textHigh:SetText(maxVal)
    slider.textHigh:ClearAllPoints()
    slider.textHigh:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", 0, 0)
    slider:SetScript("OnValueChanged", function(self, value)
        onValueChanged(self, value)
    end)
    return slider
end

-- Create alpha slider
local alphaSlider = CreateSlider("WhisperShieldAlphaSlider", "Icon Alpha", 0.1, 1, 0.1, -370, WhisperShield_SavedVariables.iconAlpha or 1, function(self, value)
    WhisperShield_SavedVariables.iconAlpha = value
    WhisperShieldIconFrame:SetAlpha(value)
    WhisperShieldIconFrame:ClearAllPoints()
    WhisperShieldIconFrame:SetPoint(WhisperShield_SavedVariables.iconPoint, UIParent, WhisperShield_SavedVariables.iconRelativePoint, WhisperShield_SavedVariables.iconXOfs, WhisperShield_SavedVariables.iconYOfs)
end)

-- Create scale slider
local scaleSlider = CreateSlider("WhisperShieldScaleSlider", "Icon Scale", 0.1, 3, 0.1, -420, WhisperShield_SavedVariables.iconScale or 1, function(self, value)
    -- Save current position
    local point, relativeTo, relativePoint, xOfs, yOfs = WhisperShieldIconFrame:GetPoint()
    WhisperShield_SavedVariables.iconPoint = point
    WhisperShield_SavedVariables.iconRelativePoint = relativePoint
    WhisperShield_SavedVariables.iconXOfs = xOfs
    WhisperShield_SavedVariables.iconYOfs = yOfs

    -- Set new scale
    WhisperShield_SavedVariables.iconScale = value
    WhisperShieldIconFrame:SetScale(value)

    -- Restore position
    WhisperShieldIconFrame:ClearAllPoints()
    WhisperShieldIconFrame:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
end)

-- Adjust slider positions to fit within the frame
alphaSlider:SetPoint("TOP", 0, -390)
scaleSlider:SetPoint("TOP", 0, -420)