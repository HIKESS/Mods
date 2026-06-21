GLOBAL.setmetatable(env,{__index=function(a,b)return GLOBAL.rawget(GLOBAL,b)end})

local _G = GLOBAL
Inv = require "widgets/inventorybar"

EQUIPSLOTS.RUNE = "rune"

--Make rune slot
AddGlobalClassPostConstruct("widgets/inventorybar", "Inv", function(self, owner)
	self:AddEquipSlot(EQUIPSLOTS.RUNE, "images/rune_slot_icon/rune_slot_icon.xml", "rune_slot_icon.tex",10)

    -- Fix the width of the background of the inventory bar.
    local Inv_Rebuild_Base = Inv.Rebuild
    function Inv:Rebuild()
        Inv_Rebuild_Base(self)

        local num_slots = self.owner.replica.inventory:GetNumSlots()
        local do_self_inspect = not (self.controller_build or GLOBAL.GetGameModeProperty("no_avatar_popup"))

        local total_w_default = self:CalcTotalWidth(num_slots, 3, 1)
        local total_w_real    = self:CalcTotalWidth(num_slots, #self.equipslotinfo, do_self_inspect and 1 or 0)
        local scale_default = 1.22 -- See `scripts/widgets/inventorybar.lua:261-262`.
        local scale_real = scale_default *  total_w_real / total_w_default
        self.bg:SetScale(scale_real, 1, 1)
        self.bgcover:SetScale(scale_real,1, 1)
    end

    function Inv:CalcTotalWidth(num_slots, num_equip, num_buttons)
        local W = 68
        local SEP = 12
        local INTERSEP = 28
        local num_slotintersep = math.ceil(num_slots / 5)
        local num_equipintersep = num_buttons > 0 and 1 or 0
        return (num_slots + num_equip + num_buttons) * W + (num_slots + num_equip + num_buttons - num_slotintersep - num_equipintersep - 1) * SEP + (num_slotintersep + num_equipintersep) * INTERSEP
    end
end)
------------------------------------------------------------------------------------------------------------