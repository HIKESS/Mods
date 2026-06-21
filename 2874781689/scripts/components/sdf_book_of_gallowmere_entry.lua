local function OnEntryTotalDirty(inst)
    inst.components.sdf_book_of_gallowmere_entry.entry_total = inst.components.sdf_book_of_gallowmere_entry.net_entry_total:value()
end

local SDFBook_Of_Gallowmere_Entry = Class(function(self, inst)
    self.inst = inst

    self.entry_total = 0
    self.net_entry_total = net_ushortint(self.inst.GUID, "entry_total", "entry_totaldirty" )
	
    --Server only code
    if TheWorld.ismastersim then
    end
	
    --Client only code
    if not TheWorld.ismastersim then
	self.inst:ListenForEvent("entry_totaldirty", OnEntryTotalDirty)
    end
	
    self.inst:StartUpdatingComponent(self)
end)

function SDFBook_Of_Gallowmere_Entry:SetEntryTotal(entry_total)
    self.entry_total = entry_total
    self.net_entry_total:set(entry_total)
end

function SDFBook_Of_Gallowmere_Entry:GetEntryTotal()
    return self.entry_total or self.net_entry_total
end

function SDFBook_Of_Gallowmere_Entry:OnUpdate(dt)
    if TheWorld.ismastersim then
	self:ServerOnUpdate(dt)
    end
end

function SDFBook_Of_Gallowmere_Entry:ServerOnUpdate(dt)
end

return SDFBook_Of_Gallowmere_Entry