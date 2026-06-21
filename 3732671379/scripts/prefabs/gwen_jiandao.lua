local assets =
{
    Asset("ANIM", "anim/dajiandao.zip"),
    --Asset("ANIM", "anim/swap_dajiandao.zip"),
    Asset("ANIM", "anim/swap_gwenshears.zip"),
    Asset("ANIM", "anim/player_actions_shear.zip"),
    Asset("ATLAS","images/inventoryimages/gwen_jiandao.xml"),
	Asset("IMAGE","images/inventoryimages/gwen_jiandao.tex"),	
}
local prefabs = {}
local function onfinished(inst)
	inst:Remove()--耐久用完后，移除这个物体
end

local function onequip(inst, owner)		
	if owner.jiandao == nil then
		owner.jiandao = inst
	end
    if owner == nil or not owner:HasTag("gwen") then
		owner:DoTaskInTime( 0, function()
			local inventory = owner.components.inventory
			if inventory then
				inventory:DropItem(inst)
			end
		end)
	else
		local skin_build = inst:GetSkinBuild()
		if skin_build ~= nil then
			owner:PushEvent("equipskinneditem", inst:GetSkinName())
			owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_gwenshears", inst.GUID, "swap_shears")
		else
			owner.AnimState:OverrideSymbol("swap_object", "swap_gwenshears", "swap_shears")
		end

		-- if skin_build ~= nil then
		-- 	owner:PushEvent("equipskinneditem", inst:GetSkinName())
		-- 	owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_feizhen", inst.GUID, "swap_feizhen")
		-- else
		-- 	owner.AnimState:OverrideSymbol("swap_object", "swap_feizhen", "swap_feizhen")
		-- end
		owner.AnimState:Show("ARM_carry")
		owner.AnimState:Hide("ARM_normal")

    end
	inst.summonsfy = {}


	if inst.components.gwen_equip:Getgw_alchemy() ~= 0 then 
		if owner.EnableSprintTrail then
            owner:EnableSprintTrail(true)
        end
	end
end

local function onunequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
	local skin_build = inst:GetSkinBuild()
	for index, value in ipairs(inst.summonsfy) do
		if value and value:IsValid() then
			value:Remove()
		end	
	end	
	if skin_build ~= nil then
		owner:PushEvent("unequipskinneditem", inst:GetSkinName())
	end

	if inst.components.gwen_equip:Getgw_alchemy() ~= 0 then 
		if owner.EnableSprintTrail then
            owner:EnableSprintTrail(false)
        end
	end
end

----裁剪
local function Gw_Cut(inst, owner, target)
	local targetpos = Vector3(target.Transform:GetWorldPosition())
	if owner.sg and owner.sg:HasState("hit") and not owner.sg:HasStateTag("noouthit") and not owner.sg:HasStateTag("flight") and owner.components.health and not owner.components.health:IsDead() and not owner:HasTag("playerghost") then
		owner.Gw_Cut = 1
		if owner and owner:IsValid() then
			owner.components.gwen_competence:mianxiang_1()
		end
		owner.sg:GoToState("gwenw_jiiandao_start",targetpos)
		if target and target.components.beard then
			inst:DoTaskInTime(.6,function()
				target.components.beard:Shave(target, inst)
			end)
		end
	end
end

----重构or炼金
local function gw_Level(inst)
	if inst.components.gwen_equip
	and inst.components.weapon
	and inst.components.planardamage
	and inst.components.equippable
	then
		local Level = inst.components.gwen_equip:Getgw_Level()
		if inst.components.gwen_equip:Getgw_refactor() ~= 0 then 
			inst.components.weapon:SetDamage((34+Level*17) *TUNING.GWEN_JIANDAODAMAGE)
			inst.components.planardamage:SetBaseDamage((Level*15) *TUNING.GWEN_JIANDAODAMAGE)
			inst.components.weapon:SetRange(1 + Level*.2, 2.2)
		end
		if inst.components.gwen_equip:Getgw_alchemy() ~= 0 then 
			inst.components.weapon:SetDamage(34 *TUNING.GWEN_JIANDAODAMAGE)
			inst.components.planardamage:SetBaseDamage(0)
			inst.components.weapon:SetRange(1, 2.2)
		end
		inst.components.equippable.walkspeedmult = 1 +  Level*.1
	end
