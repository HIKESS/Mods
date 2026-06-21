local gw_soul_common = require("prefabs/gw_soul_common")

local assets =
{
    Asset("ANIM", "anim/gwen_hundeng.zip"),
    Asset("ANIM", "anim/swap_hundeng.zip"),
    Asset("ANIM", "anim/swap_hundengfx.zip"),
    Asset("ATLAS","images/inventoryimages/gw_hundeng.xml"),
	Asset("IMAGE","images/inventoryimages/gw_hundeng.tex"),	
}
local prefabs = {}

local cd = 20



--------------------------------------------------------------------------------------------------------------------------

-- 烟雾生成
local function OnRemoveSmoke(smoke)
    smoke._hundeng._smoke = nil
end

local function StartSmoke(inst)
    if inst._smoke == nil then
        inst._smoke = SpawnPrefab("gw_smoke_fx")
        inst._smoke.entity:AddFollower()
        inst._smoke._hundeng = inst
        inst:ListenForEvent("onremove", OnRemoveSmoke, inst._smoke)

        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        if owner ~= nil then
            inst._smoke.Follower:FollowSymbol(owner.GUID, "swap_object", 100, -5, 0)
        else
            inst._smoke.Follower:FollowSymbol(inst.GUID, "gwen_hundeng", 0, 185, 0)
        end
    end
end

local function StopSmoke(inst)
    if inst._smoke ~= nil then
        inst._smoke:Remove()
        inst._smoke = nil
    end
end

----开始消耗
-- local function On_fueled(inst)
-- 	if inst.components.fueled ~= nil then
-- 		inst.components.fueled:StartConsuming()
-- 	end
-- end

-- ----停止消耗
-- local function Off_fueled(inst)
-- 	if inst.components.fueled ~= nil then
-- 		inst.components.fueled:StopConsuming()
-- 	end
-- 	inst.AnimState:PlayAnimation("idle",true)
-- end

----开灯
local function On_light(inst,owner)
	-- if inst.components.fueled.currentfuel > 0 then
		if inst._light == nil then
			inst._light = SpawnPrefab("minerhatlight")
			inst._light.Light:SetFalloff(.6)
			inst._light.Light:SetIntensity(.8)
			inst._light.Light:SetRadius(2.5) 
			inst._light.Light:SetColour(152/255, 221/255, 179/255)
			inst._light.entity:SetParent(inst.entity)
		end
	-- end
	StartSmoke(inst)
end

----关灯
local function Off_light(inst)
	if inst._light ~= nil then
		inst._light:Remove()
		inst._light = nil
	end
	if inst.fx ~= nil then
		inst.fx:Remove()
		inst.fx = nil
	end
	StopSmoke(inst)
	inst.AnimState:PlayAnimation("idle",true)
end

----续航
-- local function takefuel(inst)
-- 	if inst.components.equippable and inst.components.equippable:IsEquipped() then			
-- 		On_light(inst)
-- 		On_fueled(inst)
-- 	end
-- end

-- local function OnPickup(inst)
-- 	if inst.components.equippable and inst.components.equippable:IsEquipped() then			
-- 		On_light(inst)
-- 		On_fueled(inst)
-- 	else
-- 		Off_fueled(inst)
-- 		Off_light(inst)
-- 	end
-- end

local function OnPickup(inst)
	if inst.components.equippable and inst.components.equippable:IsEquipped() then			
		On_light(inst)
	else
		Off_light(inst)
	end
end

--------------------------------------------------------------------------------------------------------------------------
local function OnDropped(inst)
	inst:DoTaskInTime(1, function()
		if inst.Physics then
			inst.Physics:Stop()
			inst.Physics:ClearMotorVelOverride()
		end
	end)
end

local function UpdateWeaponDamage(inst)
    local base_damage = 48
    if inst.components.container then
        local soul_count = 0
        
        for i = 1, inst.components.container:GetNumSlots() do
            local item = inst.components.container:GetItemInSlot(i)
            if item and item.prefab == "gw_soul_ball" then
                if item.components.stackable then
                    soul_count = soul_count + item.components.stackable:StackSize()
                else
                    soul_count = soul_count + 1
                end
            end
        end

		if soul_count ~= 0 then
			On_light(inst)
		else
			Off_light(inst)
		end

        local total_damage = base_damage * (1 + (soul_count / (soul_count + 100)))
        -- 四舍五入保留一位小数
        total_damage = math.floor(total_damage * 10 + 0.5) / 10

        if inst.components.weapon then
            inst.components.weapon:SetDamage(total_damage)
        end
        
        if inst.components.armor then
            local defense_value = soul_count / (soul_count + 300)
            inst.components.armor:InitIndestructible(defense_value)
        end

		if inst._light ~= nil then
            local base_radius = 2.5
            local max_radius = 6.0
            local target_radius = math.min(max_radius, base_radius + (soul_count / 400) * (max_radius - base_radius))
            inst._light.Light:SetRadius(target_radius)
        end
    end
