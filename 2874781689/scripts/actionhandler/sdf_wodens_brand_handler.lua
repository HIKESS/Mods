local FRAMES = GLOBAL.FRAMES
local TimeEvent = GLOBAL.TimeEvent
local EventHandler = GLOBAL.EventHandler
local State = GLOBAL.State
local SpawnPrefab = GLOBAL.SpawnPrefab
local Vector3 = GLOBAL.Vector3
local DEGREES = GLOBAL.DEGREES
local PI = GLOBAL.PI

local function ClearStatusAilments(inst)
    if inst.components.freezable ~= nil and inst.components.freezable:IsFrozen() then
        inst.components.freezable:Unfreeze()
    end
    if inst.components.pinnable ~= nil and inst.components.pinnable:IsStuck() then
        inst.components.pinnable:Unstick()
    end
end

sdf_wodens_brand_knockback = State({
    name = "sdf_wodens_brand_knockback",
    tags = { "knockback", "busy", "nopredict", "nomorph", "nodangle", "nointerrupt", "jumping" },

        onenter = function(inst, data)
            ClearStatusAilments(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

	    inst.AnimState:PlayAnimation("buck_pst")
	end,

        onupdate = function(inst)
            if inst.sg.statemem.speed ~= nil then
                inst.sg.statemem.speed = inst.sg.statemem.speed + inst.sg.statemem.dspeed
                if inst.sg.statemem.speed < 0 then
                    inst.sg.statemem.dspeed = inst.sg.statemem.dspeed + .075
                    inst.Physics:SetMotorVel(inst.sg.statemem.reverse and -inst.sg.statemem.speed or inst.sg.statemem.speed, 0, 0)
                else
                    inst.sg.statemem.speed = nil
                    inst.sg.statemem.dspeed = nil
                    inst.Physics:Stop()
                end
            end
        end,

        timeline =
        {
            TimeEvent(1 * FRAMES, function(inst)
		local x,_,z=inst.Transform:GetWorldPosition()
                local knockbackDust = SpawnPrefab("plant_dug_small_fx").Transform:SetPosition(x,_-0.5,z)
                inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
		    inst.sg:RemoveStateTag("pinned")
		    inst.sg:RemoveStateTag("knockback")
		    inst.sg:RemoveStateTag("busy")
		    inst.sg:RemoveStateTag("nomorph")
		    inst.sg:RemoveStateTag("nointerrupt")
		    inst.sg:RemoveStateTag("jumping")
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
	    if inst.sg.statemem.restoremass ~= nil then
		inst.Physics:SetMass(inst.sg.statemem.restoremass)
	    end
            if inst.sg.statemem.isphysicstoggle then
                ToggleOnPhysics(inst)
            end
            if inst.sg.statemem.speed ~= nil then
                inst.Physics:Stop()
            end
        end,
})
--------------------------------------------WILSON SG ACTIONHANDLER FOR ATTACK OVERRIDE---------------------------------------------------------------------------
AddStategraphState("wilson", sdf_wodens_brand_knockback)

--------------------------------------------WILSON SG ACTIONHANDLER FOR ATTACK OVERRIDE---------------------------------------------------------------------------