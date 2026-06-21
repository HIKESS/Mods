local function TextEditConstruct(inst)
	local _SetEditing = inst.SetEditing
	function inst:SetEditing(editing)
		if not GLOBAL.TheNet:IsDedicated() then
			if GLOBAL.ThePlayer then
		    		GLOBAL.ThePlayer:PushEvent( "gamepaused", editing )
			end
		end
		_SetEditing(self, editing)
	end
	local _OnDestroy = inst.OnDestroy
	function inst:OnDestroy()
		if not GLOBAL.TheNet:IsDedicated() then
			if GLOBAL.ThePlayer then
		    		GLOBAL.ThePlayer:PushEvent( "gamepaused", false )
			end
		end
		_OnDestroy(self)
	end
	return inst
end
AddClassPostConstruct("widgets/textedit", TextEditConstruct)
