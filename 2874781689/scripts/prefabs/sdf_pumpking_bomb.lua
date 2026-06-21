local assets =
{
    Asset("ANIM", "anim/sdf_pumpking_gourd.zip"),
    Asset("ANIM", "anim/sdf_pumpking_bomb_sinkhole.zip"),

    Asset("SOUND", "sound/plant.fsb"),
}

local prefabs ={

}

local VALID_TILE_TYPES =
{
    [WORLD_TILES.QUAGMIRE_SOIL] = true,
    [WORLD_TILES.DIRT] = true,
    [WORLD_TILES.FOREST] = true,
    [WORLD_TILES.MUD] = true,
}

local function frozenState(inst)
    if inst.components.freezable.coldness < 10 then
	inst.components.freezable:AddColdness(15)
    end
    inst.components.freezable.damagetobreak = TUNING.SDF_PUMPKING_BOMB_HEALTH * 0.25

    if inst.components.freezable.wearofftask ~= nil then
        inst.components.freezable.wearofftask:Cancel()
    end

    inst:RemoveComponent("playerprox")

    if inst.summontask ~= nil then
	inst.summontask:Cancel()
	inst.summontask = nil
    end

    if inst.explodeSummontask ~= nil then
	inst.explodeSummontask:Cancel()
	inst.explodeSummontask = nil
	inst.SoundEmitter:KillSound("hiss")
    end

    if inst.explodeProxytask ~= nil then
	inst.explodeProxytask:Cancel()
	inst.explodeProxytask = nil
	inst.SoundEmitter:KillSound("hiss")
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
        --inst.hibernatetask = inst:DoTaskInTime(TUNING.SDF_PUMPKING_BOMB_HIBERNATE_TIME, WakeUp)
    else
	--unfreeze frozen
	if inst.components.freezable:IsFrozen() then
	    inst.components.freezable:Unfreeze()
	end
	inst.ignited = false

	inst:AddComponent("playerprox")
	inst.components.playerprox:SetDist(TUNING.SDF_PUMPKING_BOMB_RADIUS - 0.5, TUNING.SDF_PUMPKING_BOMB_RADIUS)
	inst.components.playerprox:SetOnPlayerNear(inst.EmergeProxy)
	--inst.components.playerprox:SetOnPlayerFar(inst.Retract)
	inst.components.playerprox:SetPlayerAliveMode(inst.components.playerprox.AliveModes.AliveOnly)

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

	inst:RemoveComponent("playerprox")

	if inst.summontask ~= nil then
	    inst.summontask:Cancel()
	    inst.summontask = nil
	end

	if inst.explodeSummontask ~= nil then
	    inst.explodeSummontask:Cancel()
	    inst.explodeSummontask = nil
	    inst.SoundEmitter:KillSound("hiss")
	end

	if inst.explodeProxytask ~= nil then
	    inst.explodeProxytask:Cancel()
	    inst.explodeProxytask = nil
	    inst.SoundEmitter:KillSound("hiss")
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
	inst.hibernatetask = inst:DoTaskInTime(TUNING.SDF_PUMPKING_BOMB_FREEZE_TIME, WakeUp)
    else
	frozenState(inst)
    end
end

