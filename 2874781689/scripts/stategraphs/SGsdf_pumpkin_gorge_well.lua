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
        name = "sdf_pumpkin_gorge_well_in_pre",
        tags = {"doing", "busy", "canrotate"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("give")
            --inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")
        end,
        events = {
            EventHandler("animover", function(inst)
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
        name = "sdf_pumpkin_gorge_well_in_pre",
        tags = {"doing", "busy", "canrotate"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("dissipate", false)
            inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_haunt", nil, nil, true)
        end,
        events = {
            EventHandler("animover", function(inst)
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
        name = "sdf_pumpkin_gorge_well_jump",
        tags = {"doing", "busy", "canrotate", "nopredict", "nomorph"},
        onenter = function(inst, data)
 	    _IQQ(inst)
            --ToggleOffPhysics(inst)
            inst.components.locomotor:Stop()
            inst.sg.statemem.target = data.sdf_pumpkin_gorge_well_teleporter
            inst.sg.statemem.heavy = inst.components.inventory:IsHeavyLifting()
            if data.sdf_pumpkin_gorge_well_teleporter ~= nil and data.sdf_pumpkin_gorge_well_teleporter.components.sdf_pumpkin_gorge_well_teleporter ~= nil then
                data.sdf_pumpkin_gorge_well_teleporter.components.sdf_pumpkin_gorge_well_teleporter:RegisterTeleportee(inst)
            end

	    --animation base on well or exit
	    if data.sdf_pumpkin_gorge_well_teleporter ~= nil and data.sdf_pumpkin_gorge_well_teleporter:HasTag("sdf_pumpkin_gorge_well_door_exit") then
		inst.AnimState:PlayAnimation("hooked_tight_reeling", false) --"give_pst"

		local pos = data ~= nil and data.sdf_pumpkin_gorge_well_teleporter and data.sdf_pumpkin_gorge_well_teleporter:GetPosition() or nil

		local dist
		if pos ~= nil then
		    inst:ForceFacePoint(pos:Get())
		else
		    inst.sg.statemem.speed = 0
                    dist = 0
		end
		inst.sg.statemem.sdf_pumpkin_gorge_well_teleportarrivestate = "idle"
	    else
		inst.AnimState:PlayAnimation("jump", false) --("jump", false)

		local x, y, z = inst.Transform:GetWorldPosition()
		inst.Physics:Teleport(x, 3, z) --4  3
		inst.Physics:SetMotorVel(5, -4, 0) --5, -8   5, -4

		inst.sg.statemem.sdf_pumpkin_gorge_well_teleportarrivestate = "idle" -- this can be overriden in the teleporter component
	    end
        end,
        timeline = {
	    TimeEvent(10 * FRAMES, function(inst)
		inst.Physics:SetMotorVel(2, -4, 0)
	    end),
		
	    TimeEvent(15 * FRAMES, function(inst)
		inst.sg:RemoveStateTag("nointerrupt")
		inst.Physics:SetMotorVel(0, -4, 0)
	    end),
		
	    TimeEvent(16 * FRAMES, function(inst)
		inst.SoundEmitter:PlaySound("wanda1/wanda/jump_whoosh")
		--inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
	    end),
		
	    TimeEvent(17 * FRAMES, function(inst)
		inst.Physics:SetMotorVel(0, -4, 0)
	    end),
        },
        events = {
            EventHandler("animover", function(inst)
		if inst.AnimState:AnimDone() then
		    inst.Physics:Stop()

		    if inst.sg.statemem.target ~= nil and inst.sg.statemem.target:IsValid() and inst.sg.statemem.target.components.sdf_pumpkin_gorge_well_teleporter ~= nil then
			inst.sg.statemem.target.components.sdf_pumpkin_gorge_well_teleporter:UnregisterTeleportee(inst)
			if inst.sg.statemem.target.components.sdf_pumpkin_gorge_well_teleporter:Activate(inst) then
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
            elseif inst.sg.statemem.target ~= nil and inst.sg.statemem.target:IsValid() and inst.sg.statemem.target.components.sdf_pumpkin_gorge_well_teleporter ~= nil then
                inst.sg.statemem.target.components.sdf_pumpkin_gorge_well_teleporter:UnregisterTeleportee(inst)
            end
        end
    }
)

AddStategraphState(
    "wilsonghost",
    State {
        name = "sdf_pumpkin_gorge_well_jump",
        tags = {"doing", "busy", "canrotate", "nopredict", "nomorph"},
        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            inst.sg.statemem.target = data.sdf_pumpkin_gorge_well_teleporter
            inst.sg.statemem.sdf_pumpkin_gorge_well_teleportarrivestate = "idle"
            inst.sg.statemem.target:PushEvent("starttravelsound", inst)
            if inst.sg.statemem.target ~= nil and inst.sg.statemem.target.components.sdf_pumpkin_gorge_well_teleporter ~= nil and inst.sg.statemem.target.components.sdf_pumpkin_gorge_well_teleporter:Activate(inst) then
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
    State {name = "sdf_pumpkin_gorge_well_in_pre", tags = {"doing", "busy", "canrotate"},
	onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("give")
            --inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")
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
    State {name = "sdf_pumpkin_gorge_well_in_pre", tags = {"doing", "busy", "canrotate"},
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