end


----重构
local function gw_refactor(inst, item, doer)
	local pos = Vector3(inst.Transform:GetWorldPosition())
	if inst.components.gwen_equip then
		if inst.components.gwen_equip:Getgw_alchemy() ~= 0 then
			inst.components.gwen_equip:Setgw_Level(0)
		end
		inst.components.gwen_equip:Incrgw_Level(1)
		inst.components.gwen_equip:Setgw_refactor()
		item:Remove()
		SendModRPCToClient(CLIENT_MOD_RPC["LegionMsg"]["gw_UiRefresh"],inst.userid) ----客户端发送

		--doer.sg:GoToState("mine")
		local fx = SpawnPrefab("crab_king_shine")
		fx.Transform:SetPosition(pos.x, pos.y + 2, pos.z)
		fx:ListenForEvent("animover", fx.Remove)

	end
	gw_Level(inst)
	return true
end

----炼金
local function gw_alchemy(inst, item, doer)
	local pos = Vector3(inst.Transform:GetWorldPosition())
	if inst.components.gwen_equip then
		if inst.components.gwen_equip:Getgw_refactor() ~= 0 then
			inst.components.gwen_equip:Setgw_Level(0)
		end
		inst.components.gwen_equip:Incrgw_Level(1)
		inst.components.gwen_equip:Setgw_alchemy()
		item:Remove()
		SendModRPCToClient(CLIENT_MOD_RPC["LegionMsg"]["gw_UiRefresh"],inst.userid) ----客户端发送

		--doer.sg:GoToState("mine")
		local fx = SpawnPrefab("crab_king_shine")
		fx.Transform:SetPosition(pos.x, pos.y + 2, pos.z)
		fx:ListenForEvent("animover", fx.Remove)
	end
	gw_Level(inst)
	return true
end

local function onattack(inst, attacker, target, owner)
	if inst~= nil and inst.summonsfy then
		for index, value in ipairs(inst.summonsfy) do
			if value and value:IsValid() then
				value.components.summon_controllergw:Shoot(target)
				value.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)			
			end
		end
	end

	local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
	if inst.components.gwen_equip 
	and owner and owner.prefab == "gwen" 
	and owner.components.health and owner.components.gwen_shengai
	then
		local Level = inst.components.gwen_equip:Getgw_Level()
		local maxhealth = owner.components.health and owner.components.health.maxhealth
		local maxshengai = owner.components.gwen_shengai and owner.components.gwen_shengai.max
		if inst.components.gwen_equip:Getgw_refactor() ~= 0 then
			if Level == 2 then 
				owner.components.health:DoDelta(maxhealth*.01,nil,nil,true,nil,true)
				if owner.components.health:GetPercent() >= 1 then
					owner.components.gwen_shengai:DoDelta(maxshengai*.01,nil,nil,true,nil,true)
				end
			end
			if Level == 3 then
				owner.components.health:DoDelta(maxhealth*.03,nil,nil,true,nil,true)
				if owner.components.health:GetPercent() >= 1 then
					owner.components.gwen_shengai:DoDelta(maxshengai*.03,nil,nil,true,nil,true)
				end
			end
		end
		if inst.components.gwen_equip:Getgw_alchemy() ~= 0 then
			local pt = owner:GetPosition()

			local gw_Level = owner.components.gwen_competence and owner.components.gwen_competence:Get_gwen_Level() or 1
			local cengshu

			if gw_Level >= 1 then
				cengshu = 2
			end
			if gw_Level >= 8 then
				cengshu = 3
			end
			if gw_Level >= 13 then
				cengshu = 4
			end

			if owner:HasTag("gw_cs_2") or owner:HasTag("gw_cs_1") then
				cengshu = cengshu + 1
			end

			local backpack
			if owner.components.inventory then
				for k, item in pairs(owner.components.inventory.itemslots) do
					if item and item.prefab == "gwen_beibao" then
						backpack = item
						break
					end
				end
			end

			if backpack and backpack.components.container then
				local guajian = backpack.components.container:GetItemInSlot(13)
				if guajian then
					if guajian.prefab == "gw_gj_xingguang1" or guajian.prefab == "gw_gj_xingguang2" then
						cengshu = cengshu + 1
					elseif guajian.prefab == "gw_gj_xingguang3" then
						cengshu = cengshu + 2
					end
				end
			end


			if math.random() < Level*.2 then
				target.ShockTask = target:DoTaskInTime(.3,function()
					if target:IsValid() and target.components.combat and target.components.combat ~= nil and target.components.health and not target.components.health:IsDead() then

						local fx = SpawnPrefab("gwen_canying")
						local px, py, pz = target.Transform:GetWorldPosition()
						fx.Transform:SetPosition(pt:Get())
						fx:ForceFacePoint(px, 0, pz)
						fx:SetOwner(owner)
						if owner.components.gwen_competence:Get_cengshu() >= cengshu then
						else
							owner.components.gwen_competence:Incr_cengshu(1)
						end

						target.components.combat:GetAttacked(inst, 22 + Level*11, nil, nil, {planar = 8 *Level})
						if target.components.health:IsDead() then
							owner:PushEvent("killed", { victim = target, attacker = owner })
						end
					end
				end)
			end
		end
	end
