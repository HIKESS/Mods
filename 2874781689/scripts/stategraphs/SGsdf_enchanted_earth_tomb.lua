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

local function ToggleOffPhysics(inst)
    inst.sg.statemem.isphysicstoggle = true
    inst.Physics:SetCollisionMask(COLLISION.GROUND)
end

local function ToggleOnPhysics(inst)
    inst.sg.statemem.isphysicstoggle = nil
    inst.Physics:SetCollisionMask(
	COLLISION.WORLD,
	COLLISION.OBSTACLES,
	COLLISION.SMALLOBSTACLES,
	COLLISION.CHARACTERS,
	COLLISION.GIANTS
    )
end

AddStategraphState(
    "wilson",
    State {
        name = "sdf_enchanted_earth_tomb_in_pre",
        tags = {"doing", "busy", "canrotate"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("give")
            inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")
        end,
        events = {
            EventHandler("animover",function(inst)
		if inst.AnimState:AnimDone() then
		    if inst.bufferedaction ~= nil then
			inst:PerformBufferedAction()
		    else
			inst.sg:GoToState("idle")
		    end
		end
	    end)
        }
    }
)

AddStategraphState(
    "wilsonghost",
    State {
        name = "sdf_enchanted_earth_tomb_in_pre",
        tags = {"doing", "busy", "canrotate"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("dissipate", false)
            inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_haunt", nil, nil, true)
        end,
        events = {
            EventHandler("animover",function(inst)
		if inst.AnimState:AnimDone() then
		    if inst.bufferedaction ~= nil then
			inst:PerformBufferedAction()
		    else
			inst.sg:GoToState("idle")
		    end
		end
	    end)
        }
    }
)

AddStategraphState(
    "wilson",
    State {
        name = "sdf_enchanted_earth_tomb_jump",
        tags = {"doing", "busy", "canrotate", "nopredict", "nomorph"},
        onenter = function(inst, data)
            _IQQ(inst)
            --ToggleOffPhysics(inst)
            inst.components.locomotor:Stop()
            inst.sg.statemem.target = data.sdf_enchanted_earth_tomb_teleporter
            inst.sg.statemem.heavy = inst.components.inventory:IsHeavyLifting()
            if data.sdf_enchanted_earth_tomb_teleporter ~= nil and data.sdf_enchanted_earth_tomb_teleporter.components.sdf_enchanted_earth_tomb_teleporter ~= nil then
                data.sdf_enchanted_earth_tomb_teleporter.components.sdf_enchanted_earth_tomb_teleporter:RegisterTeleportee(inst)
            end


            inst.AnimState:PlayAnimation("give_pst", false)
            local pos = data ~= nil and data.sdf_enchanted_earth_tomb_teleporter and data.sdf_enchanted_earth_tomb_teleporter:GetPosition() or nil
            local dist
            if pos ~= nil then
                inst:ForceFacePoint(pos:Get())
            else
                inst.sg.statemem.speed = 0
                dist = 0
            end
            inst.sg.statemem.sdf_enchanted_earth_tomb_teleportarrivestate = "idle"
        end,
        timeline = {
            TimeEvent(10 * FRAMES,function(inst)
		if not inst.sg.statemem.heavy then
		    inst.Physics:Stop()
		end
		if inst.sg.statemem.target ~= nil then
		    if inst.sg.statemem.target:IsValid() then
			inst.sg.statemem.target:PushEvent("starttravelsound", inst)
		    else
			inst.sg.statemem.target = nil
		    end
		end
	    end)
        },
        events = {
	    EventHandler("animover",function(inst)
		if inst.AnimState:AnimDone() then
		    if inst.sg.statemem.target ~= nil and inst.sg.statemem.target:IsValid() and inst.sg.statemem.target.components.sdf_enchanted_earth_tomb_teleporter ~= nil then
			inst.sg.statemem.target.components.sdf_enchanted_earth_tomb_teleporter:UnregisterTeleportee(a)
			if inst.sg.statemem.target.components.sdf_enchanted_earth_tomb_teleporter:Activate(inst) then
			    inst.sg.statemem.isteleporting = true
			    inst.components.health:SetInvincible(true)
			    if inst.components.playercontroller ~= nil then
				inst.components.playercontroller:Enable(false)
			    end
			    inst:Hide()
			    inst.DynamicShadow:Enable(false)
			    return
			end
		    end
		    inst.sg:GoToState("idle")
		end
	    end)
        },
        onexit = function(inst)
            if inst.sg.statemem.isphysicstoggle then
                XpkjA(inst)
            end
            inst.Physics:Stop()
            if inst.sg.statemem.isteleporting then
                inst.components.health:SetInvincible(false)
                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:Enable(true)
                end
                inst:Show()
                inst.DynamicShadow:Enable(true)
            elseif
                inst.sg.statemem.target ~= nil and inst.sg.statemem.target:IsValid() and
		inst.sg.statemem.target.components.sdf_enchanted_earth_tomb_teleporter ~= nil
             then
                inst.sg.statemem.target.components.sdf_enchanted_earth_tomb_teleporter:UnregisterTeleportee(inst)
            end
        end
    }
)

AddStategraphState(
    "wilsonghost",
    State {
        name = "sdf_enchanted_earth_tomb_jump",
        tags = {"doing", "busy", "canrotate", "nopredict", "nomorph"},
        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            inst.sg.statemem.target = data.sdf_enchanted_earth_tomb_teleporter
            inst.sg.statemem.sdf_enchanted_earth_tomb_teleportarrivestate = "idle"
            inst.sg.statemem.target:PushEvent("starttravelsound", inst)
            if inst.sg.statemem.target ~= nil and inst.sg.statemem.target.components.sdf_enchanted_earth_tomb_teleporter ~= nil and inst.sg.statemem.target.components.sdf_enchanted_earth_tomb_teleporter:Activate(inst) then
                inst.sg.statemem.isteleporting = true
                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:Enable(false)
                end
                inst:Hide()
            else
                inst.sg:GoToState("idle")
            end
        end,
        onexit = function(inst)
            if inst.sg.statemem.isteleporting then
                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:Enable(true)
                end
                inst:Show()
            end
        end
    }
)

AddStategraphState(
    "wilson_client",
    State {name = "sdf_enchanted_earth_tomb_in_pre", tags = {"doing", "busy", "canrotate"},
	onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("give")
            inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")
            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(1)
        end,

	onupdate = function(inst)
            if inst:HasTag("doing") then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

	ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end}
)

AddStategraphState(
    "wilsonghost_client",
    State {name = "sdf_enchanted_earth_tomb_in_pre", tags = {"doing", "busy", "canrotate"},
	onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("dissipate")
            inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_haunt", nil, nil, true)
            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(1)
        end,

	onupdate = function(inst)
            if inst:HasTag("doing") then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation("appear")
                inst.sg:GoToState("idle", true)
            end
        end,

	ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("appear")
            inst.sg:GoToState("idle", true)
        end}
)