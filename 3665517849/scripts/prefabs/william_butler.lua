require "prefabutil"
require "recipe"
require "modutil"

local prefabs =
{

}

    local assets =
    {
	Asset("ANIM", "anim/william_butler.zip"),
    Asset("ANIM", "anim/ui_chest_3x2.zip"),
    Asset("ANIM", "anim/ui_chest_3x1.zip"),
        Asset("SOUND", "sound/maxwell.fsb"),
    }

SetSharedLootTable("butler",
{
    {'goldnugget',          1},
})

SetSharedLootTable("butlergadget",
{
    {'williamgadget',          1},
    {'goldnugget',          1},
    {'silk',          1},

})

local brain = require "brains/williambutlerbrain"


local function MakeAlive(inst, doer)
    local pt = inst:GetPosition()
        --inst.Physics:SetCollides(false)
  local respawned = doer.components.petleash:SpawnPetAt(pt.x, 0, pt.z, "williambutler")
	--if respawned ~= nil then
	respawned.components.fueled.currentfuel = inst.components.fueled.currentfuel
	respawned.components.health:SetCurrentHealth(inst.components.health.currenthealth)
	respawned.Transform:SetRotation(inst.Transform:GetRotation())
        respawned.sg:GoToState("revived")
	inst:Remove()
	--end
end

local function onfuelchange(newsection, oldsection, inst, doer)
	if newsection >= 0 then
    local pt = inst:GetPosition()
	if doer ~= nil and doer:HasTag("williamcrafter") then
		MakeAlive(inst, doer)
		end
	end
end

local function OnAddFuel(inst)
	inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/machine_fuel")

	if inst.sg ~= nil and not inst.sg:HasStateTag("busy") then
    inst.sg:GoToState("fed")
	end
end

local function OnHammered(inst, worker)
--	if worker:HasTag("player") then
--  		for k = 1, inst.level do
--   		inst.components.lootdropper:AddChanceLoot("gear", 1)
--		end
--	end
    inst.components.lootdropper:SetChanceLootTable("bustergadget")
    inst.components.lootdropper:DropLoot()
        local fx = SpawnPrefab("collapse_small")
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx:SetMaterial("metal")
    inst:Remove()
end

local function onworked(inst)
	if inst.sg ~= nil then
	inst.sg:GoToState("hit")
	end
end

local function OnFuelEmpty(inst)
    inst.sg:GoToState("powerdown")
end

local function oncook(inst, doer)

for k, v in pairs (inst.components.container.slots) do
			if v.components.cookable ~= nil then
		local leader = inst.components.follower.leader
		local cook_pos = inst:GetPosition()
			inst.sg:GoToState("cook")
	inst:DoTaskInTime(0.9, function()

if inst.components.fueled ~= nil then
        inst.components.fueled:DoDelta(-.01 * inst.components.fueled.maxfuel)
    end

	if inst.components.fueled ~= nil and not inst.components.fueled:IsEmpty() then

        local ingredient = inst.components.container:RemoveItem(v)


	--if ingredient ~= nil then  end

        v.Transform:SetPosition(cook_pos:Get())

        if not inst.components.cooker:CanCook(ingredient, inst) then
            inst.components.container:GiveItem(ingredient, nil, cook_pos)
            return false
        end

        if ingredient.components.health ~= nil and ingredient.components.combat ~= nil then
            inst:PushEvent("killed", { victim = ingredient })
        end

        local product = inst.components.cooker:CookItem(ingredient, inst)
        if product ~= nil and doer ~= nil then
            doer.components.inventory:GiveItem(product, nil, cook_pos)

            return true
        elseif ingredient:IsValid() then
            inst.components.container:GiveItem(ingredient, nil, cook_pos)
        end

	end

	end)
		end
	end
end

local function fuelupdate(inst)
        if inst.components.fueled ~= nil
            and inst.components.fueled.currentfuel <= inst.components.fueled.maxfuel*0.2  then
                inst:AddTag("lowfuel")
		else
	if inst:HasTag("lowfuel") then
    inst:RemoveTag("lowfuel")
	end
	end
    end

local function nokeeptargetfn(inst)
    return false
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

local function OnOpen(inst)
    if not inst.components.health:IsDead() then
        inst.sg:GoToState("open")
    end
end

local function OnClose(inst)
    if not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") then
        inst.sg:GoToState("close")
    end

end

local function onload(inst)
   if inst.components.fueled:IsEmpty() then
		OnFuelEmpty(inst)
	end
