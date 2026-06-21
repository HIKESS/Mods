modimport("cooldown.lua")
local KODI_MODNAME = modname
GLOBAL.KODI_MODNAME = modname
modimport("core/screens/chatinputscreen.lua")
modimport("core/screens/consolescreen.lua")
modimport("core/widgets/textedit.lua")
local KodiTuning = require("kodi_tuning")
local KodiRecipes = require("kodi_recipes")
local KodiStategraphs = require("kodi_stategraphs")
local KodiGamepad = require("kodi_gamepad")
local KodiDemonicEnergy = require("kodi_demonic_energy")
local KodiRPC = require("kodi_rpc")
local KodiTransformModule = require("kodi_transform")
KodiTuning.SetConfigGetter(GetModConfigData)
KodiTuning.Apply(TUNING)
KodiTransformModule.SetDependencies({
    GLOBAL = GLOBAL,
    STRINGS = GLOBAL.STRINGS,
})
KodiStategraphs.SetDependencies({
    GLOBAL = GLOBAL,
    KodiTransformModule = KodiTransformModule,
})
local ShadowDash = require("skills/shadow_dash")
local DayStalker = require("skills/day_stalker")
local NightHunter = require("skills/night_hunter")
local ShadowHands = require("skills/shadow_hands")
local ShadowEruption = require("skills/shadow_eruption")
local ShadowCache = require("skills/shadow_cache")
local ShadowMinion = require("skills/shadow_minion")
local ShadowSummon = require("skills/shadow_summon")
ShadowSummon.MODNAME = modname
local ShadowMinionPool = require("skills/shadow_minion_pool")
ShadowMinionPool.MODNAME = modname
local containers = GLOBAL.require("containers")
containers.params.kodi_shadow_cache = {
    widget = {
        slotpos = {
            GLOBAL.Vector3(-75, 75, 0),
            GLOBAL.Vector3(0, 75, 0),
            GLOBAL.Vector3(75, 75, 0),
            GLOBAL.Vector3(-75, 0, 0),
            GLOBAL.Vector3(0, 0, 0),
            GLOBAL.Vector3(75, 0, 0),
            GLOBAL.Vector3(-75, -75, 0),
            GLOBAL.Vector3(0, -75, 0),
            GLOBAL.Vector3(75, -75, 0),
        },
        animbank = "ui_chest_3x3",
        animbuild = "ui_chest_3x3",
        pos = GLOBAL.Vector3(0, 200, 0),
        side_align_tip = 160,
    },
    numslots = 9,
    type = "chest",
}
NightHunter.OnMarkRemovedCallback = function(player, target)
    if GLOBAL.TheWorld and GLOBAL.TheWorld.ismastersim and player and player.userid then
        SendModRPCToClient(GetClientModRPC(modname, "NightHunterMarkSync"), player.userid, target, false)
    end
end
NightHunter.OnLeapCooldownCallback = function(player, cooldown_duration)
    if GLOBAL.TheWorld and GLOBAL.TheWorld.ismastersim and player and player.userid then
        SendModRPCToClient(GetClientModRPC(modname, "NightHunterLeapCooldownSync"), player.userid, cooldown_duration)
    end
end
local ShadowHands = require("skills/shadow_hands")
ShadowHands.OnCooldownCallback = function(player, cooldown_duration)
    if GLOBAL.TheWorld and GLOBAL.TheWorld.ismastersim and player and player.userid then
        SendModRPCToClient(GetClientModRPC(modname, "ShadowHandsCooldownSync"), player.userid, cooldown_duration)
    end
end
local ShadowMinion = require("skills/shadow_minion")
ShadowMinion.OnMinionPoolLifetimeSyncCallback = function(player)
    if not (GLOBAL.TheWorld and GLOBAL.TheWorld.ismastersim and player and player.userid) then
        return
    end
    if not player._shadow_pool then return end
    local times = {}
    for _, minion in GLOBAL.ipairs(player._shadow_pool.active_minions) do
        if minion:IsValid() and minion._shadow_lifetime_end then
            local remaining = GLOBAL.math.max(0, minion._shadow_lifetime_end - GLOBAL.GetTime())
            if remaining > 0 then
                table.insert(times, GLOBAL.math.ceil(remaining))
            end
        end
    end
    local payload = #times > 0 and table.concat(times, ",") or "0"
    SendModRPCToClient(GetClientModRPC(modname, "ShadowMinionLifetimeSync"), player.userid, payload)
end
PrefabFiles = {
	"kodi",
	"kodi_none",
	"Cursefox",
	"scythe_of_shadows",
	"kodisword",
	"shlemys",
	"whitegem",
	"whiteamulet",
	"fox_wool",
	"bedroll_fox_furry",
	"darkcrystal",
	"kitsune_mask",
	"detection_indicator",
	"mark_indicator",
	"shadow_terrorbeak",
	"shadow_spiderqueen",
	"shadow_merge_cocoon",
	"kodi_shadow_cache",
}
Assets = {
    Asset("ATLAS", "images/inventoryimages/Cursefox.xml"),
    Asset("ATLAS", "images/inventoryimages/scythe_of_shadows.xml"),
    Asset("ATLAS", "images/inventoryimages/kodisword.xml"),
	Asset("ATLAS", "images/inventoryimages/shlemys.xml"),
	Asset("ATLAS", "images/inventoryimages/fox_wool.xml"),
	Asset("ATLAS", "images/inventoryimages/bedroll_fox_furry.xml"),
	Asset("ATLAS", "images/inventoryimages/darkcrystal.xml"),
	Asset("ATLAS", "images/inventoryimages/kitsune_mask.xml"),
    Asset("ATLAS", "images/inventoryimages/whiteamulet.xml"),
    Asset("IMAGE", "images/inventoryimages/whiteamulet.tex"),
    Asset("ATLAS", "images/inventoryimages/whitegem.xml"),
    Asset("IMAGE", "images/inventoryimages/whitegem.tex"),
    Asset( "IMAGE", "images/saveslot_portraits/kodi.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/kodi.xml" ),
    Asset( "IMAGE", "images/selectscreen_portraits/kodi.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/kodi.xml" ),
    Asset( "IMAGE", "images/selectscreen_portraits/kodi_silho.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/kodi_silho.xml" ),
    Asset( "IMAGE", "bigportraits/kodi.tex" ),
    Asset( "ATLAS", "bigportraits/kodi.xml" ),
	Asset( "IMAGE", "images/map_icons/kodi.tex" ),
	Asset( "ATLAS", "images/map_icons/kodi.xml" ),
	Asset( "IMAGE", "images/avatars/avatar_kodi.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_kodi.xml" ),
	Asset( "IMAGE", "images/avatars/avatar_ghost_kodi.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_ghost_kodi.xml" ),
	Asset( "ANIM", "anim/ghost_kodi_build.zip" ),
	Asset( "IMAGE", "images/avatars/self_inspect_kodi.tex" ),
    Asset( "ATLAS", "images/avatars/self_inspect_kodi.xml" ),
	Asset( "IMAGE", "images/names_kodi.tex" ),
    Asset( "ATLAS", "images/names_kodi.xml" ),
	Asset( "IMAGE", "images/kodi_skilltree.tex" ),
	Asset( "ATLAS", "images/kodi_skilltree.xml" ),
	Asset( "IMAGE", "images/kodi_skilltree_icons.tex" ),
	Asset( "ATLAS", "images/kodi_skilltree_icons.xml" ),
	Asset("ANIM", "anim/detection_indicators.zip"),
	Asset("ANIM", "anim/mark.zip"),
}
AddMinimapAtlas("images/map_icons/kodi.xml")
local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS
local KODI_XP_CONFIG = require("kodi_xp_config")
local Ingredient = GLOBAL.Ingredient
local TECH = GLOBAL.TECH
local TUNING = GLOBAL.TUNING
local ACTIONS = GLOBAL.ACTIONS
local Action = GLOBAL.Action
local EQUIPSLOTS = GLOBAL.EQUIPSLOTS
local AllRecipes = GLOBAL.AllRecipes
local GetValidRecipe = GLOBAL.GetValidRecipe
local TheInput = GLOBAL.TheInput
local ThePlayer = GLOBAL.ThePlayer
local IsServer = GLOBAL.TheNet:GetIsServer()
local resolvefilepath = GLOBAL.resolvefilepath
local SkillTreeDefs = require("prefabs/skilltree_defs")
local function CreateKodiSkillTree()
    local BuildSkillsData = require("prefabs/skilltree_kodi")
    if BuildSkillsData then
        local data = BuildSkillsData(SkillTreeDefs.FN)
        if data then
            SkillTreeDefs.CreateSkillTreeFor("kodi", data.SKILLS)
            SkillTreeDefs.SKILLTREE_ORDERS["kodi"] = data.ORDERS
            if SkillTreeDefs.SKILLTREE_METAINFO["kodi"] then
                SkillTreeDefs.SKILLTREE_METAINFO["kodi"].BACKGROUND_SETTINGS = data.BACKGROUND_SETTINGS
            end
            if TUNING.KODI_DEBUG_SKILLTREE then
                local kodi_defs = SkillTreeDefs.SKILLTREE_DEFS["kodi"]
                if kodi_defs then
                    for _, skill_name in ipairs({"kodi_survival_scavenger_1", "kodi_survival_scavenger_2", "kodi_survival_scavenger_3"}) do
                        local skill = kodi_defs[skill_name]
                        if skill then
                            local connects_str = skill.connects and table.concat(skill.connects, ", ") or "NONE"
                        else
                        end
                    end
                else
                end
            end
        end
    end
