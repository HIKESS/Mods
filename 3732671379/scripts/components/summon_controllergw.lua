local radian = math.pi/180
local auto=TUNING.TERRAPRISMA_AUTO
local SummonControllerfy = Class(function (self,inst)
    self.inst=inst
    self.player=nil
    self.weapon=nil
    self.status="idle"
    self.start_time=0
    self.follow_time=0
    self.last_hit_time=0
    self.circle_angle=0
    self.cd_time=0
    self.offset=0
    self.circle_angle=0
    self.clockwise=1
end)


function SummonControllerfy:Init(player,offset,weapon,id)
    self.inst:DoTaskInTime(0,function ()
        self.offset=offset
        self.player=player
        self.weapon=weapon
        self.id=id
        local x,_,z = self.player.Transform:GetWorldPosition()
        if TUNING.TERRAPRISMA_CIRCLEFY then
            self.inst.Transform:SetPosition(x,0,z)
        else
            local angle = self.player.Transform:GetRotation()
            local x1=x-math.cos(angle*radian)*(1+self.offset)
            local z1=z+math.sin(angle*radian)*(1+self.offset)
            self.inst.Transform:SetPosition(x1,_,z1)
        end
        self.inst:StartUpdatingComponent(self)
        self.cd_time=GetTime()
    end)
end

function SummonControllerfy:OnUpdate(dt)
    if  self.player==nil or not self.player:IsValid() or
        self.weapon==nil or not self.weapon:IsValid() then
        self.inst:Remove()
        return
    end

    local x,_,z = self.player.Transform:GetWorldPosition()
    if self.status~="idle" and self.status~="follow" then
        if self.target==nil or not self.target:IsValid() or self.target.components.health==nil
        or self.target.components.health:IsDead() then
            self.status="back"
        end
    elseif auto then
        self:FindEnemy(x,z)
    end

    if self.status=="idle" then
        if TUNING.TERRAPRISMA_CIRCLEFY then
            self.follow_time=GetTime()
            self.status="follow"
        else
            local angle = self.player.Transform:GetRotation()
            local x1=x-math.cos(angle*radian)*(1+self.offset)
            local z1=z+math.sin(angle*radian)*(1+self.offset)
            local x2,_,z2=self.inst.Transform:GetWorldPosition()
            if (x2-x1)*(x2-x1)+(z2-z1)*(z2-z1)>=0.2 then
                self.follow_time=GetTime()
                self.status="follow"
            end
        end
    elseif self.status=="follow" then
        if GetTime()>=self.follow_time+0.1 then
            local angle = self.player.Transform:GetRotation()
            local x1=x-math.cos(angle*radian)*(1+self.offset)
            local z1=z+math.sin(angle*radian)*(1+self.offset)
            local x2,_,z2=self.inst.Transform:GetWorldPosition()
            if TUNING.TERRAPRISMA_CIRCLEFY then
                local speed=((z2-self.weapon.components.enemyselectgw.positions[self.id].z)^2+(x2-self.weapon.components.enemyselectgw.positions[self.id].x)^2)*5
                self.inst.Physics:SetMotorVel(speed,0,0)
                self:RotateToTarget(Vector3(self.weapon.components.enemyselectgw.positions[self.id].x,0,self.weapon.components.enemyselectgw.positions[self.id].z))
            else
                self.inst.Physics:SetMotorVel(self.player.components.locomotor:GetRunSpeed(),0,0)
                self:RotateToTarget(Vector3(x1,0,z1))
                if (x2-x1)*(x2-x1)+(z2-z1)*(z2-z1)<=0.1 then
                    self.status="idle"
                    self.inst.Physics:Stop()
                    self.inst.Transform:SetPosition(x1,_,z1)
                end
            end
        end
    elseif self.status=="pre_shoot" then
        local Dt=GetTime()-self.start_time
        local x1,_,z1=self.inst.Transform:GetWorldPosition()
        self.inst.Transform:SetPosition(x1,1,z1)
        if Dt>=math.random()/5 then
            self.status="shoot"
        end
    elseif self.status=="shoot" then
        self.inst.Physics:SetMotorVel(60, 0, 0)
        local dest=self.target:GetPosition()
        self:RotateToTarget(dest)
        local x1,_,z1=self.inst.Transform:GetWorldPosition()
        self.inst.Transform:SetPosition(x1,1,z1)
        if self:CheckHit() then
            self.last_hit_time=GetTime()
            self.circle_angle=self.inst:GetRotation()
            self.clockwise=math.random()>0.5 and 1 or -1
            self.status="circle"
        end
    elseif self.status=="circle" then
        if GetTime()>=self.last_hit_time+0.2 then
            self.inst.Physics:SetMotorVel(15, 0, 0)
            self.circle_angle=self.circle_angle+dt*300*self.clockwise
            if self.circle_angle>180 then
                self.circle_angle=self.circle_angle-360
            elseif self.circle_angle<-180 then
                self.circle_angle=self.circle_angle+360
            end
            self.inst.Transform:SetRotation(self.circle_angle)
            local x1,_,z1 = self.inst.Transform:GetWorldPosition()
            local x2,_,z2 = self.target.Transform:GetWorldPosition()
            local angle=math.atan2(z1-z2,x2-x1)/radian
            if math.abs(angle-self.circle_angle)<=12
            or(angle-self.circle_angle>0 and math.abs(angle-360-self.circle_angle)<=12)
            or(angle-self.circle_angle<0 and math.abs(self.circle_angle-360-angle)<=12) then
                self.status="shoot"
            end
        end
    elseif self.status=="back" then
        if TUNING.TERRAPRISMA_CIRCLEFY then
            if self:CheckBack() then
                self.status="follow"
                self.inst.AnimState:PlayAnimation("idle")
                self.inst.AnimState:SetOrientation( ANIM_ORIENTATION.BillBoard )
                self.inst.Transform:SetPosition(self.weapon.components.enemyselectgw.positions[self.id].x,0,self.weapon.components.enemyselectgw.positions[self.id].z)
                self.inst.Physics:Stop()
                self.cd_time=GetTime()
            else
                local dest=Vector3(self.weapon.components.enemyselectgw.positions[self.id].x,0,self.weapon.components.enemyselectgw.positions[self.id].z)
                self:RotateToTarget(dest)
                local x1,_,z1=self.inst.Transform:GetWorldPosition()
                self.inst.Transform:SetPosition(x1,1,z1)
                if (x1-x)*(x1-x)+(z1-z)*(z1-z)<=16 then
                    self.inst.Physics:SetMotorVel(20,0,0)
                else
                    self.inst.Physics:SetMotorVel(40,0,0)
                end
            end
        else
            if self:CheckBack() then
                self.status="idle"
                self.inst.AnimState:PlayAnimation("idle")
                self.inst.AnimState:SetOrientation(ANIM_ORIENTATION.BillBoard)
                local angle = self.player.Transform:GetRotation()
                local x1=x-math.cos(angle*radian)*(1+self.offset)
                local z1=z+math.sin(angle*radian)*(1+self.offset)
                self.inst.Transform:SetPosition(x1,_,z1)
                self.inst.Physics:Stop()
                self.cd_time=GetTime()
            else
                local dest=self.player:GetPosition()
                self:RotateToTarget(dest)
                local x1,_,z1=self.inst.Transform:GetWorldPosition()
                self.inst.Transform:SetPosition(x1,1,z1)
                if (x1-x)*(x1-x)+(z1-z)*(z1-z)<=16 then
                    self.inst.Physics:SetMotorVel(20,0,0)
                else
                    self.inst.Physics:SetMotorVel(40,0,0)
                end
            end
        end
    end

    local x1,_,z1=self.inst.Transform:GetWorldPosition()
    local sqdistance=(x1-x)*(x1-x)+(z1-z)*(z1-z)
    if sqdistance>=1600 then
        self.status="back"
        if sqdistance>=3600 then
            self.inst.Transform:SetPosition(x,0,z)
        end
    end

