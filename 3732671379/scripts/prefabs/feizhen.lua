local assets =
{
    Asset("ANIM", "anim/feizhen.zip"),
	Asset("ANIM", "anim/gwen_jiandaofx.zip"),
	Asset("ANIM", "anim/gwen_fly.zip"),
	Asset("IMAGE", "fx/sparkle.tex"), 
	Asset("ANIM", "anim/feizhen_projectile_tail.zip"),
}

---------------------------------------------------------------
--- 拖尾效果
local WEIGHTED_TAIL_FXS = {
    ["idle1"] = 1,
    ["idle2"] = 0.5,
}

local function Projectile_CreateTailFx(colour)
    local fx = CreateEntity()
    fx:AddTag("FX")
    fx:AddTag("NOCLICK")
    fx.entity:SetCanSleep(false)
    fx.persists = false

    fx.entity:AddTransform()
    fx.entity:AddAnimState()

    fx.AnimState:SetBank("feizhen_projectile_tail")
    fx.AnimState:SetBuild("feizhen_projectile_tail")
    fx.AnimState:PlayAnimation(weighted_random_choice(WEIGHTED_TAIL_FXS))
    fx.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    fx.AnimState:SetLightOverride(0.3)
    fx.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	fx.AnimState:SetMultColour(0.3, 0.4, 1.0, 0.8)

    fx:ListenForEvent("animover", fx.Remove)
    return fx
end

local function CalVelocity(pos,old_pos,dt)
    local dx = pos.x - old_pos.x
    local dz = pos.z - old_pos.z
    local speed = math.sqrt(dx*dx+dz*dz)/dt
    return speed
end

local function CalAngle(pos,old_pos)
    local x1 = old_pos.x
    local z1 = old_pos.z
    local x2 = pos.x
    local z2 = pos.z
    local angle=math.atan2(z1-z2,x2-x1)/DEGREES
    return angle
end

local function Projectile_UpdateTail(inst)
    local x,_,z = inst.Transform:GetWorldPosition()
    local time = GetTime()
    if not inst:HasTag('NoTail') then
        local speed = CalVelocity({x=x,z=z}, inst.last_pos, time-inst.last_time)
        speed = math.min(speed, 65)
        local scale = (speed > 5) and ((speed/30 - 1) * 0.35 + 0.75) or 0
        scale = math.max(0, math.min(scale, 1.8))
        local tail_1 = inst:CreateTailFx()
        tail_1.Transform:SetScale(scale, scale, scale)
        tail_1.Transform:SetPosition(inst.Transform:GetWorldPosition())
        local angle = CalAngle({x=x,z=z}, inst.last_pos)
        tail_1.Transform:SetRotation(angle)
    end
    inst.last_pos = {x=x,z=z}
    inst.last_time = time
end
---------------------------------------------------------------
---粒子尾迹效果
local function RandomRange(min, max)
    return min + math.random() * (max - min)
end

local SCALE_ENVELOPE_NAME = "feizhen_trail_scale"
local COLOUR_ENVELOPE_NAME = "feizhen_trail_colour"

local function InitEnvelopes()
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0,    { 0.8, 0.8 } },
            { 0.3,  { 0.8, 0.8 } },
            { 1,    { 0.1, 0.1 } },
        }
    )

    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME,
        {
            { 0,    { 0.2, 0.1, 0.8, 0 } },          
            { 0.2,  { 0.2, 0.2, 1, 1 } },        
            { 0.6,  { 0.1, 0.1, 0.6, 0.8 } },    
            { 1,    { 0, 0, 0, 0 } },
        }
    )

    InitEnvelopes = nil
end

local function EmitTrailParticle(effect, velocity)
    local lifetime = RandomRange(0.5, 0.9)

    local offset = 0.4
    local dir = velocity:GetNormalized()
    local px, py, pz = dir:Get()
    local pos_x = -px * offset
    local pos_y = -py * offset
    local pos_z = -pz * offset

    local speed_factor = RandomRange(0.8, 1.2)
    local vx = -px * speed_factor + RandomRange(-0.2, 0.2)
    local vz = -pz * speed_factor + RandomRange(-0.2, 0.2)
    local vy = -py * speed_factor + RandomRange(-0.1, 0.1)

    local angle = math.random(0, 3) * 90

    effect:AddRotatingParticle(
        0,
        lifetime,
        pos_x, pos_y, pos_z,
        vx, vy, vz,
        angle,
        0
    )
end

