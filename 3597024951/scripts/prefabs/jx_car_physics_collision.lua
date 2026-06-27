local function oncollision(inst, other)
  if other ~= nil and other:IsValid() and other.Physics 
    and not inst.recently_collision[other] and inst.owner
  then
    inst.recently_collision[other] = true
    inst:DoTaskInTime(1, function()
      if inst.recently_collision then
        inst.recently_collision[other] = nil
      end
    end)
    Launch(other, inst.owner)
  end
end

local function fn()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddNetwork()
    
    inst:AddTag("jx_car_physics_collision")
    
    MakeObstaclePhysics(inst, 2)
    inst.Physics:SetCollisionMask(COLLISION.ITEMS)
    
    inst.entity:SetPristine()
    
    if not TheWorld.ismastersim then
      return inst
    end
    
    inst.recently_collision = {}
    inst.Physics:SetCollisionCallback(oncollision)
    
    return inst
end

return Prefab("jx_car_physics_collision", fn)