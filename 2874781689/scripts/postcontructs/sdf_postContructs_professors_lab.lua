--local SDF_LIFEBOTTLE_BOSS_DROPS = GetModConfigData("sdf_lifebottle_boss_drops") --true

--Professors Lab
AddClassPostConstruct("cameras/followcamera",function(inst)
        local w8T3f = inst.Apply
        function inst:Apply()
            if inst.insdfprofessorslab == true and inst.sdfprofessorslabpos ~= nil then
                inst.headingtarget = 0
                local K = 42.857142857143 * DEGREES
                local qL = 0
                local vfIyB = 30
                local quNsijN = inst.sdfprofessorslabpos
                local QUh2tc = 35
                local qboV = 0
                local nSBOx7 = math.cos(K)
                local u = math.cos(qL)
                local Ki1 = math.sin(qL)
                local zz1QI = -nSBOx7 * u
                local kFTAh = -math.sin(K)
                local LBf = -nSBOx7 * Ki1
                local dijn4Ph, CO1 = 0, 0
                if qboV ~= 0 then
                    local b = 2 * qboV / RESOLUTION_Y
                    local E = 1.03
                    local KMw7_i1s = math.tan(QUh2tc * .5 * DEGREES) * vfIyB * E
                    dijn4Ph = -b * Ki1 * KMw7_i1s
                    CO1 = b * u * KMw7_i1s
                end
                TheSim:SetCameraPos(
                    quNsijN.x - zz1QI * vfIyB + dijn4Ph,
                    quNsijN.y - kFTAh * vfIyB,
                    quNsijN.z - LBf * vfIyB + CO1
                )
                TheSim:SetCameraDir(zz1QI, kFTAh, LBf)
                local RlZo = (qL + 90) * DEGREES
                local SUn = math.cos(RlZo)
                local Ib4 = 0
                local fjV1G2 = math.sin(RlZo)
                local Do = kFTAh * fjV1G2 - LBf * Ib4
                local _ = LBf * SUn - zz1QI * fjV1G2
                local TqYJ4 = zz1QI * Ib4 - kFTAh * SUn
                TheSim:SetCameraUp(Do, _, TqYJ4)
                TheSim:SetCameraFOV(QUh2tc)
                local DI = -.1 * vfIyB
                TheSim:SetListener(
                    zz1QI * DI + quNsijN.x,
                    kFTAh * DI + quNsijN.y,
                    LBf * DI + quNsijN.z,
                    zz1QI,
                    kFTAh,
                    LBf,
                    Do,
                    _,
                    TqYJ4
                )
            else
                w8T3f(inst)
            end
        end
    end
)

AddClassPostConstruct(
    "widgets/controls",
    function(UBg54E)
        local gQGq = UBg54E.ShowMap
        function UBg54E:ShowMap(Dn1Xi)
            if UBg54E.owner ~= nil and UBg54E.owner._insdfprofessorslabcamera ~= nil and UBg54E.owner._insdfprofessorslabcamera:value() ~= nil then
                return
            end
            return gQGq(UBg54E, Dn1Xi)
        end
        local OyHc5FEv = UBg54E.ToggleMap
        function UBg54E:ToggleMap()
            if
                UBg54E.owner ~= nil and UBg54E.owner._insdfprofessorslabcamera ~= nil and UBg54E.owner._insdfprofessorslabcamera:value() ~= nil and
                    UBg54E.owner.HUD ~= nil and
                    not UBg54E.owner.HUD:IsMapScreenOpen()
             then
                return
            end
            return OyHc5FEv(UBg54E)
        end
    end
)