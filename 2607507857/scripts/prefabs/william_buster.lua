local prefabs =
{

}

    local assets =
    {
	Asset("ANIM", "anim/william_buster.zip"),
	Asset("ANIM", "anim/william_buster_empty.zip"),
        Asset("SOUND", "sound/maxwell.fsb"),
    }

SetSharedLootTable("buster",
{
    {'cutstone',          1},
    {'transistor',          1},
    {'cutstone',          1},
    {'pigskin',          1},

})

SetSharedLootTable("bustergadget",
{
    {'williamgadget',          1},
    {'cutstone',          1},
    {'pigskin',          1},

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

local brain = require "brains/williambusterbrain"

local function LevelUp(inst, amount)
	if inst.level < 3 and amount ~= nil then
	inst.level = inst.level + amount
	if inst.sg ~= nil then
	inst.sg:GoToState("upgraded")
	end
end
	if inst.level > 3 then inst.level = 3 end

	inst:DoTaskInTime(0, function()
		inst:AddTag("level"..inst.level)

        inst.components.health:SetAbsorptionAmount(0+inst.level*0.05)
	if inst.components.combat ~= nil then
    inst.components.combat:SetDefaultDamage(TUNING.WILLIAM_BUSTER_DAMAGE+(inst.level*3))
	end
	end)
end

local function OnAttacked(inst, data)
    if data.attacker ~= nil then
        if data.attacker.components.petleash ~= nil and
            data.attacker.components.petleash:IsPet(inst) then
        elseif data.attacker.components.combat ~= nil then
            inst.components.combat:SuggestTarget(data.attacker)
        end
    end
end

local function OnFuelEmpty(inst)
    inst.sg:GoToState("powerdown")
end

local function OnAddFuel(inst)
	inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/machine_fuel")
	if inst.sg ~= nil then
    inst.sg:GoToState("fed")
	end
end

local function fuelupdate(inst)
        if inst.components.fueled ~= nil
            and inst.components.fueled.currentfuel <= inst.components.fueled.maxfuel*0.1  then
    inst.AnimState:AddOverrideBuild("william_buster_empty")
                --inst.AnimState:SetBuild("william_buster_empty")
		else
    inst.AnimState:ClearOverrideBuild("william_buster_empty")
	end
    end

local function retargetfn(inst)
    --Find things attacking leader
    local leader = inst.components.follower:GetLeader()
    return leader ~= nil
        and FindEntity(
            leader,
            TUNING.SHADOWWAXWELL_TARGET_DIST,
            function(guy)
                return guy ~= inst
                    and (guy.components.combat:TargetIs(leader) or
                        guy.components.combat:TargetIs(inst))
                    and inst.components.combat:CanTarget(guy)
            end,
            { "_combat" }, -- see entityreplica.lua
            { "playerghost", "INLIMBO" }
        )
        or nil
end

local function keeptargetfn(inst, target)
    --Is your leader nearby and your target not dead? Stay on it.
    --Match KEEP_WORKING_DIST in brain
    return inst.components.follower:IsNearLeader(14)
        and inst.components.combat:CanTarget(target)
		and target.components.minigame_participator == nil
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
    return (afflicter ~= nil and afflicter:HasTag("quakedebris")) or (afflicter ~= nil and afflicter:HasTag("epic") and afflicter.components.combat.target ~= inst)
end


local function MakeAlive(inst, doer)
    local pt = inst:GetPosition()
  local respawned = doer.components.petleash:SpawnPetAt(pt.x, 0, pt.z, "williambuster")
	if respawned ~= nil then
	respawned.components.fueled.currentfuel = inst.components.fueled.currentfuel
	respawned.components.health:SetCurrentHealth(inst.components.health.currenthealth)
	respawned.Transform:SetRotation(inst.Transform:GetRotation())
        respawned.sg:GoToState("revived")
	respawned.level = inst.level
	respawned:PushEvent("levelup")
	inst:Remove()
	end
end

local function onworked(inst)
	if inst.sg ~= nil then
	inst.sg:GoToState("hit")
	end
end

local function OnHammered(inst, worker)
    inst.components.lootdropper:SetChanceLootTable("bustergadget")
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
    inst.entity:AddMiniMapEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddDynamicShadow()
        inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("williambuster.png")

        inst.DynamicShadow:SetSize(1.5, 1)

        inst.Transform:SetFourFaced()

    MakeCharacterPhysics(inst, 50, .5)

	inst.level = 0

        inst.Physics:SetCollides(false)
	inst:DoTaskInTime(0, function() inst.Physics:SetCollides(true) end)

    inst.AnimState:SetBank("knight")
    inst.AnimState:SetBuild("william_buster")
        inst.AnimState:PlayAnimation("idle_loop", true)
    inst.Transform:SetScale(0.8, 0.8, 0.8)

        inst:AddTag("willfollower")
        inst:AddTag("tiddlevirusimmune")
        inst:AddTag("willminion")
        inst:AddTag("companion")
        inst:AddTag("NOBLOCK")
        inst:AddTag("mech")

    inst:SetPrefabNameOverride("williambuster")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end


	inst:AddComponent("willyraise")
    inst.components.willyraise:SetOnRiseFn(MakeAlive)
    inst.components.willyraise:SetOnLowerFn(OnFuelEmpty)

        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(TUNING.WILLIAM_BUSTER_HEALTH)
    inst.components.health:StartRegen(TUNING.WILLIAM_ROBOT_REGEN, TUNING.WILLIAM_ROBOT_REGENPERIOD)
        inst.components.health.redirect = nodebrisdmg
                inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("buster")
    inst.components.lootdropper:SetLootSetupFn(lootsetfn)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("fueled")
    inst.components.fueled:SetTakeFuelFn(OnAddFuel)
    inst.components.fueled.accepting = true
    inst.components.fueled:InitializeFuelLevel(TUNING.WILLIAM_BUSTER_MAXFUEL)
    inst.components.fueled.bonusmult = 5

        inst.OnPreLoad = onload
        inst.OnSave = onsave

        inst:ListenForEvent("levelup", LevelUp)

        return inst
    end

	--ACTIVE BUSTER-----------
	
    local function active(inst)
        local inst = fn(inst)

    inst.MiniMapEntity:SetCanUseCache(false)

    MakeCharacterPhysics(inst, 50, .5)

        if not TheWorld.ismastersim then
            return inst
        end

	inst:AddTag("alive")
        inst:AddTag("scarytoprey")
        inst:AddTag("buster")

    inst.components.fueled:SetUpdateFn(fuelupdate)
    inst.components.fueled:SetDepletedFn(OnFuelEmpty)

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.WILLIAM_BUSTER_WALK_SPEED
        inst.components.locomotor:SetAllowPlatformHopping(true)
        inst:AddComponent("embarker")

    inst:SetStateGraph("SGwilliambuster")

        inst:AddComponent("combat")
    inst.components.combat:SetRetargetFunction(2, retargetfn) --Look for leader's target.
    inst.components.combat:SetKeepTargetFunction(keeptargetfn) --Keep attacking while leader is near.
    inst.components.combat.hiteffectsymbol = "spring"
    inst.components.combat:SetAttackPeriod(TUNING.WILLIAM_BUSTER_ATTACK_PERIOD)
        inst.components.combat:SetRange(TUNING.WILLIAM_BUSTER_ATTACK_RANGE)
    inst.components.combat:SetDefaultDamage(TUNING.WILLIAM_BUSTER_DAMAGE)

        inst:ListenForEvent("attacked", OnAttacked)

        inst:AddComponent("follower")
        inst.components.follower:KeepLeaderOnAttacked()
        inst.components.follower.keepdeadleader = true
        inst.components.follower.keepleaderduringminigame = true

    inst.components.fueled:StartConsuming()

    MakeHauntablePanic(inst)

        inst:SetBrain(brain)

    MakeMediumBurnableCharacter(inst, "spring")
    MakeMediumFreezableCharacter(inst, "spring")
inst.components.burnable.ignorefuel = true

        return inst
    end

-- EMPTY BUSTER -----------------

local function onload(inst, data)
    if data ~= nil and data.william ~= nil then
        inst.william = data.william
    end
end

local function onsave(inst, data)
    data.william = inst.william ~= nil and inst.william or nil
end



local function revivetest(newsection, oldsection, inst, doer)
	if newsection >= 0 then
    local pt = inst:GetPosition()
	if doer ~= nil and doer:HasTag("williamcrafter") then
		MakeAlive(inst, doer)
		end
	end
end

    local function empty(inst)
        local inst = fn(inst)

    inst.AnimState:SetBank("knight")
    inst.AnimState:AddOverrideBuild("william_buster_empty")
    inst.AnimState:SetBuild("william_buster")
        inst.AnimState:PlayAnimation("sleep_loop", false)
        inst.AnimState:Pause()
    inst.Transform:SetScale(0.8, 0.8, 0.8)

    MakeCharacterPhysics(inst, 80, .25)
	inst.Physics:SetFriction(1)

        if not TheWorld.ismastersim then
            return inst
        end

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
            inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(OnHammered)
    inst.components.workable:SetOnWorkCallback(onworked)

        inst:AddTag("Notarget")

--    inst.components.fueled.currentfuel = 0

    MakeHauntableWork(inst)

        return inst
    end


local function onbuilt(inst, builder)
    local theta = math.random() * 2 * PI
    local pt = builder:GetPosition()
    local radius = math.random(1, 2)
    local offset = FindWalkableOffset(pt, theta, radius, 12, true, true, NoHoles)
    if offset ~= nil then
        pt.x = pt.x + offset.x
        pt.z = pt.z + offset.z
    end
   local pet = builder:HasTag("williamcrafter") and builder.components.petleash:SpawnPetAt(pt.x, 0, pt.z, "williambuster") or SpawnPrefab("williambuster_empty")
	if pet ~= nil then
	    if pet.sg ~= nil then
         	pet.sg:GoToState("spawn") 
	    else
		pet.Transform:SetPosition(pt.x, 0, pt.z)
	pet.SoundEmitter:PlaySound("dontstarve/common/chesspile_repair")
	SpawnPrefab("small_puff").Transform:SetPosition(pt.x, 0, pt.z)
	    end
	pet.components.fueled.currentfuel = pet.components.fueled.currentfuel*0.9
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


    inst.OnSave = onsave
    inst.OnLoad = onload
        inst.OnBuiltFn = onbuilt

        return inst
    end


    return Prefab("williambuster", active, assets, prefabs),
    Prefab("williambuster_builder", builder, assets, prefabs),
    Prefab("williambuster_empty", empty, assets, prefabs)



--------------------------------------------------------------------------