end
ComponentsFiles = {
	"WorldSanityMonsterSpawner",
	"keyhandler"
}
local SpawnTransformEffects = KodiTransformModule.SpawnEffects
local KodiTransform = KodiTransformModule.Execute
KodiTransformModule.RegisterControls(modname, AddModRPCHandler, GetModConfigData, SendModRPCToServer, MOD_RPC)
AddModRPCHandler(modname, "DayStalkerStealth", function(player)
	if player and player.ToggleDayStalkerStealth then
		player:ToggleDayStalkerStealth()
	end
end)
AddModRPCHandler(modname, "DayStalkerLeap", function(player, target)
	if player and player.DayStalkerLeap and target then
		player:DayStalkerLeap(target)
	end
end)
AddModRPCHandler(modname, "NightHunterLeap", function(player, target)
	if player and player.LeapToMarkedTarget then
		player:LeapToMarkedTarget(target)
	end
end)
AddClientModRPCHandler(modname, "NightHunterLeapCooldownSync", function(cooldown_duration)
	if GLOBAL.ThePlayer and GLOBAL.ThePlayer.SetNightHunterLeapCooldown then
		GLOBAL.ThePlayer:SetNightHunterLeapCooldown(cooldown_duration)
	end
end)
AddClientModRPCHandler(modname, "ShadowEruptionCooldownSync", function(cooldown_duration)
	if GLOBAL.ThePlayer and GLOBAL.ThePlayer.SetShadowEruptionCooldown then
		GLOBAL.ThePlayer:SetShadowEruptionCooldown(cooldown_duration)
	end
end)
AddClientModRPCHandler(modname, "ShadowSummonCooldownSync", function(cooldown_duration)
	if GLOBAL.ThePlayer and GLOBAL.ThePlayer.SetShadowSummonCooldown then
		GLOBAL.ThePlayer:SetShadowSummonCooldown(cooldown_duration)
	end
end)
AddClientModRPCHandler(modname, "ShadowHandsCooldownSync", function(cooldown_duration)
	if GLOBAL.ThePlayer and GLOBAL.ThePlayer.SetShadowHandsCooldown then
		GLOBAL.ThePlayer:SetShadowHandsCooldown(cooldown_duration)
	end
end)
AddClientModRPCHandler(modname, "ShadowMinionLifetimeSync", function(payload)
	if GLOBAL.ThePlayer and GLOBAL.ThePlayer.SetShadowMinionLifetimes then
		GLOBAL.ThePlayer:SetShadowMinionLifetimes(payload)
	end
end)
AddClientModRPCHandler(modname, "NightHunterMarkSync", function(target, is_marked)
	if target and target:IsValid() then
		if is_marked then
			target:AddTag("kodi_marked")
			if GLOBAL.ThePlayer and GLOBAL.ThePlayer.AddNightHunterMark then
				GLOBAL.ThePlayer:AddNightHunterMark()
			end
		else
			target:RemoveTag("kodi_marked")
			if GLOBAL.ThePlayer and GLOBAL.ThePlayer.RemoveNightHunterMark then
				GLOBAL.ThePlayer:RemoveNightHunterMark(1)
			end
		end
	end
end)
AddModRPCHandler(modname, "NightHunterVision", function(player)
	if not player or not player.ToggleNightHunterVision then return end
	player:ToggleNightHunterVision()
end)
AddModRPCHandler(modname, "NightHunterMark", function(player, target)
	if not player or not player.MarkNightHunterTarget or not target then
		return
	end
	local result = player:MarkNightHunterTarget(target)
	if result then
		local is_now_marked = target:HasTag("kodi_marked")
		SendModRPCToClient(GetClientModRPC(modname, "NightHunterMarkSync"), player.userid, target, is_now_marked)
	end
end)
GLOBAL.TheInput:AddKeyDownHandler(GLOBAL.KEY_V, function()
	if not GLOBAL.ThePlayer then return end
	if GLOBAL.ThePlayer.prefab ~= "kodi" then return end
	if GLOBAL.TheFrontEnd:GetActiveScreen() ~= GLOBAL.ThePlayer.HUD then return end
	local is_fox = GLOBAL.ThePlayer:HasTag("NotDemon")
	if is_fox and GLOBAL.ThePlayer:HasTag("kodi_day_stalker") then
		if GLOBAL.TheNet:GetIsServer() then
			if GLOBAL.ThePlayer.ToggleDayStalkerStealth then
				GLOBAL.ThePlayer:ToggleDayStalkerStealth()
			end
		else
			SendModRPCToServer(MOD_RPC[modname]["DayStalkerStealth"])
		end
		return
	end
	if GLOBAL.ThePlayer:HasTag("kodi_night_hunter") then
		if GLOBAL.TheNet:GetIsServer() then
			if GLOBAL.ThePlayer.ToggleNightHunterVision then
				GLOBAL.ThePlayer:ToggleNightHunterVision()
			end
		else
			SendModRPCToServer(MOD_RPC[modname]["NightHunterVision"])
		end
		return
	end
end)
GLOBAL.TheInput:AddMouseButtonHandler(function(button, down, x, y)
	if not down then return end
	if not GLOBAL.ThePlayer then return end
	if GLOBAL.ThePlayer.prefab ~= "kodi" then return end
	local is_middle = (button == 1002) or (button == 2) or (button == 3) or
	                  (GLOBAL.MOUSEBUTTON_MIDDLE and button == GLOBAL.MOUSEBUTTON_MIDDLE)
	if not is_middle then return end
	local has_skill = GLOBAL.ThePlayer:HasTag("kodi_night_hunter")
	local is_fox = GLOBAL.ThePlayer:HasTag("NotDemon")
	if has_skill and is_fox then
		local target = GLOBAL.TheInput:GetWorldEntityUnderMouse()
		if not target then
			return
		end
		if target.prefab and not target:HasTag("player") and not target:HasTag("wall") and not target:HasTag("structure") and not target:HasTag("INLIMBO") then
			SendModRPCToServer(MOD_RPC[modname]["NightHunterMark"], target)
		end
		return
	end
	if GLOBAL.ThePlayer:HasTag("kodi_shadow_hands") and not GLOBAL.ThePlayer:HasTag("NotDemon") then
		local target = GLOBAL.TheInput:GetWorldEntityUnderMouse()
		if target and target:HasTag("_combat") and not target:HasTag("player") then
			if GLOBAL.TheNet:GetIsServer() then
				if GLOBAL.ThePlayer.StartShadowHands then
					GLOBAL.ThePlayer:StartShadowHands(target)
				end
			else
				SendModRPCToServer(MOD_RPC[modname]["ShadowHandsStart"], target)
			end
		end
	end
end)
AddModRPCHandler(modname, "ShadowHandsStart", function(player, target)
	if player and player.StartShadowHands and target then
		player:StartShadowHands(target)
	end
end)
AddModRPCHandler(modname, "ShadowHandsStop", function(player)
	if player and player.StopShadowHands then
		player:StopShadowHands()
	end
end)
AddModRPCHandler(modname, "ShadowEruption", function(player)
	if player and player.UseShadowEruption then
		local result = player:UseShadowEruption()
		if result then
			SendModRPCToClient(GetClientModRPC(modname, "ShadowEruptionCooldownSync"), player.userid, TUNING.KODI_SHADOW_ERUPTION_COOLDOWN)
		end
	end
end)
AddModRPCHandler(modname, "ShadowCache", function(player)
	if player and player.DoOpenShadowCache then
		player:DoOpenShadowCache()
	end
end)
AddModRPCHandler(modname, "ShadowMinion", function(player)
	if player and player.DoRaiseShadowMinion then
		player:DoRaiseShadowMinion()
	end
end)
AddModRPCHandler(modname, "ShadowPoolSync", function(player)
	if player then
		local data = ShadowMinionPool.SerializeForClient(player)
		SendModRPCToClient(GLOBAL.CLIENT_MOD_RPC[modname]["ShadowPoolData"], player.userid, data)
	end
end)
AddModRPCHandler(modname, "ShadowPoolSummon", function(player, creature_id)
	if player and creature_id then
		ShadowMinionPool.TrySummon(player, creature_id)
		local data = ShadowMinionPool.SerializeForClient(player)
		SendModRPCToClient(GLOBAL.CLIENT_MOD_RPC[modname]["ShadowPoolData"], player.userid, data)
	end
end)
AddModRPCHandler(modname, "ShadowPoolFavorite", function(player, creature_id)
	if player and creature_id then
		ShadowMinionPool.ToggleFavorite(player, creature_id)
		local data = ShadowMinionPool.SerializeForClient(player)
		SendModRPCToClient(GLOBAL.CLIENT_MOD_RPC[modname]["ShadowPoolData"], player.userid, data)
	end
end)
AddClientModRPCHandler(modname, "ShadowPoolData", function(data)
	if GLOBAL.ThePlayer then
		ShadowMinionPool.DeserializeOnClient(GLOBAL.ThePlayer, data)
		if GLOBAL.ThePlayer._shadow_minion_menu and GLOBAL.ThePlayer._shadow_minion_menu:IsOpen() then
			GLOBAL.ThePlayer._shadow_minion_menu:RefreshCreatureList()
		end
	end
end)
AddModRPCHandler(modname, "ShadowSummon", function(player)
	if player and player.ShadowSummonToggle then
		player:ShadowSummonToggle()
	end
end)
GLOBAL.TheInput:AddMouseButtonHandler(function(button, down, x, y)
	if not down then return end
	if button ~= GLOBAL.MOUSEBUTTON_RIGHT then return end
	if not GLOBAL.ThePlayer then return end
	if GLOBAL.ThePlayer.prefab ~= "kodi" then return end
	if not GLOBAL.ThePlayer:HasTag("kodi_shadow_hands") then return end
	if not GLOBAL.ThePlayer:HasTag("kodi_channeling") then return end
	if GLOBAL.TheNet:GetIsServer() then
		if GLOBAL.ThePlayer.StopShadowHands then
			GLOBAL.ThePlayer:StopShadowHands()
		end
	else
		SendModRPCToServer(MOD_RPC[modname]["ShadowHandsStop"])
	end
end)
GLOBAL.TheInput:AddKeyDownHandler(GLOBAL.KEY_G, function()
	if not GLOBAL.ThePlayer then return end
	if GLOBAL.ThePlayer.prefab ~= "kodi" then return end
	if GLOBAL.TheFrontEnd:GetActiveScreen() ~= GLOBAL.ThePlayer.HUD then return end
	if not GLOBAL.ThePlayer:HasTag("kodi_shadow_eruption") then return end
	if GLOBAL.ThePlayer:HasTag("NotDemon") then return end
	if GLOBAL.ThePlayer._kodi_eruption_cd_end then
		local now = GLOBAL.GetTime()
		if now < GLOBAL.ThePlayer._kodi_eruption_cd_end then
			return
		end
	end
	if GLOBAL.TheNet:GetIsServer() then
		if GLOBAL.ThePlayer.UseShadowEruption then
			local result = GLOBAL.ThePlayer:UseShadowEruption()
			if result then
				GLOBAL.ThePlayer._kodi_eruption_cd_end = GLOBAL.GetTime() + TUNING.KODI_SHADOW_ERUPTION_COOLDOWN
			end
		end
	else
		SendModRPCToServer(MOD_RPC[modname]["ShadowEruption"])
	end
end)
GLOBAL.TheInput:AddKeyDownHandler(GLOBAL.KEY_J, function()
	if not GLOBAL.ThePlayer then return end
	if GLOBAL.ThePlayer.prefab ~= "kodi" then return end
	if GLOBAL.TheFrontEnd:GetActiveScreen() ~= GLOBAL.ThePlayer.HUD then return end
	if GLOBAL.ThePlayer:HasTag("kodi_shadow_summon") then
		if GLOBAL.TheNet:GetIsServer() then
			if GLOBAL.ThePlayer.ShadowSummonToggle then
				GLOBAL.ThePlayer:ShadowSummonToggle()
			end
		else
			SendModRPCToServer(MOD_RPC[modname]["ShadowSummon"])
		end
	end
end)
GLOBAL.TheInput:AddKeyDownHandler(GLOBAL.KEY_H, function()
	if not GLOBAL.ThePlayer then return end
	if GLOBAL.ThePlayer.prefab ~= "kodi" then return end
	if GLOBAL.TheFrontEnd:GetActiveScreen() ~= GLOBAL.ThePlayer.HUD then return end
	if GLOBAL.ThePlayer:HasTag("kodi_shadow_cache") then
		if GLOBAL.TheNet:GetIsServer() then
			if GLOBAL.ThePlayer.DoOpenShadowCache then
				GLOBAL.ThePlayer:DoOpenShadowCache()
			end
		else
			SendModRPCToServer(MOD_RPC[modname]["ShadowCache"])
		end
		return
	end
	if GLOBAL.ThePlayer:HasTag("kodi_shadow_minion") then
		if GLOBAL.ThePlayer._shadow_minion_menu then
			GLOBAL.ThePlayer._shadow_minion_menu:Toggle()
		end
		return
	end
end)
GLOBAL.TheInput:AddKeyDownHandler(GLOBAL.KEY_K, function()
	if not GLOBAL.ThePlayer then return end
	if GLOBAL.ThePlayer.prefab ~= "kodi" then return end
	if GLOBAL.TheFrontEnd:GetActiveScreen() ~= GLOBAL.ThePlayer.HUD then return end
	if not GLOBAL.ThePlayer:HasTag("kodi_shadow_minion") then return end
	if GLOBAL.ThePlayer._shadow_minion_menu and GLOBAL.ThePlayer._shadow_minion_menu:IsOpen() then
		GLOBAL.ThePlayer._shadow_minion_menu:OnSummonClicked()
		return
	end
	if GLOBAL.ThePlayer._shadow_minion_menu then
		GLOBAL.ThePlayer._shadow_minion_menu:TrySummonFavorite()
	end
end)
AddModRPCHandler(modname, "ShadowDashToPos", function(player, target_x, target_z)
	if player and target_x and target_z then
		ShadowDash.Execute(player, target_x, target_z)
	end
end)
AddModRPCHandler(modname, "ShadowDashDirection", function(player, dir_x, dir_z, distance)
	if player and dir_x and dir_z and distance then
		local px, py, pz = player.Transform:GetWorldPosition()
		local target_x = px + dir_x * distance
		local target_z = pz + dir_z * distance
		ShadowDash.Execute(player, target_x, target_z)
	end
end)
local SHADOW_DASH_ACTION = ShadowDash.CreateAction()
AddAction(SHADOW_DASH_ACTION)
GLOBAL.STRINGS.ACTIONS.SHADOW_DASH = "Shadow Dash"
local shadow_dash_state = ShadowDash.CreateStategraphState(KODI_MODNAME)
AddStategraphState("wilson", shadow_dash_state)
AddStategraphState("wilson_client", shadow_dash_state)
AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.SHADOW_DASH, "shadow_dash"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.SHADOW_DASH, "shadow_dash"))
local SHADOW_DASH_PURPLE_TINT = ShadowDash.PURPLE_TINT
local LEAP_ABILITIES = {}
local function AddLeapAbility(action, canFn)
	table.insert(LEAP_ABILITIES, { action = action, canFn = canFn })
