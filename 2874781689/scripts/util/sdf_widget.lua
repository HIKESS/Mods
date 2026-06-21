AddComponentPostInit("builder", BuilderINIT)

local soulbadge = GLOBAL.require "widgets/sdf_soul_badge"

local lifebottlebadge = GLOBAL.require "widgets/sdf_lifebottle_badge"

local superarmorbadge = GLOBAL.require "widgets/sdf_superarmor_badge"

local function onstatusdisplaysconstruct(self)
	if self.owner.prefab == "sdf" then

	    --Souls HUD
	    self.hud_souls = self:AddChild(soulbadge(self,self.owner))
	    self.owner.soulhud = self.hud_souls

	    --Lifebottle HUDs
	    self.hud_lifebottle_1 = self:AddChild(lifebottlebadge(self,self.owner))
	    self.owner.lifebottle_1_hud = self.hud_lifebottle_1

	    self.hud_lifebottle_2 = self:AddChild(lifebottlebadge(self,self.owner))
	    self.owner.lifebottle_2_hud = self.hud_lifebottle_2

	    self.hud_lifebottle_3 = self:AddChild(lifebottlebadge(self,self.owner))
	    self.owner.lifebottle_3_hud = self.hud_lifebottle_3

	    self.hud_lifebottle_4 = self:AddChild(lifebottlebadge(self,self.owner))
	    self.owner.lifebottle_4_hud = self.hud_lifebottle_4

	    self.hud_lifebottle_5 = self:AddChild(lifebottlebadge(self,self.owner))
	    self.owner.lifebottle_5_hud = self.hud_lifebottle_5

	    self.hud_lifebottle_6 = self:AddChild(lifebottlebadge(self,self.owner))
	    self.owner.lifebottle_6_hud = self.hud_lifebottle_6

	    self.hud_lifebottle_7 = self:AddChild(lifebottlebadge(self,self.owner))
	    self.owner.lifebottle_7_hud = self.hud_lifebottle_7

	    self.hud_lifebottle_8 = self:AddChild(lifebottlebadge(self,self.owner))
	    self.owner.lifebottle_8_hud = self.hud_lifebottle_8

	    self.hud_lifebottle_9 = self:AddChild(lifebottlebadge(self,self.owner))
	    self.owner.lifebottle_9_hud = self.hud_lifebottle_9

	    --Superarmor HUD
	    self.hud_superarmor = self:AddChild(superarmorbadge(self,self.owner))
	    self.owner.superarmorhud = self.hud_superarmor


            self.owner.UpdateBadges = function()


		--Souls
		local percent_souls = self.owner.currentsouls and (self.owner.currentsouls:value())/100 or 0
		self.hud_souls:SetPercent(percent_souls,100)

		--Lifebottles
		local percent_lifebottle_1 = self.owner.lifebottle_1 and (self.owner.lifebottle_1:value())/TUNING.SDF_LIFEBOTTLE_HEALTH_MAX or 0
		self.hud_lifebottle_1:SetPercent(percent_lifebottle_1,TUNING.SDF_LIFEBOTTLE_HEALTH_MAX)

		local percent_lifebottle_2 = self.owner.lifebottle_2 and (self.owner.lifebottle_2:value())/TUNING.SDF_LIFEBOTTLE_HEALTH_MAX or 0
		self.hud_lifebottle_2:SetPercent(percent_lifebottle_2,TUNING.SDF_LIFEBOTTLE_HEALTH_MAX)

		local percent_lifebottle_3 = self.owner.lifebottle_3 and (self.owner.lifebottle_3:value())/TUNING.SDF_LIFEBOTTLE_HEALTH_MAX or 0
		self.hud_lifebottle_3:SetPercent(percent_lifebottle_3,TUNING.SDF_LIFEBOTTLE_HEALTH_MAX)

		local percent_lifebottle_4 = self.owner.lifebottle_4 and (self.owner.lifebottle_4:value())/TUNING.SDF_LIFEBOTTLE_HEALTH_MAX or 0
		self.hud_lifebottle_4:SetPercent(percent_lifebottle_4,TUNING.SDF_LIFEBOTTLE_HEALTH_MAX)

		local percent_lifebottle_5 = self.owner.lifebottle_5 and (self.owner.lifebottle_5:value())/TUNING.SDF_LIFEBOTTLE_HEALTH_MAX or 0
		self.hud_lifebottle_5:SetPercent(percent_lifebottle_5,TUNING.SDF_LIFEBOTTLE_HEALTH_MAX)

		local percent_lifebottle_6 = self.owner.lifebottle_6 and (self.owner.lifebottle_6:value())/TUNING.SDF_LIFEBOTTLE_HEALTH_MAX or 0
		self.hud_lifebottle_6:SetPercent(percent_lifebottle_6,TUNING.SDF_LIFEBOTTLE_HEALTH_MAX)

		local percent_lifebottle_7 = self.owner.lifebottle_7 and (self.owner.lifebottle_7:value())/TUNING.SDF_LIFEBOTTLE_HEALTH_MAX or 0
		self.hud_lifebottle_7:SetPercent(percent_lifebottle_7,TUNING.SDF_LIFEBOTTLE_HEALTH_MAX)

		local percent_lifebottle_8 = self.owner.lifebottle_8 and (self.owner.lifebottle_8:value())/TUNING.SDF_LIFEBOTTLE_HEALTH_MAX or 0
		self.hud_lifebottle_8:SetPercent(percent_lifebottle_8,TUNING.SDF_LIFEBOTTLE_HEALTH_MAX)

		local percent_lifebottle_9 = self.owner.lifebottle_9 and (self.owner.lifebottle_9:value())/TUNING.SDF_LIFEBOTTLE_HEALTH_MAX or 0
		self.hud_lifebottle_9:SetPercent(percent_lifebottle_9,TUNING.SDF_LIFEBOTTLE_HEALTH_MAX)

		--Superarmor
		local percent_superarmor = self.owner.currentsuperarmor and (self.owner.currentsuperarmor:value())/TUNING.SDF_SUPERARMOR_MAX or 0
		self.hud_superarmor:SetPercent(percent_superarmor,TUNING.SDF_SUPERARMOR_MAX)
            end
	end
