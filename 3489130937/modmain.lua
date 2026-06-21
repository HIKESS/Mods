--- 威尔顿角色模组入口文件
 -- 负责注册预制体、资源、角色、技能树，以及链接各子脚本（字符串、数值、配方、行为 Hook、UI 等）。
 GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

-- 预先加载官方皮肤工具，确保 ShouldDisplayItemInCollection / GetRarityForItem 等函数已注册，再做重载。
require("skinsutils")

 --- Loyal 稀有度自定义皮肤过滤重载（仅推荐单人 / 私服使用）。
 -- 通过放宽 ShouldDisplayItemInCollection 对本模组 Loyal 皮肤的拥有检查，避免被官方皮肤管理过滤掉。
local _ShouldDisplayItemInCollection = GLOBAL.ShouldDisplayItemInCollection
GLOBAL.ShouldDisplayItemInCollection = function(item_type, ...)
    -- 仅对本模组前缀且稀有度为 Loyal 的皮肤跳过过滤，其余交给原逻辑处理，尽量减少与其他 MOD 冲突。
    if type(item_type) == "string" and item_type:sub(1, #"wiltonmod_") == "wiltonmod_" then
        local rarity = GLOBAL.GetRarityForItem ~= nil and GLOBAL.GetRarityForItem(item_type) or nil
        if rarity == "Loyal" then
            return true
        end
    end

    if _ShouldDisplayItemInCollection ~= nil then
        return _ShouldDisplayItemInCollection(item_type, ...)
    end

    return true
end

 --- 本模组需要在世界中注册的自定义预制体列表。
 -- 包含角色本体、角色皮肤虚拟预制体、骷髅随从、专属装备、容器及特效等。
 PrefabFiles = {
  "wiltonmod",
  "wiltonmod_none",
  "wiltonmod_skeleton",
  "scarecrow2",

  "wiltonmod_pack",
  "wiltonmod_chest",
  "wilton_resurrectiongrave",
  "wilton_dug_gravestone",

  "wiltonmod_boneheart",
  "wiltonmod_bonepaste",
  "wiltonmod_shoot",
  "wiltonmod_sharpbone",
  "wiltonmod_bonehammer",

  "wiltonmod_hat",
  "wiltonmod_armor",
  "wiltonmod_staff",
  "wiltonmod_pet",
  "wiltonmod_fx",

  "undead_armory"
}

--[[
  1人物皮肤， 随从皮肤
  2法杖换皮
  3尖刺换皮
]]

 --- 模组关联的贴图、图集与音频资源.
 -- 这些资源会被预加载，以供角色选择界面、头像、地图图标以及自定义音效使用.
 Assets = {
    Asset( "IMAGE", "bigportraits/wiltonmod.tex" ),
    Asset( "ATLAS", "bigportraits/wiltonmod.xml" ),
	
	Asset( "IMAGE", "bigportraits/wiltonmod_none.tex" ),
    Asset( "ATLAS", "bigportraits/wiltonmod_none.xml" ),

	Asset( "IMAGE", "bigportraits/wiltonmod_skin1_none.tex" ),
    Asset( "ATLAS", "bigportraits/wiltonmod_skin1_none.xml" ),	
    
	Asset( "IMAGE", "bigportraits/resurrection_scarecrow_charater_none.tex" ),
    Asset( "ATLAS", "bigportraits/resurrection_scarecrow_charater_none.xml" ),
	Asset( "ATLAS", "bigportraits/wiltonmod_scarecrow_none.xml" ),
    
	Asset( "IMAGE", "images/names_gold_wiltonmod.tex" ),
	Asset( "ATLAS", "images/names_gold_wiltonmod.xml" ),
	
	Asset( "IMAGE", "images/names_wiltonmod.tex" ),
	Asset( "ATLAS", "images/names_wiltonmod.xml" ),
	
	Asset( "IMAGE", "images/map_icons/wiltonmod.tex" ),
	Asset( "ATLAS", "images/map_icons/wiltonmod.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_wiltonmod.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_wiltonmod.xml" ),  
	
	Asset( "IMAGE", "images/avatars/avatar_ghost_wiltonmod.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_ghost_wiltonmod.xml" ),

    Asset( "IMAGE", "images/avatars/self_inspect_wiltonmod.tex" ),
    Asset( "ATLAS", "images/avatars/self_inspect_wiltonmod.xml" ),    

	Asset( "IMAGE", "images/map_icons/sturdyskeleton.tex" ),
	Asset( "ATLAS", "images/map_icons/sturdyskeleton.xml" ),
	
	Asset( "IMAGE", "images/scarecrow2.tex" ),
	Asset( "ATLAS", "images/scarecrow2.xml" ),
	
	Asset("SOUNDPACKAGE", "sound/wiltonmod.fev"),
    Asset("SOUND", "sound/wiltonmod.fsb"),

	Asset("SOUNDPACKAGE", "sound/wilton_sound.fev"),
    Asset("SOUND", "sound/wilton_sound.fsb"),

    Asset("ANIM", "anim/undead_armory.zip"),
    Asset("IMAGE", "images/inventoryimages/undead_armory_icon.tex"),
    Asset("ATLAS", "images/inventoryimages/undead_armory_icon.xml"),
}


 --- 为角色 `wiltonmod` 声明可用的角色皮肤 prefab 名称.
 -- 会与 postinits/skin.lua 中的皮肤系统扩展一起工作.
 GLOBAL.PREFAB_SKINS["wiltonmod"] = {   
  "wiltonmod_none",
  "wiltonmod_skin1_none",
  "wiltonmod_scarecrow_none"
}

RegisterInventoryItemAtlas("images/scarecrow2.xml")
RegisterInventoryItemAtlas("images/inventoryimages/wiltonmod_hat.xml", "wiltonmod_hat.tex")
RegisterInventoryItemAtlas("images/inventoryimages/wiltonmod_armor.xml", "wiltonmod_armor.tex")
RegisterInventoryItemAtlas("images/inventoryimages/undead_armory_icon.xml", "undead_armory_icon.tex")

 --- 将威尔顿注册为模组角色，并添加小地图图标.
 -- 性别用于部分对话和皮肤系统的性别区分，实际属性由 prefab 决定.
 AddModCharacter("wiltonmod", "FEMALE") 
 AddMinimapAtlas("images/map_icons/wiltonmod.xml")  

local function Wilton_ApplyLanguage()
	local langopt = GetModConfigData("wilton_language") or "default"
	local use_en

	-- 方案 ：模组默认视为中文，仅当玩家在模组设置中显式选择 English 时才使用英文字符串。
	-- 这样不会依赖 TheNet:GetLanguageCode()，避免客户端 / 服务器语言代码不一致导致占位语错乱。
	if langopt == "en" then
		use_en = true
	else
		-- "default" 和 "ch" 以及任何未知取值都统一视为中文。
		use_en = false
	end

	-- 记录当前是否使用英文字符串，供其他脚本侧根据该标记做语言相关的细节调整（如占位语音）。
	TUNING.WILTON_USE_ENGLISH_STRINGS = use_en

	-- 覆写技能轮盘与施法相关动作的提示文本：
	-- * USESPELLBOOK / CLOSESPELLBOOK：技能 / Skills、取消 / Cancel
	-- * CASTSPELL：根据当前骨杖宠物指令技能显示工作 / 跟随 / 待机 / 战斗
	STRINGS.ACTIONS.USESPELLBOOK = STRINGS.ACTIONS.USESPELLBOOK or {}
	STRINGS.ACTIONS.CLOSESPELLBOOK = STRINGS.ACTIONS.CLOSESPELLBOOK or {}
	STRINGS.ACTIONS.CASTSPELL = STRINGS.ACTIONS.CASTSPELL or {}
	if use_en then
		STRINGS.ACTIONS.USESPELLBOOK.GENERIC = "Skills"
		STRINGS.ACTIONS.CLOSESPELLBOOK.GENERIC = "Cancel"
		STRINGS.ACTIONS.USESPELLBOOK.WILTON_SKILL = "Skills"
		STRINGS.ACTIONS.CLOSESPELLBOOK.WILTON_CANCEL = "Cancel"
		-- 骨杖宠物指令：英文提示文本
		STRINGS.ACTIONS.CASTSPELL.WILTON_PET_WORK = "Work"
		STRINGS.ACTIONS.CASTSPELL.WILTON_PET_FOLLOW = "Follow"
		STRINGS.ACTIONS.CASTSPELL.WILTON_PET_STOP = "Standby"
		STRINGS.ACTIONS.CASTSPELL.WILTON_PET_FIGHT = "Fight"
	else
		STRINGS.ACTIONS.USESPELLBOOK.GENERIC = "技能"
		STRINGS.ACTIONS.CLOSESPELLBOOK.GENERIC = "取消"
		STRINGS.ACTIONS.USESPELLBOOK.WILTON_SKILL = "技能"
		STRINGS.ACTIONS.CLOSESPELLBOOK.WILTON_CANCEL = "取消"
		-- 骨杖宠物指令：中文提示文本
		STRINGS.ACTIONS.CASTSPELL.WILTON_PET_WORK = "工作"
		STRINGS.ACTIONS.CASTSPELL.WILTON_PET_FOLLOW = "跟随"
		STRINGS.ACTIONS.CASTSPELL.WILTON_PET_STOP = "待机"
		STRINGS.ACTIONS.CASTSPELL.WILTON_PET_FIGHT = "战斗"
	end

	if use_en then
		-- 英文模式：仅加载英文字符串文件；具体台词与占位语音表在字符串 / 台词文件中维护。
		modimport("scripts/mains/wilton_Strings_en.lua")
	else
		-- 中文模式（包含 default 和 ch）：仅加载中文字符串文件；具体台词与占位语音表在字符串 / 台词文件中维护。
		modimport("scripts/mains/wilton_Strings.lua")
	end

	-- 中文模式下，为海伊角色补写关键中文字符串，避免被其他语言模组覆盖。
	-- 仅在 use_en 为 false 时加载，保证英文环境不受到影响。
	if not use_en then
		modimport("scripts/mains/haiyi_Compat_Strings.lua")
	end
end

 --- 加载各类子模块:
-- * wilton_Strings：角色与物品字符串、音效映射
-- * wilton_Tuning：角色基础数值与开始物品
-- * wilton_Recipes：配方、物品皮肤注册
-- * wilton_Hook：对世界与生物行为进行后期 Hook
-- * wilton_Action_Hook：自定义动作和动作可用性
-- * wilton_Sg：状态机（stategraph）扩展
-- * wilton_Ui：角色 UI 与容器布局调整
Wilton_ApplyLanguage()
modimport("scripts/mains/wilton_Tuning.lua")
modimport("scripts/mains/wilton_Recipes.lua")
modimport("scripts/mains/wilton_Hook.lua")
modimport("scripts/mains/wilton_Action_Hook.lua")
modimport("scripts/mains/wilton_PlayerController_Hook.lua")
modimport("scripts/mains/wilton_Sg.lua")
modimport("scripts/mains/wilton_Ui.lua")

 --- 覆写 USESPELLBOOK / CLOSESPELLBOOK 的动作名称选择函数：
-- 为威尔顿（wiltonmod）强制返回自定义 key，使其显示为“技能 / 取消”，避免被基础翻译覆盖。
local _Wilton_UseSpellbook_StrFn = ACTIONS.USESPELLBOOK.strfn
ACTIONS.USESPELLBOOK.strfn = function(act)
	if act ~= nil and act.doer ~= nil and act.doer.prefab == "wiltonmod" then
		return "WILTON_SKILL"
	end
	if _Wilton_UseSpellbook_StrFn ~= nil then
		return _Wilton_UseSpellbook_StrFn(act)
	end
end

local _Wilton_CloseSpellbook_StrFn = ACTIONS.CLOSESPELLBOOK.strfn
ACTIONS.CLOSESPELLBOOK.strfn = function(act)
	if act ~= nil and act.doer ~= nil and act.doer.prefab == "wiltonmod" then
		return "WILTON_CANCEL"
	end
	if _Wilton_CloseSpellbook_StrFn ~= nil then
		return _Wilton_CloseSpellbook_StrFn(act)
	end
end

 --- 覆写 CASTAOE 动作名称选择函数：
-- 当威尔顿手持死亡权杖（2 号或 3 号骨杖）并将技能轮盘切换为 recover 时，
-- 右键施法应显示“死者复生”，而不是始终显示权杖默认技能（例如 2 号的“骨刺囚笼”）。
local _Wilton_CastAOE_StrFn = ACTIONS.CASTAOE.strfn
ACTIONS.CASTAOE.strfn = function(act)
	-- act.invobject：当前用于 CASTAOE 的物品，一般为手中的法杖
	local inv = act ~= nil and act.invobject or nil
	if inv ~= nil then
		local prefab = inv.prefab
		-- 仅针对 wilton 的死亡权杖（2 号与 3 号骨杖）及其皮肤做特殊处理
		if prefab == "wiltonmod_staff2" or prefab == "wiltonmod_staff2_skin"
			or prefab == "wiltonmod_staff3" or prefab == "wiltonmod_staff3_skin" then
			local doer = act.doer
			if doer ~= nil then
				-- 在客户端上无法调用 GetWiltonSelectedSkill（该方法仅在 master_postinit 中定义），
				-- 因此优先从 net_string `_wilton_selected_skill` 中读取当前同步过来的技能 ID，
				-- 若该字段不存在或为空，再退回到本地的 `wilton_selected_skill` 字段。
				local skill
				if doer._wilton_selected_skill ~= nil then
					local v = doer._wilton_selected_skill:value()
					if v ~= nil and v ~= "" then
						skill = v
					end
				end
				if skill == nil or skill == "" then
					skill = doer.wilton_selected_skill
				end
				-- 当当前选中技能为 recover 时，使用专用的 CASTAOE 文本 key
				if skill == "recover" then
					return "WILTONMOD_STAFF_RECOVER"
				end
			end
		end
	end

	-- 其他情况保持原有行为，交给默认的 strfn 决定显示文本
	if _Wilton_CastAOE_StrFn ~= nil then
		return _Wilton_CastAOE_StrFn(act)
	end
end

 --- 覆写 CASTSPELL 动作名称选择函数：
-- 当威尔顿手持骨杖并将技能轮盘切换为宠物指令（work/follow/stop/fight）时，
-- 右键施法应显示对应的中文 / 英文提示，而不是统一的“施放法术 / Cast Spell”。
local _Wilton_CastSpell_StrFn = ACTIONS.CASTSPELL.strfn
ACTIONS.CASTSPELL.strfn = function(act)
	if act ~= nil and act.doer ~= nil and act.invobject ~= nil then
		local doer = act.doer
		local inv = act.invobject
		local prefab = inv.prefab
		-- 仅针对本模组的骨杖及其皮肤处理宠物指令提示文本
		if prefab == "wiltonmod_staff1" or prefab == "wiltonmod_staff2" or prefab == "wiltonmod_staff3"
			or prefab == "wiltonmod_staff1_skin" or prefab == "wiltonmod_staff2_skin" or prefab == "wiltonmod_staff3_skin" then
			local skill
			-- 优先从 net 变量中读取当前同步的技能 ID
			if doer._wilton_selected_skill ~= nil then
				local v = doer._wilton_selected_skill:value()
				if v ~= nil and v ~= "" then
					skill = v
				end
			end
			-- 若 net 变量为空，则退回到本地字段
			if (skill == nil or skill == "") and doer.wilton_selected_skill ~= nil then
				skill = doer.wilton_selected_skill
			end
			if skill == "work" then
				return "WILTON_PET_WORK"
			elseif skill == "follow" then
				return "WILTON_PET_FOLLOW"
			elseif skill == "stop" then
				return "WILTON_PET_STOP"
			elseif skill == "fight" then
				return "WILTON_PET_FIGHT"
			end
		end
	end

	if _Wilton_CastSpell_StrFn ~= nil then
		return _Wilton_CastSpell_StrFn(act)
	end
end

 --- 皮肤与物品皮肤相关的通用扩展:
 -- * postinits/skin.lua：接入 Hornet 的角色皮肤系统
 -- * util/item_skin_api.lua：接入配方界面物品皮肤选择逻辑
 modimport("scripts/postinits/skin.lua")
 modimport("scripts/util/item_skin_api.lua")
--modimport("scripts/util/stu_skin_api.lua")

--- 加载并注册威尔顿的技能树定义.
-- `skilltree_wiltonmod` 返回一个 BuildSkillsData 函数，用于构造 SKILLS / ORDERS.
local skilltree_defs = require("prefabs/skilltree_defs")
local BuildSkillsData = require("prefabs/skilltree_wiltonmod")

local enable_skilltree = GetModConfigData("wilton_skilltree")
TUNING.WILTON_SKILLTREE_ENABLED = enable_skilltree ~= false

if TUNING.WILTON_SKILLTREE_ENABLED and BuildSkillsData then
    local data = BuildSkillsData(skilltree_defs.FN)
    if data then
        -- 为 wiltonmod 创建技能树并指定在 UI 中的面板布局顺序.
        skilltree_defs.CreateSkillTreeFor("wiltonmod", data.SKILLS)
        skilltree_defs.SKILLTREE_ORDERS["wiltonmod"] = data.ORDERS
    end
end

-- 威尔顿骨杖技能选择同步：客户端 -> 服务器
-- 通过自定义 ModRPC，将技能轮盘的选择在联机环境下同步到主机，
-- 再由服务器调用 wiltonmod.SetWiltonSelectedSkill 进行记忆与存档。

local _wilton_modname = modname

-- 服务器端接收技能 ID，并调用玩家身上的接口进行记忆
AddModRPCHandler(_wilton_modname, "Wilton_SetSelectedSkill", function(player, skillid)
	if player ~= nil and player.SetWiltonSelectedSkill ~= nil then
		player:SetWiltonSelectedSkill(skillid or "recover")
	end
	if player ~= nil and player.components ~= nil and player.components.inventory ~= nil then
		local inv = player.components.inventory
		local hands = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
		if hands ~= nil and hands.RefreshWiltonCastingMode ~= nil then
			hands:RefreshWiltonCastingMode(skillid)
		end
		local active = inv:GetActiveItem()
		if active ~= nil and active ~= hands and active.RefreshWiltonCastingMode ~= nil then
			active:RefreshWiltonCastingMode(skillid)
		end
		print("[WILTON_STAFF_DEBUG] Server skill synced:", player.userid, tostring(skillid))
	end
end)

-- 新 RPC：威尔顿灵魂出窍期间的“立即回魂”请求
AddModRPCHandler(_wilton_modname, "Wilton_SoulReturn", function(player)
	if player ~= nil
		and player.prefab == "wiltonmod"
		and player:HasTag("playerghost")
		and player.wilton_soul_out_active then
		player:PushEvent("wilton_soul_return", { from = "ModRPC" })
	end
end)

-- 预先获取 RPC 常量，供客户端发送使用
local RPC_WILTON_SET_SKILL = GetModRPC(_wilton_modname, "Wilton_SetSelectedSkill")
local RPC_WILTON_SOUL_RETURN = GetModRPC(_wilton_modname, "Wilton_SoulReturn")

--------------------------------------------------------------------------
-- 威尔顿与骷髅相关的基础属性与行为开关.
-- 配置 -> TUNING -> 各 prefab / Hook 统一读取，保证联机一致。
TUNING.WILTON_SKELETON_COUNT = GetModConfigData("wilton_skeleton_count")
TUNING.WILTON_SKELETON_SPEED = GetModConfigData("wilton_skeleton_speed")

--- 威尔顿与骷髅相关的基础属性与行为开关.
-- 配置 -> TUNING -> 各 prefab / Hook 统一读取，保证联机一致。
TUNING.WILTONMOD_HEALTH = GetModConfigData("wilton_health") or TUNING.WILTONMOD_HEALTH
TUNING.WILTONMOD_SANITY = GetModConfigData("wilton_sanity") or TUNING.WILTONMOD_SANITY

TUNING.WILTON_DROP_HUMANMEAT = GetModConfigData("wilton_drop_humanmeat") ~= false
TUNING.WILTON_REVIVE_TIME = GetModConfigData("wilton_revive_time") or 30
TUNING.WILTON_ATTACK_MULT = GetModConfigData("wilton_attack_mult") or 0.75
TUNING.WILTON_DISABLE_HEAL = GetModConfigData("wilton_disable_heal") == true
TUNING.WILTON_SKELETON_DURABILITY = GetModConfigData("wilton_skeleton_durability") ~= false
-- 骷髅兵无敌配置开关，开启后随从在服务端将被设置为完全无敌。
TUNING.WILTON_SKELETON_INVINCIBLE = GetModConfigData("wilton_skeleton_invincible") == true

--- 装备相关的可调数值.
-- 由 modinfo.lua 中的“装备设置 / Equipment Settings”读取进来，供各类武器与法杖统一使用。
TUNING.WILTON_SHOOT_DAMAGE = GetModConfigData("wilton_shoot_damage") or 34
TUNING.WILTON_SHARPBONE_DAMAGE = GetModConfigData("wilton_sharpbone_damage") or 45
TUNING.WILTON_BONEHAMMER_DAMAGE = GetModConfigData("wilton_bonehammer_damage") or 34

local staff1_sanitycost = GetModConfigData("wilton_staff1_sanitycost")
if staff1_sanitycost == nil then
	staff1_sanitycost = 20
end
TUNING.WILTON_STAFF1_SANITYCOST = staff1_sanitycost

local staff1_cooldown = GetModConfigData("wilton_staff1_cooldown")
if staff1_cooldown == nil then
	staff1_cooldown = 60
end
TUNING.WILTON_STAFF1_COOLDOWN = staff1_cooldown

TUNING.WILTON_STAFF2_PLANARDAMAGE = GetModConfigData("wilton_staff2_planardamage") or 40
TUNING.WILTON_STAFF3_PLANARDAMAGE = GetModConfigData("wilton_staff3_planardamage") or 60

 --------------------------------------------------------------------------
 -- 南瓜帽（pumpkinhat）装备限制放宽：
 -- 官方万圣节南瓜灯帽在非活动期间通常依赖 Equippable:IsRestricted / equippable_replica:IsRestricted
 -- 做 tag 限制。这里仅对威尔顿做一个特例放行：
 -- * 物品 prefab 必须是 "pumpkinhat"；
 -- * 装备者 prefab 必须是 "wiltonmod"；
 -- 其余所有情况仍然走原版判定逻辑，避免影响其它角色与 MOD。

 --- 服务器端组件：Equippable.IsRestricted 特例放行威尔顿的南瓜帽装备。
 -- @param self   Equippable 组件实例
 -- @param target 尝试装备该物品的实体
 AddComponentPostInit("equippable", function(self)
     local _Wilton_Orig_Equippable_IsRestricted = self.IsRestricted

     function self:IsRestricted(target)
         local inst = self.inst
         if inst ~= nil and inst.prefab == "pumpkinhat"
             and target ~= nil and target.prefab == "wiltonmod" then
             -- 威尔顿戴南瓜帽时，无视任何 restrictedtag / 事件限制。
             return false
         end

         if _Wilton_Orig_Equippable_IsRestricted ~= nil then
             return _Wilton_Orig_Equippable_IsRestricted(self, target)
         end

         return false
     end
 end)

 --- 客户端副本：equippable_replica.IsRestricted 同步放宽，保证本地 UI / 预测行为一致。
 -- 仅针对组件类 "components/equippable_replica" 实例生效，避免影响其它 replica 组件。
 AddClassPostConstruct("components/equippable_replica", function(self)
     local _Wilton_Orig_EquippableReplica_IsRestricted = self.IsRestricted

     function self:IsRestricted(target)
         local inst = self.inst
         if inst ~= nil and inst.prefab == "pumpkinhat"
             and target ~= nil and target.prefab == "wiltonmod" then
             return false
         end

         if _Wilton_Orig_EquippableReplica_IsRestricted ~= nil then
             return _Wilton_Orig_EquippableReplica_IsRestricted(self, target)
         end

         return false
     end
 end)

 --- 玩家执行动作时的回调，目前仅用于调试（保留结构以便后续扩展）。
 -- @param inst EntityScript 玩家实例
 -- @param data table 包含本次执行的 action 等信息
 local function OnPerformaction(inst, data)
    if data.action then
        -- 如需调试动作流，可临时打印 `data.action.action.id`。
        --print(data.action.action.id)
    end
end

--- 为所有玩家注册 `performaction` 事件监听；同时在客户端挂载骨杖技能选择的 RPC 帮助方法.
-- 服务器：监听 performaction；客户端：提供 rpc_SetWiltonSelectedSkill 供骨杖在本地发起 RPC.
AddPlayerPostInit(function(inst)
	if not TheWorld.ismastersim then
		-- 客户端通过该方法把技能选择同步给服务器
		inst.rpc_SetWiltonSelectedSkill = function(self, skillid)
			SendModRPCToServer(RPC_WILTON_SET_SKILL, skillid or "recover")
		end
		return inst
	end

	inst:ListenForEvent("performaction", OnPerformaction)

	-- 复活雕像（resurrectionstatue）会通过 attunable/attuner 系统绑定玩家并在幽灵时提供远程复活按钮。
	-- 这里对威尔顿做专属禁用：
	-- 1) 禁止威尔顿绑定 resurrectionstatue（防止产生 remoteresurrector attunement）
	-- 2) 兼容旧存档/已绑定的情况：威尔顿加载后自动解除其与 resurrectionstatue 的绑定，确保复活按钮不会出现
	if inst.prefab == "wiltonmod" then
		inst:DoTaskInTime(0, function(player)
			if player == nil or not player:IsValid() or player.components == nil then
				return
			end
			local attuner = player.components.attuner
			if attuner == nil or not attuner:HasAttunement("remoteresurrector") then
				return
			end
			local target = attuner:GetAttunedTarget("remoteresurrector")
			if target ~= nil and target:IsValid()
				and target.prefab == "resurrectionstatue"
				and target.components ~= nil
				and target.components.attunable ~= nil then
				print("[Wilton][ResurrectionStatue] unlink existing attunement to resurrectionstatue for wilton")
				target.components.attunable:UnlinkFromPlayer(player, true)
			end
		end)
	end
 end)

 --------------------------------------------------------------------------
 -- 禁用威尔顿绑定 resurrectionstatue
 -- 说明：
 -- * 原版 resurrectionstatue 在服务端添加 components.attunable，并设置 attunable_tag 为 "remoteresurrector"。
 -- * HUD 的复活按钮出现条件是玩家 attuner 拥有 remoteresurrector/gravestoneresurrector 之一。
 -- * 因此从源头阻断 LinkToPlayer/CanAttune 即可同时禁用绑定与复活按钮.
 AddComponentPostInit("attunable", function(self)
 	local _Wilton_Orig_Attunable_CanAttune = self.CanAttune

 	function self:CanAttune(player)
 		local inst = self.inst
 		if inst ~= nil and inst.prefab == "resurrectionstatue"
 			and player ~= nil and player.prefab == "wiltonmod" then
 			print("[Wilton][ResurrectionStatue] block attune to resurrectionstatue")
 			return false
 		end

 		if _Wilton_Orig_Attunable_CanAttune ~= nil then
 			return _Wilton_Orig_Attunable_CanAttune(self, player)
 		end

 		return false
 	end
 end)