--------------------------------------------------------
---飞针
local function fn(colour)
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	inst.entity:AddLight()
	inst.entity:SetCanSleep(false)
	inst.entity:AddSoundEmitter()
	inst.SoundEmitter:PlaySound("Gwen_sound/Gwen_sfx/Gwen_R",nil,.18)----声音飞针

	MakeInventoryPhysics(inst)

	inst.Light:SetFalloff(0.5)
	inst.Light:SetIntensity(0.8)
	inst.Light:SetRadius(1.2)
	inst.Light:SetColour(200/255, 255/255, 170/255)
	inst.Light:Enable(true)
	inst.Light:EnableClientModulation(true)

	inst.Physics:ClearCollidesWith(COLLISION.LIMITS)
	inst.Physics:ClearCollisionMask()
	inst.Physics:CollidesWith(COLLISION.GROUND)

	inst.AnimState:SetBank("feizhen")
	inst.AnimState:SetBuild("feizhen")
	inst.AnimState:PlayAnimation("idle",true)

	inst:AddTag("NOCLICK")
	inst:AddTag("NOBLOCK")
	inst:AddTag("tr_suicong")    
	MakeInventoryFloatable(inst, "med", 0.05, {1.1, 0.5, 1.1}, true, -9)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end
	
	inst.persists = false
    
	inst:AddComponent("summon_controllergw")
	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(10)    
	inst:ListenForEvent("onshoot", function (inst,data)
		inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	end)
		
	inst.SetOwner = function(self,owner)
		self.owner = owner
	end
		
	inst:DoPeriodicTask(1 * FRAMES, function()
		if inst.owner == nil or not inst.owner:IsValid() then
			if inst and inst:IsValid() then
				inst:Remove()
			end
		else
			if inst.owner and inst.owner:IsValid() then
				local hand_item = inst.owner.components.inventory and inst.owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
				if (inst.owner.components.health and inst.owner.components.health:IsDead())
				or (hand_item ~= nil and hand_item.prefab ~= "gwen_jiandao")
				or hand_item == nil					
				then
					if inst and inst:IsValid() then
						inst:Remove()
					end
				end
			end 
		end
	end)

	MakeHauntableLaunch(inst)


	if not TheNet:IsDedicated() then
		if InitEnvelopes ~= nil then
			InitEnvelopes()
		end

		local effect = inst.entity:AddVFXEffect()
		effect:InitEmitters(1)

		effect:SetRenderResources(0, "fx/sparkle.tex", "shaders/vfx_particle_add.ksh")
		effect:SetUVFrameSize(0, 0.25, 1)
		effect:SetRotationStatus(0, true)
		effect:SetMaxNumParticles(0, 300)
		effect:SetMaxLifetime(0, 0.9)
		effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
		effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
		effect:SetBlendMode(0, BLENDMODE.Additive)
		effect:EnableBloomPass(0, true)
		effect:SetLayer(0, LAYER_WORLD)
		effect:SetSortOrder(0, 2)
		effect:SetDragCoefficient(0, 0.2)
		effect:SetAngularDragCoefficient(0, 0.1)
		effect:EnableDepthTest(0, true)

		local step = 0
		EmitterManager:AddEmitter(inst, nil, function()
			step = step + 1
			if step >= 1 then
				step = 0
				local vx, vy, vz = inst.Physics:GetVelocity()
				local velocity = Vector3(vx, vy, vz)
				if velocity and velocity:LengthSq() > 0.1 then
					EmitTrailParticle(effect, velocity)
				end
			end
		end)
	
		local x,_,z = inst.Transform:GetWorldPosition()
        inst.last_pos = {x=x,z=z}
        inst.last_time = GetTime()
		inst.CreateTailFx  = function(inst) return Projectile_CreateTailFx(colour) end
		inst.UpdateTail    = Projectile_UpdateTail
        inst:DoPeriodicTask(0, inst.UpdateTail)
	end

    
	return inst
end