end
-----------------------------------------------------------------------------------------------------------
---根据灵魂调整攻击力
local function OnContainerChanged(inst, data)
    UpdateWeaponDamage(inst)
end

local function SetupContainerListeners(inst)
    if inst.components.container then
        inst:ListenForEvent("itemget", OnContainerChanged)
        inst:ListenForEvent("itemlose", OnContainerChanged)
        inst:ListenForEvent("stacksizechange", OnContainerChanged)
    end
end

local function RemoveContainerListeners(inst)
    inst:RemoveEventCallback("itemget", OnContainerChanged)
    inst:RemoveEventCallback("itemlose", OnContainerChanged)
    inst:RemoveEventCallback("stacksizechange", OnContainerChanged)
end
--------------------------------------------------------------------------------------------------------------

----装备
local function onequip(inst, owner) 
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal")

	local skin_build = inst:GetSkinBuild()
	if skin_build ~= nil then
		owner:PushEvent("equipskinneditem", inst:GetSkinName())
		owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_hundeng", inst.GUID, "swap_hundeng")
	else
		owner.AnimState:OverrideSymbol("swap_object", "swap_hundeng", "swap_hundeng")
	end

	if not owner:HasTag("gw_hundeng") then
		owner:AddTag("gw_hundeng")
	end

	if inst.components.container ~= nil then
        inst.components.container:Open(owner)
    end


	UpdateWeaponDamage(inst)
	SetupContainerListeners(inst)

	inst.task = inst:DoPeriodicTask(1 * FRAMES, function()
		if inst.fx == nil or not inst.fx:IsValid() then
			inst.fx = SpawnPrefab("swap_hundengfx")
			inst.fx.entity:AddFollower()
			local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
			if owner ~= nil then
				inst.fx.Follower:FollowSymbol(owner.GUID, "swap_object", 98, -34, 0)
			else
				if inst.task then
					inst.task:Cancel()
					inst.task = nil
				end
			end
		end

		----掉落灵魂
		--[[if inst.components.equippable and inst.components.equippable:IsEquipped() then	 
			local pos = Vector3(inst.Transform:GetWorldPosition())
			local ents = TheSim:FindEntities(pos.x,pos.y,pos.z, 25, E_CONTAIN, E_EXCLUDE)
			for k,v in pairs(ents) do
				if v ~= nil and v:IsValid() and v.components.health and v.components.health:IsDead() and not inst.targets[v] then
					inst.targets[v] = true
					local speed = 2
					local angle = math.random(360)
					local item = inst.components.lootdropper:SpawnLootPrefab("gw_dangao")
					if item ~= nil then
						local pt = Vector3(v.Transform:GetWorldPosition())
						item.Transform:SetPosition(pt.x, 3, pt.z)
						item.Physics:SetVel(speed * math.cos(angle), math.random() * 3 + 8, speed * math.sin(angle))
						local fx = SpawnPrefab("wathgrithr_spirit")
						fx.Transform:SetPosition(pt.x, pt.y, pt.z)
						fx.Transform:SetScale(2,2,2)
						fx:ListenForEvent("animover", fx.Remove)
					end
				end
			end
		end]]

	end)

	inst:RemoveTag("NOCLICK")
	inst.doer = owner
	inst.mubiao = nil
	if inst.renwu then
		inst.renwu:Cancel()
		inst.renwu = nil
	end
end

----脱下
local function onunequip(inst, owner) 
	owner.AnimState:ClearOverrideSymbol("swap_object")
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal")
	local skin_build = inst:GetSkinBuild()
	if skin_build ~= nil then
		owner:PushEvent("unequipskinneditem", inst:GetSkinName())
	end	

	Off_light(inst)
	owner:RemoveTag("gw_hundeng")

	if inst.components.container ~= nil then
        inst.components.container:Close()
    end

	RemoveContainerListeners(inst)
	
	if inst.task then
		inst.task:Cancel()
		inst.task = nil
	end


