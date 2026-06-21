
local MakePlayerCharacter = require "prefabs/player_common"
local player_common_ex = require "prefabs/player_common_extensions"


local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}
local prefabs = {}

-- 初始物品
local start_inv = {
	"wiltonmod_boneheart",
}

local function HasSkill(inst, name)
    return inst.components.skilltreeupdater and inst.components.skilltreeupdater:IsActivated(name)
end

local function onbecamehuman(inst)
	inst.components.locomotor:SetExternalSpeedMultiplier(inst, "wiltonmod_speed_mod", 1)
end

local function onbecameghost(inst)
   inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "wiltonmod_speed_mod")
end

local NON_PERSIST_COMMAND_SKILLS = {
	work = true,
	follow = true,
	stop = true,
	fight = true,
}

-- 骨杖可用的所有合法技能 ID 列表，用于统一做数据合法性校验。
local VALID_WILTON_SKILLS = {
	recover = true,
	work = true,
	follow = true,
	stop = true,
	fight = true,
	lock = true,
	cage = true,
	rotating_skull = true,
}

local function OnSave(inst, data)
	data.is_skel = inst:HasTag("is_skel")

	-- 记录当前选择的骨杖技能，保证重连与洞穴切换后仍然保持
	-- 通用指令（work/follow/stop/fight）只作为临时指令使用，不写入存档
	-- 为防止异常/篡改数据导致崩档，仅在技能 ID 合法且非通用指令时才写入存档。
	local saved = inst.wilton_saved_skill or inst.wilton_selected_skill
	if saved ~= nil
		and saved ~= ""
		and VALID_WILTON_SKILLS[saved]
		and not NON_PERSIST_COMMAND_SKILLS[saved] then
		data.wilton_selected_skill = saved
	end
	end     
	
	local function onload(inst, data)
    inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
    inst:ListenForEvent("ms_becameghost", onbecameghost)

    if inst:HasTag("playerghost") then
        onbecameghost(inst)
    else
        onbecamehuman(inst)
    end

  	   if data and data.is_skel then
	       inst.is_skel = true
	       --inst:BeCameSkel()	
	    end 	

	    if data ~= nil and data.wilton_selected_skill ~= nil then
	   	   -- 重新应用骨杖技能选择到本地字段与网络变量
	   	   -- 兼容旧存档：如果存的是通用指令（work/follow/stop/fight）或非法技能 ID，则回退为 recover
	   	   local saved = data.wilton_selected_skill
	   	   if type(saved) ~= "string" or saved == "" or NON_PERSIST_COMMAND_SKILLS[saved] or not VALID_WILTON_SKILLS[saved] then
	   	   	saved = "recover"
	   	   end
	   	   inst.wilton_saved_skill = saved
	   	   inst.wilton_selected_skill = saved
	   	   if inst._wilton_selected_skill ~= nil then
	   	   	inst._wilton_selected_skill:set(saved)
	   	   end
	   	end

	   -- 重连保护：
	   -- 服务器端在本世界首次加载威尔顿时，清理所有残留的“灵魂出窍锚点”骷髅，
	   -- 这些锚点通过 wilton_soulanchor 字段标记，只用于上一局的灵魂出窍视觉锚点，
	   -- 重新载入世界后已经失去实际用途，保留只会在场景中造成垃圾实体。
	   if TheWorld ~= nil and TheWorld.ismastersim and not TheWorld.wilton_soulanchor_cleanup_done then
	   	TheWorld.wilton_soulanchor_cleanup_done = true
	   	print("[Wilton][SoulOut][Guard] world-level soulanchor cleanup scheduled on load")
	   	-- 使用 0 延迟任务，确保世界中所有实体都已完成载入，再执行一次性全图扫描。
	   	inst:DoTaskInTime(0, function(player)
	   		if player == nil or not player:IsValid() then
	   			return
	   		end

	   		-- 全图查找所有可能的锚点骷髅：wiltonmod_skeleton / scarecrow2
	   		local ents = TheSim:FindEntities(0, 0, 0, 9999, nil, {"INLIMBO"})
	   		local removed = 0
	   		for _, ent in ipairs(ents) do
	   			if ent ~= nil and ent:IsValid()
	   				and (ent.prefab == "wiltonmod_skeleton" or ent.prefab == "scarecrow2")
	   				and ent.wilton_soulanchor
	   				-- 保留正式“复活稻草人”与墓睡临时稻草人，只清理灵魂出窍专用锚点。
	   				and not ent.wilton_bone_revive
	   				and not ent.is_wilton_sleep_scarecrow then
	   				print("[Wilton][SoulOut][Guard] cleanup stale wilton_soulanchor skeleton", ent, ent.prefab)
	   				ent:Remove()
	   				removed = removed + 1
	   			end
	   		end
	   		print("[Wilton][SoulOut][Guard] world-level soulanchor cleanup finished, removed=", removed)
	   	end)
	   end
	end

local function UpdateStartBoneheartBySkin(inst)
	if inst == nil or inst.components == nil or inst.components.inventory == nil then
		return
	end

	-- 根据当前选择的皮肤判断是否为“复活稻草人”皮肤。
	local uses_scarecrow_skin = inst.wilton_is_scarecrow_skin
	if uses_scarecrow_skin == nil and inst.components.skinner ~= nil then
		local skinner = inst.components.skinner
		local skin_name = skinner.skin_name
		if skin_name == nil and skinner.GetSkinName ~= nil then
			skin_name = skinner:GetSkinName()
		end
		uses_scarecrow_skin = (skin_name == "wiltonmod_scarecrow_none")
	end

	-- 只有稻草人皮肤才需要把开局骨心替换为稻草之心。
	if not uses_scarecrow_skin then
		return
	end

	local inv = inst.components.inventory
	local items = inv:FindItems(function(item)
		return item.prefab == "wiltonmod_boneheart"
	end)
	if items == nil or #items == 0 then
		return
	end

	for _, old in ipairs(items) do
		local owner = (old.components.inventoryitem ~= nil) and old.components.inventoryitem.owner or nil
		old:Remove()
		local new = SpawnPrefab("wiltonmod_boneheart_skin")
		if new ~= nil then
			if owner ~= nil and owner.components ~= nil and owner.components.inventory ~= nil then
				owner.components.inventory:GiveItem(new)
			else
				inv:GiveItem(new)
			end
		end
	end
end

local function CanOnWater(inst)
    if inst.components.drownable then
        inst.components.drownable.enabled = false
    end

    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.GIANTS)
end

local function CanNotOnWater(inst)
    if inst.components.drownable then
        inst.components.drownable.enabled = true
    end

    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.GIANTS)
