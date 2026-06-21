local UIAnim = require "widgets/uianim"
local cooldownColor = GetModConfigData("cooldownColor")
local GetTime = GLOBAL.GetTime
local function CreateRechargeTimer(inst)
	inst.rechargetimestart = GetTime()
	inst.rechargetimeend = GetTime()+1
	function inst:GetRechargeTime()
		return self.rechargetimeend - self.rechargetimestart
	end
	function inst:GetRechargePercent()
		return (inst.rechargetimeend-GetTime())/self:GetRechargeTime()
	end
	function inst:IsRechargeDone()
		return GetTime() > inst.rechargetimeend
	end
	function inst:StartRecharge(timer)
		if not inst:IsRechargeDone() then return end
		inst.rechargetimestart = GetTime()
		inst.rechargetimeend = GetTime()+timer
		inst:PushEvent("kitsune_mask_rechargechange", {percent=0})
		inst:PushEvent("kitsune_mask_rechargetimechange", {t=timer})
	end
end
AddPrefabPostInit("kitsune_mask",function(self)
    self.trackpercent = 100
	CreateRechargeTimer(self)
end)
AddClassPostConstruct("widgets/itemtile",function(self,invitem)
    if self.item.prefab == "kitsune_mask" then
        self.rechargepct = 1
        self.rechargetime = TUNING.KITSUNE_MASK_COOLDOWN
        self.rechargeframe = self:AddChild(UIAnim())
        self.rechargeframe:GetAnimState():SetBank("recharge_meter")
        self.rechargeframe:GetAnimState():SetBuild("recharge_meter")
        self.rechargeframe:GetAnimState():PlayAnimation("frame")
        self.rechargeframe:GetAnimState():AnimateWhilePaused(false)
		self.rechargeframe:GetAnimState():SetMultColour(0, 0, cooldownColor, 0.64)
	if self.rechargeframe ~= nil then
        self.recharge = self:AddChild(UIAnim())
        self.recharge:GetAnimState():SetBank("recharge_meter")
        self.recharge:GetAnimState():SetBuild("recharge_meter")
        self.recharge:GetAnimState():SetMultColour(0, 0, cooldownColor, 0.64) 
        self.recharge:GetAnimState():AnimateWhilePaused(false)
        self.recharge:SetClickable(false)
    end
	self:SetChargePercent(1-self.item:GetRechargePercent())
	self:SetChargeTime(self.item:GetRechargeTime())
    if self.rechargeframe ~= nil then
        self.inst:ListenForEvent("kitsune_mask_rechargechange",
            function(invitem, data)
                self:SetChargePercent(data.percent)
            end, invitem)
        self.inst:ListenForEvent("kitsune_mask_rechargetimechange",
            function(invitem, data)
                self:SetChargeTime(data.t)
            end, invitem)
    end
    end
end)
local function ApplyCooldown(inst)
    local item = inst.entity:GetParent()
    if not item or not item.replica or not item.replica.inventoryitem or
       not item.replica.inventoryitem.classified then
        return
    end
    item.trackpercent = item.replica.inventoryitem.classified.percentused:value()
    if item.prefab == "kitsune_mask" then
        inst:ListenForEvent("percentuseddirty", function(inst)
            if item.replica and item.replica.inventoryitem and
               item.replica.inventoryitem.classified and
               item.trackpercent > item.replica.inventoryitem.classified.percentused:value() then
                if hasSound then
                    inst:DoTaskInTime(TUNING.KITSUNE_MASK_COOLDOWN, function() inst.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel") end)
                end
                item:StartRecharge(TUNING.KITSUNE_MASK_COOLDOWN)
            end
            if item.replica and item.replica.inventoryitem and item.replica.inventoryitem.classified then
                item.trackpercent = item.replica.inventoryitem.classified.percentused:value()
            end
        end)
    end
end
local itemEquipped = nil
local function ApplySmallCooldown(inst)
    inst:DoTaskInTime(0, function()
        local hat_item = inst.replica.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HAT)
        if hat_item ~= nil and hat_item.prefab == "kitsune_mask" and itemEquipped ~= hat_item then
			hat_item:StartRecharge(TUNING.ARMOR_SKELETON_FIRST_COOLDOWN)
        end
        itemEquipped = inst.replica.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HAT)
    end)
end
AddPlayerPostInit(function(inst)
    inst:ListenForEvent("equip", ApplySmallCooldown)
    inst:ListenForEvent("unequip", function() itemEquipped = inst.replica.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HAT) end)
    inst:DoTaskInTime(0, function()
        itemEquipped = inst.replica.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HAT)
    end)
end)
AddPrefabPostInit("inventoryitem_classified", function(inst)
    inst:DoTaskInTime(0, function() ApplyCooldown(inst) end)
end)