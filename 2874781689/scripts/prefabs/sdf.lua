local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
	Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
	Asset("SCRIPT", "scripts/prefabs/skilltree_sdf.lua"),

	Asset( "ANIM", "anim/sdf.zip" ),
	Asset( "ANIM", "anim/ghost_sdf_build.zip" ),
	Asset( "ANIM", "anim/swap_sdf_victorian_suit.zip" ),
	Asset( "ANIM", "anim/swap_sdf_gold_armor.zip" ),
	Asset( "ANIM", "anim/swap_sdf_dragon_armor.zip" ),
	Asset( "ANIM", "anim/swap_sdf_helmet.zip" ),
	Asset( "ANIM", "anim/swap_sdf_victorian_helmet.zip" ),
	Asset( "ANIM", "anim/swap_sdf_gold_helmet.zip" ),
	Asset( "ANIM", "anim/swap_sdf_dragon_helmet.zip" ),
	Asset( "ANIM", "anim/sdf_eye.zip" ),
	Asset( "ANIM", "anim/swap_sdf_victorian_suit_eye.zip" ),
	Asset( "ANIM", "anim/swap_sdf_gold_armor_eye.zip" ),
	Asset( "ANIM", "anim/swap_sdf_dragon_armor_eye.zip" ),
	Asset( "ANIM", "anim/swap_sdf_helmet_eye.zip" ),
	Asset( "ANIM", "anim/swap_sdf_victorian_helmet_eye.zip" ),
	Asset( "ANIM", "anim/swap_sdf_gold_helmet_eye.zip" ),
	Asset( "ANIM", "anim/swap_sdf_dragon_helmet_eye.zip" ),
}

--SDF stats
TUNING.SDF_HEALTH = 60
TUNING.SDF_HUNGER = 120
TUNING.SDF_SANITY = 200
TUNING.SDF_SANITY_NIGHT_DRAIN_MULT = 1.2
TUNING.SDF_SANITY_NEG_AURA_MULT = 1.4
	

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.SDF
end
local prefabs = FlattenTree(start_inv, true)


local states = {[1] = "sdf", [2] = "swap_sdf_victorian_suit", [3] = "swap_sdf_gold_armor", [4] = "swap_sdf_dragon_armor",
		[5] = "swap_sdf_helmet", [6] = "swap_sdf_victorian_helmet", [7] = "swap_sdf_gold_helmet", [8] = "swap_sdf_dragon_helmet",
		[9] = "sdf_eye", [10] = "swap_sdf_victorian_suit_eye", [11] = "swap_sdf_gold_armor_eye", [12] = "swap_sdf_dragon_armor_eye",
		[13] = "swap_sdf_helmet_eye", [14] = "swap_sdf_victorian_helmet_eye", [15] = "swap_sdf_gold_helmet_eye", [16] = "swap_sdf_dragon_helmet_eye"}

local function ChangeForm(inst, state)
    if TheWorld.ismastersim then
	inst.form = state
	inst.form_net:set(state)
    end
    inst.AnimState:SetBuild(states[inst.form])
end

--Rune Gathering
local function onworked(inst, data)
    if data.target and data.target.components.workable and data.target.components.workable.action == ACTIONS.MINE then
	local targetWorkLeft = data.target.components.workable:GetWorkLeft()
	
	--check moon rune
	local moonRuneEnabled = inst.components.sdf_rune_holder:CheckRuneStatus("sdf_moon_rune")
	local isMoonRuneSource = inst.components.sdf_rune_holder:CheckRuneSource(data.target, inst.components.sdf_rune_holder:GetRuneMoonSource())
	if moonRuneEnabled == false and isMoonRuneSource == true and targetWorkLeft <= 0 then
	    local runeRng = math.random()
	    if runeRng <= TUNING.SDF_MOON_RUNE_GATHER_CHANCE then

		--Create Rune
		inst.components.sdf_rune_holder:CreateRune(inst, data.target, "sdf_moon_rune")

		--Lock Rune
		inst.components.sdf_rune_holder:EnableRuneStatus("sdf_moon_rune")

		--Check to disable Rune Finding
		local canGatherRunes = inst.components.sdf_rune_holder:CanGatherRunes()
		if canGatherRunes == false then
		    inst:RemoveEventCallback("working", onworked)
		end
		return
	    end
	end

	--check earth rune
	local earthRuneEnabled = inst.components.sdf_rune_holder:CheckRuneStatus("sdf_earth_rune")
	local isEarthRuneSource = inst.components.sdf_rune_holder:CheckRuneSource(data.target, inst.components.sdf_rune_holder:GetRuneEarthSource())
	if earthRuneEnabled == false and isEarthRuneSource == true and targetWorkLeft <= 0 then
	    local runeRng = math.random()
	    if runeRng <= TUNING.SDF_EARTH_RUNE_GATHER_CHANCE then

		--Create Rune
		inst.components.sdf_rune_holder:CreateRune(inst, data.target, "sdf_earth_rune")

		--Lock Rune
		inst.components.sdf_rune_holder:EnableRuneStatus("sdf_earth_rune")

		--Check to disable Rune Finding
		local canGatherRunes = inst.components.sdf_rune_holder:CanGatherRunes()
		if canGatherRunes == false then
		    inst:RemoveEventCallback("working", onworked)
		end
		return
	    end
	end

	--check star rune
	local starRuneEnabled = inst.components.sdf_rune_holder:CheckRuneStatus("sdf_star_rune")
	local isStarRuneSource = inst.components.sdf_rune_holder:CheckRuneSource(data.target, inst.components.sdf_rune_holder:GetRuneStarSource())
	if starRuneEnabled == false and isStarRuneSource == true and targetWorkLeft <= 0 then
	    local runeRng = math.random()
	    if runeRng <= TUNING.SDF_STAR_RUNE_GATHER_CHANCE then

		--Create Rune
		inst.components.sdf_rune_holder:CreateRune(inst, data.target, "sdf_star_rune")

		--Lock Rune
		inst.components.sdf_rune_holder:EnableRuneStatus("sdf_star_rune")

		--Check to disable Rune Finding
		local canGatherRunes = inst.components.sdf_rune_holder:CanGatherRunes()
		if canGatherRunes == false then
		    inst:RemoveEventCallback("working", onworked)
		end
		return
	    end
	end

	--check chaos rune
	local chaosRuneEnabled = inst.components.sdf_rune_holder:CheckRuneStatus("sdf_chaos_rune")
	local isChaosRuneSource = inst.components.sdf_rune_holder:CheckRuneSource(data.target, inst.components.sdf_rune_holder:GetRuneChaosSource())
	if chaosRuneEnabled == false and isChaosRuneSource == true and targetWorkLeft <= 0 then

	    local chaosRuneId = data.target.typeid
	    if chaosRuneId == 1 then
		--Create Rune
		inst.components.sdf_rune_holder:CreateRune(inst, data.target, "sdf_chaos_rune")

		--Lock Rune
		inst.components.sdf_rune_holder:EnableRuneStatus("sdf_chaos_rune")

		--Remove Chaos Rock Engraft
		if inst:HasTag("sdf_chaos_rock_engraft") then
		    inst:RemoveTag("sdf_chaos_rock_engraft")
		end

		--Check to disable Rune Finding
		local canGatherRunes = inst.components.sdf_rune_holder:CanGatherRunes()
		if canGatherRunes == false then
		    inst:RemoveEventCallback("working", onworked)
		end
		return
	    end
	end
    end
end

--Skill Tree Morten and Skull
local function mortenSetup(inst)
    --Remove any old mortens
    for follower,_ in pairs(inst.components.leader.followers) do
	if follower.prefab == "sdf_morten" then
	    follower:Remove()
	end
    end

    --create new Morten
    local fishingpole = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    local lure = fishingpole.components.container.slots[2]
    if lure == nil then
	
	--create Morten
	local mortenLure = SpawnPrefab("sdf_morten")
	mortenLure.components.follower:SetLeader(inst)

	--Place Morten in fishingrod
	fishingpole.components.container:GiveItem(mortenLure, fishingpole.components.container.slots[2])
    else
	--create Morten
	local mortenLure = SpawnPrefab("sdf_morten")
	mortenLure.components.follower:SetLeader(inst)

	--Place Morten in inventory
	inst.components.inventory:GiveItem(mortenLure)
    end
end

--Skill Tree Repair Helm
local function OnCyclesChanged(inst, phase)
    if TheGenericKV:GetKV("sdf_fates_arrow_survived") == "1" then
	return
    end

    --checks to see survived days
    if TheWorld.state and TheWorld.state.cycles then
        if TheWorld.state.cycles >= TUNING.SDF_SKILLSET_UNDEATH_HONOR_OF_GALLOWMERE_DAYS then
	    inst:DoTaskInTime(5, function()
		local totalDays = inst.components.age:GetAgeInDays()
		if totalDays >= TUNING.SDF_SKILLSET_UNDEATH_HONOR_OF_GALLOWMERE_DAYS and totalDays < (TUNING.SDF_SKILLSET_UNDEATH_HONOR_OF_GALLOWMERE_DAYS + 1) then
		    SendRPCToClient(CLIENT_RPC.UpdateAccomplishment, inst.userid, "sdf_fates_arrow_survived")
		end
	    end)
        end
    end
end

--Skill Tree Daring Dash
local STANCEMODE_NAMES =
{
    "defend",
}

local STANCEMODE = { NONE = 0 }
for i, v in ipairs(STANCEMODE_NAMES) do
    STANCEMODE[string.upper(v)] = i
end

local function IsStanceMode(mode)
    return STANCEMODE_NAMES[mode] ~= nil
end

local function CannotExamine(inst)
    return false
end

local function Empty()
end

local function ReticuleTargetFn()
    --Cast range is 8, leave room for error (6.5 lunge)
    return Vector3(ThePlayer.entity:LocalToWorldSpace(6.5, 0, 0))
end

local function ReticuleMouseTargetFn(inst, mousepos)
    if mousepos ~= nil then
        local x, y, z = inst.Transform:GetWorldPosition()
        local dx = mousepos.x - x
        local dz = mousepos.z - z
        local l = dx * dx + dz * dz
        if l <= 0 then
            return inst.components.reticule.targetpos
        end
        l = 6.5 / math.sqrt(l)
        return Vector3(x + dx * l, 0, z + dz * l)
    end