end

--[[
local function onputininventoryfn(inst, owner)
    if owner and owner:HasTag("gwen") then
        inst.gw_owner = owner
    end
end

local function OnDropped(inst)
	if inst.gw_owner then
		if inst.gw_owner.components.inventory:IsFull() then
			local item = inst.gw_owner.components.inventory:GetItemInSlot(1)
			if item then
				inst.gw_owner.components.inventory:DropItem(item)
			end
		end
		inst.gw_owner.components.inventory:GiveItem(inst)
	end
end

--进物品栏，持有者不是格温直接掉落
local function onpickupfn(inst, picker)
	if  not picker then
		return
	end
	if not picker:HasTag('gwen') then
		if picker.components.inventory then
			picker:DoTaskInTime(0,function()
				local inventory = picker.components.inventory
				if inventory then
					inventory:DropItem(inst)
				end
			end)
		end
	end
end

local function zhaohuanfeizhen(inst)
	local owner = inst.components.inventoryitem.owner
	if owner.feizhen == nil then
		owner.feizhen = false
	end
	if inst.cengshu >= 3 and owner.feizhen == false then
		owner.feizhen = true
		inst.components.rechargeable:Discharge(30)  -- 启动冷却
		if inst.cengshu >=3 then
			inst.summonsfy = {}
			for i = 1, TUNING.FEIZHENSHULIANG, 1 do  -- 召唤飞针
				inst.summonsfy[i] = SpawnPrefab("feizhen")
				inst.summonsfy[i].components.summon_controllergw:Init(owner, -0.5 + 0.25 * i, inst, i)
			end
			inst.cengshu = 0

			-- 在10秒后取消飞针
			inst:DoTaskInTime(30, function()
				for index, value in ipairs(inst.summonsfy) do
					if value and value:IsValid() then
						value:Remove()
					end
				end
				inst.summonsfy = nil  -- 清空记录，避免引用旧对象
				owner.feizhen = false			
			end)
		end	
	elseif inst.cengshu < 3 and owner.feizhen ==false then
		local owner = inst.components.inventoryitem.owner	
		owner.components.talker:Say("层数不足召唤飞针")			
		return false
	end
	if owner.feizhen == true and not inst.summonsfy then
		owner.components.talker:Say("我只能操控一把剪刀的飞针")
	return false
	end	
end

local function OnDischarged(inst)
	inst.components.useableitem.inuse = true	
end

local function OnCharged(inst)
	inst.components.useableitem.inuse = false
end
]]

local function OnLoad(inst,data)
	gw_Level(inst)
end

