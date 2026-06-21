local assets =
{
    Asset("ANIM", "anim/sdf_pumpking_gourd.zip"),

    Asset("SOUND", "sound/plant.fsb"),
}

local prefabs ={

}

local SOUND_TORMENTED_SCREAM = "dontstarve/creatures/leif/livinglog_burn"

local VALID_TILE_TYPES =
{
    [WORLD_TILES.DIRT] = true,
    [WORLD_TILES.SAVANNA] = true,
    [WORLD_TILES.GRASS] = true,
    [WORLD_TILES.FOREST] = true,
    [WORLD_TILES.MARSH] = true,

    -- CAVES
    [WORLD_TILES.CAVE] = true,
    [WORLD_TILES.FUNGUS] = true,
    [WORLD_TILES.SINKHOLE] = true,
    [WORLD_TILES.MUD] = true,
    [WORLD_TILES.FUNGUSRED] = true,
    [WORLD_TILES.FUNGUSGREEN] = true,

    --EXPANDED FLOOR TILES
    [WORLD_TILES.DECIDUOUS] = true,
}

local function frozenState(inst)
    if inst.components.freezable.coldness < 10 then
	inst.components.freezable:AddColdness(15)
    end
    inst.components.freezable.damagetobreak = TUNING.SDF_PUMPKIN_BOMB_HEALTH * 0.25

    if inst.components.freezable.wearofftask ~= nil then
        inst.components.freezable.wearofftask:Cancel()
    end

    if inst.taunttask ~= nil then
	inst.taunttask:Cancel()
	inst.taunttask = nil
    end

    if inst.explodeIgnittask ~= nil then
	inst.explodeIgnittask:Cancel()
	inst.explodeIgnittask = nil
	inst.SoundEmitter:KillSound("hiss")
    end

    if inst.explodeFiretask ~= nil then
	inst.explodeFiretask:Cancel()
	inst.explodeFiretask = nil
	inst.SoundEmitter:KillSound("hiss")
    end
end

local function WakeUp(inst)
    if inst.winterMode == true then
	--keep frozen
	frozenState(inst)

        --In case it's still winter when we hit this (could happen from save data)
        --inst.hibernatetask = inst:DoTaskInTime(TUNING.SDF_PUMPKIN_BOMB_FREEZE_TIME, WakeUp)
    else
	--unfreeze frozen
	if inst.components.freezable:IsFrozen() then
	    inst.components.freezable:Unfreeze()
	end
	inst.ignited = false

        inst.hibernatetask = nil
	inst.retracted = true
        inst.sg:GoToState("emerge")
    end
end

local function ResumeSleep(inst, seconds)
    inst.sg:GoToState("hibernate")

    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end

    if inst.hibernatetask ~= nil then
        inst.hibernatetask:Cancel()
    end
    inst.hibernatetask = inst:DoTaskInTime(seconds, WakeUp)
end

local function OnFrozenState(inst)
    if inst.winterMode == false then

	if inst.growth == true and inst.retracted == false then
	    inst.sg:GoToState("picked")
	elseif inst.growth == true then
	    inst.sg:GoToState("deathvine")
	elseif not inst.components.freezable:IsFrozen() then
	    inst.sg:GoToState("death")
	end

	if inst.task ~= nil then
	    inst.task:Cancel()
	    inst.task = nil
	end

	if inst.taunttask ~= nil then
	    inst.taunttask:Cancel()
	    inst.taunttask = nil
	end

	if inst.explodeIgnittask ~= nil then
	    inst.explodeIgnittask:Cancel()
	    inst.explodeIgnittask = nil
	    inst.SoundEmitter:KillSound("hiss")
	end

	if inst.explodeFiretask ~= nil then
	    inst.explodeFiretask:Cancel()
	    inst.explodeFiretask = nil
	    inst.SoundEmitter:KillSound("hiss")
	end

	if inst.hibernatetask ~= nil then
	    inst.hibernatetask:Cancel()
	end
	inst.hibernatetask = inst:DoTaskInTime(TUNING.SDF_PUMPKIN_BOMB_FREEZE_TIME, WakeUp)
    else
	frozenState(inst)
    end
end

local function IsTauntable(inst, target)
    return target.components.combat ~= nil
        and not target.components.combat:TargetIs(inst)
        and target.components.combat:CanTarget(inst)
end

