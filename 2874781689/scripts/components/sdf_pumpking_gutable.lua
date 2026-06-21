local SDFPumpkingGutable = Class(function(self, inst)
    self.inst = inst
    self.gutted = nil
    self.guttedtime = 0
end)

function SDFPumpkingGutable:Gutted()
    self.guttedtime = 2
    self.gutted = true

    self.inst:ShowPopUp(POPUPS.SDFPUMPKINGGUTTEDOVER, true)
    self.inst:StartUpdatingComponent(self)
    self.inst:AddDebuff("sdf_pumpking_gutted_player_fx", "sdf_pumpking_gutted_player_fx")
end

function SDFPumpkingGutable:OnUpdate(dt)
    self.guttedtime = self.guttedtime - dt
    if self.guttedtime <= 0 then
	--remove fx
	self.gutted = nil
	POPUPS.SDFPUMPKINGGUTTEDOVER:Close(self.inst)
	self.inst:RemoveDebuff("sdf_pumpking_gutted_player_fx")
	self.inst:StopUpdatingComponent(self)
    end
end

function SDFPumpkingGutable:TransferComponent(newinst)
    local newcomponent = newinst.components.sdf_pumpking_gutable
    if self.gutted then
    	newcomponent:Gutted()
    	newcomponent.guttedtime = self.guttedtime
    end
end

return SDFPumpkingGutable
