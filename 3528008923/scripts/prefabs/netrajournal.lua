local assets =
{
	Asset("ANIM", "anim/netrajournal.zip"),
	
	Asset("ANIM", "anim/spell_icons_netra.zip"),

	Asset("ATLAS", "images/spell_icons.xml"),
	Asset("IMAGE", "images/spell_icons.tex"),
	
	Asset("ATLAS", "images/inventoryimages/netrajournal.xml"),
    Asset("IMAGE", "images/inventoryimages/netrajournal.tex"),	
}

local prefabs =
{
	"shadow_pillar_spell",
	"reticuleaoe",
	"reticuleaoeping",
	"reticuleaoecctarget",

	"shadow_trap",
	"reticuleaoe_1_6",
	"reticuleaoeping_1_6",
	"reticuleaoesummontarget_1",

	"shadowworker",
	"shadowprotector",
	"reticuleaoe_1d2_12",
	"reticuleaoeping_1d2_12",
	"reticuleaoesummontarget_1d2",
}

local IDLE_SOUND_VOLUME = .5

--------------------------------------------------------------------------

local function SpellCost(pct)
	return pct * TUNING.LARGE_FUEL * -4
end

local function shadowhelmetSpellFn(inst, doer, pos)
	
	if inst.components.fueled:GetPercent() < .5 then
		return false
	end
	
	local item = SpawnPrefab("mevileyes_inner_head")
	doer.components.inventory:GiveItem(item)
	
	inst.components.fueled:DoDelta(SpellCost(TUNING.WAXWELLJOURNAL_SPELL_COST.SHADOW_WORKER*10), doer)
	--doer.components.sanity:DoDelta(-TUNING.SANITY_MED)
			
	return true
end

local function shadowarmorSpellFn(inst, doer, pos)
	
	if inst.components.fueled:GetPercent() < .5 then
		return false
	end
	
	local item = SpawnPrefab("mevileyes_inner_armor")
	doer.components.inventory:GiveItem(item)
	
	inst.components.fueled:DoDelta(SpellCost(TUNING.WAXWELLJOURNAL_SPELL_COST.SHADOW_WORKER*10), doer)
	--doer.components.sanity:DoDelta(-TUNING.SANITY_MED)
			
	return true
end

local function PillarsSpellFn(inst, doer, pos)
	if inst.components.fueled:GetPercent() < .5 then
		return false
	elseif doer.components.spellbookcooldowns and doer.components.spellbookcooldowns:IsInCooldown("shadow_pillar") then
        return false
	end
	
	local spell = SpawnPrefab("shadow_pillar_spell")
	spell.caster = doer
	spell.item = inst
	local platform = TheWorld.Map:GetPlatformAtPoint(pos.x, pos.z)
	if platform ~= nil then
		spell.entity:SetParent(platform.entity)
		spell.Transform:SetPosition(platform.entity:WorldToLocalSpace(pos:Get()))
	else
		spell.Transform:SetPosition(pos:Get())
	end
	inst.components.fueled:DoDelta(SpellCost(TUNING.WAXWELLJOURNAL_SPELL_COST.SHADOW_WORKER*10), doer)
	doer.components.sanity:DoDelta(-TUNING.SANITY_MED)
	
	if doer.components.spellbookcooldowns then
			doer.components.spellbookcooldowns:RestartSpellCooldown("shadow_pillar", 20)
	end
	return true
end

local function TrapSpellFn(inst, doer, pos)
	
	if inst.components.fueled:GetPercent() < .5 then
		return false
	elseif doer.components.spellbookcooldowns and doer.components.spellbookcooldowns:IsInCooldown("trap_floor") then
        return false	
	end
	
	local trap = SpawnPrefab("book_web_ground")
	trap.AnimState:SetMultColour(0, 0, 0, 1)
	trap.Transform:SetPosition(pos:Get())
	if TheWorld.Map:GetPlatformAtPoint(pos.x, pos.z) ~= nil then
		trap:RemoveTag("ignorewalkableplatforms")
	end
	inst.components.fueled:DoDelta(SpellCost(TUNING.WAXWELLJOURNAL_SPELL_COST.SHADOW_WORKER*10), doer)
	doer.components.sanity:DoDelta(-TUNING.SANITY_MED)
	
	if doer.components.spellbookcooldowns then
			doer.components.spellbookcooldowns:RestartSpellCooldown("trap_floor", 70)
	end
		
	return true
