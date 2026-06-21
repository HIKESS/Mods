local function MakeStaff(name, damage, range, use, cd, isskin)
local assets =
{
	Asset("ANIM", "anim/fireball_2_fx.zip"),
	Asset("ANIM", "anim/wiltonmod_staff.zip"),
	Asset("ANIM", "anim/swap_wiltonmod_staff.zip"),
	Asset("ANIM", "anim/wiltonmod_staff1_swap.zip"),
	Asset("ANIM", "anim/sushengscepter.zip"),
	Asset("ANIM", "anim/sushengscepter_swap.zip"),
	Asset("ANIM", "anim/despair_stone_wand.zip"),
	Asset("ANIM", "anim/despair_stone_wand_swap.zip"),
	Asset("ANIM", "anim/despair_stone_wand1.zip"),
	Asset("ANIM", "anim/despair_stone_wand1_swap.zip"),
	Asset("ATLAS", "images/inventoryimages/wiltonmod_staff1.xml"),
	Asset("ATLAS", "images/inventoryimages/wiltonmod_staff2.xml"), 
	Asset("ATLAS", "images/inventoryimages/wiltonmod_staff3.xml"),
	Asset("ATLAS", "images/inventoryimages/wiltonmod_staff3_skin.xml"),
	Asset("ATLAS", "images/inventoryimages/wiltonmod_staff1_skin.xml"),
	Asset("ATLAS", "images/inventoryimages/wiltonmod_staff2_skin.xml"),
	-- 技能轮盘图标资源（仅供 UI 使用，不参与物品栏图标注册）
	Asset("ATLAS", "images/skill_icon/recover.xml"),
	Asset("IMAGE", "images/skill_icon/recover.tex"),
	Asset("ATLAS", "images/skill_icon/fight.xml"),
	Asset("IMAGE", "images/skill_icon/fight.tex"),
	Asset("ATLAS", "images/skill_icon/follow.xml"),
	Asset("IMAGE", "images/skill_icon/follow.tex"),
	Asset("ATLAS", "images/skill_icon/stop.xml"),
	Asset("IMAGE", "images/skill_icon/stop.tex"),
	Asset("ATLAS", "images/skill_icon/work.xml"),
	Asset("IMAGE", "images/skill_icon/work.tex"),
	Asset("ATLAS", "images/skill_icon/lock.xml"),
	Asset("IMAGE", "images/skill_icon/lock.tex"),
	Asset("ATLAS", "images/skill_icon/cage.xml"),
	Asset("IMAGE", "images/skill_icon/cage.tex"),
	Asset("ATLAS", "images/skill_icon/rotating_skull.xml"),
	Asset("IMAGE", "images/skill_icon/rotating_skull.tex"),
}

-- 技能轮盘图标缩放与轮盘半径配置（对齐 waxwelljournal / ghostcommand 默认）
-- 使用官方模板同款参数：缩放 0.6，半径 50，保证视觉一致性
local ICON_SCALE = .6
local ICON_RADIUS = 50
local STAFF_SPELLBOOK_RADIUS = 100
local STAFF_SPELLBOOK_FOCUS_RADIUS = STAFF_SPELLBOOK_RADIUS + 2

-- 各技能对应的冷却 key（供 spellbookcooldowns 使用）
local SKILL_COOLDOWN_KEYS = {
	recover = "wilton_staff_recover",
	fight = "wilton_staff_fight",
	follow = "wilton_staff_follow",
	stop = "wilton_staff_stop",
	work = "wilton_staff_work",
	cage = "wilton_staff_cage",
	rotating_skull = "wilton_staff_rotating_skull",
}

-- 不同法杖的默认技能：当玩家未选择技能或当前技能不适用于该法杖时回退使用
-- 1/2/3 号骨杖统一默认 recover，保证在“未进行任何选择”时也能直接以复活技能施法
local STAFF_DEFAULT_SKILL = {
	["1"] = "recover",
	["2"] = "recover",
	["3"] = "recover",
}

local STAFF_SPECIAL_SKILL = {
	["1"] = "lock",
	["2"] = "cage",
	["3"] = "rotating_skull",
}

local SPECIAL_SKILLS = {
	lock = true,
	cage = true,
	rotating_skull = true,
}

-- 不同法杖可用的技能集合，用于判断“专属技能”是否可以在当前法杖上使用
-- 这里按照技能轮盘中实际出现的技能来限定
local STAFF_ALLOWED_SKILLS = {
	["1"] = { recover = true, fight = true, follow = true, lock = true, stop = true, work = true },
	["2"] = { recover = true, fight = true, follow = true, cage = true, stop = true, work = true },
	["3"] = { recover = true, fight = true, follow = true, rotating_skull = true, stop = true, work = true },
}

-- 技能图标资源映射
local SKILL_ICON_ATLAS = {
	recover = "images/skill_icon/recover.xml",
	fight = "images/skill_icon/fight.xml",
	follow = "images/skill_icon/follow.xml",
	stop = "images/skill_icon/stop.xml",
	work = "images/skill_icon/work.xml",
	lock = "images/skill_icon/lock.xml",
	cage = "images/skill_icon/cage.xml",
	rotating_skull = "images/skill_icon/rotating_skull.xml",
}

local SKILL_ICON_TEX = {
	recover = "recover.tex",
	fight = "fight.tex",
	follow = "follow.tex",
	stop = "stop.tex",
	work = "work.tex",
	lock = "lock.tex",
	cage = "cage.tex",
	rotating_skull = "rotating_skull.tex",
}

-- 技能轮盘显示用名称：默认直接显示 skill_id；当模组处于中文模式时显示中文。
-- 说明：本模组的语言策略由 modmain.lua 写入 TUNING.WILTON_USE_ENGLISH_STRINGS 控制。
local SKILL_DISPLAY_NAMES_ZH = {
	recover = "死者复生",
	stop = "待机",
	follow = "跟随",
	work = "工作",
	fight = "战斗",
	rotating_skull = "旋转骷髅头",
	cage = "骨牢",
	lock = "未解锁",
}

-- 统一封装技能树检查逻辑：既用于服务器逻辑，也用于客户端 UI 判断。
-- 只要玩家身上挂有 skilltreeupdater 组件，即可通过该函数判断是否解锁某个技能。
local function Wilton_PlayerHasSkill(player, skill)
	return player ~= nil
		and player.components ~= nil
		and player.components.skilltreeupdater ~= nil
		and player.components.skilltreeupdater:IsActivated(skill)
end

local function GetSkillWheelLabel(skill_id)
	-- 英文模式：保持原样，避免影响原有显示/玩家习惯。
	if TUNING ~= nil and TUNING.WILTON_USE_ENGLISH_STRINGS then
		return skill_id
	end

	return (skill_id ~= nil and SKILL_DISPLAY_NAMES_ZH[skill_id]) or skill_id
