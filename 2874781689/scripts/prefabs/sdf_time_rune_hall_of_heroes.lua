local assets = 
{
    Asset("ANIM", "anim/sdf_time_rune_hall_of_heroes.zip"),

}

local function TimeRuneTintFX(inst, val)
    local r = 255
    local g = 255
    local b = 255
    if val > 0 then
        inst.components.colouradder:PushColour("portaltint", r / 255 * val, g / 255 * val, b / 255 * val, 0)
        val = 1 - val
        inst.AnimState:SetMultColour(val, val, val, 1)
    else
        inst.components.colouradder:PopColour("portaltint")
        inst.AnimState:SetMultColour(1, 1, 1, 1)
    end
end

local function runestoneturnon(inst, player)
    if player.prefab == "sdf" then

	if player.components.skilltreeupdater:IsActivated("sdf_undeath_11") then

	    local timeRuneEnabled = player.components.sdf_rune_holder:CheckRuneStatus("sdf_time_rune")

	    --Create Time Rune
	    if timeRuneEnabled == false then

		--Animation
		local timeRune = SpawnPrefab("sdf_time_rune")
		timeRune.Transform:SetPosition(inst.Transform:GetWorldPosition())

		SpawnPrefab("sdf_time_rune_gears_fx").Transform:SetPosition(timeRune.Transform:GetWorldPosition())

		timeRune.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/infection_post", nil, .7)
		timeRune.SoundEmitter:PlaySound("dontstarve/characters/wortox/soul/spawn", nil, .5)

		--Set Hall of Heroes Location
		timeRune.components.sdf_time_rune_epoch:RecordingLocation(inst)

		--Lock Rune
		player.components.sdf_rune_holder:EnableRuneStatus("sdf_time_rune")

		timeRune:UpdateStatusFn()
	    end
	end
    end
end

local TIMEOUT = 10 --in case resurrection starts but never completes
local function OnTimeout(inst)
    --In case haunt starts, but resurrection never activates
    --Could happen if player disconnects during resurrection
    inst._task = nil
    if inst.AnimState:IsCurrentAnimation("idle_resurrect") or inst.AnimState:IsCurrentAnimation("idle_broken") then
        inst.AnimState:PlayAnimation("idle_activate", false)
        inst.SoundEmitter:PlaySound("dontstarve/common/resurrectionstone_activate")
        inst._enablelights:set(true)
    end
end

local function OnHaunt(inst, haunter)
    if inst._task == nil and haunter:HasTag("playerghost") and inst.AnimState:IsCurrentAnimation("idle_activate") then

	--Stop Moving
	if haunter.components.locomotor ~= nil then
	    haunter.components.locomotor:StopMoving()
	end
	haunter.Transform:SetPosition(inst.Transform:GetWorldPosition())

	--Animation
	local timeRuneClockFX = SpawnPrefab("sdf_time_rune_clock_fx")
	timeRuneClockFX.Transform:SetPosition(inst.Transform:GetWorldPosition())
		
	inst.SoundEmitter:PlaySound("wanda2/characters/wanda/younger_transition")
	inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/infection_post", nil, .7)
	inst.SoundEmitter:PlaySound("dontstarve/characters/wortox/soul/spawn", nil, .5)

	timeRuneClockFX:DoTaskInTime(2.5, function()
	    timeRuneClockFX:goAwayFn()
	end)

	--revive player
	haunter:PushEvent("respawnfromghost", { source = inst, user = haunter })
		
	--apply health penalty
	haunter.components.health:DeltaPenalty(TUNING.SDF_TIME_RUNE_HALL_OF_HEROES_REVIVE_PENALTY)

        inst.AnimState:PlayAnimation("idle_resurrect")
        inst.AnimState:PushAnimation("idle_broken", false)
        inst._enablelights:set(false)

        inst._task = inst:DoTaskInTime(TIMEOUT, OnTimeout)

	--Start Cooldown
	inst.components.cooldown:StartCharging()
    end
end

-------------------------------------------------------------------------