end

local function EndLunarFire(fx, doer)
	if doer.components.channelcaster then
		doer.components.channelcaster:StopChanneling()
	end
end

local function TryLunarFire(inst, doer, pos)
    if doer.components.channelcaster and
		not doer.components.channelcaster:IsChanneling()
	then
		local fx = SpawnPrefab("blackflamethrower_fx")		
		fx.entity:SetParent(doer.entity)
		fx:SetFlamethrowerAttacker(doer)

		local endtask = fx:DoTaskInTime(TUNING.WILLOW_LUNAR_FIRE_TIME, EndLunarFire, doer)

		fx:ListenForEvent("stopchannelcast", function()
			if fx then
				endtask:Cancel()
				fx:KillFX()
				fx = nil
			end
		end, doer)

		if doer.components.spellbookcooldowns then
			doer.components.spellbookcooldowns:RestartSpellCooldown("lunar_fire", 10)
		end
		
		if doer.components.channelcaster:StartChanneling() then
			return true
		end

		--channelcast fail
		fx:Remove()
    end
    return false
end

local function LunarFireSpellFn(inst, doer, pos)
	if inst.components.fueled:GetPercent() < 1 then
		return false
	elseif doer.components.spellbookcooldowns and doer.components.spellbookcooldowns:IsInCooldown("lunar_fire") then
        return false
	elseif doer.components.rider and doer.components.rider:IsRiding() then
        return false    
    elseif TryLunarFire(inst, doer, pos) then		
        inst.components.fueled:DoDelta(SpellCost(TUNING.WAXWELLJOURNAL_SPELL_COST.SHADOW_WORKER*20), doer)
		doer.components.sanity:DoDelta(-TUNING.SANITY_MED)
		return true
    end
    return false
end
------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
local function single_reticule_mouse_target_function(inst, mousepos)
    if mousepos == nil then
        return nil
    end
    local inventoryitem = inst.replica.inventoryitem
    local owner = inventoryitem:IsHeldBy(ThePlayer) and ThePlayer
    if owner then
        local pos = Vector3(owner.Transform:GetWorldPosition())
        return pos
    end
end

local function single_reticule_target_function(inst)
    if ThePlayer and ThePlayer.components.playercontroller ~= nil and ThePlayer.components.playercontroller.isclientcontrollerattached then
        local inventoryitem = inst.replica.inventoryitem
        local owner = inventoryitem and inventoryitem:IsGrandOwner(ThePlayer) and ThePlayer
        if owner then
            local pos = Vector3(owner.Transform:GetWorldPosition())
            return pos
        end
    end
end

local function single_reticule_update_position_function(inst, pos, reticule, ease, smoothing, dt)

    local inventoryitem = inst.replica.inventoryitem
    local owner = inventoryitem and inventoryitem:IsGrandOwner(ThePlayer) and ThePlayer

    if owner then
        reticule.Transform:SetPosition(Vector3(owner.Transform:GetWorldPosition()):Get())
        reticule.Transform:SetRotation(0)
    end
end
------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
local function line_reticule_target_function(inst)
    if ThePlayer and ThePlayer.components.playercontroller ~= nil and ThePlayer.components.playercontroller.isclientcontrollerattached then
        local inventoryitem = inst.replica.inventoryitem
        local owner =  inventoryitem and inventoryitem:IsGrandOwner(ThePlayer) and ThePlayer
        if owner then
			return Vector3(ThePlayer.entity:LocalToWorldSpace(5, 0, 0))
        end
    end
end

local function line_reticule_mouse_target_function(inst, mousepos)
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

