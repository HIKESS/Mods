local assets =
{
  Asset("ANIM", "anim/jx_cabinet.zip"),
}

local prefabs = 
{
  "collapse_big",
  "jx_cabinet_front",
}

local function AddDecor(inst, data)
  if data and data.slot and data.item and not inst:HasTag("burnt") then
    if inst["decor_"..data.slot] and inst["decor_"..data.slot]:IsValid() then
      inst["decor_"..data.slot]:Remove()
    end
    local copy_item = SpawnPrefab(data.item.prefab, data.item:GetSkinBuild(), data.item.skin_id)
    if copy_item == nil then return end
    copy_item.AnimState:SetScale(.5, .5, .5)
    copy_item.Transform:SetPosition(inst.Transform:GetWorldPosition())
    if copy_item.Follower == nil then
      copy_item.entity:AddFollower()
    end
    copy_item.Follower:FollowSymbol(inst.GUID, "swap_"..data.slot)
    copy_item:AddTag("FX")
    copy_item:AddTag("NOCLICK")
    copy_item:AddTag("INLIMBO")
    copy_item:AddTag("outofreach")
    if copy_item.components.perishable then
      copy_item.components.perishable:StopPerishing()
    end
    if copy_item.sg then
      copy_item.sg:Stop()
    end
    copy_item.persists = false
    inst["decor_"..data.slot] = copy_item
  end
end

local function RemoveDecor(inst, data)
    if data and data.slot and not inst:HasTag("burnt") then
      local decor = inst["decor_"..data.slot]
      if decor and decor:IsValid() then
        decor:Remove()
      end
      inst["decor_"..data.slot] = nil
    end
end

local function onopen(inst)
    if not inst:HasTag("burnt") then
      inst.AnimState:PlayAnimation("open")
      if inst.front ~= nil then
        inst.front.AnimState:PlayAnimation("open")
      end
      inst.SoundEmitter:PlaySound("dontstarve/common/wardrobe_open")
    end
end

local function onclose(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("close")
        if inst.front ~= nil then
          inst.front.AnimState:PlayAnimation("close")
        end
        inst.SoundEmitter:PlaySound("dontstarve/common/wardrobe_close")
    end
end

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end

    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
    end

    inst.components.lootdropper:DropLoot()

    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        if inst.components.container ~= nil then
          inst.components.container:DropEverything()
          inst.components.container:Close()
        end
        
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle", false)
        if inst.front ~= nil then
          inst.front.AnimState:PlayAnimation("hit")
          inst.front.AnimState:PushAnimation("idle", false)
        end
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
    if inst.front ~= nil then
      inst.front.AnimState:PlayAnimation("place")
      inst.front.AnimState:PushAnimation("idle", false)
    end
end

local function onburnt(inst)
  if inst.components.container then
    inst.components.container:DropEverything()
  end
  if inst.front then
    inst.front:Remove()
  end
  inst.AnimState:Show("body")
  DefaultBurntStructureFn(inst)
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
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    
    inst:SetDeploySmartRadius(.5)
    MakeObstaclePhysics(inst, 1)
        
    inst:AddTag("structure")
    inst:AddTag("jx_cabinet")
    
    inst.AnimState:SetBank("jx_cabinet")
    inst.AnimState:SetBuild("jx_cabinet")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetFinalOffset(-1)
    inst.AnimState:Hide("door")
    inst.AnimState:Hide("body")
    
    inst.entity:SetPristine()
    
    if not TheWorld.ismastersim then
        return inst
    end
    
    inst.front = SpawnPrefab("jx_cabinet_front")
    if inst.front ~= nil then
      inst.front.entity:SetParent(inst.entity)
    end
    
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("jx_cabinet")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
    
    inst:AddComponent("preserver")
	  inst.components.preserver:SetPerishRateMultiplier(0)
    
    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)
    
    inst:ListenForEvent("onbuilt", onbuilt)
    inst:ListenForEvent("itemget", AddDecor)
    inst:ListenForEvent("itemlose", RemoveDecor)
    
    MakeMediumBurnable(inst, nil, nil, true)
    inst.components.burnable:SetOnBurntFn(onburnt)
    MakeMediumPropagator(inst)
    
    inst.OnSave = onsave
    inst.OnLoad = onload
    
    return inst
end

local function front_fn()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
            
    inst:AddTag("FX")
    
    inst.AnimState:SetBank("jx_cabinet")
    inst.AnimState:SetBuild("jx_cabinet")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:Hide("inner")
    inst.AnimState:SetFinalOffset(1)
    
    inst.entity:SetPristine()
    
    if not TheWorld.ismastersim then
        return inst
    end
    
    inst.persists = false
    
    return inst
end

return Prefab("jx_cabinet", fn, assets, prefabs),
  Prefab("jx_cabinet_front", front_fn, assets),
  MakePlacer("jx_cabinet_placer", "jx_cabinet", "jx_cabinet", "idle")