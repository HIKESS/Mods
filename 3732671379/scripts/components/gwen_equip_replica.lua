local gwen_equip = Class(function(self, inst)
    self.inst = inst
	self.current_gw_Level = net_ushortint(inst.GUID, "gwen_equip.gw_Level")
	self.current_gw_refactor = net_ushortint(inst.GUID, "gwen_equip.gw_refactor")
	self.current_gw_alchemy = net_ushortint(inst.GUID, "gwen_equip.gw_alchemy")

end)

------------------------------------------------------
function gwen_equip:Setgw_Level(gw_Level)
    if self.current_gw_Level ~= nil then
        self.current_gw_Level:set(gw_Level)
    end
end


function gwen_equip:Getgw_Level()
    if self.inst.components.gwen_equip ~= nil then
        return self.inst.components.gwen_equip.gw_Level
    elseif self.current_gw_Level ~= nil then
        return self.current_gw_Level:value()
    else
        return 0
    end
end

----重构--------------------------------------------------
function gwen_equip:Setgw_refactor(gw_refactor)
    if self.current_gw_refactor ~= nil then
        self.current_gw_refactor:set(gw_refactor)
    end
end


function gwen_equip:Getgw_refactor()
    if self.inst.components.gwen_equip ~= nil then
        return self.inst.components.gwen_equip.gw_refactor
    elseif self.current_gw_refactor ~= nil then
        return self.current_gw_refactor:value()
    else
        return 0
    end
end

----炼金--------------------------------------------------
function gwen_equip:Setgw_alchemy(gw_alchemy)
    if self.current_gw_alchemy ~= nil then
        self.current_gw_alchemy:set(gw_alchemy)
    end
end

function gwen_equip:Getgw_alchemy()
    if self.inst.components.gwen_equip ~= nil then
        return self.inst.components.gwen_equip.gw_alchemy
    elseif self.current_gw_alchemy ~= nil then
        return self.current_gw_alchemy:value()
    else
        return 0
    end
end

return gwen_equip