end

local function ReticuleUpdatePositionFn(inst, pos, reticule, ease, smoothing, dt)
    local x, y, z = inst.Transform:GetWorldPosition()
    reticule.Transform:SetPosition(x, 0, z)
    local rot = -math.atan2(pos.z - z, pos.x - x) / DEGREES
    if ease and dt ~= nil then
        local rot0 = reticule.Transform:GetRotation()
        local drot = rot - rot0
        rot = Lerp((drot > 180 and rot0 + 360) or (drot < -180 and rot0 - 360) or rot0, rot, dt * smoothing)
    end
    reticule.Transform:SetRotation(rot)
end
------------------------------------------------------------------------------------------------------------------------
local function EnableReticule(inst, enable)
    if enable then
        if inst.components.reticule == nil then
            inst:AddComponent("reticule")
            inst.components.reticule.reticuleprefab = "reticuleline"
	    inst.components.reticule.pingprefab = "reticulelineping"
            inst.components.reticule.targetfn = ReticuleTargetFn
	    inst.components.reticule.mousetargetfn = ReticuleMouseTargetFn
            inst.components.reticule.updatepositionfn = ReticuleUpdatePositionFn
	    inst.components.reticule.validcolour = { 1, .75, 0, 1 }
	    inst.components.reticule.invalidcolour = { .5, 0, 0, 1 }
	    inst.components.reticule.ease = true
	    inst.components.reticule.mouseenabled = true
            if inst.components.playercontroller ~= nil and inst == ThePlayer then
                inst.components.playercontroller:RefreshReticule()
            end
        end
    elseif inst.components.reticule ~= nil then
        inst:RemoveComponent("reticule")
        if inst.components.playercontroller ~= nil and inst == ThePlayer then
            inst.components.playercontroller:RefreshReticule()
        end
    end
end

local function DefendActionString(inst, action)
    return STRINGS.ACTIONHANDLER_SDF_DARING_DASH, false
end

local function DefendLeftClickPicker(inst, target, pos)
    return target ~= inst
        and (
                (
		    not inst.components.playercontroller.isclientcontrollerattached and
                    inst.components.playeractionpicker:SortActionList({ ACTIONS.TACKLE }, target or pos, nil)
                )
            )
        or nil
end

local function DefendPointSpecialActions(inst, pos, useitem, right)
    return right and inst.components.playercontroller:IsEnabled() and { ACTIONS.TACKLE } or {}
end

local function removeDaringDashStatus(inst)
    if inst:HasTag("sdf_shield_daring_dash_active") then
	inst:RemoveTag("sdf_shield_daring_dash_active")
    end

    if inst:HasTag("sdf_daring_dash_action_active") then
	inst:RemoveTag("sdf_daring_dash_action_active")
    end

    --Remove Daring Dash Trail
    if inst.sg.statemem.trailtask ~= nil then
	inst.sg.statemem.trailtask:Cancel()
	inst.sg.statemem.trailtask = nil
    end
end

local function OnTackleStart(inst)
    if inst.sg.currentstate.name == "sdf_daring_dash_pre" then
        inst.sg.statemem.tackling = true
        inst.sg:GoToState("sdf_daring_dash_start")
        return true
    end
end

local function OnTackleCollide(inst, other)
    local x, y, z = inst.Transform:GetWorldPosition()
    local x1, y1, z1 = other.Transform:GetWorldPosition()
    local r = other:GetPhysicsRadius(.5)
    r = r / (r + 1)
    SpawnPrefab("planar_hit_fx").Transform:SetPosition(x1 + (x - x1) * r, 0, z1 + (z - z1) * r)
    SpawnPrefab("round_puff_fx_hi").Transform:SetPosition(x1 + (x - x1) * r, 0, z1 + (z - z1) * r)
    inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/moose/bounce")
    ShakeAllCameras(CAMERASHAKE.FULL, .6, .025, .4, other, 20)
    removeDaringDashStatus(inst)
end

local function OnTackleTrample(inst, other)
    local x, y, z = inst.Transform:GetWorldPosition()
    local x1, y1, z1 = other.Transform:GetWorldPosition()
    local r = other:GetPhysicsRadius(.5)
    r = r / (r + 1)
    SpawnPrefab("planar_hit_fx").Transform:SetPosition(x1 + (x - x1) * r, 0, z1 + (z - z1) * r)
end

local function OnTackleCheck(self,ignores)
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local angle = self.inst.Transform:GetRotation() * DEGREES
    local x1 = x + math.cos(angle) * self.distance
    local z1 = z - math.sin(angle) * self.distance
    local target = nil
    local targetdist = math.huge
    local targetworkable = nil
    local trample = {}
    for i, v in ipairs(TheSim:FindEntities(x1, 0, z1, self.radius + 3, nil, self.no_collide_tags, self.collide_tags)) do
        if ignores == nil or not ignores[v] then
            local x2, y2, z2 = v.Transform:GetWorldPosition()
            local r = v:GetPhysicsRadius(0)
            local d = self.radius + r
            if distsq(x1, z1, x2, z2) < d * d then
                d = math.sqrt(distsq(x, z, x2, z2)) - v:GetPhysicsRadius(0)
                if d < targetdist then
                    if v.components.workable ~= nil and
                        v.components.workable:CanBeWorked() and
                        self.work_actions[v.components.workable:GetWorkAction()] ~= nil and
                        not v:HasTag("smallcreature") then
                        target = v
                        targetdist = d
                        targetworkable = true
                    elseif v.components.combat ~= nil
                        and v.components.health ~= nil
                        and not v.components.health:IsDead()
                        and self.inst.components.combat ~= nil
			and self.inst.components.combat:CanTarget(v)
			and not (self.inst.TargetForceAttackOnly ~= nil and self.inst:TargetForceAttackOnly(v))
			    then
                        if v:HasTag("structure") or v:HasTag("epic") or v:HasTag("largecreature") then
                            target = v
                            targetdist = d
                            targetworkable = false
                        else
                            table.insert(trample, { inst = v, dist = d })
                        end
                    end
                end
            end
        end
    end

    --Daring Dash Collide
    if target ~= nil then
        if ignores ~= nil then
            ignores[target] = true
        end
        if self.oncollidefn ~= nil then
            self.oncollidefn(self.inst, target)
        end
        if targetworkable then
	    --self.inst.components.talker:Say("I hit work")
	    self.inst.sg:GoToState("sdf_daring_dash_collide")
	    local shield = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD)
	    if shield then
		--Damage based on Durability, mainly for Gold Shield
		local shieldDurability = shield.components.armor.condition
		if shieldDurability <= 0 then
		    --Deal Work to target ZERO work
		else
		    --Skill Tree Grit
		    local workChopBonus = 0
		    local workMineBonus = 0
		    local workHammerBonus = 0
		    if self.inst.components.skilltreeupdater:IsActivated("sdf_backbone_3") then
			workChopBonus = TUNING.SDF_SKILLSET_BACKBONE_GRIT_WORK_CHOP
			workMineBonus = TUNING.SDF_SKILLSET_BACKBONE_GRIT_WORK_MINE
			workHammerBonus = TUNING.SDF_SKILLSET_BACKBONE_GRIT_WORK_HAMMER
		    end

		    --Update Daring Dash Work stats
		     self.inst.components.tackler:AddWorkAction(ACTIONS.CHOP, (TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_WORK_CHOP + workChopBonus))
		     self.inst.components.tackler:AddWorkAction(ACTIONS.MINE, (TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_WORK_MINE + workMineBonus))
		     self.inst.components.tackler:AddWorkAction(ACTIONS.HAMMER, (TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_WORK_HAMMER + workHammerBonus))

		    --Deal Work to target
		    target.components.workable:WorkedBy(self.inst, self.work_actions[target.components.workable:GetWorkAction()])
		end

		--Skil Tree Steadfast
		local shieldDamage = 0
		if self.inst.components.skilltreeupdater:IsActivated("sdf_backbone_2") then
		    shieldDamage = TUNING.SDF_SKILLSET_BACKBONE_STEADFAST_SHIELD_DAMAGE_COLLIDE
		end

		--Deal Damage to Shield
		shield.components.armor:TakeDamage((TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_SHIELD_DAMAGE_COLLIDE - shieldDamage) / TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_ARMOR)
	    end
	elseif target:HasTag("epic") or target:HasTag("largecreature") then
	    if target:IsValid() and target.components.combat ~= nil and target.components.health ~= nil and not target.components.health:IsDead() then
		--self.inst.components.talker:Say("I hit epic")
		self.inst.sg:GoToState("sdf_daring_dash_collide")
		local shield = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD)
		if shield then
		    --Damage based on Durability, mainly for Gold Shield
		    local shieldDurability = shield.components.armor.condition
		    local shieldDaringDashBonusDamage = shield._bonusdamage or 0
		    if shieldDurability <= 0 then
			shield.components.weapon:SetDamage(TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_ATTACK_DAMAGE_BROKEN + shieldDaringDashBonusDamage)
		    else
			shield.components.weapon:SetDamage(TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_ATTACK_DAMAGE + shieldDaringDashBonusDamage)
		    end

		    --Deal Damage to target
		    self.inst.components.combat:DoAttack(target, shield)

		    --Skil Tree Steadfast
		    local shieldDamage = 0
		    if self.inst.components.skilltreeupdater:IsActivated("sdf_backbone_2") then
			shieldDamage = TUNING.SDF_SKILLSET_BACKBONE_STEADFAST_SHIELD_DAMAGE_COLLIDE
		    end

		    --Deal Damage to Shield
		    shield.components.armor:TakeDamage((TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_SHIELD_DAMAGE_COLLIDE - shieldDamage) / TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_ARMOR)
		end
	    end
	elseif target:HasTag("structure") then
	    --self.inst.components.talker:Say("I hit structure")
	    self.inst.sg:GoToState("sdf_daring_dash_collide")
	    local shield = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD)
	    if shield then
		--Damage based on Durability, mainly for Gold Shield
		local shieldDurability = shield.components.armor.condition
		local shieldDaringDashBonusDamage = shield._bonusdamage or 0
		if shieldDurability <= 0 then
		    shield.components.weapon:SetDamage(TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_ATTACK_DAMAGE_BROKEN + shieldDaringDashBonusDamage)
		else
		    shield.components.weapon:SetDamage(TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_ATTACK_DAMAGE + shieldDaringDashBonusDamage)
		end

		--Deal Damage to structure
		self.inst.components.combat.externaldamagemultipliers:SetModifier(self.inst, self.structure_damage_mult, "tackler")
		self.inst.components.combat:DoAttack(target, shield)
		self.inst.components.combat.externaldamagemultipliers:RemoveModifier(self.inst, "tackler")

		--Skil Tree Steadfast
		local shieldDamage = 0
		if self.inst.components.skilltreeupdater:IsActivated("sdf_backbone_2") then
		    shieldDamage = TUNING.SDF_SKILLSET_BACKBONE_STEADFAST_SHIELD_DAMAGE_TRAMPLE
		end

		--Deal Damage to Shield
		shield.components.armor:TakeDamage((TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_SHIELD_DAMAGE_COLLIDE - shieldDamage) / TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_ARMOR)
	    end
	end
    end

    --Daring Dash Trample
    for i, v in ipairs(trample) do
        if v.dist < targetdist and
            v.inst:IsValid() and
            v.inst.components.combat ~= nil and
            v.inst.components.health ~= nil and
            not v.inst.components.health:IsDead() and
	    self.inst.components.combat:CanTarget(v.inst) and
	    not (self.inst.TargetForceAttackOnly ~= nil and self.inst:TargetForceAttackOnly(v.inst))
		then
            if ignores ~= nil then
                ignores[v.inst] = true
            end
            if self.ontramplefn ~= nil then
                self.ontramplefn(self.inst, v.inst)
            end
	    if not (v.inst:HasTag("epic") or v.inst:HasTag("largecreature")) then
	        --self.inst.components.talker:Say("I crush underfoot")
		local shield = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD)
		if shield then
		    --Damage based on Durability, mainly for Gold Shield
		    local shieldDurability = shield.components.armor.condition
		    local shieldDaringDashBonusDamage = shield._bonusdamage or 0
		    if shieldDurability <= 0 then
			shield.components.weapon:SetDamage(TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_ATTACK_DAMAGE_BROKEN + shieldDaringDashBonusDamage)
		    else
			shield.components.weapon:SetDamage(TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_ATTACK_DAMAGE + shieldDaringDashBonusDamage)
		    end

		    --Stun targets
		    if v.inst ~= nil and v.inst:IsValid() and v.inst.components.combat ~= nil and not
			(v.inst:HasTag("player") or v.inst:HasTag("playerghost") or v.inst:HasTag("INLIMBO") or v.inst:HasTag("epic")) then
			--Stun effect
			v.inst.components.combat:BlankOutAttacks(TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_STUN_DEBUFF_DURATION)
		    end

		    --Deal Damage to targets
		    self.inst.components.combat:DoAttack(v.inst, shield)

		    --Skil Tree Steadfast
		    local shieldDamage = 0
		    if self.inst.components.skilltreeupdater:IsActivated("sdf_backbone_2") then
			shieldDamage = TUNING.SDF_SKILLSET_BACKBONE_STEADFAST_SHIELD_DAMAGE_TRAMPLE
		    end

		    --Deal Damage to Shield
		    shield.components.armor:TakeDamage((TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_SHIELD_DAMAGE_TRAMPLE - shieldDamage) / TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_ARMOR)
		end
	    end
        end
    end
    return target ~= nil