end

local function isOnWater(inst)
	local x, y , z = inst.Transform:GetWorldPosition()
    if not TheWorld.Map:IsVisualGroundAtPoint(x,y,z) and not TheWorld.Map:GetPlatformAtPoint(x,z) then
        return true
    end

    return false
end

local function CheckOnWater(inst)
	if HasSkill(inst, "wiltonmod_skill1_3") then
		-- 灵魂出窍期间的幽灵威尔顿（带水上行走技能）允许在海面行走，
		-- 现在在洞穴世界的虚空边界也视同“海面”，专门放行灵魂出窍幽灵，
		-- 但普通幽灵、骑乘状态以及洞穴中的活人仍然禁止踏水与越界。
		if inst:HasTag("playerghost") then
			if inst.wilton_soul_out_active then
				-- 灵魂出窍幽灵：无论地表还是洞穴世界，都可以踏水/虚空越界。
				CanOnWater(inst)
			else
				-- 普通幽灵：不允许踏水，保持与原版一致。
				CanNotOnWater(inst)
			end
		elseif inst.components.rider:IsRiding() or TheWorld:HasTag("cave") then
			-- 骑乘状态或洞穴世界中的活人：仍然禁止踏水，避免与骑乘/洞穴地形产生冲突。
			CanNotOnWater(inst)
		else
			-- 地表世界的活人威尔顿：根据技能开启水上行走与越过海洋边界。
			CanOnWater(inst)
		end
	end

	if HasSkill(inst, "wiltonmod_skill1_7") then
		inst.components.health:SetAbsorptionAmount(0.4)
	else
		inst.components.health:SetAbsorptionAmount(0)
	end 
end

local function OnWaterRun(inst)
    if inst:HasTag("playerghost") then return end
    local is_running = inst.sg and inst.sg:HasStateTag("running")
    if isOnWater(inst) then
    	inst.components.moisture:DoDelta(1)
    	if is_running then
        SpawnPrefab("weregoose_splash").entity:SetParent(inst.entity) 
        end 
    end

    if HasSkill(inst, "wiltonmod_skill1_2") then
        inst.components.locomotor:SetExternalSpeedMultiplier(inst, "wiltonmod_skilltree", 1.25) 
    elseif HasSkill(inst, "wiltonmod_skill1_1") then
        inst.components.locomotor:SetExternalSpeedMultiplier(inst, "wiltonmod_skilltree", 1.1) 
    end    
end

local function CheckEquipHeavy(inst)
    if inst.components.inventory:EquipHasTag("heavy") and not inst.components.rider:IsRiding()
    and not HasSkill(inst, "wiltonmod_skill1_7") then
        inst.components.health:DoDelta(-5)
    end    
end

local function CalcSanityAura(inst, observer)
    if observer:HasTag("wiltonmod") then 
        return 0
    end
    
    return -25/60
end

local function OnEat(inst, food)
    if food ~= nil and food.prefab == "goatmilk"then
        inst.components.health:DoDelta(40)
        inst:PushEvent("emote", { anim = "emoteXL_happycheer", mounted = true, mountsound = "yell" })
    end
end

local function OnHitOther(inst, data)
    if data.target ~= nil and data.target.prefab ~= "wiltonmod_pet" and inst.components.leader:CountFollowers("wiltonmod_pet") > 0 then
        for k, v in pairs(inst.components.leader.followers) do
            if (k.components.combat.target == nil or (k.components.combat.target and k.components.combat.target ~= data.target))
            and not k:HasTag("INLIMBO") then
                k.components.combat:DropTarget()
                k.components.combat:SetTarget(data.target)
            end    
        end
    end
end

local function OnNewTarget(inst, data)
    if data.target ~= nil and data.target.prefab ~= "wiltonmod_pet" and inst.components.leader:CountFollowers("wiltonmod_pet") > 0 then
        for k, v in pairs(inst.components.leader.followers) do
            if k.components.combat and (k.components.combat.target == nil or (k.components.combat.target and k.components.combat.target ~= data.target))
            and not k:HasTag("INLIMBO") then
                k.components.combat:DropTarget()
                k.components.combat:SetTarget(data.target)
            end    
        end
    end
end

local function ClearTarget(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local exclude_tags = {'FX', 'NOCLICK', 'INLIMBO'}
    local ents = TheSim:FindEntities(x, y, z, 30, { "_combat" }, exclude_tags) 
    for k, v in ipairs(ents) do
        if v.components.combat and v.components.combat.target and v.components.combat.target == inst then
            v.components.combat:DropTarget()
            v.components.combat:SetTarget(nil)
        end    
    end
end

local function BeWilton(inst)
    inst:Show()
    inst:RemoveTag("notarget")
    inst:RemoveTag("is_skel")

    inst._is_skel:set(false)
    inst.components.inventory:Show()
    --inst.components.health:SetInvincible(false)  

    if inst.skel_task then
        inst.skel_task:Cancel()
        inst.skel_task = nil
    end

    if inst.components.talker ~= nil then
        inst.components.talker:StopIgnoringAll("skel")
    end
    if inst.components.firebug ~= nil then
        inst.components.firebug:Enable()
    end
    if inst.components.playercontroller ~= nil then
        inst.components.playercontroller:Enable(true)
    end

    inst:StartUpdatingComponent(inst.components.moisture)
    inst:StartUpdatingComponent(inst.components.temperature)

    inst.sg:GoToState("wakeup")
    --inst.components.health:SetPercent(0.25) 

    local fx = SpawnPrefab("chester_transform_fx")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())

    inst.components.health:SetInvincible(true)
    inst.skel_Inv_task = inst:DoTaskInTime(5, function(inst)
        inst.components.health:SetInvincible(false)
        if inst.skel_Inv_task then
            inst.skel_Inv_task:Cancel()
            inst.skel_Inv_task = nil
        end    
    end)    

    local skeleton = inst.skel or FindEntity(inst, 1, nil, {"wiltonmod_skeleton"})
    if skeleton and skeleton:IsValid() then
        skeleton:Remove()
    end  

    -- 墓穴睡觉逻辑中，当威尔顿使用稻草人皮肤时会生成 scarecrow2 作为“骨架形态锚点”，
    -- 但原本的清理流程只处理 wiltonmod_skeleton，导致起身后稻草人残留在地面。
    -- 这里在玩家起身恢复为威尔顿时，额外尝试移除贴身的临时 scarecrow2，
    -- 同时保留带有 wilton_bone_revive 标记的“正式复活稻草人”，避免误删可复活锚点。
    local scarecrow = FindEntity(inst, 1.2, function(ent)
        return ent.prefab == "scarecrow2" and not ent.wilton_bone_revive
    end)
    if scarecrow ~= nil and scarecrow:IsValid() then
        scarecrow:Remove()
    end
