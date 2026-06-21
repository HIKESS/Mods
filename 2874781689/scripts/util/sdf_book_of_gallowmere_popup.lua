AddPopup("SDFBOOKOFGALLOWMERE")

GLOBAL.POPUPS.SDFBOOKOFGALLOWMERE.fn = function(inst, show)
    if inst.HUD then
        if not show then
            inst.HUD:CloseSDFBookOfGallowmereScreen()
        elseif not inst.HUD:OpenSDFBookOfGallowmereScreen() then
            GLOBAL.POPUPS.SDFBOOKOFGALLOWMERE:Close(inst)
        end
    end
end