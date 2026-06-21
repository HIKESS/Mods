--require "behaviours/controlminions"
require "behaviours/sdf_pumpking_control_vines"
require "behaviours/standstill"

local SDFPumpking_GourdBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function SDFPumpking_GourdBrain:OnStart()
    local root = PriorityNode(
    {
        SDFPumpking_Gourd_Control_Vines(self.inst),
        --StandStill(self.inst),
    }, .25)

    self.bt = BT(self.inst, root)
end

return SDFPumpking_GourdBrain