local function OnStartCharging(inst)
    if not inst.AnimState:IsCurrentAnimation("idle_off") then
	if inst._task ~= nil then
	    inst._task:Cancel()
	    inst._task = nil
	end

        inst.AnimState:PlayAnimation("idle_off", false)
        inst._enablelights:set(false)

        if inst.components.hauntable ~= nil then
            inst:RemoveComponent("hauntable")
        end
    end
end

local function HasPhysics(obj)
    return obj.Physics ~= nil
end

local CHANGED_MUST_HAVE_TAGS = {"playerghost"}
local CHANGED_CANT_HAVE_TAGS = {"FX", "NOCLICK", "DECOR", "INLIMBO"}
local CHANGED_AOE_RADIUS = 3
local function OnCharged(inst)
    if inst.AnimState:IsCurrentAnimation("idle_off") then
        local tx, ty, tz = inst.Transform:GetWorldPosition()

	local affected_entity = TheSim:FindEntities(tx, ty, tz, CHANGED_AOE_RADIUS, CHANGED_MUST_HAVE_TAGS, CHANGED_CANT_HAVE_TAGS)
	for i, v in ipairs(affected_entity) do
            --Something is on top of us
            --Reschedule regenration...
            inst.components.cooldown:StartCharging(math.random(5, 8))
            return
        end

        inst.AnimState:PlayAnimation("idle_activate", false)
        inst.SoundEmitter:PlaySound("dontstarve/common/resurrectionstone_activate")
        inst._enablelights:set(true)

	if inst.components.hauntable == nil and inst.AnimState:IsCurrentAnimation("idle_activate") then
	    inst:AddComponent("hauntable")
	    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_INSTANT_REZ)
	    inst.components.hauntable:SetOnHauntFn(OnHaunt)
	end
    end
end

-------------------------------------------------------------------------

local LIGHT_ANIM_PRE = "glow_pre"
local LIGHT_ANIM_PST = "glow_pst"
local LIGHT_ANIM_LOOP =
{
    "glow_activate",
}

