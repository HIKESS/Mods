local assets =
{
    Asset("ANIM", "anim/sdf_dragon_potion_dragonfire_fx.zip"),
    Asset("ANIM", "anim/sdf_dragon_potion_dragonfire_smoke_fx.zip"),
    Asset("ANIM", "anim/sdf_dragon_potion_dragonfire_burntground_fx.zip"),
}

local prefabs =
{
	--"sdf_dragon_potion_dragonfire_ember_fx",
}

local breathlevels =
{
    {anim="pre", sound="dontstarve_DLC001/creatures/dragonfly/firedup", "fireflying", radius=2, intensity=.8, falloff=.33, colour = {253/255,179/255,179/255}, soundintensity=.1},
}

--------------------------------------------------------------------------

local function GetBreathHeatFn(inst)
    return TUNING.SDF_DRAGON_POTION_DRAGONFIRE_BREATH_HEAT
end

local function setFire(inst, target, owner)
    if target then

	--fuelsource
	if target.components.burnable and target.components.fueled and target:HasTag("campfire") and target:HasTag("structure") then
	    if target.components.burnable:IsBurning() then
		target.components.fueled:DoDelta(TUNING.SDF_DRAGON_POTION_DRAGONFIRE_BREATH_FUEL, owner)
	    else

		--Fully fuels Riddle Firepit
		if target.prefab == "sdf_jack_of_the_green_riddle_firepit" then
		    local fuel = SpawnPrefab("cutgrass")
		    if fuel then
			fuel.components.fuel.fuelvalue = TUNING.SDF_JACK_OF_THE_GREEN_RIDDLE_FIREPIT_FUEL_MAX
			target.components.fueled:TakeFuelItem(fuel)
		    end
		    return
		else
		    target.components.burnable:Ignite(true)
		end
	    end

	--just burn
	elseif target.components.burnable and not target.components.burnable:IsBurning() then
	
	    --from frozen
	    if target.components.freezable and target.components.freezable:IsFrozen() then
		target.components.freezable:Unfreeze()
	    else
		target.components.burnable:Ignite(true)
	    end

	    --warm up
	    if target.components.freezable then
		target.components.freezable:AddColdness(-1) --Does this break ice staff?
		if target.components.freezable:IsFrozen() then
		    target.components.freezable:Unfreeze()
		end
	    end
	end
    end
end

local AOE_RANGE = 0.9
local AOE_RANGE_PADDING = 2 --3
local AOE_TARGET_TAGS = {}--{ "_combat" }
local AOE_TARGET_CANT_TAGS = { "INLIMBO", "invisible", "playerghost","companion"}
local AOE_TARGET_CANT_TAGS_PVE = { "INLIMBO", "invisible", "player","companion", "wall" }
local AOE_TARGET_CANT_TAGS_PVP = { "INLIMBO", "invisible", "playerghost", "wall" }
local MULTIHIT_FRAMES = 10

local function OnUpdateHitbox(inst)
    if not (inst.attacker and inst.attacker.components.combat and inst.attacker:IsValid()) then
	return
    end

    local weapon
    if inst.owner ~= inst.attacker then
	if not (inst.owner and inst.owner:IsValid()) then
	    return
	elseif inst.owner.components.weapon then
	    weapon = inst.owner
	end
    end

    local cant_tags =
	(not inst.attacker:HasTag("player") and AOE_TARGET_CANT_TAGS) or
	(TheNet:GetPVPEnabled() and AOE_TARGET_CANT_TAGS_PVP) or 
	AOE_TARGET_CANT_TAGS_PVE

    inst.attacker.components.combat.ignorehitrange = true
    inst.attacker.components.combat.ignoredamagereflect = true
    local tick = GetTick()
    local x, y, z = inst.Transform:GetWorldPosition()
    local radius = AOE_RANGE * inst.scale
    local ents = TheSim:FindEntities(x, 0, z, radius + AOE_RANGE_PADDING, AOE_TARGET_TAGS, cant_tags)
    for i, v in ipairs(ents) do	

	if v ~= inst.attacker and v:IsValid() and not v:IsInLimbo() and not (v.components.health and v.components.health:IsDead()) then
			
	    if not inst.attacker:HasTag("player") or not inst.attacker.components.combat:IsAlly(v) then		

		local range = radius + v:GetPhysicsRadius(0)
		if v:GetDistanceSqToPoint(x, 0, z) < range * range then
		    local target_data = inst.targets[v]
		    if target_data == nil then
			target_data = {}
			inst.targets[v] = target_data
		    end
		    if target_data.tick ~= tick then
			target_data.tick = tick

			--Burn
			setFire(inst, v, inst.attacker)

			--Hit
			if (target_data.hit_tick == nil or target_data.hit_tick + MULTIHIT_FRAMES < tick) and inst.attacker.components.combat:CanTarget(v) then
			    target_data.hit_tick = tick
			    inst.attacker.components.combat:DoAttack(v, weapon)
			end
		    end
		end
	    end
	end
    end

    inst.attacker.components.combat.ignorehitrange = false
    inst.attacker.components.combat.ignoredamagereflect = false