local function fn()
    local inst = CreateEntity()
	inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
	inst.entity:AddFollower()
	inst.entity:AddSoundEmitter()

	MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "med", .07, 0.71)

    inst.entity:SetPristine()
    inst.AnimState:SetBank("dajiandao")
    inst.AnimState:SetBuild("dajiandao")
    inst.AnimState:PlayAnimation("idle")
    inst:AddTag("sharp")	
	
    inst:AddTag("pointy")
    inst:AddTag("jiandao")	
    inst:AddTag("weapon")
    inst:AddTag("gw_weapon")
    inst:AddTag("e_jiandao_atk")
	
    inst:AddComponent("enemyselectgw")		

	if not TheWorld.ismastersim then
	    return inst
    end

	inst:AddComponent("gwen_equip") ----重构的组件

    inst:AddComponent("inventoryitem")
    ----inst.components.inventoryitem:SetOnPutInInventoryFn(onputininventoryfn)	
	----inst.components.inventoryitem:SetOnDroppedFn(OnDropped)	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gwen_jiandao.xml"
	inst.components.inventoryitem.imagename = "gwen_jiandao"
	----inst.components.inventoryitem:SetOnPickupFn(onpickupfn) --拾取 
    inst:AddComponent("inspectable")	
	inst:AddComponent("gewen_chaijie")--拆解物品的组件

	inst:AddComponent("planardamage")
	inst.components.planardamage:SetBaseDamage(10)

	

	inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(34*TUNING.GWEN_JIANDAODAMAGE)
	inst.components.weapon:SetRange(1, 2)
    inst.components.weapon:SetOnAttack(onattack)		
    inst.cengshu = 0

    -- inst:AddComponent("useableitem")
	-- inst.components.useableitem:SetOnUseFn(zhaohuanfeizhen)

	inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
	inst.components.equippable.walkspeedmult = 1
	inst.components.equippable.insulated = true

    -- inst:AddComponent("rechargeable")
    -- inst.components.rechargeable:SetOnDischargedFn(OnDischarged)
    -- inst.components.rechargeable:SetOnChargedFn(OnCharged)	

	----裁剪
	inst.Gw_Cut = Gw_Cut
	inst.gw_refactor = gw_refactor
	inst.gw_alchemy = gw_alchemy

	inst.OnLoad = OnLoad

	return inst
end

----------------------------------------------------------------------炼金影子
local function gwen_canyingfn()
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
	inst:AddTag("NOBLOCK")
	inst:AddTag("FX")
	inst:AddTag("notraptrigger")

	inst.AnimState:SetBank("wilson")
	inst.AnimState:SetBuild("wilson")
	inst.AnimState:PlayAnimation("idle")
	inst.AnimState:PushAnimation("atk", false)
    inst.AnimState:Hide("HAT")
    inst.AnimState:Hide("HAIR_HAT")
    inst.AnimState:Show("HAIR_NOHAT")
    inst.AnimState:Show("HAIR")
    inst.AnimState:Show("HEAD")
    inst.AnimState:Hide("HEAD_HAT")
    inst.AnimState:Show("ARM_carry")
    inst.AnimState:Hide("ARM_normal")
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.AnimState:SetSortOrder(3)

    inst.entity:SetPristine()
	
	inst:AddTag("animal")

    if not TheWorld.ismastersim then
        return inst
	end

	inst.persists = false

    inst:AddComponent("inspectable")
    inst:AddComponent("colouradder")
    inst:AddComponent("skinner")
	inst.AnimState:SetMultColour(.2, .6, 1, .8)
	inst.components.colouradder:PushColour("gwen_canying", .1, .6, .4, .8)

    inst.SetOwner = function(self, owner, gwtime)
        self.owner = owner
        self.gwtime = gwtime
        self.AnimState:OverrideSymbol("swap_object", "swap_gwenshears", "swap_shears")
		inst.components.skinner:CopySkinsFromPlayer(owner)

