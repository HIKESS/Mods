local assets =
{
    Asset("ANIM", "anim/jx_car_mark.zip"),
}

local function ontime(inst)
  local life = 30
  local colour = .7
  inst.colour_task = inst:DoPeriodicTask(FRAMES, function()
    if life > 0 then
      life = life - 1
      colour = colour - .7/30
      inst.AnimState:SetMultColour(1, 1, 1, colour)
    else
      if inst.colour_task then
        inst.colour_task:Cancel()
        inst.colour_task = nil
      end
      inst:Remove()
    end
  end)
end

local function fn()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
        
    inst.AnimState:SetBank("jx_car_mark")
    inst.AnimState:SetBuild("jx_car_mark")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	  inst.AnimState:SetLayer(LAYER_BACKGROUND)
	  inst.AnimState:SetSortOrder(3)
        
    inst:AddTag("jx_car_mark")
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
      return inst
    end
    
    inst:DoTaskInTime(1, ontime)
    
    inst.persists = false
    
    return inst
end

return Prefab("jx_car_mark", fn, assets)