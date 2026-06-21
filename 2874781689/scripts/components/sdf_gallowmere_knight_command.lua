local SDFGallowmere_Knight_Command = Class(function(self, inst)
    self.inst = inst
    self.stay = true
    self.stance = ("swap_"..TUNING.SDF_GALLOWMERE_KNIGHT_SHIELD.."")
    self.locations = {}
    self.inst:StartUpdatingComponent(self)

    self.inst:DoTaskInTime(0.1, function()
	self.inst.components.sdf_gallowmere_knight_command:SetCurrentPos()

	if self.stay == true then
	    self.inst:AddTag("sdf_gallowmere_knight_command_stay")
	else
	    self.inst:AddTag("sdf_gallowmere_knight_command_follow")
	end

    end)

    inst:AddComponent("sdf_gallowmere_knight_tactics")
    --inst.components.sdf_gallowmere_knight_tactics.turnonfn  = function() self:Follow() end
    inst.components.sdf_gallowmere_knight_tactics.turnofffn = function() self:Stay() end
    inst.components.sdf_gallowmere_knight_tactics.cooldowntime = 0
    inst.components.sdf_gallowmere_knight_tactics.ison = true

    inst:ListenForEvent("stopfollowing", self.onStopfollowing)
end)

function SDFGallowmere_Knight_Command.onStopfollowing(inst)
    inst.components.sdf_gallowmere_knight_command:SetCurrentPos()
end

function SDFGallowmere_Knight_Command:RemoveLeader()
    self.inst:InterruptBufferedAction()
    self.inst:ClearBufferedAction()
    local leader = self.inst.components.follower.leader
    if leader then
	leader.components.leader:RemoveFollower(self.inst)
    end
end

function SDFGallowmere_Knight_Command:GetNewLeader(sdf)
    self:RemoveLeader()
    --local player = GetClosestInstWithTag("player",self.inst,6)
    self.inst.components.follower:SetLeader(sdf)
end

function SDFGallowmere_Knight_Command:AnubisStoneGetNewLeader(player)
    self:RemoveLeader()
    self.inst.components.follower:SetLeader(player)
end

function SDFGallowmere_Knight_Command:Follow(sdf)
    --self.inst.components.follower:EnableLeashing()

    if self.inst.components.inventoryitem.owner == nil then
	self.inst:RestartBrain()
	self:GetNewLeader(sdf)
	self.inst:DoTaskInTime(0.5, function()
	    self.inst.sg:GoToState("talk")
	    self.inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_GALLOWMERE_KNIGHT_RECRUIT, 5)
	end)
   else
	self.inst.sg:GoToState("talk")
	self.inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_GALLOWMERE_KNIGHT_FOLLOW[math.random(#STRINGS.ANNOUNCE_SDF_GALLOWMERE_KNIGHT_FOLLOW)], 5)
   end
   self:SetStance("swap_"..TUNING.SDF_GALLOWMERE_KNIGHT_WEAPON.."")
   self:SetStaying(false)
end

function SDFGallowmere_Knight_Command:Stay()
    self:RemoveLeader()
    --self.inst.components.follower:DisableLeashing()

    self.inst.sg:GoToState("talk")
    self.inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_GALLOWMERE_KNIGHT_STAY[math.random(#STRINGS.ANNOUNCE_SDF_GALLOWMERE_KNIGHT_STAY)], 5)
    self:RememberSitPos("currentstaylocation", Point(self.inst.Transform:GetWorldPosition())) 
    self:SetStance("swap_"..TUNING.SDF_GALLOWMERE_KNIGHT_SHIELD.."")
    self:SetStaying(true)
end

function SDFGallowmere_Knight_Command:OnUpdate()
    if self.inst.components.follower and self.inst.components.follower.leader then
	if not self.inst.components.sdf_gallowmere_knight_command:IsCurrentlyStaying() then
	    if self.inst.components.sdf_gallowmere_knight_unteleportable then
		self.inst:RemoveComponent("sdf_gallowmere_knight_unteleportable") 
	    end
	else
	    if not self.inst.components.sdf_gallowmere_knight_unteleportable then
		self.inst:AddComponent("sdf_gallowmere_knight_unteleportable") 
	    end
	end
    end
end

function SDFGallowmere_Knight_Command:IsCurrentlyStaying()
    return self.stay
end

function SDFGallowmere_Knight_Command:CurrentStance()
    return self.stance
end

function SDFGallowmere_Knight_Command:SetStaying(stay)
    self.inst.components.follower:DisableLeashing()
    self.stay = stay
    self.inst.components.sdf_gallowmere_knight_tactics.ison = not stay
end

function SDFGallowmere_Knight_Command:SetStance(equipment)
    self.stance = equipment
end

function SDFGallowmere_Knight_Command:RememberSitPos(name, pos)
    self.locations[name] = pos
end

function SDFGallowmere_Knight_Command:SetCurrentPos()
    self:RememberSitPos("currentstaylocation", Point(self.inst.Transform:GetWorldPosition())) 
end

function SDFGallowmere_Knight_Command:AnubisStoneFollow(player)
    if self.inst.components.inventoryitem.owner == nil then
	self.inst:RestartBrain()
	self:AnubisStoneGetNewLeader(player)
	self.inst:DoTaskInTime(0.5, function()
	    self.inst.sg:GoToState("talk")
	    self.inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_GALLOWMERE_KNIGHT_RECRUIT, 5)
	end)
   else
	self.inst.sg:GoToState("talk")
	self.inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_GALLOWMERE_KNIGHT_FOLLOW[math.random(#STRINGS.ANNOUNCE_SDF_GALLOWMERE_KNIGHT_FOLLOW)], 5)
   end
   self:SetStance("swap_"..TUNING.SDF_GALLOWMERE_KNIGHT_WEAPON.."")
   self:SetStaying(false)
end

function SDFGallowmere_Knight_Command:CallToArms()
    self.inst:InterruptBufferedAction()
    self.inst:ClearBufferedAction()
    self.inst:RestartBrain()

    self.inst.sg:GoToState("talk")
    self.inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_GALLOWMERE_KNIGHT_CALLTOARMS, 5)
    self:RememberSitPos("currentstaylocation", Point(self.inst.Transform:GetWorldPosition())) 
    self:SetStaying(true)
    self:SetStance("swap_"..TUNING.SDF_GALLOWMERE_KNIGHT_SHIELD.."")
end

function SDFGallowmere_Knight_Command:OnSave()
    if self.stay == true then
	local data = 
	{ 
	    stay = self.stay,
	    varx = self.locations["currentstaylocation"].x, 
	    vary = self.locations["currentstaylocation"].y, 
	    varz = self.locations["currentstaylocation"].z
	}
	return data
    end
end   
   
function SDFGallowmere_Knight_Command:OnLoad(data)
    if data and data.stay then 
	self.stay = data.stay
	self:SetStaying(data.stay)
	self.locations["currentstaylocation"] = Point(data.varx, data.vary, data.varz)	
    end
end
   
return SDFGallowmere_Knight_Command