--------------------------------------------------------------------------
-- 威尔顿骨杖：客户端输入与动作选择调试 Hook
-- 说明：
-- * PlayerController / PlayerActionPicker 是客户端本地组件；官方脚本在 data/scripts 中，本模组无法直接修改。

--- 判断物品是否为威尔顿骨杖（或其皮肤）。
-- 目前统一依赖 wiltonmod_item 标签，避免与其它 MOD 的 prefab 名冲突.
local function Wilton_IsStaffItem(item)
	return item ~= nil and item:HasTag("wiltonmod_item")
end

--- 低频调试：仅当关键状态发生变化时才输出，避免 DoGetMouseActions 每帧刷屏.
-- 说明：
-- * PlayerActionPicker 会在鼠标移动/每帧反复计算动作列表，直接打印会造成日志爆炸.
-- * 这里仅在 AOE 模式切换、LMB/RMB 动作发生变化时输出一行.
-- @param pap PlayerActionPicker
-- @param userid string
-- @param staff_prefab string
-- @param isaoe boolean
-- @param lmbid string
-- @param rmbid string
local function Wilton_DebugPAP_OnActionChange(pap, userid, staff_prefab, isaoe, lmbid, rmbid)
	if pap == nil then
		return
	end

	local last = pap._wilton_staff_debug_last
	if last == nil then
		last = {}
		pap._wilton_staff_debug_last = last
	end

	local changed = false
	if last.isaoe ~= isaoe then
		changed = true
	end
	if last.lmbid ~= lmbid then
		changed = true
	end
	if last.rmbid ~= rmbid then
		changed = true
	end

	if changed then
		print("[WILTON_STAFF_DEBUG][PAP.MouseActions]",
			"userid=", userid or "nil",
			"prefab=", tostring(staff_prefab),
			"isaoe=", tostring(isaoe),
			"lmb=", tostring(lmbid),
			"rmb=", tostring(rmbid))
		last.isaoe = isaoe
		last.lmbid = lmbid
		last.rmbid = rmbid
	end
