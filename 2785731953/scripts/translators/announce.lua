--------------------------------------------------------------------------------------------

local STRINGS = GLOBAL.STRINGS
local GetGenderStrings = GLOBAL.GetGenderStrings

--------------------------------------------------------------------------------------------

function GetFormattedPrefabForName(name)
	for prefab, str in pairs(TheDictionary.og_strings.NAMES) do
		if str == name and table.contains(TheDictionary.NAMES.FORMATTED_PREFABS, prefab:lower()) then
			return prefab:lower()
		end
	end
	
	return nil
end

--------------------------------------------------------------------------------------------
--// Death
--------------------------------------------------------------------------------------------
-- Currently not using "gender_list" for player prefabs to help with flexibility.
-- I may or may not, someday, decide to change the genders for "ROBOT" and "DEFAULT".

local oldDeathAnnouncement = GLOBAL.Networking_DeathAnnouncement
local function Networking_DeathAnnouncement(message, ...)
	local separator = TheDictionary.og_strings.UI.HUD.DEATH_ANNOUNCEMENT_1
	local sep_s, sep_e = message:find(separator)
	if sep_s and sep_e then
		local victim = message:sub(1, sep_s - 2)
		local gender = "DEFAULT"
		
		local victim_player = GetPlayerWithName(victim)
		if victim_player then
			gender = GetGenderStrings(victim_player.prefab)
		end
		
		local becameghost = TheDictionary.og_strings.UI.HUD["DEATH_ANNOUNCEMENT_2_"..gender]
		local bg_s, bg_e = message:find(becameghost)
		if bg_s and bg_e then
			local killer = message:sub(sep_e + 2, bg_s - 1)
			separator = TheDictionary.ANNOUNCE.DEATH_ANNOUNCEMENT_1[gender]
			becameghost = TheDictionary.GetTranslation(becameghost)
			
			if not GetPlayerWithName(killer) then
				killer = TheDictionary.GetTranslation(killer)
			end
		
			message = victim.." "..separator.." "..killer..becameghost
		end
	end

	oldDeathAnnouncement(message, ...)
end

GLOBAL.Networking_DeathAnnouncement = Networking_DeathAnnouncement

--------------------------------------------------------------------------------------------
--// Resurrection
--------------------------------------------------------------------------------------------

local oldResurrectAnnouncement = GLOBAL.Networking_ResurrectAnnouncement
local function Networking_ResurrectAnnouncement(message, ...)
	local sep_s, sep_e = message:find(TheDictionary.og_strings.UI.HUD.REZ_ANNOUNCEMENT)
	if sep_s and sep_e then
		local rezzed = message:sub(1, sep_s - 2)
		local reviver = message:sub(sep_e + 2, -2)
		local gender = "DEFAULT"
		
		local rezzed_player = GetPlayerWithName(rezzed)
		if rezzed_player then
			gender = GetGenderStrings(rezzed_player.prefab)
		end
		
		if not GetPlayerWithName(reviver) then
		
			local name_s, name_e = FindPlayerNameInString(reviver)
			if name_s and name_e then
				local reviver_name = reviver:gsub("'s", ""):sub(name_e + 2)
				local reviver_prefab = GetFormattedPrefabForName(reviver_name)
				
				if reviver_prefab then
					local player_name = reviver:sub(name_s, name_e)
					
					reviver = GetFormattedNameTranslation(reviver, reviver_prefab)
				end
			else
				reviver = TheDictionary.GetTranslation(reviver)
			end
		end
				
		message = rezzed.." "..TheDictionary.ANNOUNCE.REZ_ANNOUNCEMENT[gender].." "..reviver.."."
	end

	oldResurrectAnnouncement(message, ...)
end

GLOBAL.Networking_ResurrectAnnouncement = Networking_ResurrectAnnouncement

--------------------------------------------------------------------------------------------
--// Everything Else
--------------------------------------------------------------------------------------------

local oldNetworkingAnnouncement = GLOBAL.Networking_Announcement
local function Networking_Announcement(message, colour, announce_type, ...)
	local direct_translation = TheDictionary.GetTranslation(message)
	if direct_translation == message and announce_type ~= "resurrect" or announce_type ~= "death" then
		for item, replacement in pairs(TheDictionary.ANNOUNCE.REPLACE) do
			local new_message = message:gsub(item, replacement, 1)
			if new_message ~= message then
				message = new_message
				break
			end
		end
	end
	
	oldNetworkingAnnouncement(direct_translation or message, colour, announce_type, ...)
end

GLOBAL.Networking_Announcement = Networking_Announcement