end
local DAY_STALKER_LEAP_ACTION = DayStalker.CreateLeapAction()
AddAction(DAY_STALKER_LEAP_ACTION)
GLOBAL.STRINGS.ACTIONS.DAY_STALKER_LEAP = "Jump"
AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.DAY_STALKER_LEAP, "doshortaction"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.DAY_STALKER_LEAP, "doshortaction"))
AddLeapAbility(GLOBAL.ACTIONS.DAY_STALKER_LEAP, DayStalker.CanLeap)
local KODI_HIDE_ACTION = DayStalker.CreateHideAction()
AddAction(KODI_HIDE_ACTION)
GLOBAL.STRINGS.ACTIONS.KODI_HIDE = TUNING.KODI_LANGUAGE == "ENGLISH" and "Hide" or "Сховатись"
local kodi_hide_state = DayStalker.CreateHideState()
AddStategraphState("wilson", kodi_hide_state)
AddStategraphState("wilson_client", kodi_hide_state)
AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.KODI_HIDE, "kodi_hide"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.KODI_HIDE, "kodi_hide"))
local kodi_shadow_cache_open_state = ShadowCache.CreateOpenState()
AddStategraphState("wilson", kodi_shadow_cache_open_state)
AddStategraphState("wilson_client", kodi_shadow_cache_open_state)
AddComponentAction("SCENE", "inspectable", function(inst, doer, actions, right)
	if right and DayStalker.CanHide(doer, inst) then
		table.insert(actions, GLOBAL.ACTIONS.KODI_HIDE)
	end
end)
local NIGHT_HUNTER_LEAP_ACTION = NightHunter.CreateLeapAction()
AddAction(NIGHT_HUNTER_LEAP_ACTION)
GLOBAL.STRINGS.ACTIONS.NIGHT_HUNTER_LEAP = "Hunt"
AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.NIGHT_HUNTER_LEAP, "doshortaction"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.NIGHT_HUNTER_LEAP, "doshortaction"))
AddLeapAbility(GLOBAL.ACTIONS.NIGHT_HUNTER_LEAP, NightHunter.CanLeap)
AddComponentAction("SCENE", "combat", function(inst, doer, actions, right)
	if right and doer.prefab == "kodi" then
		for _, ability in GLOBAL.ipairs(LEAP_ABILITIES) do
			if ability.canFn(doer, inst) then
				table.insert(actions, ability.action)
			end
		end
	end
end)
AddComponentAction("SCENE", "health", function(inst, doer, actions, right)
	if right and not inst:HasTag("player") and doer.prefab == "kodi" then
		for _, ability in GLOBAL.ipairs(LEAP_ABILITIES) do
			if ability.canFn(doer, inst) then
				local dominated = false
				for _, existing in GLOBAL.ipairs(actions) do
					if existing == ability.action then
						dominated = true
						break
					end
				end
				if not dominated then
					table.insert(actions, ability.action)
				end
			end
		end
	end
end)
KodiStategraphs.Register(AddStategraphState)
KodiGamepad.SetDependencies({
    GLOBAL = GLOBAL,
    TheInput = TheInput,
    TUNING = TUNING,
    KodiTransform = KodiTransformModule.Execute,
    SendModRPCToServer = SendModRPCToServer,
    MOD_RPC = MOD_RPC,
    KODI_MODNAME = KODI_MODNAME,
})
KodiGamepad.Register()
local function IsPlayerGhost(inst)
    if inst:HasTag("playerghost") then return true end
    local bank = inst.AnimState:GetCurrentBankName()
    if bank == "ghost" then return true end
    local build = inst.AnimState:GetBuild()
    if build and string.find(build, "ghost") then return true end
    return false
end
GLOBAL.Kodi_IsPlayerGhost = IsPlayerGhost
function featherpostinit(inst)
    inst.Reset_pre = inst.Reset
    inst.Reset = function(self)
        if self.inst.prefab == "kodi" then
            if IsPlayerGhost(self.inst) then
                self:Reset_pre()
                return
            end
            local current_stage_found = nil
            for day = self.daysgrowth, 0, -1 do
                local cb = self.callbacks[day]
                if cb then
                    if current_stage_found then
                        cb()
                        self.daysgrowth = day
                        break
                    else
                        current_stage_found = true
                    end
                else
                    self.daysgrowth = 0
                    self.bits = 0
                    if not IsPlayerGhost(self.inst) then
                        local build_to_set = self.inst:HasTag("NotDemon") and "kodi" or "demon"
                        self.inst.AnimState:SetBuild(build_to_set)
                    end
                end
            end
        else
            self:Reset_pre()
        end
    end
end
AddComponentPostInit("beard", featherpostinit)
local KODI_HEAVY_LIFT_SPEEDMULT = 0.60
local function BypassHeavyItemSpeed(inst)
	local body = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
	if body and body:HasTag("heavy") and body.components.equippable then
		body._kodi_orig_wsm = body.components.equippable.walkspeedmult
		body.components.equippable.walkspeedmult = KODI_HEAVY_LIFT_SPEEDMULT
	end
end
local function RestoreHeavyItemSpeed(inst)
	local body = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
	if body and body._kodi_orig_wsm and body.components.equippable then
		body.components.equippable.walkspeedmult = body._kodi_orig_wsm
		body._kodi_orig_wsm = nil
	end
end
local SkillTreeData = require("skilltreedata")
local function GetPointsForSkillXP_WithThresholds(skillxp, thresholds)
    local totalxp = 0
    for skillcount, xpthreshold in ipairs(thresholds) do
        totalxp = totalxp + xpthreshold
        if skillxp < totalxp then
            return skillcount - 1
        end
    end
    return #thresholds
end
local _oldValidateCharacterData = SkillTreeData.ValidateCharacterData
function SkillTreeData:ValidateCharacterData(characterprefab, activatedskills, skillxp)
    if characterprefab == "kodi" then
        if skillxp == nil or skillxp < 0 then
            return false
        end
        local maxpointsallocatable = GetPointsForSkillXP_WithThresholds(skillxp, TUNING.KODI_SKILL_THRESHOLDS)
        local allocatedskills = activatedskills and table.count(activatedskills) or 0
        if allocatedskills > maxpointsallocatable then
            return false
        end
        local skilltree = SkillTreeDefs.SKILLTREE_DEFS[characterprefab]
        if skilltree and activatedskills then
            for skill, _ in pairs(activatedskills) do
                local skilldef = skilltree[skill]
                if skilldef then
                    if skilldef.must_have_one_of then
                        local has_one_of = false
                        for must_have_skillname, _ in pairs(skilldef.must_have_one_of) do
                            local must_have_skilldef = skilltree[must_have_skillname]
                            local has_skill = activatedskills[must_have_skillname] ~= nil
                            local has_unlocked_lock = must_have_skilldef and must_have_skilldef.lock_open ~= nil
                                and must_have_skilldef.lock_open(characterprefab, activatedskills, true)
                            if has_skill or has_unlocked_lock then
                                has_one_of = true
                                break
                            end
                        end
                        if not has_one_of then
                            return false
                        end
                    end
                    if skilldef.must_have_all_of then
                        for must_have_skillname, _ in pairs(skilldef.must_have_all_of) do
                            local must_have_skilldef = skilltree[must_have_skillname]
                            local has_skill = activatedskills[must_have_skillname] ~= nil
                            local has_unlocked_lock = must_have_skilldef and must_have_skilldef.lock_open ~= nil
                                and must_have_skilldef.lock_open(characterprefab, activatedskills, true)
                            if not (has_skill or has_unlocked_lock) then
                                return false
                            end
                        end
                    end
                end
            end
        end
        return true
    else
        return _oldValidateCharacterData(self, characterprefab, activatedskills, skillxp)
    end
end
local _oldGetAvailableSkillPoints = SkillTreeData.GetAvailableSkillPoints
function SkillTreeData:GetAvailableSkillPoints(characterprefab)
    if characterprefab == "kodi" then
        local total = 0
        local skills = self.activatedskills[characterprefab]
        if skills then
            for k, v in pairs(skills) do
                total = total + 1
            end
        end
        return GetPointsForSkillXP_WithThresholds(self:GetSkillXP(characterprefab), TUNING.KODI_SKILL_THRESHOLDS) - total
    else
        return _oldGetAvailableSkillPoints(self, characterprefab)
    end
end
local _oldGetMaximumExperiencePoints = SkillTreeData.GetMaximumExperiencePoints
function SkillTreeData:GetMaximumExperiencePoints(characterprefab)
    if characterprefab == "kodi" then
        local totalxp = 0
        for _, xpthreshold in ipairs(TUNING.KODI_SKILL_THRESHOLDS) do
            totalxp = totalxp + xpthreshold
        end
        return totalxp
    end
    return _oldGetMaximumExperiencePoints(self, characterprefab)
end
if TUNING.KODI_LANGUAGE == "UKRAINIAN" then
	modimport("scripts/strings_kodi_ua.lua")
	STRINGS.CHARACTERS.KODI = require "speech_kodi_ua"
else
	modimport("scripts/strings_kodi.lua")
	STRINGS.CHARACTERS.KODI = require "speech_kodi_en"
end
KodiRecipes.Register(AddCharacterRecipe, Ingredient, TECH)
function whiteamuletpostinit(inst)
    if IsServer then
        inst.components.equippable.equipslot = GLOBAL.EQUIPSLOTS.NECK or GLOBAL.EQUIPSLOTS.BODY
    end
end
AddPrefabPostInit("whiteamulet", whiteamuletpostinit)	
local skin_modes = {
    {
        type = "ghost_skin",
        anim_bank = "ghost",
        idle_anim = "idle",
        scale = 0.75,
        offset = { 0, -25 }
    },
}
AddModCharacter("kodi", "MALE", skin_modes)
local function InitDemonicEnergyNetvar(inst)
	inst._demonic_percent_net = GLOBAL.net_byte(inst.GUID, "kodi.demonic_percent", "demonic_percent_dirty")
	inst._demonic_percent_net:set(0)
	function inst:GetDemonicPercent()
		return (self._demonic_percent_net:value() or 0) / 100
	end
