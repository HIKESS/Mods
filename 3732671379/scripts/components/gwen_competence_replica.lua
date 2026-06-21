local gwen_competence = Class(function(self, inst)
    self.inst = inst
	self.current_gwen_Level = net_ushortint(inst.GUID, "gwen_competence.gwen_Level")
	self.current_gwen_Exp = net_ushortint(inst.GUID, "gwen_competence.gwen_Exp")

end)

function gwen_competence:Setgwen_Level(gwen_Level)
    if self.current_gwen_Level ~= nil then
        self.current_gwen_Level:set(gwen_Level)
    end
end

function gwen_competence:Get_gwen_Level()
    if self.inst.components.gwen_competence ~= nil then
        return self.inst.components.gwen_competence.gwen_Level
    elseif self.current_gwen_Level ~= nil then
        return self.current_gwen_Level:value()
    else
        return 1
    end
end

function gwen_competence:Setgwen_Exp(gwen_Exp)
    if self.current_gwen_Exp ~= nil then
        self.current_gwen_Exp:set(gwen_Exp)
    end
end

function gwen_competence:Get_gwen_Exp()
    if self.inst.components.gwen_competence ~= nil then
        return self.inst.components.gwen_competence.gwen_Exp
    elseif self.current_gwen_Exp ~= nil then
        return self.current_gwen_Exp:value()
    else
        return 0
    end
end

return gwen_competence