local TAUNT_MUST_TAGS = { "hostile", "_combat", "locomotor" }
local TAUNT_CANT_TAGS = { "INLIMBO", "notaunt" }
local function FindShadowCreatures(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, TUNING.SDF_PUMPKIN_BOMB_TAUNT_RADIUS, TAUNT_MUST_TAGS, TAUNT_CANT_TAGS)
    for i = #ents, 1, -1 do
        if not IsTauntable(inst, ents[i]) then
            table.remove(ents, i)
        end
    end
    return #ents > 0 and ents or nil
end

local function TauntCreatures(inst)
    if inst.components.freezable:IsFrozen() then
	return
    end

    local taunted = false
    inst.targets = FindShadowCreatures(inst)
    if inst.targets ~= nil then
        for i, v in ipairs(inst.targets) do
            if IsTauntable(inst, v) then
                v.components.combat:SetTarget(inst)
                taunted = true
            end
        end
    end

    if inst.ignited == false then
	if inst.retracted == false then
	    inst.sg:GoToState("taunt")
	elseif inst.retracted == true then
	    inst.sg:GoToState("showbait_taunt")
	end
    end
end

local function OnTaunt(inst)
    if inst.growth == true and not inst.components.health:IsDead() then
	local rngTauntTime = math.random() * 10
	inst.taunttask = inst:DoPeriodicTask((TUNING.SDF_PUMPKIN_BOMB_TAUNT_TICK + rngTauntTime), function()  TauntCreatures(inst) end)
    end
end

local function OnDeath(inst)
    if inst.taunttask ~= nil then
	inst.taunttask:Cancel()
	inst.taunttask = nil
    end

    if inst.hibernatetask ~= nil then
        inst.hibernatetask:Cancel()
    end

    inst.components.lootdropper:DropLoot(inst:GetPosition())

    if inst.exploded == true then
	local x,_,z=inst.Transform:GetWorldPosition()
	local s = 1.5 --1.5
	local pumpkinDeathFX = SpawnPrefab("pumpkincarving_shatter_fx")
	pumpkinDeathFX.Transform:SetPosition(x,_,z)
	pumpkinDeathFX.Transform:SetScale(s,s,s)
	local pumpkinDeath2FX = SpawnPrefab("treegrowthsolution_use_fx")
	pumpkinDeath2FX.Transform:SetPosition(x,_,z)
    else
	inst.SoundEmitter:KillSound("hiss")
	inst:DoTaskInTime(0.5, function()
	    inst.SoundEmitter:PlaySound("dontstarve/creatures/leif/livinglog_burn")
	end)
	inst:DoTaskInTime(0.7, function()
	    local x,_,z=inst.Transform:GetWorldPosition()
	    local s = 1.5 --1.5
	    local pumpkinDeathFX = SpawnPrefab("pumpkincarving_shatter_fx")
	    pumpkinDeathFX.Transform:SetPosition(x,_,z)
	    pumpkinDeathFX.Transform:SetScale(s,s,s)
	    local pumpkinDeath2FX = SpawnPrefab("treegrowthsolution_use_fx")
	    pumpkinDeath2FX.Transform:SetPosition(x,_,z)

	    inst:Remove()
	end)
    end
end

local function OnExplodeFn(inst)
    inst.exploded = true
    inst.SoundEmitter:KillSound("hiss")

    local newSinkhole = SpawnPrefab("sdf_pumpking_bomb_sinkhole")
    newSinkhole.Transform:SetPosition(inst.Transform:GetWorldPosition())
    newSinkhole:DoCollapseFn()
end

local function Explode(inst)
    inst.SoundEmitter:KillSound("hiss")
    inst.components.explosive:OnBurnt()
end

local function OnIgniteFn(inst)
    if inst.growth == true then
	inst.explodeFiretask = inst:DoTaskInTime(TUNING.SDF_PUMPKIN_BOMB_FUSE_FIRE_TIME, Explode)
    end
end

local function Emerge(inst)
    if inst.retracted == true and inst.growth == true and not inst.components.health:IsDead() then
        --inst.retracted = false
	inst.sg:GoToState("showbait")

	inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_fuse_LP", "hiss")
	inst.explodeIgnittask = inst:DoTaskInTime(TUNING.SDF_PUMPKIN_BOMB_FUSE_IGNITE_TIME, Explode)
    elseif inst.retracted == false and inst.growth == true and not inst.components.health:IsDead() then
	inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_fuse_LP", "hiss")
	inst.explodeIgnittask = inst:DoTaskInTime(TUNING.SDF_PUMPKIN_BOMB_FUSE_IGNITE_TIME, Explode)
    end
