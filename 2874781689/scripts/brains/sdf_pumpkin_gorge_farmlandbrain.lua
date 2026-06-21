--require "behaviours/controlminions"
require "behaviours/sdf_pumpkin_gorge_control_farmland_debris"
require "behaviours/standstill"

local SDFPumpkin_Gorge_FarmlandBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function SDFPumpkin_Gorge_FarmlandBrain:OnStart()
    local root = PriorityNode(
    {
        SDFPumpkin_Gorge_Control_Farmland_Debris(self.inst),
        --StandStill(self.inst),
    }, .25)

    self.bt = BT(self.inst, root)
end

return SDFPumpkin_Gorge_FarmlandBrain