end
local function InitDemonicEnergyClient(inst)
	inst:ListenForEvent("demonic_percent_dirty", function()
		inst:PushEvent("demonic_energy_changed", {percent = inst:GetDemonicPercent()})
	end)
	inst._kodi_eruption_cd_end = nil
	function inst:GetShadowEruptionCooldown()
		if not self._kodi_eruption_cd_end then return 0 end
		local remaining = self._kodi_eruption_cd_end - GLOBAL.GetTime()
		return math.max(0, remaining)
	end
	function inst:SetShadowEruptionCooldown(duration)
		self._kodi_eruption_cd_end = GLOBAL.GetTime() + duration
	end
	function inst:GetDayStalkerFadeRemaining()
		local in_stealth = self:HasTag("kodi_stealth")
		local is_hiding = self:HasTag("kodi_hiding")
		if not in_stealth and not is_hiding then
			return -1
		end
		if self:HasTag("kodi_pounce_ready") then
			return 0
		end
		if not self._day_stalker_fade_start_time then
			return TUNING.KODI_DAY_STALKER_FADE_TIME or 3.0
		end
		local elapsed = GLOBAL.GetTime() - self._day_stalker_fade_start_time
		return math.max(0, (TUNING.KODI_DAY_STALKER_FADE_TIME or 3.0) - elapsed)
	end
	function inst:GetHideTimeRemaining()
		if not self:HasTag("kodi_hiding") then
			return -1
		end
		if not self._kodi_hide_start_time then
			return 20
		end
		local elapsed = GLOBAL.GetTime() - self._kodi_hide_start_time
		return math.max(0, 20 - elapsed)
	end
	inst._night_hunter_leap_cd_end = 0
	inst._night_hunter_mark_times = {}
	inst._night_hunter_mark_count = 0
	function inst:GetNightHunterLeapCooldown()
		local remaining = (self._night_hunter_leap_cd_end or 0) - GLOBAL.GetTime()
		return math.max(0, remaining)
	end
	inst._shadow_summon_cd_end = 0
	function inst:GetShadowSummonCooldown()
		local remaining = (self._shadow_summon_cd_end or 0) - GLOBAL.GetTime()
		return math.max(0, remaining)
	end
	function inst:SetShadowSummonCooldown(duration)
		self._shadow_summon_cd_end = GLOBAL.GetTime() + duration
	end
	inst._shadow_hands_cd_end = 0
	function inst:GetShadowHandsCooldown()
		local remaining = (self._shadow_hands_cd_end or 0) - GLOBAL.GetTime()
		return math.max(0, remaining)
	end
	function inst:SetShadowHandsCooldown(duration)
		self._shadow_hands_cd_end = GLOBAL.GetTime() + duration
	end
	inst._shadow_minion_lifetime_ends = {}
	function inst:SetShadowMinionLifetimes(payload)
		self._shadow_minion_lifetime_ends = {}
		if not payload or payload == "0" or payload == "" then
			return
		end
		for time_str in payload:gmatch("[^,]+") do
			local t = GLOBAL.tonumber(time_str)
			if t and t > 0 then
				table.insert(self._shadow_minion_lifetime_ends, GLOBAL.GetTime() + t)
			end
		end
	end
	function inst:GetShadowMinionTimesRemaining()
		local results = {}
		local now = GLOBAL.GetTime()
		for _, end_time in GLOBAL.ipairs(self._shadow_minion_lifetime_ends or {}) do
			local remaining = end_time - now
			if remaining > 0 then
				table.insert(results, remaining)
			end
		end
		return results
	end
	function inst:GetShadowMinionTimeRemaining()
		local times = self:GetShadowMinionTimesRemaining()
		if #times > 0 then
			return times[1]
		end
		return -1
	end
	function inst:GetNightHunterMarkTimeRemainingByIndex(index)
		if not self._night_hunter_mark_times or not self._night_hunter_mark_times[index] then
			return -1
		end
		local elapsed = GLOBAL.GetTime() - self._night_hunter_mark_times[index]
		return math.max(0, 30 - elapsed)
	end
	function inst:GetNightHunterMarkCount()
		return self._night_hunter_mark_count or 0
	end
	function inst:SetNightHunterLeapCooldown(duration)
		self._night_hunter_leap_cd_end = GLOBAL.GetTime() + duration
	end
	function inst:SetNightHunterMarkInfo(count, mark_times_data)
		self._night_hunter_mark_count = count
		if mark_times_data then
			self._night_hunter_mark_times = mark_times_data
		elseif count == 0 then
			self._night_hunter_mark_times = {}
		end
	end
	function inst:AddNightHunterMark()
		self._night_hunter_mark_count = (self._night_hunter_mark_count or 0) + 1
		if not self._night_hunter_mark_times then
			self._night_hunter_mark_times = {}
		end
		table.insert(self._night_hunter_mark_times, GLOBAL.GetTime())
	end
	function inst:RemoveNightHunterMark(index)
		self._night_hunter_mark_count = math.max(0, (self._night_hunter_mark_count or 0) - 1)
		if self._night_hunter_mark_times and index then
			table.remove(self._night_hunter_mark_times, index)
		end
	end
	function inst:ClearNightHunterMarksUI()
		self._night_hunter_mark_count = 0
		self._night_hunter_mark_times = {}
	end
	local NIGHT_VISION_COLOURCUBES = {
		day = "images/colour_cubes/day05_cc.tex",
		dusk = "images/colour_cubes/purple_moon_cc.tex",
		night = "images/colour_cubes/purple_moon_cc.tex",
		full_moon = "images/colour_cubes/purple_moon_cc.tex",
	}
	inst._night_hunter_vision_active = false
	local function UpdateNightVisionClient(player)
		if not player.components.playervision then return end
		local should_be_active = player:HasTag("kodi_night_vision_on")
		if should_be_active then
			if not player._night_hunter_vision_active then
				player.components.playervision:ForceNightVision(true)
				player.components.playervision:SetCustomCCTable(NIGHT_VISION_COLOURCUBES)
				player._night_hunter_vision_active = true
			end
		else
			if player._night_hunter_vision_active then
				player.components.playervision:ForceNightVision(false)
				player.components.playervision:SetCustomCCTable(nil)
				player._night_hunter_vision_active = false
			end
		end
	end
	inst:DoPeriodicTask(0.5, function() UpdateNightVisionClient(inst) end)
	inst:DoTaskInTime(0, function() UpdateNightVisionClient(inst) end)
	inst:DoTaskInTime(1, function() UpdateNightVisionClient(inst) end)
	inst:ListenForEvent("ms_respawnedfromghost", function()
		inst:DoTaskInTime(0.5, function() UpdateNightVisionClient(inst) end)
	end)