end

local function BeCameSkel(inst, isload)
    ClearTarget(inst)

    inst:Hide()
    inst:AddTag("notarget")
    inst:AddTag("is_skel")

    inst:DoTaskInTime(0, function(inst)
    inst.sg:GoToState("idle")

    if inst.components.playercontroller ~= nil then
        inst.components.playercontroller:Enable(false)
    end    
    end)

    inst._is_skel:set(true)

    inst.components.inventory:Hide()

    inst.Physics:Stop()
    inst.components.locomotor:Stop()

    inst.components.moisture:DoDelta(-100)
    inst.components.temperature:SetTemp(30)

    inst:StopUpdatingComponent(inst.components.moisture)
    inst:StopUpdatingComponent(inst.components.temperature)
    --inst.components.health:SetInvincible(true)

    inst.skel_task = inst:DoPeriodicTask(1, function(inst)
        inst.components.health:DoDelta(1, true, "skel")
        if inst.components.health.currenthealth >= (TUNING.WILTON_REVIVE_TIME or 30) then
	    	BeWilton(inst)
            --inst.components.timer:SetTimeLeft("wiltonmod_skeleton_time", 0)
        end 	
    end)

    if inst.components.talker ~= nil then
        inst.components.talker:IgnoreAll("skel")
    end
    if inst.components.firebug ~= nil then
        inst.components.firebug:Disable()
    end
    if inst.components.playercontroller ~= nil then
        inst.components.playercontroller:Enable(false)
    end

    local uses_scarecrow_skin = inst.wilton_is_scarecrow_skin
    if uses_scarecrow_skin == nil and inst.components ~= nil and inst.components.skinner ~= nil then
		local skinner = inst.components.skinner
		local skin_name = skinner.skin_name
		if skin_name == nil and skinner.GetSkinName ~= nil then
			skin_name = skinner:GetSkinName()
		end
		uses_scarecrow_skin = (skin_name == "wiltonmod_scarecrow_none")
	end

    if isload == nil then
		local skel
		if uses_scarecrow_skin then
			skel = SpawnPrefab("scarecrow2")
			if skel ~= nil then
				skel:AddTag("wiltonmod_scarecrow")
				-- 使用“复活稻草人”皮肤生成的稻草人：只作为复活锚点，不允许被燃烧或拆除。
				if skel.components.burnable ~= nil then
					skel:RemoveComponent("burnable")
				end
				if skel.components.propagator ~= nil then
					skel:RemoveComponent("propagator")
				end
				if skel.components.workable ~= nil then
					skel:RemoveComponent("workable")
				end
				if skel.components.hauntable ~= nil then
					skel:RemoveComponent("hauntable")
				end
				if skel.components.lootdropper ~= nil then
					skel.components.lootdropper:SetChanceLootTable('skeleton_cg')
				end
			end
		else
			skel = SpawnPrefab("wiltonmod_skeleton")
		end
		inst.skel = skel
		skel.Transform:SetPosition(inst.Transform:GetWorldPosition())

		local fx = SpawnPrefab("chester_transform_fx")
		fx.Transform:SetPosition(inst.Transform:GetWorldPosition())

		--inst.components.inventory:DropEverything(true)

		--inst.components.timer:StartTimer("wiltonmod_skeleton_time", 30) 
	end   
end

-- 灵魂出窍内部工具函数：在服务端执行，复用现有骷髅/稻草人生成逻辑但不改变 is_skel 状态。
local function Wilton_SpawnSoulSkeleton(inst)
	if inst == nil or inst.components == nil then
		return
	end

	local x, y, z = inst.Transform:GetWorldPosition()

	-- 复用皮肤判断逻辑：如果当前是稻草人皮肤，则生成 scarecrow2，否则生成 wiltonmod_skeleton。
	local uses_scarecrow_skin = inst.wilton_is_scarecrow_skin
	if uses_scarecrow_skin == nil and inst.components.skinner ~= nil then
		local skinner = inst.components.skinner
		local skin_name = skinner.skin_name
		if skin_name == nil and skinner.GetSkinName ~= nil then
			skin_name = skinner:GetSkinName()
		end
		uses_scarecrow_skin = (skin_name == "wiltonmod_scarecrow_none")
	end

	local skel
	if uses_scarecrow_skin then
		-- 这里生成的 scarecrow2 只作为灵魂出窍锚点：
		-- * 不可被锤/点燃/作祟复活
		-- * 不带 wilton_bone_revive 标记，避免与正式“复活稻草人”冲突
		skel = SpawnPrefab("scarecrow2")
		if skel ~= nil then
			-- 打上专用标记，方便复活时精确清理
			skel.wilton_soulanchor = true
			-- 移除与交互相关的组件，保证不可被拆除或点燃
			if skel.components.workable ~= nil then
				skel:RemoveComponent("workable")
			end
			if skel.components.burnable ~= nil then
				skel:RemoveComponent("burnable")
			end
			if skel.components.propagator ~= nil then
				skel:RemoveComponent("propagator")
			end
			if skel.components.hauntable ~= nil then
				skel:RemoveComponent("hauntable")
			end
		end
	else
		-- 使用自定义的 wiltonmod_skeleton 作为骨架，占位但不可交互
		skel = SpawnPrefab("wiltonmod_skeleton")
		if skel ~= nil then
			-- 设置一个标记，表示此骨架来自“灵魂出窍”而不是普通死亡
			skel.wilton_soulanchor = true
			-- 移除可挖/可敲等工作组件，避免被误拆
			if skel.components.workable ~= nil then
				skel:RemoveComponent("workable")
			end
			if skel.components.hauntable ~= nil then
				skel:RemoveComponent("hauntable")
			end
		end
	end

	if skel ~= nil then
		skel.Transform:SetPosition(x, y, z)
	end

	return skel
end

