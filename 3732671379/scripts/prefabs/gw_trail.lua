local SPRINT_TRAIL_FX_POOL = {}
local SPRINT_TRAIL_FX_COUNT = 0 --live count, excludes ones in pool
local SPRINT_TRAIL_FX_POOL_CLEANUP_TASK = nil

local function IncSprintTrailFx()
	if SPRINT_TRAIL_FX_POOL_CLEANUP_TASK then
		SPRINT_TRAIL_FX_POOL_CLEANUP_TASK:Cancel()
		SPRINT_TRAIL_FX_POOL_CLEANUP_TASK = nil
	end
	SPRINT_TRAIL_FX_COUNT = SPRINT_TRAIL_FX_COUNT + 1
end

local function DumpSprintTrailFxPool()
	for i = 1, #SPRINT_TRAIL_FX_POOL do
		SPRINT_TRAIL_FX_POOL[i]:Remove()
		SPRINT_TRAIL_FX_POOL[i] = nil
	end
end

local function DecSprintTrailFx()
	SPRINT_TRAIL_FX_COUNT = SPRINT_TRAIL_FX_COUNT - 1
	if SPRINT_TRAIL_FX_COUNT <= 0 then
		if SPRINT_TRAIL_FX_POOL_CLEANUP_TASK == nil then
			SPRINT_TRAIL_FX_POOL_CLEANUP_TASK = TheWorld:DoTaskInTime(30, DumpSprintTrailFxPool)
		else
			assert(false) --sanity check
		end
	end
end

local function CreateSprintTrailFx(inst)
	local fx = CreateEntity()

	fx:AddTag("FX")
	fx:AddTag("NOCLICK")
	--[[Non-networked entity]]
	fx.entity:SetCanSleep(false)
	fx.persists = false

	fx.entity:AddTransform()
	fx.entity:AddAnimState()

	fx.Transform:SetFourFaced()

	fx.AnimState:SetBank("wilson")
	fx.AnimState:SetBuild(inst.AnimState:GetBuild())
	fx.AnimState:SetAddColour(unpack(inst.sprint_trail_colour))
	fx.AnimState:UsePointFiltering(true)
    fx.AnimState:SetSortOrder(0)
	fx.AnimState:SetScale(1.035, 1.035)

	fx.AnimState:Hide("ARM_carry")

	fx:AddComponent("updatelooper")

	return fx
end

local function GetSprintTrailFx(inst)

	local fx = table.remove(SPRINT_TRAIL_FX_POOL)

	if fx and fx:IsValid() then
		fx:ReturnToScene()
	else
		fx = CreateSprintTrailFx(inst)
	end

	--Reset the entity
	fx.a = nil
	fx:Hide()

	fx.OnRemoveEntity = DecSprintTrailFx --This is just in case somehow something else removes us
	IncSprintTrailFx()

	return fx
end

--------------------------------------------------------------------------
local TRAIL_Y_OFFSET = -0.04

--V2C: Keeping it parented is the only way to guarantee the facing matches.
local function SprintTrailFx_PostUpdate(fx)
	local inst = fx.entity:GetParent()
	if inst then
		fx.Transform:SetPosition(inst.entity:WorldToLocalSpace(fx.x, fx.y+TRAIL_Y_OFFSET, fx.z))
		fx.Transform:SetRotation(fx.rot - inst.Transform:GetRotation())
		fx.AnimState:MakeFacingDirty()
	end
end

local TRAIL_LENGTH = 8
local TRAIL_ALPHA = 0.3
local TRAIL_FADE_DELTA = TRAIL_ALPHA / TRAIL_LENGTH
local function SprintTrailFx_OnUpdate(fx)
	if fx.a == nil then
		fx.a = TRAIL_ALPHA
		fx:Show()
	else
		fx.a = fx.a - TRAIL_FADE_DELTA
	end
	if fx.a > 0 then
		fx.AnimState:SetMultColour(1, 1, 1, fx.a * fx.alpha_mult)
	else
		--Return to pool
		fx.components.updatelooper:RemovePostUpdateFn(SprintTrailFx_PostUpdate)
		fx.components.updatelooper:RemoveOnUpdateFn(SprintTrailFx_OnUpdate)
		fx.OnRemoveEntity = nil
		fx:RemoveFromScene()
		table.insert(SPRINT_TRAIL_FX_POOL, fx)
		DecSprintTrailFx()
	end
end