local function line_reticule_update_position_function(inst, pos, reticule, ease, smoothing, dt)
    local inventoryitem = inst.replica.inventoryitem
	if inventoryitem and inventoryitem:IsHeldBy(ThePlayer) then
		reticule.Transform:SetPosition(ThePlayer.Transform:GetWorldPosition())
		local rot1 = reticule:GetAngleToPoint(inst.components.reticule.targetpos)
		if ease and dt then
			local rot = reticule.Transform:GetRotation()
			local drot = ReduceAngle(rot1 - rot)
			rot1 = Lerp(rot, rot + drot, dt * smoothing)
		end
		reticule.Transform:SetRotation(rot1)
    end
end
------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
local function NotBlocked(pt)
	return not TheWorld.Map:IsGroundTargetBlocked(pt)
end

local function FindSpawnPoints(doer, pos, num, radius)
	local ret = {}
	local theta, delta, attempts
	if num > 1 then
		delta = TWOPI / num
		attempts = 3
		theta = doer:GetAngleToPoint(pos) * DEGREES
		if num == 2 then
			theta = theta + PI * (math.random() < .5 and .5 or -.5)
		else
			theta = theta + PI
			if math.random() < .5 then
				delta = -delta
			end
		end
	else
		theta = 0
		delta = 0
		attempts = 1
		radius = 0
	end
	for i = 1, num do
		local offset = FindWalkableOffset(pos, theta, radius, attempts, false, false, NotBlocked, true, true)
		if offset ~= nil then
			table.insert(ret, Vector3(pos.x + offset.x, 0, pos.z + offset.z))
		end
		theta = theta + delta
	end
	return ret
end

local NUM_MINIONS_PER_SPAWN = 1
local function TrySpawnMinions(prefab, doer, pos)
	if doer.components.petleash ~= nil then
		local spawnpts = FindSpawnPoints(doer, pos, NUM_MINIONS_PER_SPAWN, 1)
		if #spawnpts > 0 then
			for i, v in ipairs(spawnpts) do
				local pet = doer.components.petleash:SpawnPetAt(v.x, 0, v.z, prefab)
				if pet ~= nil then
					if pet.SaveSpawnPoint ~= nil then
						pet:SaveSpawnPoint()
					end
					if #spawnpts > 1 and i <= 3 then
						--restart "spawn" state with specified time multiplier
						pet.sg.statemem.spawn = true
						pet.sg:GoToState("spawn",
							(i == 1 and 1) or
							(i == 2 and .8) or
							.87 + math.random() * .06
						)
					end
				end
			end
			return true
		end
	end
	return false
end

local function _CheckMaxSanity(sanity, minionprefab)
	return sanity ~= nil and sanity:GetPenaltyPercent() + (TUNING.SHADOWWAXWELL_SANITY_PENALTY[string.upper(minionprefab)] or 0) * NUM_MINIONS_PER_SPAWN <= TUNING.MAXIMUM_SANITY_PENALTY
end

local function CheckMaxSanity(doer, minionprefab)
	return _CheckMaxSanity(doer.components.sanity, minionprefab)
end

local function ShouldRepeatCastWorker(inst, doer)
	return _CheckMaxSanity(doer.replica.sanity, "shadowworker")
end

local function ShouldRepeatCastProtector(inst, doer)
	return _CheckMaxSanity(doer.replica.sanity, "shadowprotector")
end

local function WorkerSpellFn(inst, doer, pos)
	if inst.components.fueled:IsEmpty() then
		return false 
	elseif not CheckMaxSanity(doer, "shadowworker") then
		return false
	elseif TrySpawnMinions("shadowworker", doer, pos) then
		inst.components.fueled:DoDelta(SpellCost(TUNING.WAXWELLJOURNAL_SPELL_COST.SHADOW_WORKER), doer)
		return true
	end
	return false
end

