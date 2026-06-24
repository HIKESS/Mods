local POOL_CONFIG = require("npc/npc_pool_config")
local POOL_ANIM_ZIP = POOL_CONFIG.ANIM_ZIP or "anim/moonglasspool_tile_big.zip"
local POOL_BUILD = POOL_CONFIG.BUILD or "moonglasspool_tile_big"
local POOL_BANK = POOL_CONFIG.BANK or POOL_BUILD
local POOL_IDLE_ANIM = POOL_CONFIG.IDLE_ANIM or "idle"

local assets =
{
    Asset("ANIM", POOL_ANIM_ZIP),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    if MakePondPhysics ~= nil then
        MakePondPhysics(inst, 1.95)
    else
        MakeObstaclePhysics(inst, 1.95)
    end

    inst.AnimState:SetBuild(POOL_BUILD)
    inst.AnimState:SetBank(POOL_BANK)
    inst.AnimState:PlayAnimation(POOL_IDLE_ANIM, true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetLightOverride(0.25)

    inst.MiniMapEntity:SetIcon("grotto_pool_big.png")

    inst:AddTag("pond")
    inst:AddTag("watersource")
    inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("birdblocker")

    inst.no_wet_prefix = true
    inst:SetDeploySmartRadius(5)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.nameoverride = "pond"

    inst:AddComponent("fishable")
    inst.components.fishable:SetRespawnTime(TUNING.FISH_RESPAWN_TIME)
    inst.components.fishable:AddFish("pondfish")

    inst:AddComponent("watersource")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    return inst
end

return Prefab("npc_work_pool_big", fn, assets)