local common_postinit = function(inst)
    inst:AddTag("insomniac") 
    inst:AddTag("monster")
    inst:AddTag("wiltonmod")
	inst.MiniMapEntity:SetIcon("wiltonmod.tex")

    inst._is_skel = net_bool(inst.GUID, "is_skel", "is_skel_dirty")
    inst._is_skel:set(false)

    -- 灵魂出窍状态同步：客户端通过网络变量得知当前是否处于灵魂出窍流程中
    inst._wilton_soul_out_active = net_bool(inst.GUID, "wiltonmod.soulout_active", "wilton_soulout_dirty")
    inst._wilton_soul_out_active:set(false)

    -- 当前选中的骨杖技能（通过 net_string 在客户端和服务端之间同步）
    inst._wilton_selected_skill = net_string(inst.GUID, "wiltonmod.selected_skill", "wilton_selected_skill_dirty")

    inst:DoTaskInTime(0,function()
    if inst.replica.builder then
        --[[[
        local old_HasCharacterIngredient = inst.replica.builder.HasCharacterIngredient  
        inst.replica.builder.HasCharacterIngredient = function(self,ingredient,...)
            if ingredient.type and ingredient.type == CHARACTER_INGREDIENT.HEALTH and ingredient.amount == 40 then  
                return false                                            
            end
            return old_HasCharacterIngredient(self,ingredient,...)
        end
        ]]
        local old_HasIngredients = inst.replica.builder.HasIngredients 
        inst.replica.builder.HasIngredients  = function(self, recipe, ...)
            if recipe and recipe.name and recipe.name == "reviver" then  
                return false                                            
            end
            return old_HasIngredients(self, recipe, ...)
        end        
    end 
    end) 	
end



local master_postinit = function(inst)
	inst.soundsname = "wiltonmod"

	-- 默认选中骨杖的 recover 技能，后续通过法杖技能轮盘进行修改
	inst.wilton_selected_skill = "recover"
	if inst._wilton_selected_skill ~= nil then
		inst._wilton_selected_skill:set("recover")
	end
	inst.wilton_saved_skill = "recover"

	-- 灵魂出窍运行时状态：
	-- * wilton_soul_out_active          : 当前是否处于灵魂出窍流程中
	-- * wilton_soul_out_pos             : 记录触发时的世界坐标 Vector3
	-- * wilton_soul_out_anchor          : 记录生成的专用骨架/稻草人实例
	-- * wilton_soul_out_task            : 30 秒超时任务句柄
	-- * wilton_soul_out_prev            : 记录触发时的三维百分比，用于还魂后还原
	-- * wilton_soul_out_old_ghostenabled: 记录触发前的 ghostenabled 配置
	-- * wilton_soul_out_resurrecting    : 标记是否正在执行灵魂出窍专用复活流程
	inst.wilton_soul_out_active = false
	inst.wilton_soul_out_pos = nil
	inst.wilton_soul_out_anchor = nil
	inst.wilton_soul_out_task = nil
	inst.wilton_soul_out_blockrevive = false
	inst.wilton_soul_out_prev = nil
	inst.wilton_soul_out_old_ghostenabled = nil
	inst.wilton_soul_out_resurrecting = false

	-- 为骨杖技能记忆提供简单的读写接口，服务端是权威来源
	function inst:SetWiltonSelectedSkill(skill_id)
		-- 任何非法/缺失的技能 ID 一律回退到默认技能 recover，防止 RPC 或其他 MOD 传入脏数据
		if type(skill_id) ~= "string" or skill_id == "" or not VALID_WILTON_SKILLS[skill_id] then
			skill_id = "recover"
		end
		self.wilton_selected_skill = skill_id
		if self._wilton_selected_skill ~= nil then
			self._wilton_selected_skill:set(self.wilton_selected_skill)
		end
		-- 只在选择非通用指令时更新“持久化记忆”的技能
		if skill_id ~= nil and skill_id ~= "" and VALID_WILTON_SKILLS[skill_id] and not NON_PERSIST_COMMAND_SKILLS[skill_id] then
			self.wilton_saved_skill = self.wilton_selected_skill
		end
	end

	function inst:GetWiltonSelectedSkill()
		-- 优先读取本地字段，但只接受合法的技能 ID
		local id = self.wilton_selected_skill
		if type(id) ~= "string" or id == "" or not VALID_WILTON_SKILLS[id] then
			id = nil
		end
		-- 本地字段异常时，尝试从 net_string 中读取同步过来的技能 ID
		if id == nil and self._wilton_selected_skill ~= nil then
			local v = self._wilton_selected_skill:value()
			if type(v) == "string" and v ~= "" and VALID_WILTON_SKILLS[v] then
				id = v
			end
		end
		-- 兜底：任意路径都无法得到合法技能时，统一回退到默认技能 recover
		if id == nil then
			id = "recover"
			self.wilton_selected_skill = id
			if self._wilton_selected_skill ~= nil then
				self._wilton_selected_skill:set(id)
			end
		end
		return id
	end

	-- 内部方法：开始灵魂出窍。仅在服务端调用。
	local function StartSoulOut(inst)
		if inst.wilton_soul_out_active or inst:HasTag("playerghost") or inst:HasTag("is_skel") then
			return
		end

		-- 缓存触发前坐标
		local x, y, z = inst.Transform:GetWorldPosition()
		inst.wilton_soul_out_pos = Vector3(x, y, z)

		-- 生成灵魂出窍专用骨架/稻草人锚点
		local anchor = Wilton_SpawnSoulSkeleton(inst)
		inst.wilton_soul_out_anchor = anchor

		-- 参照官方 player_common_extensions.OnMakePlayerGhost 中的死亡特效逻辑：
		-- 正常死亡变幽灵时会在脚下生成 die_fx，这里手动补一次，保持“灵魂出窍”视觉效果与死亡时一致。
		local diefx = SpawnPrefab("die_fx")
		if diefx ~= nil then
			diefx.Transform:SetPosition(x, y, z)
		end

		-- 记录触发前三维比例和 ghostenabled，供还魂后完全还原
		if inst.components ~= nil then
			local prev = {}
			if inst.components.health ~= nil then
				prev.health = inst.components.health:GetPercent()
			end
			if inst.components.hunger ~= nil then
				prev.hunger = inst.components.hunger:GetPercent()
			end
			if inst.components.sanity ~= nil then
				prev.sanity = inst.components.sanity:GetPercent()
			end
			inst.wilton_soul_out_prev = prev
		else
			inst.wilton_soul_out_prev = nil
		end
		inst.wilton_soul_out_old_ghostenabled = inst.ghostenabled

		-- 标记处于灵魂出窍中，并禁止外部复活道具（告密的心等）介入
		inst.wilton_soul_out_active = true
		if inst._wilton_soul_out_active ~= nil then
			inst._wilton_soul_out_active:set(true)
		end
		inst.wilton_soul_out_blockrevive = true

		-- 直接调用官方幽灵化逻辑，跳过“死亡”状态与物品掉落，仅用于灵魂出窍。
		-- 使用 loading=true 避免生成墓碑和公告。
		if player_common_ex ~= nil and player_common_ex.OnMakePlayerGhost ~= nil then
			player_common_ex.OnMakePlayerGhost(inst, { skeleton = false, loading = true })
		else
			-- 理论上不会进入这里，仅作为安全兜底：退回到普通死亡流程
			inst:PushEvent("death", { cause = "wilton_soul_out" })
		end

		-- 兼容旧存档 / 旧状态机：
		-- 在 SGwilson 的 doshortaction 等人形短动作状态中途切换为幽灵时，旧的动画队列中可能已经压入了
		-- "pickup_pst" 等仅存在于人形 bank 的动画；此时直接切换到 ghost bank 会在服务端日志中产生
		-- “Could not find anim [pickup_pst] in bank [ghost]” 一类警告。
		-- 为避免这一情况，在成功幽灵化后立刻将幽灵状态机切换到 "idle"，刷新当前动画为幽灵的 idle，
		-- 主动清理掉原先排队的 pickup/pickup_pst 等人形动画队列，对新旧存档均生效。
		if inst:HasTag("playerghost") and inst.sg ~= nil then
			if inst.sg.currentstate == nil or inst.sg.currentstate.name ~= "idle" then
				inst.sg:GoToState("idle")
			end
		end

		-- 灵魂出窍持续时间：无限。
		-- 这里仍保留对旧任务句柄的清理，避免重复触发时残留旧的超时任务导致“自动回魂”。
		if inst.wilton_soul_out_task ~= nil then
			inst.wilton_soul_out_task:Cancel()
			inst.wilton_soul_out_task = nil
		end
	end

	-- 灵魂出窍专用：直接从幽灵形态恢复为正常玩家，不走官方的远景镜头与复活动画。
	-- 这里参考 player_common_extensions.lua 中 DoActualRez + CommonActualRez 的最小必要逻辑，
	-- 只做状态与组件恢复，不再播放额外起身动画，直接进入 SGwilson 的 idle，保证回魂无后摇。
	local function WiltonSoulOutDirectRez(inst)
		if not inst:HasTag("playerghost") then
			return
		end

		-- 恢复渲染与皮肤显示为正常形态，去除幽灵泛光。
		if inst.DynamicShadow ~= nil then
			inst.DynamicShadow:Enable(true)
		end
		inst:Show()

		if inst.AnimState ~= nil then
			inst.AnimState:Hide("HAT")
			inst.AnimState:Hide("HAIR_HAT")
			inst.AnimState:Show("HAIR_NOHAT")
			inst.AnimState:Show("HAIR")
			inst.AnimState:Show("HEAD")
			inst.AnimState:Hide("HEAD_HAT")
			inst.AnimState:Hide("HEAD_HAT_NOHELM")
			inst.AnimState:Hide("HEAD_HAT_HELM")
			inst.AnimState:SetBank("wilson")
			if inst.ApplySkinOverrides ~= nil then
				inst.ApplySkinOverrides(inst)
			end
			if inst.components ~= nil and inst.components.bloomer ~= nil then
				inst.components.bloomer:PopBloom("playerghostbloom")
			end
			inst.AnimState:SetLightOverride(0)
		end

		if inst.Light ~= nil then
			inst.Light:SetIntensity(.8)
			inst.Light:SetRadius(.5)
			inst.Light:SetFalloff(.65)
			inst.Light:SetColour(255 / 255, 255 / 255, 236 / 255)
			inst.Light:Enable(false)
		end

		-- 切回正常玩家状态机与物理形态。
		inst:SetStateGraph("SGwilson")
		MakeCharacterPhysics(inst, 75, .5)

		-- 关闭幽灵 HUD/小地图模式。
		if inst.player_classified ~= nil then
			inst.player_classified:SetGhostMode(false)
			if inst.player_classified.MapExplorer ~= nil then
				inst.player_classified.MapExplorer:EnableUpdate(true)
			end
		end

		-- 恢复基础组件到“活人”状态，逻辑对齐 CommonActualRez。
		if inst.components ~= nil then
			if inst.components.inventory ~= nil then
				if inst.components.revivablecorpse ~= nil then
					inst.components.inventory:Show()
				else
					inst.components.inventory:Open()
				end
			end
			if inst.components.age ~= nil and inst.components.revivablecorpse == nil then
				inst.components.age:ResumeAging()
			end
			if inst.components.health ~= nil then
				inst.components.health.canheal = true
				inst.components.health:SetInvincible(false)
			end
			if inst.components.hunger ~= nil and not GetGameModeProperty("no_hunger") then
				inst.components.hunger:Resume()
			end
			if inst.components.temperature ~= nil and not GetGameModeProperty("no_temperature") then
				inst.components.temperature:SetTemp()
			end
			if inst.components.frostybreather ~= nil then
				inst.components.frostybreather:Enable()
			end
			if inst.components.burnable == nil then
				MakeMediumBurnableCharacter(inst, "torso")
			end
			if inst.components.burnable ~= nil then
				inst.components.burnable:SetBurnTime(TUNING.PLAYER_BURN_TIME)
				inst.components.burnable.nocharring = true
			end
			if inst.components.freezable == nil then
				MakeLargeFreezableCharacter(inst, "torso")
			end
			if inst.components.freezable ~= nil then
				inst.components.freezable:SetResistance(4)
				inst.components.freezable:SetDefaultWearOffTime(TUNING.PLAYER_FREEZE_WEAR_OFF_TIME)
			end
			if inst.components.grogginess == nil then
				inst:AddComponent("grogginess")
				inst.components.grogginess:SetResistance(3)
				if player_common_ex ~= nil and player_common_ex.ShouldKnockout ~= nil then
					inst.components.grogginess:SetKnockOutTest(player_common_ex.ShouldKnockout)
				end
			end
			if inst.components.slipperyfeet == nil then
				inst:AddComponent("slipperyfeet")
			end
			if inst.components.moisture ~= nil then
				inst.components.moisture:ForceDry(false, inst)
			end
			if inst.components.sheltered ~= nil then
				inst.components.sheltered:Start()
			end
			if inst.components.debuffable ~= nil then
				inst.components.debuffable:Enable(true)
			end
			if inst.components.sanity ~= nil then
				inst.components.sanity.ignore = GetGameModeProperty("no_sanity")
			end
		end

		-- 回魂后重新应用当前头部装备的外观，避免灵魂出窍流程中重置头部符号导致头盔贴图丢失。
		-- 这里通过 Inventory:Unequip + Inventory:Equip 走一遍完整的官方装备流程，
		-- 以兼容全覆盖头盔（例如南瓜帽、蜂后头冠等）对 face/swap_face/headbase_hat 的特殊处理。
		if inst.components ~= nil and inst.components.inventory ~= nil then
			local inv = inst.components.inventory
			local hat = inv:GetEquippedItem(EQUIPSLOTS.HEAD)
			if hat ~= nil and hat.components ~= nil and hat.components.equippable ~= nil then
				-- 临时卸下再立即重新穿戴，no_animation=true 避免播放额外的装备动画，仅刷新头部符号与皮肤覆盖。
				inv:Unequip(EQUIPSLOTS.HEAD)
				inv:Equip(hat, false, true)
			end
			-- 针对南瓜帽（pumpkinhat）的额外修复：
			-- 该帽子通过 components/pumpkincarvable + prefab "pumpkincarving_swap_fx" 将雕刻的南瓜脸作为独立特效挂在玩家身上。
			-- 灵魂出窍/回魂过程中，这个特效有可能丢失，因此这里仿照 OnEquipped_Server 手动刷新一次。
			if hat ~= nil
				and hat.prefab == "pumpkinhat"
				and hat.components ~= nil
				and hat.components.pumpkincarvable ~= nil
				and TheWorld ~= nil and TheWorld.ismastersim then
				local pumpkincarvable = hat.components.pumpkincarvable
				local cutdata = pumpkincarvable.GetCutData ~= nil and pumpkincarvable:GetCutData() or nil
				if cutdata ~= nil and cutdata ~= "" then
					if pumpkincarvable.swapinst ~= nil and pumpkincarvable.swapinst:IsValid() then
						pumpkincarvable.swapinst:Remove()
					end
					pumpkincarvable.swapinst = SpawnPrefab("pumpkincarving_swap_fx")
					if pumpkincarvable.swapinst ~= nil then
						pumpkincarvable.swapinst.entity:SetParent(inst.entity)
						pumpkincarvable.swapinst:SetData(cutdata)
					end
				end
			end
		end

		-- 恢复玩家移动与交互动作集。
		if player_common_ex ~= nil then
			if player_common_ex.ConfigurePlayerLocomotor ~= nil then
				player_common_ex.ConfigurePlayerLocomotor(inst)
			end
			if player_common_ex.ConfigurePlayerActions ~= nil then
				player_common_ex.ConfigurePlayerActions(inst)
			end
		end

		inst.last_death_position = nil
		inst.last_death_shardid = nil

		-- 彻底移除幽灵标签与网络标记，视为一次完整的“从幽灵恢复为活人”。
		inst:RemoveTag("playerghost")
		if inst.Network ~= nil then
			inst.Network:RemoveUserFlag(USERFLAGS.IS_GHOST)
		end

		-- 不再播放起身动画，直接进入 idle，避免回魂后摇，保证立刻可操作。
		if inst.sg ~= nil then
			inst.sg:GoToState("idle")
		end

		-- 通知外部监听者本次“复活”已完成（包括灵魂出窍还原三维的逻辑）。
		inst:PushEvent("ms_respawnedfromghost")
	end

	-- 内部方法：从灵魂出窍状态返回肉体。仅在服务端调用。
	local function FinishSoulOut(inst)
		if not inst.wilton_soul_out_active then
			return
		end

		-- 暂时关闭溺水判定，避免回魂切换形态与平台检测之间被误判为落水。
		local prev_drownable_enabled = nil
		if inst.components ~= nil and inst.components.drownable ~= nil then
			prev_drownable_enabled = inst.components.drownable.enabled
			inst.components.drownable.enabled = false
		end

		-- 关闭超时任务
		if inst.wilton_soul_out_task ~= nil then
			inst.wilton_soul_out_task:Cancel()
			inst.wilton_soul_out_task = nil
		end

		-- 优先使用记录的原位置作为还魂落点
		local pos = inst.wilton_soul_out_pos
		if pos ~= nil and inst:HasTag("playerghost") then
			if inst.Physics ~= nil then
				inst.Physics:Teleport(pos.x, pos.y, pos.z)
			else
				inst.Transform:SetPosition(pos.x, pos.y, pos.z)
			end
		end

		-- 清理灵魂出窍专用骨架/稻草人，避免残留
		if inst.wilton_soul_out_anchor ~= nil and inst.wilton_soul_out_anchor:IsValid() then
			inst.wilton_soul_out_anchor:Remove()
		end
		inst.wilton_soul_out_anchor = nil

		-- 标记当前正由灵魂出窍流程驱动复活，用于在 ms_respawnedfromghost 中还原三维。
		inst.wilton_soul_out_resurrecting = true

		-- 改为走自定义的“瞬间复活+起身”流程，不再触发官方的复活动画与视角调整。
		if inst:HasTag("playerghost") then
			WiltonSoulOutDirectRez(inst)
		end

		-- 如果回魂落点在船上（海上平台），需要在复活后立刻刷新一次平台组件，
		-- 防止在海面上站在船上时被溺水系统误判为“在海水中”而触发落水流程。
		if inst.components ~= nil and inst.components.walkableplatformplayer ~= nil then
			inst.components.walkableplatformplayer:TestForPlatform()
		end

		-- 在平台检测完成后，恢复溺水组件的 enabled 状态，保证后续行为与原版一致。
		if inst.components ~= nil and inst.components.drownable ~= nil then
			if prev_drownable_enabled == nil then
				-- 如果此前未显式设置过，则默认恢复为启用溺水判定。
				inst.components.drownable.enabled = true
			else
				inst.components.drownable.enabled = prev_drownable_enabled
			end
		end

		-- 标记流程结束，剩余清理在 ms_respawnedfromghost 中完成。
		inst.wilton_soul_out_active = false
		if inst._wilton_soul_out_active ~= nil then
			inst._wilton_soul_out_active:set(false)
		end
		inst.wilton_soul_out_blockrevive = false
	end

	-- 监听技能事件：右键自身触发灵魂出窍 / 归体，仅在服务端执行。
	local function OnWiltonSoulOutEvent(inst, data)
		if inst == nil or not inst:IsValid() then
			return
		end
		StartSoulOut(inst)
	end

	local function OnWiltonSoulReturnEvent(inst, data)
		if inst == nil or not inst:IsValid() then
			return
		end
		FinishSoulOut(inst)
	end

	inst:ListenForEvent("wilton_soul_out", OnWiltonSoulOutEvent)
	inst:ListenForEvent("wilton_soul_return", OnWiltonSoulReturnEvent)

	--inst.components.foodaffinity:AddPrefabAffinity("baconeggs", TUNING.AFFINITY_15_CALORIES_HUGE)--ThePlayer.components.health:DoDelta(-200)

    inst.components.health.minhealth = 1
	inst.components.health:SetMaxHealth(TUNING.WILTONMOD_HEALTH)  --ThePlayer.components.health.minhealth = 0.1
    local _getHealth = inst.components.health.DoDelta
    inst.components.health.DoDelta = function(self, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb, ...)
        if (amount < 0 and inst:HasTag("is_skel")) or (amount > 0 and inst:HasTag("is_skel") and (cause == nil or cause ~= "skel")) then
            amount = 0
        end 	

        if TUNING.WILTON_DISABLE_HEAL
            and amount > 0
            and not inst:HasTag("is_skel")
            and (cause == nil or cause ~= "wiltonmod_bonepaste") then
            amount = 0
        end

        if (self.currenthealth + amount) <= 0 and self.invincible == false then  --amount < 0 and
            print("去世")
	    	amount = 0
	    	self.currenthealth = 1
	    	BeCameSkel(inst)
        end

        return _getHealth(self, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb, ...) 
    end

    local OldSetVal = inst.components.health.SetVal
    inst.components.health.SetVal = function(self, val, cause, afflicter, ...)
        if val < 1 then
            val = 1
            --return
        end 
        return OldSetVal(self, val, cause, afflicter, ...) 
    end

    -- 灵魂出窍专用：在官方复活逻辑完成后，还原触发前的三维，并清理状态。
	local function OnWiltonSoulOutRespawned(inst, data)
		if not inst.wilton_soul_out_resurrecting then
			return
		end

		inst.wilton_soul_out_resurrecting = false

		local prev = inst.wilton_soul_out_prev
		if prev ~= nil and inst.components ~= nil then
			if inst.components.health ~= nil and prev.health ~= nil then
				inst.components.health:SetPercent(prev.health, true, "wilton_soul_out")
			end
			if inst.components.hunger ~= nil and prev.hunger ~= nil then
				inst.components.hunger:SetPercent(prev.hunger, true)
			end
			if inst.components.sanity ~= nil and prev.sanity ~= nil then
				inst.components.sanity:SetPercent(prev.sanity, true)
			end
		end

		inst.wilton_soul_out_prev = nil
		inst.wilton_soul_out_pos = nil

		if inst.wilton_soul_out_old_ghostenabled ~= nil then
			inst.ghostenabled = inst.wilton_soul_out_old_ghostenabled
			inst.wilton_soul_out_old_ghostenabled = nil
		end
	end

	inst:ListenForEvent("ms_respawnedfromghost", OnWiltonSoulOutRespawned)

	inst.event_listeners.death = nil
	inst.event_listeners.respawnfromghost = nil

	inst.components.sanity:SetMax(TUNING.WILTONMOD_SANITY)
	inst.components.sanity.neg_aura_mult = 0
	inst.components.sanity.night_drain_mult = 0

	local WILTON_DAY_SANITY_MOD_KEY = "wiltonmod_day_sanity_drain"
	local function UpdateDaySanityDrain(inst, isday)
        if inst == nil or inst.components == nil or inst.components.sanity == nil then
			return
		end

		local sanity = inst.components.sanity

		-- 戴南瓜灯帽时，关闭威尔顿自带的白天掉 SAN 被动，模拟基础角色戴南瓜帽免疫黑暗的体验。
		local has_pumpkinhat = false
		if inst.components.inventory ~= nil then
			local hat = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
			if hat ~= nil and hat.prefab == "pumpkinhat" then
				has_pumpkinhat = true
			end
		end

		local should_drain = isday and not TheWorld:HasTag("cave") and not inst:HasTag("playerghost") and not has_pumpkinhat
		if should_drain then
			if not sanity.externalmodifiers:HasModifier(inst, WILTON_DAY_SANITY_MOD_KEY) then
				sanity.externalmodifiers:SetModifier(inst, -5/60, WILTON_DAY_SANITY_MOD_KEY)
				print("[wiltonmod] Day sanity drain ON (-5/min)")
			end
		else
			if sanity.externalmodifiers:HasModifier(inst, WILTON_DAY_SANITY_MOD_KEY) then
				sanity.externalmodifiers:RemoveModifier(inst, WILTON_DAY_SANITY_MOD_KEY)
				print("[wiltonmod] Day sanity drain OFF")
			end
		end
	end

	-- 头部装备变化时刷新一次威尔顿白天理智消耗状态，保证在白天中途戴上/取下南瓜帽能立即生效。
	local function OnWiltonEquipChangeForDaySanity(inst, data)
		if data ~= nil and data.eslot == EQUIPSLOTS.HEAD then
			UpdateDaySanityDrain(inst, TheWorld.state.isday)
		end
	end

	inst:WatchWorldState("isday", UpdateDaySanityDrain)
	inst:ListenForEvent("equip", OnWiltonEquipChangeForDaySanity)
	inst:ListenForEvent("unequip", OnWiltonEquipChangeForDaySanity)
	UpdateDaySanityDrain(inst, TheWorld.state.isday)

	inst.components.hunger:SetMax(50)
	inst.components.hunger:Pause()
	inst.components.hunger:SetRate(0)
	inst.components.hunger:SetKillRate(0)

    inst.components.hunger.DoDelta = function(self, delta, overtime, ignore_invincible, ...)
    end

    inst.components.hunger.SetCurrent = function(self, current, overtime, ...)
    end

    local oldSay = inst.components.talker.Say

    -- 官方推荐模式：台词文本统一由 modmain.lua 选择并写入 TUNING.WILTONMOD_SAYINGS，
    -- prefab 这边只从 TUNING.WILTONMOD_SAYINGS 中随机取一句，不再直接访问 GetModConfigData 或自行判断语言。
    inst.components.talker.Say = function(self, script, time, noanim, force, nobroadcast, colour, text_filter_context, original_author_netid, ...)
        local sayings = TUNING.WILTONMOD_SAYINGS
        if type(sayings) == "table" and #sayings > 0 then
            script = sayings[math.random(#sayings)]
        end
        return oldSay(self, script, time, noanim, force, nobroadcast, colour, text_filter_context, original_author_netid, ...)
    end

    -- 使用配置表中的攻击倍率，默认回落到 1，避免未配置时导致报错或异常放大
    if type(TUNING.WILTON_ATTACK_MULT) ~= "number" then
        TUNING.WILTON_ATTACK_MULT = 1
    end
    inst.components.combat.damagemultiplier = TUNING.WILTON_ATTACK_MULT

    if inst.components.eater ~= nil then
    --inst.components.eater.caneat = {}
    --inst.components.eater.preferseating = {}
    inst.components.eater:SetOnEatFn(OnEat)

    local OldEat = inst.components.eater.Eat
    inst.components.eater.Eat = function(self, food, feeder, ...)
        if food and food.prefab == "goatmilk" then
            return OldEat(self, food, feeder, ...)

		elseif food and food.prefab == "bonesoup" then
		if food.components.edible then
		food.components.edible.sanityvalue = 10
		food.components.edible.healthvalue = 40
		end

            return OldEat(self, food, feeder, ...)
        elseif food then 
            inst.components.inventory:DropItem(food)
            return true     
        end	
    end    	    	
    end

    inst.components.combat.damagemultiplier = TUNING.WILTON_ATTACK_MULT

    inst.components.grue:AddImmunity("wiltonmod")
	
    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura
--[[
        if ingredient.type and ingredient.type == CHARACTER_INGREDIENT.HEALTH and ingredient.amount == 40 then  
            return false                                            
        end
        return old_HasCharacterIngredient(self,ingredient,...)
    end
]]

    local Old_HasIngredients = inst.components.builder.HasIngredients
    inst.components.builder.HasIngredients = function(self, recipe, ...)
        if recipe and recipe.name and recipe.name == "reviver" then 
            return false                                            
        end
        return Old_HasIngredients(self, recipe, ...)
    end

    local function SwapBelly(inst, size)
    for i = 1, 4 do
        if i == size then
            inst.AnimState:Show("body_"..tostring(i))
        else
            inst.AnimState:Hide("body_"..tostring(i))
        end
    end
    end

    local _getAttacked = inst.components.combat.GetAttacked
    inst.components.combat.GetAttacked = function(self, attacker, damage, weapon, stimuli, spdamage, ...)
        local body = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY) or nil
        if body and body:HasTag("wiltonmod_armor") and body.atkedtask == nil then
            local fx = SpawnPrefab("shadow_shield1")
            fx.entity:SetParent(inst.entity)

            body.components.armor:TakeDamage(damage)
            body.atkedtask = body:DoTaskInTime(5, function()
                if body.atkedtask then
                    body.atkedtask:Cancel()
                    body.atkedtask = nil
                end  
            end)
            damage = 0   
        end    

        if attacker and attacker.prefab == "mosquito" and attacker.drinks then
        	attacker.drinks = attacker.drinks - 1
        	SwapBelly(attacker, attacker.drinks)
            return 
        end

        if attacker and attacker.prefab == "gelblob" then
            return 
        end
--[[
        if HasSkill(inst, "wiltonmod_skill1_7") then
            damage = damage * 0.6
        end
]]
        return _getAttacked(self, attacker, damage, weapon, stimuli, spdamage, ...) 
    end

    local OldTempDel = inst.components.temperature.DoDelta  --print(ThePlayer.components.temperature.current)
    inst.components.temperature.DoDelta = function(self, delta, ...)
        delta = delta * 0.5

        if HasSkill(inst, "wiltonmod_skill1_6") then
        	delta = 0
        end	
        return OldTempDel(self, delta, ...) 
    end

    local OldSetTemp = inst.components.temperature.SetTemperature  --print(ThePlayer.components.temperature:DoDelta(10))
    inst.components.temperature.SetTemperature = function(self, value, ...)
        --print("value1 = "value)
        if value and value ~= self.current then
            value = self.current + ((value-self.current)/2)
            --print("value2 = "value) 
        end    
 
        if HasSkill(inst, "wiltonmod_skill1_6") then
        	value = 30
        end	
        return OldSetTemp(self, value, ...) 
    end

    local OldIsInsulated = inst.components.inventory.IsInsulated
    inst.components.inventory.IsInsulated = function(self, ...) --
        if HasSkill(inst, "wiltonmod_skill1_4") then
            return true
        end 
        return OldIsInsulated(self, ...) 
    end
--[[
    inst:ListenForEvent("timerdone", function(inst, data)
        if data.name == "wiltonmod_skeleton_time" then
            BeWilton(inst)                
        end 
    end) 

    inst:DoTaskInTime(0,function()
        if inst:HasTag("is_skel") then
        	print("变回骷髅")
            BeCameSkel(inst)
        end	
    end)
]]
    inst:DoTaskInTime(0.5,function()
        if inst.is_skel then
            BeCameSkel(inst, true)
        end	
    end)

    -- 灵魂出窍保护机制：
    -- 当威尔顿处于幽灵形态时，周期性确保其处于“灵魂出窍激活”状态，
    -- 这样 PlayerController Hook 中的右键拦截逻辑（OnRightClick / OnRemoteRightClick）
    -- 始终能够触发 "wilton_soul_return" 事件，避免重进游戏后右键无法回魂。
    inst:DoPeriodicTask(1, function(player)
        -- 仅处理威尔顿本体，且当前为幽灵状态
        if player == nil or player.prefab ~= "wiltonmod" or not player:HasTag("playerghost") then
            return
        end

        -- 如果已经处于灵魂出窍流程中，则不重复设置，避免无意义写入
        if player.wilton_soul_out_active then
            return
        end

        -- 标记为灵魂出窍激活状态，并同步网络变量，
        -- 让服务器在接收到任意右键操作时，都可以通过 PlayerController Hook 推送回魂事件。
        print("[Wilton][SoulOut][Guard] periodic ensure wilton_soul_out_active for ghost player")
        player.wilton_soul_out_active = true
        if player._wilton_soul_out_active ~= nil then
            player._wilton_soul_out_active:set(true)
        end
    end)

    inst:DoPeriodicTask(0.1, CheckOnWater)
    inst:DoPeriodicTask(0.5, OnWaterRun)
    inst:DoPeriodicTask(1, CheckEquipHeavy)

    inst:ListenForEvent("emote", function(inst, data)
        if inst.components.leader:CountFollowers("wiltonmod_pet") then
        for k, v in pairs(inst.components.leader.followers) do
            if k.prefab == "wiltonmod_pet" and k.components.health and not k.components.health:IsDead()
            and k.components.combat.target == nil and not k.sg:HasStateTag("attack") then 
                k:PushEvent("emote", data)
            end
        end
        end
    end)

    inst:ListenForEvent("newcombattarget", OnNewTarget)

    inst.BeCameSkel = BeCameSkel
    inst.BeWilton = BeWilton	

    inst.OnSave = OnSave
	inst.OnLoad = onload
	--inst.OnPreLoad = onload
    inst.OnNewSpawn = onload	

    -- 根据人物皮肤调整开局骨心外观：稻草人皮肤 -> 稻草之心，其它皮肤保持原样。
	inst:DoTaskInTime(0, function(player)
		UpdateStartBoneheartBySkin(player)
	end)
end

return MakePlayerCharacter("wiltonmod", prefabs, assets, common_postinit, master_postinit, start_inv)
