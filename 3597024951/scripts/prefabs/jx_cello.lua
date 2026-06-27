local assets =
{
    Asset("ANIM", "anim/jx_cello.zip"),
}

local prefabs = 
{
  "collapse_big",
}

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
  if not inst:HasTag("burnt") then
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle", false)
  end
end

local function onbuilt(inst)
  inst.AnimState:PlayAnimation("place")
  inst.AnimState:PushAnimation("idle", false)
end

local function fn()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    --inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    
    inst:SetDeploySmartRadius(.5)
    MakeObstaclePhysics(inst, .5)
    
    inst:AddTag("structure")
    
    inst.AnimState:SetBank("jx_cello")
    inst.AnimState:SetBuild("jx_cello")
    inst.AnimState:PlayAnimation("idle")
    
    inst.entity:SetPristine()
    
    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
    
    inst:ListenForEvent("onbuilt", onbuilt)
    
    MakeHauntable(inst)
    
    --MakeMediumBurnable(inst, nil, nil, true)
    --MakeMediumPropagator(inst)
    
    return inst
end


return Prefab("jx_cello", fn, assets, prefabs),
  MakePlacer("jx_cello_placer", "jx_cello", "jx_cello", "idle")