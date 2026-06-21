
----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
local assets = {
    Asset("ATLAS", "images/inventoryimages/gwen_backpack.xml"),
	Asset("IMAGE", "images/inventoryimages/gwen_backpack.tex"),	
	Asset("ANIM", "anim/swap_gwen_backpack.zip"),
}

----重构
local function gw_refactor(inst, item, doer)
    local pos = Vector3(inst.Transform:GetWorldPosition())
    local current_level = 0
    if inst.prefab == "gwen_backpack" then
        current_level = 0
    elseif inst.prefab == "gwen_backpack_1" then
        current_level = 0
    elseif inst.prefab == "gwen_backpack_2" then
        current_level = 0
    elseif inst.prefab == "gwen_backpack_3" then
        current_level = 3
    end
    local next_level = current_level + 3
    local new_prefab = "gwen_backpack_" .. next_level

    local owner = nil
    if inst.components.equippable:IsEquipped() then
        owner = inst.components.inventoryitem:GetGrandOwner()
    end
    local items = inst.components.container:RemoveAllItems()
    local new_backpack = SpawnPrefab(new_prefab)
    if not new_backpack then
        for _, v in ipairs(items) do
            inst.components.container:GiveItem(v)
        end
        return false
    end
    for _, v in ipairs(items) do
        new_backpack.components.container:GiveItem(v)
    end

    if inst.userid then
        new_backpack.userid = inst.userid
    end

    if new_backpack.components.gwen_equip then
        new_backpack.components.gwen_equip:Incrgw_Level(next_level)
        new_backpack.components.gwen_equip:Setgw_refactor()
    end

    if owner then
        owner.components.inventory:Equip(new_backpack)
    end
    if item and item:IsValid() then
        item:Remove()
    end
    inst:Remove()

    SendModRPCToClient(CLIENT_MOD_RPC["LegionMsg"]["gw_UiRefresh"], inst.userid)

    local fx = SpawnPrefab("crab_king_shine")
    fx.Transform:SetPosition(pos.x, pos.y + 2, pos.z)
    fx:ListenForEvent("animover", fx.Remove)

    return true
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "swap_gwen_backpack", "swap_body")
    if inst.components.container ~= nil then
        inst.components.container:Open(owner)
    end
    inst:AddTag("gw_backpack_swap")
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    owner.AnimState:ClearOverrideSymbol("backpack")
    if inst.components.container ~= nil then
        inst.components.container:Close(owner)
    end
    inst:RemoveTag("gw_backpack_swap")
end

local function onequiptomodel(inst, owner, from_ground)
    if inst.components.container ~= nil then
        inst.components.container:Close(owner)
    end
end

local function onburnt(inst)
    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
        inst.components.container:Close()
    end
    SpawnPrefab("ash").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:Remove()
end

local function onignite(inst)
    if inst.components.container ~= nil then
        inst.components.container.canbeopened = false
    end
end

local function onextinguish(inst)
    if inst.components.container ~= nil then
        inst.components.container.canbeopened = true
    end
end

local function Restore(inst, owner)
    local owner = inst.components.inventoryitem.owner
    if owner == nil then
        if inst.task ~= nil then
            inst.task:Cancel()
            inst.task = nil
        end
        return
    end
    if inst.stast == 7 or inst.stast == 8 or inst.stast == 9 then
        if owner and owner.components.gwen_shengai then
            owner.components.gwen_shengai:DoDelta(1)
        end
    end
    if inst.stast == 13 or inst.stast == 14 or inst.stast == 15 then
        if owner and owner.components.sanity then
            if owner.components.sanity:IsInsanityMode() then
                owner.components.sanity:DoDelta(1, true, "debug_key")
            end
            if owner.components.sanity:IsLunacyMode() then
                owner.components.sanity:DoDelta(-1, true, "debug_key")
            end
        end
    end
end