end

--- 为 PlayerActionPicker 挂载调试 Hook：
-- * DoGetMouseActions：记录本帧计算得到的 LMB / RMB 动作（含动作 ID）。
-- * GetRightClickActions：记录右键动作列表中所有动作的 ID，便于判断是否成功插入 CASTAOE.
AddClassPostConstruct("components/playeractionpicker", function(self)
	local _Wilton_Orig_DoGetMouseActions = self.DoGetMouseActions
	local _Wilton_Orig_GetRightClickActions = self.GetRightClickActions

	if _Wilton_Orig_DoGetMouseActions ~= nil then
		self.DoGetMouseActions = function(self_pap, position, target, spellbook, ...)
			local inst = self_pap.inst
			local inv = inst.replica ~= nil and inst.replica.inventory or nil
			local equipitem = inv ~= nil and inv:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
			local is_wilton_staff = Wilton_IsStaffItem(equipitem)
			local lmb, rmb = _Wilton_Orig_DoGetMouseActions(self_pap, position, target, spellbook, ...)
			if is_wilton_staff then
				local lmbid = (lmb ~= nil and lmb.action ~= nil) and lmb.action.id or "nil"
				local rmbid = (rmb ~= nil and rmb.action ~= nil) and rmb.action.id or "nil"
				local pc = inst.components ~= nil and inst.components.playercontroller or nil
				local isaoe = pc ~= nil and pc:IsAOETargeting() or false

				Wilton_DebugPAP_OnActionChange(self_pap, inst.userid, equipitem.prefab, isaoe, lmbid, rmbid)
			end
			return lmb, rmb
		end
	end

	if _Wilton_Orig_GetRightClickActions ~= nil then
		self.GetRightClickActions = function(self_pap, position, target, spellbook, ...)
			local inst = self_pap.inst
			local inv = inst.replica ~= nil and inst.replica.inventory or nil
			local equipitem = inv ~= nil and inv:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
			local is_wilton_staff = Wilton_IsStaffItem(equipitem)
			local actions = _Wilton_Orig_GetRightClickActions(self_pap, position, target, spellbook, ...)
			if is_wilton_staff then
				local pc = inst.components ~= nil and inst.components.playercontroller or nil
				local isaoe = pc ~= nil and pc:IsAOETargeting() or false
				local ids = {}
				if actions ~= nil then
					for i, v in ipairs(actions) do
						table.insert(ids, v.action ~= nil and v.action.id or "nil")
					end
				end
				local last = self_pap._wilton_staff_debug_last
				if last == nil then
					last = {}
					self_pap._wilton_staff_debug_last = last
				end
				local ids_str = table.concat(ids, ",")
				if last.right_ids ~= ids_str or last.right_isaoe ~= isaoe then
					print("[WILTON_STAFF_DEBUG][PAP.RightClickActions]",
						"userid=", inst.userid or "nil",
						"prefab=", tostring(equipitem.prefab),
						"isaoe=", tostring(isaoe),
						"count=", actions ~= nil and #actions or 0,
						"ids=", ids_str)
					last.right_ids = ids_str
					last.right_isaoe = isaoe
				end
			end
			return actions
		end
	end
end)

