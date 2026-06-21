local function ChatPostConstruct(inst)
	function inst:OnBecomeActive()
		if not GLOBAL.TheNet:IsDedicated() then
			if GLOBAL.ThePlayer ~= nil then
		    		GLOBAL.ThePlayer:PushEvent( "gamepaused", true )
			end
		end
		inst._base.OnBecomeActive(inst)
		inst.chat_edit:SetFocus()
		inst.chat_edit:SetEditing(true)
		GLOBAL.TheFrontEnd:LockFocus(true)
	end
	function inst:OnBecomeInactive()
		if not GLOBAL.TheNet:IsDedicated() then
			if GLOBAL.ThePlayer ~= nil then
		    		GLOBAL.ThePlayer:PushEvent( "gamepaused", false )
			end
		end
    		inst._base.OnBecomeInactive(inst)
		if inst.runtask ~= nil then
        		inst.runtask:Cancel()
        		inst.runtask = nil
    		end
	end
	return inst
end
AddClassPostConstruct("screens/chatinputscreen", ChatPostConstruct)
