--Enchanted Earth Tomb Player
local function wqU76o(CQi)
    if ThePlayer ~= nil and CQi == ThePlayer then
        if CQi._insdfenchantedearthtombcamera:value() ~= nil then
            local nHlJ = CQi._insdfenchantedearthtombcamera:value()
            TheCamera.insdfenchantedearthtomb = true
            local lw4Q7kbl, IN, QYf1 = nHlJ.Transform:GetWorldPosition()
            TheCamera.sdfenchantedearthtombpos = Vector3(lw4Q7kbl, 1.5, QYf1)
        else
            TheCamera.insdfenchantedearthtomb = false
            TheCamera.sdfenchantedearthtombpos = nil
       end
        if CQi.components.playervision then
            CQi.components.playervision:UpdateCCTable()
        end
    end
end

local function LB1Z(RfsnisO)
    if RfsnisO.spawnanddelete_sdfenchantedearthtomb then
        return
    end
    local lvW2ga = FindEntity(RfsnisO, 15, nil, {"sdf_enchanted_earth_tomb_base"})
    if lvW2ga then
        if RfsnisO._insdfenchantedearthtombcamera:value() ~= lvW2ga then
            RfsnisO._insdfenchantedearthtombcamera:set(lvW2ga) --Enables Camera Lock
            --RfsnisO:AddTag("huahousrecipe") --Inside Well tags
        end
    elseif RfsnisO._insdfenchantedearthtombcamera:value() ~= nil then
        RfsnisO._insdfenchantedearthtombcamera:set(nil)
        --RfsnisO:RemoveTag("huahousrecipe") --Leave Well tags
   end
end


AddPlayerPostInit(function(wU4wYbA9)
    wU4wYbA9._insdfenchantedearthtomb = net_bool(wU4wYbA9.GUID, "_insdfenchantedearthtomb", "insdfenchantedearthtombdirty")
    wU4wYbA9._insdfenchantedearthtombcamera = net_entity(wU4wYbA9.GUID, "_insdfenchantedearthtombcamera", "insdfenchantedearthtombcameradirty")
    wU4wYbA9._insdfenchantedearthtombname = net_tinybyte(wU4wYbA9.GUID, "_insdfenchantedearthtombname", "insdfenchantedearthtombnamedirty")
    if TheWorld.ismastersim then
	wU4wYbA9:DoPeriodicTask(0.2, LB1Z, 0.2)
    end
    if not TheNet:IsDedicated() then
	wU4wYbA9:ListenForEvent("insdfenchantedearthtombcameradirty", wqU76o)
    end
end)