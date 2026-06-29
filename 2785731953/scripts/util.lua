--------------------------------------------------------------------------------------------

function DevDebugMessage(message)
	print(message)
	
	if GLOBAL.TheWorld == nil and not CONFIG.DEVMODE then
		return
	end
	
	GLOBAL.ChatHistory:AddToHistory(GLOBAL.ChatTypes.Message, nil, nil, "(Tradução Br)", message, {255/255, 255/255, 255/255, 1}, nil, false, true)
end

--------------------------------------------------------------------------------------------

function GetPlayerWithName(name)
	local players = GLOBAL.GetPlayerClientTable()
	for _, player in ipairs(players) do
		if player.name == name then
			return player
		end
	end
	
	return nil
end

function FindPlayerNameInString(str)
	local players = GLOBAL.GetPlayerClientTable()
	for _, player in ipairs(players) do
		local s, e = str:find(player.name)
		return s, e
	end
	
	return nil, nil
end