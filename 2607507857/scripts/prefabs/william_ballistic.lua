local prefabs =
{

}

    local assets =
    {
	Asset("ANIM", "anim/william_ballistic.zip"),
        Asset("SOUND", "sound/maxwell.fsb"),
    }

SetSharedLootTable("ballistic",
{
    {'cutstone',          1},
    {'transistor',          1},
    {'goldnugget',          1},
    {'nitre',          1},

})

SetSharedLootTable("ballisticgadget",
{
    {'williamgadget',          1},
    {'goldnugget',          1},
    {'nitre',          1},

})

local function lootsetfn(lootdropper)
    local loot = {}
    local amount = lootdropper.inst.level*0.75
	if amount < 1 then amount = 1 end

		if lootdropper.inst.level > 0 then
    		for k = 1, amount do
            table.insert(loot, "gears")
		end
		end
		

    lootdropper:SetLoot(loot)
end

local function LevelUp(inst, amount)
	if inst.level < 3 and amount ~= nil then
	inst.level = inst.level + amount
	if inst.sg ~= nil then
	inst.sg:GoToState("fed")
	end
end

	if inst.level > 3 then inst.level = 3 end

	inst:DoTaskInTime(0, function()
		inst:AddTag("level"..inst.level)

	if inst.components.combat ~= nil then
    inst.components.combat:SetAttackPeriod(TUNING.WILLIAM_BALLISTIC_ATTACK_PERIOD/(1+inst.level*0.3))
	end
	end)
end

local brain = require "brains/williamballisticbrain"

local function ZapFX(inst)
            local fx = SpawnPrefab("electrichitsparks")
            fx.entity:SetParent(inst.entity)
            fx.entity:AddFollower()
            fx.Follower:FollowSymbol(inst.GUID, "body", 5, -120, 0)

	end

local function maketurret(inst, pt, charge)
    local bot = SpawnPrefab("williamballistic")
    if bot ~= nil then
        bot.Physics:SetCollides(false)
        bot.Physics:Teleport(pt.x, 0, pt.z)
        bot.Physics:SetCollides(true)
 	bot.sg:GoToState("revived", charge)
	bot.components.health:SetCurrentHealth(inst.components.health.currenthealth)
	bot.components.fueled.currentfuel = inst.components.fueled.currentfuel
	bot.level = inst.level
	bot:PushEvent("levelup")
	inst:Remove()
    end
end

local function MakeAlive(inst)
	local pt = Vector3(inst.Transform:GetWorldPosition())
	maketurret(inst, pt)	
end


local function OnAddFuel(inst)
	inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/machine_fuel")
	if inst.components.inventoryitem == nil then 
    inst.sg:GoToState("fed")
--	elseif inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner == nil then
--	local pt = Vector3(inst.Transform:GetWorldPosition())
--	maketurret(inst, pt)
	end
	
end

local function fuelupdate(inst)
    end

local PLACER_SCALE = 1.6

local function retargetfn(inst)
    local playertargets = {}
    for i, v in ipairs(AllPlayers) do
        if v.components.combat.target ~= nil then
            playertargets[v.components.combat.target] = true
        end
    end

    return FindEntity(inst, PLACER_SCALE*10,
        function(guy)
            return inst.components.combat:CanTarget(guy)
                and (playertargets[guy] or
                    (guy.components.combat.target ~= nil and (guy.components.combat.target:HasTag("player") or guy.components.combat.target:HasTag("willminion"))))
        end,
        { "_combat" }, --see entityreplica.lua
        { "INLIMBO", "player" }
    )
end

local function shouldKeepTarget(inst, target)
    return target ~= nil
        and target:IsValid()
        and target.components.health ~= nil
        and not target.components.health:IsDead()
        and inst:IsNear(target, 20)
end


local function getstatus(inst, viewer)
            return inst.components.fueled:IsEmpty() and "EMPTY"
	    or inst.components.fueled.currentfuel / inst.components.fueled.maxfuel <= .3 and "CRITICALFUEL"
            or inst.components.fueled.currentfuel / inst.components.fueled.maxfuel <= .6 and "LOWFUEL"
            or "FINE"
end
local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

