local assets = 
{
    Asset("IMAGE", "images/inventoryimages/sdf_gallowmere_knight.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_gallowmere_knight.xml"),

    Asset("IMAGE", "images/map_icons/sdf_gallowmere_knight_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_gallowmere_knight_mm.xml"),

    Asset("ANIM", "anim/sdf_gallowmere_knight.zip"),	
}

local prefabs = {
}

local items =
{
    SWORD = ("swap_"..TUNING.SDF_GALLOWMERE_SQUIRE_WEAPON..""),
    SHIELD = ("swap_"..TUNING.SDF_GALLOWMERE_SQUIRE_SHIELD..""),
}

--Target Victory memory
local target_tagged = nil
local epic_tagged = nil

local function GetWeaponDamage(weapon)
    if weapon == "sdf_small_sword" then
	return TUNING.SDF_SMALL_SWORD_DAMAGE
    else
	return TUNING.SDF_GALLOWMERE_SQUIRE_ATTACK
    end
end

local function GetShieldProtection(shield)
    if shield == "sdf_copper_shield" then
	return TUNING.SDF_GALLOWMERE_SQUIRE_COPPER_DEFENSE
    else
	return TUNING.SDF_GALLOWMERE_SQUIRE_DEFENSE
    end
end

local function OnNewTarget(inst, data)
	inst.components.combat:ShareTarget(data.target, 30, function(dude) return dude:HasTag("summonedbyplayer") or (dude.components.follower and dude.components.follower.leader and dude.components.follower.leader:HasTag("player")) end, 15)
end

local function IsTargetable(inst, target)
    return not (target.components.health ~= nil and target.components.health:IsDead())
        and target.components.combat ~= nil
        and target.components.combat:CanTarget(inst)
        and (target.components.combat:TargetIs(inst) or (target:HasTag("shadowcreature") or ((target:HasTag("hostile") and (target:HasTag("brightmare") or target:HasTag("lunar_aligned") or target:HasTag("shadow_aligned")))))
	or (target.components.combat:HasTarget() and (target.components.combat.target:HasTag("player") or target.components.combat.target:HasTag("companion")))
	or (inst.components.follower.leader and inst.components.follower.leader.components.combat and inst.components.follower.leader.components.combat:HasTarget() and inst.components.follower.leader.components.combat.target == target))
end

local TARGET_DIST = 12
local RETARGET_MUST_TAGS = { "_combat" }
local RETARGET_CANT_TAGS = { "INLIMBO", "player", "playerghost", "companion", "retaliates", "sdf_undeath_healing"}
local RETARGET_ONEOF_TAGS = { "locomotor", "epic", "NPCcanaggro"}
local function NormalRetarget(inst)
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

local function OnKeepTarget(inst, target)
    if inst.components.combat:CanTarget(target) and inst:IsNear(target, TARGET_DIST) then
	return target:HasTag("shadowcreature") or target:HasTag("monster") or target:HasTag("hostile") or target:HasTag("brightmare") or target:HasTag("lunar_aligned") or target:HasTag("shadow_aligned")
    elseif inst.components.combat:CanTarget(target) and (target.components.combat.target and target.components.combat.target:HasTag("player")) then
	return true
    end
    return false
end

local function EquipItem(inst, item)
    if item then
	if item == inst.items["SWORD"] then
	    inst.AnimState:ClearOverrideSymbol("lantern_overlay")
	    inst.AnimState:OverrideSymbol("swap_object", item, item)
	    inst.AnimState:Show("ARM_carry") 
	    inst.AnimState:Hide("ARM_normal")
	    inst.AnimState:Hide("LANTERN_OVERLAY")
	    inst.AnimState:ShowSymbol("swap_object")
	elseif item == inst.items["SHIELD"] then
	    inst.AnimState:OverrideSymbol("lantern_overlay", item, "swap_shield")
	    inst.AnimState:HideSymbol("swap_object")
	    inst.AnimState:Show("LANTERN_OVERLAY")
	end
    end
end

