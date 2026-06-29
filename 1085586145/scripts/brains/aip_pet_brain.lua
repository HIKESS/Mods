require "behaviours/wander"

local MIN_FOLLOW_DIST=0.1
local TARGET_FOLLOW_DIST=3
local MAX_FOLLOW_DIST=8

local PetBrain=Class(Brain,function(self,inst)
Brain._ctor(self,inst)

end)

function PetBrain:OnStop()
end

function PetBrain:OnStart()
local root=PriorityNode({

Follow(self.inst,function()
local owner=aipGet(self.inst,"components|aipc_petable|owner")

return owner
end,MIN_FOLLOW_DIST,TARGET_FOLLOW_DIST,MAX_FOLLOW_DIST,

self.inst._aipCanRun
),


Wander(self.inst,function()
local owner=aipGet(self.inst,"components|aipc_petable|owner")
return owner~=nil and owner:GetPosition() or nil
end,MAX_FOLLOW_DIST),
},.25)

self.bt=BT(self.inst,root)
end

return PetBrain