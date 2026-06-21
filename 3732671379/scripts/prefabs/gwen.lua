
local MakePlayerCharacter = require "prefabs/player_common"
local Gwenagebadge = require("widgets/gwenagebadge")

local GWEN_TRAIL = require "prefabs/gw_trail"

local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset( "ANIM", "anim/Gwen.zip"),
    Asset( "ANIM", "anim/skeletongwwww.zip"),
    Asset( "ANIM", "anim/ghost_gwen_build.zip"),
    Asset( "IMAGE", "images/saveslot_portraits/gwen.tex" ), --存档图片
    Asset( "ATLAS", "images/saveslot_portraits/gwen.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/gwen.tex" ), --单机选人界面
    Asset( "ATLAS", "images/selectscreen_portraits/gwen.xml" ),
	
    Asset( "IMAGE", "images/selectscreen_portraits/gwen_silho.tex" ), --单机未解锁界面
    Asset( "ATLAS", "images/selectscreen_portraits/gwen_silho.xml" ),

    Asset( "IMAGE", "bigportraits/gwen.tex" ), 
    Asset( "ATLAS", "bigportraits/gwen.xml" ),
	
	Asset( "IMAGE", "images/map_icons/gwen.tex" ), --小地图
	Asset( "ATLAS", "images/map_icons/gwen.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_gwen.tex" ), --tab键人物列表显示的头像
    Asset( "ATLAS", "images/avatars/avatar_gwen.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_ghost_gwen.tex" ),--tab键人物列表显示的头像（死亡）
    Asset( "ATLAS", "images/avatars/avatar_ghost_gwen.xml" ),
	
	Asset( "IMAGE", "images/avatars/self_inspect_gwen.tex" ), --人物检查按钮的图片
    Asset( "ATLAS", "images/avatars/self_inspect_gwen.xml" ),
	
	Asset( "IMAGE", "images/names_gwen.tex" ),  --人物名字
    Asset( "ATLAS", "images/names_gwen.xml" ),
}
local prefabs = {}

-- 初始物品
local start_inv = {
	"gwen_beibao",--背包
	"gwen_jiandao", --剪刀
	"gw_gift", --礼包
}
-- 当人物复活的时候
local function onbecamehuman(inst)
	-- 设置人物的移速（1表示1倍于wilson）
	local gw_Level = inst.components.gwen_competence and inst.components.gwen_competence:Get_gwen_Level() or 1
	if gw_Level >= 1 then
		inst.components.locomotor:SetExternalSpeedMultiplier(inst, "gwen_speed_mod", 1.25)
	end
	if gw_Level >= 18 then
		inst.components.locomotor:SetExternalSpeedMultiplier(inst, "gwen_speed_mod", 1.35)
	end

	if inst.gwen_wawa ~= nil then
		inst.gwen_wawa:Remove()
		inst.gwen_wawa = nil
	end
	if inst.fx ~= nil then
		inst.fx:Remove()
		inst.fx = nil
	end
end

local function onbecameghost(inst)--死亡
    -- 当变成鬼魂时移除速度修正
    if inst.components.locomotor then
        inst.components.locomotor:SetExternalSpeedMultiplier(inst, "gwen_speed_mod", .8)
    end
	
	if inst.player_classified  and inst.player_classified.MapExplorer then
		inst.player_classified.MapExplorer:EnableUpdate(true)
	end

    --[[ 在10秒后复活
    inst:DoTaskInTime(30, function()
		inst:PushEvent("respawnfromghost", { source = inst })
    end)]]

	if inst.gwen_wawa == nil then
		inst.gwen_wawa = SpawnPrefab("gwen_wawa")
		inst.gwen_wawa.entity:SetParent(inst.entity)
		inst.gwen_wawa.Transform:SetPosition(0, 0, 0)
		inst.gwen_wawa:SetOwner(inst)
	end

	if inst.fx == nil then
		inst.fx = SpawnPrefab("Gwen")
		inst.fx.entity:SetParent(inst.entity)
		inst.fx.Transform:SetPosition(0, 2, 0)
		inst.fx:AddTag("NOBLOCK")
		inst.fx:AddTag("notarget")
		inst.fx:AddTag("FX")
		inst.fx:AddTag("NOCLICK")
		if inst.fx and inst.fx:IsValid() and inst.fx.components.health then inst.fx.components.health:SetInvincible(true) end 
		inst.fx.AnimState:SetMultColour(1, 1, 1, 0)
		inst.fx:Hide()
		inst.fx:AddTag("gw_wawa")
	end

	if inst.components.gwen_shengai then
		inst.components.gwen_shengai:DoDelta(-inst.components.gwen_shengai.max)
	end