local function ProtectorSpellFn(inst, doer, pos)
	if inst.components.fueled:IsEmpty() then
		return false
	elseif not CheckMaxSanity(doer, "shadowprotector") then
		return false
	elseif TrySpawnMinions("shadowprotector", doer, pos) then
		inst.components.fueled:DoDelta(SpellCost(TUNING.WAXWELLJOURNAL_SPELL_COST.SHADOW_PROTECTOR*2), doer)
		return true
	end
	return false
end

local function ReticuleTargetAllowWaterFn()
	local player = ThePlayer
	local ground = TheWorld.Map
	local pos = Vector3()
	--Cast range is 8, leave room for error
	--4 is the aoe range
	for r = 7, 0, -.25 do
		pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
		if ground:IsPassableAtPoint(pos.x, 0, pos.z, true) and not ground:IsGroundTargetBlocked(pos) then
			return pos
		end
	end
	return pos
end

local function StartAOETargeting(inst)
	local playercontroller = ThePlayer.components.playercontroller
	if playercontroller ~= nil then
		playercontroller:StartAOETargetingUsing(inst)
	end
end

local ICON_SCALE = .6
local ICON_RADIUS = 50
local SPELLBOOK_RADIUS = 120
local SPELLBOOK_FOCUS_RADIUS = SPELLBOOK_RADIUS + 2
local SPELLS =
{
	{
        label = "Shadow Helmet".." (Cost:50)",
        onselect = function(inst)
            inst.components.spellbook:SetSpellName("shadowhelmet")
			inst.components.spellbook:SetSpellAction(nil)
            inst.components.aoetargeting:SetDeployRadius(0)
            inst.components.aoetargeting:SetShouldRepeatCastFn(nil)
            inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoefiretarget_1"
            inst.components.aoetargeting.reticule.pingprefab = "reticuleaoefiretarget_1ping"

            inst.components.aoetargeting.reticule.mousetargetfn = single_reticule_mouse_target_function
            inst.components.aoetargeting.reticule.targetfn = single_reticule_target_function
            inst.components.aoetargeting.reticule.updatepositionfn = single_reticule_update_position_function

            if TheWorld.ismastersim then
				inst.components.aoetargeting:SetTargetFX(nil)
                inst.components.aoespell:SetSpellFn(shadowhelmetSpellFn)
                inst.components.spellbook:SetSpellFn(nil)
            end
        end,
        execute = StartAOETargeting,
		bank = "spell_icons_netra",
		build = "spell_icons_netra",
		anims =
		{
			idle = { anim = "skill_3" },
			focus = { anim = "skill_3_focus", loop = true },
			down = { anim = "skill_3_pressed" },
			disabled = { anim = "skill_3" },
			--cooldown = { anim = "skill_0_cooldown" },
		},
       widget_scale = ICON_SCALE,
    },
	
	{
		label = STRINGS.SPELLS.SHADOW_WORKER.." (Cost:5)",
		onselect = function(inst)
			inst.components.spellbook:SetSpellName(STRINGS.SPELLS.SHADOW_WORKER)
			inst.components.spellbook:SetSpellAction(nil)
			inst.components.aoetargeting:SetDeployRadius(0)
			inst.components.aoetargeting:SetShouldRepeatCastFn(ShouldRepeatCastWorker)
			inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoe_1d2_12"
			inst.components.aoetargeting.reticule.pingprefab = "reticuleaoeping_1d2_12"
			
			inst.components.aoetargeting.reticule.mousetargetfn = nil
            inst.components.aoetargeting.reticule.targetfn = ReticuleTargetAllowWaterFn
            inst.components.aoetargeting.reticule.updatepositionfn = nil
			
			if TheWorld.ismastersim then
				inst.components.aoetargeting:SetTargetFX("reticuleaoesummontarget_1d2")
				inst.components.aoespell:SetSpellFn(WorkerSpellFn)
				inst.components.spellbook:SetSpellFn(nil)
			end
		end,
		execute = StartAOETargeting,
		bank = "spell_icons_netra",
		build = "spell_icons_netra",
		anims =
		{
			idle = { anim = "skill_1" },
			focus = { anim = "skill_1_focus", loop = true },
			down = { anim = "skill_1_pressed" },
			--disabled = { anim = "skill_1" },
			--cooldown = { anim = "skill_0_cooldown" },
		},
        widget_scale = ICON_SCALE,
	},
	
	{
		label = STRINGS.SPELLS.SHADOW_PROTECTOR.." (Cost:10)",
		onselect = function(inst)
			inst.components.spellbook:SetSpellName(STRINGS.SPELLS.SHADOW_PROTECTOR)
			inst.components.spellbook:SetSpellAction(nil)
			inst.components.aoetargeting:SetDeployRadius(0)
			inst.components.aoetargeting:SetShouldRepeatCastFn(ShouldRepeatCastProtector)
			inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoe_1d2_12"
			inst.components.aoetargeting.reticule.pingprefab = "reticuleaoeping_1d2_12"
						
			inst.components.aoetargeting.reticule.mousetargetfn = nil
            inst.components.aoetargeting.reticule.targetfn = ReticuleTargetAllowWaterFn
            inst.components.aoetargeting.reticule.updatepositionfn = nil
			
			if TheWorld.ismastersim then
				inst.components.aoetargeting:SetTargetFX("reticuleaoesummontarget_1d2")
				inst.components.aoespell:SetSpellFn(ProtectorSpellFn)
				inst.components.spellbook:SetSpellFn(nil)
			end
		end,
		execute = StartAOETargeting,
		bank = "spell_icons_netra",
		build = "spell_icons_netra",
		anims =
		{
			idle = { anim = "skill_2" },
			focus = { anim = "skill_2_focus", loop = true },
			down = { anim = "skill_2_pressed" },
			--disabled = { anim = "skill_2" },
			--cooldown = { anim = "skill_0_cooldown" },
		},
        widget_scale = ICON_SCALE,
	},
	
	
	{
        label = "Shadow Armor".." (Cost:50)",
        onselect = function(inst)
            inst.components.spellbook:SetSpellName("shadowarmor")
			inst.components.spellbook:SetSpellAction(nil)
            inst.components.aoetargeting:SetDeployRadius(0)
            inst.components.aoetargeting:SetShouldRepeatCastFn(nil)
            inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoefiretarget_1"
            inst.components.aoetargeting.reticule.pingprefab = "reticuleaoefiretarget_1ping"

            inst.components.aoetargeting.reticule.mousetargetfn = single_reticule_mouse_target_function
            inst.components.aoetargeting.reticule.targetfn = single_reticule_target_function
            inst.components.aoetargeting.reticule.updatepositionfn = single_reticule_update_position_function

            if TheWorld.ismastersim then
				inst.components.aoetargeting:SetTargetFX(nil)
                inst.components.aoespell:SetSpellFn(shadowarmorSpellFn)
                inst.components.spellbook:SetSpellFn(nil)
            end
        end,
        execute = StartAOETargeting,
		bank = "spell_icons_netra",
		build = "spell_icons_netra",
		anims =
		{
			idle = { anim = "skill_4" },
			focus = { anim = "skill_4_focus", loop = true },
			down = { anim = "skill_4_pressed" },
			disabled = { anim = "skill_4" },
			--cooldown = { anim = "skill_0_cooldown" },
		},
       widget_scale = ICON_SCALE,
    },	
	--{
	--	label = STRINGS.SPELLS.SHADOW_PILLARS,
	--	onselect = function(inst)
	--		inst.components.spellbook:SetSpellName(STRINGS.SPELLS.SHADOW_PILLARS)
	--		inst.components.spellbook:SetSpellAction(nil)
	--		inst.components.aoetargeting:SetDeployRadius(0)
	--		inst.components.aoetargeting:SetShouldRepeatCastFn(nil)
	--		inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoe"
	--		inst.components.aoetargeting.reticule.pingprefab = "reticuleaoeping"
	--		
	--		inst.components.aoetargeting.reticule.mousetargetfn = nil
    --        --inst.components.aoetargeting.reticule.targetfn = ReticuleTargetAllowWaterFn
    --        inst.components.aoetargeting.reticule.updatepositionfn = nil
	--		
	--		if TheWorld.ismastersim then
	--			inst.components.aoetargeting:SetTargetFX("reticuleaoecctarget")
	--			inst.components.aoespell:SetSpellFn(PillarsSpellFn)
	--			inst.components.spellbook:SetSpellFn(nil)
	--		end
	--	end,
	--	execute = StartAOETargeting,
	--	bank = "spell_icons_netra",
	--	build = "spell_icons_netra",
	--	anims =
	--	{
	--		idle = { anim = "skill_3" },
	--		focus = { anim = "skill_3_focus", loop = true },
	--		down = { anim = "skill_3_pressed" },
	--		disabled = { anim = "skill_3" },
	--		cooldown = { anim = "skill_0_cooldown" },
	--	},
    --    widget_scale = ICON_SCALE,
	--	checkcooldown = function(user)
	--		--client safe
	--		return user
	--			and user.components.spellbookcooldowns
	--			and user.components.spellbookcooldowns:GetSpellCooldownPercent("shadow_pillar")
	--			or nil
	--	end,
	--	cooldowncolor = { 0.65,0.65,0.65, 0.75 },
	--},
	
	{
		label = STRINGS.SPELLS.SHADOW_TRAP.." (Cost:50)",
		onselect = function(inst)
			inst.components.spellbook:SetSpellName(STRINGS.SPELLS.SHADOW_TRAP)
			inst.components.spellbook:SetSpellAction(nil)
			inst.components.aoetargeting:SetDeployRadius(1)
			inst.components.aoetargeting:SetShouldRepeatCastFn(nil)
			inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoe_1_6"
			inst.components.aoetargeting.reticule.pingprefab = "reticuleaoeping_1_6"
			
			inst.components.aoetargeting.reticule.mousetargetfn = nil
            --inst.components.aoetargeting.reticule.targetfn = ReticuleTargetAllowWaterFn
            inst.components.aoetargeting.reticule.updatepositionfn = nil
			
			if TheWorld.ismastersim then
				inst.components.aoetargeting:SetTargetFX("reticuleaoesummontarget_1")
				inst.components.aoespell:SetSpellFn(TrapSpellFn)
				inst.components.spellbook:SetSpellFn(nil)
			end
		end,
		execute = StartAOETargeting,
		bank = "spell_icons_netra",
		build = "spell_icons_netra",
		anims =
		{
			idle = { anim = "skill_6" },
			focus = { anim = "skill_6_focus", loop = true },
			down = { anim = "skill_6_pressed" },
			disabled = { anim = "skill_6" },
			cooldown = { anim = "skill_6_cooldown" },
		},
        widget_scale = ICON_SCALE,
		checkcooldown = function(user)
			--client safe
			return user
				and user.components.spellbookcooldowns
				and user.components.spellbookcooldowns:GetSpellCooldownPercent("trap_floor")
				or nil
		end,
		cooldowncolor = { 0.65,0.65,0.65, 0.75 },
	},
	
	{
        label = "Amaterasu".." (Cost:100)",
        onselect = function(inst)
            inst.components.spellbook:SetSpellName("Amaterasu")
			inst.components.spellbook:SetSpellAction(nil)
            inst.components.aoetargeting:SetDeployRadius(0)
            inst.components.aoetargeting:SetShouldRepeatCastFn(nil)
            inst.components.aoetargeting.reticule.reticuleprefab = "reticuleline"
            inst.components.aoetargeting.reticule.pingprefab = "reticulelineping"
	
            inst.components.aoetargeting.reticule.mousetargetfn = line_reticule_mouse_target_function
            inst.components.aoetargeting.reticule.targetfn = line_reticule_target_function
            inst.components.aoetargeting.reticule.updatepositionfn = line_reticule_update_position_function
	
            if TheWorld.ismastersim then
				inst.components.aoetargeting:SetTargetFX(nil)
                inst.components.aoespell:SetSpellFn(LunarFireSpellFn)
                inst.components.spellbook:SetSpellFn(nil)
            end
        end,
        execute = StartAOETargeting,
		bank = "spell_icons_netra",
		build = "spell_icons_netra",
		anims =
		{
			idle = { anim = "skill_5" },
			focus = { anim = "skill_5_focus", loop = true },
			down = { anim = "skill_5_pressed" },
			disabled = { anim = "skill_5" },
			cooldown = { anim = "skill_5_cooldown" },
		},
        widget_scale = ICON_SCALE,
		checkenabled = function(user)
			--client safe
			local rider = user and user.replica.rider
			return not (rider and rider:IsRiding())
		end,
		checkcooldown = function(user)
			--client safe
			return user
				and user.components.spellbookcooldowns
				and user.components.spellbookcooldowns:GetSpellCooldownPercent("lunar_fire")
				or nil
		end,
		cooldowncolor = { 0.65,0.65,0.65, 0.75 },
    },
	
}