local function onitemget(inst, data)
    local owner = inst.components.inventoryitem.owner
    local item = inst.components.container:GetItemInSlot(17)

    if item ~= nil and not item:HasTag("gw_guajian") then
        inst.components.container:Close()
    end

    if item and item.prefab == "gw_gj_xingguang1" then
        inst.stast = 1
    elseif item and item.prefab == "gw_gj_xingguang2" then
        inst.stast = 2
    elseif item and item.prefab == "gw_gj_xingguang3" then
        inst.stast = 3
    elseif item and item.prefab == "gw_gj_xuehua1" then
        inst.stast = 4
    elseif item and item.prefab == "gw_gj_xuehua2" then
        inst.stast = 5
    elseif item and item.prefab == "gw_gj_xuehua3" then
        inst.stast = 6
    elseif item and item.prefab == "gw_gj_shaobing1" then
        inst.stast = 7
    elseif item and item.prefab == "gw_gj_shaobing2" then
        inst.stast = 8
    elseif item and item.prefab == "gw_gj_shaobing3" then
        inst.stast = 9
    elseif item and item.prefab == "gw_gj_yumao1" then
        inst.stast = 10
    elseif item and item.prefab == "gw_gj_yumao2" then
        inst.stast = 11
    elseif item and item.prefab == "gw_gj_yumao3" then
        inst.stast = 12
    elseif item and item.prefab == "gw_gj_zhihui1" then
        inst.stast = 13
    elseif item and item.prefab == "gw_gj_zhihui2" then
        inst.stast = 14
    elseif item and item.prefab == "gw_gj_zhihui3" then
        inst.stast = 15
    end

    if inst.stast ~= nil then
        if inst.stast == 1 then
            if inst._light == nil then
                inst._light = SpawnPrefab("minerhatlight")
            end
            if inst._light ~= nil then
                inst._light.Light:SetFalloff(.58)
                inst._light.Light:SetIntensity(.8)
                inst._light.Light:SetRadius(1.2)
                inst._light.Light:SetColour(240/255, 210/255, 160/255)
                inst._light.entity:SetParent(inst.entity)
            end
        elseif inst.stast == 2 then
            if inst._light == nil then
                inst._light = SpawnPrefab("minerhatlight")
            end
            if inst._light ~= nil then
                inst._light.Light:SetFalloff(.58)
                inst._light.Light:SetIntensity(.8)
                inst._light.Light:SetRadius(3.4)
                inst._light.Light:SetColour(240/255, 210/255, 160/255)
                inst._light.entity:SetParent(inst.entity)
            end
        elseif inst.stast == 3 then
            if inst._light == nil then
                inst._light = SpawnPrefab("minerhatlight")
            end
            if inst._light ~= nil then
                inst._light.Light:SetFalloff(.58)
                inst._light.Light:SetIntensity(.8)
                inst._light.Light:SetRadius(6.8)
                inst._light.Light:SetColour(240/255, 210/255, 160/255)
                inst._light.entity:SetParent(inst.entity)
            end
        end

        if inst.stast == 4 then
            if not inst.components.preserver then
                inst:AddComponent("preserver")
            end
            if inst.components.preserver then
                inst.components.preserver:SetPerishRateMultiplier(function(inst, item)
                    return (item ~= nil) and .25 or nil
                end)
            end
        elseif inst.stast == 5 then
            if not inst.components.preserver then
                inst:AddComponent("preserver")
            end
            if inst.components.preserver then
                inst.components.preserver:SetPerishRateMultiplier(function(inst, item)
                    return (item ~= nil) and .1 or nil
                end)
            end
        elseif inst.stast == 6 then
            if not inst.components.preserver then
                inst:AddComponent("preserver")
            end
            if inst.components.preserver then
                inst.components.preserver:SetPerishRateMultiplier(function(inst, item)
                    return (item ~= nil) and 0 or nil
                end)
            end
        end

        if inst.stast == 7 then
            if inst.task == nil then
                inst.task = inst:DoPeriodicTask(5, function() Restore(inst, owner) end)
            end
        elseif inst.stast == 8 then
            if inst.task == nil then
                inst.task = inst:DoPeriodicTask(3, function() Restore(inst, owner) end)
            end
        elseif inst.stast == 9 then
            if inst.task == nil then
                inst.task = inst:DoPeriodicTask(1, function() Restore(inst, owner) end)
            end
        end

        if inst.stast == 10 then
            if owner and owner.components.locomotor then
                owner.components.locomotor:SetExternalSpeedMultiplier(owner, "gw_gj_yumao", 1.07)
            end
        elseif inst.stast == 11 then
            if owner and owner.components.locomotor then
                owner.components.locomotor:SetExternalSpeedMultiplier(owner, "gw_gj_yumao", 1.15)
            end
        elseif inst.stast == 12 then
            if owner and owner.components.locomotor then
                owner.components.locomotor:SetExternalSpeedMultiplier(owner, "gw_gj_yumao", 1.30)
            end
        end

        if inst.stast == 13 then
            if inst.task == nil then
                inst.task = inst:DoPeriodicTask(5, function() Restore(inst, owner) end)
            end
        elseif inst.stast == 14 then
            if inst.task == nil then
                inst.task = inst:DoPeriodicTask(3, function() Restore(inst, owner) end)
            end
        elseif inst.stast == 15 then
            if inst.task == nil then
                inst.task = inst:DoPeriodicTask(1, function() Restore(inst, owner) end)
            end
        end
    else
        if inst._light ~= nil then
            inst._light:Remove()
            inst._light = nil
        end
        if inst.components.preserver then
            inst:RemoveComponent("preserver")
        end
        if owner and owner.components.locomotor then
            owner.components.locomotor:RemoveExternalSpeedMultiplier(owner, "gw_gj_yumao")
        end
        if inst.task ~= nil then
            inst.task:Cancel()
            inst.task = nil
        end
    end
    ---- byd挤进来我也让你调出去
    local restricted_slots = {}
    local prefab_name = inst.prefab
    if prefab_name == "gwen_backpack" then
        for i = 13, 16 do
            table.insert(restricted_slots, i)
        end
    elseif prefab_name == "gwen_backpack_1" then
        for i = 13, 16 do
            table.insert(restricted_slots, i)
        end
    elseif prefab_name == "gwen_backpack_2" then
        for i = 13, 16 do
            table.insert(restricted_slots, i)
        end
    end
    for _, slot in ipairs(restricted_slots) do
        local slot_item = inst.components.container:GetItemInSlot(slot)
        if slot_item ~= nil then
            inst:DoTaskInTime(0, function()
                local current_item = inst.components.container:GetItemInSlot(slot)
                if current_item ~= nil then
                    inst.components.container:DropItemBySlot(slot)
                end
            end)
        end
    end