local function nodebrisdmg(inst, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
    return (afflicter ~= nil and afflicter:HasTag("quakedebris"))
end

local function EquipWeapon(inst)
    if inst.components.inventory ~= nil and not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
        local weapon = CreateEntity()
        --[[Non-networked entity]]
        weapon.entity:AddTransform()
        weapon:AddComponent("weapon")
        weapon.components.weapon:SetDamage(TUNING.WILLIAM_BALLISTIC_DAMAGE)
        weapon.components.weapon:SetRange(inst.components.combat.attackrange, inst.components.combat.attackrange+4)
        weapon.components.weapon:SetProjectile("william_charge")
        weapon.components.weapon:SetElectric()
        weapon:AddComponent("inventoryitem")
        weapon.persists = false
        weapon.components.inventoryitem:SetOnDroppedFn(inst.Remove)
        weapon:AddComponent("equippable")

        inst.components.inventory:Equip(weapon)
    end
end


local function OnAttacked(inst, data)
    local attacker = data ~= nil and data.attacker or nil
    if attacker ~= nil and not PreventTargetingOnAttacked(inst, attacker, "player") then
        inst.components.combat:SetTarget(attacker)
    end
end



local function onlightning(inst)
	local pt = Vector3(inst.Transform:GetWorldPosition())
	inst.components.fueled:SetPercent(1)
	ZapFX(inst)
	if inst.sg ~= nil then
	inst.sg:GoToState("hit")
	elseif inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner == nil then
--    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PlayAnimation("hit_shield", false)
	end
end

local function onworked(inst)
	if inst.sg~= nil then
	inst.sg:GoToState("hit")
	else
    inst.AnimState:PlayAnimation("hit_shield")
	end
end

local function OnHammered(inst, worker)
	if inst:HasTag("alive") then
    inst.components.lootdropper:SetChanceLootTable("ballisticgadget")
	else
	    inst.components.lootdropper:SetChanceLootTable(nil)
	end
    inst.components.lootdropper:DropLoot()
        local fx = SpawnPrefab("collapse_small")
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx:SetMaterial("metal")
    inst:Remove()
end


local function onsave(inst, data)
	if inst.level ~= nil then
    data.level = inst.level
	end
end

local function onload(inst, data)
    if data ~= nil and data.level ~= nil then
	inst.level = data.level 
	if inst.level > 0 then inst:DoTaskInTime(0,LevelUp) end
    end

end




    local function fn(inst)
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()
        inst.entity:AddDynamicShadow()

    inst.MiniMapEntity:SetIcon("williamballistic.png")

    inst.AnimState:SetBank("spider_hider")
    inst.AnimState:SetBuild("william_ballistic")
        inst.AnimState:PlayAnimation("idle", true)
   inst.Transform:SetScale(0.9, 0.9, 0.9)

	inst:AddTag("lightningrod")
        inst:AddTag("tiddlevirusimmune")
        inst:AddTag("willminion")
        inst:AddTag("companion")
        inst:AddTag("NOBLOCK")
        inst:AddTag("mech")
        inst:AddTag("ballistic")

    inst:SetPrefabNameOverride("williamballistic")

	inst.level = 0


        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end


        inst:AddComponent("health")
	inst.components.health.canmurder = false
        inst.components.health:SetMaxHealth(TUNING.WILLIAM_BALLISTIC_HEALTH)
       -- inst.components.health.nofadeout = true
    inst.components.health:StartRegen(TUNING.WILLIAM_ROBOT_REGEN, TUNING.WILLIAM_ROBOT_REGENPERIOD)
        inst.components.health.redirect = nodebrisdmg
                inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLootSetupFn(lootsetfn)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:ListenForEvent("lightningstrike", onlightning)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
            inst.components.workable:SetWorkLeft(2)
    inst.components.workable:SetOnFinishCallback(OnHammered)
    inst.components.workable:SetOnWorkCallback(onworked)

    inst:AddComponent("fueled")
    inst.components.fueled:SetTakeFuelFn(OnAddFuel)
    inst.components.fueled.accepting = true
    inst.components.fueled:SetUpdateFn(fuelupdate)
    inst.components.fueled:InitializeFuelLevel(TUNING.WINONA_BATTERY_LOW_MAX_FUEL_TIME*5)
    inst.components.fueled.fueltype = FUELTYPE.CHEMICAL
    inst.components.fueled.bonusmult = 3

        inst.OnPreLoad = onload
        inst.OnSave = onsave

        inst:ListenForEvent("levelup", LevelUp)


        return inst
    end

	--ACTIVE-------------


local function OnDismantle(inst)--, doer)
    local item = SpawnPrefab("williamballistic_empty")
	if item ~= nil then
    item.Transform:SetPosition(inst.Transform:GetWorldPosition())
    item.DynamicShadow:SetSize(2.5, 1)
    item.AnimState:PlayAnimation("hide")
    item:DoTaskInTime(9*FRAMES, function(item) item.DynamicShadow:SetSize(0, 0)  end)
	item.components.health:SetCurrentHealth(inst.components.health.currenthealth)
	item.components.fueled.currentfuel = inst.components.fueled.currentfuel
            item.SoundEmitter:PlaySound("dontstarve/common/together/catapult/hit", nil, .5)
            item.SoundEmitter:PlaySound("dontstarve/common/together/battery/down")
	item.level = inst.level
	item:PushEvent("levelup")
    inst:Remove()
	end