end

local function SetStanceActions(inst, mode)
    local LagPredictionTimer = 0.1 --1

    if not IsStanceMode(mode) then --Normal Mode
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller.actionbuttonoverride = nil
        end
        if inst.components.playeractionpicker ~= nil then
            inst.components.playeractionpicker.leftclickoverride = nil
            inst.components.playeractionpicker.pointspecialactionsfn = nil
        end
        inst.ActionStringOverride = nil --added delay for visual
        EnableReticule(inst, false)
	inst.components.playercontroller:RemotePausePrediction(LagPredictionTimer)  --For Lag Prediction
    elseif mode == STANCEMODE.DEFEND then --Defend Mode
        inst.ActionStringOverride = DefendActionString
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller.actionbuttonoverride = Empty
        end
        if inst.components.playeractionpicker ~= nil then
            inst.components.playeractionpicker.leftclickoverride = DefendLeftClickPicker
            inst.components.playeractionpicker.pointspecialactionsfn = DefendPointSpecialActions
        end
        EnableReticule(inst, true)
	inst.components.playercontroller:RemotePausePrediction(LagPredictionTimer) --For Lag Prediction Could try no time ()
    end
end

local function SetStanceMode(inst, mode)
    if IsStanceMode(mode) then
        if not TheWorld.ismastersim then
            inst.CanExamine = CannotExamine
            SetStanceActions(inst, mode)
        end
    else
        if not TheWorld.ismastersim then
            inst.CanExamine = nil
            SetStanceActions(inst, mode)
        end
    end
end

local function OnStanceModeDirty(inst)
    if not inst:HasTag("playerghost") then
        SetStanceMode(inst, inst.stancemode:value())
    end
end

local function OnPlayerDeactivated(inst)
    if not TheWorld.ismastersim then
        inst:RemoveEventCallback("stancemodedirty", OnStanceModeDirty)
    end
end

local function OnPlayerActivated(inst)
    if not TheWorld.ismastersim then
        inst:ListenForEvent("stancemodedirty", OnStanceModeDirty)
    end
    OnStanceModeDirty(inst)
end

local function IsStanceDefend(inst)
    return inst.stancemode:value() == STANCEMODE.DEFEND
end

local function ChangeStanceModeValue(inst, newmode)
    if inst.stancemode:value() ~= newmode then
        inst.stancemode:set(newmode)
        OnStanceModeDirty(inst)
    end
end

local function onStanceNormal(inst)
    --Allows early Daring Dash Cancel
    if (inst.sg.currentstate.name == "sdf_daring_dash" or inst.sg.currentstate.name == "sdf_daring_dash_start") then
	if (inst.sg.statemem.hungry ~= nil and inst.sg.statemem.hungry == false) then
	    inst.sg:GoToState("sdf_daring_dash_stop")
	end
    elseif inst.sg.currentstate.name == "sdf_daring_dash_pre" then
	--removeDaringDashStatus(inst)
	inst.sg:GoToState("hit")
    end

    removeDaringDashStatus(inst)

    inst.components.pinnable.canbepinned = true
    inst.CanExamine = nil
    SetStanceActions(inst, STANCEMODE.NONE)
    ChangeStanceModeValue(inst, STANCEMODE.NONE)
end


local function onStanceDefend(inst)
    inst.components.pinnable.canbepinned = false
    inst.CanExamine = CannotExamine
    SetStanceActions(inst, STANCEMODE.DEFEND)
    ChangeStanceModeValue(inst, STANCEMODE.DEFEND)
end

--SkillTree Eye of Amon Ra, Morten, Daring Dash, Grit
local function IsValidSkillTreeBossKillVictim(target)
    return target ~= nil and (target:HasTag("eyeofterror") or target:HasTag("deerclops") or target:HasTag("warg") or target:HasTag("bearger"))
    and target.components.health ~= nil and target.components.combat ~= nil
end

local function trackattackers(inst,target)
    if inst and inst:HasTag("player") then
        target.attackerUSERIDs[inst.userid] = true
    end
end

