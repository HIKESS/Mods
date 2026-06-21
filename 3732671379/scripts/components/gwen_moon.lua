
local function current_moon_Level(self, moon_Level)
    self.inst.replica.gwen_moon:Setmoon_Level(moon_Level)
end

local function current_mooning(self, mooning)
    self.inst.replica.gwen_moon:Setmooning(mooning)
end

local NOTENTCHECK_CANT_TAGS = { "FX", "INLIMBO" }
local function noentcheckfn(pt)
    return not TheWorld.Map:IsPointNearHole(pt) and #TheSim:FindEntities(pt.x, pt.y, pt.z, 1, nil, NOTENTCHECK_CANT_TAGS) == 0
end

local gwen_moon = Class(function(self, inst)
    self.inst = inst
	self.moon_Level = 0
	self.owner = nil
	self.mooning = 0

end,nil,
{
	moon_Level = current_moon_Level,
	mooning = current_mooning,
})

function gwen_moon:Getmooning() return self.mooning end
function gwen_moon:Getmoon_Level() return self.moon_Level end

----全部停止
function gwen_moon:Restemoon_Level()
	self.moon_Level = 0
	self:Stop()
end

----插入次级
function gwen_moon:Setmoon_Level(count)
	self.moon_Level = count
	self.owner = nil
	self.mooning = 0
end

----成为次级
function gwen_moon:gw_refactor_0() 
	self:Setmoon_Level(2)
	self:Replace("gw_refactor_0")
	self:Stop()
	self.inst.AnimState:OverrideSymbol("swap_staffs", "gw_refactor_0", "gw_refactor_0")
end

----成为棱彩
function gwen_moon:gw_refactor_3()
	self:Setmoon_Level(3)
	self:Replace("gw_refactor_3")
	self:Stop()
	self.inst.AnimState:OverrideSymbol("swap_staffs", "gw_refactor_3", "gw_refactor_3")
end

----特效2
function gwen_moon:FXstart2()
	local pt = self.inst:GetPosition()
	local num = 48	
	for k = 0, num - 1 do
		local rad = 18
		local angle = k * 2 * PI / num
		local pos = pt + Vector3(rad * math.cos(angle), 0, rad * math.sin(angle))
		local fx = SpawnPrefab("winters_feast_depletefood")
		fx.Transform:SetPosition(pos:Get())
		fx.Transform:SetScale(.6,.6,.6)
		fx:ListenForEvent("animover", fx.Remove)
	end
end

----特效3
function gwen_moon:fx(pt)
	local fx = SpawnPrefab("spawn_fx_small")
	fx.Transform:SetPosition(pt:Get())
	fx.Transform:SetScale(1.2,1.2,1.2)
	fx:ListenForEvent("animover", fx.Remove)
end

----特效开始
function gwen_moon:FXstart()
	local x, y, z = self.inst.Transform:GetWorldPosition()
	if self.inst._fxpulse ~= nil then
		self.inst._fxpulse:Remove()
	end
	self.inst._fxpulse = SpawnPrefab("positronpulse")
	self.inst._fxpulse.Transform:SetPosition(x, y, z)

	if self.inst._fxfront ~= nil then
		self.inst._fxfront:Remove()
	end
	self.inst._fxfront = SpawnPrefab("positronbeam_front")
	self.inst._fxfront.Transform:SetPosition(x, y, z)

	if self.inst._fxback ~= nil then
		self.inst._fxback:Remove()
	end
	self.inst._fxback = SpawnPrefab("positronbeam_back")
	self.inst._fxback.Transform:SetPosition(x, y, z)

	self.inst.Light:Enable(true)
	if self.inst._staffstar == nil then
		self.inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	end
end


----特效停止
function gwen_moon:FXstop()
	if self.inst._fxpulse ~= nil then
		self.inst._fxpulse:KillFX()
		self.inst._fxpulse = nil
	end
	if self.inst._fxfront ~= nil then
		self.inst._fxfront:KillFX()
		self.inst._fxfront = nil
	end
	if self.inst._fxback ~= nil then
		self.inst._fxback:KillFX()
		self.inst._fxback = nil
	end
	self.inst.Light:Enable(false)
	if self.inst._staffstar == nil then
		self.inst.AnimState:ClearBloomEffectHandle()
	end