end

local function ReticuleTargetFn()
	local player = ThePlayer
	local ground = TheWorld.Map
	local pos = Vector3()
	for r = 7, 0, -.25 do
		pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
		if ground:IsPassableAtPoint(pos:Get()) and not ground:IsGroundTargetBlocked(pos) then
			return pos
		end
	end
	return pos
end

----落地
local function OnHit(inst, attacker, target)
	SpawnPrefab("abigail_retaliation").Transform:SetPosition(inst.Transform:GetWorldPosition())

	local hit_pos = Vector3(inst.Transform:GetWorldPosition())
    local radius = 2  
    local weapon_damage = inst.components.weapon and inst.components.weapon.damage or 48
    local damage = weapon_damage * 2
    
    if damage > 0 then
        local ents = TheSim:FindEntities(hit_pos.x, hit_pos.y, hit_pos.z, radius, {"_combat"}, {"player", "INLIMBO", "playerghost", "ghost"})
        for _, ent in ipairs(ents) do
            if ent ~= inst.doer and ent.components.combat and ent.components.health and not ent.components.health:IsDead() then
                ent.components.combat:GetAttacked(inst.doer, 0, nil, nil, {planar = damage})
				local ent_pos = Vector3(ent.Transform:GetWorldPosition())
                local fx = SpawnPrefab("halloween_firepuff_cold_2")
                if fx then
                    fx.Transform:SetPosition(ent_pos:Get())
                end
            end
        end
    end


	inst.mubiao = nil
	local pa = Vector3(inst.Transform:GetWorldPosition())
	if inst.renwu == nil then
		inst.renwu = inst:DoPeriodicTask(0,function()
			local pt = Vector3(inst.doer.Transform:GetWorldPosition())
			local pos = Vector3(inst.Transform:GetWorldPosition())
			local e_distance = (pos.x - pt.x)*(pos.x - pt.x) + (pos.z - pt.z)*(pos.z - pt.z)

			if inst.mubiao ~= nil and inst.mubiao:IsValid() and inst.mubiao.components.health and not inst.mubiao.components.health:IsDead() and not inst.mubiao:HasTag("playerghost") then
				inst.mubiao.Transform:SetPosition(pos:Get())
			end

			local ents = TheSim:FindEntities(pa.x, pa.y, pa.z, 2.6)
			for k,v in pairs(ents) do
				if v ~= nil
				and v:HasTag("player") and v.components.health and not v.components.health:IsDead() and not v:HasTag("playerghost")
				and v ~= inst.doer 
				--and v:GetPhysicsRadius(0) + 4 > distsq(pa, v:GetPosition())
				and inst.doer ~= nil and inst.mubiao == nil
				then
					inst.mubiao = v
				end
			end

			if e_distance > 1 then
				inst.Physics:Stop()
				inst.Physics:SetMotorVelOverride(27, 0, 0)
				inst:ForceFacePoint(pt:Get())
			elseif e_distance <= 1 or e_distance > 328 then
				inst.Physics:Stop()
				if inst.doer and inst.doer.components.inventory ~= nil and inst.doer.components.inventory.isopen then
					inst.doer.components.inventory:Equip(inst)
				end
				if inst.renwu then
					inst.renwu:Cancel()
					inst.renwu = nil
				end
			end

		end)
	end

	inst.components.rechargeable:Discharge(cd)
	if inst.components.complexprojectile then
		inst:RemoveComponent("complexprojectile")
	end
end

----扔出
local function onthrown(inst, doer, pos)
    inst:AddTag("NOCLICK")
	
	inst.AnimState:PlayAnimation("idle_loop",true)

    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(0)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:SetCapsule(.2, .2)

    doer.AnimState:Show("ARM_carry") 
    doer.AnimState:Hide("ARM_normal")

	local skin_build = inst:GetSkinBuild()
	if skin_build ~= nil then
		doer:PushEvent("equipskinneditem", inst:GetSkinName())
		doer.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_hundeng", inst.GUID, "swap_hundeng")
	else
		doer.AnimState:OverrideSymbol("swap_object", "swap_hundeng", "swap_hundeng")
	end

end