--------------------------------------------------------------------------
-- 威尔顿骨杖：服务器动作执行调试 Hook（CASTAOE / CASTSPELL）
-- 说明：
-- * 这里直接包裹全局 ACTIONS 表中的 fn，而不是修改 template/scripts/actions.lua 中的模板拷贝。
-- * 仅在使用带有 "wiltonmod_item" 标签的武器时输出日志，方便在 server_log 中定位实际执行的动作路径.

local _Wilton_Orig_CASTAOE_fn = ACTIONS.CASTAOE.fn
ACTIONS.CASTAOE.fn = function(act, ...)
	local staff = nil
	if act ~= nil then
		if act.invobject ~= nil then
			staff = act.invobject
		elseif act.doer ~= nil and act.doer.components ~= nil and act.doer.components.inventory ~= nil then
			staff = act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		end
	end
	local is_wilton_staff = Wilton_IsStaffItem(staff)
	if is_wilton_staff then
		local act_pos = act ~= nil and act:GetActionPoint() or nil
		local px, py, pz = 0, 0, 0
		if act_pos ~= nil and act_pos.Get ~= nil then
			px, py, pz = act_pos:Get()
		end
		print("[WILTON_STAFF_DEBUG][CASTAOE.fn] begin",
			"prefab=", tostring(staff.prefab),
			"doer=", act.doer ~= nil and act.doer.prefab or "nil",
			"userid=", act.doer ~= nil and act.doer.userid or "nil",
			"x=", tostring(px),
			"z=", tostring(pz))
	end
	if _Wilton_Orig_CASTAOE_fn ~= nil then
		local res, reason = _Wilton_Orig_CASTAOE_fn(act, ...)
		if is_wilton_staff then
			print("[WILTON_STAFF_DEBUG][CASTAOE.fn] end",
				"res=", tostring(res),
				"reason=", tostring(reason))
		end
		return res, reason
	end