local function OnHitOther(inst, data)
    if data ~= nil and (data.target ~= nil or data.attacker ~= nil) then

	--SkillTree Boss Kills
	local target = data.target
	if IsValidSkillTreeBossKillVictim(target) then
	    if target.attackerUSERIDs ~= nil then
		trackattackers(inst,target)
	    end
	end

	--SkillTree Eye of Amon Ra Active
	if inst.components.skilltreeupdater:IsActivated("sdf_skull_1") then
	    if data.damage > 0 and data.target ~= nil and data.target:IsValid() or not data.target:HasTag("INLIMBO") then
		if data.target._sdf_eye_of_amon_ra_marked_cooldown_debufftask ~= nil then
		    return
		end
		if data.target.components.combat ~= nil and data.target.components.health ~= nil and not data.target.components.health:IsDead()
		    and inst.components.combat ~= nil and inst.components.combat:CanTarget(data.target) then

		    --SkillTree Eye of Amon Ra Marked
		    if data.target._sdf_eye_of_amon_ra_marked_debufftask ~= nil then
			
			--Apply Eye Cooldown
			data.target._sdf_eye_of_amon_ra_marked_cooldown_debufftask = data.target:DoTaskInTime(TUNING.SDF_SKILLSET_SKULL_EYE_OF_AMON_RA_DEBUFF_COOLDOWN, function(i)
			    --Remove marker cooldown timer
			    i._sdf_eye_of_amon_ra_marked_cooldown_debufftask:Cancel()
			    i._sdf_eye_of_amon_ra_marked_cooldown_debufftask = nil
			end)

			--Add consume marker FX
			data.target._sdf_eye_of_amon_ra_consumeFX = SpawnPrefab("sdf_eye_of_amon_ra_marker_consume_fx")
			data.target:AddChild(data.target._sdf_eye_of_amon_ra_consumeFX)
			local scale = Remap(data.target:GetPhysicsRadius() or 0, 0, 5, 0.5, 8)
			data.target._sdf_eye_of_amon_ra_consumeFX.Transform:SetScale(scale, scale, scale)
			if data.target.SoundEmitter then
			    data.target.SoundEmitter:PlaySound("dontstarve_DLC001/characters/wathgrithr/valhalla")
			end

			--Remove logo marker FX
			if data.target._sdf_eye_of_amon_ra_logoFX then
			    data.target._sdf_eye_of_amon_ra_logoFX:goAwayFn()
			    data.target._sdf_eye_of_amon_ra_logoFX = nil
			end
			--Remove marker FX timer
			if data.target._sdf_eye_of_amon_ra_marked_debufftask ~= nil then
			    data.target._sdf_eye_of_amon_ra_marked_debufftask:Cancel()
			    data.target._sdf_eye_of_amon_ra_marked_debufftask = nil
			end
			--Remove sparkle FX repeat
			if data.target._sdf_eye_of_amon_ra_swirlFX_debufftask ~= nil then
			    data.target._sdf_eye_of_amon_ra_swirlFX_debufftask:Cancel()
			    data.target._sdf_eye_of_amon_ra_swirlFX_debufftask = nil
			end

			--Do extra damage here
			if data.weapon ~= nil then --has weapon
			    --calcDamage
			    local weaponDamage = 0
			    local bonusPlanarDamage = 0
			    local bonusPlanarDamageMulti = TUNING.SDF_SKILLSET_SKULL_EYE_OF_AMON_RA_BONUS_PLANAR_MULTI

			    --Skill Tree Focus
			    if inst.components.skilltreeupdater:IsActivated("sdf_skull_2") then
				bonusPlanarDamageMulti = TUNING.SDF_SKILLSET_SKULL_FOCUS
			    end

			    --Extra Damage
			    if data.weapon.components.weapon then
				weaponDamage = (weaponDamage + data.weapon.components.weapon:GetDamage(inst, data.target))
			    end
			    --Extra Planar Damage
			    if data.weapon.components.planardamage then
				weaponDamage = (weaponDamage + data.weapon.components.planardamage:GetDamage())
			    end

			    bonusPlanarDamage = (weaponDamage * bonusPlanarDamageMulti)
			    if bonusPlanarDamage > 0 then
				data.target.components.combat:GetAttacked(inst, 0, nil, nil, {bonusPlanarDamage})
			    end
			else --unarmed
			    --calcDamage
			    local weaponDamage = TUNING.SDF_DAMAGE_UNARMED
			    local bonusPlanarDamage = 0
			    local bonusPlanarDamageMulti = TUNING.SDF_SKILLSET_SKULL_EYE_OF_AMON_RA_BONUS_PLANAR_MULTI

			    --Skill Tree Focus
			    if inst.components.skilltreeupdater:IsActivated("sdf_skull_2") then
				bonusPlanarDamageMulti = TUNING.SDF_SKILLSET_SKULL_FOCUS
			    end

			    bonusPlanarDamage = (weaponDamage * bonusPlanarDamageMulti)
			    if bonusPlanarDamage > 0 then
				data.target.components.combat:GetAttacked(inst, 0, nil, nil, {bonusPlanarDamage})
			    end
			end
		    else
			--SkillTree Eye of Amon Ra Not Marked
			local eyeRng = math.random()
			local eyeProcChance = TUNING.SDF_SKILLSET_SKULL_EYE_OF_AMON_RA_PROC_CHANCE

			--Skill Tree Perception
			if inst.components.skilltreeupdater:IsActivated("sdf_skull_3") then
			    eyeProcChance = TUNING.SDF_SKILLSET_SKULL_PERCEPTION
			end

			if eyeRng <= eyeProcChance then --Mark Target

			    --new marker FX Timer
			    data.target._sdf_eye_of_amon_ra_marked_debufftask = data.target:DoTaskInTime(TUNING.SDF_SKILLSET_SKULL_EYE_OF_AMON_RA_DEBUFF_DURATION, function(i)
				--Remove logo
				if i._sdf_eye_of_amon_ra_logoFX then
				    i._sdf_eye_of_amon_ra_logoFX:goAwayFn()
				    i._sdf_eye_of_amon_ra_logoFX = nil
				end
				--Remove swirl Repeat
				if i._sdf_eye_of_amon_ra_swirlFX_debufftask ~= nil then
				    i._sdf_eye_of_amon_ra_swirlFX_debufftask:Cancel()
				    i._sdf_eye_of_amon_ra_swirlFX_debufftask = nil
				end
				--Remove marker timer
			        i._sdf_eye_of_amon_ra_marked_debufftask:Cancel()
			        i._sdf_eye_of_amon_ra_marked_debufftask = nil
			    end)


			    --When Debuff is Active
			    if data.target._sdf_eye_of_amon_ra_marked_debufftask ~= nil then

				--marker logo FX
				if data.target._sdf_eye_of_amon_ra_logoFX == nil and data.target ~= nil then
				    --logo FX
				    data.target._sdf_eye_of_amon_ra_logoFX = SpawnPrefab("sdf_eye_of_amon_ra_marker_logo_fx")

				    data.target:AddChild(data.target._sdf_eye_of_amon_ra_logoFX)
				    local scale = Remap(data.target:GetPhysicsRadius() or 0, 0, 5, 0.5, 8)
				    data.target._sdf_eye_of_amon_ra_logoFX.Transform:SetScale(scale, scale, scale)
				end

				--swirl FX Repeat
				if data.target._sdf_eye_of_amon_ra_swirlFX_debufftask == nil then
				    data.target._sdf_eye_of_amon_ra_swirlFX_debufftask = data.target:DoPeriodicTask(1, function(i)
					if data.target ~= nil and not i.components.health:IsDead() then
					    --swirl FX
					    i._sdf_eye_of_amon_ra_swirlFX = SpawnPrefab("sdf_eye_of_amon_ra_marker_swirl_fx")

					    i:AddChild(i._sdf_eye_of_amon_ra_swirlFX)
					    local scale2 = Remap(i:GetPhysicsRadius() or 0, 0, 5, 0.5, 8)
					    i._sdf_eye_of_amon_ra_swirlFX.Transform:SetScale(scale2, scale2, scale2)

					else
					    --Add consume marker FX
					    i._sdf_eye_of_amon_ra_consumeFX = SpawnPrefab("sdf_eye_of_amon_ra_marker_consume_fx")
					    i:AddChild(data.target._sdf_eye_of_amon_ra_consumeFX)
					    local scale = Remap(i:GetPhysicsRadius() or 0, 0, 5, 0.5, 8)
					    i._sdf_eye_of_amon_ra_consumeFX.Transform:SetScale(scale, scale, scale)
					    if i.SoundEmitter then
						i.SoundEmitter:PlaySound("dontstarve_DLC001/characters/wathgrithr/valhalla")
					    end
					    --Remove logo marker FX
					    if i._sdf_eye_of_amon_ra_logoFX then
						i._sdf_eye_of_amon_ra_logoFX:goAwayFn()
						i._sdf_eye_of_amon_ra_logoFX = nil
					    end
					    --Remove marker FX timer
					    if i._sdf_eye_of_amon_ra_marked_debufftask ~= nil then
						i._sdf_eye_of_amon_ra_marked_debufftask:Cancel()
						i._sdf_eye_of_amon_ra_marked_debufftask = nil
					    end
					    --Remove sparkle FX repeat
					    if i._sdf_eye_of_amon_ra_swirlFX_debufftask ~= nil then
						i._sdf_eye_of_amon_ra_swirlFX_debufftask:Cancel()
						i._sdf_eye_of_amon_ra_swirlFX_debufftask = nil
					    end
					end
				    end)
				end
			    end
			end
		    end
		end
	    end
	end
    end
end

local function IsValidVictim(victim)
    return victim ~= nil
	and not ((victim:HasTag("prey") and not victim:HasTag("hostile")) or
	    (victim:HasTag("smallcreature") and victim:HasTag("bird")) or
	    (victim:HasTag("smallcreature") and victim:HasTag("butterfly")) or
	    (victim:HasTag("smallcreature") and victim:HasTag("rabbit")) or
	    victim:HasTag("veggie") or
	    victim:HasTag("structure") or
	    victim:HasTag("wall") or
	    victim:HasTag("balloon") or
	    victim:HasTag("groundspike") or
	    victim:HasTag("smashable") or
	    victim:HasTag("companion"))
	    and victim.components.health ~= nil and victim.components.combat ~= nil
end


local function gatherSouls(inst, victim, soulRandom, soulValue)
    local soulTotal = 0
    local soulBonus = 0

    --Soul Amount
    if soulRandom > 0 then
	local soulRng = math.random()
	if soulRng >= soulRandom then --Max Souls
	    soulTotal = soulValue
	else
	    soulTotal = (soulValue - math.ceil(soulValue * TUNING.SDF_SOUL_VALUE_ADJUSTMENT))
	end
    else
	soulTotal = soulValue
    end

    --Skill Tree Culling
    if inst.components.skilltreeupdater:IsActivated("sdf_undeath_4") then
	local soulBonusRng = math.random()
	if soulBonusRng >= (1 - TUNING.SDF_SKILLSET_UNDEATH_CULLING) then
	    soulBonus = math.ceil(soulTotal * TUNING.SDF_SKILLSET_UNDEATH_CULLING_BONUS)
	end
    end

    --Soul FX
    local x,_,z = victim.Transform:GetWorldPosition()
    if victim:HasTag("epic") then
	SpawnPrefab("winters_feast_food_depleted").Transform:SetPosition(x,_,z) --Epic
    else
	SpawnPrefab("winters_feast_depletefood").Transform:SetPosition(x,_,z) --Norm, pvp, critter
    end

    --Skill Tree Culling FX
    if soulBonus > 0 then
	inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_haunt")
    else
	inst.SoundEmitter:PlaySound("dontstarve/characters/wortox/soul/spawn", nil, .5)
    end

    --Gather Souls	
    inst.components.sdf_souls:DoDelta(soulTotal + soulBonus) --Max Souls
end

local function gatherEnergyVial(target, amount)
    for i = 1, amount do
        target.components.lootdropper:AddChanceLoot("sdf_energyvial", 1)
    end
end

local function checkAnubisStone(inst)
    local bodyItem = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
    if bodyItem and bodyItem.prefab == "sdf_anubis_stone" then
	return true
    elseif inst.components.inventory:FindItem(function(item) return (item.prefab == "sdf_anubis_stone")end) then
	return true
    end
    return false
end

