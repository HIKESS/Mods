require "behaviours/standandattack"

local SDFLava_GolemBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function SDFLava_GolemBrain:OnStart()
	
    local root = PriorityNode(
    {
	StandAndAttack(self.inst),
    }, .25)
	
    self.bt = BT(self.inst, root)
end

return SDFLava_GolemBrain