end

local function RefreshBrightness(inst)
    local k = math.min(1, inst.brightness:value() / 6) --6) --2
    inst.AnimState:OverrideBrightness(1 + k * k * 0.5)
end

local function OnUpdateBrightness(inst)
    inst.brightness:set_local(inst.brightness:value() - 1)
    if inst.brightness:value() <= 0 then
	inst.updatingbrightness = false
	inst.components.updatelooper:RemoveOnUpdateFn(OnUpdateBrightness)
    end
    RefreshBrightness(inst)
end

local function OnBrightnessDirty(inst)
    RefreshBrightness(inst)
    if inst.brightness:value() > 0 and inst.brightness:value() < 7 then--7 then --3
	if not inst.updatingbrightness then
	    inst.updatingbrightness = true
	    inst.components.updatelooper:AddOnUpdateFn(OnUpdateBrightness)
	end
    elseif inst.updatingbrightness then
	inst.updatingbrightness = false
	inst.components.updatelooper:RemoveOnUpdateFn(OnUpdateBrightness)
    end
end

local function StartFade(inst)
    inst.brightness:set(6) --6) --2
    OnBrightnessDirty(inst)
end

local function KillFX(inst, fadeoption)
    if fadeoption == "nofade" then
	StartFade(inst)
    end

    inst.components.updatelooper:RemoveOnUpdateFn(OnUpdateHitbox)
    inst.targets = nil

    if inst.embers ~= nil then
	if inst.embers:IsValid() then
	    inst.embers:KillFX()
	end
	inst.embers = nil
    end
end

local function SetFXOwner(inst, owner, attacker)
    inst.owner = owner
    inst.attacker = attacker or owner
end

local function SpawnEmbers(inst, scale, fadeoption)
    local x, y, z = inst.Transform:GetWorldPosition()
    if not TheWorld.Map:IsPassableAtPoint(x, 0, z) then
	return
    elseif inst.embers ~= nil and inst.embers:IsValid() then
	inst.embers:KillFX()
    end

    inst.embers = inst.owner ~= nil and inst.owner.ember_pool ~= nil and table.remove(inst.owner.ember_pool) or nil
    if inst.embers == nil then
	inst.embers = SpawnPrefab("sdf_dragon_potion_dragonfire_ember_fx")
	inst.embers:SetFXOwner(inst.owner)
    end

    inst.embers.Transform:SetPosition(x, 0, z)
    inst.embers:RestartFX(scale, fadeoption)
end