end

local _Wilton_Orig_CASTSPELL_fn = ACTIONS.CASTSPELL.fn
ACTIONS.CASTSPELL.fn = function(act, ...)
	local staff = act ~= nil and act.invobject or nil
	local is_wilton_staff = Wilton_IsStaffItem(staff)
	if is_wilton_staff then
		print("[WILTON_STAFF_DEBUG][CASTSPELL.fn] begin",
			"prefab=", tostring(staff.prefab),
			"doer=", act.doer ~= nil and act.doer.prefab or "nil",
			"userid=", act.doer ~= nil and act.doer.userid or "nil")
	end
	if _Wilton_Orig_CASTSPELL_fn ~= nil then
		local res, reason = _Wilton_Orig_CASTSPELL_fn(act, ...)
		if is_wilton_staff then
			print("[WILTON_STAFF_DEBUG][CASTSPELL.fn] end",
				"res=", tostring(res),
				"reason=", tostring(reason))
		end
		return res, reason
	end
end

--------------------------------------------------------------------------
-- HoverText 提示优化：
-- 仅当玩家是威尔顿且当前右键动作目标为威尔顿复生墓碑时，隐藏第二行“连接到:”提示，
-- 保持第一行“检查 复生墓碑”，让体验与普通墓碑一致，同时不影响其他角色与 MOD。
-- AddClassPostConstruct("widgets/hoverer", function(self)
-- 	local _Wilton_Orig_OnUpdate = self.OnUpdate
-- 	function self:OnUpdate(...)
-- 		-- 先执行原始 HoverText 更新逻辑，保持其它 UI 行为不变。
-- 		_Wilton_Orig_OnUpdate(self, ...)

-- 		local owner = self.owner
-- 		if owner == nil or owner.prefab ~= "wiltonmod" then
-- 			return
-- 		end

-- 		-- 只在本地玩家拥有 playercontroller 时检查右键动作，避免无控制器时报错。
-- 		local pc = owner.components ~= nil and owner.components.playercontroller or nil
-- 		if pc == nil then
-- 			return
-- 		end

-- 		local rmb = pc:GetRightMouseAction()
-- 		if rmb ~= nil and rmb.target ~= nil and rmb.target.prefab == "wilton_resurrectiongrave" then
-- 			-- 对于威尔顿瞄准自家复生墓碑的情况，强制隐藏第二行右键提示文本。
-- 			self.secondarystr = nil
-- 			if self.secondarytext ~= nil then
-- 				self.secondarytext:Hide()
-- 			end
-- 		end
-- 	end
-- end)

