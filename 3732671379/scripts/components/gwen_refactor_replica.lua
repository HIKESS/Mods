local gwen_refactor = Class(function(self, inst)
    self.inst = inst
	self.current_gw_Permanent = net_ushortint(inst.GUID, "gwen_refactor.gw_Permanent")

end)

function gwen_refactor:Setgw_Permanent(gw_Permanent)
    if self.current_gw_Permanent ~= nil then
        self.current_gw_Permanent:set(gw_Permanent)
    end
end

function gwen_refactor:Getgw_Permanent()
    if self.inst.components.gwen_refactor ~= nil then
        return self.inst.components.gwen_refactor.gw_Permanent
    elseif self.current_gw_Permanent ~= nil then
        return self.current_gw_Permanent:value()
    else
        return 0
    end
end

return gwen_refactor