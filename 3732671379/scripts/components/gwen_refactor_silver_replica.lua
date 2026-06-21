local gwen_refactor_silver = Class(function(self, inst)
    self.inst = inst
    self.current_gw_Silver = net_ushortint(inst.GUID, "gwen_refactor_silver.gw_Silver")
end)

function gwen_refactor_silver:Setgw_Silver(gw_Silver)
    if self.current_gw_Silver ~= nil then
        self.current_gw_Silver:set(gw_Silver)
    end
end

function gwen_refactor_silver:Getgw_Silver()
    if self.inst.components.gwen_refactor_silver ~= nil then
        return self.inst.components.gwen_refactor_silver.gw_Silver
    elseif self.current_gw_Silver ~= nil then
        return self.current_gw_Silver:value()
    else
        return 0
    end
end

return gwen_refactor_silver