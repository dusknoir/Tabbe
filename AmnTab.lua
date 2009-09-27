AmnTabDB = {}
local tablist = {}
local e = ChatFrameEditBox
local showOffline = { ["friends"] = nil, ["guild"] = nil }

local AmnTab = CreateFrame"Frame"
AmnTab:RegisterEvent"PLAYER_LOGIN"
AmnTab:SetScript("OnEvent", function(self)
	if AmnTabDB.guild == nil then 
		AmnTabDB.guild = false
	end

	if AmnTabDB.friends == nil then 
		AmnTabDB.friends = false
	end
	showOffline["friends"] = AmnTabDB.friends
	showOffline["guild"] = AmnTabDB.guild
end)

-- Should not get very sloppy in big guilds. 
local function add(name)
	for _, n in pairs(tablist) do
		if n == name then return end
	end
	table.insert(tablist, name)
end

local function UpdateTab()
		tablist = {}
	
		for i = 1, GetNumFriends() do
			local name, _, _, _, online, _ = GetFriendInfo(i)
			if online or showOffline["friends"] then add(name) end
		end
		if IsInGuild() then 
			for i = 1, GetNumGuildMembers(showOffline["guild"]) do
				local name, _, _, _, _, _, _, _, online, _ = GetGuildRosterInfo(i)
				if online or showOffline["guild"] then add(name) end
			end
		end
		if UnitInRaid"player" then
			for i = 1, GetNumRaidMembers() do
				local name, _, _, _, _, _, _, _, _ = GetRaidRosterInfo(i)
				add(name) 
			end
		end
		if UnitInParty"player" then
			for i = 1, GetNumPartyMembers() do
				local name = UnitName("party"..i)
				add(name)
			end
		end
end

-- Seen it in AceTab-2.0? NOWAI. 
local function GetPosition()
	local pos
	if e:GetText() == "" then return end
	e:Insert"\255"
	pos = e:GetText():find("\255", 1) - 1
	e:HighlightText(pos, pos + 1)
	e:Insert"\0"
	return pos
end

-- Seen it in AceTab-2.0? NOWAI. 
local function CompleteTab()
 	local pos = GetPosition()
	if not pos then return end

	local full = e:GetText()
	local text = full:sub(1, pos)
	local left = text:sub(1, pos):find"%w+$"
	left = left and left - 1 or pos
	if not left or left == 1 and text:sub(1, 1) == "/" then return end
	local word = text:sub(left, pos):match"(%w+)"
	if not full:find"%a" or not word then return end

	UpdateTab()
	
	local matches = {}
	local i = 1
	for _, s in pairs(tablist) do
		if s:lower():find(word:lower(), 1, 1) == 1 then
			table.insert(matches, i, s)
			i = i + 1
		end
	end
	
	if #matches > 1 then 
		local m = ""
		for i = 1, #matches do
			m = m .. matches[i]
			if i ~= #matches then
				m = m .. ", "
			end
		end
		ChatFrame1:AddMessage(m)
	elseif #matches == 1 then 
		e:HighlightText(pos - word:len(), pos)
		e:Insert(matches[1])
		if pos-word:len() == 0 then e:Insert(": ") end
	end
end

-- Hooked on a feeling...
local ctp = ChatEdit_CustomTabPressed
function ChatEdit_CustomTabPressed()
	CompleteTab()
	ctp()
end

-- Ugly, but what to do to be user friendly.
SlashCmdList["AMNTAB"] = function(cmd)
	if cmd == "friends" then 
		showOffline["friends"] = not showOffline["friends"]
		AmnTabDB.friends = showOffline["friends"]
		local visibility
		if showOffline["friends"] then visibility = "e6cc80shown" else visibility = "ff0000hidden" end
		ChatFrame1:AddMessage(string.format("|cff33ff99AmnTab|r: Offline friends are now |cff%s|r.", visibility))
	elseif cmd == "guild" then
		showOffline["guild"] = not showOffline["guild"]
		AmnTabDB.guild = showOffline["guild"]
		local visibility
		if showOffline["guild"] then visibility = "e6cc80shown" else visibility = "ff0000hidden" end
		ChatFrame1:AddMessage(string.format("|cff33ff99AmnTab|r: Offline guild members are now |cff%s|r.", visibility))
	else
		local visibility
		ChatFrame1:AddMessage"|cff33ff99AmnTab|r: /amntab"
		if showOffline["guild"] then visibility = "e6cc80Shown" else visibility = "ff0000Hidden" end
		ChatFrame1:AddMessage(string.format("- |cff33ff99guild|r: Toggles between showing offline guild members. [|cff%s|r]", visibility))
		if showOffline["friends"] then visibility = "e6cc80Shown" else visibility = "ff0000Hidden" end
		ChatFrame1:AddMessage(string.format("- |cff33ff99friends|r: Toggles between showing offline friends. [|cff%s|r]", visibility))
	end
end
SLASH_AMNTAB1 = "/amntab"