end


AddClassPostConstruct("widgets/statusdisplays", onstatusdisplaysconstruct)


--Souls
local function OnUpdateSouls(inst)
    if GLOBAL.ThePlayer then
	if not GLOBAL.ThePlayer.UpdateBadges then return end
	GLOBAL.ThePlayer.UpdateBadges()
    end
end

local function DirtySoulUpdate(inst)
    if inst.components.sdf_souls.current ~= 0 then
        inst.currentsouls:set(math.floor(inst.components.sdf_souls.current))
    else
        if not inst.soulupdate then
            inst.currentsouls:set(1)
            inst.soulupdate = true
        else
            inst.currentsouls:set(math.floor(inst.components.sdf_souls.current))
        end
    end
end


--Lifebottles
local function OnUpdateLifebottle(inst)
    if GLOBAL.ThePlayer then
	if not GLOBAL.ThePlayer.UpdateBadges then return end
	GLOBAL.ThePlayer.UpdateBadges()
    end
end

local function DirtyLifebottleUpdate(inst)

    --Lifebottle 1
    if inst.components.sdf_lifebottle_1.current ~= 0 then
        inst.lifebottle_1:set(math.floor(inst.components.sdf_lifebottle_1.current))
    else
        if not inst.lifebottle_1_update then
            inst.lifebottle_1:set(1)
            inst.lifebottle_1_update = true
        else
            inst.lifebottle_1:set(math.floor(inst.components.sdf_lifebottle_1.current))
        end
    end

    --Lifebottle 2
    if inst.components.sdf_lifebottle_2.current ~= 0 then
        inst.lifebottle_2:set(math.floor(inst.components.sdf_lifebottle_2.current))
    else
        if not inst.lifebottle_2_update then
            inst.lifebottle_2:set(1)
            inst.lifebottle_2_update = true
        else
            inst.lifebottle_2:set(math.floor(inst.components.sdf_lifebottle_2.current))
        end
    end

    --Lifebottle 3
    if inst.components.sdf_lifebottle_3.current ~= 0 then
        inst.lifebottle_3:set(math.floor(inst.components.sdf_lifebottle_3.current))
    else
        if not inst.lifebottle_3_update then
            inst.lifebottle_3:set(1)
            inst.lifebottle_3_update = true
        else
            inst.lifebottle_3:set(math.floor(inst.components.sdf_lifebottle_3.current))
        end
    end

    --Lifebottle 4
    if inst.components.sdf_lifebottle_4.current ~= 0 then
        inst.lifebottle_4:set(math.floor(inst.components.sdf_lifebottle_4.current))
    else
        if not inst.lifebottle_4_update then
            inst.lifebottle_4:set(1)
            inst.lifebottle_4_update = true
        else
            inst.lifebottle_4:set(math.floor(inst.components.sdf_lifebottle_4.current))
        end
    end

    --Lifebottle 5
    if inst.components.sdf_lifebottle_5.current ~= 0 then
        inst.lifebottle_5:set(math.floor(inst.components.sdf_lifebottle_5.current))
    else
        if not inst.lifebottle_5_update then
            inst.lifebottle_5:set(1)
            inst.lifebottle_5_update = true
        else
            inst.lifebottle_5:set(math.floor(inst.components.sdf_lifebottle_5.current))
        end
    end

    --Lifebottle 6
    if inst.components.sdf_lifebottle_6.current ~= 0 then
        inst.lifebottle_6:set(math.floor(inst.components.sdf_lifebottle_6.current))
    else
        if not inst.lifebottle_6_update then
            inst.lifebottle_6:set(1)
            inst.lifebottle_6_update = true
        else
            inst.lifebottle_6:set(math.floor(inst.components.sdf_lifebottle_6.current))
        end
    end

    --Lifebottle 7
    if inst.components.sdf_lifebottle_7.current ~= 0 then
        inst.lifebottle_7:set(math.floor(inst.components.sdf_lifebottle_7.current))
    else
        if not inst.lifebottle_7_update then
            inst.lifebottle_7:set(1)
            inst.lifebottle_7_update = true
        else
            inst.lifebottle_7:set(math.floor(inst.components.sdf_lifebottle_7.current))
        end
    end

    --Lifebottle 8
    if inst.components.sdf_lifebottle_8.current ~= 0 then
        inst.lifebottle_8:set(math.floor(inst.components.sdf_lifebottle_8.current))
    else
        if not inst.lifebottle_8_update then
            inst.lifebottle_8:set(1)
            inst.lifebottle_8_update = true
        else
            inst.lifebottle_8:set(math.floor(inst.components.sdf_lifebottle_8.current))
        end
    end

    --Lifebottle 9
    if inst.components.sdf_lifebottle_9.current ~= 0 then
        inst.lifebottle_9:set(math.floor(inst.components.sdf_lifebottle_9.current))
    else
        if not inst.lifebottle_9_update then
            inst.lifebottle_9:set(1)
            inst.lifebottle_9_update = true
        else
            inst.lifebottle_9:set(math.floor(inst.components.sdf_lifebottle_9.current))
        end
    end
