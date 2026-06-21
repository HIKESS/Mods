local assets =
{
    Asset("IMAGE", "images/inventoryimages/sdf_gallowmere_knight.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_gallowmere_knight.xml"),

    Asset("IMAGE", "images/map_icons/sdf_gallowmere_knight_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_gallowmere_knight_mm.xml"),

    Asset("ANIM", "anim/sdf_asgard_golem.zip"),
    Asset("ANIM", "anim/umbrella_voidcloth.zip"),
    Asset("SOUND", "sound/rocklobster.fsb"),
}

local prefabs ={
}

local TARGET_DIST = 12
local WAKE_TO_FOLLOW_DISTANCE = 14
local SLEEP_NEAR_LEADER_DISTANCE = 7

local function ShouldWakeUp(inst)
    return DefaultWakeTest(inst) or not inst.components.follower:IsNearLeader(WAKE_TO_FOLLOW_DISTANCE)
end

local function ShouldSleep(inst)
    if DefaultSleepTest(inst) == true and inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE) == true then
	inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_ASGARD_GOLEM_SLEEP_START, 4)
	return true
    end
    return false
end

local function OnSleepTask(inst)
    inst._sleeptask = nil
end

local function OnEntitySleep(inst)
    if inst._sleeptask ~= nil then
        inst._sleeptask = inst:DoTaskInTime(.5, OnSleepTask)
    end
end

local function OnEntityWake(inst)
    if inst._sleeptask ~= nil then
        inst._sleeptask:Cancel()
        inst._sleeptask = nil
    end
end

local function IsTargetable(inst, target)
    return not (target.components.health ~= nil and target.components.health:IsDead())
        and target.components.combat ~= nil
        and target.components.combat:CanTarget(inst)
        and (target.components.combat:TargetIs(inst) or (target:HasTag("shadowcreature") or ((target:HasTag("hostile") and (target:HasTag("brightmare") or target:HasTag("lunar_aligned") or target:HasTag("shadow_aligned")))))
	or (target.components.combat:HasTarget() and (target.components.combat.target:HasTag("player") or target.components.combat.target:HasTag("companion")))
	or (inst.components.follower.leader and inst.components.follower.leader.components.combat and inst.components.follower.leader.components.combat:HasTarget() and inst.components.follower.leader.components.combat.target == target))
end

local RETARGET_MUST_TAGS = { "_combat" }
local RETARGET_CANT_TAGS = { "INLIMBO", "player", "playerghost", "companion", "retaliates", "sdf_asgard_golem_friend"}
local RETARGET_ONEOF_TAGS = { "locomotor", "epic", "NPCcanaggro"}

local function RetargetFn(inst)
    if inst.components.combat:HasTarget() then
        return
    end
    local x, y, z = inst.Transform:GetWorldPosition()
    for i, v in ipairs(TheSim:FindEntities(x, y, z, TARGET_DIST, RETARGET_MUST_TAGS, RETARGET_CANT_TAGS, RETARGET_ONEOF_TAGS)) do
        if IsTargetable(inst, v) then
            return v
        end
    end
end

local function KeepTargetFn(inst, target)
    if inst.components.combat:CanTarget(target) and (target.components.combat.target and target.components.combat.target:HasTag("player")) then
	return true
    elseif inst.components.combat:CanTarget(target) and inst:IsNear(target, TARGET_DIST) and not target:HasTag("retaliates") then
	return target:HasTag("shadowcreature") or target:HasTag("monster") or target:HasTag("hostile") or target:HasTag("brightmare") or target:HasTag("lunar_aligned") or target:HasTag("shadow_aligned")
    end
    return false
end

local function ShouldAggro(inst, target)
    if target:HasTag("player") then
        return TheNet:GetPVPEnabled()
    end
    if target:HasTag("sdf_asgard_golem_friend") then
	return false
    end
    return true
end

