local ThePlayer = GLOBAL.ThePlayer
local TheInput = GLOBAL.TheInput
local SpawnPrefab = GLOBAL.SpawnPrefab

GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----


local function IsPassableAtPoint(x, y, z)
    local grounds = TheSim:FindEntities(x, y, z, 30, { "FAKEGROUND" })
    for _, v in ipairs(grounds) do
        local v_pos = v:GetPosition()
        local target_pos = Vector3(x, y, z)
        local dist = target_pos:Dist(v_pos)

        if v.FAKEGROUND_RADIUS == nil or v.FAKEGROUND_RADIUS >= dist then
            return true
        end
    end
    return TheWorld.Map:IsAboveGroundAtPoint(x, y, z)
end

local function rescue(inst, begin)
    inst:PutBackOnGround()
    if not IsPassableAtPoint(inst:GetPosition():Get()) then
        if inst.Physics ~= nil then
            inst.Physics:Teleport(begin:Get())
        end
        if inst.Transform ~= nil then
            inst.Transform:SetPosition(begin:Get())
        end
    end
    if inst.components.talker then
        inst.components.talker:Say("干了,掉海里了!")
    end
end

local function ToggleOffPhysics(inst)
    inst.sg.statemem.isphysicstoggle = true
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
end

local function ToggleOnPhysics(inst)
    inst.sg.statemem.isphysicstoggle = nil
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.GIANTS)
end

-- **主机端冲刺状态**------------------------------------------------------
AddStategraphState("wilson",
    State {
        name = "corin_rush",
        tags = { "busy", "evade", "dodge", "no_stun", "nopredict" },

        onenter = function(inst, targetpos)
            inst.components.locomotor:Stop()
			
			if inst.current_location == nil then
				inst.current_location = Vector3(inst.Transform:GetWorldPosition())
			end

            
            if not (inst.components.rider and inst.components.rider:IsRiding()) then
                inst.AnimState:PlayAnimation("atk_leap_lag") -- 冲刺动画
				inst.SoundEmitter:PlaySound("Gwen_sound/Gwen_sfx/Gwen_Z",nil,.12) ----声音冲刺、剪刀
            end

			if inst.components.gwen_competence:Get_mianxiang() == 0
			and inst.components.gwen_competence:Get_Zkeepmianxiang() ~= 1
			then
				inst:ForceFacePoint(targetpos:Get())
			end
			inst.components.gwen_competence:mianxiang_0()
			
			local px, py, pz = inst.Transform:GetWorldPosition()
			local found_water = TheWorld.Map:IsVisualGroundAtPoint(px, 0, pz)
			if found_water or inst:HasTag("gwen_flying") then
                if not inst.components.skilltreeupdater:IsActivated("gwen_dash_shadow_2") then
				    inst.Physics:SetMotorVelOverride(30, 0, 0)
                else
                    inst.Physics:SetMotorVelOverride(34, 0, 0)
                end
			end

			inst:StartThread(function()
				for i = 0,4 do
					local pos =	Vector3(inst.Transform:GetWorldPosition())
					inst.gwen_chongci = SpawnPrefab("gwen_chongci")
					inst.gwen_chongci:SetOwner(inst)
					inst.gwen_chongci.Transform:SetPosition(pos.x, 0, pos.z)
					Sleep(.01)
				end
			end)


            if inst and inst.components.skilltreeupdater then
                if inst.components.skilltreeupdater:IsActivated("gwen_dash_shadow_1") then
                    inst.AnimState:SetMultColour(0.1, 0.6, 0.4, 0.6)
                    local shadow = SpawnAt("gwen_dash_shadow", inst)
                    if shadow then
                        shadow:ForceFacePoint(targetpos:Get())
                        shadow:SetOwner(inst, 2)
                    end
                end
            end


			ToggleOffPhysics(inst)

            inst.components.locomotor:EnableGroundSpeedMultiplier(false)
            inst.components.health:SetInvincible(true)

            inst.sg.statemem.beginpos = inst:GetPosition()
            inst.sg.statemem.targetpos = targetpos

            inst.sg:SetTimeout(0.2) -- 冲刺时间 0.2 秒
        end,

        onupdate = function(inst)
			local px, py, pz = inst.Transform:GetWorldPosition()
			local found_water = TheWorld.Map:IsVisualGroundAtPoint(px, 0, pz)
			if found_water or inst:HasTag("gwen_flying") then
				if not inst.components.skilltreeupdater:IsActivated("gwen_dash_shadow_2") then
				    inst.Physics:SetMotorVelOverride(30, 0, 0)
                else
                    inst.Physics:SetMotorVelOverride(34, 0, 0)
                end
			end
        end,

        timeline = {
            TimeEvent(0.2, function(inst)
                inst.components.health:SetInvincible(false) -- 0.2 秒后取消无敌
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle") -- 冲刺结束
        end,

        onexit = function(inst)
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)
            inst.Physics:ClearMotorVelOverride()
            inst.components.locomotor:Stop()
            inst.components.health:SetInvincible(false)
            inst.AnimState:SetMultColour(1, 1, 1, 1)
			if not inst:HasTag("gwen_flying") then
				--[[ 如果掉入海洋，回到起点
				if not inst:IsOnPassablePoint(true) then
					rescue(inst, inst.sg.statemem.beginpos)
				end]]
				local x, y, z = inst.Transform:GetWorldPosition()
				local local_passable = TheWorld.Map:IsPassableAtPoint(x, 0, z)
				if not local_passable then
					if inst.current_location ~= nil then
						inst.Transform:SetPosition(inst.current_location.x, inst.current_location.y, inst.current_location.z)
					end
				end
				inst.current_location = nil

				ToggleOnPhysics(inst)
			end
        end,
    }
)

-- **客户端冲刺状态**
AddStategraphState("wilson_client",
    State {
        name = "corin_rush",
        tags = { "busy", "evade", "dodge", "no_stun", "nopredict" },

        onenter = function(inst, targetpos)
            if not (inst.replica.rider and inst.replica.rider:IsRiding()) then
                inst.AnimState:PlayAnimation("atk_leap_lag") -- 客户端冲刺动画
            end
            inst:ForceFacePoint(targetpos:Get())
            inst.sg:SetTimeout(0.1) -- 设定持续时间
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle") -- 结束冲刺
        end,
    }
)


-- **主机端剪刀1状态**------------------------------------------------------
AddStategraphState("wilson",
    State {
        name = "gwenw_jiiandao_start",
        --tags = { "nopredict", "forcedangle", "busy", "nointerrupt", "nomorph", "evade", "dodge", "no_stun", "preshear", "shearing", "working" },
		tags = {"nopredict", "forcedangle", "busy", "nointerrupt", "preshear", "shearing", "working" },

        onenter = function(inst, targetpos)
            inst.components.locomotor:Stop()

			if inst.components.gwen_competence:Get_mianxiang() == 0 
			and inst.components.gwen_competence:Get_Vkeepmianxiang() ~= 1
			then
				inst:ForceFacePoint(targetpos:Get())
			end
			if inst.components.gwen_competence:Get_cengshu() <= 1 then
				inst.components.gwen_competence:mianxiang_0()
			end

			if inst.components.rider ~= nil and inst.components.rider:IsRiding() then
				inst.AnimState:PlayAnimation("atk_pre")
			else
				inst.AnimState:PlayAnimation("cut_pre")
			end

			inst.components.health:SetInvincible(true)
        end,
		
        timeline = {
            TimeEvent(3 * FRAMES, function(inst)
                inst.components.health:SetInvincible(false)
            end),
        },

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("gwenw_jiiandao")
                end
            end),
        },

    }
)