end

local function OnSave(inst, data)
    data.gwen_shengai = inst.gwen_shengai
end

-- 重载游戏或者生成一个玩家的时候
local function onload(inst,data)
    inst:PushEvent("gw_level")

	if data ~= nil then
        if data and data.gwen_shengai ~= nil then
            inst.gwen_shengai = data.gwen_shengai
			inst.components.gwen_shengai.current = inst.gwen_shengai
        end
    end

    inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
    inst:ListenForEvent("ms_becameghost", onbecameghost)

    if inst:HasTag("playerghost") then
        onbecameghost(inst)
    else
        onbecamehuman(inst)
    end

	inst.components.gwen_shengai:DoDelta(0)

	-- local gw_Level = (inst.components.gwen_competence and inst.components.gwen_competence:Get_gwen_Level()) or 1
	-- if gw_Level == 1 then
	-- 	local updater = inst.components.skilltreeupdater
	-- 	updater:SetSkipValidation(true)
	-- 	local activated = updater:GetActivatedSkills()
	-- 	if activated then
	-- 		for skill, _ in pairs(activated) do
	-- 			updater:DeactivateSkill(skill)
	-- 		end
	-- 	end
	-- 	updater:SetSkipValidation(false)
	-- 	SendModRPCToClient(CLIENT_MOD_RPC["gwen_skill"]["removekehu"],inst.userid)
	-- 	inst.components.gwen_competence.level_up_granted = 0
	-- end


	inst:PushEvent("OnGwen_equip")
	inst:PushEvent("OffGwen_equip")
end
local function UpdateWetnessSpeed(inst)
    if inst.components.moisture then
        local wetness = inst.components.moisture:GetMoisture()		
        -- 假设速度属性的名字为 "speed"
        local speedMultiplier = 1 - (0.0075 * wetness)	
		inst.components.locomotor:SetExternalSpeedMultiplier(inst, "jiansu_buff", speedMultiplier)--潮湿减速
		inst.components.health.externalfiredamagemultipliers:SetModifier(inst, 1 + TUNING.ARMORDRAGONFLY_FIRE_RESIST)--火焰伤害翻倍				
    end
end

-- 防止变猴诅咒
local function ongetitem(inst , data)
    if data.item and data.item.prefab == 'cursed_monkey_token' then
        inst.components.cursable:RemoveCurse('MONKEY', 20)
    end
end

local function EquipGwenJiandao(inst)
    if not inst.components.inventory then
        return
    end

    local jiandao

    if inst.jiandao ~= nil then
        -- 查找范围内是否存在标记为"jiandao"的物品
        jiandao = FindEntity(inst, 3000, function(item)
            return item:HasTag("jiandao")
        end)

        -- 如果找到了剪刀，尝试拾取并装备
        if jiandao then
            inst.components.inventory:GiveItem(jiandao)
            inst.components.inventory:Equip(jiandao)
            return  -- 找到并处理了剪刀，结束函数
        end
    end

    -- 如果没有找到剪刀或inst.jiandao是nil，生成新的剪刀
end

