require("stategraphs/commonstates")

local function _IQQ(QKKks_zt)
    QKKks_zt.sg.statemem.isphysicstoggle = true
    QKKks_zt.Physics:ClearCollisionMask()
    QKKks_zt.Physics:CollidesWith(COLLISION.GROUND)
end

local function XpkjA(Are7xU)
    Are7xU.sg.statemem.isphysicstoggle = nil
    Are7xU.Physics:ClearCollisionMask()
    Are7xU.Physics:CollidesWith(COLLISION.WORLD)
    Are7xU.Physics:CollidesWith(COLLISION.OBSTACLES)
    Are7xU.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
    Are7xU.Physics:CollidesWith(COLLISION.CHARACTERS)
    Are7xU.Physics:CollidesWith(COLLISION.GIANTS)
end

AddStategraphState(
    "wilson",
    State {
        name = "sdf_professors_lab_in_pre",
        tags = {"doing", "busy", "canrotate"},
        onenter = function(yxjl)
            yxjl.components.locomotor:Stop()
            yxjl.AnimState:PlayAnimation("give")
            yxjl.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")
        end,
        events = {
            EventHandler(
                "animover",
                function(ZG)
                    if ZG.AnimState:AnimDone() then
                        if ZG.bufferedaction ~= nil then
                            ZG:PerformBufferedAction()
                        else
                            ZG.sg:GoToState("idle")
                        end
                    end
                end
            )
        }
    }
)

AddStategraphState(
    "wilsonghost",
    State {
        name = "sdf_professors_lab_in_pre",
        tags = {"doing", "busy", "canrotate"},
        onenter = function(Vu0cCAf)
            Vu0cCAf.components.locomotor:Stop()
            Vu0cCAf.AnimState:PlayAnimation("dissipate", false)
            Vu0cCAf.SoundEmitter:PlaySound("dontstarve/ghost/ghost_haunt", nil, nil, true)
        end,
        events = {
            EventHandler(
                "animover",
                function(q)
                    if q.AnimState:AnimDone() then
                        if q.bufferedaction ~= nil then
                            q:PerformBufferedAction()
                        else
                            q.sg:GoToState("idle")
                        end
                    end
                end
            )
        }
    }
)

AddStategraphState(
    "wilson",
    State {
        name = "sdf_professors_lab_jump",
        tags = {"doing", "busy", "canrotate", "nopredict", "nomorph"},
        onenter = function(kP7O5, lqT)
            _IQQ(kP7O5)
            kP7O5.components.locomotor:Stop()
            kP7O5.sg.statemem.target = lqT.sdf_professors_lab_teleporter
            kP7O5.sg.statemem.heavy = kP7O5.components.inventory:IsHeavyLifting()
            if lqT.sdf_professors_lab_teleporter ~= nil and lqT.sdf_professors_lab_teleporter.components.sdf_professors_lab_teleporter ~= nil then
                lqT.sdf_professors_lab_teleporter.components.sdf_professors_lab_teleporter:RegisterTeleportee(kP7O5)
            end
            kP7O5.AnimState:PlayAnimation("give_pst", false)
            local mP3mlD = lqT ~= nil and lqT.sdf_professors_lab_teleporter and lqT.sdf_professors_lab_teleporter:GetPosition() or nil
            local PrPyxMK
            if mP3mlD ~= nil then
                kP7O5:ForceFacePoint(mP3mlD:Get())
            else
                kP7O5.sg.statemem.speed = 0
                PrPyxMK = 0
            end
            kP7O5.sg.statemem.sdf_professors_lab_teleportarrivestate = "idle"
        end,
        timeline = {
            TimeEvent(
                10 * FRAMES,
                function(tczrIB)
                    if not tczrIB.sg.statemem.heavy then
                        tczrIB.Physics:Stop()
                    end
                    if tczrIB.sg.statemem.target ~= nil then
                        if tczrIB.sg.statemem.target:IsValid() then
                            tczrIB.sg.statemem.target:PushEvent("starttravelsound", tczrIB)
                        else
                            tczrIB.sg.statemem.target = nil
                        end
                    end
                end
            )
        },
        events = {
            EventHandler(
                "animover",
                function(a)
                    if a.AnimState:AnimDone() then
                        if
                            a.sg.statemem.target ~= nil and a.sg.statemem.target:IsValid() and
                                a.sg.statemem.target.components.sdf_professors_lab_teleporter ~= nil
                         then
                            a.sg.statemem.target.components.sdf_professors_lab_teleporter:UnregisterTeleportee(a)
                            if a.sg.statemem.target.components.sdf_professors_lab_teleporter:Activate(a) then
                                a.sg.statemem.isteleporting = true
                                a.components.health:SetInvincible(true)
                                if a.components.playercontroller ~= nil then
                                    a.components.playercontroller:Enable(false)
                                end
                                a:Hide()
                                a.DynamicShadow:Enable(false)
                                return
                            end
                        end
                        a.sg:GoToState("idle")
                    end
                end
            )
        },
        onexit = function(wqU76o)
            if wqU76o.sg.statemem.isphysicstoggle then
                XpkjA(wqU76o)
            end
            wqU76o.Physics:Stop()
            if wqU76o.sg.statemem.isteleporting then
                wqU76o.components.health:SetInvincible(false)
                if wqU76o.components.playercontroller ~= nil then
                    wqU76o.components.playercontroller:Enable(true)
                end
                wqU76o:Show()
                wqU76o.DynamicShadow:Enable(true)
            elseif
                wqU76o.sg.statemem.target ~= nil and wqU76o.sg.statemem.target:IsValid() and
                    wqU76o.sg.statemem.target.components.sdf_professors_lab_teleporter ~= nil
             then
                wqU76o.sg.statemem.target.components.sdf_professors_lab_teleporter:UnregisterTeleportee(wqU76o)
            end
        end
    }
)