-- **客户端剪刀1状态**
AddStategraphState("wilson_client",
    State {
        name = "gwenw_jiiandao_start",
        --tags = { "nopredict", "forcedangle", "busy", "nointerrupt", "nomorph", "evade", "dodge", "no_stun", "preshear", "shearing", "working" },
		tags = {"nopredict", "forcedangle", "busy", "nointerrupt", "preshear", "shearing", "working" },

        onenter = function(inst, targetpos)
            inst.components.locomotor:Stop()

			if inst.components.gwen_competence:Get_mianxiang() == 0 
			and inst.components.gwen_competence:Get_Vkeepmianxiang() ~= 1
			then
				inst:ForceFacePoint(targetpos:Get())
			end
			if inst.components.gwen_competence:Get_cengshu() <= 1 then
				inst.components.gwen_competence:mianxiang_0()
			end

			if inst.components.rider ~= nil and inst.components.rider:IsRiding() then
				inst.AnimState:PlayAnimation("atk_pre")
			else
				inst.AnimState:PlayAnimation("cut_pre")
			end

			inst.components.health:SetInvincible(true)
        end,
		
        timeline = {
            TimeEvent(3 * FRAMES, function(inst)
                inst.components.health:SetInvincible(false)
            end),
        },

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("gwenw_jiiandao")
                end
            end),
        },
    }
)