--------------------------------------------------------------------------
-- 威尔顿灵魂出窍：鼠标右键“回魂”提示 UI。
-- 仅在本地玩家是威尔顿幽灵且处于灵魂出窍流程中时，在 HoverText 第二行显示
-- “右键图标 + 回魂”的提示，提示玩家可以通过鼠标右键立即回魂。
AddClassPostConstruct("widgets/hoverer", function(self)
	local _Wilton_Orig_OnUpdate = self.OnUpdate

	function self:OnUpdate(...)
		-- 先执行原始 HoverText 更新逻辑，保持其它 UI 行为不变。
		if _Wilton_Orig_OnUpdate ~= nil then
			_Wilton_Orig_OnUpdate(self, ...)
		end

		local owner = self.owner
		if owner == nil or owner.prefab ~= "wiltonmod" then
			return
		end

		local pc = owner.components ~= nil and owner.components.playercontroller or nil
		if pc == nil or not pc:UsingMouse() then
			return
		end

		if not owner:HasTag("playerghost") then
			return
		end

		-- 通过网络变量优先判断是否处于灵魂出窍流程中，
		-- 若网络变量不存在则退回到本地字段，保证单机 / 掉线场景下也有提示。
		local active = false
		if owner._wilton_soul_out_active ~= nil then
			active = owner._wilton_soul_out_active:value()
		elseif owner.wilton_soul_out_active ~= nil then
			active = owner.wilton_soul_out_active == true
		end

		if not active then
			return
		end

		local control_str = nil
		if TheInput ~= nil then
			control_str = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_SECONDARY)
		end

		local hint
		if control_str ~= nil and control_str ~= "" then
			hint = control_str .. " 回魂"
		else
			hint = "右键 回魂"
		end

		self.secondarystr = hint
		if self.secondarytext ~= nil then
			self.secondarytext:SetString(hint)
			self.secondarytext:Show()
		end

		-- 文本内容更新后根据当前鼠标位置刷新整体提示位置，保证紧跟鼠标/指示器
		if TheInput ~= nil then
			local pos = TheInput:GetScreenPosition()
			self:UpdatePosition(pos.x, pos.y)
		end
	end