end

local function ReticuleTargetFn()
	local player = ThePlayer
	local ground = TheWorld and TheWorld.Map or nil
	local pos = Vector3()
	if player == nil or ground == nil then
		return pos
	end
	for r = 7, 0, -.25 do
		pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
		if ground:IsPassableAtPoint(pos:Get()) and not ground:IsGroundTargetBlocked(pos) then
			return pos
		end
	end
	return pos
end

local function OnDischarged(inst)
	local aoetargeting = (inst.components ~= nil) and inst.components.aoetargeting or nil
	if aoetargeting ~= nil then
		aoetargeting:SetEnabled(false)
	end
end

local function OnCharged(inst)
	-- 充能完成后，根据当前骨杖施法模式恢复/刷新 AOE 瞄准。
	-- 这里不直接推断技能ID，而是委托给 inst:RefreshWiltonCastingMode（其闭包内持有 staff 名称与默认技能）。
	if inst ~= nil and inst.RefreshWiltonCastingMode ~= nil then
		print("[WILTON_STAFF_DEBUG] rechargeable charged, refresh casting mode")
		inst:RefreshWiltonCastingMode()
		return
	end

	local aoetargeting = (inst ~= nil and inst.components ~= nil) and inst.components.aoetargeting or nil
	if aoetargeting ~= nil then
		print("[WILTON_STAFF_DEBUG] rechargeable charged, enable aoetargeting fallback")
		aoetargeting:SetEnabled(true)
	end
end

