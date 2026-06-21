Inv = require "widgets/inventorybar"
GLOBAL.INVINFO = {}

--Create Rune Holder slot Info
local function InvBarPostConstruct(self, owner)
    owner:DoTaskInTime(1, function()
	GLOBAL.INVINFO["ITEMSLOTSNUM"] = self.owner.replica.inventory:GetNumSlots()
	GLOBAL.INVINFO["EQUIPSLOTINFO"] = self.equipslotinfo
	GLOBAL.INVINFO["EQUIP"] = self.equip
	GLOBAL.INVINFO["INV"] = self.inv
    end)
end

AddClassPostConstruct("widgets/inventorybar", InvBarPostConstruct)

local function EquipSlotPostConstruct(self, equipslot, atlas, bgim, owner)
    GLOBAL.INVINFO["EQUIPSLOT_"..equipslot] = self
end

AddClassPostConstruct("widgets/equipslot", EquipSlotPostConstruct)