local function RestartFX(inst, scale, fadeoption, targets)
    if inst:IsInLimbo() then
	inst:ReturnToScene()
    end

    if not inst.AnimState:IsCurrentAnimation("pre") then
	inst.AnimState:PlayAnimation("pre") --"pre"
    end

    inst.scale = scale or 1
    inst.AnimState:SetScale(math.random() < 0.5 and -inst.scale or inst.scale, inst.scale)

    if fadeoption == "latefade" then
	inst:DoTaskInTime(10 * FRAMES, StartFade)
    elseif fadeoption ~= "nofade" then
	StartFade(inst)
    end
    inst:DoTaskInTime(2 * FRAMES, SpawnEmbers, inst.scale * 1.1, fadeoption)
    inst:DoTaskInTime(math.random(18, 22) * FRAMES, KillFX, fadeoption)

    if inst.embers ~= nil then
	if inst.embers:IsValid() then
	    inst.embers:KillFX()
	end
	inst.embers = nil
    end

    if inst.owner ~= nil then
	inst.targets = targets or {}
	inst.components.updatelooper:AddOnUpdateFn(OnUpdateHitbox)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    local s = 0.5 --0.8
    inst.Transform:SetScale(s,s,s)

    inst.AnimState:SetBank("flamethrow_fx")
    inst.AnimState:SetBuild("flamethrow_fx")
    inst.AnimState:PlayAnimation("pre",false)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetLightOverride(0.1)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.brightness = net_tinybyte(inst.GUID, "sdf_dragon_potion_dragonfire_fx.brightness", "brightnessdirty")
    inst.brightness:set(7) --7 --3
    --inst.updatingbrightness = false
    OnBrightnessDirty(inst)

    inst:AddComponent("updatelooper")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	inst:ListenForEvent("brightnessdirty", OnBrightnessDirty)
	return inst
    end

    inst:AddComponent("firefx")
    inst.components.firefx.levels = breathlevels
    inst.components.firefx:SetLevel(1)

    inst:AddComponent("heater")
    inst.components.heater.heatfn = GetBreathHeatFn

    --inst:DoTaskInTime(10/30,function()
	--local x,y,z= inst.Transform:GetWorldPosition()
	--SpawnPrefab("deerclops_laserscorch").Transform:SetPosition(x, 0, z)
    --end)

    inst:ListenForEvent("animover", function()
        if inst.AnimState:IsCurrentAnimation("pre") then
            inst:Remove()
        end
    end)

    inst.persists = false
    inst.SetFXOwner = SetFXOwner
    inst.RestartFX = RestartFX

    RestartFX(inst)

    return inst
end

--------------------------------------------------------------------------

local function ember_OnFizzle(inst, rnd)
    if rnd >= 56 then
	return
    end

    local fx = CreateEntity()

    fx:AddTag("FX")
    fx:AddTag("NOCLICK")

    --[[Non-networked entity]]
    fx.entity:SetCanSleep(false)
    fx.persists = false

    fx.entity:AddTransform()
    fx.entity:AddAnimState()
    fx.entity:AddFollower()

    fx.AnimState:SetBank("sdf_dragon_potion_dragonfire_smoke_fx")
    fx.AnimState:SetBuild("sdf_dragon_potion_dragonfire_smoke_fx")

    --rnd [0, 56)
    local animvariation = rnd < 28 and "1" or "2"
    rnd = rnd % 28

    --rnd [0, 28)
    if rnd < 14 then
	fx.AnimState:PlayAnimation("ember"..animvariation.."_float")
	fx.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    else
	fx.AnimState:PlayAnimation("smoke"..animvariation.."_float")
    end
    rnd = rnd % 14

    --rnd [0, 14)
    local flip = rnd >= 7
    rnd = rnd % 7

    --rnd [0, 7)
    local scale = 0.25 + 0.75 * rnd / 6
    fx.AnimState:SetScale(flip and -scale or scale, scale)

    fx:ListenForEvent("animover", fx.Remove)

    fx.Follower:FollowSymbol(inst.GUID, "swap_fizzle")
end

---------------------------------------------------------------------------

local function GetEmberHeatFn(inst)
    return TUNING.SDF_DRAGON_POTION_DRAGONFIRE_EMBER_HEAT
end

local function ember_RefreshFade(inst)
    --Unfortunately there is no local "Override" version for SetSymbolMultColour
    local k = inst.fade:value()
    if k < 3 then
	local k1 = 1 - k / 3
	inst.AnimState:OverrideMultColour(1, 1, 1, k1)
	inst.AnimState:SetSymbolMultColour("track", 1, 1, 1, 0)
    else
	if k < 33 then
	    inst.AnimState:OverrideMultColour(1, 1, 1, 1)
	else
	    local k1 = (k - 33) / 30
	    inst.AnimState:OverrideMultColour(1, 1, 1, 1 - k1 * k1)
	end
	if k < 8 then --8
	    local k1 = 1 - (k - 2) / 6
	    inst.AnimState:SetSymbolMultColour("track", 1, 1, 1, 1 - k1 * k1)
	elseif k < 18 then
	    inst.AnimState:SetSymbolMultColour("track", 1, 1, 1, 1)
	elseif k < 38 then
	    local k1 = (k - 18) / 20
	    inst.AnimState:SetSymbolMultColour("track", 1, 1, 1, 1 - k1 * k1)
	else
	    inst.AnimState:SetSymbolMultColour("track", 1, 1, 1, 0)
	end
    end
