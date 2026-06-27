local assets = 
{
  Asset("ANIM", "anim/jx_hat_reindeer_fx.zip"),
}

local function Start(inst, data)
  if data.symbolnum == 2 then 
    inst.AnimState:SetSortOrder(-1)
  end
  inst.entity:SetParent(data.owner.entity)
  inst.Follower:FollowSymbol(data.owner.GUID, "swap_hat", data.x, data.y, 0, data.scale, false, data.symbolnum)
  
  inst.AnimState:PlayAnimation("idle"..data.num.."_shake_small")
  inst.AnimState:PushAnimation("idle"..data.num.."_shake_small", false)
  inst:ListenForEvent("animqueueover", function()
    inst.AnimState:PlayAnimation("idle"..data.num.."_shake_small")
    local rnd = math.random(3, 5)
    for i = 2, rnd - 2 do
      inst.AnimState:PushAnimation("idle"..data.num.."_shake_small")
    end
    inst.AnimState:PushAnimation("idle"..data.num.."_shake_middle")
    inst.AnimState:PushAnimation("idle"..data.num.."_shake_large")
    inst.AnimState:PushAnimation("idle"..data.num.."_shake_large")
    inst.AnimState:PushAnimation("idle"..data.num.."_shake_large")
    inst.AnimState:PushAnimation("idle"..data.num.."_shake_middle")
    for i = rnd + 4, 8 do
      inst.AnimState:PushAnimation("idle"..data.num.."_shake_small")
    end
    inst.AnimState:PushAnimation("idle"..data.num.."_shake_small", false)
  end)
end

local function fn()
  local inst = CreateEntity()

  inst.entity:AddTransform()
  inst.entity:AddAnimState()
  inst.entity:AddFollower()
  inst.entity:AddNetwork()
  
  inst.AnimState:SetBank("jx_hat_reindeer_fx")
  inst.AnimState:SetBuild("jx_hat_reindeer_fx")
  inst.AnimState:PlayAnimation("idle1_shake_small")
  inst.AnimState:SetFinalOffset(1)
    
  inst:AddTag("FX")
  inst:AddTag("NOCLICK")

  inst.entity:SetPristine()

  if not TheWorld.ismastersim then
    return inst
  end
  
  inst.Start = Start
  
  inst.persists = false
  
  return inst
end

return Prefab("jx_hat_reindeer_fx", fn, assets)