----cd控制
local function OnChargedFn(inst)
	if inst.components.rechargeable:GetTimeToCharge() <= 0 then
		if not inst.components.complexprojectile then
			inst:AddComponent("complexprojectile")
			inst.components.complexprojectile:SetHorizontalSpeed(15)
			inst.components.complexprojectile:SetGravity(-35)
			inst.components.complexprojectile:SetLaunchOffset(Vector3(.25, 1, 0))
			inst.components.complexprojectile:SetOnLaunch(onthrown)
			inst.components.complexprojectile:SetOnHit(OnHit)
		end
	end
end

--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--
local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
	inst.entity:AddSoundEmitter()
	inst.entity:AddLight()
	inst.entity:AddMiniMapEntity()

	MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "med", .07, 0.71)

    inst.AnimState:SetBank("gwen_hundeng")
    inst.AnimState:SetBuild("gwen_hundeng")
    inst.AnimState:PlayAnimation("idle",true)

    inst:AddTag("sharp")
    inst:AddTag("pointy")
	inst:AddTag("weapon")
	inst:AddTag("gw_weapon")
	inst:AddTag("gwen_hudeng")
	-- inst:AddTag("show_broken_ui")

	inst:AddTag("hide_percentage")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end

	inst.targets = {}

	inst:AddComponent("inspectable")
	
	inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_hundeng.xml"
	inst.components.inventoryitem.imagename = "gw_hundeng"
	inst.components.inventoryitem:SetOnPutInInventoryFn(OnPickup)
	inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
	inst.components.inventoryitem.canonlygoinpocket = true

	inst:AddTag("rechargeable")
	inst:AddComponent("rechargeable")
	inst.components.rechargeable:SetOnChargedFn(OnChargedFn)

	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)
	inst.components.equippable.walkspeedmult = 1.1

	inst:AddComponent("weapon")    
	inst.components.weapon:SetDamage(48)

	inst:AddComponent("armor")
    inst.components.armor:InitIndestructible(0) 


	
    -- inst:AddComponent("fueled")
    -- inst.components.fueled:InitializeFuelLevel(720)
    -- inst.components.fueled:SetDepletedFn(Off_light)
	-- inst.components.fueled.fueltype = "GW_SOUL_BALL"
	-- inst.components.fueled.accepting = true
	-- inst.components.fueled.ontakefuelfn = takefuel
	
	inst:ListenForEvent("ondropped", OnContainerChanged)
	-- inst:ListenForEvent("ondropped", On_fueled)

	local container = inst:AddComponent("container")
    container:WidgetSetup("gw_hundeng")
	container:EnableInfiniteStackSize(true)
--[[
	inst:AddComponent("aoetargeting")
    inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoesmall"
    inst.components.aoetargeting.reticule.pingprefab = "reticuleaoesmallping"
    inst.components.aoetargeting.reticule.targetfn = ReticuleTargetFn
    inst.components.aoetargeting.reticule.validcolour = { 1, .75, 0, 1 }
    inst.components.aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
    inst.components.aoetargeting.reticule.ease = true
    inst.components.aoetargeting.reticule.mouseenabled = true
    inst.components.aoetargeting:SetRange(35)---技能距离

	inst:AddComponent("aoespell")
	inst:RegisterComponentActions("aoespell")
]]
    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetHorizontalSpeed(15)
    inst.components.complexprojectile:SetGravity(-35)
    inst.components.complexprojectile:SetLaunchOffset(Vector3(.25, 1, 0))
    inst.components.complexprojectile:SetOnLaunch(onthrown)
	inst.components.complexprojectile:SetOnHit(OnHit)
	
	inst.mubiao = nil

	----每两天消耗一个幽魂（960秒）
	inst:DoPeriodicTask(960, function()
        if inst.components.container then
            for i = 1, inst.components.container:GetNumSlots() do
                local item = inst.components.container:GetItemInSlot(i)
                if item and item.prefab == "gw_soul_ball" then
                    if item.components.stackable and item.components.stackable:StackSize() > 0 then
                        item.components.stackable:Get(1):Remove()
                        break
                    end
                end
            end
        end
    end)

    return inst
end

--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--
local function fxfn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst.AnimState:SetBank("swap_hundengfx")
	inst.AnimState:SetBuild("swap_hundengfx")
	inst.AnimState:PlayAnimation("idle",true)

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    inst.persists = false

	return inst
end

----------------------------------------------------------------------
return Prefab("gw_hundeng", fn, assets),
		Prefab("swap_hundengfx", fxfn, assets)