-- **主机端剪刀2状态**------------------------------------------------------
AddStategraphState("wilson",
    State {
        name = "gwenw_jiiandao",
		--tags = { "nopredict", "forcedangle", "busy", "nointerrupt", "nomorph", "evade", "dodge", "no_stun", "preshear", "shearing", "working" },
		tags = {"nopredict", "forcedangle", "busy", "nointerrupt", "preshear", "shearing", "working" },

		onenter = function(inst, targetpos)
			inst.components.locomotor:Stop()

			if inst.components.gwen_competence:Get_mianxiang() == 0 
			and inst.components.gwen_competence:Get_Vkeepmianxiang() ~= 1
			and inst.components.gwen_competence:Get_cengshu() > 1
			then
                if targetpos ~= nil then
                    inst:ForceFacePoint(targetpos:Get())
                end
			end
			inst.components.gwen_competence:mianxiang_0()

			if inst.components.rider ~= nil and inst.components.rider:IsRiding() then
				inst.AnimState:PlayAnimation("atk_pre")
				inst.AnimState:PushAnimation("atk", false)
			else
				inst.AnimState:PlayAnimation("cut_loop")
			end

			if inst and inst:IsValid() then
				local x,y,z = inst.Transform:GetWorldPosition()
				inst.gwen_jiandaofx = SpawnPrefab("gwen_jiandaofx")
				if inst.gwen_jiandaofx then
					inst.gwen_jiandaofx:AddTag("mianxiang")
					inst.gwen_jiandaofx:SetOwner(inst)
					inst.gwen_jiandaofx.Transform:SetPosition(x,y+1,z)
				end
				inst.gwen_jiandaofx1 = SpawnPrefab("gwen_jiandaofx")
				if inst.gwen_jiandaofx1 then
					inst.gwen_jiandaofx1:AddTag("mianxiang")
					inst.gwen_jiandaofx1:AddTag("fly_yingzi")
					inst.gwen_jiandaofx1:SetOwner(inst)
					inst.gwen_jiandaofx1.Transform:SetPosition(x,y,z)
				end
			end

			inst.components.health:SetInvincible(true)
		end,

        timeline =
        {
			TimeEvent(3 * FRAMES, function(inst)
                inst.components.health:SetInvincible(false)
            end),

            TimeEvent(4 * FRAMES, function(inst)
                inst:PerformBufferedAction()
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/harvested/grass_tall/shears")
            end),

            TimeEvent(9 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("preshear")
            end),

            TimeEvent(16 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("shearing")
            end),

        },

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
					if inst.components.rider ~= nil and inst.components.rider:IsRiding() then
						inst.sg:GoToState("idle")
					else
						inst.AnimState:PlayAnimation("cut_pst")
						inst.sg:GoToState("idle", true)
					end

                end
            end),
        },

    }
)

-- **客户端剪刀2状态**
AddStategraphState("wilson_client",
    State {
        name = "gwenw_jiiandao",
		--tags = { "nopredict", "forcedangle", "busy", "nointerrupt", "nomorph", "evade", "dodge", "no_stun", "preshear", "shearing", "working" },
		tags = {"nopredict", "forcedangle", "busy", "nointerrupt", "preshear", "shearing", "working" },

		onenter = function(inst, targetpos)
			inst.components.locomotor:Stop()

			if inst.components.gwen_competence:Get_mianxiang() == 0 
			and inst.components.gwen_competence:Get_Vkeepmianxiang() ~= 1
			and inst.components.gwen_competence:Get_cengshu() > 1
			then
                if targetpos ~= nil then
                    inst:ForceFacePoint(targetpos:Get())
                end
			end
			inst.components.gwen_competence:mianxiang_0()

			if inst.components.rider ~= nil and inst.components.rider:IsRiding() then
				inst.AnimState:PlayAnimation("atk_pre")
				inst.AnimState:PushAnimation("atk", false)
			else
				inst.AnimState:PlayAnimation("cut_loop")
			end

			if inst and inst:IsValid() then
				local x,y,z = inst.Transform:GetWorldPosition()
				inst.gwen_jiandaofx = SpawnPrefab("gwen_jiandaofx")
				if inst.gwen_jiandaofx then
					inst.gwen_jiandaofx:AddTag("mianxiang")
					inst.gwen_jiandaofx:SetOwner(inst)
					inst.gwen_jiandaofx.Transform:SetPosition(x,y+1,z)
				end
				inst.gwen_jiandaofx1 = SpawnPrefab("gwen_jiandaofx")
				if inst.gwen_jiandaofx1 then
					inst.gwen_jiandaofx1:AddTag("mianxiang")
					inst.gwen_jiandaofx1:AddTag("fly_yingzi")
					inst.gwen_jiandaofx1:SetOwner(inst)
					inst.gwen_jiandaofx1.Transform:SetPosition(x,y,z)
				end
			end

			inst.components.health:SetInvincible(true)
		end,

        timeline =
        {
			TimeEvent(3 * FRAMES, function(inst)
                inst.components.health:SetInvincible(false)
            end),

            TimeEvent(4 * FRAMES, function(inst)
                inst:PerformBufferedAction()
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/harvested/grass_tall/shears")
            end),

            TimeEvent(9 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("preshear")
            end),

            TimeEvent(16 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("shearing")
            end),
        },

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
					if inst.components.rider ~= nil and inst.components.rider:IsRiding() then
						inst.sg:GoToState("idle")
					else
						inst.AnimState:PlayAnimation("cut_pst")
						inst.sg:GoToState("idle", true)
					end

                end
            end),
        },
		
    }
)


