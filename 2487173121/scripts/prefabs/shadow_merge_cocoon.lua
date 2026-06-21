local assets = {
    Asset("ANIM", "anim/spider_cocoon.zip"),
}
local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddGroundCreepEntity()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank("spider_cocoon")
    inst.AnimState:SetBuild("spider_cocoon")
    inst.AnimState:PlayAnimation("cocoon_small", true)
    inst.AnimState:SetMultColour(0.3, 0.1, 0.4, 0.9)
    inst:AddTag("NOCLICK")
    inst:AddTag("FX")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.persists = false
    inst.GroundCreepEntity:SetRadius(6)
    return inst
end
return Prefab("shadow_merge_cocoon", fn, assets)
