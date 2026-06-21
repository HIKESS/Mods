local function fuZ3z86(yxjl)
    if yxjl.targetTeleporter~=nil and yxjl.enabled==true then 
	yxjl.inst:AddTag("sdf_pumpkin_gorge_well_teleporter")
    else 
	yxjl.inst:RemoveTag("sdf_pumpkin_gorge_well_teleporter")
    end
end;

local SDFPumpkin_Gorge_Well_Teleporter=Class(function(self,inst)
    self.inst=inst;
    self.targetTeleporter=nil;
    self.onActivate=nil;
    self.onActivateByOther=nil;
    self.offset=2;
    self.enabled=true;
    self.numteleporting=0;
    self.teleportees={}
    self.saveenabled=true;
    self.travelcameratime=3;
    self.travelarrivetime=4;
    self._onremoveteleportee=function(q)
	self:UnregisterTeleportee(q)
    end
end,
nil,
{
    targetTeleporter=fuZ3z86,
    enabled=fuZ3z86
})

    function SDFPumpkin_Gorge_Well_Teleporter:OnRemoveFromEntity()
	self.inst:RemoveTag("sdf_pumpkin_gorge_well_teleporter")
    end;

    function SDFPumpkin_Gorge_Well_Teleporter:IsActive()
	return self.enabled and self.targetTeleporter~=nil
    end;

    function SDFPumpkin_Gorge_Well_Teleporter:IsBusy()
	return self.numteleporting>0 or next(self.teleportees)~=nil
    end;

    function SDFPumpkin_Gorge_Well_Teleporter:IsTargetBusy()
	return self.targetTeleporter~=nil and self.targetTeleporter.components.sdf_pumpkin_gorge_well_teleporter:IsBusy()
    end;

    function SDFPumpkin_Gorge_Well_Teleporter:RegisterTeleportee(kP7O5)
	if not self.teleportees[kP7O5]then
	    self.teleportees[kP7O5]=true;
	    self.inst:ListenForEvent("onremove",self._onremoveteleportee,kP7O5)
	end
    end

    function SDFPumpkin_Gorge_Well_Teleporter:UnregisterTeleportee(lqT)
	if self.teleportees[lqT]then
	    self.teleportees[lqT]=nil;
	    self.inst:RemoveEventCallback("onremove",self._onremoveteleportee,lqT)
	end
    end;

    function SDFPumpkin_Gorge_Well_Teleporter:Activate(mP3mlD)
	if not self:IsActive()then
	    return false
	end;
	if self.onActivate~=nil then
	    self.onActivate(self.inst,mP3mlD)
	end;
	if self.targetTeleporter.components.sdf_pumpkin_gorge_well_teleporter~=nil then
	    if self.targetTeleporter.components.sdf_pumpkin_gorge_well_teleporter.onActivateByOther~=nil then
		self.targetTeleporter.components.sdf_pumpkin_gorge_well_teleporter.onActivateByOther(self.targetTeleporter,self.inst,mP3mlD)
	    end;
	    self.targetTeleporter.components.sdf_pumpkin_gorge_well_teleporter.numteleporting=self.targetTeleporter.components.sdf_pumpkin_gorge_well_teleporter.numteleporting+1
	end;
	self:Teleport(mP3mlD)
	if self.targetTeleporter.components.sdf_pumpkin_gorge_well_teleporter~=nil then
	    if mP3mlD:HasTag("player")then
		self.targetTeleporter.components.sdf_pumpkin_gorge_well_teleporter:ReceivePlayer(mP3mlD)
	    elseif mP3mlD.components.inventoryitem~=nil then
		self.targetTeleporter.components.sdf_pumpkin_gorge_well_teleporter:ReceiveItem(mP3mlD)
	    end
	end;
	if mP3mlD.components.leader~=nil then
	    for PrPyxMK,tczrIB in pairs(mP3mlD.components.leader.followers)do
		self:Teleport(PrPyxMK)
	    end
	end;
	if mP3mlD.components.inventory~=nil then
	    for a,wqU76o in pairs(mP3mlD.components.inventory.itemslots)do
		if wqU76o.components.leader~=nil then
		    for LB1Z,N9L in pairs(wqU76o.components.leader.followers)do
			self:Teleport(LB1Z)
		    end
		end
	    end;
	    for hDc_M,qW0lRiD1 in pairs(mP3mlD.components.inventory.equipslots)do
		if qW0lRiD1.components.container~=nil then
		    for iD1IUx,JLCOx_ak in pairs(qW0lRiD1.components.container.slots)do
			if JLCOx_ak.components.leader~=nil then
			    for hPQ,R1FIoQI in pairs(JLCOx_ak.components.leader.followers)do
				self:Teleport(hPQ)
			    end
			end
		    end
		end
	    end
	end;
	return true
    end;

    local function DFb100j(NsoTwDs)
	return not TheWorld.Map:IsPointNearHole(NsoTwDs)
    end;

    local function XL_(HGli)
	return not(IsAnyPlayerInRange(HGli.x,0,HGli.z,2)or TheWorld.Map:IsPointNearHole(HGli))
    end;

    function SDFPumpkin_Gorge_Well_Teleporter:Teleport(iy)
	if self.targetTeleporter~=nil then
	    local m6SCS0,NUhYw6R4,Hv=self.targetTeleporter.Transform:GetWorldPosition()
	    local Ch= self.targetTeleporter.components.sdf_pumpkin_gorge_well_teleporter~=nil and self.targetTeleporter.components.sdf_pumpkin_gorge_well_teleporter.offset or 0;
	    local urkh=iy.components.locomotor~=nil and iy.components.locomotor:IsAquatic()
	    if Ch~=0 then
		local rHSjalVy=Vector3(m6SCS0,NUhYw6R4,Hv)
		local TjhsnP=math.random()*2*PI;
		if not urkh then
		    Ch=FindWalkableOffset(rHSjalVy,TjhsnP,Ch,8,true,false,XL_)or FindWalkableOffset(rHSjalVy,TjhsnP,Ch*.5,6,true,false,XL_)or FindWalkableOffset(rHSjalVy,TjhsnP,Ch,8,true,false,DFb100j)or FindWalkableOffset(rHSjalVy,TjhsnP,Ch*.5,6,true,false,DFb100j)
		else
		    Ch=FindSwimmableOffset(rHSjalVy,TjhsnP,Ch,8,true,false,XL_)or FindSwimmableOffset(rHSjalVy,TjhsnP,Ch*.5,6,true,false,XL_)or FindSwimmableOffset(rHSjalVy,TjhsnP,Ch,8,true,false,DFb100j)or FindSwimmableOffset(rHSjalVy,TjhsnP,Ch*.5,6,true,false,DFb100j)
		end;
		if Ch~=nil then
		    m6SCS0=m6SCS0+Ch.x;Hv=Hv+Ch.z
		end
	    end
	    local zhzpBSx=TheWorld.Map:IsOceanAtPoint(m6SCS0,NUhYw6R4,Hv,false)
	    if zhzpBSx then
		local t5jzEd9=iy.components.locomotor~=nil and iy.components.locomotor:IsTerrestrial()
		if t5jzEd9 then
		    return
		end
	    else
		if urkh then
		    return
		end
	    end;
	    if iy.Transform~=nil then
		iy.Transform:SetPosition(m6SCS0,NUhYw6R4,Hv)
	    elseif iy.Physics~=nil then
		iy.Physics:Teleport(m6SCS0,NUhYw6R4,Hv)
	    end
	end
    end;

    function SDFPumpkin_Gorge_Well_Teleporter:PushDoneTeleporting(JZAU2)
	self.inst:PushEvent("doneteleporting",JZAU2)
    end

    local function WYdR(zPXTTg,seMLr,qX)
	if qX:IsValid()then
	    zPXTTg:RemoveChild(qX)
	    qX:ReturnToScene()
	    if qX.Transform~=nil then
		local h_8,xL7OTb,w8T3f=qX.Transform:GetWorldPosition()
		local K=math.random()*2*PI;
		if qX.Physics~=nil then
		    qX.Physics:Stop()
		    if qX:IsAsleep()then
			local qL=zPXTTg:GetPhysicsRadius(0)+math.random()
			qX.Physics:Teleport(h_8+math.cos(K)*qL,0,w8T3f-math.sin(K)*qL)
		    else
			local vfIyB=qX.components.inventoryitem~=nil and not qX.components.inventoryitem.nobounce;
			local quNsijN=(vfIyB and 3 or 4)+math.random()*.5+zPXTTg:GetPhysicsRadius(0)
			qX.Physics:Teleport(h_8,0,w8T3f)
			qX.Physics:SetVel(quNsijN*math.cos(K),vfIyB and quNsijN*3 or 0,quNsijN*math.sin(K))
		    end
		else
		    local QUh2tc=2+math.random()*.5;
		    qX.Transform:SetPosition(h_8+math.cos(K)*QUh2tc,0,w8T3f-math.sin(K)*QUh2tc)
		end
	    end
	else
	    qX=nil
	end;
	seMLr.numteleporting=seMLr.numteleporting-1;seMLr:PushDoneTeleporting(qX)
    end;

    function SDFPumpkin_Gorge_Well_Teleporter:ReceiveItem(qboV)
	qboV:RemoveFromScene()
	TemporarilyRemovePhysics(qboV,4.5)
	self.inst:AddChild(qboV)
	self.inst:DoTaskInTime(.5,WYdR,self,qboV)
    end;

    local function QKKks_zt(nSBOx7,u)
	if u:IsValid()then
	    u:SnapCamera()u:ScreenFade(true,0.5)
	end
    end;

    local function Are7xU(K,i1,zz1QI)
	if not zz1QI:IsValid()then
	    zz1QI=nil
	elseif zz1QI.sg.statemem.sdf_pumpkin_gorge_well_teleportarrivestate~=nil then
	    zz1QI.sg:GoToState(zz1QI.sg.statemem.sdf_pumpkin_gorge_well_teleportarrivestate)
	end;
	i1.numteleporting=i1.numteleporting-1;
	i1:PushDoneTeleporting(zz1QI)
    end;

    function SDFPumpkin_Gorge_Well_Teleporter:ReceivePlayer(kFTAh)
	kFTAh:ScreenFade(false)
	self.inst:DoTaskInTime(self.travelcameratime,QKKks_zt,kFTAh)
	self.inst:DoTaskInTime(self.travelarrivetime,Are7xU,self,kFTAh)
    end;

    function SDFPumpkin_Gorge_Well_Teleporter:Target(LBf)
	self.targetTeleporter=LBf
    end;

    function SDFPumpkin_Gorge_Well_Teleporter:SetEnabled(dijn4Ph)
	self.enabled=dijn4Ph
    end;

    function SDFPumpkin_Gorge_Well_Teleporter:OnSave()
	if self.saveenabled and self.targetTeleporter~=nil then
	    return{target=self.targetTeleporter.GUID},{self.targetTeleporter.GUID}
	end
    end;

    function SDFPumpkin_Gorge_Well_Teleporter:LoadPostPass(CO1,RlZo)
	if RlZo~=nil and RlZo.target~=nil then
	    local SUn=CO1[RlZo.target]
	    if SUn~=nil and SUn.entity.components.sdf_pumpkin_gorge_well_teleporter~=nil then
		self.targetTeleporter=SUn.entity
	    end
	end
    end;

    function SDFPumpkin_Gorge_Well_Teleporter:GetDebugString()
	return"Enabled: ".. (self.enabled and"T"or"F").." Target:"..tostring(self.targetTeleporter)
    end;

return SDFPumpkin_Gorge_Well_Teleporter