-- **主机端修理状态**------------------------------------------------------
AddStategraphState("wilson",
    State {
        name = "gwenw_xiuli",
		--tags = { "nopredict", "forcedangle", "busy", "nointerrupt", "nomorph", "evade", "dodge", "no_stun", "preshear", "shearing", "working" },
		tags = {"nopredict", "forcedangle", "busy", "nointerrupt", "preshear", "shearing", "working" },

		onenter = function(inst)
			inst:ClearBufferedAction()
			inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("build_pre")
            inst.AnimState:PushAnimation("build_loop", true)
		end,

		timeline =
		{
            TimeEvent(0 * FRAMES, function(inst)
				inst:PerformBufferedAction()
			end),
			TimeEvent(24 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
				inst.sg:RemoveStateTag("nointerrupt")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
					inst.sg:RemoveStateTag("busy")
					inst.sg:RemoveStateTag("nointerrupt")
				end
			end),
		},
    }
)

-- **客户端修理状态**
AddStategraphState("wilson_client",
    State {
        name = "gwenw_xiuli",
		--tags = { "nopredict", "forcedangle", "busy", "nointerrupt", "nomorph", "evade", "dodge", "no_stun", "preshear", "shearing", "working" },
		tags = {"nopredict", "forcedangle", "busy", "nointerrupt", "preshear", "shearing", "working" },

		onenter = function(inst)
			inst:ClearBufferedAction()
			inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("build_pre")
            inst.AnimState:PushAnimation("build_loop", true)
		end,

		timeline =
		{
            TimeEvent(0 * FRAMES, function(inst)
				inst:PerformBufferedAction()
			end),
			TimeEvent(24 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
				inst.sg:RemoveStateTag("nointerrupt")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
					inst.sg:RemoveStateTag("busy")
					inst.sg:RemoveStateTag("nointerrupt")
				end
			end),
		},
    }
)