local function OnAttackOther(inst, data)
    if data.weapon == nil then  -- 空手攻击
        EquipGwenJiandao(inst)
	else
		local hand_item = inst.components.inventory and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		if hand_item ~= nil and hand_item.prefab == "gwen_jiandao" then
			hand_item.SoundEmitter:PlaySound("Gwen_sound/Gwen_sfx/Gwen_A",nil,.08)----声音平A
		end
    end

	local gw_Level = inst.components.gwen_competence and inst.components.gwen_competence:Get_gwen_Level() or 1
	local cengshu = 4

	-- if gw_Level >= 1 then
	-- 	cengshu = 2
	-- end
	-- if gw_Level >= 8 then
	-- 	cengshu = 3
	-- end
	-- if gw_Level >= 13 then
	-- 	cengshu = 4
	-- end

	if inst:HasTag("gw_cs_2") or inst:HasTag("gw_cs_1") then
        cengshu = cengshu + 1
	end

		local backpack = nil
		if inst.components.inventory then
			local equipslots = inst.components.inventory.equipslots
			if equipslots then
				local back_slot = equipslots[EQUIPSLOTS.BACK]
				if back_slot and back_slot:HasTag("gw_backpack") then
					backpack = back_slot
				else
					local body_slot = equipslots[EQUIPSLOTS.BODY]
					if body_slot and body_slot:HasTag("gw_backpack") then
						backpack = body_slot
					end
				end
			end
		end

    if backpack and backpack.components.container then
        local guajian = backpack.components.container:GetItemInSlot(17)
        if guajian then
            if guajian.prefab == "gw_gj_xingguang1" or guajian.prefab == "gw_gj_xingguang2" then
                cengshu = cengshu + 1
            elseif guajian.prefab == "gw_gj_xingguang3" then
                cengshu = cengshu + 2
            end
        end
    end

	if inst.components.gwen_competence:Get_cengshu() >= cengshu then
		
	else
		inst.components.gwen_competence:Incr_cengshu(1)
	end
end

local function OnHitOther(inst, data)--击中敌人时
--inst.components.health:DoDelta(data.damage*0.03)
    -- 如果 gwen_shengai 小于 最大，则增加 1
	local shengai_current = inst.components.gwen_shengai.current	
    if shengai_current < inst.components.gwen_shengai.max then
		inst.components.gwen_shengai:DoDelta(1)	
    end

	local target = data.target
    if target and target.components.health and not target.components.health:IsDead() then
        -- 获取目标当前的最大生命值
        local currentHealth = target and target.components.health and target.components.health.currenthealth
        -- 计算百分比生命伤害
        local damage = currentHealth * TUNING.BAIFENBISHANGHAI
		target.components.health:DoDelta(-damage, nil, inst.prefab, nil, inst, true)
		if target.components.health and target.components.health:IsDead() then
			inst:PushEvent("killed", { victim = target })
			if target.components.combat ~= nil and target.components.combat.onkilledbyother ~= nil then
				target.components.combat.onkilledbyother(target, inst)		
			end			
		end
	end
    local target = data.target -- 目标
    if target and target:IsValid() and inst.gwen_buff ~= nil then
        -- **造成额外 20 伤害**
		target.components.health:DoDelta(-20, nil, inst.prefab, nil, inst, true)
    end
end

-- 修改格温回血逻辑
local function ModifyPlayerHealing(inst, health_delta, hunger_delta, sanity_delta, food, feeder)
	if inst:HasTag("gwen") then
		-- 如果有格温的标签则不回血
		health_delta = 0
	end
	return health_delta, hunger_delta, sanity_delta
end

--这个函数将在服务器和客户端都会执行
--一般用于添加小地图标签等动画文件或者需要主客机都执行的组件（少数）

