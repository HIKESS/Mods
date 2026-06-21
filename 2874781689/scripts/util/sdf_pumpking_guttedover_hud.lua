local SDFPumpkingGuttedOverWidget = require "util/sdf_pumpking_guttedover_widget"

AddClassPostConstruct("screens/playerhud", function(playerhud)
    playerhud.CloseSDFPumpkingGuttedOverScreen = function(self)
	if self.SDFPumpkingGuttedOver then
	    if self.SDFPumpkingGuttedOver.inst:IsValid() then
		GLOBAL.TheFrontEnd:PopScreen(self.SDFPumpkingGuttedOver)
	    end
	    self.SDFPumpkingGuttedOver = nil
	end

    end
	
    playerhud.OpenSDFPumpkingGuttedOverScreen = function(self)
	self:CloseSDFPumpkingGuttedOverScreen()
	self.SDFPumpkingGuttedOver = self.overlayroot:AddChild(SDFPumpkingGuttedOverWidget(self.owner))
		
	return true
    end
end)