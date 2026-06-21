local radian = math.pi/180
local R = 2.5
local EnemySelectgw = Class(function (self,inst)
    self.inst = inst
	if self.inst.cengshu == nil then
		self.inst.cengshu = 0
	end

    if TUNING.TERRAPRISMA_CIRCLEFY then
        self.circle = 0
        self.circle_angle = self.circle * radian
        self.inst:StartUpdatingComponent(self)
        self.positions={
            [1]={},
            [2]={},
            [3]={},
            [4]={},
            [5]={},
            [6]={},
            [7]={},
            [8]={},
            [9]={},
            [10]={},
            [11]={},
            [12]={},
        }
    end
end)

function EnemySelectgw:OnUpdate(dt)
	local owner = self.inst.components.inventoryitem and self.inst.components.inventoryitem.owner
	
	local feizhennum
	if owner ~= nil and owner.components.gwen_competence then
		local gw_Level = (owner.components.gwen_competence and owner.components.gwen_competence:Get_gwen_Level()) or 1
		if gw_Level >= 1 then
			feizhennum = TUNING.FEIZHENSHULIANG
		end
		if gw_Level >= 12 then
			feizhennum = TUNING.FEIZHENSHULIANG + 1
		end
		if gw_Level >= 17 then
			feizhennum = TUNING.FEIZHENSHULIANG + 2
		end
	else
		feizhennum = TUNING.FEIZHENSHULIANG
	end
	self.num = feizhennum
	self.per_angle = 2 * math.pi/self.num

	if owner ~= nil then
		local x,_,z = owner.Transform:GetWorldPosition()
		self.circle = self.circle+dt*120
		if self.circle > 180 then
			self.circle = self.circle-360
		end
		self.circle_angle = self.circle * radian
		for i = 0, self.num - 1 do
			self.positions[i+1].x = x + R* math.sin(self.circle_angle+self.per_angle*i)
			self.positions[i+1].z = z + R* math.cos(self.circle_angle+self.per_angle*i)
		end
	else
		return
	end
end

return EnemySelectgw