local function onKilled(inst, data)
    local victim = data.victim
    if data ~= nil and victim ~= nil then
	if IsValidVictim(victim) then

	    local soulPercent = inst.components.sdf_souls:GetPercent()

	    --Gathering Souls
	    if soulPercent < 1 then
		if victim:HasTag("epic") then

		    --Gathering soul Randomness
		    if not victim:HasTag("soulless") then
			gatherSouls(inst, victim, TUNING.SDF_SOUL_VALUE_EPIC_CHANCE, TUNING.SDF_SOUL_VALUE_EPIC) --Epic Kills
		    end

		    --Skill Tree Embalming And Rites
		    if victim.components.lootdropper ~= nil then

			--Skill Tree Embalming
			if inst.components.skilltreeupdater:IsActivated("sdf_undeath_2") then
			    gatherEnergyVial(victim, TUNING.SDF_SKILLSET_UNDEATH_EMBALMING_EPIC_2)
			elseif inst.components.skilltreeupdater:IsActivated("sdf_undeath_1") then
			    gatherEnergyVial(victim, TUNING.SDF_SKILLSET_UNDEATH_EMBALMING_EPIC_1)
			end

			--Skill Tree Rites
			if checkAnubisStone(inst) == true then
			    if inst.components.skilltreeupdater:IsActivated("sdf_undeath_6") then
				victim.components.lootdropper:AddChanceLoot("sdf_soul_helmet", TUNING.SDF_SKILLSET_UNDEATH_RITES_EPIC_2)
			    elseif inst.components.skilltreeupdater:IsActivated("sdf_undeath_5") then
				victim.components.lootdropper:AddChanceLoot("sdf_soul_helmet", TUNING.SDF_SKILLSET_UNDEATH_RITES_EPIC_1)
			    else
				victim.components.lootdropper:AddChanceLoot("sdf_soul_helmet", TUNING.SDF_ANUBIS_STONE_SOUL_HELMET_CHANCE_EPIC)
			    end
			else
			    if inst.components.skilltreeupdater:IsActivated("sdf_undeath_6") then
				victim.components.lootdropper:AddChanceLoot("sdf_soul_helmet", TUNING.SDF_SKILLSET_UNDEATH_RITES_EPIC_2)
			    elseif inst.components.skilltreeupdater:IsActivated("sdf_undeath_5") then
				victim.components.lootdropper:AddChanceLoot("sdf_soul_helmet", TUNING.SDF_SKILLSET_UNDEATH_RITES_EPIC_1)
			    end
			end
		    end
		elseif victim:HasTag("player") then
		    if not victim:HasTag("soulless") then
			gatherSouls(inst, victim, 0, TUNING.SDF_SOUL_VALUE_PVP) --Pvp Kills
		    end
		elseif victim:HasTag("smallcreature") and not victim:HasTag("hostile") then
		    if not victim:HasTag("soulless") then
			gatherSouls(inst, victim, 0, TUNING.SDF_SOUL_VALUE_CRITTER) --Critter Kills
		    end

		    --Skill Tree Embalming And Rites
		    if victim.components.lootdropper ~= nil then
			--Skill Tree Embalming
			if inst.components.skilltreeupdater:IsActivated("sdf_undeath_2") then
			    victim.components.lootdropper:AddChanceLoot("sdf_energyvial", TUNING.SDF_SKILLSET_UNDEATH_EMBALMING_2)
			elseif inst.components.skilltreeupdater:IsActivated("sdf_undeath_1") then
			    victim.components.lootdropper:AddChanceLoot("sdf_energyvial", TUNING.SDF_SKILLSET_UNDEATH_EMBALMING_1)
			end

			--Skill Tree Rites
			if checkAnubisStone(inst) == true then
			    if inst.components.skilltreeupdater:IsActivated("sdf_undeath_7") then
				victim.components.lootdropper:AddChanceLoot("sdf_soul_helmet", TUNING.SDF_SKILLSET_UNDEATH_RITES_2 + TUNING.SDF_ANUBIS_STONE_SOUL_HELMET_CHANCE)
			    else
				victim.components.lootdropper:AddChanceLoot("sdf_soul_helmet", TUNING.SDF_ANUBIS_STONE_SOUL_HELMET_CHANCE)
			    end
			elseif inst.components.skilltreeupdater:IsActivated("sdf_undeath_6") then
			    victim.components.lootdropper:AddChanceLoot("sdf_soul_helmet", TUNING.SDF_SKILLSET_UNDEATH_RITES_2)
			elseif inst.components.skilltreeupdater:IsActivated("sdf_undeath_5") then
			    victim.components.lootdropper:AddChanceLoot("sdf_soul_helmet", TUNING.SDF_SKILLSET_UNDEATH_RITES_1)
			end
		    end
		else
		    --Gathering soul Randomness
		    if not victim:HasTag("soulless") then
			gatherSouls(inst, victim, TUNING.SDF_SOUL_VALUE_CHANCE, TUNING.SDF_SOUL_VALUE) --Normal Kills
		    end
			
		    --Skill Tree Embalming And Rites
		    if victim.components.lootdropper ~= nil then

			--Skill Tree Embalming
			if inst.components.skilltreeupdater:IsActivated("sdf_undeath_2") then
			    victim.components.lootdropper:AddChanceLoot("sdf_energyvial", TUNING.SDF_SKILLSET_UNDEATH_EMBALMING_2)
			elseif inst.components.skilltreeupdater:IsActivated("sdf_undeath_1") then
			    victim.components.lootdropper:AddChanceLoot("sdf_energyvial", TUNING.SDF_SKILLSET_UNDEATH_EMBALMING_1)
			end

			--Skill Tree Rites
			if checkAnubisStone(inst) == true then
			    if inst.components.skilltreeupdater:IsActivated("sdf_undeath_7") then
				victim.components.lootdropper:AddChanceLoot("sdf_soul_helmet", TUNING.SDF_SKILLSET_UNDEATH_RITES_2 + TUNING.SDF_ANUBIS_STONE_SOUL_HELMET_CHANCE)
			    else
				victim.components.lootdropper:AddChanceLoot("sdf_soul_helmet", TUNING.SDF_ANUBIS_STONE_SOUL_HELMET_CHANCE)
			    end
			elseif inst.components.skilltreeupdater:IsActivated("sdf_undeath_6") then
			    victim.components.lootdropper:AddChanceLoot("sdf_soul_helmet", TUNING.SDF_SKILLSET_UNDEATH_RITES_2)
			elseif inst.components.skilltreeupdater:IsActivated("sdf_undeath_5") then
			    victim.components.lootdropper:AddChanceLoot("sdf_soul_helmet", TUNING.SDF_SKILLSET_UNDEATH_RITES_1)
			end
		    end
		end

	    --Full on souls
	    else
		if victim:HasTag("epic") then

		    --Skill Tree Embalming And Rites
		    if victim.components.lootdropper ~= nil then
			--Skill Tree Embalming
			if inst.components.skilltreeupdater:IsActivated("sdf_undeath_2") then
			    gatherEnergyVial(victim, TUNING.SDF_SKILLSET_UNDEATH_EMBALMING_EPIC_2)
			elseif inst.components.skilltreeupdater:IsActivated("sdf_undeath_1") then
			    gatherEnergyVial(victim, TUNING.SDF_SKILLSET_UNDEATH_EMBALMING_EPIC_1)
			end

			--Skill Tree Rites
			if checkAnubisStone(inst) == true then
			    if inst.components.skilltreeupdater:IsActivated("sdf_undeath_6") then
				victim.components.lootdropper:AddChanceLoot("sdf_soul_helmet", TUNING.SDF_SKILLSET_UNDEATH_RITES_EPIC_2)
			    elseif inst.components.skilltreeupdater:IsActivated("sdf_undeath_5") then
				victim.components.lootdropper:AddChanceLoot("sdf_soul_helmet", TUNING.SDF_SKILLSET_UNDEATH_RITES_EPIC_1)
			    else
				victim.components.lootdropper:AddChanceLoot("sdf_soul_helmet", TUNING.SDF_ANUBIS_STONE_SOUL_HELMET_CHANCE_EPIC)
			    end
			else
			    if inst.components.skilltreeupdater:IsActivated("sdf_undeath_6") then
				victim.components.lootdropper:AddChanceLoot("sdf_soul_helmet", TUNING.SDF_SKILLSET_UNDEATH_RITES_EPIC_2)
			    elseif inst.components.skilltreeupdater:IsActivated("sdf_undeath_5") then
				victim.components.lootdropper:AddChanceLoot("sdf_soul_helmet", TUNING.SDF_SKILLSET_UNDEATH_RITES_EPIC_1)
			    end
			end
		    end
		elseif victim:HasTag("smallcreature") and not victim:HasTag("hostile") then

		    --Skill Tree Embalming And Rites
		    if victim.components.lootdropper ~= nil then
			--Skill Tree Embalming
			if inst.components.skilltreeupdater:IsActivated("sdf_undeath_2") then
			    victim.components.lootdropper:AddChanceLoot("sdf_energyvial", TUNING.SDF_SKILLSET_UNDEATH_EMBALMING_2)
			elseif inst.components.skilltreeupdater:IsActivated("sdf_undeath_1") then
			    victim.components.lootdropper:AddChanceLoot("sdf_energyvial", TUNING.SDF_SKILLSET_UNDEATH_EMBALMING_1)
			end

			--Skill Tree Rites
			if checkAnubisStone(inst) == true then
			    if inst.components.skilltreeupdater:IsActivated("sdf_undeath_7") then
				victim.components.lootdropper:AddChanceLoot("sdf_soul_helmet", TUNING.SDF_SKILLSET_UNDEATH_RITES_2 + TUNING.SDF_ANUBIS_STONE_SOUL_HELMET_CHANCE)
			    else
				victim.components.lootdropper:AddChanceLoot("sdf_soul_helmet", TUNING.SDF_ANUBIS_STONE_SOUL_HELMET_CHANCE)
			    end
			elseif inst.components.skilltreeupdater:IsActivated("sdf_undeath_6") then
			    victim.components.lootdropper:AddChanceLoot("sdf_soul_helmet", TUNING.SDF_SKILLSET_UNDEATH_RITES_2)
			elseif inst.components.skilltreeupdater:IsActivated("sdf_undeath_5") then
			    victim.components.lootdropper:AddChanceLoot("sdf_soul_helmet", TUNING.SDF_SKILLSET_UNDEATH_RITES_1)
			end
		    end
		else

		    --Skill Tree Embalming And Rites
		    if victim.components.lootdropper ~= nil then
			--Skill Tree Embalming
			if inst.components.skilltreeupdater:IsActivated("sdf_undeath_2") then
			    victim.components.lootdropper:AddChanceLoot("sdf_energyvial", (TUNING.SDF_SKILLSET_UNDEATH_EMBALMING_2 * TUNING.SDF_MAX_SOUL_BONUS))
			elseif inst.components.skilltreeupdater:IsActivated("sdf_undeath_1") then
			    victim.components.lootdropper:AddChanceLoot("sdf_energyvial", (TUNING.SDF_SKILLSET_UNDEATH_EMBALMING_1 * TUNING.SDF_MAX_SOUL_BONUS))
			end

			--Skill Tree Rites
			if checkAnubisStone(inst) == true then
			    if inst.components.skilltreeupdater:IsActivated("sdf_undeath_7") then
				victim.components.lootdropper:AddChanceLoot("sdf_soul_helmet", TUNING.SDF_SKILLSET_UNDEATH_RITES_2 + TUNING.SDF_ANUBIS_STONE_SOUL_HELMET_CHANCE)
			    else
				victim.components.lootdropper:AddChanceLoot("sdf_soul_helmet", TUNING.SDF_ANUBIS_STONE_SOUL_HELMET_CHANCE)
			    end
			elseif inst.components.skilltreeupdater:IsActivated("sdf_undeath_6") then
			    victim.components.lootdropper:AddChanceLoot("sdf_soul_helmet", (TUNING.SDF_SKILLSET_UNDEATH_RITES_2 * TUNING.SDF_MAX_SOUL_BONUS))
			elseif inst.components.skilltreeupdater:IsActivated("sdf_undeath_5") then
			    victim.components.lootdropper:AddChanceLoot("sdf_soul_helmet", (TUNING.SDF_SKILLSET_UNDEATH_RITES_1 * TUNING.SDF_MAX_SOUL_BONUS))
			end
		    end
		end
	    end

	    --Skill Tree Culling Sanity Kill
	    if inst.components.skilltreeupdater:IsActivated("sdf_undeath_4") then
		inst.components.sanity:DoDelta(TUNING.SDF_SKILLSET_UNDEATH_CULLING_SANITY_BONUS)
	    end

	    --Skill Tree Unlock Boss Kill
	    if victim.prefab == "eyeofterror" then
		trackattackers(inst,victim)
		for ID, data in pairs(victim.attackerUSERIDs) do
		    for i, player in ipairs(AllPlayers) do
			if player.userid == ID then 
			    SendRPCToClient(CLIENT_RPC.UpdateAccomplishment, player.userid, "sdf_eyeofterror_killed")
			    break
			end
		    end
		end
	    end
	    if victim.prefab == "twinofterror1" then
		trackattackers(inst,victim)
		for ID, data in pairs(victim.attackerUSERIDs) do
		    for i, player in ipairs(AllPlayers) do
			if player.userid == ID then 
			    SendRPCToClient(CLIENT_RPC.UpdateAccomplishment, player.userid, "sdf_twinofterror1_killed")
			    break
			end
		    end
		end
	    end
	    if victim.prefab == "twinofterror2" then
		trackattackers(inst,victim)
		for ID, data in pairs(victim.attackerUSERIDs) do
		    for i, player in ipairs(AllPlayers) do
			if player.userid == ID then 
			    SendRPCToClient(CLIENT_RPC.UpdateAccomplishment, player.userid, "sdf_twinofterror2_killed")
			    break
			end
		    end
		end
	    end

	    if victim.prefab == "deerclops" then
		trackattackers(inst,victim)
		for ID, data in pairs(victim.attackerUSERIDs) do
		    for i, player in ipairs(AllPlayers) do
			if player.userid == ID then 
			    SendRPCToClient(CLIENT_RPC.UpdateAccomplishment, player.userid, "sdf_deerclops_killed")
			    break
			end
		    end
		end
	    end
	    if victim.prefab == "mutateddeerclops" then
		trackattackers(inst,victim)
		for ID, data in pairs(victim.attackerUSERIDs) do
		    for i, player in ipairs(AllPlayers) do
			if player.userid == ID then 
			    SendRPCToClient(CLIENT_RPC.UpdateAccomplishment, player.userid, "sdf_mutateddeerclops_killed")
			    break
			end
		    end
		end
	    end

	    if (victim.prefab == "warg" or victim.prefab == "gingerbreadwarg" or victim.prefab == "claywarg") then
		trackattackers(inst,victim)
		for ID, data in pairs(victim.attackerUSERIDs) do
		    for i, player in ipairs(AllPlayers) do
			if player.userid == ID then 
			    SendRPCToClient(CLIENT_RPC.UpdateAccomplishment, player.userid, "sdf_warg_killed")
			    break
			end
		    end
		end
	    end
	    if victim.prefab == "mutatedwarg" then
		trackattackers(inst,victim)
		for ID, data in pairs(victim.attackerUSERIDs) do
		    for i, player in ipairs(AllPlayers) do
			if player.userid == ID then 
			    SendRPCToClient(CLIENT_RPC.UpdateAccomplishment, player.userid, "sdf_mutatedwarg_killed")
			    break
			end
		    end
		end
	    end

	    if victim.prefab == "bearger" then
		trackattackers(inst,victim)
		for ID, data in pairs(victim.attackerUSERIDs) do
		    for i, player in ipairs(AllPlayers) do
			if player.userid == ID then 
			    SendRPCToClient(CLIENT_RPC.UpdateAccomplishment, player.userid, "sdf_bearger_killed")
			    break
			end
		    end
		end
	    end
	    if victim.prefab == "mutatedbearger" then
		trackattackers(inst,victim)
		for ID, data in pairs(victim.attackerUSERIDs) do
		    for i, player in ipairs(AllPlayers) do
			if player.userid == ID then 
			    SendRPCToClient(CLIENT_RPC.UpdateAccomplishment, player.userid, "sdf_mutatedbearger_killed")
			    break
			end
		    end
		end
	    end
	    if victim.prefab == "daywalker2" then
		trackattackers(inst,victim)
		for ID, data in pairs(victim.attackerUSERIDs) do
		    for i, player in ipairs(AllPlayers) do
			if player.userid == ID then 
			    SendRPCToClient(CLIENT_RPC.UpdateAccomplishment, player.userid, "sdf_daywalker2_killed")
			    break
			end
		    end
		end
	    end
	end
    end