end

--Super Armor
local function OnUpdateSuperarmor(inst)
    if GLOBAL.ThePlayer then
	if not GLOBAL.ThePlayer.UpdateBadges then return end
	GLOBAL.ThePlayer.UpdateBadges()
    end
end

local function DirtySuperarmorUpdate(inst)
    if inst.components.sdf_superarmor.current ~= 0 then
        inst.currentsuperarmor:set(math.floor(inst.components.sdf_superarmor.current))
    else
        if not inst.superarmorupdate then
            inst.currentsuperarmor:set(1)
            inst.superarmorupdate = true
        else
            inst.currentsuperarmor:set(math.floor(inst.components.sdf_superarmor.current))
        end
    end
end

---------------------------------------------------------------------------------------------
--Shield Vars Setup
local SHIELDMODE_NAMES =
{
    "parry",
}

local SHIELDMODE = { NONE = 0 }
for i, v in ipairs(SHIELDMODE_NAMES) do
    SHIELDMODE[string.upper(v)] = i
end

local function IsShieldMode(mode)
    return SHIELDMODE_NAMES[mode] ~= nil
end

local function CannotExamine(inst)
    return false
end

local function Empty()
end
------------------------------------------------------------------------------------------------------------------------
local function ReticuleTargetFn(inst)
    return Vector3(inst.entity:LocalToWorldSpace(1.5, 0, 0))
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

	if inst.components.reticule ~= nil then
		inst.components.reticule.ease = reticule.entity:IsVisible()
	end
end

local function EnableReticule(inst, enable)
    if enable then
        if inst.components.reticule == nil then
            inst:AddComponent("reticule")
            inst.components.reticule.reticuleprefab = "reticulearc"
	    inst.components.reticule.pingprefab = "reticulearcping"
            inst.components.reticule.targetfn = ReticuleTargetFn
            inst.components.reticule.updatepositionfn = ReticuleUpdatePositionFn
            inst.components.reticule.ease = true
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
---------------------------------------------------------------------------------------------
local function ParryActionString(inst, action)
    return STRINGS.ACTIONHANDLER_SDF_SHIELD_PARRY, false
end

local function ParryLeftClickPicker(inst, target, pos)
    return target ~= inst
        and (
                (
		    not inst.components.playercontroller.isclientcontrollerattached and
                    inst.components.playeractionpicker:SortActionList({ ACTIONS.CASTAOE }, pos, nil)
                )
            )
        or nil
end

local function ParryPointSpecialActions(inst, pos, useitem, right)
    return right and inst.components.playercontroller:IsEnabled() and { ACTIONS.CASTAOE } or {}
end

local function removeShieldParryStatus(inst)
    if inst:HasTag("sdf_shield_parry_active") then
	inst:RemoveTag("sdf_shield_parry_active")
    end

    if inst:HasTag("sdf_shield_parry_action_active") then
	inst:RemoveTag("sdf_shield_parry_action_active")
    end
