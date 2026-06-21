local MakePlayerCharacter = require "prefabs/player_common"
local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
	Asset( "ANIM", "anim/kodi.zip" ),
	Asset( "ANIM", "anim/kodi_short.zip" ),
	Asset( "ANIM", "anim/kodi_med.zip" ),
	Asset( "ANIM", "anim/demon.zip" ),
	Asset( "ANIM", "anim/demon_short.zip" ),
	Asset( "ANIM", "anim/demon_med.zip" ),
	Asset( "ANIM", "anim/ghost_kodi_build.zip" ),
}
local WOOL_GROWTH_DAYS = {0, 5, 10}
local WOOL_CONFIG = {
    [0] = {
        tag = "NoWool",
        insulation = 0,
        overheat_temp = 70,
        fire_damage_scale = 0,
        bits = 0,
        build_fox = "kodi",
        build_demon = "demon",
    },
    [1] = {
        tag = "ShortWool",
        insulation = 100,
        overheat_temp = 60,
        fire_damage_scale = 0.1,
        bits = 4,
        build_fox = "kodi_short",
        build_demon = "demon_short",
    },
    [2] = {
        tag = "MedWool",
        insulation = 150,
        overheat_temp = 55,
        fire_damage_scale = 0.2,
        bits = 9,
        build_fox = "kodi_med",
        build_demon = "demon_med",
    },
}
local prefabs = {
"Cursefox",
"whitegem",
"whiteamulet",
"kodisword",
"shlemys",
"fox_wool",
"bedroll_fox_furry",
"darkcrystal",
"kitsune_mask",
}
local start_inv = {
"bedroll_fox_furry", "whiteamulet", "fox_wool", "fox_wool", "fox_wool", "fox_wool", "fox_wool", "fox_wool",
}
local function GetWoolBuild(inst)
    local stage = inst._wool_stage or 0
    local config = WOOL_CONFIG[stage]
    if inst:HasTag("NotDemon") then
        return config.build_fox
    else
        return config.build_demon
    end
end
local function IsPlayerGhost(inst)
    return Kodi_IsPlayerGhost and Kodi_IsPlayerGhost(inst) or inst:HasTag("playerghost")
end
local function RefreshWoolAppearance(inst)
    if IsPlayerGhost(inst) then return end
    inst.AnimState:SetBuild(GetWoolBuild(inst))
end
local function UpdateWoolStage(inst, new_stage)
    if IsPlayerGhost(inst) then return end
    local old_stage = inst._wool_stage or 0
    local old_config = WOOL_CONFIG[old_stage]
    local new_config = WOOL_CONFIG[new_stage]
    inst._wool_stage = new_stage
    if inst.components.temperature then
        local current_insulation = inst.components.temperature.inherentinsulation or 0
        local insulation_delta = new_config.insulation - old_config.insulation
        inst.components.temperature.inherentinsulation = current_insulation + insulation_delta
        inst.components.temperature.overheattemp = new_config.overheat_temp
    end
    if inst.components.health then
        inst.components.health.fire_damage_scale = new_config.fire_damage_scale
    end
    if inst.components.beard then
        inst.components.beard.bits = new_config.bits
    end
    inst:RemoveTag("NoWool")
    inst:RemoveTag("ShortWool")
    inst:RemoveTag("MedWool")
    inst:AddTag(new_config.tag)
    inst.AnimState:SetBuild(GetWoolBuild(inst))
end
local function onbecamehuman(inst)
    inst.components.locomotor:SetExternalSpeedMultiplier(inst, "kodi_speed_mod", TUNING.KODI_SPEED)
end
local function onbecameghost(inst)
    inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "kodi_speed_mod")
end
local function onload(inst)
    inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
    inst:ListenForEvent("ms_becameghost", onbecameghost)
    inst:ListenForEvent("ms_becameghost", function()
        inst:DoTaskInTime(0, function()
            if inst:HasTag("playerghost") then
                inst.AnimState:SetBuild("ghost_kodi_build")
            end
        end)
    end)
    if inst:HasTag("playerghost") then
        onbecameghost(inst)
    else
        onbecamehuman(inst)
    end
end
local KODI_DAPPERNESS = {
    DAY_PENALTY    = TUNING.KODI_DAPPERNESS_DAY_PENALTY,
    NIGHT_COMFORT  = TUNING.KODI_DAPPERNESS_NIGHT_COMFORT,
    NIGHT_HUNTER   = TUNING.KODI_DAPPERNESS_NIGHT_HUNTER,
}
local function UpdateSanityDapperness(inst, phase)
    phase = phase or TheWorld.state.phase
    if not inst:HasTag("NotDemon") then
        inst.components.sanity.dapperness = 0
        return
    end
    local has_night_hunter = inst:HasTag("kodi_night_hunter")
    if phase == "day" then
        inst.components.sanity.dapperness = -KODI_DAPPERNESS.DAY_PENALTY
    elseif phase == "dusk" then
        inst.components.sanity.dapperness = 0
    elseif phase == "night" then
        if has_night_hunter then
            inst.components.sanity.dapperness = KODI_DAPPERNESS.NIGHT_HUNTER
        else
            inst.components.sanity.dapperness = KODI_DAPPERNESS.NIGHT_COMFORT
        end
    end
end
local function OnDeath(inst)
    if inst:HasTag("monster") and inst._kodi_do_transform_from_demon then
        inst:_kodi_do_transform_from_demon()
    end
end
local function IsValidShadowDashPosition(pt)
	if not TheWorld or not TheWorld.Map then return false end
	local map = TheWorld.Map
	return map:IsPassableAtPoint(pt:Get())
		and not map:IsGroundTargetBlocked(pt)
		and not map:IsOceanAtPoint(pt.x, 0, pt.z)