-- **主机端起飞状态**------------------------------------------------------
AddStategraphState("wilson",
    State {
        name = "gw_fly",
        tags = {"nopredict", "forcedangle", "busy", "nointerrupt", "preshear", "shearing", "working" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("jumpout")
			inst:AddTag("gwen_flying")
			if inst.Physics then
				RemovePhysicsColliders(inst)
			end
			if inst.components.drownable then
				inst.components.drownable.enabled = false
			end
			if inst.components.locomotor then
				inst.components.locomotor:SetExternalSpeedMultiplier(inst, "gw_fly", 1.25)
			end
			inst.Physics:SetMotorVel(4, 0, 0)
			if inst.gwen_fly == nil then
				inst.gwen_fly = SpawnPrefab("gwen_flyfx")
				inst.gwen_fly.entity:SetParent(inst.entity)
				inst.gwen_fly:SetOwner(inst)
			end
			if inst.gwen_fly2 == nil then
				inst.gwen_fly2 = SpawnPrefab("gwen_flyfx")
				inst.gwen_fly2.entity:SetParent(inst.entity)
				inst.gwen_fly2.Transform:SetPosition(0, -1, 0)
				inst.gwen_fly2:AddTag("fly_yingzi")
				inst.gwen_fly2:SetOwner(inst)
			end
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                if inst.sg.statemem.heavy then
                    inst.Physics:SetMotorVel(3, 0, 0)
                end
            end),
            TimeEvent(12 * FRAMES, function(inst)
                if inst.sg.statemem.heavy then
                    inst.Physics:SetMotorVel(2, 0, 0)
                end
				
            end),
            TimeEvent(16 * FRAMES, function(inst)
                if inst.sg.statemem.heavy then
                    inst.Physics:SetMotorVel(1, 0, 0)
                end
            end),
            TimeEvent(10 * FRAMES, function(inst)
                if not inst.sg.statemem.heavy then
                    inst.Physics:SetMotorVel(3, 0, 0)
                end
            end),
            TimeEvent(15 * FRAMES, function(inst)
                if not inst.sg.statemem.heavy then
                    inst.Physics:SetMotorVel(2, 0, 0)
                end
            end),
            TimeEvent(18 * FRAMES, function(inst)
                inst.Physics:Stop()
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    }
)


-- **客户端起飞状态**
AddStategraphState("wilson_client",
    State {
        name = "gw_fly",
		tags = {"nopredict", "forcedangle", "busy", "nointerrupt", "preshear", "shearing", "working" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			inst:AddTag("gwen_flying")
            inst.AnimState:PlayAnimation("jumpout")
			if inst.Physics then
				RemovePhysicsColliders(inst)
			end
			if inst.components.drownable then
				inst.components.drownable.enabled = false
			end
			if inst.components.locomotor then
				inst.components.locomotor:SetExternalSpeedMultiplier(inst, "gw_fly", 1.2)
			end
			inst.Physics:SetMotorVel(4, 0, 0)
			if inst.gwen_fly == nil then
				inst.gwen_fly = SpawnPrefab("gwen_flyfx")
				inst.gwen_fly.entity:SetParent(inst.entity)
				inst.gwen_fly:SetOwner(inst)
			end
			if inst.gwen_fly2 == nil then
				inst.gwen_fly2 = SpawnPrefab("gwen_flyfx")
				inst.gwen_fly2.entity:SetParent(inst.entity)
				inst.gwen_fly2.Transform:SetPosition(0, -1, 0)
				inst.gwen_fly2:AddTag("fly_yingzi")
				inst.gwen_fly2:SetOwner(inst)
			end
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                if inst.sg.statemem.heavy then
                    inst.Physics:SetMotorVel(3, 0, 0)
                end
            end),
            TimeEvent(12 * FRAMES, function(inst)
                if inst.sg.statemem.heavy then
                    inst.Physics:SetMotorVel(2, 0, 0)
                end
				
            end),
            TimeEvent(16 * FRAMES, function(inst)
                if inst.sg.statemem.heavy then
                    inst.Physics:SetMotorVel(1, 0, 0)
                end
            end),
            TimeEvent(10 * FRAMES, function(inst)
                if not inst.sg.statemem.heavy then
                    inst.Physics:SetMotorVel(3, 0, 0)
                end
            end),
            TimeEvent(15 * FRAMES, function(inst)
                if not inst.sg.statemem.heavy then
                    inst.Physics:SetMotorVel(2, 0, 0)
                end
            end),
            TimeEvent(18 * FRAMES, function(inst)
                inst.Physics:Stop()
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    }
)



----剪刀动作
local function e_jiandao_atk_Master(sg)
	local old_handler = sg.actionhandlers[ACTIONS.ATTACK].deststate
	sg.actionhandlers[ACTIONS.ATTACK].deststate = function(inst, action)
		inst.sg.mem.localchainattack = not action.forced or nil
		local weapon = inst.components.combat ~= nil and inst.components.combat:GetWeapon() or nil
		if weapon and weapon:HasTag("1asdgasgd") then
			return "e_jiandao_atk"                           
		else
			return old_handler(inst, action)
		end
	end
end

local function e_jiandao_atk_Client(sg)
	local old_handler = sg.actionhandlers[ACTIONS.ATTACK].deststate
	sg.actionhandlers[ACTIONS.ATTACK].deststate = function(inst, action)
		local weapon = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		if weapon and weapon:HasTag("1asdgasgd") then
			return "e_jiandao_atk"                            
		else
			return old_handler(inst, action)
		end
	end
end

AddStategraphPostInit("wilson", e_jiandao_atk_Master)
AddStategraphPostInit("wilson_client", e_jiandao_atk_Client) 

local function DoMountSound(inst, mount, sound, ispredicted)
    if mount ~= nil and mount.sounds ~= nil then
        inst.SoundEmitter:PlaySound(mount.sounds[sound], nil, nil, ispredicted)
    end
end

local e_jiandao_atk_M = GLOBAL.State(
	{
        name = "e_jiandao_atk",
        --tags = { "prehammer", "attack", "notalking", "abouttoattack", "autopredict", "doing",  },
		tags = { "attack","notalking",},

        onenter = function(inst)
            local buffaction = inst:GetBufferedAction()
            local target = buffaction ~= nil and buffaction.target or nil
            local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            inst.components.combat:SetTarget(target)
            inst.components.combat:StartAttack()
            inst.components.locomotor:Stop()
            local cooldown = inst.components.combat.min_attack_period + .5 * FRAMES
            if inst.components.rider ~= nil and inst.components.rider:IsRiding() then
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
                DoMountSound(inst, inst.components.rider:GetMount(), "angry", true)
				cooldown = math.max(cooldown, 16 * FRAMES)
            elseif equip ~= nil then
				inst.AnimState:PlayAnimation("cut_loop")
				inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_firestaff", nil, nil, true)
				local weapon = inst.components.combat ~= nil and inst.components.combat:GetWeapon() or nil
				cooldown = math.max(cooldown, 12 * FRAMES)
            else
				inst.AnimState:PlayAnimation("punch")
				inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, nil, true)
				cooldown = math.max(cooldown, 24 * FRAMES)
            end

            inst.sg:SetTimeout(cooldown)

            if target ~= nil then
				inst.components.combat:BattleCry()
				if target:IsValid() then
					inst:FacePoint(target:GetPosition())
					inst.sg.statemem.attacktarget = target
                end
            end
        end,

        timeline =
        {
            TimeEvent(10 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("prehammer")
				inst:PerformBufferedAction()
				inst.sg:RemoveStateTag("abouttoattack")
            end),
        },

        ontimeout = function(inst)
			inst.sg:RemoveStateTag("prehammer")
			inst.sg:RemoveStateTag("attack")
			inst.sg:RemoveStateTag("notalking")
			inst.sg:AddStateTag("idle")
			if inst.bufferedaction == inst.sg.statemem.action then
				inst:ClearBufferedAction()
			end
			inst.sg.statemem.action = nil
        end,

        events =
        {
            EventHandler("equip", function(inst) inst.sg:GoToState("idle")end),
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle")end),
            EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.AnimState:PlayAnimation("cut_pst")
					if inst.components.rider ~= nil and inst.components.rider:IsRiding() then
						inst.sg:GoToState("idle")
					else
						inst.sg:GoToState("idle", true)
					end
				end
			end),
        },

        onexit = function(inst)
            inst.components.combat:SetTarget(nil)
            if inst.sg:HasStateTag("abouttoattack") then
                inst.components.combat:CancelAttack()
            end
			if inst.bufferedaction == inst.sg.statemem.action then
				inst:ClearBufferedAction()
			end
			inst.sg.statemem.action = nil
        end,
    }
)

