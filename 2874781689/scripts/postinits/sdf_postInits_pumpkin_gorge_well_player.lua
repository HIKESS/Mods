--Pumpkin Gorge Well Player
local function wqU76o(CQi)
    if ThePlayer ~= nil and CQi == ThePlayer then
        if CQi._insdfpumpkingorgewellcamera:value() ~= nil then
            local nHlJ = CQi._insdfpumpkingorgewellcamera:value()
            TheCamera.insdfpumpkingorgewell = true
            local lw4Q7kbl, IN, QYf1 = nHlJ.Transform:GetWorldPosition()
            TheCamera.sdfpumpkingorgewellpos = Vector3(lw4Q7kbl, 1.5, QYf1)
        else
            TheCamera.insdfpumpkingorgewell = false
            TheCamera.sdfpumpkingorgewellpos = nil
       end
        if CQi.components.playervision then
            CQi.components.playervision:UpdateCCTable()
        end
    end
end

local function LB1Z(RfsnisO)
    if RfsnisO.spawnanddelete_sdfpumpkingorgewell then
        return
    end
    local lvW2ga = FindEntity(RfsnisO, 15, nil, {"sdf_pumpkin_gorge_well_base"})
    if lvW2ga then
        if RfsnisO._insdfpumpkingorgewellcamera:value() ~= lvW2ga then
            RfsnisO._insdfpumpkingorgewellcamera:set(lvW2ga) --Enables Camera Lock
            --RfsnisO:AddTag("huahousrecipe") --Inside Well tags
        end
    elseif RfsnisO._insdfpumpkingorgewellcamera:value() ~= nil then
        RfsnisO._insdfpumpkingorgewellcamera:set(nil)
        --RfsnisO:RemoveTag("huahousrecipe") --Leave Well tags
   end
end


AddPlayerPostInit(function(wU4wYbA9)
    wU4wYbA9._insdfpumpkingorgewell = net_bool(wU4wYbA9.GUID, "_insdfpumpkingorgewell", "insdfpumpkingorgewelldirty")
    wU4wYbA9._insdfpumpkingorgewellcamera = net_entity(wU4wYbA9.GUID, "_insdfpumpkingorgewellcamera", "insdfpumpkingorgewellcameradirty")
    wU4wYbA9._insdfpumpkingorgewellname = net_tinybyte(wU4wYbA9.GUID, "_insdfpumpkingorgewellname", "insdfpumpkingorgewellnamedirty")
    if TheWorld.ismastersim then
	wU4wYbA9:DoPeriodicTask(0.2, LB1Z, 0.2)
    end
    if not TheNet:IsDedicated() then
	wU4wYbA9:ListenForEvent("insdfpumpkingorgewellcameradirty", wqU76o)
    end
end)