end

local function Retract(inst)
    if not inst.retracted and inst.growth == true and not inst.components.health:IsDead() then
        inst.retracted = true
	inst.sg:GoToState("hidebait")

	if inst.explodeIgnitetask ~= nil then
	    inst.explodeIgnittask:Cancel()
	    inst.explodeIgnittask = nil
	    inst.SoundEmitter:KillSound("hiss")
	end
    end
end

local function OnAttacked(inst, data)
    if inst.growth == false then
	return
    end

    local attacker = data ~= nil and data.attacker or nil
    if attacker ~= nil then
	local target = inst.components.combat.target
	if inst.ignited == false and inst.explodeIgnittask == nil and inst.growth == true and not inst.components.health:IsDead() then
	    if not (target ~= nil and target:IsValid() and inst:IsNear(target, TUNING.SDF_PUMPKIN_BOMB_RADIUS + target:GetPhysicsRadius(0))) then
		inst.ignited = true
		inst:DoTaskInTime(0, function()
		    Emerge(inst)
		end)
	    end
	end
    end
end

local function FreshSpawn(inst)
    inst.AnimState:SetBank("sdf_pumpking_gourd")
    inst.AnimState:SetBuild("sdf_pumpking_gourd")
    inst.sg:GoToState("spawn")
    inst:AddTag("planted")

    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end

    if inst.hibernatetask ~= nil then
        inst.hibernatetask:Cancel()
    end
    inst.hibernatetask = inst:DoTaskInTime(TUNING.SDF_PUMPKIN_BOMB_HIBERNATE_TIME, WakeUp)
end

local function OnLoad(inst, data)
    if data ~= nil and data.timeuntilwake ~= nil then
        ResumeSleep(inst, math.max(0, data.timeuntilwake))
    end
    if data ~= nil and data.planted then
        inst:AddTag("planted")
    end
end

local function OnSave(inst, data)
    data.timeuntilwake = inst.hibernatetask ~= nil and math.floor(GetTaskRemaining(inst.hibernatetask)) or nil
    data.planted = inst:HasTag("planted")
end

local function OnLongUpdate(inst, dt)
    if inst.hibernatetask ~= nil then
        local t = GetTaskRemaining(inst.hibernatetask)
        inst.hibernatetask:Cancel()

        if t > dt then
            inst.hibernatetask = inst:DoTaskInTime(t - dt, WakeUp)
        else
            WakeUp(inst)
        end
    end
end

local function ExtendHibernation(inst)
    --hibernate if you aren't already
    if inst.sg.currentstate.name ~= "hibernate" then
        OnFrozenState(inst)
    else
        --it's already hibernating & it's still winter. Make it sleep for longer!
	--keep frozen
	frozenState(inst)

        if inst.hibernatetask ~= nil then
            inst.hibernatetask:Cancel()
        end
        inst.hibernatetask = inst:DoTaskInTime(TUNING.SDF_PUMPKIN_BOMB_FREEZE_TIME, WakeUp)
    end
end

local function OnSnowLevel(inst, snowlevel)
    if snowlevel >= .02 then
	if not inst.frozen then
            inst.frozen = true
	    inst.winterMode = true

	    --keep frozen
	    frozenState(inst)

	    if inst.growth == true and inst.retracted == false then
		inst.sg:GoToState("picked")
	    elseif inst.growth == true then
		inst.sg:GoToState("deathvine")
	    elseif not inst.components.freezable:IsFrozen() then
		inst.sg:GoToState("death")
	    end

	    if inst.wintertask == nil then
		inst.wintertask = inst:DoPeriodicTask(30, ExtendHibernation)
		ExtendHibernation(inst)
	    end
	end
    elseif inst.wintertask ~= nil then
	inst.frozen = false
	inst.winterMode = false

        inst.wintertask:Cancel()
        inst.wintertask = nil
	ExtendHibernation(inst)
    end
end