local function OnLightAnimOver(inst)
    if inst._end then
        if not inst.entity:IsVisible() or inst.AnimState:IsCurrentAnimation(LIGHT_ANIM_PST) then
            inst:Remove()
        else
            inst.AnimState:PlayAnimation(LIGHT_ANIM_PST, false)
        end
    elseif inst._parent.AnimState:IsCurrentAnimation("idle_activate") then
        if inst.entity:IsVisible() then
            --randomize
            inst.AnimState:PlayAnimation(LIGHT_ANIM_LOOP[math.random(#LIGHT_ANIM_LOOP)], false)
        else
            inst.AnimState:PlayAnimation(LIGHT_ANIM_PRE, false)
            inst:Show()
        end
    elseif not inst.entity:IsVisible() then
        inst:DoTaskInTime(1, OnLightAnimOver)
    elseif inst.AnimState:IsCurrentAnimation(LIGHT_ANIM_PST) then
        inst:Hide()
    else
        inst.AnimState:PlayAnimation(LIGHT_ANIM_PST, false)
    end
end

local function EndLight(inst)
    inst._end = true
    if not inst.entity:IsVisible() then
        inst:Remove()
    end
end

local function CreateLight(parent)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("sdf_time_rune_hall_of_heroes")
    inst.AnimState:SetBuild("sdf_time_rune_hall_of_heroes")

    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetFinalOffset(4)
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst:Hide()

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:SetParent(parent.entity)
    inst._parent = parent

    inst._end = false
    inst:ListenForEvent("animover", OnLightAnimOver)
    OnLightAnimOver(inst)

    inst.EndLight = EndLight

    return inst
end

local function TryRandomLightFX(inst)
    inst._lighttask = nil

    if inst.AnimState:IsCurrentAnimation("idle_activate") then
	inst._lightfx = CreateLight(inst)
    else
	inst._lighttask = inst:DoTaskInTime(.8 + math.random() * .4, TryRandomLightFX)
    end
end

local function OnSleep(inst)
    if inst._lightplayer ~= nil then
        inst:RemoveEventCallback("ghostvision", inst._onghostvision, inst._lightplayer)
    end
    if inst._lighttask ~= nil then
        inst._lighttask:Cancel()
        inst._lighttask = nil
    end
    if inst._lightfx ~= nil then
        inst._lightfx:Remove()
        inst._lightfx = nil
    end
end

local function OnWake(inst)
    if inst._lightplayer ~= nil then
        inst:ListenForEvent("ghostvision", inst._onghostvision, inst._lightplayer)
        inst._onghostvision(inst._lightplayer, inst._lightplayer.components.playervision:HasGhostVision())
    end
end

local function OnEnableLightsDirty(inst)
    if inst._enablelights:value() then
        inst.OnEntitySleep = OnSleep
        inst.OnEntityWake = OnWake
        if not inst:IsAsleep() then
            OnWake(inst)
        end
    else
        inst.OnEntitySleep = nil
        inst.OnEntityWake = nil
        OnSleep(inst)
    end
end

local function SetupLights(inst)
    inst._lightplayer = nil
    inst._lighttask = nil
    inst._lightfx = nil

    inst._onghostvision = function(player, ghostvision)
        if ghostvision then
            if inst._lighttask == nil and inst._lightfx == nil then
                --In case we need to wait for _touchstoneid initial sync
                --Also staggers the FX if multiple stones are nearby
                inst._lighttask = inst:DoTaskInTime(math.random() * .5, TryRandomLightFX)
            end
        else
            if inst._lighttask ~= nil then
                inst._lighttask:Cancel()
                inst._lighttask = nil
            end
            if inst._lightfx ~= nil then
                inst._lightfx:EndLight()
                inst._lightfx = nil
            end
        end
    end

    local function OnPlayerDeactivated(world, player)
        if inst._lightplayer == player then
            inst._lightplayer = nil
            inst:RemoveEventCallback("enablelightsdirty", OnEnableLightsDirty)
            OnEnableLightsDirty(inst)
        end
    end

    local function OnPlayerActivated(world, player)
        if inst._lightplayer ~= player then
            if inst._lightplayer ~= nil then
                OnPlayerDeactivated(world, inst._lightplayer)
            end
            inst._lightplayer = player
            inst:ListenForEvent("enablelightsdirty", OnEnableLightsDirty)
            if inst._enablelights:value() then
                OnEnableLightsDirty(inst)
            end
        end
    end

    inst:ListenForEvent("playeractivated", OnPlayerActivated, TheWorld)
    inst:ListenForEvent("playerdeactivated", OnPlayerDeactivated, TheWorld)

    if ThePlayer ~= nil then
        OnPlayerActivated(TheWorld, ThePlayer)
    end
end

local function OnInit(inst)
    if not TheNet:IsDedicated() then
        SetupLights(inst)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("sdf_time_rune_hall_of_heroes")
    inst.AnimState:SetBuild("sdf_time_rune_hall_of_heroes")
    inst.AnimState:PlayAnimation("idle_activate", false)

    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)

    inst:AddTag("resurrector")
    inst:AddTag("antlion_sinkhole_blocker")

    inst._enablelights = net_bool(inst.GUID, "sdf_time_rune_hall_of_heroes._enablelights", "enablelightsdirty")
    inst._enablelights:set(true)

    inst.entity:SetPristine()

    inst:DoTaskInTime(0, OnInit)

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(1.2,1.4)
    inst.components.playerprox:SetOnPlayerNear(runestoneturnon)

    inst:AddComponent("inspectable")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_INSTANT_REZ)
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

    inst:AddComponent("cooldown")
    inst.components.cooldown.cooldown_duration = (TUNING.SDF_TIME_RUNE_HALL_OF_HEROES_REVIVE_COOLDOWN * TUNING.TOTAL_DAY_TIME)
    inst.components.cooldown.onchargedfn = OnCharged
    inst.components.cooldown.startchargingfn = OnStartCharging
    inst.components.cooldown.charged = true

    inst._task = nil

    return inst
end

return Prefab("sdf_time_rune_hall_of_heroes",fn,assets)