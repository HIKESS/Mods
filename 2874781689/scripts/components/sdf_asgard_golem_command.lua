local SDFAsgard_Golem_Command = Class(function(self, inst)
    self.inst = inst
    self.stay = true
    self.locations = {}
    self.inst:StartUpdatingComponent(self)

    self.inst:DoTaskInTime(0.1, function()
	self.inst.components.sdf_asgard_golem_command:SetCurrentPos()

	if self.stay == true then
	    self.inst:AddTag("sdf_asgard_golem_command_stay")
	else
	    self.inst:AddTag("sdf_asgard_golem_command_follow")
	end

    end)

    inst:AddComponent("sdf_asgard_golem_tactics")
    --inst.components.sdf_asgard_golem_tactics.turnonfn  = function() self:Follow() end
    inst.components.sdf_asgard_golem_tactics.turnofffn = function() self:Stay() end
    inst.components.sdf_asgard_golem_tactics.cooldowntime = 0
    inst.components.sdf_asgard_golem_tactics.ison = true

    inst:ListenForEvent("stopfollowing", self.onStopfollowing)
end)

function SDFAsgard_Golem_Command.onStopfollowing(inst)
    inst.components.sdf_asgard_golem_command:SetCurrentPos()
end

function SDFAsgard_Golem_Command:RemoveLeader()
    self.inst:InterruptBufferedAction()
    self.inst:ClearBufferedAction()
    local leader = self.inst.components.follower.leader
    if leader then
	leader.components.leader:RemoveFollower(self.inst)
    end
end

function SDFAsgard_Golem_Command:GetNewLeader(ocarina)
    self:RemoveLeader()
    self.inst.components.follower:SetLeader(ocarina)
end

function SDFAsgard_Golem_Command:Follow(ocarina)
    if self.inst.components.inventoryitem.owner == nil then
	self.inst:RestartBrain()
	self:GetNewLeader(ocarina)
   end

   self:SetStaying(false)
end

function SDFAsgard_Golem_Command:SummonFollow(soulbound)
    self.inst:RestartBrain()
    self:GetNewLeader(soulbound)

   self:SetStaying(false)
end

function SDFAsgard_Golem_Command:Stay()
    self:RemoveLeader()

    self:RememberSitPos("currentstaylocation", Point(self.inst.Transform:GetWorldPosition())) 
    self:SetStaying(true)
end

function SDFAsgard_Golem_Command:OnUpdate()
    if self.inst.components.follower and self.inst.components.follower.leader then
	if not self.inst.components.sdf_asgard_golem_command:IsCurrentlyStaying() then
	    if self.inst.components.sdf_asgard_golem_unteleportable then
		self.inst:RemoveComponent("sdf_asgard_golem_unteleportable") 
	    end
	else
	    if not self.inst.components.sdf_asgard_golem_unteleportable then
		self.inst:AddComponent("sdf_asgard_golem_unteleportable") 
	    end
	end
    end
end

function SDFAsgard_Golem_Command:IsCurrentlyStaying()
    return self.stay
end

function SDFAsgard_Golem_Command:SetStaying(stay)
    self.stay = stay
    self.inst.components.sdf_asgard_golem_tactics.ison = not stay
end

function SDFAsgard_Golem_Command:RememberSitPos(name, pos)
    self.locations[name] = pos
end

function SDFAsgard_Golem_Command:SetCurrentPos()
    self:RememberSitPos("currentstaylocation", Point(self.inst.Transform:GetWorldPosition())) 
end

function SDFAsgard_Golem_Command:OnSave()
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
   
function SDFAsgard_Golem_Command:OnLoad(data)
    if data and data.stay then 
	self.stay = data.stay
	self:SetStaying(data.stay)
	self.locations["currentstaylocation"] = Point(data.varx, data.vary, data.varz)	
    end
end
   
return SDFAsgard_Golem_Command