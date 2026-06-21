AddPopup("SDFPUMPKINGGUTTEDOVER")

GLOBAL.POPUPS.SDFPUMPKINGGUTTEDOVER.fn = function(inst, show)
    if inst.HUD then
        if not show then
            inst.HUD:CloseSDFPumpkingGuttedOverScreen()
        elseif not inst.HUD:OpenSDFPumpkingGuttedOverScreen() then
            GLOBAL.POPUPS.SDFPUMPKINGGUTTEDOVER:Close(inst)
        end
    end
end