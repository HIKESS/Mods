local assets=
{
    Asset("ANIM", "anim/sdf_chest_skull.zip"),

    Asset("ATLAS", "images/map_icons/sdf_chest_skull_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_chest_skull_mm.tex"),
}

prefabs = {
}

local function calculateDamage(inst, affected_entity)
    if affected_entity.components.health then
        local ae_combat = affected_entity.components.combat
        if ae_combat then
            ae_combat:GetAttacked(inst, TUNING.SDF_CHEST_SKULL_AOE_DAMAGE, inst)
        else
            affected_entity.components.health:DoDelta(-TUNING.SDF_CHEST_SKULL_AOE_DAMAGE, nil, inst.prefab, nil, inst)
        end
    end
end

local MUST_HAVE_TAGS = nil
local CANT_HAVE_TAGS = {"player", "playerghost", "INLIMBO", "companion", "ghost", "wall", "noauradamage"}
local AOE_RADIUS = 10

local function aoeCheck(inst)
    local tx, ty, tz = inst.Transform:GetWorldPosition()

    local affected_entity = TheSim:FindEntities(tx, ty, tz, AOE_RADIUS, MUST_HAVE_TAGS, CANT_HAVE_TAGS)
    for i, v in ipairs(affected_entity) do

	--aoe Damage
	calculateDamage(inst,v)
    end
end

local function OnDeath(inst)
    if inst.components.workable then
	inst:RemoveComponent("workable")
    end

    inst.AnimState:PlayAnimation("open")
    inst.AnimState:PushAnimation("removed", true)

    local x,_,z = inst.Transform:GetWorldPosition()
    SpawnPrefab("round_puff_fx_sm").Transform:SetPosition(x,_,z)
    inst:DoTaskInTime(0.5, function()
	--inst.components.lootdropper:DropLoot()
    end)

    inst:DoTaskInTime(0.7, function()
	local x,_,z = inst.Transform:GetWorldPosition()
	SpawnPrefab("maxwell_smoke").Transform:SetPosition(x,_,z)
    end)

    inst:DoTaskInTime(0.8, function()
    	--OrbFX
	local smartBombFX = SpawnPrefab("moon_geyser_explode")
	if smartBombFX then
	    local x,_,z = inst.Transform:GetWorldPosition()
	    smartBombFX.Transform:SetPosition(x,_,z)
	    smartBombFX.Transform:SetScale(0.3,0.3,0.3)
	end
	inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/shocked")
    end)

    inst:DoTaskInTime(1.6, function()
    	--aoeSplashFX
	local smartBombSplashFX = SpawnPrefab("moonpulse2_fx")
	if smartBombSplashFX then
	    local x,_,z = inst.Transform:GetWorldPosition()
	    smartBombSplashFX.Transform:SetPosition(x,_,z)
	    smartBombSplashFX.Transform:SetScale(1.5,1.5,1.5)
	end
	SpawnPrefab("explode_small").Transform:SetPosition(inst.Transform:GetWorldPosition())

	--aoeDamge
	aoeCheck(inst)
    end)

    inst:DoTaskInTime(2.0, function()
	local x,_,z = inst.Transform:GetWorldPosition()
	SpawnPrefab("sdf_chest_skull_empty").Transform:SetPosition(x,_,z)
	inst:Remove()
    end)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_chest_skull_mm.tex")

    inst.AnimState:SetBank("sdf_chest_skull")
    inst.AnimState:SetBuild("sdf_chest_skull")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetBloomEffectHandle("shaders/anim_bloom_ghost.ksh")

    MakeObstaclePhysics(inst, .5)

    inst:AddTag("soulless")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("combat")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(1)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:ListenForEvent("death", OnDeath)

    return inst
end

local function on_day_change(inst)
    local regenerationCount = inst.components.sdf_chest_regeneration:GetRegenerationCount()
    local regenerationCountMax = inst.components.sdf_chest_regeneration:GetMaxRegenerationCount()

    if regenerationCount >= regenerationCountMax then
	local x,_,z = inst.Transform:GetWorldPosition()
	SpawnPrefab("halloween_moonpuff").Transform:SetPosition(x,_,z)
	inst:DoTaskInTime(0.5, function()
	    local x,_,z = inst.Transform:GetWorldPosition()
	     SpawnPrefab("sdf_chest_skull").Transform:SetPosition(x,_,z)
	    inst:Remove()
	end)
    else
	inst.components.sdf_chest_regeneration:SetRegenerationCount(regenerationCount + 1)
    end
end

local function fn2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_chest_skull_mm.tex")

    inst.AnimState:SetBank("sdf_chest_skull")
    inst.AnimState:SetBuild("sdf_chest_skull")
    inst.AnimState:PlayAnimation("removed", true)

    --MakeObstaclePhysics(inst, .5)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --Allows regeneration of Skull Chests
    inst:AddComponent("sdf_chest_regeneration")
    inst.components.sdf_chest_regeneration:SetMaxRegenerationCount(TUNING.SDF_CHEST_SKULL_REGENERATION_DAY_MAX)

    inst:AddComponent("inspectable")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:WatchWorldState("cycles", on_day_change)

    return inst
end

return  Prefab("sdf_chest_skull", fn, assets),
	Prefab("sdf_chest_skull_empty", fn2, assets)