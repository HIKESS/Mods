local G = GLOBAL

local function stopusingbush(inst, data)
  local bodyitem = inst.components.inventory ~= nil and inst.components.inventory:GetEquippedItem(G.EQUIPSLOTS.BODY) or nil
  if data.statename ~= "hide" then
    if bodyitem and bodyitem:HasTag("jx_frog_raincoat") and bodyitem.components.equippable then
      if bodyitem.components.equippable.onunequipfn then
        bodyitem.components.equippable.onunequipfn(bodyitem, inst)
      end
      if bodyitem.components.equippable.onequipfn then
        bodyitem.components.equippable.onequipfn(bodyitem, inst)
      end
    end
    inst:RemoveEventCallback("newstate", stopusingbush)
  end
end

AddPrefabPostInit("bushhat", function(inst)
    if not G.TheWorld.ismastersim then return end
    if inst.components.useableitem then
      local old_onusefn = inst.components.useableitem.onusefn
      inst.components.useableitem.onusefn = function(inst, ...)
        if old_onusefn then
          old_onusefn(inst, ...)
        end
        local owner = inst.components.inventoryitem.owner
        if owner and owner.components.inventory then
          local body_item = owner.components.inventory:GetEquippedItem(G.EQUIPSLOTS.BODY)
          if not (body_item and body_item:HasTag("jx_frog_raincoat")) then
            return
          end
          if body_item.components.equippable and body_item.components.equippable.onunequipfn then
            body_item.components.equippable.onunequipfn(body_item, owner)
          end
          owner:ListenForEvent("newstate", stopusingbush)
        end
      end
    end
end)