----[[以下代码有问题的话直接删除-----------------------------
		inst:AddTag("gwen")
		inst:AddComponent("inventory")
		local doer = owner.components.inventory
		local weapon = doer and doer:GetEquippedItem(EQUIPSLOTS.HANDS)
		local armor = doer and doer:GetEquippedItem(EQUIPSLOTS.BODY)
		local ownerhat = doer and doer:GetEquippedItem(EQUIPSLOTS.HEAD)

		if inst.owner.prefab == "gwen" then
			if weapon ~= nil then
				inst.weapon = weapon:GetSaveRecord()
				inst.components.inventory:Equip(SpawnSaveRecord(inst.weapon))
			end
			if armor ~= nil then
				inst.armor = armor:GetSaveRecord()
				inst.components.inventory:Equip(SpawnSaveRecord(inst.armor))
			end
			if ownerhat ~= nil then
				inst.ownerhat = ownerhat:GetSaveRecord()
				inst.components.inventory:Equip(SpawnSaveRecord(inst.ownerhat))
			end
		end
--------------------------------------------------------]]

		if inst.gwtime == nil then
			inst.gwtime = .42
		else
			if inst.gwtime <= 1 then
				inst.gwtime = .7
			else
				inst.gwtime = inst.gwtime*.2 + .2
			end
			inst:DoTaskInTime(inst.gwtime - .05,function()
				inst.AnimState:PlayAnimation("cut_pst",false)
			end)
		end

		inst:DoTaskInTime(inst.gwtime,function()
			inst.AnimState:ClearBloomEffectHandle()----移除光晕
			inst:StartThread(function()
				local fade = 1
				while fade > 0 do
					inst.AnimState:SetMultColour(.2, .6, 1, fade)
					fade = fade - 0.1
					Yield()
				end
				inst.AnimState:SetMultColour(.2, .6, 1, fade)
				inst:Remove()
			end)
		end)

    end

	inst:DoTaskInTime(2.5,function()
		if inst and inst:IsValid() then
			inst:Remove()
		end
	end)


    return inst
end

-----------------------------------------------------------------------------------
---e的幽魂

local DAMAGE_MULTIPLIER = 1.5
local HIT_RADIUS = 2.2
local HIT_INTERVAL = 0.05
local COMBAT_MUSTHAVE_TAGS = { "_combat", "_health" }
local COMBAT_CANTHAVE_TAGS = {
    "INLIMBO", "FX", "NOCLICK", "DECOR",
    "playerghost", "companion", "wall", "abigail",
    "shadowminion", "player"
}

local function CheckAndDamageEnemies(inst)
    if not inst:IsValid() or not inst.owner or not inst.owner:IsValid() then
        return
    end

        local weapon_damage = 0
        local weapon_planar_damage = 0
        local damage_multiplier = 1

        if inst.owner and inst.owner.components.combat then
            local weapon = inst.owner.components.combat:GetWeapon()
            if weapon then
                weapon_damage = weapon.components.weapon and weapon.components.weapon.damage or 10
				if type(weapon_damage) == "function" then
                    weapon_damage = weapon_damage(weapon, inst)
                end
                weapon_planar_damage = weapon.components.planardamage and 
                    weapon.components.planardamage:GetDamage() or 0

                if inst.owner.components.combat.externaldamagemultipliers then
                    damage_multiplier = inst.owner.components.combat.externaldamagemultipliers:Get() or 1
                end
            end
        end

        local base_damage = weapon_damage * damage_multiplier * DAMAGE_MULTIPLIER
        local planar_damage = weapon_planar_damage

        local x, y, z = inst.Transform:GetWorldPosition()
        local entities = TheSim:FindEntities(x, y, z, HIT_RADIUS, COMBAT_MUSTHAVE_TAGS, COMBAT_CANTHAVE_TAGS)

        for _, ent in ipairs(entities) do
            if ent ~= inst.owner and not (inst._hit_targets and inst._hit_targets[ent]) then
                local is_follower = ent.components.follower and ent.components.follower:GetLeader() and ent.components.follower:GetLeader():HasTag("player")
                if ent.components.combat and ent.components.health and not ent.components.health:IsDead() and not is_follower then
                    ent.components.combat:GetAttacked(
                        inst.owner,
                        base_damage,
                        nil,
                        nil,
                        {planar = planar_damage}
                    )

					if ent.components.hauntable and ent.components.hauntable.panicable then
                        ent.components.hauntable:Panic(2.5)
                    end

                    if not inst._hit_targets then
                        inst._hit_targets = {}
                    end
                    inst._hit_targets[ent] = true

                local fx = SpawnPrefab("impact")
                if fx then
                    fx.Transform:SetPosition(ent.Transform:GetWorldPosition())
                end
            end
        end
    end