AddStategraphState(
    "wilsonghost",
    State {
        name = "sdf_professors_lab_jump",
        tags = {"doing", "busy", "canrotate", "nopredict", "nomorph"},
        onenter = function(LB1Z, N9L)
            LB1Z.components.locomotor:Stop()
            LB1Z.sg.statemem.target = N9L.sdf_professors_lab_teleporter
            LB1Z.sg.statemem.sdf_professors_lab_teleportarrivestate = "idle"
            LB1Z.sg.statemem.target:PushEvent("starttravelsound", LB1Z)
            if
                LB1Z.sg.statemem.target ~= nil and LB1Z.sg.statemem.target.components.sdf_professors_lab_teleporter ~= nil and
                    LB1Z.sg.statemem.target.components.sdf_professors_lab_teleporter:Activate(LB1Z)
             then
                LB1Z.sg.statemem.isteleporting = true
                if LB1Z.components.playercontroller ~= nil then
                    LB1Z.components.playercontroller:Enable(false)
                end
                LB1Z:Hide()
            else
                LB1Z.sg:GoToState("idle")
            end
        end,
        onexit = function(hDc_M)
            if hDc_M.sg.statemem.isteleporting then
                if hDc_M.components.playercontroller ~= nil then
                    hDc_M.components.playercontroller:Enable(true)
                end
                hDc_M:Show()
            end
        end
    }
)

AddStategraphState(
    "wilson_client",
    State {name = "sdf_professors_lab_in_pre", tags = {"doing", "busy", "canrotate"}, onenter = function(qW0lRiD1)
            qW0lRiD1.components.locomotor:Stop()
            qW0lRiD1.AnimState:PlayAnimation("give")
            qW0lRiD1.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")
            qW0lRiD1:PerformPreviewBufferedAction()
            qW0lRiD1.sg:SetTimeout(1)
        end, onupdate = function(iD1IUx)
            if iD1IUx:HasTag("doing") then
                if iD1IUx.entity:FlattenMovementPrediction() then
                    iD1IUx.sg:GoToState("idle", "noanim")
                end
            elseif iD1IUx.bufferedaction == nil then
                iD1IUx.sg:GoToState("idle")
            end
        end, ontimeout = function(JLCOx_ak)
            JLCOx_ak:ClearBufferedAction()
            JLCOx_ak.sg:GoToState("idle")
        end}
)

AddStategraphState(
    "wilsonghost_client",
    State {name = "sdf_professors_lab_in_pre", tags = {"doing", "busy", "canrotate"}, onenter = function(hPQ)
            hPQ.components.locomotor:Stop()
            hPQ.AnimState:PlayAnimation("dissipate")
            hPQ.SoundEmitter:PlaySound("dontstarve/ghost/ghost_haunt", nil, nil, true)
            hPQ:PerformPreviewBufferedAction()
            hPQ.sg:SetTimeout(1)
        end, onupdate = function(R1FIoQI)
            if R1FIoQI:HasTag("doing") then
                if R1FIoQI.entity:FlattenMovementPrediction() then
                    R1FIoQI.sg:GoToState("idle", "noanim")
                end
            elseif R1FIoQI.bufferedaction == nil then
                R1FIoQI.AnimState:PlayAnimation("appear")
                R1FIoQI.sg:GoToState("idle", true)
            end
        end, ontimeout = function(NsoTwDs)
            NsoTwDs:ClearBufferedAction()
            NsoTwDs.AnimState:PlayAnimation("appear")
            NsoTwDs.sg:GoToState("idle", true)
        end}
)