end

local function SetShieldActions(inst, mode)
    if not IsShieldMode(mode) then --Normal Mode
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller.actionbuttonoverride = nil
        end
        if inst.components.playeractionpicker ~= nil then
            inst.components.playeractionpicker.leftclickoverride = nil
            inst.components.playeractionpicker.pointspecialactionsfn = nil
        end
        inst.ActionStringOverride = nil --added delay for visual
        EnableReticule(inst, false) --might beable to remove
	inst.components.playercontroller:RemotePausePrediction(1)
    elseif mode == SHIELDMODE.PARRY then --Parry Mode
        inst.ActionStringOverride = ParryActionString
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller.actionbuttonoverride = Empty
        end
        if inst.components.playeractionpicker ~= nil then
            inst.components.playeractionpicker.leftclickoverride = ParryLeftClickPicker
            --inst.components.playeractionpicker.rightclickoverride = nil --maybe not needed
            inst.components.playeractionpicker.pointspecialactionsfn = ParryPointSpecialActions
        end
        EnableReticule(inst, true) --might beable to remove
	inst.components.playercontroller:RemotePausePrediction(1)
    end
end

local function SetShieldMode(inst, mode)
    if IsShieldMode(mode) then
        if not TheWorld.ismastersim then
            inst.CanExamine = CannotExamine
            SetShieldActions(inst, mode)
        end
    else
        if not TheWorld.ismastersim then
            inst.CanExamine = nil
            SetShieldActions(inst, mode)
        end
    end
end

local function OnShieldModeDirty(inst)
    if not inst:HasTag("playerghost") then
        SetShieldMode(inst, inst.sdf_shieldmode:value())
    end
end

local function OnPlayerDeactivated(inst)
    if not TheWorld.ismastersim then
        inst:RemoveEventCallback("shieldmodedirty", OnShieldModeDirty)
    end
end

local function OnPlayerActivated(inst)
    if not TheWorld.ismastersim then
        inst:ListenForEvent("shieldmodedirty", OnShieldModeDirty)
    end
    OnShieldModeDirty(inst)
end

local function IsShieldParry(inst)
    return inst.sdf_shieldmode:value() == SHIELDMODE.PARRY
end

local function ChangeShieldModeValue(inst, newmode)
    if inst.sdf_shieldmode:value() ~= newmode then
        inst.sdf_shieldmode:set(newmode)
        OnShieldModeDirty(inst)
    end
end

local function onShieldNormal(inst)
    removeShieldParryStatus(inst)

    --can drop shield
    inst:RemoveTag("nosteal")
    inst:RemoveTag("stickygrip")

    if inst.components.pinnable then
	inst.components.pinnable.canbepinned = true
    end
    inst.CanExamine = nil
    SetShieldActions(inst, SHIELDMODE.NONE)
    ChangeShieldModeValue(inst, SHIELDMODE.NONE)
end

local function onShieldParry(inst)
    --cant drop shield
    inst:AddTag("nosteal")
    inst:AddTag("stickygrip")

    inst.components.pinnable.canbepinned = false
    inst.CanExamine = CannotExamine
    SetShieldActions(inst, SHIELDMODE.PARRY)
    ChangeShieldModeValue(inst, SHIELDMODE.PARRY)
end
---------------------------------------------------------------------------------------------
local function checkAnubisStone(inst)
    local bodyItem = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
    if bodyItem and bodyItem.prefab == "sdf_anubis_stone" then
	return true
    elseif inst.components.inventory:FindItem(function(item) return (item.prefab == "sdf_anubis_stone")end) then
	return true
    end
    return false
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

local function onKilled(inst, data)
    if checkAnubisStone(inst) == true then
	local victim = data.victim
	if data ~= nil and victim ~= nil then
	    if IsValidVictim(victim) then
		if victim:HasTag("epic") then
		    if victim.components.lootdropper ~= nil then
			victim.components.lootdropper:AddChanceLoot("sdf_soul_helmet", TUNING.SDF_ANUBIS_STONE_SOUL_HELMET_CHANCE_EPIC)
		    end
		elseif victim:HasTag("smallcreature") and not victim:HasTag("hostile") then
		    if victim.components.lootdropper ~= nil then
			victim.components.lootdropper:AddChanceLoot("sdf_soul_helmet", TUNING.SDF_ANUBIS_STONE_SOUL_HELMET_CHANCE)
		    end
		else
		    if victim.components.lootdropper ~= nil then
			victim.components.lootdropper:AddChanceLoot("sdf_soul_helmet", TUNING.SDF_ANUBIS_STONE_SOUL_HELMET_CHANCE)
		    end
		end
	    end
	end
    end