local function incrementGwenShengai(inst)
	if not inst:HasTag("playerghost") then
		inst.gwen_shengai = inst.components.gwen_shengai.current
		local shengai_current = inst.components.gwen_shengai.current	
		if not inst:HasTag("gwen_flying") then 
			if shengai_current < inst.components.gwen_shengai.max then
				inst.components.gwen_shengai:DoDelta(1)
				inst.gwen_shengai = inst.components.gwen_shengai.current
				if inst.components.gwen_competence and inst.components.gwen_competence:Get_gwen_Level() >= 18 then
					inst.components.gwen_shengai:DoDelta(1)
					inst.gwen_shengai = inst.components.gwen_shengai.current
				end
			end
		else
			if not (inst.components.skilltreeupdater and inst.components.skilltreeupdater:IsActivated("gwen_fly_radiance_1")) then
				if shengai_current >= 1 then
					inst.components.gwen_shengai:DoDelta(-1)
					inst.gwen_shengai = inst.components.gwen_shengai.current
				end
			end
		end
	end
end

local function startIncrementing(inst)
    -- 每 4 秒调用一次 incrementGwenShengai 函数
    inst:DoPeriodicTask(4, function()
        incrementGwenShengai(inst)
    end)
end

local function ongwen_shengaidelta(inst)
	if not inst:HasTag("playerghost") then
		inst.gwen_shengai = inst.components.gwen_shengai.current
		local shengai_current = inst.components.gwen_shengai.current
		local shengai_max = inst.components.gwen_shengai.max

		if shengai_current >= shengai_max * .8 and inst.components.gwen_competence:Get_gwen_chengfa() >= 1 then
			inst.components.gwen_shengai.current = shengai_max * .8
		end
		if shengai_current >= shengai_max * .6 and inst.components.gwen_competence:Get_gwen_chengfa() >= 2 then
			inst.components.gwen_shengai.current = shengai_max * .6
		end
		if shengai_current >= shengai_max * .4 and inst.components.gwen_competence:Get_gwen_chengfa() >= 3 then
			inst.components.gwen_shengai.current = shengai_max * .4
		end
		if shengai_current >= shengai_max * .2 and inst.components.gwen_competence:Get_gwen_chengfa() >= 4 then
			inst.components.gwen_shengai.current = shengai_max * .2
		end
		inst.gwen_shengai = inst.components.gwen_shengai.current
	end
end

----隐藏外甲
local function OnGwen_equip(inst, data)
	if inst and inst:IsValid()
	and inst.components.gwen_competence and inst.components.gwen_competence:Get_gwen_equip() == 1
	then
		inst.components.gwen_competence:OnGwen_equip()
		inst.AnimState:ClearOverrideSymbol("swap_body")
		inst.AnimState:ClearOverrideSymbol("swap_hat")
		inst.AnimState:ClearOverrideSymbol("swap_body_tall")
		if inst:HasTag("player") then
			inst.AnimState:Show("HEAD")
			inst.AnimState:Hide("HEAD_HAT")
			inst.AnimState:Hide("HEAD_HAT_NOHELM")
			inst.AnimState:Hide("HEAD_HAT_HELM")
		end
		inst.AnimState:ShowSymbol("face")
		inst.AnimState:ShowSymbol("swap_face")
		inst.AnimState:ShowSymbol("beard")
		inst.AnimState:ShowSymbol("cheeks")
	end
end

----显示外甲
local function OffGwen_equip(inst, data)
	if inst and inst:IsValid()
	and inst.components.gwen_competence and inst.components.gwen_competence:Get_gwen_equip() == 0
	and inst ~= nil and inst.components.inventory ~= nil and inst.components.inventory.isopen
	then
		inst.components.gwen_competence:OffGwen_equip()
		local owner = inst and inst.components.inventory
		local armor = owner and owner:GetEquippedItem(EQUIPSLOTS.BODY)
		local ownerhat = owner and owner:GetEquippedItem(EQUIPSLOTS.HEAD)
		if armor ~= nil then
			local container = armor.components.inventoryitem:GetContainer()
			if container ~= nil then
				local slot = armor.components.inventoryitem:GetSlotNum()
				container:GiveItem(armor, slot)
				inst.components.inventory:Equip(armor)
			end
		end
		if ownerhat ~= nil then
			local container = ownerhat.components.inventoryitem:GetContainer()
			if container ~= nil then
				local slot = ownerhat.components.inventoryitem:GetSlotNum()
				container:GiveItem(ownerhat, slot)
				inst.components.inventory:Equip(ownerhat)
			end
		end
	end