end


    local function active(inst)
        local inst = fn(inst)

    inst.DynamicShadow:SetSize(2.5, 1)

    MakeObstaclePhysics(inst, 0.25)
        inst.Transform:SetFourFaced()
        if not TheWorld.ismastersim then
            return inst
        end

	inst:AddTag("alive")
        inst:AddTag("scarytoprey")

    inst:SetStateGraph("SGwilliamballistic")


    inst:AddComponent("portablewillybot")
    inst.components.portablewillybot:SetOnDismantleFn(OnDismantle)

        inst:AddComponent("combat")
    inst.components.combat:SetRetargetFunction(1, retargetfn)
    inst.components.combat:SetKeepTargetFunction(shouldKeepTarget)
    inst.components.combat.hiteffectsymbol = "body"
    inst.components.combat:SetAttackPeriod(TUNING.WILLIAM_BALLISTIC_ATTACK_PERIOD)
    inst.components.combat:SetRange(TUNING.WINONA_CATAPULT_MAX_RANGE)
    inst.components.combat:SetDefaultDamage(TUNING.WILLIAM_BALLISTIC_DAMAGE)

        inst:ListenForEvent("attacked", OnAttacked)

    inst.components.lootdropper:SetChanceLootTable("ballistic")


    inst.components.fueled:SetDepletedFn(OnDismantle)
        inst:SetBrain(brain)

    inst:AddComponent("inventory")
    inst:DoTaskInTime(0, function() EquipWeapon(inst) end)
        inst.components.fueled:StartConsuming()

    MakeMediumFreezableCharacter(inst, "body")

    MakeHauntableWork(inst)

        return inst
    end

-- EMPTY ballistic



local function ondeploy(inst, pt, deployer)
	if not inst.components.fueled:IsEmpty() then
	maketurret(inst, pt, false)
	else
        inst.Physics:Teleport(pt.x, 0, pt.z)
	end
	end

    local function empty(inst)
        local inst = fn(inst)

    inst.AnimState:SetBank("spider_hider")
    inst.AnimState:SetBuild("william_ballistic")
        inst.AnimState:PlayAnimation("hide_loop", true)
    inst.Transform:SetScale(0.9, 0.9, 0.9)

    inst:AddTag("portableitem")

    MakeInventoryPhysics(inst)

        if not TheWorld.ismastersim then
            return inst
        end

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/williamballistic_empty.xml"   
   inst.components.inventoryitem:ChangeImageName("williamballistic_empty")
    inst.components.inventoryitem:SetSinks(true)

    MakeHauntableLaunch(inst)

    inst:AddComponent("deployable")
    inst.components.deployable.restrictedtag = "william"
    inst.components.deployable.ondeploy = ondeploy

        return inst
    end




local function placer_postinit_fn(inst)

    local placer2 = CreateEntity()

    --[[Non-networked entity]]
    placer2.entity:SetCanSleep(false)
    placer2.persists = false

    placer2.entity:AddTransform()
    placer2.entity:AddAnimState()

    placer2:AddTag("CLASSIFIED")
    placer2:AddTag("NOCLICK")
    placer2:AddTag("placer")

    local s = 0.9 / PLACER_SCALE
    placer2.Transform:SetScale(s, s, s)

    placer2.AnimState:SetBank("spider_hider")
    placer2.AnimState:SetBuild("william_ballistic")
    placer2.AnimState:PlayAnimation("idle")
    placer2.AnimState:SetLightOverride(1)

    placer2.entity:SetParent(inst.entity)

    inst.components.placer:LinkEntity(placer2)
end

    return Prefab("williamballistic", active, assets, prefabs),
    Prefab("williamballistic_empty", empty, assets, prefabs),
    MakePlacer("williamballistic_empty_placer", "firefighter_placement", "firefighter_placement", "idle", true, nil, nil, PLACER_SCALE, nil, nil, placer_postinit_fn)


--------------------------------------------------------------------------
