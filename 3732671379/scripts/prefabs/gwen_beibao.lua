
local assets = {
    Asset("ATLAS", "images/inventoryimages/gwen_beibao.xml"),
	Asset("IMAGE", "images/inventoryimages/gwen_beibao.tex"),	
    Asset("ATLAS", "images/inventoryimages/xiufugezi.xml"),
    Asset("ATLAS", "images/inventoryimages/gw_boli.xml"),
    Asset("ATLAS", "images/inventoryimages/gw_guajian.xml"),
    Asset("ATLAS", "images/inventoryimages/gw_heiwu.xml"),
	Asset("ANIM", "anim/gwenbeibao.zip"),
}

local function OnLoad(inst, data)
end


--[[
local function RepairDurability(item)
    -- ��������˲��޽�������Ʒ������ƷΪgreenstaff��greenamulet���򲻽����޸�
    if TUNING.XIUBUXIUCHAIJIEJIANZAO == false and (item.prefab == "greenstaff" or item.prefab == "greenamulet") then
        return
    end

    if item.components.finiteuses then
        -- �����Ʒ��finiteuses�����������ʹ�ô���
        local uses = item.components.finiteuses:GetUses()
        local max_uses = item.components.finiteuses.total
        item.components.finiteuses:SetUses(math.min(uses + max_uses * 0.01, max_uses))
    elseif item.components.armor then
        -- �����Ʒ��armor������������;ðٷֱ�
        local armor = item.components.armor:GetPercent()
        item.components.armor:SetPercent(math.min(armor + 0.01, 1))
    elseif item.components.fueled then
        -- �����Ʒ��fueled�����������ȼ�ϰٷֱ�
        local fuel = item.components.fueled:GetPercent()
        item.components.fueled:SetPercent(math.min(fuel + 0.01, 1))
    end
end
 
local function CheckAndRepair(container)
    for i = 1, 2 do
        local item = container.components.container:GetItemInSlot(i)
        if item then
            RepairDurability(item)
        end
    end
end

local function StartRepairTimer(container)
    if container.repair_task == nil then
        container.repair_task = container:DoPeriodicTask(1, function() CheckAndRepair(container) end)
    end
end

local function StopRepairTimer(container)
    if container.repair_task then
        container.repair_task:Cancel()
        container.repair_task = nil
    end
end

local function onequip(inst, owner)
    inst.components.container:Open(owner)
end

local function onunequip(inst, owner)
    inst.components.container:Close(owner)
end
local function OnOpen(container)
    StartRepairTimer(container)
end

local function OnClose(container)
    StopRepairTimer(container)
end
]]
----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
----背包在学习心灵手巧三级时缓慢修复物品耐久（根据上方被注释的代码重写）
local function RepairDurability(item)
    if (item.prefab == "greenstaff" or item.prefab == "greenamulet") then -------不恢复建造护符和拆解魔杖
        return
    end
    if item.components.finiteuses then
        local uses = item.components.finiteuses:GetUses()
        local max_uses = item.components.finiteuses.total
        item.components.finiteuses:SetUses(math.min(uses + max_uses * 0.005, max_uses))
    elseif item.components.armor then
        local armor = item.components.armor:GetPercent()
        item.components.armor:SetPercent(math.min(armor + 0.005, 1))
    elseif item.components.fueled then
        local fuel = item.components.fueled:GetPercent()
        item.components.fueled:SetPercent(math.min(fuel + 0.005, 1))
    end
end
 
local function CheckAndRepair(container)
    local owner = container.components.inventoryitem and container.components.inventoryitem.owner
    if not owner or not (owner.components.skilltreeupdater and owner.components.skilltreeupdater:IsActivated("gwen_xiubu_3")) then
        return
    end
    
    for i = 1, 2 do
        local item = container.components.container:GetItemInSlot(i)
        if item then
            RepairDurability(item)
        end
    end
end

local function StartRepairTimer(container)
    if container.repair_task == nil then
        container.repair_task = container:DoPeriodicTask(1, function() CheckAndRepair(container) end)
    end
end

local function StopRepairTimer(container)
    if container.repair_task then
        container.repair_task:Cancel()
        container.repair_task = nil
    end
end

local function OnContainerOpen(container)
    StartRepairTimer(container)
end

local function OnContainerClose(container)
    StopRepairTimer(container)
end

----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]---[]-----[]------
---
local function onputininventoryfn(inst, owner)
    if owner and owner:HasTag("gwen") then
        inst.gw_owner = owner

		---- 监听换人这个事件，换人时为true
		inst:ListenForEvent("ms_playerreroll", function() inst.rerolling = true end, owner)
    end
end