end
local function gwen_shadowfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
	inst.entity:AddPhysics()

    inst.Transform:SetFourFaced()


	MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst:AddTag("companion")
	inst:AddTag("NOBLOCK")
	inst:AddTag("FX")
	inst:AddTag("notraptrigger")

	inst.AnimState:SetBank("wilson")
	inst.AnimState:SetBuild("wilson")
	inst.AnimState:PlayAnimation("idle")
	inst.AnimState:PushAnimation("lunge_pre", false)
	inst.AnimState:PushAnimation("lunge_lag", true)
    inst.AnimState:Hide("HAT")
    inst.AnimState:Hide("HAIR_HAT")
    inst.AnimState:Show("HAIR_NOHAT")
    inst.AnimState:Show("HAIR")
    inst.AnimState:Show("HEAD")
    inst.AnimState:Hide("HEAD_HAT")
    inst.AnimState:Show("ARM_carry")
    inst.AnimState:Hide("ARM_normal")
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.AnimState:SetSortOrder(3)

	inst.AnimState:AddOverrideBuild("player_lunge")

    inst.entity:SetPristine()
	
	inst:AddTag("animal")

    if not TheWorld.ismastersim then
        return inst
	end

	inst.persists = false

    inst:AddComponent("inspectable")
    inst:AddComponent("colouradder")
    inst:AddComponent("skinner")
	inst.AnimState:SetMultColour(.2, .6, 1, .8)
	inst.components.colouradder:PushColour("gwen_canying", .1, .6, .4, .8)

    inst.SetOwner = function(self, owner)
        self.owner = owner
        self.AnimState:OverrideSymbol("swap_object", "swap_gwenshears", "swap_shears")
		inst.components.skinner:CopySkinsFromPlayer(owner)

----[[以下代码有问题的话直接删除-----------------------------
		inst:AddTag("gwen")
		inst:AddComponent("inventory")
		local doer = owner.components.inventory
		local weapon = doer and doer:GetEquippedItem(EQUIPSLOTS.HANDS)
		local armor = doer and doer:GetEquippedItem(EQUIPSLOTS.BODY)
		local ownerhat = doer and doer:GetEquippedItem(EQUIPSLOTS.HEAD)

		if inst.owner.prefab == "gwen" then
			if weapon ~= nil then
				inst.weapon = weapon:GetSaveRecord()
				inst.components.inventory:Equip(SpawnSaveRecord(inst.weapon))
			end
			if armor ~= nil then
				inst.armor = armor:GetSaveRecord()
				inst.components.inventory:Equip(SpawnSaveRecord(inst.armor))
			end
			if ownerhat ~= nil then
				inst.ownerhat = ownerhat:GetSaveRecord()
				inst.components.inventory:Equip(SpawnSaveRecord(inst.ownerhat))
			end
		end
--------------------------------------------------------]]
    end

	
	inst:DoTaskInTime(1.2,function()
		if inst.owner.components.skilltreeupdater:IsActivated("gwen_dash_shadow_2") and not inst:HasTag("is_back") then
            local shadow = SpawnAt("gwen_dash_shadow", inst)
            local angle = inst.Transform:GetRotation()
            if shadow then
                shadow.Transform:SetRotation(angle + 180)
                shadow:SetOwner(inst.owner, 2)
				shadow:AddTag("is_back")
            end
		end
		if inst and inst:IsValid() then
			inst:Remove()
		end
	end)


	inst:DoTaskInTime(0.6,function()
        inst.AnimState:PlayAnimation("lunge_pst")
		if inst:HasTag("is_back") then
			inst.Physics:SetMotorVelOverride(36, 0, 0)
		else
        	inst.Physics:SetMotorVelOverride(30, 0, 0)
		end
		if inst._damage_task then
            inst._damage_task:Cancel()
        end
		inst._hit_targets = {}
		inst._damage_task = inst:DoPeriodicTask(HIT_INTERVAL, CheckAndDamageEnemies)
    end)


    return inst
end


return Prefab("gwen_jiandao",fn,assets,prefabs),
		Prefab("gwen_canying",gwen_canyingfn),
		Prefab("gwen_dash_shadow",gwen_shadowfn)