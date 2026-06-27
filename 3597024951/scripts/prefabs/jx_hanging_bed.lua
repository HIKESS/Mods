local assets =
{
    Asset("ANIM", "anim/jx_hanging_bed.zip"),
}

local prefabs =
{
  "collapse_big",
}

local function onhammered(inst, worker)
    local collapse_fx = SpawnPrefab("collapse_big")
    collapse_fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    collapse_fx:SetMaterial("wood")
    inst.components.lootdropper:DropLoot()
    inst:Remove()
end

local function StartSpawnColorTask(inst)
  local life = 50
  local color = 0.02
  inst.spawn_colortask = inst:DoPeriodicTask(FRAMES,function()
    if life >= 1 then
      inst.AnimState:SetMultColour(1, 1, 1, color)
      life = life - 1
      color = color + 0.02
    else
      if inst.spawn_colortask then
        inst.spawn_colortask:Cancel()
        inst.spawn_colortask = nil
      end
      inst.AnimState:SetMultColour(1, 1, 1, 1)
    end
  end)
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data and data.burnt then
      inst.components.burnable.onburnt(inst)
    end
end

local function fn()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    
    inst:SetDeploySmartRadius(2)
    --MakeObstaclePhysics(inst, .25)
    
    inst.AnimState:SetBank("jx_hanging_bed")
    inst.AnimState:SetBuild("jx_hanging_bed")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetFinalOffset(-1)
    inst.AnimState:SetMultColour(1, 1, 1, 0)
    
    inst:AddTag("jx_hanging_bed")
    inst:AddTag("structure")
    
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("lootdropper")
    
    inst:AddComponent("jx_hanging_bed")
    
    local workable = inst:AddComponent("workable")
    workable:SetWorkAction(ACTIONS.HAMMER)
    workable:SetWorkLeft(4)
    --workable:SetOnWorkCallback(OnHammer)
    workable:SetOnFinishCallback(onhammered)
    
    MakeMediumBurnable(inst, nil, nil, true)
    MakeMediumPropagator(inst)
    
    inst:ListenForEvent("onbuilt", StartSpawnColorTask)
    
    inst:DoTaskInTime(.1, function()
      if inst.spawn_colortask == nil then
        inst.AnimState:SetMultColour(1, 1, 1, 1)
      end
    end)
    
    inst.OnSave = onsave
    inst.OnLoad = onload
    
    return inst
end

return Prefab("jx_hanging_bed", fn, assets, prefabs),
  MakePlacer("jx_hanging_bed_placer", "jx_hanging_bed", "jx_hanging_bed", "idle")