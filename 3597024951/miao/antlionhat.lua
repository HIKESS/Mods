local G = GLOBAL
---
--修改 autoterraformer 这个组件是因为不想完全覆盖刮地皮头盔原本的 onequip 方法

--在写了新的组件 jx_autoterraformer 情况下，并未直接禁用这个组件
--只在检测到装备 jx_backpack_3 背包时进行禁用
--希望大多数情况下保持原本的流程
AddComponentPostInit("autoterraformer",function(self)
    local old_StartTerraforming = self.StartTerraforming
    function self:StartTerraforming(...)
      if self.inst.components.inventoryitem ~= nil then
        local owner = self.inst.components.inventoryitem:GetGrandOwner()
        if owner ~= nil and owner.components.inventory ~= nil and owner.components.inventory:EquipHasTag("jx_backpack_3") then
          return
        end
      end
      old_StartTerraforming(self, ...)
    end
end)

---
local function onfinishterraforming(inst, x, y, z)
  local turf_smoke = G.SpawnPrefab("turf_smoke_fx")
  turf_smoke.Transform:SetPosition(G.TheWorld.Map:GetTileCenterPoint(x, y, z))
end

AddPrefabPostInit("antlionhat", function(inst)
    if not G.TheWorld.ismastersim then return end
    inst:AddComponent("jx_autoterraformer")
    inst.components.jx_autoterraformer.onfinishterraformingfn = onfinishterraforming
    
    if inst.components.equippable then
      local old_onequipfn = inst.components.equippable.onequipfn
      inst.components.equippable:SetOnEquip(function(inst, owner)
        old_onequipfn(inst, owner)
        if owner.components.inventory ~= nil and owner.components.inventory:EquipHasTag("jx_backpack_3") then
          if inst.components.jx_autoterraformer ~= nil and owner.components.locomotor ~= nil then
            inst.components.jx_autoterraformer:StartTerraforming()
          end
        end
      end)
      
      local old_onunequipfn = inst.components.equippable.onunequipfn
      inst.components.equippable:SetOnUnequip(function(inst, owner)
        old_onunequipfn(inst, owner)
        if inst.components.jx_autoterraformer ~= nil and owner.components.locomotor ~= nil then
          inst.components.jx_autoterraformer:StopTerraforming()
        end
      end)
    end
end)