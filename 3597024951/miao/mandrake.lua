--烤箱烹饪曼德拉草保护
AddPrefabPostInit("mandrake", function(inst)
    if not TheWorld.ismastersim then return end
    if inst.components.cookable then
      local old_oncooked = inst.components.cookable.oncooked
      inst.components.cookable:SetOnCookedFn(function(inst, cooker, chef)
        if chef and chef:HasTag("jx_oven") then
          --只播放声音，移除其余行为
          chef.SoundEmitter:PlaySound("dontstarve/creatures/mandrake/death")
        else
          old_oncooked(inst, cooker, chef)
        end
      end)
    end
end)