-- 单词"can"在这个文件里面有“罐头”的意思

local ret = {}

local assets =
{
  Asset("ANIM", "anim/jx_can.zip"),
}

local function OnUnwrapped(inst, pos, doer)
  if pos and inst.can_product then
    local product = SpawnPrefab(inst.can_product)
    if product then
      product.Transform:SetPosition(pos:Get())
      if inst.product_percent and product.components.perishable then
        product.components.perishable:SetPercent(inst.product_percent)
      end
      if doer and doer.components.inventory then
        doer.components.inventory:GiveItem(product)
        if doer.userid then
          SendModRPCToClient(GetClientModRPC("JX", "JX_OpenCan"), doer.userid) -- 播放开罐头声音
        end
      elseif product.components.inventoryitem then
        product.components.inventoryitem:OnDropped(true)
      end
      if inst.components.stackable then
        inst.components.stackable:Get():Remove()
      else
        inst:Remove()
      end
    end
  end
end

local function ondestack(new, inst)
  new.product_percent = inst.product_percent
end

local function OnSave(inst, data)
  if inst.product_percent then
    data.product_percent = inst.product_percent
  end
end

local function OnLoad(inst, data)
  if data then
    if data.product_percent then
      inst.product_percent = data.product_percent
    end
  end
end
  
local function MakeCan(prefab_name, product)
  local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("jx_can")
    inst.AnimState:SetBuild("jx_can")
    inst.AnimState:PlayAnimation(prefab_name)
    
    inst:AddTag("bundle")
    inst:AddTag("unwrappable")
    inst:AddTag("jx_can")
    
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = 1
    
    inst:AddComponent("unwrappable")
    inst.components.unwrappable:SetOnUnwrappedFn(OnUnwrapped)
    
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM
    inst.components.stackable:SetOnDeStack(ondestack)
    
    MakeHauntableLaunch(inst)
    
    inst.can_product = product
    inst.product_percent = 1 -- 0 ~ 1，代表产品的新鲜度，在生成时修改
    
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    
    return inst
  end
  
  table.insert(ret, Prefab(prefab_name, fn, assets))
end

--    prefab_name, product
MakeCan("jx_can0", "kelp_dried") -- 海带罐头
MakeCan("jx_can1", "meat_dried") -- 肉罐头
MakeCan("jx_can2", "fishmeat_dried") -- 鱼干罐头

return unpack(ret)