end

----降落
local function gw_land(inst, data)
	inst:RemoveTag("gwen_flying")
	if inst.components.drownable then
		inst.components.drownable.enabled = true
	end
	if inst.gwen_fly ~= nil then
		inst.gwen_fly:Remove()
		inst.gwen_fly = nil
	end
	if inst.gwen_fly2 ~= nil then
		inst.gwen_fly2:Remove()
		inst.gwen_fly2 = nil
	end
	if inst.Physics then
		ChangeToCharacterPhysics(inst)
		local x,y,z = inst.Physics:GetMotorVel()
		inst.Physics:SetMotorVelOverride(x, -4 * 32, z)
	end
	if inst.components.locomotor then
		inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "gw_fly")
	end
end

----起飞
local function gw_fly(inst, data)
	if inst and inst:IsValid() then
		if not inst:HasTag("gwen_flying") then 
			if inst.sg 
			and inst.sg:HasState("hit") 
			and not inst.sg:HasStateTag("noouthit") 
			and not inst.sg:HasStateTag("flight")
			and not inst.sg:HasStateTag("attack")
			and inst.components.health and not inst.components.health:IsDead() and not inst:HasTag("playerghost")
			then
				inst.sg:GoToState("gw_fly")
			end
		else
			if inst.sg 
			and inst.sg:HasState("hit") 
			and not inst.sg:HasStateTag("noouthit") 
			and not inst.sg:HasStateTag("flight")
			and not inst.sg:HasStateTag("attack")
			and inst.components.health and not inst.components.health:IsDead() and not inst:HasTag("playerghost")
			then
				if inst.components.rider ~= nil and inst.components.rider:IsRiding() then
					inst.sg:GoToState("idle")
				else
					inst.sg:GoToState("jumpout")
				end
			end
			gw_land(inst, data)
		end
	end
end

----等级
local function gw_level(inst, data)

	local gw_Level = inst.components.gwen_competence and inst.components.gwen_competence:Get_gwen_Level() or 1

	----伤害系数
	if gw_Level >= 1 then
		inst.components.combat.damagemultiplier = 1
		inst.components.gwen_shengai:SetMax(150)
		inst.components.locomotor:SetExternalSpeedMultiplier(inst, "gwen_speed_mod", 1.25)
	end
	
	----伤害系数
	if gw_Level >= 3 then
		inst.components.combat.damagemultiplier = 1.1
	end
	if gw_Level >= 18 then
		inst.components.combat.damagemultiplier = 1.3
	end

	----圣蔼
	if gw_Level >= 9 then 
		inst.components.gwen_shengai:SetMax(200)
	end
	if gw_Level >= 15 then 
		inst.components.gwen_shengai:SetMax(300)
	end

	----移速
	if gw_Level >= 18 then
		inst.components.locomotor:SetExternalSpeedMultiplier(inst, "gwen_speed_mod", 1.35)
	end

end

local function stop_gw_xiufu(inst, data)
	local is_idle = inst and inst.sg and inst.sg:HasStateTag("idle")
	local is_funnyidle = inst and inst.sg and inst.sg:HasStateTag("funnyidle")
	if not is_idle and not is_funnyidle then
		inst:RemoveTag("gw_xiufu")
		if inst.gw_xiufu then
			inst.gw_xiufu:Cancel()
			inst.gw_xiufu = nil
		end
	end
end