local function OnEntityWake(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/eye_central_idle", "loop")
end

local function OnEntitySleep(inst)
    inst.SoundEmitter:KillSound("loop")
end

local function OnHaunt(inst)
    inst.components.hauntable.hauntvalue = TUNING.HAUNT_TINY
    return true
end

local function OnWorkFinished(inst, worker)
    if not inst.components.health:IsDead() then
	inst.components.health:Kill()
    end
end

local function allanimalscanscream(inst)
    inst.SoundEmitter:PlaySound(SOUND_TORMENTED_SCREAM)
end

local function onignite(inst)
    allanimalscanscream(inst)
end

local function TryRegenHealth(inst)
    if inst.components.health and not inst.components.health:IsDead() then
	if inst.components.health:GetPercent() >= 1 then
	    return
	end
	if inst.components.combat and ((GetTime() - inst.components.combat.laststartattacktime) > TUNING.SDF_PUMPKING_HEALTH_REGEN_IDLE_THRESHOLD_TIME)
	    and ((GetTime() - inst.components.combat.lastwasattackedtime) > TUNING.SDF_PUMPKING_HEALTH_REGEN_IDLE_THRESHOLD_TIME) then 
	    inst.components.health:DoDelta(TUNING.SDF_PUMPKING_HEALTH_REGEN_AMOUNT)
	end
    end 
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.DEFAULT] / 2)
    inst:SetPhysicsRadiusOverride(.7)
    MakeObstaclePhysics(inst, inst.physicsradiusoverride)

    local scale = 1.3
    inst.Transform:SetScale(scale, scale, scale)

    inst:AddTag("veggie")
    inst:AddTag("character")
    inst:AddTag("companion")
    inst:AddTag("elemental")
    inst:AddTag("soulless")
    inst:AddTag("wildfirepriority")
    inst:AddTag("NPCcanaggro")
    inst:AddTag("NPC_workable")
    inst:AddTag("sdf_pumpking_friend")
    inst:AddTag("sdf_pumpkin_bomb")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.SDF_PUMPKIN_BOMB_HEALTH)
    inst.components.health.fire_damage_scale = TUNING.SDF_PUMPKIN_BOMB_FIRE_DAMAGE

    inst:AddComponent("combat")
    inst:ListenForEvent("death", OnDeath)

    inst:AddComponent("explosive")
    inst.components.explosive:SetOnExplodeFn(OnExplodeFn)
    inst.components.explosive.explosivedamage = TUNING.SDF_PUMPKIN_BOMB_DAMAGE
    inst.components.explosive.explosiverange = TUNING.SDF_PUMPKIN_BOMB_RADIUS
    inst.components.explosive.lightonexplode = false

    inst:AddComponent("inventory")

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"plantmeat"})

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(nil)
    inst.components.workable:SetOnFinishCallback(OnWorkFinished)

    MakeTinyFreezableCharacter(inst)
    inst.components.freezable:SetResistance(3)

    inst:SetStateGraph("SGsdf_pumpking_gourd")

    inst.growth = false
    inst.retracted = true
    inst.ignited = false
    inst.Emerge = Emerge
    inst.Retract = Retract
    inst.targets = nil
    inst.exploded = false
    inst.summoned = false
    inst.explodeIgnittask = nil
    inst.explodeFiretask = nil
    inst.taunttask = nil
    inst.OnTaunt = OnTaunt
    inst.winterMode = false

    inst:ListenForEvent("freeze", OnFrozenState)

    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    local burnable = inst:AddComponent("burnable")
    burnable:SetFXLevel(3)
    burnable:SetBurnTime(10)
    burnable.canlight = false
    burnable:AddBurnFX("fire", Vector3(0, 0, 0))
    burnable:SetOnBurntFn(nil)
    burnable:SetOnIgniteFn(OnIgniteFn)

    MakeMediumPropagator(inst)

    MakeHauntableIgnite(inst, TUNING.HAUNT_CHANCE_OCCASIONAL)
    AddHauntableCustomReaction(inst, OnHaunt, false, false, true)

    inst.OnLoad = OnLoad
    inst.OnSave = OnSave

    inst.OnLongUpdate = OnLongUpdate

    inst:WatchWorldState("snowlevel", OnSnowLevel)
    OnSnowLevel(inst, TheWorld.state.snowlevel)

    inst:ListenForEvent("attacked", OnAttacked)

    inst:DoTaskInTime(0, FreshSpawn)
    inst:DoPeriodicTask(2, TryRegenHealth)

    return inst
end

return Prefab("sdf_pumpkin_bomb", fn, assets, prefabs)