end
local function ShadowDashReticuleTargetFn(inst)
	return ControllerReticle_Blink_GetPosition(inst, IsValidShadowDashPosition)
end
local function CanKodiShadowDash(inst, pos)
	if inst.prefab ~= "kodi" then return false end
	if inst:HasTag("NotDemon") then return false end
	if inst:HasTag("shadow_dash_cooldown") then return false end
	if not pos then return false end
	return IsValidShadowDashPosition(pos)
end
local function GetKodiPointSpecialActions(inst, pos, useitem, right)
	if right and useitem == nil then
		if not inst:HasTag("NotDemon") and not inst:HasTag("shadow_dash_cooldown") then
			local equipped = inst.replica.inventory
				and inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			if equipped and equipped:HasTag("rechargeable") then
				return {}
			end
			if pos and CanKodiShadowDash(inst, pos) then
				return { ACTIONS.SHADOW_DASH }
			end
		end
	end
	return {}
end
local function OnSetOwner(inst)
	if inst.components.playeractionpicker ~= nil then
		inst.components.playeractionpicker.pointspecialactionsfn = GetKodiPointSpecialActions
	end
end
local common_postinit = function(inst)
	inst:AddTag("kodi")
	inst:AddTag("kodi_builder")
	inst.MiniMapEntity:SetIcon( "kodi.tex" )
	inst.ghostbuild = "ghost_kodi_build"
	inst.components.talker.font = TALKINGFONT
    inst.components.talker.colour = Vector3(181/255, 5/255, 5/255)
	inst:AddTag("NotDemon")
	inst:AddTag("NoWool")
	inst:AddComponent("reticule")
	inst.components.reticule.targetfn = ShadowDashReticuleTargetFn
	inst.components.reticule.ease = true
	inst.components.reticule.twinstickcheckscheme = true
	inst.components.reticule.twinstickmode = 1
	inst.components.reticule.twinstickrange = 15
	inst.components.reticule.validcolour = { 148/255, 0, 211/255, 1 }
	inst.components.reticule.invalidcolour = { 0.5, 0, 0.3, 1 }
	inst:ListenForEvent("setowner", OnSetOwner)
	local function GetExpectedBuild()
		if inst:HasTag("playerghost") then return nil end
		if inst:HasTag("NotDemon") then
			if inst:HasTag("MedWool") then
				return "kodi_med"
			elseif inst:HasTag("ShortWool") then
				return "kodi_short"
			else
				return "kodi"
			end
		else
			if inst:HasTag("MedWool") then
				return "demon_med"
			elseif inst:HasTag("ShortWool") then
				return "demon_short"
			else
				return "demon"
			end
		end
	end
	local function CheckAndCorrectBuild()
		if not inst:IsValid() then return end
		if IsPlayerGhost(inst) then return end
		local current = inst.AnimState:GetBuild()
		local expected = GetExpectedBuild()
		if expected and current ~= expected then
			inst.AnimState:SetBuild(expected)
		end
	end
	inst:ListenForEvent("onskinschanged", function()
		inst:DoTaskInTime(0.1, CheckAndCorrectBuild)
	end)
	inst:ListenForEvent("ms_respawnedfromghost", function()
		inst:DoTaskInTime(0.5, CheckAndCorrectBuild)
	end)
	inst:ListenForEvent("kodi_form_changed", function()
		inst:DoTaskInTime(0.1, CheckAndCorrectBuild)
	end)
	inst:DoTaskInTime(1, function()
		if not inst:IsValid() then return end
		inst._wardrobe_check_task = inst:DoPeriodicTask(3, CheckAndCorrectBuild)
	end)
	inst:ListenForEvent("onremove", function()
		if inst._wardrobe_check_task then
			inst._wardrobe_check_task:Cancel()
			inst._wardrobe_check_task = nil
		end
	end)
end
local master_postinit = function(inst)
	inst.soundsname = "wilson"
	inst.components.health:SetMaxHealth(TUNING.KODI_MAX_HP)
	inst.components.hunger:SetMax(TUNING.KODI_MAX_HUNGER)
	inst.components.sanity:SetMax(TUNING.KODI_MAX_SANITY)
	inst.ghostbuild = "ghost_kodi_build"
    inst.components.combat.damagemultiplier = (TUNING.KODI_DAMAGEMULT)
	inst.components.hunger.hungerrate = 1 * TUNING.WILSON_HUNGER_RATE
	if inst.components.eater then
		inst.components.eater:SetCanEatHorrible()
	end
	if not inst:HasTag("playerghost") then
		inst:AddComponent("beard")
	end
	inst._wool_stage = 0
	inst.components.beard.prize = "fox_wool"
	for stage = 0, 2 do
		inst.components.beard:AddCallback(WOOL_GROWTH_DAYS[stage + 1], function()
			UpdateWoolStage(inst, stage)
		end)
	end
	inst:ListenForEvent("kodi_form_changed", function()
		RefreshWoolAppearance(inst)
	end)
	inst.GetWoolBuild = function() return GetWoolBuild(inst) end
	inst.RefreshWoolAppearance = function() RefreshWoolAppearance(inst) end
	inst.OnLoad = onload
    inst.OnNewSpawn = onload
	inst:ListenForEvent("death",OnDeath)
    inst:WatchWorldState("phase", UpdateSanityDapperness)
    UpdateSanityDapperness(inst, TheWorld.state.phase)
    inst:ListenForEvent("kodi_form_changed", function()
        UpdateSanityDapperness(inst)
    end)
end
return MakePlayerCharacter("kodi", prefabs, assets, common_postinit, master_postinit, start_inv)