local common_postinit = function(inst) 
	-- Minimap icon
	inst.current_UIswitch = net_uint(inst.GUID,"gwen_competence.current_UIswitch")
	inst.currentfeizhen = net_uint(inst.GUID,"gwen_competence.currentfeizhen")
	inst.currentcengshu = net_uint(inst.GUID,"gwen_competence.currentcengshu")
	inst.currentmianxiang = net_uint(inst.GUID,"gwen_competence.currentmianxiang")
	inst.currentVkeepmianxiang = net_uint(inst.GUID,"gwen_competence.currentVkeepmianxiang")
	inst.currentZkeepmianxiang = net_uint(inst.GUID,"gwen_competence.currentZkeepmianxiang")
	inst.currentgwen_chengfa = net_uint(inst.GUID,"gwen_competence.currentgwen_chengfa")
	inst.currentgwen_equip = net_uint(inst.GUID,"gwen_competence.currentgwen_equip")
	
	if not TheNet:IsDedicated() then
		inst.CreateHealthBadge = Gwenagebadge
	end		
	inst.MiniMapEntity:SetIcon( "gwen.tex" )

	GWEN_TRAIL.SetUpSprintTrail(inst, {0.4, 0.1, 0.6, 0})

	inst.AnimState:AddOverrideBuild("gw_emotes")

	inst.customidleanim = "gwen_shear"
end


-- 这里的的函数只在主机执行  一般组件之类的都写在这里
local master_postinit = function(inst)

	-- 人物音效
	inst.soundsname = "wendy"
	inst:AddTag("gwen")	
	--最喜欢的食物  名字 倍率（1.2）
	inst.components.foodaffinity:AddPrefabAffinity("baconeggs", TUNING.AFFINITY_15_CALORIES_HUGE)
	inst.components.foodaffinity:AddPrefabAffinity("gw_dangao", 1.5)
	-- 三维	
	inst.components.health:SetMaxHealth(TUNING.GWEN_HEALTH)
	inst.components.hunger:SetMax(TUNING.GWEN_HUNGER)
	inst.components.sanity:SetMax(TUNING.GWEN_SANITY)

	inst.components.eater.custom_stats_mod_fn = ModifyPlayerHealing	

	-- 饥饿速度
	inst.components.hunger.hungerrate = 0.9 * TUNING.WILSON_HUNGER_RATE


	inst.components.burnable:SetBurnTime(TUNING.WORMWOOD_BURN_TIME)


	-------------------------------------------------------------------------------------------------------
	-- 禁用天数经验
    if inst.xpgeneration_task then
        inst.xpgeneration_task:Cancel()
        inst.xpgeneration_task = nil
    end
    if inst.components.experiencecollector then
        inst:RemoveComponent("experiencecollector")
    end

    -- 等级提升给技能点
    local function GetXPNeededForNextSkillPoint(skilltree)
        local current_xp = skilltree:GetSkillXP()
        local current_points = skilltree:GetPointsForSkillXP(current_xp)
        local totalxp = 0
        for i, threshold in ipairs(TUNING.SKILL_THRESHOLDS) do
            totalxp = totalxp + threshold
            if i > current_points then
                return totalxp - current_xp
            end
        end
        return 0
    end

    local function OnGwenLevelUp(inst)
        local comp = inst.components.gwen_competence
        if comp and comp:GetLevelUpGranted() <= 15 then
            local needed = GetXPNeededForNextSkillPoint(inst.components.skilltreeupdater)
            if needed > 0 then
                inst.components.skilltreeupdater:AddSkillXP(needed)
                comp:IncrLevelUpGranted()
            end
        end
    end



	inst:ListenForEvent("gw_level", OnGwenLevelUp)


	inst:DoPeriodicTask(1, function()
		UpdateWetnessSpeed(inst)
	end)
	inst:AddComponent("gwen_competence")
	inst:AddComponent("gwen_shengai")
	inst.components.gwen_shengai:SetMax(100) --设置最大值100	
	startIncrementing(inst)	
	inst:ListenForEvent("onattackother", OnAttackOther)	
	inst.OnSave = OnSave	
	inst.OnLoad = onload
	inst.OnNewSpawn = onload	
	inst:ListenForEvent("onhitother", OnHitOther)		
	--inst:ListenForEvent("itemget", ongetitem)
	inst:ListenForEvent("gwen_shengaidelta", ongwen_shengaidelta)
	inst:ListenForEvent("equip",OnGwen_equip )
	inst:ListenForEvent("OnGwen_equip",OnGwen_equip )
	inst:ListenForEvent("OffGwen_equip",OffGwen_equip )
	inst:ListenForEvent("gw_fly",gw_fly )
	inst:ListenForEvent("death",gw_land)
	
	inst:ListenForEvent("gw_land",gw_land)

	inst:ListenForEvent("gw_level",gw_level)

	inst:ListenForEvent("newstate",stop_gw_xiufu)