local e_jiandao_atk_C = GLOBAL.State(

	{
        name = "e_jiandao_atk",
        --tags = { "prehammer", "attack", "notalking", "abouttoattack", "autopredict", "doing" },
        tags = { "attack","notalking",},

        onenter = function(inst)
		
            local cooldown = inst.replica.combat:MinAttackPeriod() + .5 * FRAMES
            if inst.replica.combat ~= nil then
                inst.replica.combat:StartAttack()
            end
            inst.components.locomotor:Stop()
            local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            local rider = inst.replica.rider
            if rider ~= nil and rider:IsRiding() then
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
				DoMountSound(inst, rider:GetMount(), "angry")
				if cooldown > 0 then
					cooldown = math.max(cooldown, 16 * FRAMES)
				end
			elseif equip ~= nil then
				inst.AnimState:PlayAnimation("cut_loop")
				inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_firestaff", nil, nil, true)
				if cooldown > 0 then
					cooldown = math.max(cooldown, 12 * FRAMES)
				end
				if inst.components.playercontroller then
					inst.components.playercontroller:Enable(false)
				end
			else
                inst.AnimState:PlayAnimation("punch")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, nil, true)
				if cooldown > 0 then
					cooldown = math.max(cooldown, 24 * FRAMES)
				end
            end
			    inst:PerformPreviewBufferedAction()
							
            local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil then
                inst:PerformPreviewBufferedAction()
                if buffaction.target ~= nil and buffaction.target:IsValid() then
                    inst:FacePoint(buffaction.target:GetPosition())
                    inst.sg.statemem.attacktarget = buffaction.target
                end
            end

			if cooldown > 0 then
				inst.sg:SetTimeout(cooldown)
			end
			
        end,

        timeline =
        {
            TimeEvent(10 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("prehammer")
				inst:ClearBufferedAction()
				inst.sg:RemoveStateTag("abouttoattack")
            end),
            
        },

        ontimeout = function(inst)
			inst:ClearBufferedAction()
			inst.sg:RemoveStateTag("prehammer")
            inst.sg:RemoveStateTag("attack")
            inst.sg:RemoveStateTag("notalking")
            inst.sg:AddStateTag("idle")
			if inst.bufferedaction == inst.sg.statemem.action then
				inst:ClearBufferedAction()
			end
			inst.sg.statemem.action = nil
        end,

        events =
        {
            EventHandler("equip", function(inst) inst.sg:GoToState("idle")end),
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle")end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.AnimState:PlayAnimation("cut_pst")
					local rider = inst.replica.rider
					if rider ~= nil and rider:IsRiding() then
						inst.sg:GoToState("idle")
					else
						inst.sg:GoToState("idle", true)
					end
                end
            end),
        },

        onexit = function(inst)
            if inst.sg:HasStateTag("abouttoattack") and inst.replica.combat ~= nil then
                inst.replica.combat:CancelAttack()
            end
			if inst.bufferedaction == inst.sg.statemem.action then
				inst:ClearBufferedAction()
			end
			inst.sg.statemem.action = nil
        end,
    }
)

----剪刀动作
AddStategraphState("wilson", e_jiandao_atk_M)
AddStategraphState("wilson_client", e_jiandao_atk_C)



