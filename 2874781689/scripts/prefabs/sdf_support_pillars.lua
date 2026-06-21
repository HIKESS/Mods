local assets=
{
    Asset("ATLAS", "images/map_icons/sdf_support_stone_pillar_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_support_stone_pillar_mm.tex"),

    Asset("ANIM", "anim/sdf_support_stone_pillar.zip"),
}

prefabs = {
}

local PF_DIMS = 4 --equal to 4x4 grid of walls

local function UnregisterPathFinding(inst)
    local x = inst._pfpos.x - (PF_DIMS - 1) / 2
    local z = inst._pfpos.z - (PF_DIMS - 1) / 2
    local pathfinder = TheWorld.Pathfinder
    for i = 0, PF_DIMS - 1 do
	for j = 0, PF_DIMS - 1 do
	    pathfinder:RemoveWall(x + i, 0, z + j)
	end
    end
end

local function RegisterPathFinding(inst)
    inst._pfpos = inst:GetPosition()
    local x = inst._pfpos.x - (PF_DIMS - 1) / 2
    local z = inst._pfpos.z - (PF_DIMS - 1) / 2
    local pathfinder = TheWorld.Pathfinder
    for i = 0, PF_DIMS - 1 do
	for j = 0, PF_DIMS - 1 do
	    pathfinder:AddWall(x + i, 0, z + j)
	end
    end
    inst.OnRemoveEntity = UnregisterPathFinding
end

--------------------------------------------------------------------------

local PHYSICS_RADIUS = 1.35

--------------------------------------------------------------------------

local DEBRIS_FX =
{
    HIT = 1,
    QUAKE = 2,
    COLLAPSE = 3,
}

local function OnDebrisFXDirty(inst)
    if inst._debrisfx:value() == 0 then
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

    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())

    fx.AnimState:SetBank(inst.debrisbank)
    fx.AnimState:SetBuild(inst.debrisbuild)
    fx.AnimState:SetFinalOffset(1)

    fx.persists = false

    if inst._debrisfx:value() == DEBRIS_FX.COLLAPSE then
	fx.Transform:SetEightFaced()
	fx.AnimState:PlayAnimation("collapse_top")

	--if inst.debrisbuild == "support_pillar_dreadstone" then
	    --fx.AnimState:SetSymbolLightOverride("pillar_pieces_red", 1)
	    --fx.AnimState:SetSymbolLightOverride("pillar_pieces_red_90", 1)
	--end

	ErodeAway(fx, 1)
    else
	fx.entity:AddSoundEmitter()
	fx.SoundEmitter:PlaySound("meta2/pillar/pillar_quake")
	fx.AnimState:PlayAnimation(inst._debrisfx:value() == 2 and "quake_debris" or "hit_debris")
	fx:ListenForEvent("animover", fx.Remove)
    end
end

local function PushDebrisFX(inst, fxlevel)
    --force dirty
    inst._debrisfx:set_local(fxlevel)
    inst._debrisfx:set(fxlevel)

    --Dedicated server does not need to spawn the local fx
    if not TheNet:IsDedicated() then
	OnDebrisFXDirty(inst)
    end
end

local function DoQuake(inst)
    inst._quaketask = nil
    local oldsuffix = inst.suffix
    if inst.AnimState:IsCurrentAnimation("collapse") then
	return
    elseif inst.suffix ~= "_4" then
	inst.AnimState:PlayAnimation("idle_quake"..inst.suffix)
	PushDebrisFX(inst, DEBRIS_FX.QUAKE)
    elseif oldsuffix ~= "_4" then
	inst.AnimState:PlayAnimation("idle_quake"..oldsuffix)
	PushDebrisFX(inst, DEBRIS_FX.QUAKE)
	inst.components.workable:SetWorkable(false)
    end
end

local function SetEnableWatchQuake(inst, enable, keeptask)
    if enable then
	if inst._onquake == nil then
	    inst._onquake = function(_, data)
		if inst._quaketask ~= nil then
		    inst._quaketask:Cancel()
		end
		--delay till the first camera shake period
		inst._quaketask = inst:DoTaskInTime(data ~= nil and data.debrisperiod or 0, DoQuake)
	    end
	    inst:ListenForEvent("startquake", inst._onquake, TheWorld.net)
	end
    else
	if inst._onquake ~= nil then
	    inst:RemoveEventCallback("startquake", inst._onquake, TheWorld.net)
	    inst._onquake = nil
	end
	if inst._quaketask ~= nil and not keeptask then
	    inst._quaketask:Cancel()
	    inst._quaketask = nil
	end
    end
end

local function UpdateLevel(inst)
    inst._level:set(inst.reinforced)
    inst.suffix = inst._level:value() > 0 and "_"..tostring(inst._level:value()) or ""
    inst.AnimState:PlayAnimation("idle"..inst.suffix)

    if inst.suffix == "_4" then
	inst:RemoveTag("quake_blocker")
    else
	inst:AddTag("quake_blocker")
    end
    if not inst:IsAsleep() then
	SetEnableWatchQuake(inst, inst.suffix ~= "_4")
    end
end

local function OnEntitySleep(inst)
    SetEnableWatchQuake(inst, false, true)