end

----替换物品
function gwen_moon:Replace(item)
	if self.inst.components.pickable then
		self.inst.components.pickable:ChangeProduct(item)
	end
end

----死亡删除
local function death(critter)
	if critter and critter:IsValid() then
		local pa = critter:GetPosition()
		local fx = SpawnPrefab("spawn_fx_small")
		fx.Transform:SetPosition(pa:Get())
		fx.Transform:SetScale(1.2,1.2,1.2)
		fx:ListenForEvent("animover", fx.Remove)
		critter:PushEvent("transfercombattarget", nil)
		critter:Remove()
	end
end

----召唤怪物
function gwen_moon:Spawn_2(critter, pt)
	local critter = SpawnPrefab(critter)
	critter.Transform:SetPosition(pt:Get())
	critter.e_NoLootdropper = true
	critter:DoPeriodicTask(.1,function()
		if critter and critter:IsValid() and critter.components.combat then
			if self.owner == nil or not self.owner:IsValid() then
				death(critter)
			else
				if self.owner.components.combat and self.owner.components.health and not self.owner.components.health:IsDead() then
					critter.components.combat:SetTarget(self.owner)
				end
				local pos = Vector3(self.inst.Transform:GetWorldPosition())
				local pt = Vector3(self.owner.Transform:GetWorldPosition())
				local e_distance = (pos.x - pt.x)*(pos.x - pt.x) + (pos.z - pt.z)*(pos.z - pt.z)
				if (self.owner.components.health and self.owner.components.health:IsDead())
				or e_distance > 346
				then
					death(critter)
				end
			end
		end
	end)
end

function gwen_moon:Spawn_1(critter)
	local pt = self.inst:GetPosition()
	local offset = FindWalkableOffset(pt, math.random() * 2 * PI, 6 + math.random(), 14, false, true, noentcheckfn, true, true)
				or FindWalkableOffset(pt, math.random() * 2 * PI, 10 + math.random(), 14, false, true, noentcheckfn, true, true)
				or FindWalkableOffset(pt, math.random() * 2 * PI, 14 + math.random(), 14, false, true, noentcheckfn, true, true)
	if offset ~= nil then
		pt = pt + offset
	end

	self:fx(pt)

	self.inst:DoTaskInTime(.7,function()
		self:Spawn_2(critter, pt)
	end)
end

