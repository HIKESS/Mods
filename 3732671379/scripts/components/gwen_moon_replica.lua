local gwen_moon = Class(function(self, inst)
    self.inst = inst
	self.current_moon_Level = net_ushortint(inst.GUID, "gwen_moon.moon_Level")
	self.current_mooning = net_ushortint(inst.GUID, "gwen_moon.mooning")

end)

function gwen_moon:Setmoon_Level(moon_Level)
    if self.current_moon_Level ~= nil then
        self.current_moon_Level:set(moon_Level)
    end
end

function gwen_moon:Getmoon_Level()
    if self.inst.components.gwen_moon ~= nil then
        return self.inst.components.gwen_moon.moon_Level
    elseif self.current_moon_Level ~= nil then
        return self.current_moon_Level:value()
    else
        return 0
    end
end

function gwen_moon:Setmooning(mooning)
    if self.current_mooning ~= nil then
        self.current_mooning:set(mooning)
    end
end

function gwen_moon:Getmooning()
    if self.inst.components.gwen_moon ~= nil then
        return self.inst.components.gwen_moon.mooning
    elseif self.current_mooning ~= nil then
        return self.current_mooning:value()
    else
        return 0
    end
end

return gwen_moon