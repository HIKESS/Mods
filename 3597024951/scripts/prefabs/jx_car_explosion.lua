local assets = 
{
  Asset("ANIM", "anim/jx_car_explosion.zip"),
}

local function fn()
  local inst = CreateEntity()

  inst.entity:AddTransform()
  inst.entity:AddAnimState()
  inst.entity:AddSoundEmitter()
  inst.entity:AddNetwork()
  
  inst.AnimState:SetBank("jx_car_explosion")
  inst.AnimState:SetBuild("jx_car_explosion")  
  inst.AnimState:PlayAnimation("explosion")
  
  inst.SoundEmitter:PlaySound("jx_car_explosion/jx_car_explosion/explosion")
    
  inst:AddTag("FX")
  inst:AddTag("NOCLICK")

  inst.entity:SetPristine()

  if not TheWorld.ismastersim then
    return inst
  end

  inst:ListenForEvent("animover", inst.Remove)
  
  inst.persists = false
  
  return inst
end

return Prefab("jx_car_explosion", fn, assets)