end

local function OnSoulsDelta(inst, data)
    local chaliceReady = inst.components.sdf_souls:GetChaliceReady()
    local soulPercent = inst.components.sdf_souls:GetPercent()
    if chaliceReady == false and soulPercent >= 1 then
	inst.components.sdf_souls:SetChaliceReady()
	inst.components.talker:Say(GetString(inst, "ANNOUNCE_SDF_CHALICE_COLLECT_READY"))
    end
end

local function OnHealthDelta(inst, data)
    if data.newpercent ~= nil then
	if data.newpercent < 0.02 and inst.components.health.minhealth > 0 then
  
	    --Create Iframe
	    if inst._fx == nil then
		--Update Death
		local lifebottle_holder = inst.components.sdf_lifebottle_holder:GetLifebottleHolder()
		if lifebottle_holder ~= nil then
		    inst.components.sdf_lifebottle_holder:UpdateLifebottleDeath(inst, lifebottle_holder)

		    --Create FX
		    local x,_,z=inst.Transform:GetWorldPosition()
		    inst._fx = SpawnPrefab("spider_heal_target_fx")
		    inst._fx.entity:SetParent(inst.entity)
		    inst._fx2 = SpawnPrefab("spider_heal_fx")
		    inst._fx2.Transform:SetPosition(x,_,z)
		    inst.SoundEmitter:PlaySound("dontstarve/common/together/moondial/water_movement")

		    --Take away Iframe
		    inst:DoTaskInTime(2,function()
			if inst._fx ~= nil then
			    inst._fx = nil
			end
			local lifebottle_holder = inst.components.sdf_lifebottle_holder:GetLifebottleHolder()
			if lifebottle_holder ~= nil then
			    inst.components.sdf_lifebottle_holder:ActivateLifebottle(inst, lifebottle_holder)
			end
		    end)
		end
	    end
    	end
    end
end

local function OnDeath(inst)
    local helmItem = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
    --Check for helm
    if helmItem then
	if helmItem.prefab == "sdf_helmet" then
	    helmItem.components.equippable:SetPreventUnequipping(false)
	    inst.components.inventory:DropItem(helmItem)
	    inst.components.inventory:GiveItem(helmItem)
	end
    end

    --[[local runeHolderItem = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.RUNE)
    --Check for rune holder
    if runeHolderItem then
	if runeHolderItem.prefab == "sdf_rune_holder" then
	    inst.components.inventory:DropItem(runeHolderItem)
	    inst.components.inventory:GiveItem(runeHolderItem)
	end
    end]]

    --Kills all Gallowmere Knights
    for follower,_ in pairs(inst.components.leader.followers) do
	if follower.prefab == "sdf_gallowmere_knight" then
	    follower.components.health:Kill()
        end
    end
end

local function OnBuildItem(inst, data)
    --Adds Book of Gallowmere Entries
    if data then
	--Skill Tree Insight
	if data.item.prefab == "sdf_book_of_gallowmere" and inst.components.skilltreeupdater:IsActivated("sdf_skull_4") then
	    data.item:CreateNewBookRestoredFn()
	elseif data.item.prefab == "sdf_book_of_gallowmere" and inst.components.sdf_jack_of_the_green_riddle_quest:CheckBookOfGallowmereRestored() == true then
	    data.item:CreateNewBookRestoredFn()
	elseif data.item.prefab == "sdf_book_of_gallowmere" then
	    data.item:CreateNewBookFn()
	end
    end
end

local function unequipCheck(inst, data)
    --Skill Tree Morten
    if inst.components.skilltreeupdater:IsActivated("sdf_skull_5") then
	local hand = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if hand then
	    if not hand.components.oceanfishingrod and not hand.components.container then
		--Remove any old mortens
		for follower,_ in pairs(inst.components.leader.followers) do
		    if follower.prefab == "sdf_morten" then
			follower:Remove()
		    end
		end
	    end
	else
	    --Remove any old mortens
	    for follower,_ in pairs(inst.components.leader.followers) do
		if follower.prefab == "sdf_morten" then
		    follower:Remove()
		end
	    end
	end
    end

    return
end