end

----------------------------------------------------------------------
---可销毁变量
local function onhammered(inst, data)
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst:Remove()
end
local function onhit(inst, worker)
    if not inst:HasTag("burnt") and inst.AnimState:AnimDone() then
        inst.AnimState:PlayAnimation("zl")
        inst.AnimState:PushAnimation("dj")
    end
end

STRINGS.NAMES.GWEN_WAWA = "格温娃娃"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GWEN_WAWA = "格温是个娃娃"

local function gwen_wawafn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()

	MakeObstaclePhysics(inst, .3)

	inst.AnimState:SetBank("skeletongwwww")
	inst.AnimState:SetBuild("skeletongwwww")
    inst.AnimState:PlayAnimation("dj",true)

    inst.entity:SetPristine()

	inst:AddTag("animal")
	inst:AddTag("NOBLOCK")
	inst:AddTag("notarget")

	inst.persists = false

    if not TheWorld.ismastersim then
        return inst
    end
	
	if inst._light == nil then
		inst._light = SpawnPrefab("minerhatlight")
		inst._light.Light:SetFalloff(.9)
		inst._light.Light:SetIntensity(.13)
		inst._light.Light:SetRadius(3.64) 
		inst._light.Light:SetColour(30/255, 120/255, 244/255)
		inst._light.entity:SetParent(inst.entity)
	end

    inst:AddComponent("inspectable")

	inst:AddComponent("inventory")

	--[[--可销毁
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)]]
	
	inst.delay_count = 0

	inst.SetOwner = function(self,owner)
		self.owner = owner
		inst.Transform:SetRotation(inst.owner.Transform:GetRotation())
