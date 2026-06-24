
local assets = {
    Asset("ANIM", "anim/wormwood_plant_fx.zip"),
}

local function HasBloomingPlantkinNearby(x, y, z)
    for _, v in ipairs(AllPlayers) do
        if v.fullbloom
           and v:HasTag("plantkin")
           and not (v.components.health:IsDead() or v:HasTag("playerghost"))
           and v.entity:IsVisible()
           and v:GetDistanceSqToPoint(x, y, z) < 4 then
            return true
        end
    end
    for _, v in ipairs(TheSim:FindEntities(x, y, z, 2, { "plantkin" }, { "INLIMBO", "NOCLICK" })) do
        if v:HasTag("npcfriend")
           and v.fullbloom
           and not v._is_ghost_mode
           and not (v.components.health and v.components.health:IsDead())
           and v.entity:IsVisible() then
            return true
        end
    end
    return false
end

local function OnAnimOver(inst)
    if inst.AnimState:IsCurrentAnimation("ungrow_" .. tostring(inst.variation)) then
        inst:Remove()
        return
    end
    local x, y, z = inst.Transform:GetWorldPosition()
    if HasBloomingPlantkinNearby(x, y, z) then
        inst.AnimState:PlayAnimation("idle_" .. tostring(inst.variation))
    else
        inst.AnimState:PlayAnimation("ungrow_" .. inst.variation)
    end
end

local function SetVariation(inst, variation)
    if inst.variation ~= variation then
        inst.variation = variation
        inst.AnimState:PlayAnimation("grow_" .. tostring(variation))
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("wormwood_plant_fx")
    inst:AddTag("npc_wormwood_plant_fx")

    inst.AnimState:SetBuild("wormwood_plant_fx")
    inst.AnimState:SetBank("wormwood_plant_fx")
    inst.AnimState:PlayAnimation("grow_1")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.variation = 1
    inst.SetVariation = SetVariation
    inst:ListenForEvent("animover", OnAnimOver)
    inst.persists = false

    return inst
end

return Prefab("npc_wormwood_plant_fx", fn, assets)
