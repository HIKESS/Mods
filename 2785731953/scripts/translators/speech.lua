local function Split(str, separator)
  	local fields = {}
	local chr = 1
	
	str = str..separator
	for i = 1, #str do
		if str:sub(i, i) == separator then
			table.insert(fields, str:sub(chr, i - 1))
			chr = i + 1
		end
	end
	
	return fields
end

--[[local function isChar(x)
	return (x>='a' and x<='z') or (x>='A' and x<='Z') or (x>='0' and x<='9')
end--]]

local function isAcceptableAfterNick(x)
	return (x==' ') or (x==',' ) or (x=='.') or (x=='!')  or (x=='?') or (x=='\'')
end

local function translateFromDictionary(s)
	if s == nil then
		return ""
	end
	
	local gender = Genderer.GetGender(GLOBAL.ThePlayer)
	
	if TheDictionary.HasTranslation(s) then
		return Genderer.SubGender(TheDictionary.GetTranslation(s), gender)
	end
	
	local colon = s:find(":")
	if colon and colon == #s then
		local word = s:sub(1, -2)
		return TheDictionary.GetTranslation(word)..":"
	end
	
	--// Try to find a counter (x1, x2, ...) to determine what to do.
	local x_start, _ = s:find("%dx ") --// Search for an "x" with a number before it and a space after it.
	if x_start then
		local new_list = ""
		local ingredients = s:split(",")
		for i, ing in ipairs(ingredients) do
			local amount_start = i == 1 and 1 or 2
			local amount = ing:sub(amount_start, amount_start + 2)
			local ingredient = ing:sub(amount_start + 3,  i == #ingredients and -2 or -1)
			
			new_list = new_list..(i == 1 and "" or ", ")..amount..TheDictionary.GetTranslation(ingredient)
		end
		
		return new_list.."."
	end
	
	--// To be frank, these are very much band-aid fixes. If at any point any of the strings I'm looking for change, they'll break.
	--// This also means that any strings containing these get altered, but that's less concerning, since colons are rare and the translations
	--   included are pretty much universal.
	--// Either way, I don't believe there is a better way of doing this as of now...
	local caught_start, caught_end = s:find("Caught by: ")
	if caught_start and caught_end then
		local donor = s:sub(caught_end + 1)
		return "Pego por: "..TheDictionary.GetTranslation(donor)
	end
	
	local map_start, map_end = s:find("Mapped")
	if map_start and map_start == 1 and map_end then
		local new_s = s:gsub(" in the caves", STRINGS.MAPRECORDER.LOCATION.CAVE)
		local by_start, by_end = new_s:find("by")
		local onday_start, onday_end = new_s:find("on day")
		if by_start and by_end and onday_start and onday_end then
			local location = by_start - map_end > 2 and new_s:sub(map_end + 2, by_start - 2) or ""
			local author = new_s:sub(by_end + 2, onday_start - 2)
			local day = new_s:sub(onday_end + 2, -2)
			
			return GLOBAL.subfmt(STRINGS.MAPRECORDER.MAPDESC, { location = location, author = author, day = day })
		end
	end
	
	local subs_s = s
	for k, v in pairs(TheDictionary.SPEECH.REPLACE) do
		subs_s = subs_s:gsub(k, v)
	end
	
	if subs_s ~= s then
		return Genderer.SubGender(subs_s, gender)
	end

	--// Searching for strings that use %s.
	local n = s:len()
	local ret, nickLen = nil, n+1
	for i = 1, n do
		if i == 1 or s:sub(i-1, i-1) == " " then
			for j = math.min(n, i + nickLen - 2), i, -1 do
				if j == n or isAcceptableAfterNick(s:sub(j+1,j+1)) then
					-- napis [i,j] moze byc nickiem gracza
					local x = s:sub(1,i-1).."%s"..s:sub(j+1)
--					print("x1=", x)
--					print("x2=", x) ;
					if TheDictionary.HasTranslation(x) then
--						print("cand=", x)
						x = TheDictionary.GetTranslation(x):gsub("%%s", s:sub(i,j))
						if j-i+1 < nickLen then
							nickLen = j-i+1
							ret = x
						end
					end
				end
			end
		end
	end
	
	if ret == nil then
		-- // Searching for strings that use two %s.
		ret, nickLen = nil, n+1
		for i=1,n do
			if i==1 or s:sub(i-1,i-1)==' ' then
				for j = math.min(n,i+nickLen-2),i,-1 do
					if j==n or isAcceptableAfterNick(s:sub(j+1,j+1)) then
						-- napis [i,j] moze byc nickiem gracza
						for k=j+2,n do
							if s:sub(k-1,k-1)== ' ' then
								for l=k,n do
									if l==n or isAcceptableAfterNick(s:sub(l+1,l+1)) then
										-- napis [k,l] moze byc atakujacym
										local x = s:sub(1,i-1).."%s"..s:sub(j+1,k-1).."%s"..s:sub(l+1)
	--									print("x1=", x)
	--									print("x2=", x) ;
										if TheDictionary.HasTranslation(x) then
	--										print("cand=", x)
											local attacker = s:sub(k,l)
											attacker = TheDictionary.GetTranslation(attacker)
											x = TheDictionary.GetTranslation(x)
											x = x:gsub("%%s", s:sub(i,j), 1)
											x = x:gsub("%%s", attacker)
											if j-i+1 < nickLen then
												nickLen = j-i+1
												ret = x
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
	
	return ret and Genderer.SubGender(ret, gender) or s
end


function translateMessage(message)
	local messages = Split(message, "\n") or { message }
	local ret = ""
	for i = 1, #messages do
		local translated = translateFromDictionary(messages[i])
				
		if i == 1 then
			ret = translated
		elseif translated ~= messages[i] then
			ret = ret.."\n"..translated
		else
			ret = ret..translateFromDictionary("\n"..messages[i])
		end
	end
	return ret
end

local OldNetworking_Talk = GLOBAL.Networking_Talk
local function Networking_Talk(guid, message, ...)
	message = translateMessage(message)
	OldNetworking_Talk(guid, message, ...)
	
	return message
end

--[[
local oldNetworking_Say = GLOBAL.Networking_Say
local function Networking_Say(guid, userid, name, prefab, message, ...)
	message = SubGender(message, GetGender(GLOBAL.ThePlayer))
	oldNetworking_Say(guid, userid, name, prefab, message, ...)
end
]]

local oldChatHistory_OnChatterMesage = GLOBAL.ChatHistory.OnChatterMessage
local function ChatHistory_OnChatterMessage(self, inst, name_colour, message, ...)
	message = Genderer.SubGender(message, 0)
	oldChatHistory_OnChatterMesage(self, inst, name_colour, message, ...)
end

---------------------------------------------------
--// Save Variables
---------------------------------------------------
GLOBAL.Networking_Talk = Networking_Talk
GLOBAL.ChatHistory.OnChatterMessage = ChatHistory_OnChatterMessage

if not GLOBAL.TheNet:GetIsClient() and GLOBAL.TheNet:GetIsMasterSimulation() then
	--// This is made to prevent strings from looking broken when playing in a singleplayer world or without caves,
	--   since Networking_Talk doesn't work in this case.
	AddClassPostConstruct("components/talker", function(self)
		local oldTalkerSay = self.Say
		function self:Say(script, ...)
			script = Genderer.SubGender(script, 0)
				
			oldTalkerSay(self, script, ...)
		end
	end)
end