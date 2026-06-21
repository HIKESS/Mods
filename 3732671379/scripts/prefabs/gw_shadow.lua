local assets_despawn_fx =
{
	Asset("ANIM", "anim/statue_ruins_fx.zip"),
}

local prefabs =
{
    "shadow_despawn",
	"shadow_glob_fx",
    "statue_transition_2",
    "nightmarefuel",
	"ocean_splash_med1",
	"ocean_splash_med2",
	"ocean_splash_small1",
	"ocean_splash_small2",
}

local brain = require("brains/gw_shadowbrain")

local function nokeeptargetfn(inst)
    return false
end

local function workerfn(inst)
    inst:AddComponent("inventory")
    -- inst.components.combat:SetKeepTargetFunction(nokeeptargetfn) 
    inst.components.inventory.maxslots = 1
	inst.components.follower.noleashing = true
end

local function DropAggro(inst)
	local leader = inst.components.follower:GetLeader()
	if leader ~= nil and
		(	(leader.components.health ~= nil and leader.components.health:IsDead()) or
			(leader.sg ~= nil and leader.sg:HasStateTag("hiding")) or
			not inst:IsNear(leader, TUNING.SHADOWWAXWELL_PROTECTOR_TRANSFER_AGGRO_RANGE) or
			not leader.entity:IsVisible() or
			leader:HasTag("playerghost")
		) then
		--dead, hiding, or too far
		leader = nil
	end
	--nil leader will just drop target
	inst:PushEvent("transfercombattarget", leader)
end

local function nodebrisdmg(inst, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
    return afflicter ~= nil and afflicter:HasTag("quakedebris")
end

local function MakeMinion(prefab)
    local assets =
    {
        Asset("PKGREF", "anim/waxwell_shadow_mod.zip"), -- Deprecated asset but mods might use it.
        Asset("SOUND", "sound/maxwell.fsb"),

		Asset("ANIM", "anim/waxwell_minion_spawn.zip"),
		Asset("ANIM", "anim/waxwell_minion_appear.zip"),
		Asset("ANIM", "anim/splash_weregoose_fx.zip"),
		Asset("ANIM", "anim/splash_water_drop.zip"),
    }

	local prefabs_override

    table.insert(assets, Asset("ANIM", "anim/waxwell_minion_idle.zip"))

    prefabs_override = shallowcopy(prefabs)

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

		inst:SetPhysicsRadiusOverride(.5)
		MakeGhostPhysics(inst, 1, inst.physicsradiusoverride)

        inst.Transform:SetFourFaced(inst)

        inst.AnimState:SetBank("wilson")
        inst.AnimState:SetBuild("gwen") 
        inst.AnimState:OverrideSymbol("fx_wipe", "wilson_fx", "fx_wipe")
		inst.AnimState:PlayAnimation("minion_spawn")
        inst.AnimState:UsePointFiltering(true)
        inst.AnimState:SetMultColour(0, 0, 0, 0.5) 
        inst.AnimState:SetScale(1.0,1.0,1.0)

		inst.AnimState:AddOverrideBuild("waxwell_minion_spawn")
		inst.AnimState:AddOverrideBuild("waxwell_minion_appear")

        inst.AnimState:Show("ARM_carry")
        inst.AnimState:Hide("ARM_normal")
        inst.AnimState:OverrideSymbol("swap_object", "swap_duoluo", "swap_duoluo")

        inst:AddTag("scarytoprey")
        inst:AddTag("NOBLOCK")
        inst:AddTag("gw_shadow")
        inst:AddTag("shadowminion")

        inst:AddTag("NOCLICK")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("locomotor")
        inst.components.locomotor.runspeed = TUNING.SHADOWWAXWELL_SPEED
	    inst.components.locomotor:SetTriggersCreep(false)
        inst.components.locomotor.pathcaps = { ignorecreep = true }
        inst.components.locomotor:SetSlowMultiplier(.6)

        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(100)
        inst.components.health.nofadeout = true
        inst.components.health:SetAbsorptionAmount(1)

        
        -- inst:AddComponent("combat")
        -- inst.components.combat.hiteffectsymbol = "torso"
        -- inst.components.combat:SetRange(2)

        inst:AddComponent("follower")
        inst.components.follower.keepdeadleader = true
        inst.components.follower.keepleaderonattacked = true

        inst:AddComponent("timer")

        -- inst:AddComponent("pinnable")

        local old = inst.components.follower.SetLeader
        inst.components.follower.SetLeader = function (s,new_leader,...)
            if new_leader then 
                if s.leader ~= nil then
                    for k, v in pairs(s.inst.event_listening['performaction'] or {}) do
                        for source,fn in pairs(v) do 
                            if k == s.leader then 
                                s.inst:RemoveEventCallback('performaction', fn, k)
                            end 
                        end 
                    end     
                end
                s.inst:ListenForEvent("performaction",function (player,data)
                    if data and data.action and data.action.action and (data.action.action.id == "DIG" or 
                     data.action.action.id == "MINE" or data.action.action.id == "CHOP" or data.action.action.id == "NET")then
                        if s.inst.shouldwork ~= true then 
                            s.inst.shouldwork = true 
                            s.inst:StopBrain()
                            s.inst:RestartBrain()
                        end 
                        if s.inst._stopwork ~= nil then
                            s.inst._stopwork:Cancel()
                            s.inst._stopwork = nil 
                        end
                        s.inst._stopwork = s.inst:DoTaskInTime(30,function ()
                            s.inst.shouldwork = false 
                            inst.sg.mem.swaptool = nil 
                            s.inst:StopBrain()
                            s.inst:RestartBrain()
                            inst.sg:GoToState("item_out_atk")
                        end)
                    end                            
                end,new_leader)
                s.inst:ListenForEvent("onhitother",function (player,data)
                    if data and data.target and s.inst.shouldwork == true then
                        s.inst:stopworking()
                    end
                end,new_leader)
            end 
            old(s,new_leader,...)
        end

        inst:SetBrain(brain)
        inst:SetStateGraph("SGgw_shadow")

		inst:ListenForEvent("death", DropAggro)

		inst.DropAggro = DropAggro
        inst.stopworking = function (inst)
            if inst._stopwork ~= nil then
                inst._stopwork:Cancel()
                inst._stopwork = nil 
            end
            inst.shouldwork = false 
            inst.sg.mem.swaptool = nil 
            inst:StopBrain()
            inst:RestartBrain()
            inst.sg:GoToState("item_out_atk")
        end

        inst:AddComponent("inspectable")


        workerfn(inst)


        return inst
    end

	return Prefab(prefab, fn, assets, prefabs_override or prefabs)
end

return 
    MakeMinion("gw_shadow")