--[[
		inst.task_1 = inst:DoPeriodicTask(1 * FRAMES,function()
			local is_moving = inst.owner and inst.owner.sg and inst.owner.sg:HasStateTag("moving")
			local is_running = inst.owner and inst.owner.sg and inst.owner.sg:HasStateTag("running") ----在跑步
			if inst ~= nil and inst:IsValid() then
				if is_moving or is_running then
					if inst.AnimState:AnimDone() then
						inst.AnimState:PlayAnimation("zl")
						inst.SoundEmitter:PlaySound("Gwen_sound/Gwen_sfx/Gwen_T",nil,1)----声音娃娃跳
					end
				else
					if inst.AnimState:AnimDone() then
						inst.AnimState:PlayAnimation("dj",true)
					end
				end
			end
		end)
]]
		inst.task = inst:DoPeriodicTask(1,function()
			if inst.owner and inst.owner:IsValid() and inst.owner.components.gwen_shengai then
				if inst.owner.components.gwen_shengai.current < inst.owner.components.gwen_shengai.max then
					inst.owner.components.gwen_shengai:DoDelta(1)
					inst.owner.gwen_shengai = inst.owner.components.gwen_shengai.current
				end
				local x,y,z = inst.Transform:GetWorldPosition()
				for k,v in pairs(TheSim:FindEntities(x,y,z,8)) do 
					if v ~= nil and (v:HasTag("player")or v:HasTag("companion")or v:HasTag("abigail")or v:HasTag("glommer")or v:HasTag("chester")or v:HasTag("shadowminion")) then
						if v.components.health and not v.components.health:IsDead() then
							if v.components.sanity and not v:HasTag("playerghost") and v ~= inst.owner.fx and not v:HasTag("gw_wawa") then
								if v.components.sanity:IsInsanityMode() then
									v.components.sanity:DoDelta(.4, true,"debug_key")
									inst.owner.components.gwen_shengai:DoDelta(1)
								end
								if v.components.sanity:IsLunacyMode() then
									v.components.sanity:DoDelta(-.4, true,"debug_key")
									inst.owner.components.gwen_shengai:DoDelta(1)
								end

								--- 娃娃的战斗激励
								if inst.owner and inst.owner.components.skilltreeupdater and inst.owner.components.skilltreeupdater:IsActivated("gwen_wawa_1") then
									if v.components.debuffable then
										v.components.debuffable:AddDebuff("gwen_wawa_buff", "gwen_wawa_buff",{ caster = inst.owner })
									end
								end
							end
						end
					end
				end

			end
		end)



		inst:ListenForEvent("wawa_tiao",function()
			local is_idle = inst.owner and inst.owner.sg and inst.owner.sg:HasStateTag("idle")
			if is_idle then
				inst.AnimState:PlayAnimation("zl")
				inst.AnimState:PushAnimation("dj",true)
				inst.SoundEmitter:PlaySound("Gwen_sound/Gwen_sfx/Gwen_T",nil,1)----声音娃娃跳
			end
		end, inst.owner)

		inst:ListenForEvent("locomote",function()
			if inst.yidong then
				inst.yidong:Cancel()
				inst.yidong = nil
			end

			if inst.AnimState:AnimDone() then
				inst.AnimState:PlayAnimation("zl")
				inst.SoundEmitter:PlaySound("Gwen_sound/Gwen_sfx/Gwen_T",nil,1)----声音娃娃跳
			end
			
			-- 如果玩家在水上移动
			local x, y, z = inst.Transform:GetWorldPosition()
			local is_moving = inst.owner and inst.owner.sg and inst.owner.sg:HasStateTag("moving") ----在移动
			local is_running = inst.owner and inst.owner.sg and inst.owner.sg:HasStateTag("running") ----在跑步
			local local_passable = TheWorld.Map:IsPassableAtPoint(x, 0, z)
			if not local_passable then
				if is_running or is_moving then
					inst.delay_count = inst.delay_count + 1 ----计数器加1
					if inst.delay_count > 6 then ----生成水花(延迟为5)
						SpawnPrefab("weregoose_splash_less" ..tostring(math.random(2))).entity:SetParent(inst.entity)
						inst.delay_count = 0 ----重置计数器
					end
				end
			end

			if inst.yidong == nil then
				inst.yidong = inst:DoTaskInTime(4 * FRAMES,function()
					inst.AnimState:PushAnimation("dj",true)				
				end)
			end
		end, inst.owner)----移动中

	end

	inst:DoPeriodicTask(1 * FRAMES, function()
		if inst.owner == nil or not inst.owner:IsValid() then
			if inst and inst:IsValid() then
				if inst.task then
					inst.task:Cancel()
					inst.task = nil
				end
				inst:Remove()
			end
		else
			if inst.owner and inst.owner:IsValid() then
				if not inst.owner:HasTag("playerghost") then
					if inst.task then
						inst.task:Cancel()
						inst.task = nil
					end
					inst:Remove()
				end
			end
		end
	end)


    return inst
end

----------------------------------------------------------------------
return MakePlayerCharacter("gwen", prefabs, assets, common_postinit, master_postinit, start_inv),
		Prefab("gwen_wawa", gwen_wawafn, assets)