--------------------------------------------------------------------------
local function Revive_OnHaunt(inst, haunter)
    inst.components.hauntable.hauntvalue = TUNING.HAUNT_SMALL
	if haunter:HasTag("mevileyescraft") and haunter:HasTag("playerghost") and not haunter:HasTag("reviving") then
	
		haunter:PushEvent("respawnfromghost", { source = inst })
				
		if haunter.components.health then
            haunter.components.health:DeltaPenalty(0.25)
        end
		
	    SpawnPrefab("brokentool").Transform:SetPosition(inst.Transform:GetWorldPosition())
		inst:Remove()
	else
        Launch(inst, haunter, TUNING.LAUNCH_SPEED_SMALL)
	end
end
--------------------------------------------------------------------------

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	
	inst.entity:AddMiniMapEntity()
	inst.MiniMapEntity:SetIcon("netrajournal.tex")
	
	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("netrajournal")
	inst.AnimState:SetBuild("netrajournal")
	inst.AnimState:PlayAnimation("anim")

	inst:AddTag("willow_ember")
		
	MakeInventoryFloatable(inst, "med", nil, 0.75)

	inst:AddComponent("spellbook")
	inst.components.spellbook:SetRequiredTag("mevileyescraft")
	inst.components.spellbook:SetRadius(SPELLBOOK_RADIUS)
	inst.components.spellbook:SetFocusRadius(SPELLBOOK_FOCUS_RADIUS)
	inst.components.spellbook:SetItems(SPELLS)

	inst:AddComponent("aoetargeting")
	inst.components.aoetargeting:SetAllowWater(true)
	inst.components.aoetargeting.reticule.targetfn = ReticuleTargetAllowWaterFn
	inst.components.aoetargeting.reticule.validcolour = { 0, 0, 0, 1 }
	inst.components.aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
	inst.components.aoetargeting.reticule.ease = true
	inst.components.aoetargeting.reticule.mouseenabled = true
	inst.components.aoetargeting.reticule.twinstickmode = 1
	inst.components.aoetargeting.reticule.twinstickrange = 8

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then		
		return inst
	end

	inst:AddComponent("inspectable")
	
	inst:AddComponent("inventoryitem")
	
	inst.components.inventoryitem.imagename = "netrajournal"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/netrajournal.xml"
	
	inst:AddComponent("fueled")
	inst.components.fueled.accepting = true
	inst.components.fueled.fueltype = FUELTYPE.NIGHTMARE
	inst.components.fueled:InitializeFuelLevel(TUNING.LARGE_FUEL * 4)

	inst:AddComponent("fuel")
	inst.components.fuel.fuelvalue = TUNING.MED_FUEL

	inst:AddComponent("aoespell")

	MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
	MakeSmallPropagator(inst)

	inst:AddComponent("hauntable")
	inst.components.hauntable:SetOnHauntFn(Revive_OnHaunt)

	return inst
end

return Prefab("netrajournal", fn, assets, prefabs)