local function OnAttacked(inst, data)
    local attacker = data ~= nil and data.attacker or nil
    if attacker ~= nil and not PreventTargetingOnAttacked(inst, attacker, TheNet:GetPVPEnabled() or "player") then
        local target = inst.components.combat.target
        if not (target ~= nil and target:IsValid() and inst:IsNear(target, TUNING.SDF_ASGARD_GOLEM_ATTACK_RANGE + target:GetPhysicsRadius(0))) then
            inst.components.combat:SetTarget(attacker)
        end

	--remove aggro during shield
	if inst:HasTag("sdf_stone_golem_shielded") then

	    --remove aggro
	    if attacker.components.combat.target == inst then
		attacker.components.combat:DropTarget()
	    end

	    --Remove debuff
	    attacker._sdf_asgard_golem_aggro_debufftask = attacker:DoTaskInTime((TUNING.SDF_ASGARD_GOLEM_SHIELD_DURATION), function(i)
		i.components.combat:RemoveShouldAvoidAggro(inst) i._sdf_asgard_golem_aggro_debufftask = nil
	    end)

	    --Add debuff
	    attacker.components.combat:SetShouldAvoidAggro(inst)
	end
    end
end

local function onModeChange(inst)
    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_ASGARD_GOLEM_ACTIVATE_MODE_CHANGE, 4)
    if inst.mode == 0 then
	inst.mode = 1
	inst.components.combat:SetDefaultDamage(TUNING.SDF_ASGARD_GOLEM_ATTACK_AOE_DAMAGE)
	inst.components.combat:SetAreaDamage(TUNING.SDF_ASGARD_GOLEM_AOE_RANGE, 0.8)
    else
	inst.mode = 0
	inst.components.combat:SetDefaultDamage(TUNING.SDF_ASGARD_GOLEM_ATTACK_DAMAGE)
	inst.components.combat.areahitrange = nil
    end
end

local _sizes = {}
local _maxsize = 0

local function _reg_active_dome_size(size)
    _maxsize = math.max(size, _maxsize)
    _sizes[size] = (_sizes[size] or 0) + 1
end

local function _unreg_active_dome_size(size)
    if _sizes[size] > 1 then
	_sizes[size] = _sizes[size] - 1
    else
	_sizes[size] = nil
	if size == _maxsize then
	    _maxsize = 0
	    for k in pairs(_sizes) do
		_maxsize = math.max(k, _maxsize)
	    end
	end
    end
end

local function onHighPoweredBarrierPulse(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local barrierWaveFX = SpawnPrefab("sdf_asgard_golem_optimize_data_type_b_barrier_wave_fx")
    if barrierWaveFX ~= nil then
	barrierWaveFX.Transform:SetPosition(x, 0, z)
    end

    local barrierDomeFX = SpawnPrefab("sdf_asgard_golem_optimize_data_type_b_barrier_dome_fx")
    if barrierDomeFX ~= nil then
	barrierDomeFX.Transform:SetPosition(x, 0, z)
	barrierDomeFX.SoundEmitter:PlaySound("meta2/voidcloth_umbrella/barrier_activate")
    end 
end

local function onHighPoweredBarrierStart(inst)
    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_ASGARD_GOLEM_ACTIVATE_TYPE_B, 4)

    --Barrier
    inst.sg:GoToState("optimize_data_type_b_start")
    inst.components.raindome:Enable()

    --Barrier FX
    onHighPoweredBarrierPulse(inst)
    inst.highPoweredBarrierTask = inst:DoPeriodicTask(TUNING.SDF_ASGARD_GOLEM_OPTIMIZE_DATA_TYPE_B_BARRIER_DOME_TICK, function() onHighPoweredBarrierPulse(inst) end)

    inst.SoundEmitter:PlaySound("meta2/voidcloth_umbrella/barrier_lp", "loop")
end

local function onHighPoweredBarrierEnd(inst)
    inst.components.raindome:Disable()

    --Barrier FX
    if inst.highPoweredBarrierTask ~= nil then
	inst.highPoweredBarrierTask:Cancel()
	inst.highPoweredBarrierTask = nil
    end

    if inst.SoundEmitter:PlayingSound("loop") then
	inst.SoundEmitter:KillSound("loop")
	inst.SoundEmitter:PlaySound("meta2/voidcloth_umbrella/barrier_close")
    end
end