end

local function onitemlose(inst, data)
    local owner = inst.components.inventoryitem.owner
    local item = inst.components.container:GetItemInSlot(17)
    if item == nil then
        inst.stast = nil
    end
    if inst.stast == nil then
        if inst._light ~= nil then
            inst._light:Remove()
            inst._light = nil
        end
        if inst.components.preserver then
            inst:RemoveComponent("preserver")
        end
        if owner and owner.components.locomotor then
            owner.components.locomotor:RemoveExternalSpeedMultiplier(owner, "gw_gj_yumao")
        end
        if inst.task ~= nil then
            inst.task:Cancel()
            inst.task = nil
        end
    end
end

local function OnClose(inst, doer)
    local item = inst.components.container:GetItemInSlot(17)
    if item ~= nil and not item:HasTag("gw_guajian") then
        if inst.components.container ~= nil then
            inst:DoTaskInTime(0, function()
                if item ~= nil and not item:HasTag("gw_guajian") then
                    inst.components.container:DropItemBySlot(17)
                end
            end)
        end
        if doer and doer.components.inventory ~= nil and doer.components.inventory.isopen and item ~= nil then
            doer.components.inventory:GiveItem(item)
        end
    end

    ---- 再放一次，挤进来关上也给你扔出去
    local restricted_slots = {}
    local prefab_name = inst.prefab
    if prefab_name == "gwen_backpack" then
        for i = 13, 16 do
            table.insert(restricted_slots, i)
        end
    elseif prefab_name == "gwen_backpack_1" then
        for i = 13, 16 do
            table.insert(restricted_slots, i)
        end
    elseif prefab_name == "gwen_backpack_2" then
        for i = 13, 16 do
            table.insert(restricted_slots, i)
        end
    end
    for _, slot in ipairs(restricted_slots) do
        local slot_item = inst.components.container:GetItemInSlot(slot)
        if slot_item ~= nil then
            inst:DoTaskInTime(0, function()
                local current_item = inst.components.container:GetItemInSlot(slot)
                if current_item ~= nil then
                    inst.components.container:DropItemBySlot(slot)
                end
            end)
        end
    end
end

local function OnSave(inst)
end


local function OnLoad(inst, data)
end

local function MakeBackpack(name, widget_name)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("backpack1")
        inst.AnimState:SetBuild("swap_gwen_backpack")
        inst.AnimState:PlayAnimation("anim")

        inst:AddTag("backpack")
        inst:AddTag("gw_backpack")

        inst.MiniMapEntity:SetIcon("backpack.png")

        inst.foleysound = "dontstarve/movement/foley/backpack"

        local swap_data = {bank = "backpack1", anim = "anim"}
        MakeInventoryFloatable(inst, "small", 0.2, nil, nil, nil, swap_data)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.cangoincontainer = false
        inst.components.inventoryitem.atlasname = "images/inventoryimages/gwen_backpack.xml"
        inst.components.inventoryitem.imagename = "gwen_backpack"

        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.BACK or EQUIPSLOTS.BODY
        inst.components.equippable:SetOnEquip(onequip)
        inst.components.equippable:SetOnUnequip(onunequip)
        inst.components.equippable:SetOnEquipToModel(onequiptomodel)

        inst:AddComponent("gwen_equip")


        inst:AddComponent("container")
        inst.components.container:WidgetSetup(widget_name)

        inst.components.container.onclosefn = OnClose

        inst:ListenForEvent("itemget", onitemget)
        inst:ListenForEvent("itemlose", onitemlose)

        -- MakeSmallBurnable(inst)
        -- MakeSmallPropagator(inst)
        -- inst.components.burnable:SetOnBurntFn(onburnt)
        -- inst.components.burnable:SetOnIgniteFn(onignite)
        -- inst.components.burnable:SetOnExtinguishFn(onextinguish)

        -- MakeHauntableLaunchAndDropFirstItem(inst)

        inst.gw_refactor = gw_refactor

        return inst
    end
    
    return Prefab(name, fn, assets)
end

local prefabs = {}

table.insert(prefabs, MakeBackpack("gwen_backpack", "gwen_backpack"))
table.insert(prefabs, MakeBackpack("gwen_backpack_1", "gwen_backpack_1"))
table.insert(prefabs, MakeBackpack("gwen_backpack_2", "gwen_backpack_2"))
table.insert(prefabs, MakeBackpack("gwen_backpack_3", "gwen_backpack_3"))

return unpack(prefabs)