end

local function OnEntityWake(inst)
    if inst.suffix ~= "_4" then
	SetEnableWatchQuake(inst, true)
    end
end

local function IsQuakeAnim(inst)
    return inst.AnimState:IsCurrentAnimation("idle_quake")
	or inst.AnimState:IsCurrentAnimation("idle_quake_1")
	or inst.AnimState:IsCurrentAnimation("idle_quake_2")
	or inst.AnimState:IsCurrentAnimation("idle_quake_3")
end

local function IsHitAnim(inst)
    return inst.AnimState:IsCurrentAnimation("idle_hit")
	or inst.AnimState:IsCurrentAnimation("idle_hit_1")
	or inst.AnimState:IsCurrentAnimation("idle_hit_2")
	or inst.AnimState:IsCurrentAnimation("idle_hit_3")
end

local function OnAnimOver(inst)
    local collapsing = inst.AnimState:IsCurrentAnimation("collapse")
    if not collapsing then
	if inst.AnimState:IsCurrentAnimation("build") then
	    inst.AnimState:ClearAllOverrideSymbols()
	elseif not (IsHitAnim(inst) or IsQuakeAnim(inst)) then
	    return
	end
    end
    if inst.suffix == "_4" and not collapsing then
	inst.AnimState:PlayAnimation("collapse")
	inst.SoundEmitter:PlaySound("meta2/pillar/pillar_collapse")
    else
	if collapsing and inst.suffix == "_4" then
	    PushDebrisFX(inst, DEBRIS_FX.COLLAPSE)
	end
	inst.AnimState:PlayAnimation("idle"..inst.suffix)
	inst.components.workable:SetWorkable(true)
    end
end

local function onhit(inst, worker, workleft, numworks)
    if numworks <= 0 then
	return
    end
    local oldsuffix = inst.suffix
    if IsQuakeAnim(inst) then
	if inst.AnimState:GetCurrentAnimationFrame() < 15 then
	    return
	end
    elseif inst.AnimState:IsCurrentAnimation("collapse") then
	return
    elseif inst.suffix ~= "_4" then
	inst.AnimState:PlayAnimation("idle_hit"..inst.suffix)
	if inst.suffix ~= oldsuffix then
	    PushDebrisFX(inst, DEBRIS_FX.HIT)
	end
    elseif oldsuffix ~= "_4" then
	inst.AnimState:PlayAnimation("idle_hit_3")
	if inst.suffix ~= oldsuffix then
	    PushDebrisFX(inst, DEBRIS_FX.HIT)
	end
	inst.components.workable:SetWorkable(false)
    end
end

local function onhammered(inst)
    local pt = inst:GetPosition()
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(pt:Get())
    fx:SetMaterial("rock")

    inst.components.workable:SetWorkLeft(1000)
end

local function OnSave(inst, data)
    data.reinforced = inst.reinforced
end

local function OnLoad(inst, data, ents)
    if data ~= nil and data.reinforced ~= nil then
	inst.reinforced = data.reinforced
    end
    UpdateLevel(inst)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("sdf_support_stone_pillar_mm.tex")
    inst.MiniMapEntity:SetPriority(3)

    MakeObstaclePhysics(inst, PHYSICS_RADIUS, 6)
    inst.Physics:SetDontRemoveOnSleep(true)

    inst.Transform:SetEightFaced()

    local s = 0.9 --0.9
    inst.Transform:SetScale(s,s,s)

    inst.AnimState:SetBank("sdf_support_stone_pillar")
    inst.AnimState:SetBuild("sdf_support_stone_pillar")
    inst.AnimState:PlayAnimation("idle_4")

    --if build == "support_pillar_dreadstone" then
	--inst.AnimState:SetSymbolLightOverride("pillar_pieces_red", 1)
	--inst.AnimState:SetSymbolLightOverride("pillar_pieces_red_90", 1)
    --end

    inst:AddTag("structure")
    inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("sdf_lava_pond_immune")

    inst._level = net_tinybyte(inst.GUID, "sdf_support_stone_pillar._level", "leveldirty")

    inst._debrisfx = net_tinybyte(inst.GUID, "sdf_support_stone_pillar._debrisfx", "debrisfxdirty")
    inst.debrisbank = "sdf_support_stone_pillar"
    inst.debrisbuild = "sdf_support_stone_pillar"

    inst:DoTaskInTime(0, RegisterPathFinding)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	inst:DoTaskInTime(0, inst.ListenForEvent, "debrisfxdirty", OnDebrisFXDirty)

	return inst
    end

    inst.reinforced = 4 --0-4
    UpdateLevel(inst)

    inst:AddComponent("inspectable")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1000)
    inst.components.workable:SetOnWorkCallback(onhit)
    inst.components.workable:SetOnFinishCallback(onhammered)

    inst:ListenForEvent("animover", OnAnimOver)
    inst:ListenForEvent("onsink", onhammered)

    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("sdf_support_stone_pillar", fn, assets, prefabs)

	--dreadstone
	--MakePillar("support_pillar_dreadstone", "support_pillar_dreadstone", "support_pillar_dreadstone")