local function OnDeath(inst)
    if inst.hibernatetask ~= nil then
        inst.hibernatetask:Cancel()
    end

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
	inst:DoTaskInTime(0.6, function()
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

    OnDeath(inst)
end

local function Explode(inst)
    inst.SoundEmitter:KillSound("hiss")
    inst.components.explosive:OnBurnt()
end

local function OnIgniteFn(inst)
    if inst.growth == true then
	inst.explodeFiretask = inst:DoTaskInTime(TUNING.SDF_PUMPKING_BOMB_FUSE_FIRE_TIME, Explode)
    end
end

local function Emerge(inst)
    if inst.retracted == true and inst.growth == true and not inst.components.health:IsDead() then
        --inst.retracted = false
	inst.sg:GoToState("showbait")

	inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_fuse_LP", "hiss")
	inst.explodeIgnittask = inst:DoTaskInTime(TUNING.SDF_PUMPKING_BOMB_FUSE_IGNITE_TIME, Explode)
    elseif inst.retracted == false and inst.growth == true and not inst.components.health:IsDead() then
	inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_fuse_LP", "hiss")
	inst.explodeIgnittask = inst:DoTaskInTime(TUNING.SDF_PUMPKING_BOMB_FUSE_IGNITE_TIME, Explode)
    end
end

local function EmergeProxy(inst)
    if inst.retracted == true and inst.growth == true and not inst.components.health:IsDead() then
        inst.retracted = false
	inst.ignited = true
	inst.sg:GoToState("showbait")

	inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_fuse_LP", "hiss")
	inst.explodeProxytask = inst:DoTaskInTime(TUNING.SDF_PUMPKING_BOMB_FUSE_PROXY_TIME, Explode)
    end
end

local function EmergeSummon(inst)
    if inst.retracted and inst.growth == true and not inst.components.health:IsDead() then
        inst.retracted = false
	inst.ignited = true
	inst.sg:GoToState("showbait")

	inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_fuse_LP", "hiss")
	inst.explodeSummontask = inst:DoTaskInTime(TUNING.SDF_PUMPKING_BOMB_FUSE_IGNITE_TIME, Explode)
    end
end

local function OnSummon(inst)
    if inst.retracted and inst.growth == true and not inst.components.health:IsDead() then
	local rngSummonTime = math.random() * 10
	inst.summontask = inst:DoTaskInTime((TUNING.SDF_PUMPKING_BOMB_FUSE_SUMMON_TIME + rngSummonTime), EmergeSummon)
    end
end

local function Retract(inst)
    if not inst.retracted and inst.growth == true and not inst.components.health:IsDead() then
        inst.retracted = true
	inst.sg:GoToState("hidebait")

	if inst.explodeProxytask ~= nil then
	    inst.explodeProxytask:Cancel()
	    inst.explodeProxytask = nil
	    inst.SoundEmitter:KillSound("hiss")
	end

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
    elseif inst.explodeProxytask ~= nil then
	return
    end

    local attacker = data ~= nil and data.attacker or nil
    if attacker ~= nil then
	local target = inst.components.combat.target
	if inst.ignited == false and inst.explodeIgnittask == nil and inst.growth == true and not inst.components.health:IsDead() then
	    if not (target ~= nil and target:IsValid() and inst:IsNear(target, TUNING.SDF_PUMPKING_BOMB_RADIUS + target:GetPhysicsRadius(0))) then
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
    inst.hibernatetask = inst:DoTaskInTime(TUNING.SDF_PUMPKING_BOMB_HIBERNATE_TIME, WakeUp)
end

local function OnLoad(inst, data)
    if data ~= nil and data.planted then
        inst:AddTag("planted")
    end

    if data ~= nil and data.timeuntilwake ~= nil then
        ResumeSleep(inst, math.max(0, data.timeuntilwake))
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
        inst.hibernatetask = inst:DoTaskInTime(TUNING.SDF_PUMPKING_BOMB_FREEZE_TIME, WakeUp)
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

    inst:AddTag("hostile")
    inst:AddTag("veggie")
    inst:AddTag("character")
    inst:AddTag("elemental")
    inst:AddTag("soulless")
    inst:AddTag("wildfirepriority")
    inst:AddTag("NPCcanaggro")
    inst:AddTag("NPC_workable")
    inst:AddTag("sdf_pumpking_friend")
    inst:AddTag("sdf_pumpking_bomb")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.SDF_PUMPKING_BOMB_HEALTH)
    inst.components.health.fire_damage_scale = TUNING.SDF_PUMPKING_BOMB_FIRE_DAMAGE

    inst:AddComponent("combat")
    inst:ListenForEvent("death", OnDeath)

    inst:AddComponent("explosive")
    inst.components.explosive:SetOnExplodeFn(OnExplodeFn)
    inst.components.explosive.explosivedamage = TUNING.SDF_PUMPKING_BOMB_DAMAGE
    inst.components.explosive.explosiverange = TUNING.SDF_PUMPKING_BOMB_RADIUS
    inst.components.explosive.lightonexplode = false

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(TUNING.SDF_PUMPKING_BOMB_RADIUS - 0.5, TUNING.SDF_PUMPKING_BOMB_RADIUS)
    inst.components.playerprox:SetOnPlayerNear(EmergeProxy)
    --inst.components.playerprox:SetOnPlayerFar(Retract)
    inst.components.playerprox:SetPlayerAliveMode(inst.components.playerprox.AliveModes.AliveOnly)

    inst:AddComponent("inventory")

    inst:AddComponent("inspectable")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(nil)
    inst.components.workable:SetOnFinishCallback(OnWorkFinished)

    MakeTinyFreezableCharacter(inst)
    inst.components.freezable:SetResistance(3)

    inst:SetStateGraph("SGsdf_pumpking_gourd")

    inst.growth = false
    inst.retracted = true
    inst.Emerge = Emerge
    inst.Retract = Retract
    inst.EmergeProxy = EmergeProxy
    inst.ignited = false
    inst.exploded = false
    inst.summoned = false
    inst.summontask = nil
    inst.explodeIgnittask = nil
    inst.explodeSummontask = nil
    inst.explodeProxytask = nil
    inst.explodeFiretask = nil
    inst.OnSummon = OnSummon
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