local function OnDropped(inst)
	---- 如果是换人，掉落全部物品并且移除自身
	  if inst.rerolling then
        if inst.components.container then
            inst.components.container:DropEverything()
			inst:Remove()
        end
        inst.rerolling = false
        return
    end

	---- 不是换人掉落正常吸回去
    if inst.gw_owner then
        if inst.gw_owner.components.inventory:IsFull() then
            local item = inst.gw_owner.components.inventory:GetItemInSlot(1)
            if item then
                inst.gw_owner.components.inventory:DropItem(item)
            end
        end
        inst.gw_owner.components.inventory:GiveItem(inst)
    end
end

--����Ʒ���������߲��Ǹ���ֱ�ӵ���
local function onpickupfn(inst, picker)
	if  not picker then
		return
	end
	if not picker:HasTag('gwen') then
		if picker.components.inventory then
			picker:DoTaskInTime(0,function()
				local inventory = picker.components.inventory
				if inventory then
					inventory:DropItem(inst)
				end
			end)
		end
	end
end

local function Restore(inst, owner)
	local owner = inst.components.inventoryitem.owner
	if owner == nil then
		if inst.task ~= nil then
			inst.task:Cancel()
			inst.task = nil
		end
	end
	if owner ~= nil then
		if inst.stast == 7 or inst.stast == 8 or inst.stast == 9 then
			if owner and owner.components.gwen_shengai then
				owner.components.gwen_shengai:DoDelta(1)
			end
		end
		if inst.stast == 13 or inst.stast == 14 or inst.stast == 15 then
			if owner and owner.components.sanity then
				if owner.components.sanity:IsInsanityMode() then
					owner.components.sanity:DoDelta(1, true,"debug_key")
				end
				if owner.components.sanity:IsLunacyMode() then
					owner.components.sanity:DoDelta(-1, true,"debug_key")
				end
			end
		end
	end
end

local function onitemget(inst, data)
    local item = data.item
	local owner = inst.components.inventoryitem.owner

	local item = inst.components.container:GetItemInSlot(13)

	if item ~= nil and not item:HasTag("gw_guajian") then
		inst.components.container:Close()
	end

	if item and item.prefab == "gw_gj_xingguang1" then 
		inst.stast = 1
	end
	if item and item.prefab == "gw_gj_xingguang2" then 
		inst.stast = 2
	end
	if item and item.prefab == "gw_gj_xingguang3" then 
		inst.stast = 3
	end
	if item and item.prefab == "gw_gj_xuehua1" then 
		inst.stast = 4
	end
	if item and item.prefab == "gw_gj_xuehua2" then 
		inst.stast = 5
	end
	if item and item.prefab == "gw_gj_xuehua3" then 
		inst.stast = 6
	end
	if item and item.prefab == "gw_gj_shaobing1" then 
		inst.stast = 7
	end
	if item and item.prefab == "gw_gj_shaobing2" then 
		inst.stast = 8
	end
	if item and item.prefab == "gw_gj_shaobing3" then 
		inst.stast = 9
	end
	if item and item.prefab == "gw_gj_yumao1" then 
		inst.stast = 10
	end
	if item and item.prefab == "gw_gj_yumao2" then 
		inst.stast = 11
	end
	if item and item.prefab == "gw_gj_yumao3" then 
		inst.stast = 12
	end
	if item and item.prefab == "gw_gj_zhihui1" then 
		inst.stast = 13
	end
	if item and item.prefab == "gw_gj_zhihui2" then 
		inst.stast = 14
	end
	if item and item.prefab == "gw_gj_zhihui3" then 
		inst.stast = 15
	end
	if inst.stast ~= nil then
		----�ǹ�
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
		end
		if inst.stast == 2 then
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
		end
		if inst.stast == 3 then
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

		----ѩ��
		if inst.stast == 4 then
			if not inst.components.preserver then
				inst:AddComponent("preserver")
			end
			if inst.components.preserver then
				inst.components.preserver:SetPerishRateMultiplier(function(inst, item)
					return (item ~= nil) and .25 or nil
				end)--4������
			end
		end
		if inst.stast == 5 then
			if not inst.components.preserver then
				inst:AddComponent("preserver")
			end
			if inst.components.preserver then
				inst.components.preserver:SetPerishRateMultiplier(function(inst, item)
					return (item ~= nil) and .1 or nil
				end)--10������
			end
		end
		if inst.stast == 6 then
			if not inst.components.preserver then
				inst:AddComponent("preserver")
			end
			if inst.components.preserver then
				inst.components.preserver:SetPerishRateMultiplier(function(inst, item)
					return (item ~= nil) and 0 or nil
				end)--���ñ���
			end
		end

		----�ڱ�
		if inst.stast == 7 then
			if inst.task == nil then
				inst.task = inst:DoPeriodicTask(5, function() Restore(inst, owner) end)
			end
		end
		if inst.stast == 8 then
			if inst.task == nil then
				inst.task = inst:DoPeriodicTask(3, function() Restore(inst, owner) end)
			end
		end
		if inst.stast == 9 then
			if inst.task == nil then
				inst.task = inst:DoPeriodicTask(1, function() Restore(inst, owner) end)
			end
		end

		----��ë
		if inst.stast == 10 then
			if owner and owner.components.locomotor then
				owner.components.locomotor:SetExternalSpeedMultiplier(owner, "gw_gj_yumao_beibao", 1.07)
			end
		end
		if inst.stast == 11 then
			if owner and owner.components.locomotor then
				owner.components.locomotor:SetExternalSpeedMultiplier(owner, "gw_gj_yumao_beibao", 1.15)
			end
		end
		if inst.stast == 12 then
			if owner and owner.components.locomotor then
				owner.components.locomotor:SetExternalSpeedMultiplier(owner, "gw_gj_yumao_beibao", 1.30)
			end
		end

		----�ǻ�
		if inst.stast == 13 then
			if inst.task == nil then
				inst.task = inst:DoPeriodicTask(5, function() Restore(inst, owner) end)
			end
		end
		if inst.stast == 14 then
			if inst.task == nil then
				inst.task = inst:DoPeriodicTask(3, function() Restore(inst, owner) end)
			end
		end
		if inst.stast == 15 then
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
			owner.components.locomotor:RemoveExternalSpeedMultiplier(owner, "gw_gj_yumao_beibao")
		end
		if inst.task ~= nil then
			inst.task:Cancel()
			inst.task = nil
		end
	end