end

function SummonControllerfy:Shoot(target)
    if self.status=="idle" or self.status=="follow" then
        if GetTime()<self.cd_time+0.2 then
            return
        end
        self.start_time=GetTime()
        self.target = target
        local facing_angle = (self.player and self.player.Transform:GetRotation()) or 0
        local random = math.random()
		if random < 0.25 then
            self.inst.Transform:SetRotation(facing_angle+90)
        elseif random < 0.5 then
            self.inst.Transform:SetRotation(facing_angle-90)
        elseif random < 0.75 then
            self.inst.Transform:SetRotation(facing_angle+120)
        else
            self.inst.Transform:SetRotation(facing_angle-120)
        end
        self.inst.Physics:SetMotorVel(30, 0, 0)
        self.inst:PushEvent("onshoot", {thrower = self.player, target = self.target})
        self.inst.AnimState:PlayAnimation("shoot")
        self.status="pre_shoot"
    else
        self.target = target
    end
end

function SummonControllerfy:CheckHit()
    local start = self.inst:GetPosition()
	local dest = self.target:GetPosition()
    if start:DistSq(dest)<=6 then
        if self.target.components.combat then
            self.target.components.combat:GetAttacked(self.player, self.inst.components.weapon.damage)
        end
		local x,_,z=self.target.Transform:GetWorldPosition()
		local fx = SpawnPrefab("crab_king_shine")
		fx.Transform:SetPosition(x,_,z)
		--self.inst:Remove()
        return true
    end
end

function SummonControllerfy:CheckBack()
    if TUNING.TERRAPRISMA_CIRCLEFY then
        local x1,_,z1 = self.inst.Transform:GetWorldPosition()
        local x=self.weapon.components.enemyselectgw.positions[self.id].x
        local z=self.weapon.components.enemyselectgw.positions[self.id].z
        if (x1-x)*(x1-x)+(z1-z)*(z1-z)<=6 then
            return true
        end
    else
        local x,_,z = self.player.Transform:GetWorldPosition()
        local x1,_,z1 = self.inst.Transform:GetWorldPosition()
        if (x1-x)*(x1-x)+(z1-z)*(z1-z)<=6 then
            return true
        end
    end
end

function SummonControllerfy:RotateToTarget(dest)
    self.inst:FacePoint(dest)
end

function SummonControllerfy:FindEnemy(x,z)
    local ents = TheSim:FindEntities(x,0,z,16,{"_combat","_health" }, { "playerghost", "INLIMBO", "player","companion","wall" })
    for k, v in pairs(ents) do
        if  v.components.combat and v.components.combat.target==self.player
        and v.components.health and not v.components.health:IsDead() then
            if math.random()>0.6 then
                self:Shoot(v)
                return
            end
        end
    end
end

return SummonControllerfy