require("stategraphs/commonstates")
local NUM_CRACKING_STAGES = 1
local COLLAPSE_STAGE_DURATION = 1
local OBJECT_SCALE = 0.6
local NUM_FX = 7
local FX_THETA_DELTA = TWOPI / NUM_FX
local FX_RADIUS = 1.6

local function SpawnFx(inst, scale, pos)
    local theta = math.random() * PI * 2

    pos = pos or inst:GetPosition()

    --Spawn an fx at the middle of the sinkhole.
    SpawnPrefab("sinkhole_spawn_fx_"..math.random(3)).Transform:SetPosition(pos:Get())

    --Spawn an fx around the edges of the sinkhole circle.
    for i = 1, NUM_FX do
        local dust = SpawnPrefab("sinkhole_spawn_fx_"..math.random(3))

        dust.Transform:SetPosition(
            pos.x + math.cos(theta) * FX_RADIUS * (1 + math.random() * .1),
            0,
            pos.z - math.sin(theta) * FX_RADIUS * (1 + math.random() * .1)
        )

        local s = scale + math.random() * .2
        local x_scale = (i % 2 == 0 and -s) or s
        dust.Transform:SetScale(x_scale, s, s)

        theta = theta + FX_THETA_DELTA
    end

    inst.SoundEmitter:PlaySoundWithParams("dontstarve/creatures/together/antlion/sfx/ground_break", { size = 2 })
end

local function OnTimerDone(inst, data)
    if data ~= nil and data.name == "repair" then
        if not inst:IsAsleep() then
	    SpawnFx(inst, inst.scale / 2)
        end

        inst.components.unevenground:Disable()
        inst.persists = false
        ErodeAway(inst)
    end
end

local function SmallLaunch(inst, launcher, basespeed)
    local hp = inst:GetPosition()
    local pt = launcher:GetPosition()
    local vel = (hp - pt):GetNormalized()
    local speed = basespeed * .5 + math.random()
    local angle = math.atan2(vel.z, vel.x) + (math.random() * 20 - 10) * DEGREES
    inst.Physics:Teleport(hp.x, .1, hp.z)
    inst.Physics:SetVel(math.cos(angle) * speed, 3 * speed + math.random(), math.sin(angle) * speed)
end

local COLLAPSIBLE_WORK_ACTIONS =
{
    CHOP = true,
    DIG = true,
    HAMMER = true,
    MINE = true,
}
local COLLAPSIBLE_TAGS = { "pickable", "NPC_workable" }
for k, v in pairs(COLLAPSIBLE_WORK_ACTIONS) do
    table.insert(COLLAPSIBLE_TAGS, k.."_workable")
end
local NON_COLLAPSIBLE_TAGS = { "flying", "bird", "ghost", "locomotor", "FX", "NOCLICK", "DECOR", "INLIMBO" }

local TOSS_MUST_TAGS = { "_inventoryitem" }
local TOSS_CANT_TAGS = { "locomotor", "INLIMBO" }

local function SnareAOE(inst)
    local debuffkey = inst.prefab
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 3)
    for i, v in ipairs(ents) do
	if v ~= nil and v:IsValid() and v.components.locomotor ~= nil and not (v:HasTag("epic") 
	    or v:HasTag("player") or v:HasTag("playerghost") or v:HasTag("INLIMBO")) then
	    --slowing effect
	    if v._sdf_pumpking_bomb_sinkhole_movespeed_debufftask ~= nil then
		v._sdf_pumpking_bomb_sinkhole_movespeed_debufftask:Cancel()
	    end
	    v._sdf_pumpking_bomb_sinkhole_movespeed_debufftask = v:DoTaskInTime(TUNING.SDF_PUMPKING_BOMB_SINKHOLE_MOVESPEED_DEBUFF_DURATION, function(i) i.components.locomotor:RemoveExternalSpeedMultiplier(i, debuffkey) i._sdf_pumpking_bomb_sinkhole_movespeed_debufftask = nil end)

	    v.components.locomotor:SetExternalSpeedMultiplier(v, debuffkey, TUNING.SDF_PUMPKING_BOMB_SINKHOLE_MOVESPEED_DEBUFF)
	end
    end
end