local loot = { "trinket_6", "cutstone", "rocks", "flint" }
local function OnDeath(inst)

    --Loots
    if inst.components.sdf_asgard_golem_optimize_data:GetODTypeAInstalled() == true then
	local lootRng = math.random()
	if TUNING.SDF_ASGARD_GOLEM_OPTIMIZE_DATA_CHANCE >= lootRng then
	    inst.components.lootdropper:AddChanceLoot("sdf_asgard_golem_optimize_data_type_a", 1)
	else
	    inst.components.lootdropper:AddChanceLoot("sdf_asgard_golem_optimize_data_damaged", 1)
	end
    end
    if inst.components.sdf_asgard_golem_optimize_data:GetODTypeCInstalled() == true then
	local lootRng = math.random()
	if TUNING.SDF_ASGARD_GOLEM_OPTIMIZE_DATA_CHANCE >= lootRng then
	    inst.components.lootdropper:AddChanceLoot("sdf_asgard_golem_optimize_data_type_c", 1)
	else
	    inst.components.lootdropper:AddChanceLoot("sdf_asgard_golem_optimize_data_damaged", 1)
	end
    end
    inst.components.lootdropper:DropLoot()


    --Respawn Cooldown
    local soulbound = inst.components.follower.leader
    if soulbound ~= nil then

	--check for Ocarina
	if soulbound.prefab == "sdf_asgard_golem_giants_ocarina" then
	    if inst.asgardGolem_ID == soulbound.asgardGolem_ID then
		if soulbound.components.rechargeable then
		    --Cooldown
		    soulbound.components.rechargeable:Discharge(TUNING.SDF_ASGARD_GOLEM_GIANTS_OCARINA_SUMMON_RESPAWN_COOLDOWN *  TUNING.TOTAL_DAY_TIME)
		end
	    end
	    return true

	--check for Players Ocarina
	elseif soulbound:HasTag("player") then
	    local Ocarina = soulbound.components.inventory:FindItem(function(item) return (item.prefab == "sdf_asgard_golem_giants_ocarina" and  (inst.asgardGolem_ID == item.asgardGolem_ID))end)
	    if Ocarina ~= nil then
		if Ocarina.components.rechargeable then
		    --Cooldown
		    Ocarina.components.rechargeable:Discharge(TUNING.SDF_ASGARD_GOLEM_GIANTS_OCARINA_SUMMON_RESPAWN_COOLDOWN * TUNING.TOTAL_DAY_TIME)
		end
	    end
	    return true
	end
    end
    return true
end


local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

