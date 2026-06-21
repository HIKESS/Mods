local function ClearStatusAilments(inst)
    if inst.components.freezable ~= nil and inst.components.freezable:IsFrozen() then
        inst.components.freezable:Unfreeze()
    end
    if inst.components.pinnable ~= nil and inst.components.pinnable:IsStuck() then
        inst.components.pinnable:Unstick()
    end
end

local function ForceStopHeavyLifting(inst)
    if inst.components.inventory:IsHeavyLifting() then
        inst.components.inventory:DropItem(
            inst.components.inventory:Unequip(EQUIPSLOTS.BODY),
            true,
            true
        )
    end
end

sdf_hero_status = State({
    name = "sdf_hero_status",
    tags = { "busy", "nopredict", "transform", "nomorph", "nointerrupt" },
    
    onenter = function(inst)
            ClearStatusAilments(inst)
            ForceStopHeavyLifting(inst)
            inst:SetCameraDistance(14)
            inst.Physics:Stop()
            inst.components.locomotor:Stop()
            inst.components.inventory:Close(true) --true to keep activeitem over seamless player swap
            inst:PushEvent("ms_closepopups")
	    inst.components.health:SetInvincible(true)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
                inst.components.playercontroller:EnableMapControls(false)
            end

            inst.AnimState:PlayAnimation("deform_pre")
	    inst.components.bloomer:PushBloom("Hero", "shaders/anim.ksh", 50)

            SpawnPrefab("monkey_deform_pre_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
        end,

        timeline =
        {
            TimeEvent(78*FRAMES, function(inst)
		inst:DoTaskInTime(9, function()
		    if inst.components.playercontroller ~= nil then
			inst.components.playercontroller:EnableMapControls(true)
			inst.components.playercontroller:Enable(true)
		    end
		    inst:SetCameraDistance()
		    inst.components.health:SetInvincible(false)
		    inst.components.inventory:Open(true)
		    inst.components.bloomer:PopBloom("Hero")
		end)
	    inst.sg:GoToState("idle")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                end
            end),
        },

        onexit = function(inst)
        end,
})

--------------------------------------------WILSON SG ACTIONHANDLER FOR HERO STATUS ANIMATION OVERRIDE---------------------------------------------------------------------------
AddStategraphState("wilson", sdf_hero_status)

--------------------------------------------WILSON SG ACTIONHANDLER FOR ATTACK OVERRIDE---------------------------------------------------------------------------