----------------------------------------------------------------------残影
local function chongcifx()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
	inst.entity:AddPhysics()

    inst.Transform:SetFourFaced()

    inst:AddTag("scarytoprey")
    inst:AddTag("character")
    inst:AddTag("companion")
	inst:AddTag("notraptrigger")

	inst.AnimState:SetBank("wilson")
	inst.AnimState:SetBuild("wilson")
    inst.AnimState:PlayAnimation("atk_leap_lag")
	inst.AnimState:SetMultColour(.7, .8, .9, .4)

    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(5)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:SetCapsule(.5, 1)

    inst.AnimState:Hide("HAT")
    inst.AnimState:Hide("HAIR_HAT")
    inst.AnimState:Show("HAIR_NOHAT")
    inst.AnimState:Show("HAIR")
    inst.AnimState:Show("HEAD")
    inst.AnimState:Hide("HEAD_HAT")
    inst.AnimState:Show("ARM_carry")
    inst.AnimState:Hide("ARM_normal")

    inst.entity:SetPristine()

	inst:AddTag("animal")

    if not TheWorld.ismastersim then
        return inst
    end

	inst.persists = false

    inst:AddComponent("inspectable")
    inst:AddComponent("skinner")

    inst.SetOwner = function(self,owner)
        self.owner = owner
        self.AnimState:OverrideSymbol("swap_object", "swap_gwenshears", "swap_shears")
		inst.components.skinner:CopySkinsFromPlayer(owner)
		inst.Transform:SetRotation(inst.owner.Transform:GetRotation())
    end

	inst:DoTaskInTime(.08,function()
		inst:Remove()
    end)

    return inst
end

----------------------------------------------------------------------飞行
local function gwen_flyfxfn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	inst.entity:AddFollower()

    inst.AnimState:SetBank("gwen_fly")
    inst.AnimState:SetBuild("gwen_fly")
    inst.AnimState:PlayAnimation("on_idle", false)
    inst.AnimState:PushAnimation("idle", true)		
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetSortOrder(-1)
	--inst.AnimState:SetLayer(LAYER_GROUND)

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.SetOwner = function(self,owner)
        self.owner = owner
		--inst.Transform:SetRotation(inst.owner.Transform:GetRotation())
    end

	inst:DoPeriodicTask(1 * FRAMES, function()
		if inst:HasTag("fly_yingzi") then
			inst.AnimState:SetMultColour(0, 0, 0, .44)
			inst.Transform:SetScale(1.32,1.32,1.32)
		else
			inst.Transform:SetScale(1.34,1.34,1.34)
		end
		if inst.owner == nil or not inst.owner:IsValid() then
			if inst and inst:IsValid() then
				inst:Remove()
			end
		end
	end)

	return inst
end

---------------------------------------------------------------------剪刀技能

local function IsEntityInFront(inst, entity, doer_rotation, doer_pos)
    local facing = Vector3(math.cos(-doer_rotation / RADIANS), 0 , math.sin(-doer_rotation / RADIANS))

    return IsWithinAngle(doer_pos, facing, TUNING.VOIDCLOTH_SCYTHE_HARVEST_ANGLE_WIDTH, entity:GetPosition())