-- runs on clients too
local function OnUpdateSprintTrail(inst, dt)
	local bank, anim = inst.AnimState:GetHistoryData()
	local arm_carry = inst.replica.inventory and inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

	if anim and inst.entity:IsVisible() then
		local fx = GetSprintTrailFx(inst)
		fx.entity:SetParent(inst.entity)
		fx.AnimState:PlayAnimation(anim)
		if arm_carry then
			fx.AnimState:Show("ARM_carry")
			fx.AnimState:Hide("ARM_normal")
			if arm_carry:HasTag("mad_mita_knife") then
				fx.AnimState:OverrideSymbol("swap_object", "swap_mad_mita_knife", "swap_knife_blood_1")
			else
				fx.AnimState:ClearOverrideSymbol("swap_object")
			end

			-- local swap_build, swap_sym = inst.AnimState:GetSymbolOverride("swap_object")
			-- local skin_build = arm_carry:GetSkinBuild()
			-- -- print(skin_build, swap_build, swap_sym)
			-- if swap_build and swap_sym then
			-- 	if skin_build then
			-- 		fx.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, swap_sym, arm_carry.GUID, swap_build)
			-- 	else
			-- 		fx.AnimState:OverrideSymbol("swap_object", swap_build, swap_sym)
			-- 	end
			-- else
			-- 	fx.AnimState:ClearOverrideSymbol("swap_object")
			-- end
		else
			fx.AnimState:Show("ARM_normal")
			fx.AnimState:Hide("ARM_carry")
		end
		fx.AnimState:SetTime(inst.AnimState:GetCurrentAnimationTime())
		fx.AnimState:Pause()
		fx.x, fx.y, fx.z = inst.Transform:GetWorldPosition()
		fx.alpha_mult = inst.trail_alpha_mult or 1
		fx.rot = inst.Transform:GetRotation()
		fx.components.updatelooper:AddPostUpdateFn(SprintTrailFx_PostUpdate)
		fx.components.updatelooper:AddOnUpdateFn(SprintTrailFx_OnUpdate)
	end
end

local function SprintTrail_OnEntitySleep(inst)
	if inst._sprinttrail_onudpate then
		inst._sprinttrail_onudpate = nil
		inst.components.updatelooper:RemoveOnUpdateFn(OnUpdateSprintTrail)
	end
end

local function SprintTrail_OnEntityWake(inst)
	if not inst._sprinttrail_onudpate then
		inst._sprinttrail_onudpate = true
		inst.components.updatelooper:AddOnUpdateFn(OnUpdateSprintTrail)
	end
end

local function OnHasSprintTrail(inst)
	if inst._predict_sprint_trail or inst.has_sprint_trail:value() then
		if not inst._updatingsprinttrail then
			if inst.components.updatelooper == nil then
				inst:AddComponent("updatelooper")
			end
			if TheWorld.ismastersim then
				inst:ListenForEvent("entitysleep", SprintTrail_OnEntitySleep)
				inst:ListenForEvent("entitywake", SprintTrail_OnEntityWake)
				if not inst:IsAsleep() then
					SprintTrail_OnEntityWake(inst)
				end
			else
				inst.components.updatelooper:AddOnUpdateFn(OnUpdateSprintTrail)
			end
			inst._updatingsprinttrail = true
		end
	elseif inst._updatingsprinttrail then
		if TheWorld.ismastersim then
			inst:RemoveEventCallback("entitysleep", SprintTrail_OnEntitySleep)
			inst:RemoveEventCallback("entitywake", SprintTrail_OnEntityWake)
			SprintTrail_OnEntitySleep(inst)
		else
			inst.components.updatelooper:RemoveOnUpdateFn(OnUpdateSprintTrail)
		end
		inst._updatingsprinttrail = false
	end
end

local function OnDisableSprintTask_Server(inst)
	inst._disablesprinttrailtask = nil
	inst.has_sprint_trail:set(false)
	if not TheNet:IsDedicated() then
		OnHasSprintTrail(inst)
	end
end

local function EnableSprintTrail_Server(inst, enable)
	if enable then
		if inst._disablesprinttrailtask then
			inst._disablesprinttrailtask:Cancel()
			inst._disablesprinttrailtask = nil
		elseif not inst.has_sprint_trail:value() then
			inst.has_sprint_trail:set(true)
			if not TheNet:IsDedicated() then
				OnHasSprintTrail(inst)
			end
		end
	elseif inst.has_sprint_trail:value() and inst._disablesprinttrailtask == nil then
		inst._disablesprinttrailtask = inst:DoStaticTaskInTime(0, OnDisableSprintTask_Server)
	end
	if inst.toggle_trail_task then
		inst.toggle_trail_task:Cancel()
		inst.toggle_trail_task = nil
	end
end