local function equipCheck(inst, data)
    if inst:HasTag("playerghost") then return end

    --Limits for Dragon Potion
    --[[local body = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.EXTRABODY1 or EQUIPSLOTS.EXTRABODY2 or EQUIPSLOTS.EXTRABODY3 or EQUIPSLOTS.BODY)

    if body then
	if body.prefab == "sdf_dragon_potion" then
	    local item = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) --data.item
	    if item then
		if item.prefab == "sdf_dragon_potion_dragonbreath" or item.prefab == "sdf_anubis_stone_necrotic_touch" then
		    return
		elseif data.eslot == EQUIPSLOTS.HANDS then
		    inst:DoTaskInTime(0.0, function()  --0.1 Might need adjusting
			inst.components.inventory:DropItem(item)
		    	inst.components.inventory:GiveItem(item)

		    	if data.eslot == EQUIPSLOTS.HANDS then inst.AnimState:ClearOverrideSymbol("swap_object") end

		    	--inst.components.talker:Say(GetString(inst, "ANNOUNCE_SDF_DRAGON_POTION_NO_EQUIP"))
		    end)
		end
	    end
	end
    end]]

    --Limits for Dans Helmet on fated arrow
    if TUNING.SDF_FATES_ARROW == true then
	local head = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
	if head then
	    if head.prefab == "sdf_helmet" then
		local item = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)--data.item
		if item.prefab == "sdf_helmet" then
		    return
		elseif data.eslot == EQUIPSLOTS.HEAD then
		    inst:DoTaskInTime(0.0, function()  --0.1 Might need adjusting
			inst.components.inventory:DropItem(item)
			inst.components.inventory:GiveItem(item)

			if data.eslot == EQUIPSLOTS.HEAD then inst.AnimState:ClearOverrideSymbol("headbase_hat") end

			--inst.components.talker:Say(GetString(inst, "ANNOUNCE_SDF_HELMET_NO_UNEQUIP"))
		    end)
		end
	    end
	end
    end

    --Limits for Dans Rune Holder
    --[[local runeHolder = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.RUNE)
    if runeHolder then
	if runeHolder.prefab == "sdf_rune_holder" then
	    local item = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.RUNE)
	    if item.prefab == "sdf_rune_holder" then
		return
	    elseif data.eslot == EQUIPSLOTS.RUNE then
		inst:DoTaskInTime(0.5, function()  --0.1 Might need adjusting
		    inst.components.inventory:DropItem(item)
		    inst.components.inventory:GiveItem(item)
		end)
	    end
	end
    end]]

    --Skill Tree Morten
    if inst.components.skilltreeupdater:IsActivated("sdf_skull_5") then
	local hand = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if hand then
	    if hand.components.oceanfishingrod and hand.components.container then
		mortenSetup(inst)
	    end
	end
    end
end

local function equipmentUpdateCheck(inst)
	if inst:HasTag("playerghost") then
	    return
	end

	local body = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.EXTRABODY1 or EQUIPSLOTS.EXTRABODY2 or EQUIPSLOTS.EXTRABODY3 or EQUIPSLOTS.BODY)
	local helmItem = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
	local handItem = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

	if body then
	    if body.prefab == "sdf_victorian_suit" then
		--Skill Tree Eye of Amon Ra
		if inst.components.skilltreeupdater:IsActivated("sdf_skull_1") then
		    inst:MakeVictorianSuitEye()
		else
		    inst:MakeVictorianSuit()
		end

		--Check for helm
		if helmItem then
		    if helmItem.prefab == "sdf_helmet" then
			helmItem.components.equippable.onequipfn(helmItem, inst)
		    end
		end

	    elseif body.prefab == "sdf_gold_armor" then
		--Skill Tree Eye of Amon Ra
		if inst.components.skilltreeupdater:IsActivated("sdf_skull_1") then
		    inst:MakeGoldArmorEye()
		else
		    inst:MakeGoldArmor()
		end

		--Sync up Super Armor
		local armor_superarmor = body.components.sdf_superarmor:GetCurrent()
		local sdf_superarmor = inst.components.sdf_superarmor:GetCurrent()
		if armor_superarmor ~= nil and sdf_superarmor ~= nil then
		    local syncSuperarmor = armor_superarmor - sdf_superarmor
		    inst.components.sdf_superarmor:DoDelta(syncSuperarmor, false, "sdf_gold_armor")
		end

		--Check for helm
		if helmItem then
		    if helmItem.prefab == "sdf_helmet" then
			helmItem.components.equippable.onequipfn(helmItem, inst)
		    end
		end
	    elseif body.prefab == "sdf_dragon_potion" then
		--Skill Tree Eye of Amon Ra
		if inst.components.skilltreeupdater:IsActivated("sdf_skull_1") then
		    inst:MakeDragonArmorEye()
		else
		    inst:MakeDragonArmor()
		end

		--Check for helm
		if helmItem then
		    if helmItem.prefab == "sdf_helmet" then
			helmItem.components.equippable.onequipfn(helmItem, inst)
		    end
		end
	    end
	else
	    --Skill Tree Eye of Amon Ra
	    if inst.components.skilltreeupdater:IsActivated("sdf_skull_1") then
		inst:MakeNormalArmorEye()
	    else
		inst:MakeNormalArmor()
	    end

	    --Removes super armor
	    local sdf_superarmor = inst.components.sdf_superarmor:GetCurrent()
	    if sdf_superarmor ~= nil or sdf_superarmor > 0 then
		inst.components.sdf_superarmor:DoDelta(-TUNING.SDF_SUPERARMOR_MAX, false, "sdf")
	    end

	    --Check for helm
	    if helmItem then
		if helmItem.prefab == "sdf_helmet" then
		    helmItem.components.equippable.onequipfn(helmItem, inst)
		end
	    end
	end
end

local function OnBecameGhost(inst, data)
    --Close Holder
    --inst:DoTaskInTime(0.1, function()
    --for k, v in pairs(inst.components.inventory.itemslots) do
	--if v and v.prefab == "sdf_rune_holder" then
	    --if v.components.container ~= nil then
		--v.components.container:Close(inst)
	   --end
	--end
    --end
    --end)
end

local function OnRespawnFromGhost(inst)
    --Auto equip dans helmet
    if TUNING.SDF_FATES_ARROW == true then
	inst:DoTaskInTime(5.5, function()
	    for k, v in pairs(inst.components.inventory.itemslots) do
		if v and v.prefab == "sdf_helmet" then
		    inst.components.inventory:Equip(v)
		end
	    end
	end)
    end

    inst:DoTaskInTime(5, function()
	equipmentUpdateCheck(inst)
    end)
end

--When loading
local function OnLoad(inst,data)
    inst:ListenForEvent("onhitother", OnHitOther)
    inst:ListenForEvent("killed", onKilled)
    inst:ListenForEvent("healthdelta", OnHealthDelta)
    inst:ListenForEvent("sdf_soulsdelta", OnSoulsDelta)
    inst:ListenForEvent("builditem", OnBuildItem)

    --update vender trade tags
    inst.components.sdf_chalice_id_lock:CreateTradeTags(inst)

    --checks book of gallowmere
    local book_of_gallowmere_Enabled = inst.components.sdf_jack_of_the_green_riddle_quest:CheckBookOfGallowmere()
    if book_of_gallowmere_Enabled == true then
	inst:AddTag("sdf_book_of_gallowmere_builder")
    end

    --checks hero of gallowmere
    local hero_Enabled = inst.components.sdf_chalice_id_lock:CheckHeroStatus()
    if hero_Enabled == true then
	inst:AddTag("sdf_hero")
    end

    --checks for rune finding
    local canGatherRunes = inst.components.sdf_rune_holder:CanGatherRunes()
    if canGatherRunes == true then
	local rune_chaos_enabled = inst.components.sdf_rune_holder:CheckRuneStatus("sdf_chaos_rune")
	if rune_chaos_enabled == false then
	    inst:AddTag("sdf_chaos_rock_engraft")
	end
	inst:ListenForEvent("working", onworked)
    end

    --Updates the Lifebottle UI and Activates Full lifebottle lives
    local lifebottle_holder = inst.components.sdf_lifebottle_holder:GetLifebottleHolder()
    if lifebottle_holder ~= nil then
	for i, v in ipairs(lifebottle_holder) do
	    if lifebottle_holder[i] == true then
		inst:AddTag("lifebottle_"..i.."_enabled")
	    end
	end

	--Activates Full lifebottle lives
	inst.components.sdf_lifebottle_holder:ActivateLifebottle(inst, lifebottle_holder)
    end

    --Auto equip dans helmet SkillTree Honor of Gallowmere
    if TUNING.SDF_FATES_ARROW == true then
	inst:DoTaskInTime(0.1, function()
	    --[[if not inst:HasTag("playerghost") then

		--auto equip Dans Helmet
		for k, v in pairs(inst.components.inventory.itemslots) do
		    if v and v.prefab == "sdf_helmet" then
			--create ID
			inst.components.sdf_key_item_inventory:SetKeyItem(v, inst)
			inst.components.inventory:Equip(v)
		    end
		end
	    end]]

	    --SkillTree Honor of Gallowmere
	    if inst.components.skilltreeupdater:IsActivated("sdf_undeath_10") then
	    else
		--SkillTree Honor of Gallowmere Track
		if TheGenericKV:GetKV("sdf_fates_arrow_survived") == "1" then
		else
		    inst:WatchWorldState("cycles", OnCyclesChanged)
		end
	    end
	end)
    end

    --remove Arm and auto equip Rune Holder
    inst:DoTaskInTime(0.2, function()
	for k, v in pairs(inst.components.inventory.itemslots) do
	    if v and v.prefab == "sdf_arm" then
		v:Remove()
	    end
	    if v and v.prefab == "sdf_rune_holder" then
		inst.components.inventory:Equip(v)
	    end
	end
    end)

    --updates worn armor
    inst:DoTaskInTime(0.1, function()
	equipmentUpdateCheck(inst)
    end)
end


local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