-----瞬移的动作
local gwen_soul_jump = State{
    name = "gwen_soul_jump",
    tags = {"busy", "gwen_soul_jump","noattack","doing",},
    server_states = {"gwen_soul_jump"},

    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("wortox_portal_jumpout")
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller:Enable(false)
        end
        local fx = SpawnPrefab("attune_out_fx")
        if fx ~= nil then
            local x, y, z = inst.Transform:GetWorldPosition()
            fx.Transform:SetPosition(x, y, z)
        end
    end,

    onexit = function(inst)
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller:Enable(true)
        end
    end,

    events = {
        EventHandler("animover", function (inst)
            inst.sg:GoToState("idle")
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
        end)
    },

    ontimeout = function(inst)
        inst:ClearBufferedAction()
        inst.sg:GoToState("idle")
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller:Enable(true)
        end
    end,
}

AddStategraphState("wilson", gwen_soul_jump)
AddStategraphState("wilson_client", gwen_soul_jump)


---------------------------------------------------------------------
---正义冲拳！！！！
local gwen_collision = State{
    name = "gwen_collision",
    tags = {"busy", "gwen_collision","doing",},
    server_states = {"gwen_collision"},

    onenter = function(inst, targetpos)
        inst.components.locomotor:Stop()

        if not (inst.components.rider and inst.components.rider:IsRiding()) then
            inst.AnimState:PlayAnimation("divegrab_pre",false)
            inst.AnimState:PlayAnimation("divegrab_lag",false)
        end

        if inst.current_location == nil then
			inst.current_location = Vector3(inst.Transform:GetWorldPosition())
		end

        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller:Enable(false)
        end
        if inst.components.gwen_competence:Get_mianxiang() == 0
			and inst.components.gwen_competence:Get_Zkeepmianxiang() ~= 1
		then
			inst:ForceFacePoint(targetpos:Get())
		end
        inst.components.gwen_shengai:DoDelta(-3)

        if inst.components.health then
            inst.components.health:SetInvincible(true)
        end

        inst.sg.statemem.beginpos = inst:GetPosition()
        inst.sg.statemem.targetpos = targetpos

        inst.sg:SetTimeout(16 * FRAMES)

        if TUNING.DASH_MAN ~= false then
            inst.SoundEmitter:PlaySound("man/manba/man",nil,0.8) ----肘击音效
        end
        -- inst.sg.statemem.speed = 50
        -- inst.sg.statemem.dspeed = -2
    end,

    -- onupdate = function(inst)
    --     ---- 更新冲刺速度
    --         if inst.sg.statemem.speed ~= nil and not inst.sg.statemem.stopped then
    --             inst.sg.statemem.speed = inst.sg.statemem.speed + inst.sg.statemem.dspeed
    --         end
    --     end,

    timeline = {

        TimeEvent(6 * FRAMES, function(inst)
            local px, py, pz = inst.Transform:GetWorldPosition()
			local found_water = TheWorld.Map:IsVisualGroundAtPoint(px, 0, pz)
            inst.AnimState:SetAddColour(1, 1, 1, 0)
			if found_water or inst:HasTag("gwen_flying") then
				inst.Physics:SetMotorVelOverride(32, 0, 0)
			end
            inst.AnimState:PlayAnimation("spearjab_pre")
            inst.AnimState:PlayAnimation("multithrust")
            inst:StartThread(function()
                for i = 0, 7 do
                    local fx = SpawnAt("gwen_chongquan_fx",inst)
                    fx.Transform:SetRotation(inst.Transform:GetRotation())
                    Sleep(.02)
                end
            end)

            inst.gwen_collision_hit = {}
            inst.sg.statemem.damage_active = true
            inst:StartThread(function()
                while inst.sg and inst.sg:HasStateTag("gwen_collision")  and inst.sg.statemem.damage_active do
                    local x, y, z = inst.Transform:GetWorldPosition()
                    local weapon = inst.components.combat:GetWeapon() or 
                                   inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                    
                    if weapon ~= nil then
                        local weapon_damage = weapon.components.weapon and weapon.components.weapon.damage or 10
                        if type(weapon_damage) == "function" then
                            weapon_damage = weapon_damage(weapon, inst)
                        end
                        local weapon_planar_damage = weapon.components.planardamage and 
                                                     weapon.components.planardamage:GetDamage() or 0
                        local damage_multiplier = inst.components.combat.externaldamagemultipliers:Get() or 1
                        
                        local base_damage = weapon_damage * damage_multiplier * 1.2
                        local planar_damage = weapon_planar_damage
                        local ents = TheSim:FindEntities(x, y, z, 3.4,
                            { "_combat", "_health" }, 
                            { "INLIMBO", "FX", "NOCLICK", "DECOR", "playerghost", 
                              "companion", "wall", "abigail", "shadowminion", "player" })
                        
                        for _, ent in ipairs(ents) do
                            local is_follower = ent.components.follower and 
                                                ent.components.follower:GetLeader() and 
                                                ent.components.follower:GetLeader():HasTag("player")

                            if ent ~= inst and not inst.gwen_collision_hit[ent] and not is_follower then
                                inst.gwen_collision_hit[ent] = true
                                
                                if ent.components.combat and ent.components.health and not ent.components.health:IsDead() then
                                    local damage2 = inst.components.health.maxhealth * 0.05
                                    ent.components.combat:GetAttacked(
                                        inst,
                                        base_damage + damage2,
                                        nil,
                                        nil,
                                        {planar = planar_damage}
                                    )

                                    ent:PushEvent("repel", {
                                        knocker = inst,
                                        strengthmult = 1.2,
                                        radius = 1.2,
                                        is_gwen_repel = true
                                    })

                                    if ent.components.health and ent.components.health.maxhealth >= 1000 then
                                        if inst.components.skilltreeupdater and inst.components.skilltreeupdater:IsActivated("gwen_dash_radiance_2")  then
                                            inst.sg:GoToState("repelled")
                                            inst.components.hunger:DoDelta(-1)
                                             inst.components.gwen_shengai:DoDelta(-3)
                                        else
                                            inst.sg:GoToState("knockback")
                                            inst.components.hunger:DoDelta(-2)
                                             inst.components.gwen_shengai:DoDelta(-5)
                                        end
                                    end
                                end
                            end
                        end
                    end
                    local workable_ents = TheSim:FindEntities(x, 0, z, 2.1, nil, {'INLIMBO'})
                    for _, ent in ipairs(workable_ents) do
                        if ent:IsValid() and ent.components.workable ~= nil and ent.components.workable:CanBeWorked() then
                            if ent.components.workable.action == ACTIONS.CHOP or
                            ent.components.workable.action == ACTIONS.MINE 
                            -- or(ent.components.workable.action == ACTIONS.DIG and ent:HasTag('stump')) 
                            then
                                SpawnPrefab('collapse_small').Transform:SetPosition(ent.Transform:GetWorldPosition())
                                ent.components.workable:WorkedBy(inst, 10000)
                                if inst.components.skilltreeupdater and inst.components.skilltreeupdater:IsActivated("gwen_dash_radiance_2")  then
                                    inst.sg:GoToState("repelled")
                                    inst.components.gwen_shengai:DoDelta(-2)
                                    inst.components.hunger:DoDelta(-2)
                                else
                                    inst.sg:GoToState("knockback")
                                    inst.components.gwen_shengai:DoDelta(-4)
                                    inst.components.hunger:DoDelta(-4)
                                end
                            end
                        end
                    end
                    Sleep(0.01)
                end
            end)
        end),


        TimeEvent(14 * FRAMES, function(inst)
            inst.Physics:ClearMotorVelOverride()

            inst.sg.statemem.damage_active = false
            if inst.components.health then
                inst.components.health:SetInvincible(false)
            end
            inst.sg.statemem.stopped = true

            inst.AnimState:SetAddColour(0, 0, 0, 0)
        end),

    },

    onexit = function(inst)
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller:Enable(true)
        end
        inst.Physics:ClearMotorVelOverride()

        inst.sg.statemem.damage_active = false
        inst.gwen_collision_hit = nil
        inst.sg.statemem.first_hit_done = nil
        
        if inst.components.health then
            inst.components.health:SetInvincible(false)
        end

        inst.AnimState:SetAddColour(0, 0, 0, 0)

        if not inst:HasTag("gwen_flying") then
			local x, y, z = inst.Transform:GetWorldPosition()
			local local_passable = TheWorld.Map:IsPassableAtPoint(x, 0, z)
			if not local_passable then
				if inst.current_location ~= nil then
					inst.Transform:SetPosition(inst.current_location.x, inst.current_location.y, inst.current_location.z)
				end
			end
			inst.current_location = nil
		end
    end,

    events = {
        EventHandler("animover", function (inst)
            inst.sg:GoToState("idle")
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
        end)
    },

    ontimeout = function(inst)
        inst:ClearBufferedAction()
        inst.sg.statemem.damage_active = false
        inst.sg:GoToState("idle")
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller:Enable(true)
        end
        if inst.components.health then
            inst.components.health:SetInvincible(false)
        end
        inst.Physics:ClearMotorVelOverride()
        inst.sg.statemem.stopped = true
        inst.AnimState:SetAddColour(0, 0, 0, 0)
    end,
}

AddStategraphState("wilson", gwen_collision)
AddStategraphState("wilson_client", gwen_collision)


-----------------------------------------------------------------------------------------------
---眨眼比耶