end
----剪下掉落物
local function TryDropLoot(target)
    if target.components.lootdropper == nil or target:HasTag("fossil") then
        return false
    end
    if math.random() < 0.12 then
        local loot_list = target.components.lootdropper:GenerateLoot()
        if loot_list and #loot_list > 0 then
                local chosen_loot = loot_list[math.random(#loot_list)]
                target.components.lootdropper:SpawnLootPrefab(chosen_loot)
            return true
        end
    end
    return false
end

local function gwen_jiandaofx()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
	inst.entity:AddLight()
	
	--inst.Transform:SetFourFaced()
	
	inst.AnimState:SetBank("gwen_jiandaofx")
	inst.AnimState:SetBuild("gwen_jiandaofx")
	inst.AnimState:PlayAnimation("idle")
	--inst.AnimState:SetFinalOffset(1)
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	--inst.AnimState:SetLayer(LAYER_GROUND)
	
	inst.SoundEmitter:PlaySound("Gwen_sound/Gwen_sfx/Gwen_Z",nil,.1) ----声音冲刺、剪刀

	MakeInventoryPhysics(inst)
	RemovePhysicsColliders(inst)
	
	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	inst:AddTag("companion")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:AddComponent("lootdropper")
    inst:AddComponent("inspectable")
    inst:AddComponent("colouradder")

    inst.SetOwner = function(self,owner)
        self.owner = owner
		if inst:HasTag("mianxiang") then
			inst.Transform:SetRotation(inst.owner.Transform:GetRotation())
		end
		inst.owner.IsEntityInFront = IsEntityInFront
    end

	inst:DoTaskInTime(0,function()
		----人物判定
		local doer 
		if inst.owner ~= nil and inst.owner:IsValid() then
			doer = inst.owner
		else	
			return
		end

		local range = 5.2
		local scale = 1.0
		if doer.components.skilltreeupdater and doer.components.skilltreeupdater:IsActivated("gwen_cut_radiance_1") then
			range = 8.2
			scale = 1.35
			inst.AnimState:SetAddColour(1, 1, 1, 0)
		end
		inst.Transform:SetScale(scale, scale, scale)

		local radiance2_mult = 1.0
		if doer.components.skilltreeupdater and doer.components.skilltreeupdater:IsActivated("gwen_cut_radiance_2") then
			radiance2_mult = 1.25
		end

		if not inst:HasTag("fly_yingzi") then
			inst.AnimState:SetMultColour(.96, .9, .96, .7)
			inst.AnimState:SetSortOrder(3)
			inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
		else
			inst.AnimState:SetMultColour(0, 0, 0, .3)
			inst.AnimState:SetSortOrder(1)
			doer.Gw_Cut = nil
			return
		end

		-- local doer_pos = doer:GetPosition()
		-- local x, y, z = doer_pos:Get()
		-- local doer_rotation = doer.Transform:GetRotation()
		-- local pos = Vector3(doer.Transform:GetWorldPosition())
		-- local Gwen_externaldamagemultipliers = (inst.owner and inst.owner.components.combat and inst.owner.components.combat.externaldamagemultipliers:Get()) or 1
		-- local Gwen_damagemultiplier = (inst.owner and inst.owner.components.combat and inst.owner.components.combat.damagemultiplier) or 1
		-- local weapon = inst.owner and inst.owner.components.inventory and inst.owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		-- local Gwen_basedamage = (weapon and weapon.components.planardamage and weapon.components.planardamage.basedamage) or 0

		-- ----伤害判定
		-- local ents = TheSim:FindEntities(pos.x, pos.y , pos.z, 5.2, E_CONTAIN, E_EXCLUDE)
		-- for k,v in pairs(ents) do
		-- 	if doer:IsEntityInFront(v, doer_rotation, doer_pos) and doer.Gw_Cut == nil then
		-- 		if v ~= nil and v:IsValid() and v.components.health and not v.components.health:IsDead() and v.components.combat ~= nil
		-- 		and not (v.components.follower and v.components.follower:GetLeader() and v.components.follower:GetLeader():HasTag("player"))
		-- 		then
		-- 			if doer and v.gw_Attack_Record ~= nil then
		-- 				v.gw_Attack_Record[doer.userid] = true
		-- 			end
		-- 			if v.components.combat and v.components.combat ~= nil and v.components.health and not v.components.health:IsDead()then
		-- 				v.components.combat:GetAttacked(doer, 53.5 *Gwen_damagemultiplier *Gwen_externaldamagemultipliers,nil, nil, {planar = Gwen_basedamage})

		-- 				local fx = SpawnPrefab("shadowstrike_slash_fx")
		-- 				fx.entity:SetParent(v.entity)
		-- 				fx.Transform:SetPosition(0, 2.5, 0)
		-- 				fx.Transform:SetScale(1.2,1.2,1.2)
		-- 				doer.components.gwen_competence:Reset_cengshu()
		-- 			end
		-- 		end
		-- 	end
		-- end

		local doer_pos = inst:GetPosition()
		local x, y, z = doer_pos:Get()
		local doer_rotation = inst.Transform:GetRotation()
		local pos = Vector3(inst.Transform:GetWorldPosition())
		local Gwen_externaldamagemultipliers = (inst.owner and inst.owner.components.combat and inst.owner.components.combat.externaldamagemultipliers:Get()) or 1
		local Gwen_damagemultiplier = (inst.owner and inst.owner.components.combat and inst.owner.components.combat.damagemultiplier) or 1
		local weapon = inst.owner and inst.owner.components.inventory and inst.owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		local weapon_damage = (weapon and weapon.components.weapon.damage) or 10
		local skill_cengshu = (doer.components.gwen_competence and doer.components.gwen_competence:Get_cengshu()) or 1
		local cengshu_multiplier = 0.5 + skill_cengshu / 10
		local Gwen_basedamage = (weapon and weapon.components.planardamage and weapon.components.planardamage.basedamage) or 0

		----伤害判定
		local ents = TheSim:FindEntities(pos.x, pos.y , pos.z, range, E_CONTAIN, E_EXCLUDE)
		for k,v in pairs(ents) do
			if doer:IsEntityInFront(v, doer_rotation, doer_pos) and doer.Gw_Cut == nil then
				if v ~= nil and v:IsValid() and v.components.health and not v.components.health:IsDead() and v.components.combat ~= nil
				and not (v.components.follower and v.components.follower:GetLeader() and v.components.follower:GetLeader():HasTag("player"))
				then
					if doer and v.gw_Attack_Record ~= nil then
						v.gw_Attack_Record[doer.userid] = true
					end
					if v.components.combat and v.components.combat ~= nil and v.components.health and not v.components.health:IsDead()then
						-- 新的伤害：武器攻击力 × 倍率 × 技能树 × (0.5 + 层数/10) + 位面伤害
						local calculated_damage = weapon_damage * Gwen_damagemultiplier * Gwen_externaldamagemultipliers * cengshu_multiplier * radiance2_mult
						v.components.combat:GetAttacked(doer, calculated_damage, nil, nil, {planar = Gwen_basedamage})
						local fx = SpawnPrefab("shadowstrike_slash_fx")
						fx.entity:SetParent(v.entity)
						fx.Transform:SetPosition(0, 2.5, 0)
						fx.Transform:SetScale(1.2,1.2,1.2)
						doer.components.gwen_competence:Reset_cengshu()
						if doer.components.skilltreeupdater and doer.components.skilltreeupdater:IsActivated("gwen_cut_radiance_2") then
							TryDropLoot(v)
						end
					end
				end
			end
		end

		----飞针判定
		local ents = TheSim:FindEntities(pos.x, pos.y , pos.z, range, E_CONTAIN, E_EXCLUDE)
		for k,v in pairs(ents) do
			if v ~= nil and v:IsValid() and v.components.health and not v.components.health:IsDead() and v.components.combat ~= nil
			and not (v.components.follower and v.components.follower:GetLeader() and v.components.follower:GetLeader():HasTag("player"))
			then
				if doer:IsEntityInFront(v, doer_rotation, doer_pos) and doer.Gw_Cut == nil then
					if v.components.combat and v.components.combat ~= nil and v.components.health and not v.components.health:IsDead() then
						local hand_item = nil
						if doer and doer.components.inventory then
							for key, value in pairs(doer.components.inventory.equipslots) do
								if value.components.enemyselectgw then
									hand_item = value
								end
							end
							if hand_item ~= nil and hand_item.summonsfy then
								for index, value in ipairs(hand_item.summonsfy) do
									if value and value:IsValid() and v then
										hand_item.SoundEmitter:PlaySound("Gwen_sound/Gwen_sfx/Gwen_R",nil,.18)----声音飞针
										value.components.summon_controllergw:Shoot(v)
										value.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)						
									end
								end
								return true
							end
						end
					end
				end
			end
		end
		
		local function tryharvest(inst) 
			if inst.components.crop ~= nil then
				inst.components.crop:Harvest(doer) 
			elseif inst.components.harvestable ~= nil then
				inst.components.harvestable:Harvest(doer) 
			elseif inst.components.stewer ~= nil then
				inst.components.stewer:Harvest(doer)
			elseif inst.components.dryer ~= nil then
				inst.components.dryer:Harvest(doer)
			elseif inst.components.occupiable ~= nil and inst.components.occupiable:IsOccupied() then
				local item = inst.components.occupiable:Harvest(doer) 
				if item ~= nil then
					doer.components.inventory:GiveItem(item) 
				end 
			elseif inst.components.pickable ~= nil and inst.components.pickable:CanBePicked() then
				inst.components.pickable:Pick(doer) 
			end
		end
		local ents = TheSim:FindEntities(pos.x, pos.y , pos.z, range)
		for k, v in pairs(ents) do
			if doer:IsEntityInFront(v, doer_rotation, doer_pos) then
				if not v:HasTag("reader") 
				and not v:HasTag("flower") 
				and not v:HasTag("mushroom_farm") 
				and not v:HasTag("trap") 
				and not v:HasTag("mine") 
				and not v:HasTag("cage")
				and v ~= TheWorld 
				and v.AnimState 
				and v.components 
				and v.prefab 
				and v.prefab ~= "atrium_gate"
				and not string.find(v.prefab, "mandrake") 
				and not string.find(v.prefab, "moonbase") 
				and not string.find(v.prefab,"gemsocket") 
				then 
					tryharvest(v)
				end

				if v:HasTag("flower") and v:HasTag("bush") then
					tryharvest(v) 
				end
			end
		end

		doer.Gw_Cut = nil
    end)

	inst:ListenForEvent("animover",inst.Remove)

    return inst
end

---------------------------------------------------------------------
return Prefab("feizhen", fn, assets),
		Prefab("gwen_chongci", chongcifx),
		Prefab("gwen_flyfx", gwen_flyfxfn),
		Prefab("gwen_jiandaofx", gwen_jiandaofx, assets)