end)

--------------------------------------------------------------------------
-- 威尔顿骨杖：客户端输入与动作选择调试 Hook
-- 说明：
-- * PlayerController / PlayerActionPicker 是客户端本地组件；官方脚本在 data/scripts 中，本模组无法直接修改。

--- 为 PlayerController 挂载调试 Hook：
-- * TryAOETargeting：记录在尝试进入 AOE 瞄准模式前后的状态（是否启用、是否成功进入等）。
-- * OnRightClick：记录本地缓存的 RMBaction 以及当前是否处于 AOE 瞄准模式.
AddClassPostConstruct("components/playercontroller", function(self)
	-- 保护性缓存原始方法，确保不破坏其它 MOD 或游戏本体逻辑.
	local _Wilton_Orig_TryAOETargeting = self.TryAOETargeting
	local _Wilton_Orig_OnRightClick = self.OnRightClick

	if _Wilton_Orig_TryAOETargeting ~= nil then
		self.TryAOETargeting = function(self_pc, ...)
			local inst = self_pc.inst
			local inv = inst.replica ~= nil and inst.replica.inventory or nil
			local hands = inv ~= nil and inv:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
			local is_wilton_staff = Wilton_IsStaffItem(hands)
			if is_wilton_staff then
				local aoetargeting = hands.components ~= nil and hands.components.aoetargeting or nil
				local enabled = aoetargeting ~= nil and aoetargeting:IsEnabled() or false
				print("[WILTON_STAFF_DEBUG][PC.TryAOETargeting] begin",
					"userid=", inst.userid or "nil",
					"prefab=", tostring(hands.prefab),
					"enabled=", tostring(enabled),
					"is_aoetargeting=", tostring(self_pc:IsAOETargeting()))
			end
			local ret = _Wilton_Orig_TryAOETargeting(self_pc, ...)
			if is_wilton_staff then
				print("[WILTON_STAFF_DEBUG][PC.TryAOETargeting] end",
					"result=", tostring(ret),
					"is_aoetargeting=", tostring(self_pc:IsAOETargeting()))
			end
			return ret
		end
	end

	if _Wilton_Orig_OnRightClick ~= nil then
		self.OnRightClick = function(self_pc, down, ...)
			local inst = self_pc.inst
			-- 客户端环境下：威尔顿幽灵任意右键都立刻向服务器发送“回魂” RPC，避免等待路径预测或其他动作完成。
			if not TheWorld.ismastersim
				and down
				and inst ~= nil
				and inst.prefab == "wiltonmod"
				and inst:HasTag("playerghost") then
				SendModRPCToServer(RPC_WILTON_SOUL_RETURN)
			end

			-- 原有：仅在手持威尔顿骨杖时输出调试日志，不影响其他角色与行为。
			local inv = inst.replica ~= nil and inst.replica.inventory or nil
			local hands = inv ~= nil and inv:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
			local is_wilton_staff = Wilton_IsStaffItem(hands)
			if is_wilton_staff then
				local act = self_pc:GetRightMouseAction()
				local actid = (act ~= nil and act.action ~= nil) and act.action.id or "nil"
				print("[WILTON_STAFF_DEBUG][PC.OnRightClick] begin",
					"down=", tostring(down),
					"userid=", inst.userid or "nil",
					"prefab=", tostring(hands.prefab),
					"is_aoetargeting=", tostring(self_pc:IsAOETargeting()),
					"RMBaction=", actid)
			end
			return _Wilton_Orig_OnRightClick(self_pc, down, ...)
		end
	end
end)