local function DoCollapse(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, COLLAPSE_STAGE_DURATION, .03, .15, inst, inst.radius * 6)

    inst.components.unevenground:Enable()

    local pos = inst:GetPosition()
	SpawnFx(inst, inst.scale, pos)

    local ents = TheSim:FindEntities(
        pos.x, 0, pos.z,
        inst.radius + 1, nil,
        NON_COLLAPSIBLE_TAGS, COLLAPSIBLE_TAGS
    )

    for _, collapsible_entity in ipairs(ents) do
        local isworkable = false

        if collapsible_entity.components.workable ~= nil then
            local work_action = collapsible_entity.components.workable:GetWorkAction()
            --V2C: nil action for NPC_workable (e.g. campfires)
            --     allow digging spawners (e.g. rabbithole)
            isworkable = (
                (work_action == nil and collapsible_entity:HasTag("NPC_workable")) or
                (collapsible_entity.components.workable:CanBeWorked() and work_action ~= nil and COLLAPSIBLE_WORK_ACTIONS[work_action.id])
            )
        end

	-- Work the object a little if it can be worked (or destroy if inst.maxwork is true),
        -- and pick stuff that can be picked.
       if isworkable then
	    --ignore pumpkin plants
	    if inst.maxwork then
		collapsible_entity.components.workable:Destroy(inst)
	    else
		if collapsible_entity.components.workable:GetWorkAction() == ACTIONS.MINE then
		    PlayMiningFX(inst, collapsible_entity, true)
		end
		collapsible_entity.components.workable:WorkedBy(inst, 1)
	    end
            if collapsible_entity:IsValid() and collapsible_entity:HasTag("stump") then
                collapsible_entity:Remove()
            end
        elseif collapsible_entity.components.pickable ~= nil
                and collapsible_entity.components.pickable:CanBePicked()
                and not collapsible_entity:HasTag("intense") then

            local num = collapsible_entity.components.pickable.numtoharvest or 1
            local product = collapsible_entity.components.pickable.product

            collapsible_entity.components.pickable:Pick(inst) -- only calling this to trigger callbacks on the object

            if product ~= nil and num > 0 then
                local ce_x, ce_y, ce_z = collapsible_entity.Transform:GetWorldPosition()
                for i = 1, num do
                    SpawnPrefab(product).Transform:SetPosition(ce_x, 0, ce_z)
                end
            end
        end
    end

    local totoss = TheSim:FindEntities(pos.x, 0, pos.z, inst.radius, TOSS_MUST_TAGS, TOSS_CANT_TAGS)
    for _, tossible_entity in ipairs(totoss) do
        if tossible_entity.components.mine ~= nil then
            tossible_entity.components.mine:Deactivate()
        end
        if not tossible_entity.components.inventoryitem.nobounce
                and (tossible_entity.Physics ~= nil and tossible_entity.Physics:IsActive()) then
            SmallLaunch(tossible_entity, inst, 1.5)
        end
    end

    inst.components.timer:StartTimer("repair", TUNING.SDF_PUMPKING_BOMB_SINKHOLE_DURATION)
end

local function OnLoad2(inst)--, data)
    if inst.components.timer:TimerExists("repair") then
        inst.components.unevenground:Enable()
    end
end

local function OnLoadPostPass2(inst)--, newents, data)
    if inst.persists and not inst.components.timer:TimerExists("repair") then
	--backup, in case sinkholes got spawned and never started collapsing
	inst:Remove()
    end
end

local function fn2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("sdf_pumpking_bomb_sinkhole")
    inst.AnimState:SetBuild("sdf_pumpking_bomb_sinkhole")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(2)
    inst.AnimState:SetScale(OBJECT_SCALE, OBJECT_SCALE)

    inst.Transform:SetEightFaced()

    inst:AddTag("antlion_sinkhole")
    inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("NOCLICK")

    inst:SetDeployExtraSpacing(4)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	return inst
    end

    inst.radius = TUNING.SDF_PUMPKING_BOMB_SINKHOLE_RADIUS
    inst.scale = OBJECT_SCALE
    inst.maxwork = false

    inst:AddComponent("aura")
    inst.components.aura.pretickfn = SnareAOE
    inst.components.aura.radius = TUNING.SDF_PUMPKING_BOMB_SINKHOLE_RADIUS + 1
    inst.components.aura.tickperiod = TUNING.SDF_PUMPKING_BOMB_SINKHOLE_TICK
    inst.components.aura:Enable(true)

    inst:AddComponent("timer")

    inst:AddComponent("unevenground")
    inst.components.unevenground.radius = TUNING.SDF_PUMPKING_BOMB_SINKHOLE_RADIUS

    inst.DoCollapseFn = function() DoCollapse(inst) end

    inst:ListenForEvent("timerdone", OnTimerDone)

    inst.OnLoad = OnLoad2
    inst.OnLoadPostPass = OnLoadPostPass2

    return inst
end

return Prefab("sdf_pumpking_bomb", fn, assets, prefabs),
	Prefab("sdf_pumpking_bomb_sinkhole", fn2, assets)