end

local function ember_OnUpdate(inst)
    if inst.fade:value() <= 1 then
	inst.fade:set(0)
	inst.updating = false
	inst.components.updatelooper:RemoveOnUpdateFn(ember_OnUpdate)
    elseif inst.fade:value() < 3 then
	inst.fade:set_local(inst.fade:value() - 1)
    elseif inst.fade:value() < 63 then
	inst.fade:set_local(inst.fade:value() + 1)
	--Dedicated server does not need to spawn the local fx
	if inst.fade:value() == 8 and not TheNet:IsDedicated() then --8
	    ember_OnFizzle(inst, inst.fizzle:value())
	end
    elseif not TheWorld.ismastersim then
	inst.updating = false
	inst.components.updatelooper:RemoveOnUpdateFn(ember_OnUpdate)
    elseif inst.owner ~= nil and inst.owner.ember_pool ~= nil then
	inst.updating = false
	inst.components.updatelooper:RemoveOnUpdateFn(ember_OnUpdate)
	inst:RemoveFromScene()
	table.insert(inst.owner.ember_pool, inst)
	return
    else
	inst:Remove()
	return
    end
    ember_RefreshFade(inst)
end

local function ember_OnFadeDirty(inst)
    ember_RefreshFade(inst)
    if inst.fade:value() > 0 then
	if not inst.updating then
	    inst.updating = true
	    inst.components.updatelooper:AddOnUpdateFn(ember_OnUpdate)
	end
    elseif inst.updating then
	inst.updating = false
	inst.components.updatelooper:RemoveOnUpdateFn(ember_OnUpdate)
    end
end

local function ember_SetFXOwner(inst, owner)
    inst.owner = owner
end

local function ember_RestartFX(inst, scale, fadeoption)
    if inst:IsInLimbo() then
	inst:ReturnToScene()
    end

    if fadeoption == "nofade" then
	inst.AnimState:SetSymbolMultColour("hash", 1, 1, 1, .9 + math.random() * .1)
    elseif fadeoption == "latefade" then
	inst.AnimState:SetSymbolMultColour("hash", 1, 1, 1, .7 + math.random() * .15)
    else
	inst.AnimState:SetSymbolMultColour("hash", 1, 1, 1, .45 + math.random() * .15)
    end

    local anim = "ember"..tostring(math.random(4)).."_ground" --this here
    if not inst.AnimState:IsCurrentAnimation(anim) then
	inst.AnimState:PlayAnimation(anim, true)
    end
    inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)

    local rnd = math.random(4)
    if rnd == 2 or rnd == 4 then
	inst.AnimState:Hide("ember1")
    else
	inst.AnimState:Show("ember1")
    end
    if rnd == 3 or rnd == 4 then
	inst.AnimState:Hide("ember2")
	inst.fizzle:set(63) --hidden
    else
	inst.AnimState:Show("ember2")
	if fadeoption == "nofade" then
	    inst.fizzle:set(63) --no fizzles when close to the head
	else
	    inst.fizzle:set(math.min(63, math.random(96) - 1))
	end
    end

    inst.fade:set(2)
    ember_OnFadeDirty(inst)
end

local function ember_KillFX(inst)
    if inst.fade:value() < 3 then
	inst.fade:set(3)
	ember_OnFadeDirty(inst)
    end
end