local function VictoryKill(inst)
    local canTalk = math.random()
    if inst.epic_tagged ~= nil then
	inst.sg:GoToState("talk")
	inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_GALLOWMERE_KNIGHT_VICTORY_EPIC, 5)
	inst.talkedCombat = true
	inst.epic_tagged = nil
	inst.target_tagged = nil
	inst:DoTaskInTime(60, function(inst)
	    inst.talkedCombat = false
	end)
    elseif inst.talkedCombat == false and inst.target_tagged ~= nil and canTalk <= 0.1 then
	inst.sg:GoToState("talk")
	inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_GALLOWMERE_KNIGHT_VICTORY[math.random(#STRINGS.ANNOUNCE_SDF_GALLOWMERE_KNIGHT_VICTORY)], 5)
	inst.talkedCombat = true
	inst.target_tagged = nil
	inst:DoTaskInTime(60, function(inst)
	    inst.talkedCombat = false
	end)
    else
	inst.target_tagged = nil
    end
end

local function IsValidVictim(victim)
    return victim ~= nil
	and not ((victim:HasTag("prey") and not victim:HasTag("hostile")) or
	    victim:HasTag("veggie") or
	    victim:HasTag("structure") or
	    victim:HasTag("wall") or
	    victim:HasTag("balloon") or
	    victim:HasTag("groundspike") or
	    victim:HasTag("smashable") or
	    victim:HasTag("companion"))
	    and victim.components.health ~= nil and victim.components.combat ~= nil
end

local function OnDoAttack(inst, data)
    if inst.epic_tagged == nil or (inst.target_tagged == nil and inst.talkedCombat == false) then
	local victim = data.target
	if data ~= nil and victim ~= nil then
	    if IsValidVictim(victim) then
		if inst.target_tagged == nil then
		    inst.target_tagged = victim
		end
		if inst.epic_tagged == nil then
		    if victim:HasTag("epic") then 
			inst.epic_tagged = victim
		    end
		end
	    end
	end
    end
end

local function OnAttacked(inst, data)
    inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/trinket")

    local attacker = data.attacker
    inst.components.combat:SetTarget(attacker)
    inst.components.combat:ShareTarget(attacker, 30, function(dude) return dude:HasTag("summonedbyplayer") end, 15)
end

local function OnDeath(inst)
    local gKnightDead = SpawnPrefab("wathgrithr_spirit")
    gKnightDead.Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:DoTaskInTime(1.7, function()
	local fx = SpawnPrefab("collapse_small")
    	fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    	fx:SetMaterial("rock")
    end)
end

local function gknightoff(inst)
    if inst:HasTag("sdf_gallowmere_knight_tactics") then
	inst:RemoveTag("sdf_gallowmere_knight_tactics")
    end
end

local function gknighton(inst, player)
    if player and inst.talked == false then
	local canGreet = math.random()
	if canGreet <= 0.1 and not (inst.components.combat.target or inst.sg:HasStateTag("attack") or inst.sg:HasStateTag("busy") or inst.components.freezable:IsFrozen() or inst.components.health:IsDead() or inst.components.sdf_gallowmere_knight_command:IsCurrentlyStaying() == false) then
	    inst.sg:GoToState("talk")

	    if player.prefab == "sdf" then
		local randomGreeting = math.random()
		if randomGreeting <= 0.7 then
		    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_GALLOWMERE_KNIGHT_GREETINGS[math.random(#STRINGS.ANNOUNCE_SDF_GALLOWMERE_KNIGHT_GREETINGS)], 5)
		else
		    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_GALLOWMERE_KNIGHT_GREETINGS_COMMON[math.random(#STRINGS.ANNOUNCE_SDF_GALLOWMERE_KNIGHT_GREETINGS_COMMON)], 5)
		end
	    else
		inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_GALLOWMERE_KNIGHT_GREETINGS_COMMON[math.random(#STRINGS.ANNOUNCE_SDF_GALLOWMERE_KNIGHT_GREETINGS_COMMON)], 5)
	    end

	    inst.talked = true
	    inst:DoTaskInTime(90, function(inst)
		inst.talked = false
	    end)
	end	
    end
end

local function firstGlow(inst)
    local healthpool = inst.components.health:GetPercent()
    if healthpool > 0.6 then
	inst.components.bloomer:PushBloom("Healthy", "shaders/anim.ksh", 50)
    end
end

local function OnHealthDelta(inst, data)
    if data.newpercent ~= nil then
	if data.newpercent <= 0.6 then
	    inst.components.bloomer:PopBloom("Healthy")
	elseif data.newpercent > 0.6 then
	    inst.components.bloomer:PushBloom("Healthy", "shaders/anim.ksh", 50)
	end
    end
end

local function squireDecay(inst)
    if not (inst.components.health and inst.components.health:IsDead()) then
	inst.components.health:DoDelta(-(TUNING.SDF_GALLOWMERE_SQUIRE_DECAY_HEALTH / GetShieldProtection(TUNING.SDF_GALLOWMERE_SQUIRE_SHIELD)), false, "summon decay")
    end
end

local function onload(inst, data)
    local healthpool = inst.components.health:GetPercent()
    if healthpool > 0.6 then
	inst.components.bloomer:PushBloom("Healthy", "shaders/anim.ksh", 50)
    end

    local stance = inst.components.sdf_gallowmere_knight_command:CurrentStance()
    local staying = inst.components.sdf_gallowmere_knight_command:IsCurrentlyStaying()
    if stance == ("swap_"..TUNING.SDF_GALLOWMERE_SQUIRE_SHIELD.."") and staying == true then
	inst.AnimState:OverrideSymbol("lantern_overlay", "swap_"..TUNING.SDF_GALLOWMERE_SQUIRE_SHIELD.."", "swap_shield")
	inst.AnimState:HideSymbol("swap_object")
	inst.AnimState:Show("LANTERN_OVERLAY")
    else
	inst.AnimState:ClearOverrideSymbol("lantern_overlay")
	inst.AnimState:OverrideSymbol("swap_object", "swap_"..TUNING.SDF_GALLOWMERE_SQUIRE_WEAPON.."", "swap_"..TUNING.SDF_GALLOWMERE_SQUIRE_WEAPON.."")
	inst.AnimState:Show("ARM_carry") 
	inst.AnimState:Hide("ARM_normal")
	inst.AnimState:Hide("LANTERN_OVERLAY")
	inst.AnimState:ShowSymbol("swap_object")
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.entity:AddPhysics()
    inst.Transform:SetFourFaced(inst)

    inst.MiniMapEntity:SetIcon("sdf_gallowmere_knight_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetPriority(5)

    MakeCharacterPhysics(inst, 75, .5)
	
    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("sdf_gallowmere_knight")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:OverrideSymbol("swap_object", items["SWORD"], items["SWORD"])
    inst.AnimState:Show("ARM_carry") 
    inst.AnimState:Hide("ARM_normal")
	
    inst:AddTag("character")	
    inst:AddTag("notraptrigger")
    inst:AddTag("scarytoprey")
    inst:AddTag("companion")
    inst:AddTag("summonedbyplayer")
    inst:AddTag("nosteal")
    inst:AddTag("sdf_undeath_healing")

    inst:AddComponent("talker")
    if inst.components and inst.components.talker ~= nil then
	inst.components.talker.fontsize = 35
	inst.components.talker.font = TALKINGFONT
	inst.components.talker.colour = Vector3(0.55, 0.53, 0.3, 0)
	inst.components.talker.offset = Vector3(0,-400,0)
    end

    inst.entity:SetPristine() 

    if not TheWorld.ismastersim then   
      return inst  
    end   
    
    inst:AddComponent("sdf_gallowmere_knight_command")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.SDF_GALLOWMERE_SQUIRE_HEALTH)
    inst.components.health.canheal = false
    inst.components.health.canmurder = false
    inst.components.health:SetAbsorptionAmount(GetShieldProtection(TUNING.SDF_GALLOWMERE_SQUIRE_SHIELD)) --sdf_copper_shield 0.5

    inst:AddComponent("bloomer")
    inst:DoTaskInTime(0.1, function(inst) firstGlow(inst) end)

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "body"
    inst.components.combat:SetDefaultDamage(GetWeaponDamage(TUNING.SDF_GALLOWMERE_SQUIRE_WEAPON)) --sdf_small_sword 27.5
    inst.components.combat:SetAttackPeriod(TUNING.SDF_GALLOWMERE_SQUIRE_ATTACK_SPEED + math.random() * 2) --3
    inst.components.combat:SetNoAggroTags(RETARGET_CANT_TAGS)
    inst.components.combat:SetKeepTargetFunction(OnKeepTarget)
    inst.components.combat:SetRetargetFunction(1, NormalRetarget)
    local old_CanTarget = inst.components.combat.CanTarget
    function inst.components.combat:CanTarget(guy)
	if guy.components.follower and guy.components.follower.leader and guy.components.follower.leader:HasTag("player") then
	    return false
	else
	    return old_CanTarget(self, guy) -- call original function
	end
    end

    inst:AddComponent("locomotor")
    inst.components.locomotor:SetSlowMultiplier( 0.75 )
    inst.components.locomotor.pathcaps = { ignorecreep = true }
    inst.components.locomotor.runspeed = TUNING.SDF_GALLOWMERE_SQUIRE_MOVEMENT_SPEED --7

    --boat hopping setup
    inst.components.locomotor:SetAllowPlatformHopping(true)
    inst:AddComponent("embarker")
    inst:AddComponent("drownable")

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(3,3.2)
    inst.components.playerprox:SetOnPlayerNear(gknighton)
    inst.components.playerprox:SetOnPlayerFar(gknightoff)

    inst:AddComponent("inspectable")
    inst:AddComponent("knownlocations")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:AddChanceLoot("sdf_energyvial", TUNING.SDF_GALLOWMERE_SQUIRE_ENERGYVIAL_CHANCE)

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

    MakeMediumBurnableCharacter(inst, "body")
    inst.components.burnable.flammability = TUNING.SDF_GALLOWMERE_SQUIRE_FLAMMABILITY
    inst:RemoveComponent("propagator")
    MakeMediumFreezableCharacter(inst, "body")
    --MakeMediumFreezableCharacter(inst, "face")
    inst.components.freezable.wearofftime = 1.5

    inst.items = items
    inst.weaponfn = GetWeaponDamage(TUNING.SDF_GALLOWMERE_SQUIRE_WEAPON)
    inst.shieldfn = GetShieldProtection(TUNING.SDF_GALLOWMERE_SQUIRE_SHIELD)
    inst.equipfn = EquipItem
    EquipItem(inst)

    inst:SetStateGraph("SGsdf_gallowmere_knight")
    local brain = require "brains/sdf_gallowmere_knightbrain"
    inst:SetBrain(brain)

    inst.talkedCombat = false
    inst.talked = false
    inst.target_tagged = target_tagged
    inst.epic_tagged = epic_tagged
    inst.victorykillfn = VictoryKill

    inst:ListenForEvent("healthdelta", OnHealthDelta)
    inst:ListenForEvent("doattack", OnDoAttack)
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("newcombattarget", OnNewTarget)
    inst:ListenForEvent("death", OnDeath)
				
    inst.OnSave = function(inst, data)
    	data.gKnight_id = inst.gKnight_id -- duplication bug fix, when a game starts.
    end   

    inst.OnPreLoad = function(inst, data)
        -- duplication bug fix, when a game starts.
        if data and data.gKnight_id then
            inst.gKnight_id = data.gKnight_id
        end
    end

    inst.OnLoad = onload

    -- duplication bug fix, when a game starts.
    inst.gKnight_id = math.random()
    local old_SetLeader = inst.components.follower.SetLeader
    function inst.components.follower:SetLeader(player)
        if player ~= nil then
            local inst = self.inst
            local ents = player.components.leader.followers or {}
            for e,_ in pairs(ents) do
                if e ~= inst and e.gKnight_id == inst.gKnight_id then
                    inst:DoTaskInTime(0, function(inst) inst:Remove() end)
                    return
                end
            end
        end
        old_SetLeader(self, player)
    end

    inst.squireDecaytask = inst:DoPeriodicTask(TUNING.SDF_GALLOWMERE_SQUIRE_DECAY_TICK, function() squireDecay(inst) end)

    return inst
end

return Prefab("sdf_gallowmere_squire", fn, assets, prefabs)