local function onSummonLavaGolem(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local spawn_radius = 4
    local offset = (inst.overridespawnlocation ~= nil and inst.overridespawnlocation(inst))
        or (inst.wateronly and FindSwimmableOffset(Vector3(x, 0, z), math.random() * TWOPI, spawn_radius + inst:GetPhysicsRadius(0), 8, false, true, NoHoles))
        or (FindWalkableOffset(Vector3(x, 0, z), math.random() * TWOPI, spawn_radius + inst:GetPhysicsRadius(0), 8, false, true, NoHoles, inst.allowwater, inst.allowboats))
    if not offset then
        return
    end

    local child = SpawnPrefab("sdf_asgard_golem_lava_golem")
    if child ~= nil then
	child.Transform:SetPosition(x + offset.x, 0, z + offset.z)

	local target = inst.components.combat.target
	if target ~= nil and child.components.combat ~= nil then
	    child.components.combat:SetTarget(target)
	end
    end
end

local function onsave(inst, data)
    data.asgardGolem_ID = inst.asgardGolem_ID
end

local function OnPreLoad(inst, data)
    if data.asgardGolem_ID then
	inst.asgardGolem_ID = data.asgardGolem_ID
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 200, 1) --200
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)

    --local s = 1.2
    --inst.Transform:SetScale(s,s,s)

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("sdf_asgard_golem")
    inst.AnimState:SetBuild("sdf_asgard_golem")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst.AnimState:SetMultColour(unpack({ 1, 1, 1, 1 })) --red 255/255, 153/255, 153/255
    inst.DynamicShadow:SetSize(1.75, 1.75)

    inst:AddTag("noauradamage")
    inst:AddTag("lunarhailprotection")
    inst:AddTag("notraptrigger")
    inst:AddTag("largecreature")
    inst:AddTag("character")
    inst:AddTag("companion")
    inst:AddTag("elemental")
    inst:AddTag("summonedbyplayer")
    inst:AddTag("soulless")
    inst:AddTag("crazy")
    inst:AddTag("sdf_asgard_golem")
    inst:AddTag("sdf_asgard_golem_friend")
    inst:AddTag("sdf_asgard_golem_optimize_data_install")

    inst:AddComponent("raindome")

    inst:AddComponent("talker")
    if inst.components and inst.components.talker ~= nil then
	inst.components.talker.fontsize = 35
	inst.components.talker.font = TALKINGFONT
	inst.components.talker.colour = Vector3(0.55, 0.53, 0.3, 0)
	inst.components.talker.offset = Vector3(0,-600,0) --400
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --Allows player commands to Asgard Golem
    inst:AddComponent("sdf_asgard_golem_command")

    --Allows Optimize Data installed into Asgard Golem
    inst:AddComponent("sdf_asgard_golem_optimize_data")

    --Allows installing Optimize Data into Asgard Golem
    inst:AddComponent("sdf_asgard_golem_optimize_data_install")

    --Allows Optimize Data Barrier
    inst.components.raindome:SetRadius(TUNING.SDF_ASGARD_GOLEM_OPTIMIZE_DATA_TYPE_B_BARRIER_DOME_RADIUS)
    inst.components.raindome.SetActiveRadius_Internal = function(self, new, old)
	if new ~= old then
	    if old ~= 0 then
		_unreg_active_dome_size(old)
		if new == 0 then
		    for tgt in pairs(self.targets) do
			if tgt.components.rainimmunity ~= nil and tgt:IsValid() then
			    tgt.components.rainimmunity:RemoveSource(self.inst)
			end

			--Damage Protection
			if tgt:IsValid() and (tgt:HasTag("player") or tgt:HasTag("character") or tgt:HasTag("companion")) then
			    if tgt.components.combat and (tgt.components.health and not tgt.components.health:IsDead()) then
				tgt.components.health.externalabsorbmodifiers:RemoveModifier(tgt, "sdf_asgard_golem_optimize_data_b_barrier_dome")
			    end
			end

		    end
		    self.targets = nil
		    self.newtargets = nil
		    self.delay = nil
		    self.inst:RemoveTag("raindome")
		    self.inst:StopUpdatingComponent(self)
		end
	    end
	    if new ~= 0 then
		if old == 0 then
		    assert(self.targets == nil)
		    self.targets = {}
		    self.newtargets = {}
		    self.delay = math.random() * .5
		    self.inst:AddTag("raindome")
		    self.inst:StartUpdatingComponent(self)
		end
		_reg_active_dome_size(new)
	    end
	    self._activeradius:set(new)
	end
    end
    inst.components.raindome.OnUpdate = function(self, dt)
	if self.delay > dt then
	    self.delay = self.delay - dt
	    return
	end

	local awake = not self.inst:IsAsleep()

	local TAGS = { "inspectable" }
	local NOTAGS = { "INLIMBO" }
	local oldtargets = self.targets
	local x, y, z = self.inst.Transform:GetWorldPosition()
	for _, target in ipairs(TheSim:FindEntities(x, y, z, self.radius, TAGS, NOTAGS)) do
	    if oldtargets[target] then
		oldtargets[target] = nil
	    else
		if not target.components.rainimmunity then
		    target:AddComponent("rainimmunity")
		end
		target.components.rainimmunity:AddSource(self.inst)

		--Damage Protection
		if target:IsValid() and (target:HasTag("player") or target:HasTag("character") or target:HasTag("companion")) then
		    if target.components.combat and (target.components.health and not target.components.health:IsDead()) then
			target.components.health.externalabsorbmodifiers:SetModifier(target, TUNING.SDF_ASGARD_GOLEM_OPTIMIZE_DATA_TYPE_B_BARRIER_DOME_ABSORB, "sdf_asgard_golem_optimize_data_b_barrier_dome")
		    end
		end

	    end
	    self.newtargets[target] = true
	    awake = awake or not target:IsAsleep()
	end
	for tgt in pairs(oldtargets) do
	    if tgt.components.rainimmunity ~= nil and tgt:IsValid() then
		tgt.components.rainimmunity:RemoveSource(self.inst)
	    end

	    --Damage Protection
	    if tgt:IsValid() and (tgt:HasTag("player") or tgt:HasTag("character") or tgt:HasTag("companion")) then
		if tgt.components.combat and (tgt.components.health and not tgt.components.health:IsDead()) then
		    tgt.components.health.externalabsorbmodifiers:RemoveModifier(tgt, "sdf_asgard_golem_optimize_data_b_barrier_dome")
		end
	    end

	    oldtargets[tgt] = nil
	end
	self.targets = self.newtargets
	self.newtargets = oldtargets --just swapping over the now empty table

	self.delay = awake and 1 or 3
    end
    inst.components.raindome:Disable()

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(loot)

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.SDF_ASGARD_GOLEM_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.SDF_ASGARD_GOLEM_RUN_SPEED

    inst:AddComponent("sleeper")
    inst.components.sleeper.watchlight = true
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWakeUp)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.SDF_ASGARD_GOLEM_HEALTH)

    inst:AddComponent("planardefense")
    inst.components.planardefense:SetBaseDefense(TUNING.SDF_ASGARD_GOLEM_PLANAR_DEFENSE)

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.SDF_ASGARD_GOLEM_ATTACK_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.SDF_ASGARD_GOLEM_ATTACK_PERIOD)
    inst.components.combat:SetRange(TUNING.SDF_ASGARD_GOLEM_ATTACK_RANGE)
    inst.components.combat:SetNoAggroTags(RETARGET_CANT_TAGS)
    inst.components.combat:SetRetargetFunction(1, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetShouldAggroFn(ShouldAggro)

    inst:AddComponent("timer")
    inst:AddComponent("embarker")

    inst:AddComponent("follower")
    inst.components.follower.keepdeadleader = true
    inst.components.follower:KeepLeaderOnAttacked()
    inst.components.follower.keepleaderduringminigame = true

    inst:AddComponent("inventory")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.nobounce = true
    inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.imagename = "sdf_gallowmere_knight"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_gallowmere_knight.xml"	

    inst:AddComponent("inspectable")
    inst:AddComponent("knownlocations")

    MakeHauntablePanic(inst)

    inst:SetStateGraph("SGsdf_asgard_golem")
    inst:SetBrain(require "brains/sdf_asgard_golembrain")

    inst.mode = 0
    inst.highPoweredBarrierTask = nil
    inst.damageUntilShield = (TUNING.SDF_ASGARD_GOLEM_HEALTH / TUNING.SDF_ASGARD_GOLEM_SHIELD_THRESHOLD)
    inst.avoidProjectileAttacks = true
    inst.shieldTime = TUNING.SDF_ASGARD_GOLEM_SHIELD_DURATION
    inst.scale = TUNING.SDF_STONE_GOLEM_MIN_SCALE

    inst.ModeChangeFn = function() onModeChange(inst) end
    inst.DeaggroFn = function() onDeaggro(inst) end
    inst.HighPoweredBarrierStartFn = function() onHighPoweredBarrierStart(inst) end
    inst.HighPoweredBarrierEndFn = function() onHighPoweredBarrierEnd(inst) end
    inst.SummonLavaGolemFn = function() onSummonLavaGolem(inst) end

    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("death", OnDeath)

    inst.OnSave = onsave
    inst.OnPreLoad = OnPreLoad
    --inst.OnLoad = onload

    local old_SetLeader = inst.components.follower.SetLeader
    function inst.components.follower:SetLeader(soulbound)
        if soulbound ~= nil then
            local inst = self.inst
            local ents = soulbound.components.leader.followers or {}
            for e,_ in pairs(ents) do
                if e ~= inst and e.asgardGolem_ID == inst.asgardGolem_ID then
                    inst:DoTaskInTime(0, function(inst) inst:Remove() end)
                    return
                end
            end
        end
        old_SetLeader(self, soulbound)
    end

    return inst
end

return Prefab("sdf_asgard_golem", fn, assets, prefabs)