end

local function onitemlose(inst, data)
    local item = data.item
	local owner = inst.components.inventoryitem.owner

	local item = inst.components.container:GetItemInSlot(13)
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
			owner.components.locomotor:RemoveExternalSpeedMultiplier(owner, "gw_gj_yumao_beibao")
		end
		if inst.task ~= nil then
			inst.task:Cancel()
			inst.task = nil
		end
	end

end

local function OnClose(inst, doer)
	local item = inst.components.container:GetItemInSlot(13)
	if item ~= nil and not item:HasTag("gw_guajian") then
		if inst.components.container ~= nil then
			inst:DoTaskInTime(0, function()
				if item ~= nil and not item:HasTag("gw_guajian") then
					inst.components.container:DropItemBySlot(13)
				end
			end)
		end
		if doer and doer.components.inventory ~= nil and doer.components.inventory.isopen and item ~= nil then
			doer.components.inventory:GiveItem(item)
		end
	end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddLight()
	
	MakeInventoryFloatable(inst, "med", .07, 0.71)
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("gwenbeibao")
    inst.AnimState:SetBuild("gwenbeibao")
    inst.AnimState:PlayAnimation("idle", true)
	inst:AddTag("gwen_backpack")

    if not TheWorld.ismastersim then
        inst.OnEntityReplicated = function(inst)
            inst.replica.container:WidgetSetup("gwen_back")
        end
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(onputininventoryfn)	
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
    inst.components.inventoryitem.atlasname = "images/inventoryimages/gwen_beibao.xml"
	inst.components.inventoryitem.imagename = "gwen_beibao"
	inst.components.inventoryitem:SetOnPickupFn(onpickupfn) --ʰȡ 
    inst.components.inventoryitem.canonlygoinpocket = true

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("gwen_back")
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true
	inst.components.container.onclosefn = OnClose

    inst:ListenForEvent("itemget", onitemget)
    inst:ListenForEvent("itemlose", onitemlose)
	
    inst:AddComponent("inspectable")

    inst.OnLoad = OnLoad

	-- inst:ListenForEvent("onopen", OnOpen)
	-- inst:ListenForEvent("onclose", OnClose)	

	inst:ListenForEvent("onopen", OnContainerOpen)		----监听背包打开和关闭决定是否恢复
	inst:ListenForEvent("onclose", OnContainerClose)


--[[
	if TUNING.BEIBAOFANXIANMA == 3 then	
		inst:AddComponent("preserver")
		inst.components.preserver:SetPerishRateMultiplier(function(inst, item)
			return (item ~= nil) and -2 or nil
		end)--����
	elseif TUNING.BEIBAOFANXIANMA == 2 then
		inst:AddComponent("preserver")
		inst.components.preserver:SetPerishRateMultiplier(function(inst, item)
			return (item ~= nil) and 1 or nil
		end)--����
	elseif TUNING.BEIBAOFANXIANMA == 1 then

	end
]]
	

    return inst
end
---------------------------------------------------------------------
return Prefab("gwen_beibao", fn, assets)