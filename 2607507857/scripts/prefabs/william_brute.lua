local prefabs =
{

}

    local assets =
    {
	Asset("ANIM", "anim/william_brute.zip"),
	Asset("ANIM", "anim/william_upgrades.zip"),
	Asset("ANIM", "anim/william_garyhat_swap.zip"),
    Asset("ANIM", "anim/merm_actions.zip"),
    Asset("ANIM", "anim/merm_guard_transformation.zip"),    
    Asset("ANIM", "anim/ds_pig_boat_jump.zip"),
    Asset("ANIM", "anim/ds_pig_basic.zip"),
    Asset("ANIM", "anim/ds_pig_actions.zip"),
    Asset("ANIM", "anim/ds_pig_attacks.zip"),
    }

SetSharedLootTable("brute",
{
    {'cutstone',          1},
    {'transistor',          1},
    {'log',          1},
    {'log',          1},
    {'log',          1},
    {'cutreeds',          1},
    {'cutreeds',          1},
    {'cutreeds',          1},
    {'cutreeds',          1},
})

SetSharedLootTable("brutegadget",
{
    {'williamgadget',          1},
    {'armorwood',          1},
    {'cutreeds',          1},
    {'cutreeds',          1},
    {'cutreeds',          1},
    {'cutreeds',          1},

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

local brain = require "brains/williambrutebrain"

local function RememberKnownLocation(inst)
--    inst.components.knownlocations:RememberLocation("home", inst:GetPosition())
end

local function IsTauntable(inst, target)
    return not (target.components.health ~= nil and target.components.health:IsDead())
        and target.components.combat ~= nil
        and not target.components.combat:TargetIs(inst)
        and target.components.combat:CanTarget(inst)
        and  (   target.components.combat:HasTarget() and
                    (   target.components.combat.target:HasTag("player") or
                        (target.components.combat.target:HasTag("companion") and target.components.combat.target.prefab ~= inst.prefab)
                    )
                )
end


local function TauntCreatures(inst)
    if not inst.components.health:IsDead() then
        local x, y, z = inst.Transform:GetWorldPosition()
        for i, v in ipairs(TheSim:FindEntities(x, y, z, 7, { "_combat", "locomotor" }, { "INLIMBO", "player", "companion", "epic", "notaunt", "shadow" })) do
            if IsTauntable(inst, v) then
                v.components.combat:SetTarget(inst)
            end
        end
    end
end

local function OnHammered(inst, worker)
	if worker:HasTag("player") then
    inst.components.lootdropper:SetLootSetupFn(lootsetfn)
	end
    inst.components.lootdropper:SetChanceLootTable("brutegadget")
    inst.components.lootdropper:DropLoot()
        local fx = SpawnPrefab("collapse_small")
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx:SetMaterial("metal")
    inst:Remove()
end


local function _ShareTargetFn(dude)
    return dude:HasTag("willminion") and not dude:HasTag("butler")
end

local function OnAttacked(inst, data)
    if data.attacker ~= nil then
if data.attacker.components.combat ~= nil then
            inst.components.combat:SuggestTarget(data.attacker)
		if not data.attacker:HasTag("william") then
    inst.components.combat:ShareTarget(data.attacker, 15, _ShareTargetFn, 5)
		end
        end
    end
end




local function retargetfn(inst)
	local exclude_tags = { "playerghost", "INLIMBO", "abigail", "playermonster" }
	if inst.components.minigame_spectator ~= nil then
		table.insert(exclude_tags, "player") -- prevent spectators from auto-targeting webber
	end

    local playertargets = {}
    for i, v in ipairs(AllPlayers) do
        if v.components.combat.target ~= nil then
            playertargets[v.components.combat.target] = true
        end
    end

    local oneof_tags = {"monster", "hostile"}

    return not inst:IsInLimbo()
        and FindEntity(
                inst,
                20,
                function(guy)
                    return inst.components.combat:CanTarget(guy) and playertargets[guy] or
                    (guy.components.combat.target ~= nil and (guy.components.combat.target:HasTag("player") or guy.components.combat.target:HasTag("willminion")))
			--inst.components.combat:CanTarget(guy)
                end,
                { "_combat" }, -- see entityreplica.lua
                exclude_tags
--                oneof_tags
            )
        or nil
end

local function keeptargetfn(inst, target)
    --give up on dead guys, or guys in the dark, or werepigs
    return inst.components.combat:CanTarget(target)
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
    return afflicter ~= nil and afflicter:HasTag("quakedebris")
end

local function CanInteract(inst)
    return not inst.components.fueled:IsEmpty()
end

local function onworked(inst)
	if inst:HasTag("alive") then
	inst.sg:GoToState("hit")
	end
end

local function TurnOff(inst, doer, instant)
    inst.on = false

		if inst._task ~= nil then
	            inst._task:Cancel()
            inst._task = nil
        end
	    MakeHauntableWork(inst)
	inst:RemoveTag("scarytoprey")
	inst:RemoveTag("alive")
	inst:AddTag("notarget")

    inst.MiniMapEntity:SetCanUseCache(true)

	if inst.components.workable == nil then
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
            inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(OnHammered)
    inst.components.workable:SetOnWorkCallback(onworked)
	end

    inst.components.fueled:StopConsuming()
	inst.components.combat:SetTarget(nil)
    inst.components.combat:SetRetargetFunction(nil)
    inst.components.combat:SetKeepTargetFunction(nil)
--	inst.components.health:SetInvincible(true)
    inst.sg:GoToState("turn_off")
end


local function TurnOn(inst, doer, instant)
    inst.on = true

    if inst._task == nil then
    inst._taunttask = inst:DoPeriodicTask(2, TauntCreatures, 0)
	end

    inst.MiniMapEntity:SetCanUseCache(false)

    MakeHauntablePanic(inst)
	inst:AddTag("scarytoprey")
	inst:AddTag("alive")
	inst:RemoveTag("notarget")

	if inst.components.workable ~= nil then
	inst:RemoveComponent("workable")
		end

    inst.components.fueled:StartConsuming()
	inst.components.health:SetInvincible(false)
    inst.components.combat:SetRetargetFunction(2, retargetfn) --Look for leader's target.
    inst.components.combat:SetKeepTargetFunction(keeptargetfn) --Keep attacking while leader is near.
    inst.sg:GoToState("turn_on")
end


local function OnFuelEmpty(inst)
    inst.components.willyraise:Lower()
end

local function OnAddFuel(inst)
	inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/machine_fuel")
    if inst.on == false then
--    inst.components.willyraise:Rise(inst, nil)
	else
    inst.sg:GoToState("fed")
    end
	
end

local function LevelUp(inst, amount)
	if inst.level < 3 and amount ~= nil then
	inst.level = inst.level + amount
	if inst.on == true then
	inst.sg:GoToState("upgraded")
	end
end

	if inst.level > 3 then inst.level = 3 end

	inst:DoTaskInTime(0, function()

    local health_percent = inst.components.health:GetPercent()

		inst:AddTag("level"..inst.level)
--            inst.AnimState:OverrideSymbol("swap_hat", "william_upgrades", "swap_brute"..inst.level)

    inst.components.health:StopRegen()
    inst.components.health:StartRegen(TUNING.WILLIAM_ROBOT_REGEN+(inst.level*5), TUNING.WILLIAM_ROBOT_REGENPERIOD)
        inst.components.health:SetAbsorptionAmount(0+inst.level*0.08)
	end)

end

local function onsave(inst, data)
	if inst.on ~= nil then
    data.on = inst.on
	end
	if inst.level ~= nil then
    data.level = inst.level
	end
end

local function onload(inst, data)
    if data ~= nil and data.on ~= nil then
	inst.on = data.on 
    end
    if data ~= nil and data.level ~= nil then
	inst.level = data.level 
	if inst.level > 0 then inst:DoTaskInTime(0,LevelUp) end
    end
	if inst.on == true then
    inst.components.willyraise:Rise(inst, nil, true)
	else
    inst.components.willyraise:Lower(inst, nil, true)
	end

end

local function onbuilt(inst, builder)
    inst.components.knownlocations:RememberLocation("home", inst:GetPosition())
    inst.components.willyraise:Rise()
end

local PLACER_SCALE = 1.5

    local function fn(inst)
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddDynamicShadow()
        inst.entity:AddNetwork()
    inst.entity:AddMiniMapEntity()

    inst.MiniMapEntity:SetIcon("williambrute.png")

	inst.level = 0

        inst.DynamicShadow:SetSize(2, 1.25)

        inst.Transform:SetFourFaced()

        inst.AnimState:SetBank("pigman")
    inst.AnimState:SetBuild("william_brute")
        inst.AnimState:PlayAnimation("sit_idle", true)

    MakeCharacterPhysics(inst, 0.9, .5)
    inst.Transform:SetScale(1.7, 1.7, 1.7)

	inst:AddTag("alive")
        inst:AddTag("tiddlevirusimmune")
        inst:AddTag("willminion")
        inst:AddTag("companion")
        inst:AddTag("NOBLOCK")
        inst:AddTag("mech")
        inst:AddTag("buster")

    inst._task = nil
    inst.on = nil

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

    inst:AddComponent("locomotor")
        inst.components.locomotor.runspeed = TUNING.WILLIAM_BRUTE_RUN_SPEED
    inst.components.locomotor.walkspeed = TUNING.WILLIAM_BRUTE_WALK_SPEED

        inst.components.locomotor:SetAllowPlatformHopping(true)
        inst:AddComponent("embarker")

    inst:SetStateGraph("SGwilliambrute")

        inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "pig_torso"
    inst.components.combat:SetAttackPeriod(TUNING.WILLIAM_BRUTE_ATTACK_PERIOD)
        inst.components.combat:SetRange(TUNING.WILLIAM_BRUTE_ATTACK_RANGE)
    inst.components.combat:SetDefaultDamage(TUNING.WILLIAM_BRUTE_DAMAGE)

    MakeMediumBurnableCharacter(inst, "pig_torso")
    MakeMediumFreezableCharacter(inst, "pig_torso")

inst.components.burnable.ignorefuel = true

        inst:ListenForEvent("attacked", OnAttacked)

	inst:AddComponent("willyraise")
    inst.components.willyraise:SetOnRiseFn(TurnOn)
    inst.components.willyraise:SetOnLowerFn(TurnOff)

        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(TUNING.WILLIAM_BRUTE_HEALTH)
       -- inst.components.health.nofadeout = true
    inst.components.health:StartRegen(TUNING.WILLIAM_ROBOT_REGEN, TUNING.WILLIAM_ROBOT_REGENPERIOD)
        inst.components.health.redirect = nodebrisdmg
                inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("brute")
    inst.components.lootdropper:SetLootSetupFn(lootsetfn)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("fueled")
    inst.components.fueled:SetTakeFuelFn(OnAddFuel)
    inst.components.fueled.accepting = true
    inst.components.fueled:InitializeFuelLevel(TUNING.WILLIAM_BRUTE_MAXFUEL)
    inst.components.fueled.bonusmult = 5
    inst.components.fueled:SetDepletedFn(OnFuelEmpty)
    inst.components.fueled:StartConsuming()

        inst:ListenForEvent("levelup", LevelUp)


        inst:SetBrain(brain)

    inst:AddComponent("knownlocations")

        inst.OnPreLoad = onload
        inst.OnSave = onsave

        return inst
    end


    local function gary(inst)
        local inst = fn()

    inst:SetPrefabNameOverride("williambrute")
            inst.AnimState:OverrideSymbol("swap_hat", "william_garyhat_swap", "swap_hat")

    inst:AddTag("_named")

        if not TheWorld.ismastersim then
            return inst
        end
    inst:RemoveTag("_named")
	inst:AddComponent("named")
	inst.components.named:SetName("Gary")
        return inst
    end


local function onbuilt(inst, builder)
	local type = math.random(1, 100) == 100 and "williambrute_gary" or "williambrute"
    local robot = SpawnPrefab(type)
	if robot ~= nil then
    robot.Transform:SetPosition(inst.Transform:GetWorldPosition())
    robot.components.knownlocations:RememberLocation("home", inst:GetPosition())
    robot.components.willyraise:Rise()
        robot.SoundEmitter:PlaySound("dontstarve/common/chesspile_repair")
                    local x, y, z = robot.Transform:GetWorldPosition()
    SpawnPrefab("maxwell_smoke").Transform:SetPosition(x, y, z)
	inst:Remove()
	end
end

    local function builder()
        local inst = CreateEntity()

        inst.entity:AddTransform()

        inst:AddTag("CLASSIFIED")

        --[[Non-networked entity]]
        inst.persists = false

        --Auto-remove if not spawned by builder
        inst:DoTaskInTime(0, inst.Remove)

        if not TheWorld.ismastersim then
            return inst
        end


        inst.OnBuiltFn = onbuilt

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

    local s = 1.7 / PLACER_SCALE
    placer2.Transform:SetScale(s, s, s)

    placer2.AnimState:SetBank("william_brute")
    placer2.AnimState:SetBuild("william_brute")
    placer2.AnimState:PlayAnimation("sit_idle", true)
    placer2.AnimState:SetLightOverride(1)

    placer2.entity:SetParent(inst.entity)

    inst.components.placer:LinkEntity(placer2)
end


    return Prefab("williambrute", fn, assets, prefabs),
    Prefab("williambrute_gary", gary, assets, prefabs),
    MakePlacer("williambrute_placer", "william_brute", "william_brute", "sit_idle", false, nil, nil, 1.7),
	Prefab("williambrute_builder", builder, assets, prefabs)



--------------------------------------------------------------------------
