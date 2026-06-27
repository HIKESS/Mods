--栅栏击剑旋转地毯、洗手池
AddComponentPostInit("fencerotator",function(self)
    local old_Rotate = self.Rotate
    function self:Rotate(target, delta, ...)
      if target and target:HasTag("jx_rug") and target.rotatable_angle then
        local angle = target.Transform:GetRotation()
        target.Transform:SetRotation(angle + target.rotatable_angle)--不用delta参数
        
        if target.NOCLICK_Tag_Task then
          target.NOCLICK_Tag_Task:Cancel()
          target.NOCLICK_Tag_Task = nil
        end
        target.NOCLICK_Tag_Task = target:DoTaskInTime(target.NOCLICK_Tag_Task_Time or 5,function() target:AddTag("NOCLICK") end)
        
        self.inst:PushEvent("fencerotated")
        SpawnPrefab("fence_rotator_fx").Transform:SetPosition(target.Transform:GetWorldPosition())
        
      else
        old_Rotate(self, target, delta, ...)
      end
    end
end)

--[[AddPrefabPostInit("fence_rotator", function(inst)
    if not TheWorld.ismastersim then return end
    if inst.components.equippable then
      local old_onequipfn = inst.components.equippable.onequipfn
      inst.components.equippable:SetOnEquip(function(inst, owner)
        old_onequipfn(inst, owner)
        if owner then
          local x, y, z = owner.Transform:GetWorldPosition()
          local ents = TheSim:FindEntities(x, y, z, 2.8, {"jx_rug", "rotatableobject",})
          if #ents > 0 then
            local target = ents[1]
            target:RemoveTag("NOCLICK")
            if target.NOCLICK_Tag_Task then
              target.NOCLICK_Tag_Task:Cancel()
              target.NOCLICK_Tag_Task = nil
            end
            target.NOCLICK_Tag_Task = target:DoTaskInTime(target.NOCLICK_Tag_Task_Time or 3,function() target:AddTag("NOCLICK") end)
          end
        end
      end)
    end
end)]]