end


    local function fn(inst)
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddDynamicShadow()
        inst.entity:AddNetwork()
    inst.entity:AddMiniMapEntity()
        inst.DynamicShadow:SetSize(1.3, .6)
        inst.Transform:SetFourFaced()


    inst.MiniMapEntity:SetIcon("williambutler.png")

        inst.AnimState:SetBank("wilson")
        inst.AnimState:SetBuild("william_butler")
        inst.AnimState:PlayAnimation("idle")
            inst.AnimState:Hide("ARM_carry")
            inst.AnimState:Hide("HEAD_HAT")

    MakeCharacterPhysics(inst, 50, .5)
        --inst.Physics:SetCollides(true)
	--inst:DoTaskInTime(0, function() inst.Physics:SetCollides(true) end)

        inst.AnimState:OverrideSymbol("fx_wipe", "wilson_fx", "fx_wipe")
        inst.AnimState:OverrideSymbol("fx_liquid", "wilson_fx", "fx_liquid")
        inst.AnimState:OverrideSymbol("shadow_hands", "shadow_hands", "shadow_hands")
    inst.AnimState:AddOverrideBuild("player_idles_warly")


        inst:AddTag("willminion")
        inst:AddTag("willfollower")
        inst:AddTag("companion")
        inst:AddTag("NOBLOCK")
        inst:AddTag("mech")
    inst:AddTag("cooker")
   inst:AddTag("container")
    inst:AddTag("stewer")
        inst:AddTag("tiddlevirusimmune")
        inst:AddTag("williamhealable")
    inst:SetPrefabNameOverride("williambutler")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end





        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(TUNING.WILLIAM_BUTLER_HEALTH)
       -- inst.components.health.nofadeout = true
    inst.components.health:StartRegen(TUNING.WILLIAM_ROBOT_REGEN, TUNING.WILLIAM_ROBOT_REGENPERIOD)
        inst.components.health.redirect = nodebrisdmg
                inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("butler")

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

	inst:AddComponent("willyraise")
    inst.components.willyraise:SetOnRiseFn(MakeAlive)
    inst.components.willyraise:SetOnLowerFn(OnFuelEmpty)

    inst:AddComponent("fueled")
    inst.components.fueled:SetTakeFuelFn(OnAddFuel)
    inst.components.fueled.accepting = true
    inst.components.fueled:InitializeFuelLevel(TUNING.WILLIAM_BUTLER_MAXFUEL)
    inst.components.fueled.bonusmult = 5

        return inst
    end

	--ACTIVE butler
	
    local function active(inst)
        local inst = fn(inst)
    MakeCharacterPhysics(inst, 50, .5)

    inst.MiniMapEntity:SetCanUseCache(false)

        inst.Transform:SetFourFaced()

	inst:AddTag("alive")
        inst:AddTag("scarytoprey")
        inst:AddTag("willminion")
        inst:AddTag("companion")
        inst:AddTag("NOBLOCK")
        inst:AddTag("mech")
        inst:AddTag("butler")
	inst:AddTag("dangerouscooker")
	inst:AddTag("expertchef")
        inst:AddTag("tiddlevirusimmune")

        if not TheWorld.ismastersim then
            return inst
        end



 inst:AddComponent("locomotor")
        inst.components.locomotor.runspeed = TUNING.SHADOWWAXWELL_SPEED
        inst.components.locomotor:SetAllowPlatformHopping(true)
        inst:AddComponent("embarker")

        inst:SetStateGraph("SGwilliambutler")

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("williambutler")
    inst.components.container.onopenfn = OnOpen
    inst.components.container.onclosefn = OnClose
    inst.components.container.skipopensnd = true
    inst.components.container.skipclosesnd = true

        inst:AddComponent("combat")
        inst.components.combat.hiteffectsymbol = "torso"
        inst.components.combat:SetRange(3)
    inst.components.combat:SetKeepTargetFunction(nokeeptargetfn)


        inst:ListenForEvent("docookery", oncook)

        inst:AddComponent("follower")
        inst.components.follower:KeepLeaderOnAttacked()
        inst.components.follower.keepdeadleader = true
        inst.components.follower.keepleaderduringminigame = true

    inst.components.fueled:SetUpdateFn(fuelupdate)
    inst.components.fueled:SetDepletedFn(OnFuelEmpty)

        inst:SetBrain(brain)

    MakeMediumBurnableCharacter(inst, "torso")
    MakeMediumFreezableCharacter(inst, "torso")

    inst.components.fueled:StartConsuming()

inst.components.burnable.ignorefuel = true
    inst:AddComponent("cooker")

--        inst.OnLoad = onload

    MakeHauntablePanic(inst)

        return inst
    end

-- EMPTY butler


    local function empty(inst)
        local inst = fn(inst)

        inst.AnimState:PlayAnimation("sleep_loop", false)
        inst.AnimState:Pause()
    	MakeCharacterPhysics(inst, 80, .25)
	inst.Physics:SetFriction(1)

        inst:AddTag("NOBLOCK")
        inst:AddTag("Notarget")
        inst:AddTag("mech")
        inst:AddTag("butler")
        inst:AddTag("tiddlevirusimmune")

        if not TheWorld.ismastersim then
            return inst
        end

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
            inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(OnHammered)
    inst.components.workable:SetOnWorkCallback(onworked)

--    inst.components.fueled.currentfuel = 0

    inst.components.lootdropper:SetChanceLootTable("butlergadget")


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
   local pet = builder:HasTag("williamcrafter") and builder.components.petleash:SpawnPetAt(pt.x, 0, pt.z, "williambutler") or SpawnPrefab("williambutler_empty")
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

        inst.OnBuiltFn = onbuilt

        return inst
    end


    return Prefab("williambutler", active, assets, prefabs),
    Prefab("williambutler_builder", builder, assets, prefabs),
    Prefab("williambutler_empty", empty, assets, prefabs)



--------------------------------------------------------------------------