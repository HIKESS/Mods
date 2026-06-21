require("stategraphs/commonstates")

local function DoShake(inst)
    ShakeAllCameras(CAMERASHAKE.VERTICAL, .35, .02, .3, inst, 40)
end

local AOE_RANGE_PADDING = 3
local AOE_TARGET_MUSTHAVE_TAGS = { "_combat" }
local AOE_TARGET_CANT_TAGS = { "INLIMBO", "invisible", "notarget", "wall", "noattack", "sdf_pumpkin_king", "sdf_pumpkin_king_vine_end", "sdf_pumpking_friend" }
local MAX_SIDE_TOSS_STR = 0.8

local function DoAOEAttack(inst, dist, radius, heavymult, mult, forcelanded, targets)
    inst.components.combat.ignorehitrange = true
    local x, y, z = inst.Transform:GetWorldPosition()
    local rot0, x0, z0
    if dist ~= 0 then
        if dist > 0 and ((mult ~= nil and mult > 1) or (heavymult ~= nil and heavymult > 1)) then
            x0, z0 = x, z
        end
        rot0 = inst.Transform:GetRotation() * DEGREES
        x = x + dist * math.cos(rot0)
        z = z - dist * math.sin(rot0)
    end
    for i, v in ipairs(TheSim:FindEntities(x, y, z, radius + AOE_RANGE_PADDING, AOE_TARGET_MUSTHAVE_TAGS, AOE_TARGET_CANT_TAGS)) do
        if v ~= inst and not (targets ~= nil and targets[v]) and v:IsValid() and not v:IsInLimbo() and not (v.components.health ~= nil and v.components.health:IsDead()) then
            local range = radius + v:GetPhysicsRadius(0)
            if v:GetDistanceSqToPoint(x, y, z) < range * range and inst.components.combat:CanTarget(v) then

		--check if can be attacked
		if v:HasTag("companion") or v:HasTag("summonedbyplayer") then
		    v.components.combat:DropTarget()

		    --stop attacking during retaliates
		    if v._sdf_pumpkin_king_aggro_debufftask ~= nil then
			v._sdf_pumpkin_king_aggro_debufftask:Cancel()
		    end

		    v.components.combat:AddNoAggroTag("retaliates")
		    v._sdf_pumpkin_king_aggro_debufftask = v:DoTaskInTime((TUNING.SDF_PUMPKIN_KING_AGGRO_DEBUFF_DURATION), function(i)
			i.components.combat:RemoveNoAggroTag("retaliates") i._sdf_pumpkin_king_aggro_debufftask = nil
		    end)
		else
		    inst.components.combat:DoAttack(v)
		end

                if mult ~= nil then
                    local strengthmult = (v.components.inventory ~= nil and v.components.inventory:ArmorHasTag("heavyarmor") or v:HasTag("heavybody")) and heavymult or mult
                    if strengthmult > MAX_SIDE_TOSS_STR and x0 ~= nil then
                        --Don't toss as far to the side for frontal attacks
                        local rot1 = (v:GetAngleToPoint(x0, 0, z0) + 180) * DEGREES
                        local k = math.max(0, math.cos(math.min(PI, DiffAngleRad(rot1, rot0) * 2)))
                        strengthmult = MAX_SIDE_TOSS_STR + (strengthmult - MAX_SIDE_TOSS_STR) * k * k
                    end
                    v:PushEvent("knockback", { knocker = inst, radius = radius + dist + 3, strengthmult = strengthmult, forcelanded = forcelanded })
                end

                if targets ~= nil then
                    targets[v] = true
                end
            end
        end
    end
    inst.components.combat.ignorehitrange = false
end

local function shouldBombardment(inst)
    if not inst.sg:HasStateTag('busy') and not inst.components.timer:TimerExists("bombardment_cooldown") then
	inst.sg:GoToState("bombardment")
    else
	inst.sg:GoToState("idle")
    end
end

local actionhandlers =
{

}

local events =
{
    CommonHandlers.OnFreeze(),

    EventHandler("attacked", function(inst)
        if not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") then
	    if inst:HasTag("huskRegen") and inst.winterMode == true then
                inst.sg:GoToState("hit_husk_frozen")
	    elseif inst:HasTag("huskRegen") and (inst.components.freezable == nil or not inst.components.freezable:IsFrozen()) then
                inst.sg:GoToState("hit_husk")
	    elseif inst:HasTag("huskRegen") and inst.components.freezable:IsFrozen() then
                inst.sg:GoToState("hit_husk_frozen")
	    else
                inst.sg:GoToState("hit")
	    end
        end
    end),

    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
}

