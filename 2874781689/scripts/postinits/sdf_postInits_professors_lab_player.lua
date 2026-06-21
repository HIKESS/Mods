--Professors Lab Player
local function wqU76o(CQi)
    if ThePlayer ~= nil and CQi == ThePlayer then
        if CQi._insdfprofessorslabcamera:value() ~= nil then
            local nHlJ = CQi._insdfprofessorslabcamera:value()
            TheCamera.insdfprofessorslab = true
            local lw4Q7kbl, IN, QYf1 = nHlJ.Transform:GetWorldPosition()
            TheCamera.sdfprofessorslabpos = Vector3(lw4Q7kbl, 1.5, QYf1)
        else
            TheCamera.insdfprofessorslab = false
            TheCamera.sdfprofessorslabpos = nil
        end

        if CQi.components.playervision then
            CQi.components.playervision:UpdateCCTable()
        end
    end
end

local function LB1Z(RfsnisO)
    if RfsnisO.spawnanddelete_sdfprofessorslab then
        return
    end
    local lvW2ga = FindEntity(RfsnisO, 15, nil, {"sdf_professors_lab_base"})
    if lvW2ga then
        if RfsnisO._insdfprofessorslabcamera:value() ~= lvW2ga then
            RfsnisO._insdfprofessorslabcamera:set(lvW2ga)
            --RfsnisO:AddTag("huahousrecipe") --Inside Lab
        end
    elseif RfsnisO._insdfprofessorslabcamera:value() ~= nil then
        RfsnisO._insdfprofessorslabcamera:set(nil)
        --RfsnisO:RemoveTag("huahousrecipe") --Leave Lab
    end
end


AddPlayerPostInit(function(wU4wYbA9)
    wU4wYbA9._insdfprofessorslab = net_bool(wU4wYbA9.GUID, "_insdfprofessorslab", "insdfprofessorslabdirty")
    wU4wYbA9._insdfprofessorslabcamera = net_entity(wU4wYbA9.GUID, "_insdfprofessorslabcamera", "insdfprofessorslabcameradirty")
    wU4wYbA9._insdfprofessorslabname = net_tinybyte(wU4wYbA9.GUID, "_insdfprofessorslabname", "insdfprofessorslabnamedirty")
    if TheWorld.ismastersim then
	wU4wYbA9:DoPeriodicTask(0.2, LB1Z, 0.2)
    end
    if not TheNet:IsDedicated() then
	wU4wYbA9:ListenForEvent("insdfprofessorslabcameradirty", wqU76o)
    end
end)