-- 骨刺囚笼用的环形骨刺生成
local function SpawnCage(inst, x, z, r, num, target)
	local vars = { 1, 2, 3, 4, 5, 6, 7 }
	local used = {}
	local queued = {}
	local count = 0
	local dtheta = TWOPI / num
	local delaytoggle = 0
	local map = TheWorld.Map
	for theta = math.random() * dtheta, TWOPI, dtheta do
		local x1 = x + r * math.cos(theta)
		local z1 = z + r * math.sin(theta)
		if map:IsPassableAtPoint(x1, 0, z1) and not map:IsPointNearHole(Vector3(x1, 0, z1)) then
			local spike = SpawnPrefab("fossilspike")
			spike.Transform:SetPosition(x1, 0, z1)

			local delay = delaytoggle == 0 and 0 or .2 + delaytoggle * math.random() * .2
			delaytoggle = delaytoggle == 1 and -1 or 1

			local duration = 5

			local variation = table.remove(vars, math.random(#vars))
			table.insert(used, variation)
			if #used > 3 then
				table.insert(queued, table.remove(used, 1))
			end
			if #vars <= 0 then
				local swap = vars
				vars = queued
				queued = swap
			end

			spike:RestartSpike(delay, duration, variation)
			count = count + 1
		end
	end
	if count <= 0 then
		return false
	end
	if target ~= nil and target:IsValid() then
		target:PushEvent("snared", { attacker = inst })
	end
	return true
end

-- AOE 复活技能：根据选中技能 recover，从落点附近复活幽灵 / 骨堆并治疗骷髅宠物
local function DoRecoverSpell(inst, doer, pos)
	if doer == nil or doer.Transform == nil then
		return false
	end

	local sanity_comp = doer.components ~= nil and doer.components.sanity or nil
	local sanity_cost = TUNING.WILTON_STAFF1_SANITYCOST or 20

	-- 理智不足时给提示，不执行施法
	if sanity_comp ~= nil and sanity_cost > 0 and sanity_comp.current <= sanity_cost then
		local msgtbl = STRINGS.WILTONMOD_MESSAGES
		local msg = (msgtbl ~= nil and msgtbl.SANITY_NOT_ENOUGH) or "Sanity not enough"
		if doer.components ~= nil and doer.components.talker ~= nil then
			doer.components.talker:Say(msg)
		end
		return false
	end

	-- 亡灵指挥家2级：仅当玩家解锁该技能时，才允许对骷髅宠物进行范围回血。
	local enable_skeleton_heal = Wilton_PlayerHasSkill(doer, "wiltonmod_skill2_5")

	local cast = false
	local exclude_tags = { "FX", "NOCLICK", "INLIMBO" }
	local ents = TheSim:FindEntities(pos.x, 0, pos.z, 12, nil, exclude_tags)
	for _, v in ipairs(ents) do
		if v:HasTag("playerghost") then
			cast = true
			v:PushEvent("respawnfromghost", { source = inst })
		elseif v.prefab == "skeleton" or v.prefab == "skeleton_pet" or v.prefab == "scarecrow2" or v.prefab == "skeleton_player" then
			cast = true
			if v.Skel_Respawn ~= nil then
				local x, y, z = v.Transform:GetWorldPosition()
				v:Skel_Respawn(doer)
				if TheWorld ~= nil and TheWorld.ismastersim then
					local fx = SpawnPrefab("wilton_revive_lightning_fx")
					if fx ~= nil then
						fx.Transform:SetPosition(x, y, z)
					end
				end
			end
		end
		if enable_skeleton_heal and v.prefab == "wiltonmod_pet"
			and v.components ~= nil and v.components.health ~= nil then
			v.components.health:SetPercent(1)
			local fx = SpawnPrefab("abigail_shadow_buff_fx")
			if fx ~= nil then
				v:AddChild(fx)
			end
			cast = true
		end
	end

	if cast then
		-- 仅当配置了正数消耗时才扣理智
		if sanity_comp ~= nil and sanity_cost > 0 then
			sanity_comp:DoDelta(-sanity_cost)
		end
	end

	return cast
end

-- 囚笼技能：在目标附近生成一圈骨刺，禁锢敌对单位
local function DoCageSpell(inst, doer, pos)
	if doer == nil or doer.Transform == nil then
		return false
	end
	local cast = false
	local SNARE_TAGS = { "_combat", "locomotor" }
	local targets = TheSim:FindEntities(pos.x, 0, pos.z, 6, SNARE_TAGS)
	for _, v in ipairs(targets) do
		if doer.replica ~= nil and doer.replica.combat ~= nil
			and doer.replica.combat:CanTarget(v)
			and not doer.replica.combat:IsAlly(v) then
			local x, y, z = v.Transform:GetWorldPosition()
			local islarge = v:HasTag("largecreature")
			local r = v:GetPhysicsRadius(0) + (islarge and 1.5 or .5)
			local num = islarge and 12 or 6
			if SpawnCage(doer, x, z, r, num, v) then
				cast = true
			end
		end
	end
	return cast
end

-- 根据玩家记忆的技能和骨杖类型解析实际施法技能
-- 说明：客户端无法访问 GetWiltonSelectedSkill 时，会从 net_string `_wilton_selected_skill` 读取当前技能,
-- 从而保证默认 recover 在“未进行任何选择”时也能立即生效。
local function ResolveSkillForStaff(doer, staff_name, raw_skill_id)
	local default_skill = STAFF_DEFAULT_SKILL[staff_name] or "recover"
	local fallback_skill = default_skill
	-- 调试日志：记录技能解析的输入参数与默认值
	print("[WILTON_STAFF_DEBUG][ResolveSkillForStaff] begin",
		"staff=", tostring(staff_name),
		"raw=", tostring(raw_skill_id),
		"doer_prefab=", doer ~= nil and doer.prefab or "nil",
		"doer_userid=", doer ~= nil and doer.userid or "nil",
		"default=", tostring(default_skill))

	local skill_id = raw_skill_id
	if skill_id == nil and doer ~= nil then
		if doer.GetWiltonSelectedSkill ~= nil then
			-- 服务端优先：通过角色方法做统一的合法性与默认值处理
			skill_id = doer:GetWiltonSelectedSkill()
			print("[WILTON_STAFF_DEBUG][ResolveSkillForStaff] use GetWiltonSelectedSkill:", tostring(skill_id))
		elseif doer._wilton_selected_skill ~= nil then
			-- 客户端 / 无方法时：从 net_string 读取当前同步过来的技能 ID
			local v = doer._wilton_selected_skill:value()
			if type(v) == "string" and v ~= "" then
				skill_id = v
				print("[WILTON_STAFF_DEBUG][ResolveSkillForStaff] use net_string value:", tostring(skill_id))
			end
		elseif doer.wilton_selected_skill ~= nil then
			-- 兜底：退回到本地字段，主要兼容潜在的旧版本 / 其它 MOD 写入
			skill_id = doer.wilton_selected_skill
			print("[WILTON_STAFF_DEBUG][ResolveSkillForStaff] use local field:", tostring(skill_id))
		end
	end

	if skill_id == nil or skill_id == "" then
		print("[WILTON_STAFF_DEBUG][ResolveSkillForStaff] empty skill, fallback to default:", tostring(default_skill))
		return default_skill
	end

	-- 技能轮盘中的“未解锁”占位技能（lock）在解析时统一回退到当前骨杖的默认技能，
	-- 避免进入无效果但仍然触发冷却的异常分支。
	if skill_id == "lock" then
		print("[WILTON_STAFF_DEBUG][ResolveSkillForStaff] lock skill, fallback to default:", tostring(default_skill))
		return default_skill
	end

	if SPECIAL_SKILLS[skill_id] then
		fallback_skill = STAFF_SPECIAL_SKILL[staff_name] or default_skill
		print("[WILTON_STAFF_DEBUG][ResolveSkillForStaff] SPECIAL skill, fallback skill set: skill=" .. tostring(skill_id) .. ", fallback=" .. tostring(fallback_skill))
	end

	-- 亡灵指挥家3级：未解锁前禁止使用随从指令技能，强制退回到默认技能，避免通过旧存档或网络修改绕过限制。
	if (skill_id == "work" or skill_id == "follow" or skill_id == "stop" or skill_id == "fight")
		and not Wilton_PlayerHasSkill(doer, "wiltonmod_skill2_6") then
		print("[WILTON_STAFF_DEBUG][ResolveSkillForStaff] pet command without unlock, fallback:", tostring(skill_id), "->", tostring(fallback_skill))
		return fallback_skill
	end

	local allowed = STAFF_ALLOWED_SKILLS[staff_name]
	if allowed ~= nil and not allowed[skill_id] then
		print("[WILTON_STAFF_DEBUG][ResolveSkillForStaff] skill not allowed for staff, fallback:", tostring(skill_id), "->", tostring(fallback_skill))
		return fallback_skill
	end
	print("[WILTON_STAFF_DEBUG][ResolveSkillForStaff] final skill:", tostring(skill_id))
	return skill_id
end

local COOLDOWN_FAIL_REASON = "WILTONMOD_SKILL_COOLDOWN"

-- 检查某个技能是否处于冷却中，仅用于决定能否施放与给玩家提示。
local function CheckSkillCooldown(doer, skill_id)
	if doer == nil or doer.components == nil or skill_id == nil then
		print("[WILTON_STAFF_DEBUG][Cooldown] skip check",
			"skill=", tostring(skill_id),
			"doer_nil_or_no_components=", tostring(doer == nil or doer.components == nil))
		return true, nil
	end
	local comp = doer.components.spellbookcooldowns
	local key = SKILL_COOLDOWN_KEYS[skill_id]
	if comp ~= nil and key ~= nil and comp:IsInCooldown(key) then
		print("[WILTON_STAFF_DEBUG][Cooldown] in cooldown",
			"skill=", tostring(skill_id),
			"key=", tostring(key),
			"doer_userid=", doer.userid or "nil")
		if doer.components.talker ~= nil then
			local msgtbl = STRINGS.WILTONMOD_MESSAGES
			local msg = (msgtbl ~= nil and msgtbl.SKILL_COOLDOWN) or "技能正在CD中"
			doer.components.talker:Say(msg)
		end
		return false, COOLDOWN_FAIL_REASON
	end
	print("[WILTON_STAFF_DEBUG][Cooldown] ok",
		"skill=", tostring(skill_id),
		"doer_userid=", doer.userid or "nil")
	return true, nil
end

-- 不同技能的总冷却时间（秒）。
local function GetSkillCooldown(skill_id)
	if skill_id == "recover" then
		local v = TUNING.WILTON_STAFF1_COOLDOWN
		print("[WILTON_STAFF_DEBUG][GetSkillCooldown] recover cooldown:", tostring(v))
		return (v ~= nil and v > 0) and v or 0
	elseif skill_id == "cage" or skill_id == "rotating_skull" then
		return 5
	end
	return 0
end

-- 根据当前技能冷却同步骨杖自身的 rechargeable 显示（仅服务器执行，客户端依赖网络同步）。
local function RefreshStaffRecharge(inst, owner, skill_id)
	if inst == nil or inst.components == nil then
		return
	end
	local rechargeable = inst.components.rechargeable
	if rechargeable == nil then
		return
	end
	if TheWorld == nil or not TheWorld.ismastersim then
		return
	end

	local duration = GetSkillCooldown(skill_id)
	-- 没有冷却时间的技能：物品栏显示为已充能，不走 recharge 计时。
	if duration == nil or duration <= 0 then
		rechargeable:SetChargeTime(0)
		rechargeable:SetPercent(1)
		return
	end

	local pct = 0
	if owner ~= nil and owner.components ~= nil and owner.components.spellbookcooldowns ~= nil then
		local key = SKILL_COOLDOWN_KEYS[skill_id]
		if key ~= nil then
			local v = owner.components.spellbookcooldowns:GetSpellCooldownPercent(key)
			if v ~= nil then
				pct = v
			end
		end
	end
	-- spellbookcooldowns 返回的是“剩余比例”（1->0），而 rechargeable 使用的是“已恢复比例”（0->1）。
	if pct < 0 then
		pct = 0
	elseif pct > 1 then
		pct = 1
	end
	local elapsed = 1 - pct

	rechargeable:SetChargeTime(duration)
	rechargeable:SetPercent(elapsed)
end

-- 通过 spellbookcooldowns 记录技能冷却（服务器权威），并驱动法杖自身的 rechargeable 显示。
local function StartSkillCooldown(doer, skill_id, staffinst)
	if doer == nil or doer.components == nil then
		return
	end
	local key = SKILL_COOLDOWN_KEYS[skill_id]
	local comp = doer.components.spellbookcooldowns
	local duration = GetSkillCooldown(skill_id)
	if key ~= nil and comp ~= nil and duration ~= nil and duration > 0 then
		comp:RestartSpellCooldown(key, duration)
		-- 若有明确的骨杖实例，则优先刷新这根骨杖的冷却展示；否则尝试刷新手持骨杖。
		if staffinst ~= nil and staffinst.RefreshWiltonCastingMode ~= nil then
			staffinst:RefreshWiltonCastingMode(skill_id)
		elseif TheWorld ~= nil and TheWorld.ismastersim and doer.components.inventory ~= nil then
			local hands = doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			if hands ~= nil and hands.RefreshWiltonCastingMode ~= nil then
				hands:RefreshWiltonCastingMode(skill_id)
			end
		end
	end
end

-- 注意：本函数同时会处理旋转骷髅的“召回/攻击”快捷逻辑，避免使用未定义的全局变量。
local function ApplyPetCommand(staff, caster, command, target)
	if caster == nil or not caster:IsValid() then
		return
	end

	if TheWorld == nil or not TheWorld.ismastersim then
		return
	end

	local can_cast, reason = CheckSkillCooldown(caster, command)
	if not can_cast then
		return false, reason
	end

	local x, y, z = caster.Transform:GetWorldPosition()

	if command == "rotating_skull" then
		if target == caster then
			local exclude_tags = { "FX", "NOCLICK", "INLIMBO", "player" }
			local ents = TheSim:FindEntities(x, y, z, 12, nil, exclude_tags)
			for _, v in ipairs(ents) do
				if v.prefab == "skeleton" or v.prefab == "scarecrow2" then
					if v.Skel_Respawn ~= nil then
						v:Skel_Respawn(caster)
					end
					StartSkillCooldown(caster, "rotating_skull", staff)
				end
			end
		elseif target ~= nil and target:HasTag("playerghost") then
			target:PushEvent("respawnfromghost", { source = staff })
			StartSkillCooldown(caster, "rotating_skull", staff)
		elseif target ~= nil and target.components ~= nil and target.components.combat ~= nil and target.components.health ~= nil then
			local shoot = SpawnPrefab("wiltonmod_staff_skelhead_project")
			shoot.Transform:SetPosition(x, y, z)
			shoot.target = target
			shoot.components.projectile:Throw(staff, target, caster)
			StartSkillCooldown(caster, "rotating_skull", staff)
		end
		return
	end

	-- follow 命令对随从而言应该回到“默认逻辑”（即 nil），否则会进入一个未定义的状态而影响行为.
	local pet_state = (command == "follow") and nil or command

	local pets = nil
	if caster.components ~= nil and caster.components.leader ~= nil then
		pets = caster.components.leader:GetFollowersByTag("wiltonmod_pet")
	end

	-- 部分情况下 leader.followers 表可能尚未同步/缓存，做一次附近扫描兜底.
	if pets == nil or #pets <= 0 then
		local musttags = { "wiltonmod_pet" }
		local exclude_tags = { "INLIMBO" }
		local scanned = TheSim:FindEntities(x, y, z, 40, musttags, exclude_tags)
		if scanned ~= nil and #scanned > 0 then
			pets = {}
			for _, v in ipairs(scanned) do
				if v ~= nil and v:IsValid() and v.components ~= nil and v.components.follower ~= nil and v.components.follower.leader == caster then
					table.insert(pets, v)
				end
			end
		end
	end

	if pets == nil or #pets <= 0 then
		print("[WILTON_STAFF_DEBUG] no wiltonmod_pet followers:", tostring(command), caster.userid or "nil")
	else
		for _, pet in ipairs(pets) do
			if pet ~= nil and pet:IsValid() and pet.components ~= nil and pet.components.follower ~= nil and pet.components.follower.leader == caster then
				if pet.SetCommandState ~= nil then
					pet:SetCommandState(pet_state)
				else
					pet.command_state = pet_state
				end

				if pet_state == "stop" then
					if pet.components.combat ~= nil then
						pet.components.combat:SetTarget(nil)
					end
					pet.tree_target = nil
					pet:ClearBufferedAction()
				elseif pet_state == "work" then
					if target ~= nil and target:IsValid() and target.components ~= nil and target.components.workable ~= nil and target.components.workable:CanBeWorked() then
						pet.tree_target = target
					else
						pet.tree_target = nil
					end
					pet:ClearBufferedAction()
				elseif pet_state == "fight" then
					if target ~= nil and target:IsValid() and pet.components ~= nil and pet.components.combat ~= nil and pet.components.combat:CanTarget(target) then
						pet.components.combat:SetTarget(target)
					end
				else
					-- follow（pet_state=nil）或其它未单独处理的指令：回到默认逻辑，清理残留工作目标与动作。
					pet.tree_target = nil
					pet:ClearBufferedAction()
				end

				if pet.brain ~= nil then
					pet.brain:Stop()
					pet.brain:Start()
				end
				print("[WILTON_STAFF_DEBUG] pet command applied:", tostring(command), tostring(pet_state), caster.userid or "nil", pet.GUID, target ~= nil and target.prefab or "nil")
			end
		end
	end

	StartSkillCooldown(caster, command, staff)
end

-- 为 spellbook 生成技能轮盘 items（客户端与服务器都会用到）。
-- spell wheel 支持两种显示：UIAnim(bank/build/anims) 或 ImageButton(atlas/normal)。
-- 这里使用 ImageButton，直接复用 mod 内的 atlas/tex 资源，避免额外动画资源依赖。
local function BuildStaffSkillItemsForName(staff_name)
	local allowed = STAFF_ALLOWED_SKILLS[staff_name] or STAFF_ALLOWED_SKILLS["1"]
	-- 技能轮盘统一默认高亮 recover，避免不同法杖默认指向不同技能导致误触。
	local default_skill = "recover"
	local order = { "recover", "fight", "work", "lock", "cage", "rotating_skull", "follow", "stop" }

	local items = {}
	for _, skill_id in ipairs(order) do
		if allowed ~= nil and allowed[skill_id] then
			local atlas = SKILL_ICON_ATLAS[skill_id]
			local tex = SKILL_ICON_TEX[skill_id]
			if atlas ~= nil and tex ~= nil then
				local cdkey = SKILL_COOLDOWN_KEYS[skill_id]
				local is_pet_command = (skill_id == "work" or skill_id == "follow" or skill_id == "stop" or skill_id == "fight")
				local item = {
					label = GetSkillWheelLabel(skill_id),
					atlas = atlas,
					normal = tex,
					widget_scale = ICON_SCALE,
					default_focus = (skill_id == default_skill) or nil,
					checkcooldown = function(doer)
						return (doer ~= nil
							and doer.components ~= nil
							and doer.components.spellbookcooldowns ~= nil
							and cdkey ~= nil
							and doer.components.spellbookcooldowns:GetSpellCooldownPercent(cdkey))
							or nil
					end,
					cooldowncolor = { 0.65, 0.65, 0.65, 0.75 },
					execute = function(staffinst)
						local player = ThePlayer
						if player == nil then
							return
						end
						-- 亡灵指挥家3级：未解锁前禁止切换到随从指令技能（work/follow/stop/fight），保持当前技能不变。
						if is_pet_command and not Wilton_PlayerHasSkill(player, "wiltonmod_skill2_6") then
							if player.components ~= nil and player.components.talker ~= nil then
								local msgtbl = STRINGS.WILTONMOD_MESSAGES
								local msg = msgtbl ~= nil and msgtbl.SKILL_LOCKED or nil
								if msg ~= nil then
									player.components.talker:Say(msg)
								end
							end
							return
						end
						if player.rpc_SetWiltonSelectedSkill ~= nil then
							player:rpc_SetWiltonSelectedSkill(skill_id)
						elseif player.SetWiltonSelectedSkill ~= nil then
							player:SetWiltonSelectedSkill(skill_id)
						end
						if staffinst ~= nil and staffinst.RefreshWiltonCastingMode ~= nil then
							staffinst:RefreshWiltonCastingMode(skill_id)
						end
					end,
				}
				-- 亡灵指挥家3级：在未解锁前让随从指令在轮盘中处于“不可用且不可见”状态，避免误触。
				-- 使用 spell wheel 的 checkenabled + ImageButton 的禁用颜色机制做到：
				--  - checkenabled 返回 false 时按钮被 Disable（无法点击）
				--  - postinit 中将 Disabled 颜色改为全透明，使图标完全看不见
				if is_pet_command then
					item.checkenabled = function(user)
						return Wilton_PlayerHasSkill(user, "wiltonmod_skill2_6")
					end
					item.postinit = function(widget)
						-- 只改禁用态颜色：解锁后仍使用默认 Normal/Focus 颜色正常显示。
						widget:SetImageDisabledColour(1, 1, 1, 0)
					end
				end
				table.insert(items, item)
			end
		end
	end

	return items
end

-- 仅当骨杖真正装备在玩家手上时才允许打开技能轮盘，避免背包/地面右键直接呼出
local function StaffSpellbookCanUseFn(staff_inst, user)
	if staff_inst == nil or user == nil then
		return false
	end

	-- 优先使用服务端 inventory 组件，其次回退到客户端 replica，保证单双端行为一致
	local inv = (user.components ~= nil and user.components.inventory)
		or (user.replica ~= nil and user.replica.inventory)
		or nil
	if inv == nil or inv.GetEquippedItem == nil then
		return false
	end

	local hands_item = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
	-- 只有当玩家当前手部装备就是这根骨杖时，才允许 spellbook 被认为可用
	return hands_item == staff_inst
end

-- 单体施法技能（普通挥动动画）：旋转骷髅 + 四个骷髅命令
local function SkillUsesSingleCast(skill_id)
	return skill_id == "rotating_skull"
		or skill_id == "fight"
		or skill_id == "follow"
		or skill_id == "stop"
		or skill_id == "work"
end

-- AOE 施法入口：根据当前技能分发 recover / cage
local function SpellFn(inst, doer, pos, caster)
	local skillid = ResolveSkillForStaff(doer, name)
	-- 兜底保护：任何无法解析出的技能都强制回退到默认技能 recover，
	-- 避免首次施法时出现 skillid 为空导致 CanCast/SpellFn 行为异常（例如卡在起手动画）。
	if skillid == nil or skillid == "" then
		local default_skill = STAFF_DEFAULT_SKILL[name] or "recover"
		skillid = default_skill
	end

	if TheWorld.ismastersim then
		print("[WILTON_STAFF_DEBUG] AOESpell Cast:", tostring(skillid), doer ~= nil and doer.userid or "nil")
	end
	if skillid == "recover" then
		local can_cast, reason = CheckSkillCooldown(doer, "recover")

		if not can_cast then
			return false, reason
		end
		local success = DoRecoverSpell(inst, doer, pos)
		if success then
			StartSkillCooldown(doer, "recover", inst)
			return true
		end
		-- 注意：当周围没有任何可复活目标时，DoRecoverSpell 会返回 false。
		-- 此时我们不触发效果与冷却，但也不再将本次施法视为“失败”，
		-- 避免服务器立即打断 CASTAOE 动作导致客户端动画卡在起手帧。
		return true
	elseif skillid == "cage" then
		local can_cast, reason = CheckSkillCooldown(doer, "cage")

		if not can_cast then
			return false, reason
		end
		local success = DoCageSpell(inst, doer, pos)
		if success then
			StartSkillCooldown(doer, "cage", inst)
		end
		return success == true
	end
	return false
end

local function RefreshWiltonCastingMode(inst, skill_id)
	local owner = (inst.components ~= nil and inst.components.inventoryitem ~= nil)
		and inst.components.inventoryitem:GetGrandOwner()
		or nil
	local raw_skill = skill_id
	skill_id = ResolveSkillForStaff(owner, name, skill_id)
	-- 若 ResolveSkillForStaff 返回空字符串，强制退回到当前骨杖的默认技能，
	-- 避免在客户端第一次刷新施法模式时得到一个空 skill_id，导致 aoetargeting 未被正确启用。
	if skill_id == nil or skill_id == "" then
		local default_skill = STAFF_DEFAULT_SKILL[name] or "recover"
		skill_id = default_skill
	end

	local is_single = SkillUsesSingleCast(skill_id)
	local aoetargeting = inst.components ~= nil and inst.components.aoetargeting or nil
	local spellcaster = inst.components ~= nil and inst.components.spellcaster or nil

	if inst ~= nil and inst:HasTag("wiltonmod_item") then
		print("[WILTON_STAFF_DEBUG][RefreshMode]",
			"staff=", tostring(name),
			"raw=", tostring(raw_skill),
			"resolved=", tostring(skill_id),
			"owner=", owner ~= nil and owner.prefab or "nil",
			"userid=", owner ~= nil and owner.userid or "nil")
	end

	if aoetargeting ~= nil then
		-- 默认情况下不强制禁用 AOE 瞄准；只有在解析为单体技能时才关闭，
		-- 这样可以保证首次装备、默认 recover 时，客户端立刻认为 aoetargeting 处于启用状态，
		-- 右键即可通过 TryAOETargeting 进入 CASTAOE 流程。
		inst._wilton_aoetargeting_forced_disabled = is_single and true or false

		-- 单体技能不需要落点 reticule；AOE 技能才启用瞄准。
		aoetargeting:SetEnabled(not is_single)
		if is_single then
			if not TheWorld.ismastersim then
				aoetargeting:StopTargeting()
			end
		else
			aoetargeting:SetDeployRadius(0)
			aoetargeting:SetRange(20)
		end
	end

	if spellcaster ~= nil then
		spellcaster.canuseondead = true
		spellcaster.canusefrominventory = false
		spellcaster.quickcast = is_single
		spellcaster.veryquickcast = false
		spellcaster:SetCanCastFn(nil)

		-- 先清空限制，避免切换技能后遗留 tag 导致无法施法。
		spellcaster.canonlyuseonworkable = false
		spellcaster.canonlyuseoncombat = false
		spellcaster.canonlyuseonrecipes = false
		spellcaster.canonlyuseonlocomotors = false
		spellcaster.canonlyuseonlocomotorspvp = false
		spellcaster.canuseontargets = false
		spellcaster.canuseonpoint = false

		if skill_id == "work" then
			spellcaster.canuseontargets = true
			spellcaster.canonlyuseonworkable = true
			spellcaster.canuseonpoint = true
			spellcaster:SetCanCastFn(function(doer, target, pos)
				local can_cast, reason = CheckSkillCooldown(doer, "work")
				if not can_cast then
					return false, reason
				end
				if target ~= nil then
					return target.components ~= nil
						and target.components.workable ~= nil
						and target.components.workable:CanBeWorked()
				end
				return true
			end)
		elseif skill_id == "fight" then
			-- 战斗指令既可以对实体施法，也可以对地面施法:
			-- * 对实体：仅允许可攻击且存活的生物作为目标，非生物在此直接被视为不可施放。
			-- * 对地面：只做冷却检测，实际目标选择由 OnCast 在落点附近搜索决定。
			spellcaster.canuseontargets = true
			spellcaster.canuseonpoint = true
			spellcaster:SetCanCastFn(function(doer, target, pos)
				local can_cast, reason = CheckSkillCooldown(doer, "fight")
				if not can_cast then
					return false, reason
				end
				-- 对实体施法时：仅允许可攻击且存活的生物，否则视为不可施放，直接跳过。
				if target ~= nil then
					if doer == nil or doer.components == nil or doer.components.combat == nil then
						return false
					end
					local combat = doer.components.combat
					-- 排除与施法者为友方的单位（包括同阵营/随从等）。
					if combat.IsAlly ~= nil and combat:IsAlly(target) then
						return false
					end
					return target.components ~= nil
						and target.components.health ~= nil
						and not target.components.health:IsDead()
						and combat:CanTarget(target)
				end
				-- 对地面施法：仅需通过冷却检测，是否实际找到目标由 OnCast 决定。
				return true
			end)
		elseif skill_id == "follow" or skill_id == "stop" then
			-- 跟随 / 待机 指令：只需要对地面施法即可，不要求选中特定实体。
			spellcaster.canuseonpoint = true
			local sid = skill_id
			spellcaster:SetCanCastFn(function(doer, target, pos)
				local can_cast, reason = CheckSkillCooldown(doer, sid)
				if not can_cast then
					return false, reason
				end
				return true
			end)
		else
			spellcaster.canuseontargets = is_single
			if skill_id == "rotating_skull" then
				spellcaster:SetCanCastFn(function(doer, target, pos)
					local can_cast, reason = CheckSkillCooldown(doer, "rotating_skull")
					if not can_cast then
						return false, reason
					end
					if doer == nil or target == nil then
						return false
					end
					if target == doer then
						return true
					end
					if target:HasTag("playerghost") then
						return true
					end
					return target.components ~= nil
						and target.components.health ~= nil
						and not target.components.health:IsDead()
						and target.components.combat ~= nil
				end)
			end
		end
	end

	-- 根据当前解析出的技能，刷新骨杖自身的数据显示为该技能的冷却进度。
	RefreshStaffRecharge(inst, owner, skill_id)
end

local function OnCast(inst, target, pos, caster)
	if inst == nil or caster == nil then
		return
	end

	local skill_id = ResolveSkillForStaff(caster, name)
	if TheWorld.ismastersim then
		print("[WILTON_STAFF_DEBUG] Single Cast:", tostring(skill_id), caster.userid or "nil")
	end

	if skill_id == "fight" then
		-- 战斗指令：
		-- * 若对实体施法，则尝试让随从攻击该生物（可攻击性与存活状态已在 CanCastFn 中约束）。
		-- * 若对地面施法，则在落点附近搜索一个可攻击的敌对 / 中立生物，找到后才下达战斗命令。
		local final_target = target
		if final_target == nil then
			local x, y, z
			if pos ~= nil then
				x, y, z = pos:Get()
			else
				x, y, z = caster.Transform:GetWorldPosition()
			end
			local exclude_tags = { "FX", "NOCLICK", "INLIMBO", "player" }
			local ents = TheSim:FindEntities(x, 0, z, 12, nil, exclude_tags)
			if ents ~= nil then
				for _, v in ipairs(ents) do
					if v ~= nil
						and v:IsValid()
						and v.components ~= nil
						and v.components.health ~= nil
						and not v.components.health:IsDead()
						and v.components.combat ~= nil
						and caster.components ~= nil
						and caster.components.combat ~= nil
						and (caster.components.combat.IsAlly == nil or not caster.components.combat:IsAlly(v))
						and caster.components.combat:CanTarget(v) then
						final_target = v
						break
					end
				end
			end
		end

		-- 未能找到合适的战斗目标时，直接返回：不对随从下达命令，也不触发冷却。
		if final_target == nil then
			return
		end

		ApplyPetCommand(inst, caster, "fight", final_target)
		return
	elseif skill_id == "follow" or skill_id == "stop" or skill_id == "work" then
		ApplyPetCommand(inst, caster, skill_id, target)
		return
	elseif skill_id == "rotating_skull" then
		-- rotating_skull 的详细逻辑已在 ApplyPetCommand 中兼容处理（召回/攻击/复活等）
		ApplyPetCommand(inst, caster, skill_id, target)
		return
	end
end

------------------------------------------------------------------------
-- 装备外观与残影逻辑（来自旧测试版）

local STAFF_TRAIL_FLAGS = { "shadowtrail" }
local staff_cane_do_trail
local staff_cane_equipped
local staff_cane_unequipped

staff_cane_do_trail = function(inst)
	if inst.trail_fx == nil then
		return
	end
	local owner = inst.components ~= nil and inst.components.inventoryitem ~= nil and inst.components.inventoryitem:GetGrandOwner() or inst
	if owner == nil or not owner.entity:IsVisible() then
		return
	end
	local x, y, z = owner.Transform:GetWorldPosition()
	if owner.sg ~= nil and owner.sg:HasStateTag("moving") and owner.components.locomotor ~= nil then
		local theta = -owner.Transform:GetRotation() * DEGREES
		local speed = owner.components.locomotor:GetRunSpeed() * .1
		x = x + speed * math.cos(theta)
		z = z + speed * math.sin(theta)
	end
	local mounted = owner.components.rider ~= nil and owner.components.rider:IsRiding()
	local map = TheWorld.Map
	local offset = FindValidPositionByFan(
		math.random() * TWOPI,
		(mounted and 1 or .5) + math.random() * .5,
		4,
		function(off)
			local pt = Vector3(x + off.x, 0, z + off.z)
			return map:IsPassableAtPoint(pt:Get())
				and not map:IsPointNearHole(pt)
				and #TheSim:FindEntities(pt.x, 0, pt.z, .7, STAFF_TRAIL_FLAGS) <= 0
		end
	)
	if offset ~= nil then
		SpawnPrefab(inst.trail_fx).Transform:SetPosition(x + offset.x, 0, z + offset.z)
	end
end

staff_cane_equipped = function(inst, owner)
	if inst.trail_fx ~= nil and inst._trailtask == nil then
		inst._trailtask = inst:DoPeriodicTask(6 * FRAMES, staff_cane_do_trail, 2 * FRAMES)
	end
end

staff_cane_unequipped = function(inst)
	if inst._trailtask ~= nil then
		inst._trailtask:Cancel()
		inst._trailtask = nil
	end
end

-- 修理相关：骨杖被打坏时暂时移除 equippable/weapon，修复后恢复
local function DisableComponents(inst)
	if inst.components.equippable ~= nil then
		inst:RemoveComponent("equippable")
	end
	if inst.components.weapon ~= nil then
		inst:RemoveComponent("weapon")
	end
end

local function OnBroken(inst)
	if inst.components.inventoryitem ~= nil then
		inst:AddTag("broken")
		DisableComponents(inst)
	end
end

local function OnRepaired(inst)
	if inst:HasTag("broken") then
		inst:RemoveTag("broken")
		-- 重新挂回基础战斗组件，保持与 fn() 中初始设置一致
		if inst.components.weapon == nil then
			inst:AddComponent("weapon")
			if name == "1" then
				inst.components.weapon:SetDamage(damage)
			else
				inst.components.weapon:SetDamage(10)
				inst.components.weapon:SetProjectile("wiltonmod_staff_projectile" .. name)
				if inst.components.planardamage == nil then
					inst:AddComponent("planardamage")
					inst.components.planardamage:SetBaseDamage(damage)
				end
			end
			if range then
				inst.components.weapon:SetRange(range)
			end
		end
		if inst.components.equippable == nil then
			inst:AddComponent("equippable")
			inst.components.equippable:SetOnEquip(onequip)
			inst.components.equippable:SetOnUnequip(onunequip)
			inst.components.equippable.walkspeedmult = name == "1" and 1.2 or 1.25
			inst.components.equippable.restrictedtag = "wiltonmod"
		end
	end
end

local function onequip(inst, owner)
	if isskin and name == "3" then
		owner.AnimState:OverrideSymbol("swap_object", "sushengscepter_swap", "sushengscepter_swap")
	elseif isskin and name == "1" then
		owner.AnimState:OverrideSymbol("swap_object", "despair_stone_wand_swap", "despair_stone_wand_swap")
	elseif isskin and name == "2" then
		owner.AnimState:OverrideSymbol("swap_object", "despair_stone_wand1_swap", "despair_stone_wand1_swap")
	else
		if not isskin and name == "1" then
			-- 1 号原版骨杖使用单独的手持动画
			owner.AnimState:OverrideSymbol("swap_object", "wiltonmod_staff1_swap", "wiltonmod_staff1_swap")
		else
			owner.AnimState:OverrideSymbol("swap_object", "swap_wiltonmod_staff", "swap_wiltonmod_staff"..name)
		end
	end
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
	if isskin and name == "1" then
		staff_cane_equipped(inst, owner)
	end
	-- 装备时强制以骨杖自身的默认技能刷新一次施法模式，
	-- 确保在玩家从未打开过技能轮盘的情况下，recover 已在客户端/服务器两端完全生效。
	if inst ~= nil and inst.RefreshWiltonCastingMode ~= nil then
		local default_skill = STAFF_DEFAULT_SKILL[name] or "recover"
		inst:RefreshWiltonCastingMode(default_skill)
	end
end

local function onunequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
	if isskin and name == "1" then
		staff_cane_unequipped(inst)
	end
end

------------------------------------------------------------------------
-- 预制体构造函数

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "small")

	if isskin and name == "3" then
		inst.AnimState:SetBank("sushengscepter")
		inst.AnimState:SetBuild("sushengscepter")
		inst.AnimState:PlayAnimation("idle")
	elseif isskin and name == "1" then
		inst.AnimState:SetBank("despair_stone_wand")
		inst.AnimState:SetBuild("despair_stone_wand")
		inst.AnimState:PlayAnimation("idle")
	elseif isskin and name == "2" then
		inst.AnimState:SetBank("despair_stone_wand1")
		inst.AnimState:SetBuild("despair_stone_wand1")
		inst.AnimState:PlayAnimation("idle")
	else
		inst.AnimState:SetBank("wiltonmod_staff")
		inst.AnimState:SetBuild("wiltonmod_staff")
		inst.AnimState:PlayAnimation(name)
	end

	inst:AddTag("weapon")
	inst:AddTag("rechargeable")
	inst:AddTag("wiltonmod_item")
	if name ~= "1" then
		inst:AddTag("rangedweapon")
		inst:AddTag("magicweapon")
	end

	-- AOE 瞄准与技能轮盘组件（客户端也需要）
	inst:AddComponent("aoetargeting")
	inst.components.aoetargeting:SetAllowRiding(false)
	inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoe"
	inst.components.aoetargeting.reticule.pingprefab = "reticuleaoeping"
	inst.components.aoetargeting.reticule.targetfn = ReticuleTargetFn
	inst.components.aoetargeting.reticule.validcolour = { 1, .75, 0, 1 }
	inst.components.aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
	inst.components.aoetargeting.reticule.ease = true
	inst.components.aoetargeting.reticule.mouseenabled = true
	if inst.components.aoetargeting._wilton_old_IsEnabled == nil then
		inst.components.aoetargeting._wilton_old_IsEnabled = inst.components.aoetargeting.IsEnabled
		inst.components.aoetargeting.IsEnabled = function(self, ...)
			if self ~= nil and self.inst ~= nil and self.inst._wilton_aoetargeting_forced_disabled then
				return false
			end
			return self._wilton_old_IsEnabled(self, ...)
		end
	end
	if inst.components.aoetargeting._wilton_old_StartTargeting == nil then
		inst.components.aoetargeting._wilton_old_StartTargeting = inst.components.aoetargeting.StartTargeting
		inst.components.aoetargeting.StartTargeting = function(self, ...)
			if self ~= nil and self.inst ~= nil and self.inst._wilton_aoetargeting_forced_disabled then
				return
			end
			return self._wilton_old_StartTargeting(self, ...)
		end
	end

	inst:AddComponent("spellbook")
	inst.components.spellbook:SetRequiredTag("wiltonmod")
	inst.components.spellbook:SetRadius(STAFF_SPELLBOOK_RADIUS)
	inst.components.spellbook:SetFocusRadius(STAFF_SPELLBOOK_FOCUS_RADIUS)
	inst.components.spellbook:SetItems(BuildStaffSkillItemsForName(name))
	inst.components.spellbook:SetCanUseFn(StaffSpellbookCanUseFn)
	inst.components.spellbook:SetSpellFn(nil)
	-- 首次生成时预选中技能轮盘的第一个槽位（recover），
	-- 避免未打开技能轮盘时 spell_id 为空，导致 OnRemoteLeftClick 无法在服务器端重算 CASTAOE 动作。
	local _wilton_default_slot_ok = inst.components.spellbook:SelectSpell(1)
	print("[WILTON_STAFF_DEBUG] spellbook initialized for staff", name, "default_slot_ok=", tostring(_wilton_default_slot_ok))

	inst:AddComponent("aoespell")
	inst.components.aoespell:SetSpellFn(SpellFn)

	if name == "3" then
		inst.fxcolour = { 10 / 255, 10 / 255, 255 / 255 }
	end

	inst:AddComponent("spellcaster")
	inst.components.spellcaster:SetSpellFn(OnCast)

	inst:AddComponent("rechargeable")
	inst.components.rechargeable:SetOnDischargedFn(OnDischarged)
	inst.components.rechargeable:SetOnChargedFn(OnCharged)

	inst.RefreshWiltonCastingMode = RefreshWiltonCastingMode

	-- 根据当前默认技能刷新一次施法模式。
	-- 这里直接传入骨杖的默认技能，避免初次生成时依赖玩家身上的未初始化技能字段，
	-- 提前把 aoetargeting / spellcaster 的状态配置成 recover。
	local default_skill = STAFF_DEFAULT_SKILL[name] or "recover"
	inst:RefreshWiltonCastingMode(default_skill)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("weapon")
	if name == "1" then
		inst.components.weapon:SetDamage(damage)
	else
		inst.components.weapon:SetDamage(10)
		inst.components.weapon:SetProjectile("wiltonmod_staff_projectile" .. name)
		inst:AddComponent("planardamage")
		inst.components.planardamage:SetBaseDamage(damage)
	end

	if name == "2" and isskin then
		inst.components.weapon:SetProjectile("wiltonmod_staff_projectile2_purple")
	end

	if name == "1" and isskin then
		inst.trail_fx = "cane_ancient_fx"
	end

	if range then
		inst.components.weapon:SetRange(range)
	end

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	if isskin and name == "3" then
		inst.components.inventoryitem.imagename = "wiltonmod_staff3_skin"
		inst.components.inventoryitem.atlasname = "images/inventoryimages/wiltonmod_staff3_skin.xml"
	elseif isskin and name == "1" then
		inst.components.inventoryitem.imagename = "wiltonmod_staff1_skin"
		inst.components.inventoryitem.atlasname = "images/inventoryimages/wiltonmod_staff1_skin.xml"
	elseif isskin and name == "2" then
		inst.components.inventoryitem.imagename = "wiltonmod_staff2_skin"
		inst.components.inventoryitem.atlasname = "images/inventoryimages/wiltonmod_staff2_skin.xml"
	else
		inst.components.inventoryitem.imagename = "wiltonmod_staff" .. name
		inst.components.inventoryitem.atlasname = "images/inventoryimages/wiltonmod_staff" .. name .. ".xml"
	end

	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)
	inst.components.equippable.walkspeedmult = name == "1" and 1.2 or 1.25
	inst.components.equippable.restrictedtag = "wiltonmod"

	if use then
		inst:AddComponent("finiteuses")
		inst.components.finiteuses:SetMaxUses(use)
		inst.components.finiteuses:SetUses(use)
	end

	if name == "2" then
		MakeForgeRepairable(inst, FORGEMATERIALS.VOIDCLOTH, OnBroken, OnRepaired)
	elseif name == "3" then
		MakeForgeRepairable(inst, FORGEMATERIALS.LUNARPLANT, OnBroken, OnRepaired)
	end

	MakeHauntableLaunch(inst)

	return inst
end

local prefabname = isskin and ("wiltonmod_staff" .. name .. "_skin") or ("wiltonmod_staff" .. name)

return Prefab(prefabname, fn, assets)
end

return MakeStaff("1", 34, nil, nil, TUNING.WILTON_STAFF1_COOLDOWN or 60),
	   MakeStaff("2", TUNING.WILTON_STAFF2_PLANARDAMAGE or 40, 8, 400, 5),
	   MakeStaff("3", TUNING.WILTON_STAFF3_PLANARDAMAGE or 60, 8, 400, 60),
	   MakeStaff("3", TUNING.WILTON_STAFF3_PLANARDAMAGE or 60, 8, 400, 60, true),
	   MakeStaff("1", 34, nil, nil, TUNING.WILTON_STAFF1_COOLDOWN or 60, true),
	   MakeStaff("2", TUNING.WILTON_STAFF2_PLANARDAMAGE or 40, 8, 400, 5, true)