end
local function InitDemonicEnergyServer(inst)
	if inst.components.experiencecollector then
		inst:RemoveComponent("experiencecollector")
	end
	inst.demonic_energy = 0
	inst.demonic_drain_task = nil
	function inst:UpdateDemonicNetvar()
		if self._demonic_percent_net then
			local percent = math.floor((self.demonic_energy or 0) / TUNING.KODI_DEMONIC_MAX * 100)
			percent = math.max(0, math.min(100, percent))
			self._demonic_percent_net:set(percent)
		end
	end
	function inst:AddDemonicEnergy(amount)
		local old = self.demonic_energy or 0
		local sanity_mult = 1
		if self.components.sanity then
			local sanity_pct = self.components.sanity:GetPercent()
			sanity_mult = 1 + (1 - sanity_pct) * 0.5
		end
		local final_amount = amount * sanity_mult
		self.demonic_energy = math.min(TUNING.KODI_DEMONIC_MAX, old + final_amount)
		self:UpdateDemonicNetvar()
		self:PushEvent("demonic_energy_changed", {percent = self:GetDemonicPercent(), old = old, new = self.demonic_energy})
		if old < TUNING.KODI_DEMONIC_MAX and self.demonic_energy >= TUNING.KODI_DEMONIC_MAX then
			self.components.talker:Say(GLOBAL.STRINGS.KODI_SPEECH.POWER_READY, 2.5, true)
		end
	end
	function inst:CanTransform()
		return (self.demonic_energy or 0) >= TUNING.KODI_DEMONIC_MAX
	end
	function inst:StartDemonicDrain()
		self:StopDemonicDrain()
		self.demonic_drain_task = self:DoPeriodicTask(0.1, function()
			if self.demonic_energy and self.demonic_energy > 0 then
				local drain_reduction = 0
				if self.GetProgressiveDrainReduction then
					drain_reduction = self:GetProgressiveDrainReduction()
				end
				local drain_amount = TUNING.KODI_DEMONIC_DRAIN_RATE * 0.1 * (1 - drain_reduction)
				if self._shadow_summon_extra_drain then
					drain_amount = drain_amount * 1.5
				end
				self.demonic_energy = math.max(0, self.demonic_energy - drain_amount)
				self:UpdateDemonicNetvar()
				self:PushEvent("demonic_energy_changed", {percent = self:GetDemonicPercent()})
			end
			if (self.demonic_energy or 0) <= 0 and not self:HasTag("NotDemon") then
				KodiTransform(self)
			end
		end)
	end
	function inst:StopDemonicDrain()
		if self.demonic_drain_task then
			self.demonic_drain_task:Cancel()
			self.demonic_drain_task = nil
		end
	end
	inst.fear_aura_task = nil
	local FEAR_RADIUS = 12
	local FEAR_TAGS = {"prey", "rabbit", "bird", "butterfly", "catcoon", "babybeefalo"}
	local FEAR_EXCLUDE = {
		"player", "monster", "epic", "companion", "abigail",
		"hostile", "killer", "bee", "killerbee", "frog", "mosquito",
		"spider", "hound", "tentacle", "leif", "merm", "pigguard",
		"bunnyman", "rocky", "tallbird", "walrus", "penguin",
		"warg", "koalefant", "beefalo", "hostile_mob"
	}
	function inst:StartFearAura()
		self:StopFearAura()
		self.fear_aura_task = self:DoPeriodicTask(0.5, function()
			if self:HasTag("NotDemon") then
				self:StopFearAura()
				return
			end
			local x, y, z = self.Transform:GetWorldPosition()
			local creatures = GLOBAL.TheSim:FindEntities(x, y, z, FEAR_RADIUS, nil, FEAR_EXCLUDE, FEAR_TAGS)
			for _, creature in ipairs(creatures) do
				if creature and creature:IsValid() and creature.components.locomotor then
					if creature.components.hauntable and creature.components.hauntable.panicable then
						creature.components.hauntable:Panic(3)
					elseif creature.brain and creature.brain.GetCurrentBehaviour and creature.brain:GetCurrentBehaviour() then
						local angle = creature:GetAngleToPoint(x, y, z) + 180
						local rad = angle * GLOBAL.DEGREES
						local dist = 8 + math.random() * 4
						if creature.components.locomotor then
							creature.components.locomotor:RunInDirection(angle)
						end
					end
					if creature.sg and creature:HasTag("bird") then
						local current_state_name = creature.sg.currentstate and creature.sg.currentstate.name
						if not current_state_name or (current_state_name ~= "flyaway" and current_state_name ~= "glide" and current_state_name ~= "land") then
							if creature.sg.HasState and creature.sg:HasState("flyaway") then
								creature.sg:GoToState("flyaway")
							end
						end
					end
				end
			end
		end)
	end
	function inst:StopFearAura()
		if self.fear_aura_task then
			self.fear_aura_task:Cancel()
			self.fear_aura_task = nil
		end
	end
	inst._night_vision_light = nil
	function inst:StartNightVision()
		self:StopNightVision()
		self._night_vision_light = GLOBAL.SpawnPrefab("minerhatlight")
		if self._night_vision_light then
			self._night_vision_light.entity:SetParent(self.entity)
			if self._night_vision_light.Light then
				self._night_vision_light.Light:SetRadius(6)
				self._night_vision_light.Light:SetFalloff(0.7)
				self._night_vision_light.Light:SetIntensity(0.6)
				self._night_vision_light.Light:SetColour(100/255, 0/255, 150/255)
			end
		end
		if self.components.playerlightningtarget then
			self._old_lightning_target = self.components.playerlightningtarget
		end
		self:AddTag("nightvision")
	end
	function inst:StopNightVision()
		if self._night_vision_light then
			self._night_vision_light:Remove()
			self._night_vision_light = nil
		end
		self:RemoveTag("nightvision")
	end
	inst._shadow_strike_ready = false
	local SHADOW_STRIKE_MULT = 2.0
	function inst:EnableShadowStrike()
		self._shadow_strike_ready = true
		self:AddTag("shadow_strike_ready")
	end
	function inst:DisableShadowStrike()
		self._shadow_strike_ready = false
		self:RemoveTag("shadow_strike_ready")
	end
	inst._old_temp_settings = nil
	function inst:StartTemperatureImmunity()
		if self.components.temperature then
			self._old_temp_settings = {
				inherentinsulation = self.components.temperature.inherentinsulation,
				inherentsummerinsulation = self.components.temperature.inherentsummerinsulation,
				overheattemp = self.components.temperature.overheattemp,
				freezetemp = self.components.temperature.freezetemp or 0,
			}
			self.components.temperature.inherentinsulation = 999
			self.components.temperature.inherentsummerinsulation = 999
			self.components.temperature.overheattemp = 999
			self:AddTag("temperature_immune")
		end
	end
	function inst:StopTemperatureImmunity()
		if self.components.temperature and self._old_temp_settings then
			self.components.temperature.inherentinsulation = self._old_temp_settings.inherentinsulation
			self.components.temperature.inherentsummerinsulation = self._old_temp_settings.inherentsummerinsulation
			self.components.temperature.overheattemp = self._old_temp_settings.overheattemp
			self._old_temp_settings = nil
			self:RemoveTag("temperature_immune")
		end
	end
	inst._demon_penalty_task = nil
	local DEMON_SANITY_AURA_RADIUS = 10
	local DEMON_SANITY_AURA_DRAIN = -0.5
	local function IsWearingKitsuneMask(player)
		if player.components.inventory then
			local hat = player.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HEAD)
			if hat and hat.prefab == "kitsune_mask" then
				return true
			end
		end
		return false
	end
	local function GetDynamicSanityDrain(player)
		local energy_percent = player:GetDemonicPercent() or 0
		if energy_percent > 0.75 then
			return -0.5
		elseif energy_percent > 0.25 then
			return -1.0
		else
			return -1.5
		end
	end
	function inst:StartDemonPenalties()
		self:StopDemonPenalties()
		self._old_healing_mult = 1
		self._demon_penalty_task = self:DoPeriodicTask(1, function()
			if self:HasTag("NotDemon") then
				self:StopDemonPenalties()
				return
			end
			if self.components.sanity then
				if self:HasTag("kodi_demon_mastery") then
				elseif IsWearingKitsuneMask(self) then
				else
					local drain = GetDynamicSanityDrain(self)
					self.components.sanity:DoDelta(drain)
				end
			end
			local x, y, z = self.Transform:GetWorldPosition()
			local players_nearby = GLOBAL.TheSim:FindEntities(x, y, z, DEMON_SANITY_AURA_RADIUS, {"player"}, {"playerghost"})
			for _, player in ipairs(players_nearby) do
				if player ~= self and player.components.sanity then
					player.components.sanity:DoDelta(DEMON_SANITY_AURA_DRAIN)
				end
			end
			local pigs_nearby = GLOBAL.TheSim:FindEntities(x, y, z, 15, nil, {"player"}, {"pig", "bunnyman"})
			for _, pig in ipairs(pigs_nearby) do
				if pig.components.combat and not pig:HasTag("werepig") then
					if pig.components.combat.target ~= self then
						pig.components.combat:SetTarget(self)
					end
				end
			end
		end)
		if self.components.eater and self._kodi_demon_healabsorb_saved == nil then
			self._kodi_demon_healabsorb_saved = self.components.eater.healthabsorption or 1
			self.components.eater.healthabsorption = self._kodi_demon_healabsorb_saved * 0.7
		end
	end
	function inst:StopDemonPenalties()
		if self._demon_penalty_task then
			self._demon_penalty_task:Cancel()
			self._demon_penalty_task = nil
		end
		if self.components.eater and self._kodi_demon_healabsorb_saved ~= nil then
			self.components.eater.healthabsorption = self._kodi_demon_healabsorb_saved
			self._kodi_demon_healabsorb_saved = nil
		end
	end
	inst.demon_time_total = 0
	inst._demon_time_task = nil
	local PROG_TIER1 = 600
	local PROG_TIER2 = 1800
	local PROG_TIER3 = 3600
	function inst:GetProgressiveTier()
		if self.demon_time_total >= PROG_TIER3 then
			return 3
		elseif self.demon_time_total >= PROG_TIER2 then
			return 2
		elseif self.demon_time_total >= PROG_TIER1 then
			return 1
		end
		return 0
	end
	function inst:GetProgressiveDamageBonus()
		local bonus = self:GetProgressiveTier() * 0.05
		if self:HasTag("kodi_damage_1") then
			bonus = bonus + 0.10
		end
		if self:HasTag("kodi_damage_2") then
			bonus = bonus + 0.15
		end
		return bonus
	end
	function inst:GetProgressiveDrainReduction()
		local reduction = 0
		if self:GetProgressiveTier() >= 2 then
			reduction = 0.1
		end
		if self:HasTag("kodi_duration_1") then
			reduction = reduction + 0.10
		end
		if self:HasTag("kodi_duration_2") then
			reduction = reduction + 0.20
		end
		if self:HasTag("kodi_duration_3") then
			reduction = reduction + 0.30
		end
		return reduction
	end
	function inst:GetProgressiveDashBonus()
		local bonus = 0
		if self:GetProgressiveTier() >= 3 then
			bonus = 3
		end
		if self:HasTag("kodi_dash_1") then
			bonus = bonus + 2
		end
		return bonus
	end
	function inst:GetDashCooldownReduction()
		if self:HasTag("kodi_dash_2") then
			return 0.25
		end
		return 0
	end
	function inst:StartProgressiveTracking()
		self:StopProgressiveTracking()
		self._demon_time_task = self:DoPeriodicTask(1, function()
			if not self:HasTag("NotDemon") then
				local old_tier = self:GetProgressiveTier()
				self.demon_time_total = self.demon_time_total + 1
				local new_tier = self:GetProgressiveTier()
				if new_tier > old_tier then
					if new_tier == 1 then
						self.components.talker:Say(GLOBAL.STRINGS.KODI_SPEECH.DEMON_STRONGER, 3, true)
					elseif new_tier == 2 then
						self.components.talker:Say(GLOBAL.STRINGS.KODI_SPEECH.DEMON_SUSTAIN, 3, true)
					elseif new_tier == 3 then
						self.components.talker:Say(GLOBAL.STRINGS.KODI_SPEECH.DEMON_DASH_MASTER, 3, true)
					end
					self.SoundEmitter:PlaySound("dontstarve/common/ghost_spawn")
				end
			end
		end)
	end
	function inst:StopProgressiveTracking()
		if self._demon_time_task then
			self._demon_time_task:Cancel()
			self._demon_time_task = nil
		end
	end
	function inst:RefreshDemonBonuses()
		if self:HasTag("NotDemon") then
			return
		end
		local bonus = self:GetProgressiveDamageBonus()
		self.components.combat.damagemultiplier = TUNING.KODI_DAMAGETRANSFORM * (1 + bonus)
	end
	local old_onsave = inst.OnSave
	inst.OnSave = function(inst, data)
		if old_onsave then old_onsave(inst, data) end
		data.demon_time_total = inst.demon_time_total
		data.demonic_energy = inst.demonic_energy
		data.last_stand_ready = inst._last_stand_ready
		if inst._shadow_summon_cooldown then
			local remaining = inst._shadow_summon_cooldown - GLOBAL.GetTime()
			if remaining > 0 then
				data.shadow_summon_cooldown = remaining
			end
		end
		if inst._kodi_eruption_cd_end then
			local remaining = inst._kodi_eruption_cd_end - GLOBAL.GetTime()
			if remaining > 0 then
				data.shadow_eruption_cooldown = remaining
			end
		end
		if inst._night_hunter_leap_cd_end then
			local remaining = inst._night_hunter_leap_cd_end - GLOBAL.GetTime()
			if remaining > 0 then
				data.night_hunter_leap_cooldown = remaining
			end
		end
		local pool_data = ShadowMinionPool.OnSave(inst)
		if pool_data then
			data.shadow_minion_pool = pool_data
		end
	end
	local old_onload = inst.OnLoad
	inst.OnLoad = function(inst, data)
		if old_onload then old_onload(inst, data) end
		if data then
			inst.demon_time_total = data.demon_time_total or 0
			inst.demonic_energy = math.max(0, data.demonic_energy or 0)
			inst:UpdateDemonicNetvar()
			inst:PushEvent("demonic_energy_changed", {percent = inst:GetDemonicPercent()})
			if data.last_stand_ready ~= nil then
				inst._last_stand_ready = data.last_stand_ready
			end
			if data.shadow_summon_cooldown and data.shadow_summon_cooldown > 0 then
				inst._shadow_summon_cooldown = GLOBAL.GetTime() + data.shadow_summon_cooldown
			end
			if data.shadow_eruption_cooldown and data.shadow_eruption_cooldown > 0 then
				inst._kodi_eruption_cd_end = GLOBAL.GetTime() + data.shadow_eruption_cooldown
			end
			if data.night_hunter_leap_cooldown and data.night_hunter_leap_cooldown > 0 then
				inst._night_hunter_leap_cd_end = GLOBAL.GetTime() + data.night_hunter_leap_cooldown
			end
			if data.shadow_minion_pool then
				ShadowMinionPool.OnLoad(inst, data.shadow_minion_pool)
			end
			local saved_summon_cd = data.shadow_summon_cooldown
			local saved_leap_cd = data.night_hunter_leap_cooldown
			local saved_eruption_cd = data.shadow_eruption_cooldown
			inst:DoTaskInTime(0.5, function()
				if inst.userid then
					if saved_summon_cd and saved_summon_cd > 0 then
						SendModRPCToClient(GetClientModRPC(modname, "ShadowSummonCooldownSync"), inst.userid, saved_summon_cd)
					end
					if saved_leap_cd and saved_leap_cd > 0 then
						SendModRPCToClient(GetClientModRPC(modname, "NightHunterLeapCooldownSync"), inst.userid, saved_leap_cd)
					end
					if saved_eruption_cd and saved_eruption_cd > 0 then
						inst:SetShadowEruptionCooldown(saved_eruption_cd)
					end
				end
			end)
		end
	end
	inst:ListenForEvent("onattackother", function(inst, data)
		if data.target and data.target.components.health then
			local bonus_mult = 0
			if inst:HasTag("kodi_shadow_allegiance") then
				if data.target:HasTag("lunar") or data.target:HasTag("lunar_aligned") or
				   data.target:HasTag("brightmare") or data.target:HasTag("gestalt") then
					bonus_mult = 0.10
				end
			end
			if inst:HasTag("kodi_lunar_allegiance") then
				if data.target:HasTag("shadow") or data.target:HasTag("shadowcreature") or
				   data.target:HasTag("shadow_aligned") or data.target:HasTag("nightmare") then
					bonus_mult = 0.10
				end
			end
			if bonus_mult > 0 then
				local weapon = inst.components.combat:GetWeapon()
				local base_damage = inst.components.combat:CalcDamage(data.target, weapon)
				local allegiance_bonus = base_damage * bonus_mult
				if allegiance_bonus > 0 then
					data.target.components.health:DoDelta(-allegiance_bonus)
				end
			end
		end
		if inst._shadow_strike_ready and data.target and not inst:HasTag("NotDemon") then
			local weapon = inst.components.combat:GetWeapon()
			local base_damage = inst.components.combat:CalcDamage(data.target, weapon)
			local bonus_damage = base_damage * (SHADOW_STRIKE_MULT - 1)
			if data.target.components.health and bonus_damage > 0 then
				data.target.components.health:DoDelta(-bonus_damage)
			end
			local x, y, z = data.target.Transform:GetWorldPosition()
			local fx = GLOBAL.SpawnPrefab("electricchargedfx")
			if fx then
				fx.Transform:SetPosition(x, y, z)
			end
			inst.SoundEmitter:PlaySound("dontstarve/common/shadowTentacle_attack")
			if math.random() < 0.5 then
				inst.components.talker:Say(GLOBAL.STRINGS.KODI_SPEECH.SHADOW_STRIKE, 1.5, true)
			end
			inst:DisableShadowStrike()
		end
		if inst:HasTag("kodi_fear_attack") and not inst:HasTag("NotDemon") and data.target then
			local target = data.target
			if target.components.locomotor and not target:HasTag("epic") and not target:HasTag("player") then
				if target.components.combat then
					target.components.combat:SetTarget(nil)
				end
				if target.components.hauntable and target.components.hauntable.panicable then
					target.components.hauntable:Panic(3)
				elseif target.brain then
					local x, y, z = inst.Transform:GetWorldPosition()
					local angle = target:GetAngleToPoint(x, y, z) + 180
					if target.components.locomotor then
						target.components.locomotor:RunInDirection(angle)
					end
				end
			end
		end
	end)
	inst:ListenForEvent("death", function()
		inst.demonic_energy = 0
		inst:UpdateDemonicNetvar()
		inst:StopDemonicDrain()
		inst:PushEvent("demonic_energy_changed", {percent = 0})
	end)
	inst:ListenForEvent("killed", function(inst, data)
		local victim = data and data.victim
		if victim and inst.components.skilltreeupdater and KODI_XP_CONFIG then
			local xp_amount = KODI_XP_CONFIG.GetXPForVictim(victim)
			if xp_amount > 0 then
				inst.components.skilltreeupdater:AddSkillXP(xp_amount)
			end
		end
		if not inst:HasTag("NotDemon") and inst.demonic_energy then
			local bonus = TUNING.KODI_KILL_ENERGY_BONUS or 5
			if inst:HasTag("kodi_kill_extend") then
				bonus = bonus + 5
			end
			local old_energy = inst.demonic_energy
			inst.demonic_energy = math.min(TUNING.KODI_DEMONIC_MAX, inst.demonic_energy + bonus)
			inst:UpdateDemonicNetvar()
			inst:PushEvent("demonic_energy_changed", {percent = inst:GetDemonicPercent()})
			if inst.components.sanity then
				inst.components.sanity:DoDelta(5)
			end
			inst.SoundEmitter:PlaySound("dontstarve/sanity/creature1/taunt")
			if math.random() < 0.3 then
				inst.components.talker:Say(GLOBAL.STRINGS.KODI_SPEECH.MORE_POWER, 1.5, true)
			end
		elseif inst:HasTag("NotDemon") and victim then
			if victim:HasTag("shadow") or victim:HasTag("shadowcreature") or
			   victim.prefab == "crawlinghorror" or victim.prefab == "terrorbeak" or
			   victim.prefab == "crawlingnightmare" or victim.prefab == "nightmarebeak" then
				local shadow_bonus = 3
				inst:AddDemonicEnergy(shadow_bonus)
				inst.SoundEmitter:PlaySound("dontstarve/sanity/creature1/taunt")
				if math.random() < 0.5 then
					inst.components.talker:Say(GLOBAL.STRINGS.KODI_SPEECH.SHADOW_ESSENCE, 1.5, true)
				end
			end
		end
	end)
	local NIGHT_SPEED_BONUS = 1.10
	local SLEEP_REGEN_PERCENT = 0.01
	inst:WatchWorldState("phase", function(inst, phase)
		if inst:HasTag("kodi_speed_3") then
			if phase == "night" or phase == "dusk" then
				if inst.components.locomotor then
					inst.components.locomotor:SetExternalSpeedMultiplier(inst, "kodi_skill_speed_night", NIGHT_SPEED_BONUS)
				end
			else
				if inst.components.locomotor then
					inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "kodi_skill_speed_night")
				end
			end
		end
	end)
	inst:DoTaskInTime(0, function()
		if inst:HasTag("kodi_speed_3") and GLOBAL.TheWorld.state.phase ~= "day" then
			if inst.components.locomotor then
				inst.components.locomotor:SetExternalSpeedMultiplier(inst, "kodi_skill_speed_night", NIGHT_SPEED_BONUS)
			end
		end
	end)
	local RAW_MEAT_PREFABS = {
		meat = true,
		monstermeat = true,
		smallmeat = true,
		drumstick = true,
		batwing = true,
		froglegs = true,
		fish = true,
		eel = true,
		fish_raw = true,
		fish_raw_small = true,
		plantmeat = true,
		oceanfish_small_1_inv = true,
		oceanfish_small_2_inv = true,
		oceanfish_small_3_inv = true,
		oceanfish_small_4_inv = true,
		oceanfish_small_5_inv = true,
		oceanfish_small_6_inv = true,
		oceanfish_small_7_inv = true,
		oceanfish_small_8_inv = true,
		oceanfish_medium_1_inv = true,
		oceanfish_medium_2_inv = true,
		oceanfish_medium_3_inv = true,
		oceanfish_medium_4_inv = true,
		oceanfish_medium_5_inv = true,
		oceanfish_medium_6_inv = true,
		oceanfish_medium_7_inv = true,
		oceanfish_medium_8_inv = true,
	}
	local EXTRA_LOOT_CHANCE = 0.25
	local EXTRA_LOOT_WHITELIST = {
		rabbit = true,
		mole = true,
		butterfly = true,
		bee = true,
		killerbee = true,
		fireflies = true,
		crow = true,
		robin = true,
		robin_winter = true,
		canary = true,
		puffin = true,
		penguin = true,
		spider = true,
		spider_warrior = true,
		spider_hider = true,
		spider_spitter = true,
		spider_dropper = true,
		spider_healer = true,
		spider_water = true,
		hound = true,
		firehound = true,
		icehound = true,
		frog = true,
		bat = true,
		mosquito = true,
		tentacle = true,
		pigman = true,
		pigguard = true,
		bunnyman = true,
		merm = true,
		mermguard = true,
		catcoon = true,
		tallbird = true,
		beefalo = true,
		koalefant_summer = true,
		koalefant_winter = true,
		slurper = true,
		snurtle = true,
		slurtle = true,
		monkey = true,
		rocky = true,
		worm = true,
		squid = true,
		gnarwail = true,
		moonpig = true,
		moonglass_penguin = true,
	}
	local function GetAllPossibleLoot(lootdropper)
		if not lootdropper then return {} end
		local all_loot = {}
		if lootdropper.loot then
			for _, prefab in ipairs(lootdropper.loot) do
				table.insert(all_loot, prefab)
			end
		end
		if lootdropper.chanceloottable and GLOBAL.LootTables then
			local loot_table = GLOBAL.LootTables[lootdropper.chanceloottable]
			if loot_table then
				for _, entry in ipairs(loot_table) do
					table.insert(all_loot, entry[1])
				end
			end
		end
		if lootdropper.chanceloot then
			for _, entry in ipairs(lootdropper.chanceloot) do
				table.insert(all_loot, entry.prefab)
			end
		end
		if lootdropper.randomloot then
			for _, entry in ipairs(lootdropper.randomloot) do
				table.insert(all_loot, entry.prefab)
			end
		end
		return all_loot
	end
	inst:ListenForEvent("killed", function(inst, data)
		if not inst:HasTag("kodi_extra_meat") then return end
		local victim = data and data.victim
		if not victim then return end
		if not victim.prefab then return end
		if not victim.components.lootdropper then return end
		if not EXTRA_LOOT_WHITELIST[victim.prefab] then return end
		local all_loot = GetAllPossibleLoot(victim.components.lootdropper)
		if #all_loot == 0 then return end
		if math.random() < EXTRA_LOOT_CHANCE then
			local random_loot = all_loot[math.random(#all_loot)]
			local extra_item = GLOBAL.SpawnPrefab(random_loot)
			if extra_item then
				extra_item.Transform:SetPosition(victim.Transform:GetWorldPosition())
				inst.SoundEmitter:PlaySound("dontstarve/HUD/collect_resource")
				local fx = GLOBAL.SpawnPrefab("sparks")
				if fx then
					fx.Transform:SetPosition(victim.Transform:GetWorldPosition())
				end
			end
		end
	end)
	if inst.components.eater then
		local old_Eat = inst.components.eater.Eat
		inst.components.eater.Eat = function(self, food, feeder)
			if food and food.components.edible then
				local edible = food.components.edible
				local modified = false
				local orig_hunger = edible.hungervalue
				local orig_sanity = edible.sanityvalue
				local orig_health = edible.healthvalue
				local is_stale = food:HasTag("stale")
				local is_spoiled = food:HasTag("spoiled")
				if inst:HasTag("kodi_food_sense") and food.prefab and RAW_MEAT_PREFABS[food.prefab] then
					edible.sanityvalue = math.max(0, orig_sanity)
					if food.prefab ~= "monstermeat" then
						edible.healthvalue = math.max(0, orig_health)
					end
					modified = true
				end
				if inst:HasTag("kodi_eat_spoiled") and (is_stale or is_spoiled) then
					edible.sanityvalue = 0
					food:RemoveTag("stale")
					food:RemoveTag("spoiled")
					modified = true
				end
				if modified then
					local result = old_Eat(self, food, feeder)
					edible.hungervalue = orig_hunger
					edible.sanityvalue = orig_sanity
					edible.healthvalue = orig_health
					if is_stale then food:AddTag("stale") end
					if is_spoiled then food:AddTag("spoiled") end
					return result
				end
			end
			return old_Eat(self, food, feeder)
		end
	end
	local DODGE_CHANCE = 0.15
	inst._last_stand_ready = true
	inst:WatchWorldState("isday", function(inst, isday)
		if isday and inst:HasTag("kodi_last_stand") and not inst._last_stand_ready then
			inst._last_stand_ready = true
			if inst.components.talker then
				inst.components.talker:Say(GLOBAL.STRINGS.KODI_SPEECH and GLOBAL.STRINGS.KODI_SPEECH.LAST_STAND_READY or "*I feel my survival instincts returning*", 2.5, true)
			end
		end
	end)
	local _old_health_dodelta = inst.components.health.DoDelta
	inst.components.health.DoDelta = function(self, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
		if amount < 0 and inst:HasTag("kodi_last_stand") and inst._last_stand_ready then
			local current_hp = self.currenthealth
			local new_hp = current_hp + amount
			if new_hp <= 0 and current_hp > 0 then
				inst._last_stand_ready = false
				local actual_damage = current_hp - 1
				_old_health_dodelta(self, -actual_damage, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
				local x, y, z = inst.Transform:GetWorldPosition()
				local fx = GLOBAL.SpawnPrefab("statue_transition_2")
				if fx then
					fx.Transform:SetPosition(x, y, z)
				end
				inst.SoundEmitter:PlaySound("dontstarve/common/ghost_spawn")
				if inst.player_classified then
					inst.player_classified.isghostmode:set_local(true)
					inst:DoTaskInTime(0.2, function()
						if inst.player_classified then
							inst.player_classified.isghostmode:set_local(false)
						end
					end)
				end
				if inst.components.talker then
					inst.components.talker:Say(GLOBAL.STRINGS.KODI_SPEECH and GLOBAL.STRINGS.KODI_SPEECH.LAST_STAND_TRIGGER or "*Not today, death!*", 2.5, true)
				end
				return 0
			end
		end
		return _old_health_dodelta(self, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
	end
	inst:ListenForEvent("attacked", function(inst, data)
		if not inst:HasTag("kodi_dodge") then return end
		if not data or not data.attacker then return end
		if math.random() < DODGE_CHANCE then
			if inst.components.health and data.damage then
				inst.components.health:DoDelta(data.damage)
				local x, y, z = inst.Transform:GetWorldPosition()
				local fx = GLOBAL.SpawnPrefab("sand_puff")
				if fx then
					fx.Transform:SetPosition(x, y, z)
				end
				inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
				inst.components.talker:Say(GLOBAL.STRINGS.KODI_SPEECH and GLOBAL.STRINGS.KODI_SPEECH.DODGE or "*dodged!*", 1, true)
				inst:AddTag("kodi_just_dodged")
				inst:DoTaskInTime(0.3, function()
					inst:RemoveTag("kodi_just_dodged")
				end)
			end
		end
	end)
	ShadowSummon.SetupPlayer(inst)
	inst._shadow_cache_items = inst._shadow_cache_items or {}
	inst.OpenShadowCache = function(self)
		if not self:HasTag("kodi_shadow_cache") then return false end
		if self.DoOpenShadowCache then
			return self:DoOpenShadowCache()
		end
		return false
	end
	inst._shadow_minion = nil
	inst._shadow_minion_cooldown = 0
	inst.RaiseShadowMinion = function(self, corpse)
		if not self:HasTag("kodi_shadow_minion") then return false end
		if self.DoRaiseShadowMinion then
			return self:DoRaiseShadowMinion(corpse)
		end
		return false
	end
	ShadowDash.SetupPlayer(inst)
	DayStalker.SetupPlayer(inst)
	NightHunter.SetupPlayer(inst)
	ShadowHands.SetupPlayer(inst)
	ShadowEruption.SetupPlayer(inst)
	ShadowCache.SetupPlayer(inst)
	ShadowMinion.SetupPlayer(inst)
	ShadowMinionPool.SetupPlayer(inst)
	inst:ListenForEvent("equip", function(inst, data)
		if not inst:HasTag("NotDemon") and data.item and data.item:HasTag("heavy")
			and data.item.components.equippable then
			data.item._kodi_orig_wsm = data.item.components.equippable.walkspeedmult
			data.item.components.equippable.walkspeedmult = KODI_HEAVY_LIFT_SPEEDMULT
		end
	end)
	inst:ListenForEvent("unequip", function(inst, data)
		if data.item and data.item._kodi_orig_wsm and data.item.components.equippable then
			data.item.components.equippable.walkspeedmult = data.item._kodi_orig_wsm
			data.item._kodi_orig_wsm = nil
		end
	end)
end
AddPrefabPostInit("world", function(inst)
	if inst.ismastersim then
		inst:DoTaskInTime(2, function()
			ShadowMinionPool.CleanupOrphanedMinions()
		end)
	end
end)
local function SetupShadowMinionMenuUI(player)
	if not player or not player.HUD then return end
	if player.prefab ~= "kodi" then return end
	if player ~= GLOBAL.ThePlayer then return end
	local ShadowMinionMenu = require("widgets/shadow_minion_menu")
	player._shadow_minion_menu = player.HUD.controls:AddChild(ShadowMinionMenu(player))
end
AddClassPostConstruct("screens/playerhud", function(self)
	local old_SetMainCharacter = self.SetMainCharacter
	self.SetMainCharacter = function(self, maincharacter, ...)
		old_SetMainCharacter(self, maincharacter, ...)
		if maincharacter and maincharacter.prefab == "kodi" then
			maincharacter:DoTaskInTime(0, function()
				SetupShadowMinionMenuUI(maincharacter)
				maincharacter:DoTaskInTime(0.5, function()
					if MOD_RPC[modname] and MOD_RPC[modname]["ShadowPoolSync"] then
						SendModRPCToServer(MOD_RPC[modname]["ShadowPoolSync"])
					end
				end)
			end)
		end
	end
end)
local function DoTransformToDemon(inst)
	if not GLOBAL.TheWorld.ismastersim then return end
	if IsPlayerGhost(inst) then return end
	if inst.ExitDayStalkerStealth then
		inst:ExitDayStalkerStealth()
	end
	if inst.ClearNightHunterMarks then
		inst:ClearNightHunterMarks()
	end
	inst:AddTag("monster")
	inst:RemoveTag("NotDemon")
	inst:PushEvent("kodi_form_changed")
	BypassHeavyItemSpeed(inst)
	if inst.RefreshWoolAppearance then
		inst:RefreshWoolAppearance()
	end
	SpawnTransformEffects(inst, true)
	inst.components.locomotor:SetExternalSpeedMultiplier(inst, "kodi_speed_mod", TUNING.KODI_SPEEDTRANSFORM)
	inst.components.combat.damagemultiplier = (TUNING.KODI_DAMAGETRANSFORM)
	inst.components.hunger:SetRate(1.2)
	inst.components.sanity:DoDelta(-25)
	inst.components.hunger:DoDelta(-15)
	if inst.components.moisture then
		inst._kodi_original_drying_rate = inst.components.moisture.maxDryingRate
		inst.components.moisture.maxDryingRate = inst.components.moisture.maxDryingRate * 2
	end
	local olddefense = inst.components.health.absorb
	local newdefense = (olddefense + TUNING.KODI_DAMAGEBLOCK)
	inst.components.health:SetAbsorptionAmount(newdefense)
	local lightningx, lightningy, lightningz = inst.Transform:GetWorldPosition()
	local lightning1 = GLOBAL.SpawnPrefab("lightning")
	local lightning2 = GLOBAL.SpawnPrefab("lightning")
	local lightning3 = GLOBAL.SpawnPrefab("lightning")
	lightning1.Transform:SetPosition(lightningx+math.random(-5,5), 0, lightningz+math.random(-5,5))
	lightning2.Transform:SetPosition(lightningx-math.random(-5,10), 0, lightningz+math.random(-5,10))
	lightning3.Transform:SetPosition(lightningx-math.random(-5,15), 0, lightningz-math.random(-5,15))
	local radius = 15
	local players_nearby = GLOBAL.TheSim:FindEntities(lightningx, lightningy, lightningz, radius, {"player"})
	for _, player in ipairs(players_nearby) do
		if player and player:IsValid() and player:HasTag("player") then
			player:ShakeCamera(GLOBAL.CAMERASHAKE.FULL, 1.4, 0.03, .7)
		end
	end
	local crowx, crowy, crowz = inst.Transform:GetWorldPosition()
	local insanecrow1 = GLOBAL.SpawnPrefab("crow") local insanecrow2 = GLOBAL.SpawnPrefab("crow")
	local insanecrow3 = GLOBAL.SpawnPrefab("crow") local insanecrow4 = GLOBAL.SpawnPrefab("crow")
	local insanecrow5 = GLOBAL.SpawnPrefab("crow") local insanecrow6 = GLOBAL.SpawnPrefab("crow")
	local insanecrow7 = GLOBAL.SpawnPrefab("crow") local insanecrow8 = GLOBAL.SpawnPrefab("crow")
	insanecrow1.Transform:SetPosition(crowx+1, 0, crowz+1) insanecrow2.Transform:SetPosition(crowx-1, 0, crowz+1)
	insanecrow3.Transform:SetPosition(crowx-1, 0, crowz-1) insanecrow4.Transform:SetPosition(crowx+1, 0, crowz-1)
	insanecrow5.Transform:SetPosition(crowx+2, 0, crowz-2) insanecrow6.Transform:SetPosition(crowx+2, 0, crowz-2)
	insanecrow7.Transform:SetPosition(crowx+2, 0, crowz-2) insanecrow8.Transform:SetPosition(crowx+2, 0, crowz-2)
	insanecrow1.sg:GoToState("flyaway") insanecrow2.sg:GoToState("flyaway")
	insanecrow3.sg:GoToState("flyaway") insanecrow4.sg:GoToState("flyaway")
	insanecrow5.sg:GoToState("flyaway") insanecrow6.sg:GoToState("flyaway")
	insanecrow7.sg:GoToState("flyaway") insanecrow8.sg:GoToState("flyaway")
	if inst.components.eater ~= nil then
		inst.components.eater.strongstomach = true
	end
	if inst.StartDemonicDrain then
		inst:StartDemonicDrain()
	end
	if inst.StartFearAura then
		inst:StartFearAura()
	end
	if inst.EnableShadowStrike then
		inst:EnableShadowStrike()
	end
	if inst.StartTemperatureImmunity then
		inst:StartTemperatureImmunity()
	end
	if inst.StartProgressiveTracking then
		inst:StartProgressiveTracking()
	end
	if inst.GetProgressiveDamageBonus then
		local bonus = inst:GetProgressiveDamageBonus()
		inst.components.combat.damagemultiplier = TUNING.KODI_DAMAGETRANSFORM * (1 + bonus)
	end
	if inst.StartDemonPenalties then
		inst:StartDemonPenalties()
	end
	inst.components.talker:Say(GLOBAL.STRINGS.KODI_SPEECH.FORM_DRAIN, 3.5, true)
end
local function DoTransformFromDemon(inst)
	if not GLOBAL.TheWorld.ismastersim then return end
	if inst.StopDemonicDrain then
		inst:StopDemonicDrain()
	end
	if inst.StopFearAura then
		inst:StopFearAura()
	end
	if inst.DisableShadowStrike then
		inst:DisableShadowStrike()
	end
	if inst.StopTemperatureImmunity then
		inst:StopTemperatureImmunity()
	end
	if inst.StopProgressiveTracking then
		inst:StopProgressiveTracking()
	end
	if inst.StopDemonPenalties then
		inst:StopDemonPenalties()
	end
	if inst.components.moisture and inst._kodi_original_drying_rate then
		inst.components.moisture.maxDryingRate = inst._kodi_original_drying_rate
		inst._kodi_original_drying_rate = nil
	end
	RestoreHeavyItemSpeed(inst)
	inst:RemoveTag("monster")
	inst:AddTag("NotDemon")
	inst:PushEvent("kodi_form_changed")
	if inst.RefreshWoolAppearance then
		inst:RefreshWoolAppearance()
	end
	SpawnTransformEffects(inst, false)
	inst.components.locomotor:SetExternalSpeedMultiplier(inst, "kodi_speed_mod", TUNING.KODI_SPEED)
	inst.components.combat.damagemultiplier = (TUNING.KODI_DAMAGEMULT)
	inst.components.hunger:SetRate(TUNING.WILSON_HUNGER_RATE)
	inst.components.sanity:DoDelta(10)
	local olddefense = inst.components.health.absorb
	local newdefense = (olddefense - TUNING.KODI_DAMAGEBLOCK)
	inst.components.health:SetAbsorptionAmount(newdefense)
	if inst.components.eater ~= nil then
		inst.components.eater.strongstomach = false
	end
	inst.components.talker:Say(GLOBAL.STRINGS.KODI_SPEECH.FORM_FADES, 3.5, true)
end
local function InitDemonicEnergy(inst)
	inst._kodi_do_transform_to_demon = function(self)
		DoTransformToDemon(self)
	end
	inst._kodi_do_transform_from_demon = function(self)
		DoTransformFromDemon(self)
	end
	InitDemonicEnergyNetvar(inst)
	InitDemonicEnergyClient(inst)
	if GLOBAL.TheWorld.ismastersim then
		InitDemonicEnergyServer(inst)
	end
end
AddPrefabPostInit("kodi", InitDemonicEnergy)
local KODI_HUNT_TRACKS = 3
AddComponentPostInit("hunter", function(self)
	local _tonumber = GLOBAL.tonumber
	local _TheSim = GLOBAL.TheSim
	local _ipairs = GLOBAL.ipairs
	local _Vector3 = GLOBAL.Vector3
	local _oldOnDirtInvestigated = self.OnDirtInvestigated
	self.OnDirtInvestigated = function(self, pt, doer)
		local result = _oldOnDirtInvestigated(self, pt, doer)
		if doer and doer.prefab == "kodi" and doer:HasTag("kodi_food_sense") then
			local debug_str = self:GetDebugString()
			for ts, nts in debug_str:gmatch("Track # (%d+)/(%d+)") do
				local trackspawned = _tonumber(ts)
				local numtrackstospawn = _tonumber(nts)
				if numtrackstospawn > KODI_HUNT_TRACKS then
					if trackspawned == 1 then
						if doer.components.talker then
							local speech = GLOBAL.STRINGS.KODI_SPEECH and GLOBAL.STRINGS.KODI_SPEECH.HUNT_INSTINCT
								or "*I can smell the prey nearby...*"
							doer.components.talker:Say(speech, 2, true)
						end
					elseif trackspawned == KODI_HUNT_TRACKS then
						local skip_count = numtrackstospawn - KODI_HUNT_TRACKS
						local function AutoFinishHunt(remaining)
							if remaining <= 0 or not doer:IsValid() then return end
							local px, _, pz = doer.Transform:GetWorldPosition()
							local ents = _TheSim:FindEntities(px, 0, pz, 80, {"dirtpile"})
							local closest_dirt, closest_dsq = nil, 999999
							for _, ent in _ipairs(ents) do
								if ent.prefab == "dirtpile" and ent:IsValid() then
									local ex, _, ez = ent.Transform:GetWorldPosition()
									local dsq = (ex - px) * (ex - px) + (ez - pz) * (ez - pz)
									if dsq < closest_dsq then
										closest_dirt = ent
										closest_dsq = dsq
									end
								end
							end
							if closest_dirt then
								closest_dirt.Transform:SetPosition(px, 0, pz)
								local dirt_pos = _Vector3(px, 0, pz)
								_oldOnDirtInvestigated(self, dirt_pos, doer)
								if closest_dirt:IsValid() then
									closest_dirt:Remove()
								end
								local nearby = _TheSim:FindEntities(px, 0, pz, 3)
								for _, ent in _ipairs(nearby) do
									if ent.prefab == "animal_track" then
										ent:Remove()
										break
									end
								end
								if remaining > 1 then
									self.inst:DoTaskInTime(0, function()
										AutoFinishHunt(remaining - 1)
									end)
								end
							end
						end
						self.inst:DoTaskInTime(0, function()
							AutoFinishHunt(skip_count)
						end)
					end
				end
				break
			end
		end
		return result
	end
end)
AddPrefabPostInit("nightmarefuel", function(inst)
	if not GLOBAL.TheWorld.ismastersim then return end
	if not inst.components.edible then
		inst:AddComponent("edible")
	end
	inst.components.edible.foodtype = GLOBAL.FOODTYPE.HORRIBLE
	inst.components.edible.healthvalue = 0
	inst.components.edible.hungervalue = 0
	inst.components.edible.sanityvalue = -5
	inst.components.edible:SetOnEatenFn(function(food, eater)
		if eater.prefab == "kodi" and eater.AddDemonicEnergy then
			eater:AddDemonicEnergy(TUNING.KODI_DEMONIC_PER_FUEL)
			eater.SoundEmitter:PlaySound("dontstarve/sanity/creature2/taunt")
			if not eater:HasTag("NotDemon") and eater.components.sanity then
				eater.components.sanity:DoDelta(5)
			end
		end
	end)
end)
AddPrefabPostInit("horrorfuel", function(inst)
	if not GLOBAL.TheWorld.ismastersim then return end
	if not inst.components.edible then
		inst:AddComponent("edible")
	end
	inst.components.edible.foodtype = GLOBAL.FOODTYPE.HORRIBLE
	inst.components.edible.healthvalue = -5
	inst.components.edible.hungervalue = 0
	inst.components.edible.sanityvalue = -15
	inst.components.edible:SetOnEatenFn(function(food, eater)
		if eater.prefab == "kodi" and eater.AddDemonicEnergy then
			eater:AddDemonicEnergy(TUNING.KODI_DEMONIC_PER_FUEL * 2)
			eater.SoundEmitter:PlaySound("dontstarve/sanity/creature2/taunt")
			if not eater:HasTag("NotDemon") then
				if eater.components.sanity then
					eater.components.sanity:DoDelta(15)
				end
				if eater.components.health then
					eater.components.health:DoDelta(5)
				end
			end
			eater.components.talker:Say(GLOBAL.STRINGS.KODI_SPEECH.PURE_POWER, 2, true)
		end
	end)
end)
AddPrefabPostInit("atrium_key", function(inst)
	if not GLOBAL.TheWorld.ismastersim then return end
end)
local BADGE_POS_X = GetModConfigData("badge_pos_x") or -120
local BADGE_POS_Y = GetModConfigData("badge_pos_y") or -40
AddClassPostConstruct("widgets/statusdisplays", function(self)
	if self.owner and self.owner.prefab == "kodi" then
		local DemonicBadge = require "widgets/demonicbadge"
		self.demonicbadge = self:AddChild(DemonicBadge(self.owner))
		self.demonicbadge:SetPosition(BADGE_POS_X, BADGE_POS_Y, 0)
		if self.owner.GetDemonicPercent then
			self.demonicbadge:SetPercent(self.owner:GetDemonicPercent())
		end
		local SkillCooldown = require "widgets/skillcooldown"
		self.demonicbadge.skillcooldown = self.demonicbadge:AddChild(SkillCooldown(self.owner))
		self.demonicbadge.skillcooldown:SetPosition(0, -50, 0)
	end
end)
CreateKodiSkillTree()
local atlas_path = resolvefilepath("images/kodi_skilltree.xml")
GLOBAL.RegisterSkilltreeBGAtlas(atlas_path, "kodi_background.tex")
local icons_atlas_path = resolvefilepath("images/kodi_skilltree_icons.xml")
local kodi_skill_icons = {
    "fast_fox.tex",
    "fast_fox2.tex",
    "fast_fox3.tex",
    "fluffy_fur.tex",
    "fluffy_fur2.tex",
    "fluffy_fur3.tex",
    "day_stalker.tex",
    "hight_hunter.tex",
    "demonic_endurance.tex",
    "demonic_endurance2.tex",
    "demonic_endurance3.tex",
    "demonic_mastery.tex",
    "the_power_of_darkness.tex",
    "the_power_of_darkness2.tex",
    "shadow_step.tex",
    "shadow_step2.tex",
    "shadow_hands.tex",
    "shadow_eruption.tex",
    "scavenger.tex",
    "scavenger2.tex",
    "scavenger3.tex",
    "the_last_frontier.tex",
    "avoidance.tex",
    "summoning_the_shadows.tex",
    "shadow_hideout.tex",
    "shadowy_skunk.tex",
    "shadow_affinity.tex",
    "lunar_affinity.tex",
}
for _, icon_name in ipairs(kodi_skill_icons) do
    GLOBAL.RegisterSkilltreeIconsAtlas(icons_atlas_path, icon_name)
end
local kodi_atlas = resolvefilepath("images/kodi_skilltree.xml")
AddClassPostConstruct("widgets/redux/skilltreewidget", function(self)
    if self.target == "kodi" and self.bg_tree then
        self.bg_tree:SetTexture(kodi_atlas, "kodi_background.tex")
    end
end)
AddClassPostConstruct("widgets/redux/skilltreebuilder", function(self)
    local _oldRefreshTree = self.RefreshTree
    if _oldRefreshTree then
        self.RefreshTree = function(self, ...)
            local result = _oldRefreshTree(self, ...)
            if self.target == "kodi" and self.skillgraphics then
                local kodi_defs = SkillTreeDefs.SKILLTREE_DEFS["kodi"]
                if kodi_defs then
                    if TUNING.KODI_DEBUG_SKILLTREE then
                        if self.skilltreedata and self.skilltreedata.activatedskills then
                            local activated = self.skilltreedata.activatedskills["kodi"]
                            if activated then
                                for skill_name, v in pairs(activated) do
                                    if skill_name:find("scavenger") or skill_name:find("speed") then
                                    end
                                end
                            else
                            end
                        else
                        end
                        for _, skill_name in ipairs({"kodi_survival_scavenger_1", "kodi_survival_scavenger_2", "kodi_survival_scavenger_3"}) do
                            local graphics = self.skillgraphics[skill_name]
                            if graphics and graphics.status then
                            else
                            end
                        end
                        for _, skill_name in ipairs({"kodi_fox_speed_1", "kodi_fox_speed_2", "kodi_fox_speed_3"}) do
                            local graphics = self.skillgraphics[skill_name]
                            if graphics and graphics.status then
                            end
                        end
                    end
                    for skill, graphics in pairs(self.skillgraphics) do
                        local def = kodi_defs[skill]
                        if def and def.lock_open and graphics.status then
                            graphics.status.activatable = nil
                        end
                    end
                    if self.selectedskill then
                        local selected_def = kodi_defs[self.selectedskill]
                        if selected_def and selected_def.lock_open then
                            if self.infopanel and self.infopanel.activatebutton then
                                self.infopanel.activatebutton:Hide()
                            end
                        end
                    end
                end
            end
            return result
        end
    end
    local _oldLearnSkill = self.LearnSkill
    if _oldLearnSkill then
        self.LearnSkill = function(self, skilltreeupdater, characterprefab, ...)
            if characterprefab == "kodi" and self.selectedskill then
                local def = SkillTreeDefs.SKILLTREE_DEFS["kodi"] and SkillTreeDefs.SKILLTREE_DEFS["kodi"][self.selectedskill]
                if TUNING.KODI_DEBUG_SKILLTREE then
                    if def then
                    else
                    end
                end
                if def and def.lock_open ~= nil then
                    if TUNING.KODI_DEBUG_SKILLTREE then
                    end
                    return
                end
            end
            return _oldLearnSkill(self, skilltreeupdater, characterprefab, ...)
        end
    end
end)
GLOBAL.c_kodi_test = function(test_name)
    local KodiTests = require("tests/kodi_tests")
    KodiTests.run(test_name)
end
GLOBAL.c_kodi_test_all = function()
    local KodiTests = require("tests/kodi_tests")
    KodiTests.run_all()
end
GLOBAL.c_kodi_status = function()
    local player = GLOBAL.ThePlayer or GLOBAL.ConsoleCommandPlayer()
    if not player or player.prefab ~= "kodi" then
        return
    end
    local is_fox = player:HasTag("NotDemon")
    if player.GetDemonicPercent then
    end
    if player.components.health then
    end
    if player.components.sanity then
    end
    if player.components.hunger then
    end
    local skills = {"kodi_shadow_dash", "kodi_night_hunter", "kodi_day_stalker", "kodi_shadow_eruption", "kodi_shadow_cache", "kodi_shadow_summon"}
    for _, skill in ipairs(skills) do
        if player:HasTag(skill) then
        end
    end
end
GLOBAL.c_kodi_energy = function(percent)
    local player = GLOBAL.ThePlayer or GLOBAL.ConsoleCommandPlayer()
    if not player or player.prefab ~= "kodi" then
        return
    end
    percent = math.max(0, math.min(100, percent or 100))
    if player.demonic_energy ~= nil then
        player.demonic_energy = percent
        if player.UpdateDemonicNetvar then
            player:UpdateDemonicNetvar()
        end
    end
end
GLOBAL.c_kodi_debug = function(category)
    local KodiUtils = require("kodi_utils")
    if category then
        local current = KodiUtils.DEBUG[category:upper()]
        KodiUtils.SetDebug(category:upper(), not current)
    else
        KodiUtils.DEBUG.ENABLED = not KodiUtils.DEBUG.ENABLED
    end
end