----仪式启动
function gwen_moon:Start(target, item ,owner)
	self:FXstart()
	self:FXstart2()
	self.owner = owner
	self.mooning = 1
	-- item:Remove()

	item.components.stackable:Get(1):Remove()

	self.inst:StartUpdatingComponent(self)

	if self.inst.chixu == nil then
		self.inst.chixu = self.inst:DoPeriodicTask(1,function()
			self:FXstart2()
		end)
	end

	if self.inst.jieduan_1 == nil then
		self.inst.jieduan_1 = self.inst:DoTaskInTime(5,function()
			if self.inst and self.inst.components.talker then
				self.inst.components.talker:Say("要小心了..")
				for i = 0 , 3 do			
					self:Spawn_1("hound")
					self:Spawn_1("beeguard")
				end
			end
		end)
	end

	if self.inst.jieduan_2 == nil then
		self.inst.jieduan_2 = self.inst:DoTaskInTime(15,function()
			if self.inst and self.inst.components.talker then
				self.inst.components.talker:Say("第二次..")
				for i = 0 , 3 do			
					self:Spawn_1("frog")
					self:Spawn_1("mermguard")
				end
			end
		end)
	end

	if self.inst.jieduan_3 == nil then
		self.inst.jieduan_3 = self.inst:DoTaskInTime(25,function()
			if self.inst and self.inst.components.talker then
				self.inst.components.talker:Say("还..还要继续吗..")
				for i = 0 , 2 do			
					self:Spawn_1("spider_hider")
					self:Spawn_1("spider_warrior")
				end
			end
		end)
	end

	if self.inst.jieduan_4 == nil then
		self.inst.jieduan_4 = self.inst:DoTaskInTime(35,function()
			if self.inst and self.inst.components.talker then
				self.inst.components.talker:Say("第四次..")
				for i = 0 , 1 do			
					self:Spawn_1("beefalo")
					self:Spawn_1("pigguard")
				end
			end
		end)
	end

	if self.inst.jieduan_5 == nil then
		self.inst.jieduan_5 = self.inst:DoTaskInTime(45,function()
			if self.inst and self.inst.components.talker then
				self.inst.components.talker:Say("还..还要继续吗..")
				for i = 0 , 0 do			
					self:Spawn_1("knight")
					self:Spawn_1("bishop")
				end
			end
		end)
	end

	if self.inst.jieduan_6 == nil then
		self.inst.jieduan_6 = self.inst:DoTaskInTime(55,function()
			if self.inst and self.inst.components.talker then
				self.inst.components.talker:Say("快要结束了吧..")
				for i = 0 , 0 do			
					self:Spawn_1("crawlingnightmare")
					self:Spawn_1("nightmarebeak")
				end
			end
		end)
	end

	if self.inst.renwuchenggong == nil then
		self.inst.renwuchenggong = self.inst:DoTaskInTime(70,function()
			if self.inst and self.inst.components.talker then
				self.inst.components.talker:Say("呼~结束了")
			end
			self:gw_refactor_3()
		end)
	end
end

----仪式终止
function gwen_moon:Stop()
	self:FXstop()
	self.owner = nil
	self.mooning = 0
	
	if self.inst.jieduan_1 then
		self.inst.jieduan_1:Cancel()
		self.inst.jieduan_1 = nil
	end
	if self.inst.jieduan_2 then
		self.inst.jieduan_2:Cancel()
		self.inst.jieduan_2 = nil
	end
	if self.inst.jieduan_3 then
		self.inst.jieduan_3:Cancel()
		self.inst.jieduan_3 = nil
	end
	if self.inst.jieduan_4 then
		self.inst.jieduan_4:Cancel()
		self.inst.jieduan_4 = nil
	end
	if self.inst.jieduan_5 then
		self.inst.jieduan_5:Cancel()
		self.inst.jieduan_5 = nil
	end
	if self.inst.jieduan_6 then
		self.inst.jieduan_6:Cancel()
		self.inst.jieduan_6 = nil
	end
	if self.inst.renwuchenggong then
		self.inst.renwuchenggong:Cancel()
		self.inst.renwuchenggong = nil
	end
	if self.inst.chixu then
		self.inst.chixu:Cancel()
		self.inst.chixu = nil
	end

	self.inst:StopUpdatingComponent(self)
end

----刷帧
function gwen_moon:OnUpdate(dt)
	if self.owner == nil or not self.owner:IsValid() then
		self:Stop()
	else
		local pos = Vector3(self.inst.Transform:GetWorldPosition())
		local pt = Vector3(self.owner.Transform:GetWorldPosition())
		local e_distance = (pos.x - pt.x)*(pos.x - pt.x) + (pos.z - pt.z)*(pos.z - pt.z)
		if self.owner.components.health and self.owner.components.health:IsDead() then
			if self.inst and self.inst.components.talker then
				self.inst.components.talker:Say("角色死亡仪式失败！")
			end
			self:Stop()
		end
		if e_distance > 346 then
			if self.inst and self.inst.components.talker then
				self.inst.components.talker:Say("距离过远仪式失败！")
			end
			self:Stop()
		end
	end
end

function gwen_moon:OnSave() --保存
	local data = {
		moon_Level = self.moon_Level,
	}
	return data
end

function gwen_moon:OnLoad(data) --加载
	if data.moon_Level then
        self.moon_Level = data.moon_Level or 0
    end
end

return gwen_moon