--------------------------------------------------------------------------
--For prediction

local function OnDisableSprintTask_Client(inst)
	inst._disablesprinttrailtask = nil
	inst._predict_sprint_trail = false
	OnHasSprintTrail(inst)
end

local function EnableSprintTrail_Client(inst, enable)
	if enable then
		if inst._disablesprinttrailtask then
			inst._disablesprinttrailtask:Cancel()
			inst._disablesprinttrailtask = nil
		elseif not inst._predict_sprint_trail then
			inst._predict_sprint_trail = true
			OnHasSprintTrail(inst)
		end
	elseif inst._predict_sprint_trail and inst._disablesprinttrailtask == nil then
		inst._disablesprinttrailtask = inst:DoStaticTaskInTime(0, OnDisableSprintTask_Client)
	end
end

local function OnEnableMovementPrediction_Client(inst, enable)
	if not enable and inst._predict_sprint_trail then
		if inst._disablesprinttrailtask then
			inst._disablesprinttrailtask:Cancel()
			inst._disablesprinttrailtask = nil
		end
		inst._predict_sprint_trail = nil
		OnHasSprintTrail(inst)
	end
end

--------------------------------------------------------------------------
-- HookAnimState

-- local hooked = false
-- local hooked_anims = {}

-- local anim_plays = {}
-- local anim_pushs = {}
-- local anim_dirty = {}

-- local function HookAnimState(inst)

-- 	if not hooked then

-- 		local AnimState = inst.AnimState
-- 		local metatable = getmetatable(AnimState)
-- 		local AnimState__index = metatable.__index
	
-- 		local old_PlayAnimation = AnimState__index.PlayAnimation
-- 		AnimState__index.PlayAnimation = function(self, anim, ...)
-- 			if hooked_anims[self] then
-- 				anim_plays[self] = anim
-- 				anim_dirty[self] = true
-- 			end
-- 			return old_PlayAnimation(self, anim, ...)
-- 		end
	
-- 		local old_PushAnimation = AnimState__index.PushAnimation
-- 		AnimState__index.PushAnimation = function(self, anim, ...)
-- 			if hooked_anims[self] then
-- 				anim_pushs[self] = anim
-- 				anim_dirty[self] = true
-- 			end
-- 			return old_PushAnimation(self, anim, ...)
-- 		end

-- 		hooked = true
-- 	end

-- 	local AnimState = inst.AnimState
-- 	hooked_anims[AnimState] = true
-- 	local now_anim = nil

-- 	-- 用于客机获取当前动画
-- 	inst._now_anim = net_string(inst.GUID, "mad_mita_trail.now_anim")

--     inst.GetCurrentAnimation = function(inst)
-- 		if not TheWorld.ismastersim then
-- 			return inst._now_anim:value()
-- 		end
--         if anim_dirty[AnimState] then
-- 			local playanim = anim_plays[AnimState]
-- 			local pushanim = anim_pushs[AnimState]
--             if playanim and AnimState:IsCurrentAnimation(playanim) then
--                 now_anim = playanim
--             elseif pushanim and AnimState:IsCurrentAnimation(pushanim) then
--                 now_anim = pushanim
--             end
--             anim_dirty[AnimState] = false
--         end
--         return now_anim
--     end

-- 	inst:ListenForEvent("onremove",function()
-- 		hooked_anims[AnimState] = nil
-- 	end)

-- end

local function SetUpSprintTrail(inst, colour)

	inst.has_sprint_trail = net_bool(inst.GUID, "mad_mita.has_sprint_trail", "has_sprint_trail_dirty")
	inst.sprint_trail_colour = colour or {1, 1, 1, 0}

	if TheWorld.ismastersim then
		inst.EnableSprintTrail = EnableSprintTrail_Server
	else
		inst:ListenForEvent("has_sprint_trail_dirty", OnHasSprintTrail)
		inst:ListenForEvent("enablemovementprediction", OnEnableMovementPrediction_Client)
		inst.EnableSprintTrail = EnableSprintTrail_Client
	end
end

local function SetTrailAlphaMult(inst, mult)
	inst.trail_alpha_mult = mult or 1
end

return {
    -- HookAnimState = HookAnimState,
    OnHasSprintTrail = OnHasSprintTrail,
    EnableSprintTrail_Server = EnableSprintTrail_Server,
    EnableSprintTrail_Client = EnableSprintTrail_Client,
    OnEnableMovementPrediction_Client = OnEnableMovementPrediction_Client,
	SetUpSprintTrail = SetUpSprintTrail,
	SetTrailAlphaMult = SetTrailAlphaMult,
}