local function emberfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("sdf_dragon_potion_dragonfire_smoke_fx")
    inst.AnimState:SetBuild("sdf_dragon_potion_dragonfire_smoke_fx")
    inst.AnimState:PlayAnimation("ember1_ground", true) --"ember1_ground", true flame3_pst

    inst.AnimState:SetSymbolBloom("track")
    inst.AnimState:SetSymbolLightOverride("track", 0.1)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    local scale = math.random()
    if scale < 0.7 then
	inst.AnimState:SetScale(scale, scale, scale)
    else
	inst.AnimState:SetScale(0.7, 0.7, 0.7)
    end
    inst.Transform:SetRotation(math.random() * 360)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.fade = net_smallbyte(inst.GUID, "sdf_dragon_potion_dragonfire_ember_fx.fade", "fadedirty")
    inst.fizzle = net_smallbyte(inst.GUID, "sdf_dragon_potion_dragonfire_ember_fx.fizzle")

    inst:AddComponent("updatelooper")
    --inst.updating = false

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	inst:ListenForEvent("fadedirty", ember_OnFadeDirty)
	return inst
    end

    inst:AddComponent("heater")
    inst.components.heater.heatfn = GetEmberHeatFn

    inst:ListenForEvent("animover", function()
	inst:DoTaskInTime(1,function()
	    local x,y,z= inst.Transform:GetWorldPosition()
	    local scorchfx = SpawnPrefab("sdf_dragon_potion_dragonfire_scorch_fx")
	    if scale < 0.4 then
		scorchfx.AnimState:SetScale(0.4, 0.4, 0.4)
	    elseif scale < 0.8 then
		scorchfx.AnimState:SetScale(scale, scale, scale)
	    else
		scorchfx.AnimState:SetScale(0.8, 0.8, 0.8)
	    end
	    scorchfx.Transform:SetPosition(x, 0, z)
	end)
    end)

    inst.persists = false
    inst.SetFXOwner = ember_SetFXOwner
    inst.RestartFX = ember_RestartFX
    inst.KillFX = ember_KillFX

    ember_RestartFX(inst)

    return inst
end
--------------------------------------------------------------------------

local SCORCH_RED_FRAMES = 20
local SCORCH_DELAY_FRAMES = 40
local SCORCH_FADE_FRAMES = 15

local function Scorch_OnFadeDirty(inst)
    --V2C: hack alert: using SetHightlightColour to achieve something like OverrideAddColour
    --     (that function does not exist), because we know this FX can never be highlighted!
    if inst._fade:value() > SCORCH_FADE_FRAMES + SCORCH_DELAY_FRAMES then
        local k = (inst._fade:value() - SCORCH_FADE_FRAMES - SCORCH_DELAY_FRAMES) / SCORCH_RED_FRAMES
        inst.AnimState:OverrideMultColour(1, 1, 1, 1)
        inst.AnimState:SetHighlightColour(k, 0, 0, 0)
    elseif inst._fade:value() >= SCORCH_FADE_FRAMES then
        inst.AnimState:OverrideMultColour(1, 1, 1, 1)
        inst.AnimState:SetHighlightColour()
    else
        local k = inst._fade:value() / SCORCH_FADE_FRAMES
        k = k * k
        inst.AnimState:OverrideMultColour(1, 1, 1, k)
        inst.AnimState:SetHighlightColour()
    end
end

local function Scorch_OnUpdateFade(inst)
    if inst._fade:value() > 1 then
        inst._fade:set_local(inst._fade:value() - 1)
        Scorch_OnFadeDirty(inst)
    elseif TheWorld.ismastersim then
        inst:Remove()
    elseif inst._fade:value() > 0 then
        inst._fade:set_local(0)
        inst.AnimState:OverrideMultColour(1, 1, 1, 0)
    end
end

local function scorchfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("sdf_dragon_potion_dragonfire_burntground_fx")
    inst.AnimState:SetBank("sdf_dragon_potion_dragonfire_burntground_fx")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")

    inst._fade = net_byte(inst.GUID, "sdf_dragon_potion_dragonfire_scorch_fx._fade", "scorchfadedirty")
    inst._fade:set(SCORCH_RED_FRAMES + SCORCH_DELAY_FRAMES + SCORCH_FADE_FRAMES)

    inst:DoPeriodicTask(0, Scorch_OnUpdateFade)
    Scorch_OnFadeDirty(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("scorchfadedirty", Scorch_OnFadeDirty)

        return inst
    end

    inst.Transform:SetRotation(math.random() * 360)
    inst.persists = false

    return inst
end
--------------------------------------------------------------------------

return Prefab("sdf_dragon_potion_dragonfire_breath_fx", fn, assets, prefabs),
	Prefab("sdf_dragon_potion_dragonfire_ember_fx", emberfn, assets),
	Prefab("sdf_dragon_potion_dragonfire_scorch_fx", scorchfn, assets)