local states=
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst)
            inst:customPlayAnimation("idle_"..inst.targetsize)
        end,

        events =
        {
            EventHandler("animover", function(inst) 
		if inst.phaseCount > 0 then
		    local bombRng = math.random()
		    if bombRng <= TUNING.SDF_PUMPKIN_KING_SEED_BOMBARDMENT_CHANCE then
			shouldBombardment(inst)
		    else
			inst.sg:GoToState("idle")
		    end
		else
		    inst.sg:GoToState("idle")
		end
            end),
        },
    },

    State{
        name = "spawn",
        tags = {"busy"},

        onenter = function(inst)
            inst:customPlayAnimation("spawn_"..inst.targetsize)
            inst.SoundEmitter:PlaySound("rifts/lunarthrall/spawn")

            inst.tired = true
        end,

        events =
        {
            EventHandler("animover", function(inst)  inst.sg:GoToState("husk_regen_spawn") end),
        },
    }, 

    State{
        name = "spawn_thaw",
        tags = {"busy"},

        onenter = function(inst)
            inst:customPlayAnimation("frozen_loop_pst_"..inst.targetsize, true)
            inst.SoundEmitter:PlaySound("dontstarve/common/freezethaw", "thawing")

            inst.tired = true

	    --remove husk frost
	    if inst.husk ~= nil then
		inst.husk.components.colouradder:PopColour("frost")
	    end

	    local x,_,z=inst.Transform:GetWorldPosition()
	    local s = 1.5 --1.5
	    local pumpkingFrostFX = SpawnPrefab("fx_ice_crackle") --fx_ice_pop
	    if pumpkingFrostFX ~= nil then
		pumpkingFrostFX.Transform:SetPosition(x,_ +2,z)
		pumpkingFrostFX.Transform:SetScale(s,s,s)
	    end
        end,

        events =
        {
            EventHandler("animover", function(inst)  inst.sg:GoToState("husk_regen_spawn") end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("thawing")
        end,
    }, 

    State{
        name = "spawn_winter",
        tags = {"busy"},

        onenter = function(inst)
            inst:customPlayAnimation("spawn_"..inst.targetsize)
            inst.SoundEmitter:PlaySound("rifts/lunarthrall/spawn")

            inst.tired = true
        end,

        events =
        {
            EventHandler("animover", function(inst)  inst.sg:GoToState("husk_regen_winter") end),
        },
    }, 

    State{
        name = "rest",
        tags = {"busy"},

        onenter = function(inst)
            inst:customPlayAnimation("sleep_pst_"..inst.targetsize)
            inst.SoundEmitter:PlaySound("rifts/lunarthrall/tired_pre")

            inst.tired = true
        end,

        events =
        {
            EventHandler("animover", function(inst)  inst.sg:GoToState("husk_regen_spawn") end),
        },
    }, 

    State{
        name = "husk_regen_spawn",
        tags = {"husk", "canrotate"},

        onenter = function(inst)
            inst:customPlayAnimation("idle_"..inst.targetsize)
        end,

        events =
        {
            EventHandler("animover", function(inst) 
                inst.sg:GoToState("husk_regen_spawn")
            end),
        },
    },

    State{
        name = "husk_regen",
        tags = {"husk", "canrotate"},

        onenter = function(inst)
            inst:customPlayAnimation("idle_"..inst.targetsize)
        end,

        events =
        {
            EventHandler("animover", function(inst) 
                inst.sg:GoToState("husk_regen")
            end),
        },
    },

    State{
        name = "husk_regen_winter",
        tags = {"husk", "canrotate"},

        onenter = function(inst)
            inst:customPlayAnimation("frozen_"..inst.targetsize)
        end,

        events =
        {
            EventHandler("animover", function(inst) 
                inst.sg:GoToState("husk_regen_winter")
            end),
        },
    },

    State{
        name = "husk_regen_pst",
        tags = {"busy"},

        onenter = function(inst)
	    inst.SoundEmitter:PlaySound("rifts/lunarthrall/tired_pre")
            inst:customPlayAnimation("sleep_pst_"..inst.targetsize) --"tired_pst_"

	    --shake screen
	    DoShake(inst)
        end,

        onexit = function(inst)
	    inst:RemoveTag("huskRegen")
	    inst:AddTag("retaliates")
	    inst.waketask = nil
	    inst.wake = nil
	    inst.tired = nil
	    inst.vinelimit = TUNING.SDF_PUMPKIN_KING_VINE_LIMIT --TUNING.SDF_PUMPKIN_KING_VINE_LIMIT - inst.phaseCount
	    inst.components.health:SetAbsorptionAmount(TUNING.SDF_PUMPKIN_KING_HEALTH_ABSORB)

	    if inst.components.talker then
		inst.components.talker:Say(""..inst.phaseCount.." phase start")
	    end
        end,

        events =
        {
            EventHandler("animover", function(inst)
		if inst.AnimState:AnimDone() then
		    if inst.phaseCount == 0 then
			inst.sg:GoToState("idle") --idle
		    else
			inst.sg:GoToState("attack_ability") -- do special attack based on phase
		    end
		end
	    end),
        },
    },

    State{
        name = "hit",
        tags = {"busy","nointerrupt"},

        onenter = function(inst)
	    inst.SoundEmitter:PlaySound("rifts/lunarthrall/hit")
            if inst.tired then
		if not inst.SoundEmitter:PlayingSound("wakeLP") then
		    inst.SoundEmitter:PlaySound("rifts/lunarthrall/rustle_wakeup_LP", "wakeLP")
		    inst:customPlayAnimation("hit_"..inst.targetsize)
		end
            else
		inst.sg:GoToState("attack_counter")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst) 
                if inst.tired then
                    if inst.wake then
			inst.sg.statemem.tired_wake = true
                        inst.sg:GoToState("tired_wake")
                    else
                        inst.sg:GoToState("tired")
                    end
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
	    if not inst.sg.statemem.tired_wake then
		inst.SoundEmitter:KillSound("wakeLP")
	    end
        end,
    },

    State{
        name = "hit_husk",
        tags = {"busy","nointerrupt"},

        onenter = function(inst)
	    inst.SoundEmitter:PlaySound("rifts/lunarthrall/hit")
	    inst.sg:GoToState("attack_husk")
        end,

        events =
        {
            EventHandler("animover", function(inst)
		if inst.phaseCount == 0 then
		    inst.sg:GoToState("husk_regen_spawn")
		else
		    inst.sg:GoToState("husk_regen")
		end
            end),
        },

        onexit = function(inst)
	    if not inst.sg.statemem.tired_wake then
		inst.SoundEmitter:KillSound("wakeLP")
	    end
        end,
    },

    State{
        name = "hit_husk_frozen",
        tags = {"busy","nointerrupt"},

        onenter = function(inst)
	    local fx = SpawnPrefab("shatter")
	    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
	    fx.components.shatterfx:SetLevel(2)
        end,

        events =
        {
            EventHandler("animover", function(inst)
		if inst.winterMode == true then
		    inst.sg:GoToState("husk_regen_winter")
		elseif inst.phaseCount == 0 then
		    inst.sg:GoToState("husk_regen_spawn")
		else
		    inst.sg:GoToState("husk_regen")
		end
            end),
        },

        onexit = function(inst)
	    if not inst.sg.statemem.tired_wake then
		inst.SoundEmitter:KillSound("wakeLP")
	    end
        end,
    },

    State{
	name = "attack",
        tags = {"busy"},

        onenter = function(inst)
            inst:customPlayAnimation("atk_"..inst.targetsize)
	    inst.SoundEmitter:PlaySound("rifts/lunarthrall/attack")
        end,

        timeline=
        {
	    FrameEvent(4, function(inst)
		inst.sg.statemem.targets = {}
		DoAOEAttack(inst, 0, 4, 1, 1, false, inst.sg.statemem.targets)
	    end),
	    FrameEvent(5, function(inst)
		DoAOEAttack(inst, 0, 4, 1, 1, false, inst.sg.statemem.targets)
	    end),
	    FrameEvent(6, function(inst)
		DoAOEAttack(inst, 0, 4, 1, 1, false, inst.sg.statemem.targets)
	    end),
        },

        events =
        {
            EventHandler("animover", function(inst)
		if inst.AnimState:AnimDone() then
		    if inst.phaseCount >= 2 then
			local addRng = math.random()
			if addRng <= TUNING.SDF_PUMPKIN_KING_SEED_REINFORCEMENT_CHANCE then
			    inst:PlantPumpkingRandomSeed()
			    inst.sg:GoToState("cast_ability")
			else
			    inst.sg:GoToState("idle")
			end
		    else
			inst.sg:GoToState("idle")
		    end
		end 
	    end),
        },
    },

    State{
	name = "attack_counter",
        tags = {"busy"},

        onenter = function(inst)
            inst:customPlayAnimation("atk_"..inst.targetsize)
	    inst.SoundEmitter:PlaySound("rifts/lunarthrall/attack")
        end,

        timeline=
        {
	    FrameEvent(4, function(inst)
		inst.sg.statemem.targets = {}
		DoAOEAttack(inst, 0, 4, 1, 1, false, inst.sg.statemem.targets)
	    end),
	    FrameEvent(5, function(inst)
		DoAOEAttack(inst, 0, 4, 1, 1, false, inst.sg.statemem.targets)
	    end),
	    FrameEvent(6, function(inst)
		DoAOEAttack(inst, 0, 4, 1, 1, false, inst.sg.statemem.targets)
	    end),
        },

        events =
        {
            EventHandler("animover", function(inst)
		if inst.AnimState:AnimDone() then
		    inst.sg:GoToState("idle")
		end
	    end),
        },
    },

    State{
	name = "attack_husk",
        tags = {"busy"},

        onenter = function(inst)
            inst:customPlayAnimation("atk_"..inst.targetsize)
	    inst.SoundEmitter:PlaySound("rifts/lunarthrall/attack")
        end,

        timeline=
        {
	    FrameEvent(4, function(inst)
		inst.sg.statemem.targets = {}
		DoAOEAttack(inst, 0, 4, 1, 1, false, inst.sg.statemem.targets)
	    end),
	    FrameEvent(5, function(inst)
		DoAOEAttack(inst, 0, 4, 1, 1, false, inst.sg.statemem.targets)
	    end),
	    FrameEvent(6, function(inst)
		DoAOEAttack(inst, 0, 4, 1, 1, false, inst.sg.statemem.targets)
	    end),
        },

        events =
        {
            EventHandler("animover", function(inst)
		if inst.AnimState:AnimDone() then
		    if inst.phaseCount == 0 then
			inst.sg:GoToState("husk_regen_spawn")
		    else
			inst.sg:GoToState("husk_regen")
		    end
		end
	    end),
        },
    },

    State{
	name = "attack_ability",
        tags = {"busy"},

        onenter = function(inst)
            inst:customPlayAnimation("atk_"..inst.targetsize)
	    inst.SoundEmitter:PlaySound("rifts/lunarthrall/attack")
        end,

        timeline=
        {
	    FrameEvent(4, function(inst)
		inst.sg.statemem.targets = {}
		DoAOEAttack(inst, 0, 4, 1, 1, false, inst.sg.statemem.targets)
	    end),
	    FrameEvent(5, function(inst)
		DoAOEAttack(inst, 0, 4, 1, 1, false, inst.sg.statemem.targets)
	    end),
	    FrameEvent(6, function(inst)
		DoAOEAttack(inst, 0, 4, 1, 1, false, inst.sg.statemem.targets)
	    end),
        },

        events =
        {
            EventHandler("animover", function(inst)
		if inst.AnimState:AnimDone() then
		    if inst.phaseCount == 1 then  --spawn pumpking plants and bombardment
			inst:PlantPumpkingGourdSeed()
			inst.sg:GoToState("cast_ability")
		    elseif inst.phaseCount == 2 then  --spawn pumpking plants x 1, spawn pumpking creepers x 1, bombardment, reinforcement, and start misama aoe
			inst:PlantPumpkingGourdSeed()

			inst:DoTaskInTime(TUNING.SDF_PUMPKIN_KING_SEED_COMBO_COOLDOWN, function()
			    inst:PlantPumpkingCreeperSeed()
			    inst.sg:GoToState("cast_ability")
			end)
			inst.sg:GoToState("cast_ability")
		    elseif inst.phaseCount == 3 then  --spawn pumpking plants x 1, spawn pumpking creepers x 1, bombardment, reinforcement, fast misama aoe, and misama on hit chance 
			inst:PlantPumpkingGourdSeed()

			inst:DoTaskInTime(TUNING.SDF_PUMPKIN_KING_SEED_COMBO_COOLDOWN, function()
			    inst:PlantPumpkingCreeperSeed()
			    inst.sg:GoToState("cast_ability")
			end)
			inst.sg:GoToState("cast_ability")
		    else
			inst.sg:GoToState("idle")
		    end
		end 
	    end),
        },
    },

    State{
        name = "cast_ability",
        tags = { "attack", "busy", "canrotate" },

        onenter = function(inst)
	    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/infection_post")
            inst:customPlayAnimation("frozen_loop_pst_"..inst.targetsize)
        end,

        events =
        {
            EventHandler("animover", function(inst) 
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "bombardment",
        tags = { "attack", "busy" },

        onenter = function(inst, target)
            inst.AnimState:PlayAnimation("frozen_loop_pst_"..inst.targetsize)
	    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/infection_post")

	    inst:DoBombardment()

	    local bombardmentTimerAdjustment = TUNING.SDF_PUMPKIN_KING_SEED_BOMBARDMENT_COOLDOWN - ((inst.phaseCount * 2) + 4)
	    inst.components.timer:StopTimer("bombardment_cooldown")
	    inst.components.timer:StartTimer("bombardment_cooldown", bombardmentTimerAdjustment + math.random()*3)
        end,

        timeline =
        {

        },

        events =
        {
            EventHandler("animover", function(inst) 
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "death",
        tags = {"busy"},

        onenter = function(inst)
            inst:customPlayAnimation("death_"..inst.targetsize)
            inst.SoundEmitter:PlaySound("rifts/lunarthrall/death")

	    --inst:customPushAnimation("rotten_"..inst.targetsize)
            RemovePhysicsColliders(inst)
        end,
    }, 

    State{
        name = "tired_pre",
        tags = {"busy","tired"},

        onenter = function(inst)
            inst.tired = true
            inst:RemoveTag("retaliates")

	    if inst.phaseReady == false then
		inst.components.health:SetAbsorptionAmount(TUNING.SDF_PUMPKIN_KING_HEALTH_ABSORB_WEAKEN)
	    end

	    --deals damage to pumpkin king
	    local currentKingHealthPercent = inst.components.health:GetPercent()
	    if currentKingHealthPercent >= (TUNING.SDF_PUMPKIN_KING_VINE_HEALTH_DAMAGE_PERCENT + 0.01) then
		local totalAdjustDamage = (TUNING.SDF_PUMPKIN_KING_HEALTH * TUNING.SDF_PUMPKIN_KING_VINE_HEALTH_DAMAGE_PERCENT)
		inst.components.combat:GetAttacked(inst, totalAdjustDamage)
	    end

            inst.SoundEmitter:PlaySound("rifts/lunarthrall/tired_pre")

	    DoShake(inst)
        end,

        onexit = function(inst)
            inst:AddTag("retaliates")
        end,
        
        events =
        {
            EventHandler("animover", function(inst) if inst.AnimState:AnimDone() then inst.sg:GoToState("tired") end end),
        },
    },

    State{
        name = "tired",
        tags = {"idle","tired"},

        onenter = function(inst)
            inst:RemoveTag("retaliates")
            inst.tired = true
            inst:customPlayAnimation("sleep_loop_"..inst.targetsize) --"tired_loop_"
        end,

        onexit = function(inst)
            inst:AddTag("retaliates")
        end,

        events =
        {
            EventHandler("animover", function(inst) if inst.AnimState:AnimDone() then inst.sg:GoToState("tired") end end),
        },
    },

    State{
        name = "tired_wake",
        tags = {"idle","tried","wake"},

        onenter = function(inst)
            inst:RemoveTag("retaliates")
	    if not inst.SoundEmitter:PlayingSound("wakeLP") then
		inst.SoundEmitter:PlaySound("rifts/lunarthrall/rustle_wakeup_LP", "wakeLP")
	    end
            inst.wake = true
            inst:customPlayAnimation("frozen_loop_pst_"..inst.targetsize) --"tired_wakeup_loop_"
        end,

        events =
        {
            EventHandler("animover", function(inst) 
                if inst.AnimState:AnimDone() then 
                    inst.sg.statemem.tired_wake = true
                    inst.sg:GoToState("tired_wake") 
                end 
            end),
        },

        onexit = function(inst)
	    if inst.phaseReady == false then
		inst:AddTag("retaliates")
		inst.components.health:SetAbsorptionAmount(TUNING.SDF_PUMPKIN_KING_HEALTH_ABSORB)
	    end

            if not inst.sg.statemem.tired_wake then
                inst.SoundEmitter:KillSound("wakeLP")                
            end
        end,
    },


    State{
        name = "frozen",
        tags = { "busy", "frozen" },

        onenter = function(inst)
            inst:customPlayAnimation("frozen_"..inst.targetsize, true)
            inst.SoundEmitter:PlaySound("dontstarve/common/freezecreature")
            inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")

	    if inst:HasTag("huskRegen") then
		if inst.winterMode == true then
		    inst.sg:GoToState("hit_husk_frozen")
		elseif inst.components.freezable == nil then
		    inst.sg:GoToState("hit_husk_frozen")
		elseif inst.components.freezable:IsThawing() then
		    inst.sg.statemem.thawing = true
		    inst.sg:GoToState("thaw")
		elseif not inst.components.freezable:IsFrozen() then
		    inst.sg:GoToState("hit_husk_frozen")
		end
	    else
		if inst.components.freezable == nil then
		    inst.sg:GoToState("hit")
		elseif inst.components.freezable:IsThawing() then
		    inst.sg.statemem.thawing = true
		    inst.sg:GoToState("thaw")
		elseif not inst.components.freezable:IsFrozen() then
		    inst.sg:GoToState("hit")
		end
	    end
        end,

        events =
        {
            EventHandler("unfreeze", function(inst)
		if inst:HasTag("huskRegen") then
		    if inst.winterMode == true then
			inst.sg:GoToState("husk_regen_winter")
		    elseif inst.phaseCount == 0 then
			inst.sg:GoToState("husk_regen_spawn")
		    else
			inst.sg:GoToState("husk_regen")
		    end
		else
		    inst.sg:GoToState(inst.sg.sg.states.hit ~= nil and "hit" or "idle")
		end
	    end),
	    EventHandler("onthaw", function(inst)
		inst.sg.statemem.thawing = true
		inst.sg:GoToState("thaw")
	    end),
        },

        onexit = function(inst)
	    if not inst.sg.statemem.thawing then
		--inst.AnimState:ClearOverrideSymbol("swap_frozen")
		--inst.components.freezable:Unfreeze()
	    end
        end,
    },

    State{
        name = "thaw",
        tags = { "busy", "thawing" },

        onenter = function(inst)
            inst:customPlayAnimation("frozen_loop_pst_"..inst.targetsize, true)
            inst.SoundEmitter:PlaySound("dontstarve/common/freezethaw", "thawing")
            inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")

	    if inst:HasTag("huskRegen") then
		if inst.winterMode == true then
		    inst.sg:GoToState("hit_husk_frozen")
		elseif inst.components.freezable == nil or not inst.components.freezable:IsFrozen() then
		  inst.sg:GoToState("hit_husk")
		end
            else
		if inst.components.freezable == nil or not inst.components.freezable:IsFrozen() then
		    inst.sg:GoToState("hit")
		end
	    end
        end,

        events =
        {
	    EventHandler("unfreeze", function(inst)
		if inst:HasTag("huskRegen") then
		    if inst.winterMode == true then
			inst.sg:GoToState("husk_regen_winter")
		    elseif inst.phaseCount == 0 then
			inst.sg:GoToState("husk_regen_spawn")
		    else
			inst.sg:GoToState("husk_regen")
		    end
		else
		    inst.sg:GoToState(inst.sg.sg.states.hit ~= nil and "hit" or "idle")
		end
	    end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("thawing")
            inst.AnimState:ClearOverrideSymbol("swap_frozen")
	    inst.components.freezable:Unfreeze()
        end,
    },
}


return StateGraph("SGsdf_pumpkin_king", states, events, "idle", actionhandlers)