--- 为 PlayerActionPicker 挂载调试 Hook：
-- * DoGetMouseActions：记录本帧计算得到的 LMB / RMB 动作（含动作 ID）。
-- * GetRightClickActions：记录右键动作列表中所有动作的 ID，便于判断是否成功插入 CASTAOE.
AddClassPostConstruct("components/playeractionpicker", function(self)
	local _Wilton_Orig_DoGetMouseActions = self.DoGetMouseActions
	local _Wilton_Orig_GetRightClickActions = self.GetRightClickActions

	if _Wilton_Orig_DoGetMouseActions ~= nil then
		self.DoGetMouseActions = function(self_pap, position, target, spellbook, ...)
			local inst = self_pap.inst
			local inv = inst.replica ~= nil and inst.replica.inventory or nil
			local equipitem = inv ~= nil and inv:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
			local is_wilton_staff = Wilton_IsStaffItem(equipitem)
			local lmb, rmb = _Wilton_Orig_DoGetMouseActions(self_pap, position, target, spellbook, ...)
			if is_wilton_staff then
				local lmbid = (lmb ~= nil and lmb.action ~= nil) and lmb.action.id or "nil"
				local rmbid = (rmb ~= nil and rmb.action ~= nil) and rmb.action.id or "nil"
				local pc = inst.components ~= nil and inst.components.playercontroller or nil
				local isaoe = pc ~= nil and pc:IsAOETargeting() or false

				Wilton_DebugPAP_OnActionChange(self_pap, inst.userid, equipitem.prefab, isaoe, lmbid, rmbid)
			end
			return lmb, rmb
		end
	end

	if _Wilton_Orig_GetRightClickActions ~= nil then
		self.GetRightClickActions = function(self_pap, position, target, spellbook, ...)
			local inst = self_pap.inst
			local inv = inst.replica ~= nil and inst.replica.inventory or nil
			local equipitem = inv ~= nil and inv:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
			local is_wilton_staff = Wilton_IsStaffItem(equipitem)
			local actions = _Wilton_Orig_GetRightClickActions(self_pap, position, target, spellbook, ...)
			if is_wilton_staff then
				local pc = inst.components ~= nil and inst.components.playercontroller or nil
				local isaoe = pc ~= nil and pc:IsAOETargeting() or false
				local ids = {}
				if actions ~= nil then
					for i, v in ipairs(actions) do
						table.insert(ids, v.action ~= nil and v.action.id or "nil")
					end
				end
				local last = self_pap._wilton_staff_debug_last
				if last == nil then
					last = {}
					self_pap._wilton_staff_debug_last = last
				end
				local ids_str = table.concat(ids, ",")
				if last.right_ids ~= ids_str or last.right_isaoe ~= isaoe then
					print("[WILTON_STAFF_DEBUG][PAP.RightClickActions]",
						"userid=", inst.userid or "nil",
						"prefab=", tostring(equipitem.prefab),
						"isaoe=", tostring(isaoe),
						"count=", actions ~= nil and #actions or 0,
						"ids=", ids_str)
					last.right_ids = ids_str
					last.right_isaoe = isaoe
				end
			end
			return actions
		end
	end
end)

--------------------------------------------------------------------------
-- 威尔顿骨杖：服务器动作执行调试 Hook（CASTAOE / CASTSPELL）
-- 说明：
-- * 这里直接包裹全局 ACTIONS 表中的 fn，而不是修改 template/scripts/actions.lua 中的模板拷贝。
-- * 仅在使用带有 "wiltonmod_item" 标签的武器时输出日志，方便在 server_log 中定位实际执行的动作路径.

local _Wilton_Orig_CASTAOE_fn = ACTIONS.CASTAOE.fn
ACTIONS.CASTAOE.fn = function(act, ...)
	local staff = nil
	if act ~= nil then
		if act.invobject ~= nil then
			staff = act.invobject
		elseif act.doer ~= nil and act.doer.components ~= nil and act.doer.components.inventory ~= nil then
			staff = act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		end
	end
	local is_wilton_staff = Wilton_IsStaffItem(staff)
	if is_wilton_staff then
		local act_pos = act ~= nil and act:GetActionPoint() or nil
		local px, py, pz = 0, 0, 0
		if act_pos ~= nil and act_pos.Get ~= nil then
			px, py, pz = act_pos:Get()
		end
		print("[WILTON_STAFF_DEBUG][CASTAOE.fn] begin",
			"prefab=", tostring(staff.prefab),
			"doer=", act.doer ~= nil and act.doer.prefab or "nil",
			"userid=", act.doer ~= nil and act.doer.userid or "nil",
			"x=", tostring(px),
			"z=", tostring(pz))
	end
	if _Wilton_Orig_CASTAOE_fn ~= nil then
		local res, reason = _Wilton_Orig_CASTAOE_fn(act, ...)
		if is_wilton_staff then
			print("[WILTON_STAFF_DEBUG][CASTAOE.fn] end",
				"res=", tostring(res),
				"reason=", tostring(reason))
		end
		return res, reason
	end
end

local _Wilton_Orig_CASTSPELL_fn = ACTIONS.CASTSPELL.fn
ACTIONS.CASTSPELL.fn = function(act, ...)
	local staff = act ~= nil and act.invobject or nil
	local is_wilton_staff = Wilton_IsStaffItem(staff)
	if is_wilton_staff then
		print("[WILTON_STAFF_DEBUG][CASTSPELL.fn] begin",
			"prefab=", tostring(staff.prefab),
			"doer=", act.doer ~= nil and act.doer.prefab or "nil",
			"userid=", act.doer ~= nil and act.doer.userid or "nil")
	end
	if _Wilton_Orig_CASTSPELL_fn ~= nil then
		local res, reason = _Wilton_Orig_CASTSPELL_fn(act, ...)
		if is_wilton_staff then
			print("[WILTON_STAFF_DEBUG][CASTSPELL.fn] end",
				"res=", tostring(res),
				"reason=", tostring(reason))
		end
		return res, reason
	end
end