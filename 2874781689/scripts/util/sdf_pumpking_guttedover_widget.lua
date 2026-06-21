local SDFPumpkingGuttedOverSplat = require "widgets/sdf_pumpking_guttedover_splat"
local Widget = require "widgets/widget"

local SDFPumpkingGuttedOverWidget =  Class(Widget, function(self, owner)
    self.owner = owner
    Widget._ctor(self, "SDFPumpkingGuttedOverWidget")

    self.SDFPumpkingGuttedOverWidget = self:AddChild(SDFPumpkingGuttedOverSplat(owner))
    self.SDFPumpkingGuttedOverWidget2 = self:AddChild(SDFPumpkingGuttedOverSplat(owner))

    TheFrontEnd:GetSound():PlaySound("hookline/creatures/squid/ink")

    local time1 = GetTime() - self.SDFPumpkingGuttedOverWidget.time
    local time2 = GetTime() - self.SDFPumpkingGuttedOverWidget2.time
    if time1 > 2 then
        time1 = nil
    end
    if time2 > 2 then
        time2 = nil
    end

    if time1 and time2 then
        if time1 < time2 then
            self.SDFPumpkingGuttedOverWidget2:Flash("ink2")
        else
            self.SDFPumpkingGuttedOverWidget:Flash("ink")
        end
    else
        if time1 then
            self.SDFPumpkingGuttedOverWidget2:Flash("ink2")
        elseif time2 then
            self.SDFPumpkingGuttedOverWidget:Flash("ink")
        else
            if math.random() < 0.5 then
                self.SDFPumpkingGuttedOverWidget:Flash("ink")
            else
                self.SDFPumpkingGuttedOverWidget2:Flash("ink2")
            end
        end
    end

end)

return SDFPumpkingGuttedOverWidget