end
---------------------------------------------------------------------------------------------
local function applySdfShadowTalismanVision(inst)
    if inst.components.playervision then
	if inst.sdf_shadowtalismanvision:value() then
	    inst.components.playervision:ForceNightVision(true)
	else
	    inst.components.playervision:ForceNightVision(false)
	end
    end
end

local function registerSdfShadowTalismanVisionListener(inst)
    inst:ListenForEvent("shadowtalismanvisiondirty", applySdfShadowTalismanVision)
end

local function initializeSdfShadowTalismanVision(inst)
    inst.sdf_shadowtalismanvision = net_bool(inst.GUID, "player.sdf_shadowtalismanvision", "shadowtalismanvisiondirty")
    inst.sdf_shadowtalismanvision:set(false)
    inst:DoTaskInTime(0, registerSdfShadowTalismanVisionListener)
end

---------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------

-- Adds things to the player after initialization
AddPlayerPostInit(function(inst)

    --Shield Action Setup
	--Dirty
	if not GLOBAL.TheNet:IsDedicated() then
	    inst:ListenForEvent("playeractivated", OnPlayerActivated)
            inst:ListenForEvent("playerdeactivated", OnPlayerDeactivated)
	end

	inst.sdf_shieldmode = net_tinybyte(inst.GUID, "wilson.sdf_shieldmode", "shieldmodedirty")


	--Shield Parry
        inst.sdf_isshieldparry  = IsShieldParry

 	inst.SDF_ShieldParryEnableFn = function() onShieldParry(inst) end
	inst.SDF_ShieldParryDisableFn = function() onShieldNormal(inst) end
	inst.SDF_ShieldParryRemoveFn = function() removeShieldParryStatus(inst) end


    --Book of Gallowmere Setup
    inst:AddComponent("sdf_book_of_gallowmere_entry")

    --Anubis Stone Soul Helmet Drop Setup -Not SDF-
    if inst.prefab ~= "sdf" then
	inst:ListenForEvent("killed", onKilled)
    end

    --Gutable Setup
    if inst.components.inkable then
        inst:AddComponent("sdf_pumpking_gutable")
    end

    --Shadow Talisman Setup
    initializeSdfShadowTalismanVision(inst)

    --SDF UI Setup
    if inst.prefab == "sdf" then

	--Chalice system
	inst:AddComponent("sdf_chalice_id_lock")

	--Soul system
        inst:AddComponent("sdf_souls")
        inst.currentsouls = GLOBAL.net_ushortint(inst.GUID, "sdf_souls.current","sdfsoulsdirty")

	    if not GLOBAL.TheNet:IsDedicated() then
            inst:ListenForEvent("sdfsoulsdirty", 
            function(inst)
                 OnUpdateSouls(inst) 
            end)
            inst:DoPeriodicTask(0.3,function (inst)
                if inst.soulhud then
		    --Other Addon spacing Stuff
                    local currentPlaform = inst:GetCurrentPlatform()

		    --Combined Status Mod
		    if GLOBAL.KnownModIndex:IsModEnabled("workshop-376333686") then
                        inst.soulhud:SetPosition(-62,-52,0)
                    else
                        inst.soulhud:SetPosition(-75,-45,0) --(-75,-45,0) Default
                    end

                    if not inst:HasTag("playerghost") then
                        inst.soulhud:Show()
                    else
                        inst.soulhud:Hide()
                    end
                end
            end)
        end

	--Lifebottle system
	inst:AddComponent("sdf_lifebottle_holder")
        inst:AddComponent("sdf_lifebottle_1")
        inst:AddComponent("sdf_lifebottle_2")
        inst:AddComponent("sdf_lifebottle_3")
        inst:AddComponent("sdf_lifebottle_4")
        inst:AddComponent("sdf_lifebottle_5")
        inst:AddComponent("sdf_lifebottle_6")
        inst:AddComponent("sdf_lifebottle_7")
        inst:AddComponent("sdf_lifebottle_8")
        inst:AddComponent("sdf_lifebottle_9")

        inst.lifebottle_1 = GLOBAL.net_ushortint(inst.GUID, "sdf_lifebottle_1.current","sdflifebottledirty")
        inst.lifebottle_2 = GLOBAL.net_ushortint(inst.GUID, "sdf_lifebottle_2.current","sdflifebottledirty")
        inst.lifebottle_3 = GLOBAL.net_ushortint(inst.GUID, "sdf_lifebottle_3.current","sdflifebottledirty")
        inst.lifebottle_4 = GLOBAL.net_ushortint(inst.GUID, "sdf_lifebottle_4.current","sdflifebottledirty")
        inst.lifebottle_5 = GLOBAL.net_ushortint(inst.GUID, "sdf_lifebottle_5.current","sdflifebottledirty")
        inst.lifebottle_6 = GLOBAL.net_ushortint(inst.GUID, "sdf_lifebottle_6.current","sdflifebottledirty")
        inst.lifebottle_7 = GLOBAL.net_ushortint(inst.GUID, "sdf_lifebottle_7.current","sdflifebottledirty")
        inst.lifebottle_8 = GLOBAL.net_ushortint(inst.GUID, "sdf_lifebottle_8.current","sdflifebottledirty")
        inst.lifebottle_9 = GLOBAL.net_ushortint(inst.GUID, "sdf_lifebottle_9.current","sdflifebottledirty")

	    if not GLOBAL.TheNet:IsDedicated() then
            inst:ListenForEvent("sdflifebottledirty", 
            function(inst)
                 OnUpdateLifebottle(inst) 
            end)

	    --Lifebottles
            inst:DoPeriodicTask(0.2,function (inst)
                if inst.lifebottle_1_hud then

		    --Combined Status Mod
		    if GLOBAL.KnownModIndex:IsModEnabled("workshop-376333686") then
                        inst.lifebottle_1_hud:SetPosition(41,-92,0)
                    else
                        inst.lifebottle_1_hud:SetPosition(52,-35,0) --(50,-80,0) Default
                    end	    
                    if not inst:HasTag("playerghost") and inst:HasTag("lifebottle_1_enabled") then
			inst.lifebottle_1_hud:Show()
                    else
                        inst.lifebottle_1_hud:Hide()
                    end
                end
                if inst.lifebottle_2_hud then

		    --Combined Status Mod
		    if GLOBAL.KnownModIndex:IsModEnabled("workshop-376333686") then
                        inst.lifebottle_2_hud:SetPosition(41,-115,0)
                    else
                        inst.lifebottle_2_hud:SetPosition(52,-65,0) --(55,-65,0) Default
                    end	 
                    if not inst:HasTag("playerghost") and inst:HasTag("lifebottle_2_enabled") then
                        inst.lifebottle_2_hud:Show()
                    else
                        inst.lifebottle_2_hud:Hide()
                    end
                end
                if inst.lifebottle_3_hud then

		    --Combined Status Mod
		    if GLOBAL.KnownModIndex:IsModEnabled("workshop-376333686") then
                        inst.lifebottle_3_hud:SetPosition(41,-138,0)
                    else
                        inst.lifebottle_3_hud:SetPosition(52,-95,0) --(55,-95,0) Default
                    end	 
                    if not inst:HasTag("playerghost") and inst:HasTag("lifebottle_3_enabled") then
                        inst.lifebottle_3_hud:Show()
                    else
                        inst.lifebottle_3_hud:Hide()
                    end
                end
                if inst.lifebottle_4_hud then

		    --Combined Status Mod
		    if GLOBAL.KnownModIndex:IsModEnabled("workshop-376333686") then
                        inst.lifebottle_4_hud:SetPosition(41,-161,0)
                    else
                        inst.lifebottle_4_hud:SetPosition(52,-125,0) --(55,-125,0) Default
                    end	 
                    if not inst:HasTag("playerghost") and inst:HasTag("lifebottle_4_enabled") then
                        inst.lifebottle_4_hud:Show()
                    else
                        inst.lifebottle_4_hud:Hide()
                    end
                end
                if inst.lifebottle_5_hud then

		    --Combined Status Mod
		    if GLOBAL.KnownModIndex:IsModEnabled("workshop-376333686") then
                        inst.lifebottle_5_hud:SetPosition(41,-184,0)
                    else
                        inst.lifebottle_5_hud:SetPosition(52,-155,0) --(55,-155,0) Default
                    end	 
                    if not inst:HasTag("playerghost") and inst:HasTag("lifebottle_5_enabled") then
                        inst.lifebottle_5_hud:Show()
                    else
                        inst.lifebottle_5_hud:Hide()
                    end
                end
                if inst.lifebottle_6_hud then

		    --Combined Status Mod
		    if GLOBAL.KnownModIndex:IsModEnabled("workshop-376333686") then
                        inst.lifebottle_6_hud:SetPosition(41,-207,0)
                    else
                        inst.lifebottle_6_hud:SetPosition(52,-185,0) --(55,-185,0) Default
                    end	 
                    if not inst:HasTag("playerghost") and inst:HasTag("lifebottle_6_enabled") then
                        inst.lifebottle_6_hud:Show()
                    else
                        inst.lifebottle_6_hud:Hide()
                    end
                end
                if inst.lifebottle_7_hud then

		    --Combined Status Mod
		    if GLOBAL.KnownModIndex:IsModEnabled("workshop-376333686") then
                        inst.lifebottle_7_hud:SetPosition(41,-230,0)
                    else
                        inst.lifebottle_7_hud:SetPosition(52,-215,0) --(55,-215,0) Default
                    end	 
                    if not inst:HasTag("playerghost") and inst:HasTag("lifebottle_7_enabled") then
                        inst.lifebottle_7_hud:Show()
                    else
                        inst.lifebottle_7_hud:Hide()
                    end
                end
                if inst.lifebottle_8_hud then

		    --Combined Status Mod
		    if GLOBAL.KnownModIndex:IsModEnabled("workshop-376333686") then
                        inst.lifebottle_8_hud:SetPosition(41,-253,0)
                    else
                        inst.lifebottle_8_hud:SetPosition(52,-245,0) --(55,-245,0) Default
                    end	 
                    if not inst:HasTag("playerghost") and inst:HasTag("lifebottle_8_enabled") then
                        inst.lifebottle_8_hud:Show()
                    else
                        inst.lifebottle_8_hud:Hide()
                    end
                end
                if inst.lifebottle_9_hud then

		    --Combined Status Mod
		    if GLOBAL.KnownModIndex:IsModEnabled("workshop-376333686") then
                        inst.lifebottle_9_hud:SetPosition(41,-276,0)
                    else
                        inst.lifebottle_9_hud:SetPosition(52,-275,0) --(55,-275,0) Default
                    end	 
                    if not inst:HasTag("playerghost") and inst:HasTag("lifebottle_9_enabled") then
                        inst.lifebottle_9_hud:Show()
                    else
                        inst.lifebottle_9_hud:Hide()
                    end
                end
            end)
        end

	--Superarmor system
        inst:AddComponent("sdf_superarmor")
        inst.currentsuperarmor = GLOBAL.net_ushortint(inst.GUID, "sdf_superarmor.current","sdfsuperarmordirty")

	    if not GLOBAL.TheNet:IsDedicated() then
            inst:ListenForEvent("sdfsuperarmordirty", 
            function(inst)
                 OnUpdateSuperarmor(inst) 
            end)
            inst:DoPeriodicTask(0.3,function (inst)
                if inst.superarmorhud then
		    --Other Addon spacing Stuff
                    local currentPlaform = inst:GetCurrentPlatform()

		    --Combined Status Mod
		    if GLOBAL.KnownModIndex:IsModEnabled("workshop-376333686") then
			inst.superarmorhud:SetPosition(62,35,0)
                        --inst.superarmorhud:SetPosition(-124,35,0)
                    else
                        inst.superarmorhud:SetPosition(40,20,0) --(40,20,0) Default
                    end

                    if not inst:HasTag("playerghost") then
                        inst.superarmorhud:Show()
                    else
                        inst.superarmorhud:Hide()
                    end
                end
            end)
        end

	--Rune system
	inst:AddComponent("sdf_rune_holder")

	--Master Updater
        if GLOBAL.TheWorld.ismastersim then
            --inst:DoPeriodicTask(1, function(inst)inst:PushEvent("sdfUpdate")end)
            inst:DoPeriodicTask(0.3, function()
                DirtySoulUpdate(inst)
            end)
            inst:DoPeriodicTask(0.3, function()
                DirtyLifebottleUpdate(inst)
            end)
            inst:DoPeriodicTask(0.3, function()
                DirtySuperarmorUpdate(inst)
            end)
        end
    end


    --SDF Special Action Setup
    inst:DoTaskInTime(0,function()
	if inst.components.playeractionpicker then

	    --self
	    local self = inst.components.playeractionpicker

	    --Only sdf special actions.
	    if inst.prefab ~= "sdf" then
		return
	    end


	    self.rightclickoverride = function(inst, target, position)
		if target and target:HasTag("sdf_gallowmere_knight_tactics") and target:HasTag("sdf_gallowmere_knight_command_stay") then
		    local actions = {}
		    table.insert(actions, ACTIONS.SDF_GALLOWMERE_KNIGHT_COMMAND_FOLLOW)
		    return self:SortActionList(actions, target)
		elseif target and target:HasTag("sdf_gallowmere_knight_tactics") and target:HasTag("sdf_gallowmere_knight_command_follow") then
		    local actions = {}
		    table.insert(actions, ACTIONS.SDF_GALLOWMERE_KNIGHT_COMMAND_STAY)
		    return self:SortActionList(actions, target)
		elseif inst:HasTag("sdf_lightning_gauntlet_transfer") and target and not (inst == target) and (target:HasTag("lightningrod") or target:HasTag("sdf_chalice_goodlightning")) then
		    local actions = {}
		    table.insert(actions, ACTIONS.SDF_LIGHTNING_GAUNTLET_TRANSFER)
		    return self:SortActionList(actions, target)
		else

		    --Restores old Right Click Functions
		    local steering_actions = self:GetSteeringActions(self.inst, position, true)
		    if steering_actions ~= nil then
			--self.disable_right_click = true
			return steering_actions
		    end

		    local cannon_aim_actions = self:GetCannonAimActions(self.inst, position, true)
		    if cannon_aim_actions ~= nil then
			return cannon_aim_actions
		    end

		    local actions = nil
		    local useitem = self.inst.replica.inventory:GetActiveItem()
		    local equipitem = self.inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

		    if target ~= nil and self.containers[target] then
			--check if we have container widget actions
			actions = self:GetSceneActions(target, true)
		    elseif useitem ~= nil then
			--if we're specifically using an item, see if we can use it on the target entity
			if useitem:IsValid() then
 			    if target == self.inst then
				actions = self:GetInventoryActions(useitem, true)
			    elseif target ~= nil and ((not target:HasTag("walkableplatform") and not target:HasTag("ignoremouseover")) or (useitem:HasTag("repairer") and not useitem:HasTag("deployable"))) then
				actions = self:GetUseItemActions(target, useitem, true)
				if #actions == 0 and target:HasTag("walkableperipheral") then
				    actions = self:GetPointActions(position, useitem, true, target)
				end
			    else
				actions = self:GetPointActions(position, useitem, true, target)
			    end
			end
		    elseif target ~= nil and not target:HasTag("walkableplatform") then
			--if we're clicking on a scene entity, see if we can use our equipped object on it, or just use it
			if equipitem ~= nil and equipitem:IsValid() then
			    actions = self:GetEquippedItemActions(target, equipitem, true)

			    --strip out all other actions for weapons with right click special attacks
			    --@V2C: #FORGE_AOE_RCLICK *searchable*
			    --      -Forge used to strip all r.click actions even before starting aoe targeting.
			    --if equipitem.components.aoetargeting ~= nil then
			    if equipitem.components.aoetargeting and self.inst.components.playercontroller:IsAOETargeting() then
				return (#actions <= 0 or actions[1].action == ACTIONS.CASTAOE) and actions or {}
			    end
			end

			if actions == nil or #actions == 0 then
			    actions = self:GetSceneActions(target, true)
				if (#actions == 0 or (#actions == 1 and actions[1].action == ACTIONS.LOOKAT)) and target:HasTag("walkableperipheral") then
				    if equipitem ~= nil and equipitem:IsValid() then
				    local alwayspassable, allowwater--, deployradius
				    local aoetargeting = equipitem.components.aoetargeting
				    if aoetargeting ~= nil and aoetargeting:IsEnabled() then
					alwayspassable = aoetargeting.alwaysvalid
					allowwater = aoetargeting.allowwater
					--deployradius = aoetargeting.deployradius
				    end
				    alwayspassable = alwayspassable or equipitem:HasTag("allow_action_on_impassable")
				    --V2C: just do passable check here, componentactions tends to redo the full check
				    --if self.map:CanCastAtPoint(position, alwayspassable, allowwater, deployradius) then
				    if alwayspassable or self.map:IsPassableAtPoint(position.x, 0, position.z, allowwater) then
					actions = self:GetPointActions(position, equipitem, true, target)
				    end
				end
			    end
			end
		    else
			local item = spellbook or equipitem
			if item ~= nil and item:IsValid() then
			    local alwayspassable, allowwater--, deployradius
			    local aoetargeting = item.components.aoetargeting
			    if aoetargeting ~= nil and aoetargeting:IsEnabled() then
				alwayspassable = item.components.aoetargeting.alwaysvalid
				allowwater = item.components.aoetargeting.allowwater
				--deployradius = item.components.aoetargeting.deployradius
			    end
			    alwayspassable = alwayspassable or item:HasTag("allow_action_on_impassable")
			    --V2C: just do passable check here, componentactions tends to redo the full check
			    --if self.map:CanCastAtPoint(position, alwayspassable, allowwater, deployradius) then
			    if alwayspassable or self.map:IsPassableAtPoint(position.x, 0, position.z, allowwater) then
				actions = self:GetPointActions(position, item, true, target)
			    end
			end
		    end

		    if (actions == nil or #actions <= 0) and (target == nil or target:HasTag("walkableplatform") or target:HasTag("walkableperipheral")) and self.map:IsPassableAtPoint(position:Get()) then
			actions = self:GetPointSpecialActions(position, useitem, true)
		    end

		    return actions or {}
		end
	    end
	end
    end)
end)