--spawning the character
local function OnLoadSpawn(inst,data)
    inst:ListenForEvent("onhitother", OnHitOther)
    inst:ListenForEvent("killed", onKilled)
    inst:ListenForEvent("healthdelta", OnHealthDelta)
    inst:ListenForEvent("sdf_soulsdelta", OnSoulsDelta)
    inst:ListenForEvent("builditem", OnBuildItem)

    --update vender trade tags
    inst.components.sdf_chalice_id_lock:CreateTradeTags(inst)

    --checks book of gallowmere
    local book_of_gallowmere_Enabled = inst.components.sdf_jack_of_the_green_riddle_quest:CheckBookOfGallowmere()
    if book_of_gallowmere_Enabled == true then
	inst:AddTag("sdf_book_of_gallowmere_builder")
    end

    --checks hero of gallowmere
    local hero_Enabled = inst.components.sdf_chalice_id_lock:CheckHeroStatus()
    if hero_Enabled == true then
	inst:AddTag("sdf_hero")
    end

    --checks for rune finding
    local canGatherRunes = inst.components.sdf_rune_holder:CanGatherRunes()
    if canGatherRunes == true then
	local rune_chaos_enabled = inst.components.sdf_rune_holder:CheckRuneStatus("sdf_chaos_rune")
	if rune_chaos_enabled == false then
	    inst:AddTag("sdf_chaos_rock_engraft")
	end
	inst:ListenForEvent("working", onworked)
    end

    --Updates the Lifebottle UI and Activates Full lifebottle lives
    local lifebottle_holder = inst.components.sdf_lifebottle_holder:GetLifebottleHolder()
    if lifebottle_holder ~= nil then
	for i, v in ipairs(lifebottle_holder) do
	    if lifebottle_holder[i] == true then
		inst:AddTag("lifebottle_"..i.."_enabled")
	    end
	end

	--Activates Full lifebottle lives
	inst.components.sdf_lifebottle_holder:ActivateLifebottle(inst, lifebottle_holder)
    end

    --SkillTree Honor of Gallowmere
    if TUNING.SDF_FATES_ARROW == true then
	inst:DoTaskInTime(0.1, function()

	    --SkillTree Honor of Gallowmere
	    if inst.components.skilltreeupdater:IsActivated("sdf_undeath_10") then
	    else
		--SkillTree Honor of Gallowmere Track
		if TheGenericKV:GetKV("sdf_fates_arrow_survived") == "1" then
		else
		    inst:WatchWorldState("cycles", OnCyclesChanged)
		end
	    end
	end)
    end

    --Auto equip dans helmet 
    --[[if not inst:HasTag("playerghost") then
	for k, v in pairs(inst.components.inventory.itemslots) do
	    if v and v.prefab == "sdf_helmet" then
		--create ID
		inst.components.sdf_key_item_inventory:SetKeyItem(v, inst)
		inst.components.inventory:Equip(v)
	    end
	end
    end]]

    --remove Arm and auto equip Rune Holder
    inst:DoTaskInTime(0.2, function()
	for k, v in pairs(inst.components.inventory.itemslots) do
	    if v and v.prefab == "sdf_arm" then
		v:Remove()
	    end
	    if v and v.prefab == "sdf_rune_holder" then
		inst.components.inventory:Equip(v)
	    end
	end
    end)

    --updates worn armor
    inst:DoTaskInTime(0.1, function()
	equipmentUpdateCheck(inst)
    end)

    --spawns information gargoyle
    inst:DoTaskInTime(0.3, function()
	local x, y, z = inst.Transform:GetWorldPosition()
	local spawn_radius = 4
	local offset = (inst.overridespawnlocation ~= nil and inst.overridespawnlocation(inst))
	    or (inst.wateronly and FindSwimmableOffset(Vector3(x, 0, z), math.random() * TWOPI, spawn_radius + inst:GetPhysicsRadius(0), 8, false, true, NoHoles))
	    or (FindWalkableOffset(Vector3(x, 0, z), math.random() * TWOPI, spawn_radius + inst:GetPhysicsRadius(0), 8, false, true, NoHoles, inst.allowwater, inst.allowboats))
	if not offset then
	    return
	end

	local nearby_gargoyle = TheSim:FindEntities(x, y, z, TUNING.SDF_INFORMATION_GARGOYLE_UNIQUE_SPAWN_DISTANCE, {"sdf_information_gargoyle_0"}, {})
	if #nearby_gargoyle == 0 then
	    local infoGargoyle = SpawnPrefab("sdf_information_gargoyle")
	    infoGargoyle.Transform:SetPosition(x + offset.x, 0, z + offset.z)
	end
    end)
end

local function OnInit(inst)
    inst.task = nil

    --Auto equip dans helmet 
    if not inst:HasTag("playerghost") then
	for k, v in pairs(inst.components.inventory.itemslots) do
	    if v and v.prefab == "sdf_helmet" then
		--create ID
		inst.components.sdf_key_item_inventory:SetKeyItem(v, inst)
		inst.components.inventory:Equip(v)
		return
	    end
	end
    end
end

local common_postinit = function(inst) 
	inst.MiniMapEntity:SetIcon("sdf.tex") 

	inst:AddTag("sdf")
	inst:AddTag("sdf_builder")

	--inst:AddTag("sdf_hero") --temp testing
	---------------------------------------------------------------------------
	if inst.components and inst.components.talker ~= nil then
		inst.components.talker.colour = Vector3(.9, .6, 0, 0)
	end

	--Armor Graphic
	inst.form = 1
	inst.form_net = net_byte(inst.GUID, "form", "form_dirty")
        inst:ListenForEvent("playeractivated", OnPlayerActivated)
        inst:ListenForEvent("playerdeactivated", OnPlayerDeactivated)

	--Skill Tree Daring Dash
	inst.stancemode = net_tinybyte(inst.GUID, "sdf.stancemode", "stancemodedirty")

	if not TheWorld.ismastersim then
	    inst:ListenForEvent("form_dirty", ChangeForm)
	end
end

local master_postinit = function(inst)
	inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

	inst.soundsname = "sdf"
	
	inst.components.health:SetMaxHealth(TUNING.SDF_HEALTH)
	inst.components.hunger:SetMax(TUNING.SDF_HUNGER)
	inst.components.sanity:SetMax(TUNING.SDF_SANITY)

	inst.components.hunger:SetRate(TUNING.WILSON_HUNGER_RATE*1)
	inst.components.sanity.night_drain_mult = TUNING.SDF_SANITY_NIGHT_DRAIN_MULT
	inst.components.sanity.neg_aura_mult = TUNING.SDF_SANITY_NEG_AURA_MULT
	inst.components.sanity:AddSanityAuraImmunity("ghost")
	inst.components.sanity:SetPlayerGhostImmunity(true)

	inst.components.combat:SetDefaultDamage(TUNING.SDF_DAMAGE_UNARMED)
	inst.components.combat.damagemultiplier = 1

	inst.components.foodaffinity:AddPrefabAffinity("pumpkincookie", TUNING.AFFINITY_15_CALORIES_MED)
	inst.components.foodaffinity:AddPrefabAffinity("pumpkinpie", TUNING.AFFINITY_15_CALORIES_MED)

	--Chalice of Souls 
	inst:AddComponent("sdf_chalice_counter")
	inst.components.sdf_chalice_counter:SetUsedChaliceCount(0)
	inst.components.sdf_chalice_counter:SetCollectedChaliceCount(0)

	--Key Item Inventory
	inst:AddComponent("sdf_key_item_inventory")

	--Jack of the Green Quest
	inst:AddComponent("sdf_jack_of_the_green_riddle_quest")

	--King Peregrin Quest
	inst:AddComponent("sdf_king_peregrin_quest")

	--Anubis Stone Quest
	inst:AddComponent("sdf_anubis_stone_quest")

	--Skill Tree Daring Dash
        inst.IsStanceDefend  = IsStanceDefend

        inst:AddComponent("tackler")
        inst.components.tackler:SetOnStartTackleFn(OnTackleStart)
        inst.components.tackler:SetDistance(.5)
        inst.components.tackler:SetRadius(.75)
        inst.components.tackler:SetStructureDamageMultiplier(2)
        inst.components.tackler:AddWorkAction(ACTIONS.CHOP, TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_WORK_CHOP)
        inst.components.tackler:AddWorkAction(ACTIONS.MINE, TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_WORK_MINE)
        inst.components.tackler:AddWorkAction(ACTIONS.HAMMER, TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_WORK_HAMMER)
        inst.components.tackler:SetOnCollideFn(OnTackleCollide)
        inst.components.tackler:SetOnTrampleFn(OnTackleTrample)
        inst.components.tackler:SetEdgeDistance(5)
	inst.components.tackler.CheckCollision = function(self,ignores)
	    OnTackleCheck(self,ignores)
	end

	inst.MakeNormalArmor = function() ChangeForm(inst, 1) end
	inst.MakeVictorianSuit = function() ChangeForm(inst, 2) end
	inst.MakeGoldArmor = function() ChangeForm(inst, 3) end
	inst.MakeDragonArmor = function() ChangeForm(inst, 4) end
	inst.MakeNormalHelmet = function() ChangeForm(inst, 5) end
	inst.MakeVictorianHelmet = function() ChangeForm(inst, 6) end
	inst.MakeGoldHelmet = function() ChangeForm(inst, 7) end
	inst.MakeDragonHelmet = function() ChangeForm(inst, 8) end
	inst.MakeNormalArmorEye = function() ChangeForm(inst, 9) end
	inst.MakeVictorianSuitEye = function() ChangeForm(inst, 10) end
	inst.MakeGoldArmorEye = function() ChangeForm(inst, 11) end
	inst.MakeDragonArmorEye = function() ChangeForm(inst, 12) end
	inst.MakeNormalHelmetEye = function() ChangeForm(inst, 13) end
	inst.MakeVictorianHelmetEye = function() ChangeForm(inst, 14) end
	inst.MakeGoldHelmetEye = function() ChangeForm(inst, 15) end
	inst.MakeDragonHelmetEye = function() ChangeForm(inst, 16) end

	inst.MakeMortenFn = function() mortenSetup(inst) end

	inst.SkilltreeDaringDashEnableFn = function() onStanceDefend(inst) end
	inst.SkilltreeDaringDashDisableFn = function() onStanceNormal(inst) end
	inst.SkilltreeDaringDashRemoveFn = function() removeDaringDashStatus(inst) end
	inst.SkilltreeEyeOfAmonRaUpdateFn = function() equipmentUpdateCheck(inst) end


	inst:ListenForEvent("equip", equipCheck)
	inst:ListenForEvent("unequip", unequipCheck)
	inst:ListenForEvent("death", OnDeath)
	inst:ListenForEvent("respawnfromghost", OnRespawnFromGhost)
	inst:ListenForEvent("ms_respawnedfromghost", OnRespawnFromGhost)

	inst.task = inst:DoTaskInTime(0, OnInit)

	inst.OnLoad = OnLoad
	--inst.OnSave = OnSave
	inst.OnNewSpawn = OnLoadSpawn
	--inst.OnDespawn = OnSave

	return inst
end

return MakePlayerCharacter("sdf", prefabs, assets, common_postinit, master_postinit, prefabs)