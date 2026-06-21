GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

----手拿物品类动作----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
AddComponentAction("USEITEM", "inventoryitem", function(inst, doer, target, actions, right)
	----炼金
	if target.prefab == "gwen_jiandao" and target.replica.gwen_equip
	and inst:HasTag("gw_alchemy")
	then
		if (target.replica.gwen_equip:Getgw_Level() == 0 and inst.prefab == "gw_alchemy_1" and target.replica.gwen_equip:Getgw_alchemy() == 0)
		or (target.replica.gwen_equip:Getgw_Level() == 1 and inst.prefab == "gw_alchemy_2" and target.replica.gwen_equip:Getgw_alchemy() ~= 0)
		or (target.replica.gwen_equip:Getgw_Level() == 2 and inst.prefab == "gw_alchemy_3" and target.replica.gwen_equip:Getgw_alchemy() ~= 0)
		or (target.replica.gwen_equip:Getgw_Level() == 3 and inst.prefab == "gw_alchemy_4" and target.replica.gwen_equip:Getgw_alchemy() ~= 0)
		--or (inst.prefab == "gw_alchemy_1" and target.replica.gwen_equip:Getgw_refactor() ~= 0)
		then
			table.insert(actions, ACTIONS.GW_ALCHEMY)
		end
    end
	
	----重构
	if target.prefab == "gwen_jiandao" and target.replica.gwen_equip
	and inst:HasTag("gw_refactor")
	then
		if (target.replica.gwen_equip:Getgw_Level() == 0 and inst.prefab == "gw_refactor_1" and target.replica.gwen_equip:Getgw_refactor() == 0)
		or (target.replica.gwen_equip:Getgw_Level() == 1 and inst.prefab == "gw_refactor_2"	and target.replica.gwen_equip:Getgw_refactor() ~= 0)
		--or (inst.prefab == "gw_refactor_1" and target.replica.gwen_equip:Getgw_alchemy() ~= 0)
		then
			table.insert(actions, ACTIONS.GW_REFACTOR)
		end
    end

    ----背包的重构
    -- if inst and inst:HasTag("gw_refactor") and target and target:HasTag("gw_backpack") and target:HasTag("gw_backpack_swap")
    -- then
    --     if (target.prefab == "gwen_backpack" and inst.prefab == "gw_refactor_1" )
    --         or (target.prefab == "gwen_backpack_1" and inst.prefab == "gw_refactor_2") then
    --         table.insert(actions, ACTIONS.GW_REFACTOR)
    --     end
    -- end

	----棱彩重构
	if target
	and(
	(target.replica.gwen_refactor and target.replica.gwen_refactor:Getgw_Permanent() == 0)
	or(target.prefab == "gwen_jiandao" and target.replica.gwen_equip and target.replica.gwen_equip:Getgw_Level() == 2 and target.replica.gwen_equip:Getgw_refactor() ~= 0)
	)
	and inst.prefab == "gw_refactor_3"
	then
		table.insert(actions, ACTIONS.GW_REFACTOR3)
    end

    ----背包棱彩
    if target and target:HasTag("gw_backpack_swap")
	-- and((target.prefab == "gwen_backpack")
	-- )
	and inst.prefab == "gw_refactor_3"
	then
		table.insert(actions, ACTIONS.GW_REFACTOR3)
    end

	----剪开
    if not target:HasTag("player") and inst.prefab == "gwen_jiandao" then
		table.insert(actions, ACTIONS.GW_CHAIKAI)
    end

	----修理
    if (target.prefab == "gw_tasui" or target.prefab == "gw_sjmz") and inst.prefab == "marble" then
		table.insert(actions, ACTIONS.GW_XIUFU)
    end

	----激活
    if target.prefab == "moonbase" and target.replica.gwen_moon and target.replica.gwen_moon:Getmoon_Level() == 2 and target.replica.gwen_moon:Getmooning() == 0
	and inst.prefab == "opalpreciousgem"
	then
		table.insert(actions, ACTIONS.GW_EXCITE)
    end

	----缝补
    if target:HasTag("gw_fuzhuang")
	and inst.prefab == "gw_repair"
	then
		table.insert(actions, ACTIONS.GW_FENGBU)
    end
end)

----炼金--------------------
GW_ALCHEMY = AddAction("GW_ALCHEMY","炼金",function(act)
	return act.target:gw_alchemy(act.invobject, act.doer, act.target)
end)
GW_ALCHEMY.priority = 99
GW_ALCHEMY.mount_valid = true

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.GW_ALCHEMY, "give")) 
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.GW_ALCHEMY, "give"))


----重构--------------------
GW_REFACTOR = AddAction("GW_REFACTOR","重构",function(act)
	return act.target:gw_refactor(act.invobject, act.doer, act.target)
end)
GW_REFACTOR.priority = 99
GW_REFACTOR.mount_valid = true

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.GW_REFACTOR, "give")) 
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.GW_REFACTOR, "give"))


----棱彩重构--------------------
local GW_REFACTOR3 = GLOBAL.Action({
    priority = 99,
	mount_valid = true
})
GW_REFACTOR3.id = "GW_REFACTOR3"
GW_REFACTOR3.str = "棱彩重构"

GW_REFACTOR3.fn = function(act)
    local target = act.target
    local invobject = act.invobject
    local doer = act.doer

    if not invobject then
        return true
    else
        if target.prefab ~= "gwen_jiandao" and target.components.gwen_refactor then
			target.components.gwen_refactor:Firstgw_Permanent(invobject, target, doer)
		end
		if target.prefab == "gwen_jiandao" and target.components.gwen_equip and target.components.gwen_equip:Getgw_Level() == 2 then
			target:gw_refactor(invobject, doer, target)
		end

        ---背包重构
        if target:HasTag("gw_backpack_swap") and target.components.gwen_equip then
			target:gw_refactor(invobject, doer, target)
		end
		return true
	end
	
end
AddAction(GW_REFACTOR3)

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.GW_REFACTOR3, "give")) 
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.GW_REFACTOR3, "give"))


----剪刀剪开--------------------
local exp = { 5000, 2000, 1000 }
GW_CHAIKAI = AddAction("GW_CHAIKAI","剪刀剪开",function(act)
    local target = act.target
    local invobject = act.invobject
    local doer = act.doer
    if not invobject then
        return true
    else
        if target then
			local can_dismantle, reason = act.invobject.components.gewen_chaijie:CanDismantle(act.target, act.doer)
			if can_dismantle then
				act.invobject.components.gewen_chaijie:Dismantle(act.target, act.doer)
			end

			return can_dismantle, reason
		end
	end
end)
GW_CHAIKAI.priority = 99
GW_CHAIKAI.distance = 3

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(ACTIONS.GW_CHAIKAI, "doshortaction"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(ACTIONS.GW_CHAIKAI, "doshortaction"))



----修理--------------------
GW_XIUFU = AddAction("GW_XIUFU","修理",function(act)
	return act.target:gwxiufu(act.invobject, act.doer, act.target)
end)
GW_XIUFU.priority = 99
GW_XIUFU.mount_valid = true

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(ACTIONS.GW_XIUFU, "doshortaction"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(ACTIONS.GW_XIUFU, "doshortaction"))



----激活--------------------
GW_EXCITE = AddAction("GW_EXCITE","激活",function(act)
    local target = act.target
    local invobject = act.invobject
    local doer = act.doer

    if not invobject then
        return true
    else
        if target.components.gwen_moon then
			target.components.gwen_moon:Start(target, invobject, doer)
			return true
		end
	end
end)
GW_EXCITE.priority = 99
GW_EXCITE.mount_valid = true

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(ACTIONS.GW_EXCITE, "doshortaction"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(ACTIONS.GW_EXCITE, "doshortaction"))


----修理衣服--------------------
GW_FENGBU = AddAction("GW_FENGBU", "缝补",function(act)
    local target = act.target
    local invobject = act.invobject
    local doer = act.doer

    if not invobject then
        return true
    else
		if target.components.armor and target:HasTag("gw_fuzhuang") then			-----对战斗服使用
			local current_condition = target.components.armor.condition or 0
			local max_condition = target.components.armor.maxcondition or 1000
    		local repair_amount = max_condition * 0.5
			local new_condition = math.min(current_condition + repair_amount, max_condition)
			target.components.armor:SetCondition(new_condition)
			act.invobject.components.stackable:Get(1):Remove()
		if act.doer.components.talker then
			act.doer.components.talker:Say("又可以接着战斗啦~！")
		end
		return true
	end

        if target.components.fueled then
			local fuel = target.components.fueled:GetPercent()
			target.components.fueled:SetPercent(math.min(fuel + .5, 1))
			act.invobject.components.stackable:Get(1):Remove()
			if act.doer.components.talker then
				act.doer.components.talker:Say("焕然一新啦~！")
			end
			return true
		end
	end
end)
GW_FENGBU.priority = 99
GW_FENGBU.mount_valid = true

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(ACTIONS.GW_FENGBU, "dolongaction"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(ACTIONS.GW_FENGBU, "dolongaction"))


----装备类----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
AddComponentAction("EQUIPPED", "inventoryitem" , function(inst, doer, target, actions, right)
	if right and target ~= doer and target:HasTag("pickable") 
	and not target:HasTag("flower")
	and target.prefab ~= "atrium_gate"
	and target.prefab ~= "moonbase"
	then
		if inst.prefab == "gwen_jiandao" and inst:HasTag("jiandao") then
			table.insert(actions, ACTIONS.GW_CUT)
		end
	end

	if right and target ~= doer
	and target.prefab == "beefalo"
	and inst.prefab == "gwen_jiandao" and inst:HasTag("jiandao")
	then
		table.insert(actions, ACTIONS.GW_XIUJIAN)
	end
end)

----剪刀裁剪--------------------
GW_CUT = AddAction("GW_CUT", "剪刀裁剪",function(act)
	local owner = act.doer 
	local target = act.target 
	local invobject = act.invobject
	invobject.Gw_Cut(invobject, owner, target)
	return true
end)
GW_CUT.priority = 98
GW_CUT.mount_valid = true
GW_CUT.distance = 2

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.GW_CUT))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.GW_CUT))

----修剪牛毛
GW_XIUJIAN = AddAction("GW_XIUJIAN", "修剪牛毛",function(act)
	local owner = act.doer 
	local target = act.target 
	local invobject = act.invobject
	invobject.Gw_Cut(invobject, owner, target)
	return true
end)
GW_XIUJIAN.priority = 98
GW_XIUJIAN.mount_valid = true
GW_XIUJIAN.distance = 3

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.GW_XIUJIAN))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.GW_XIUJIAN))



----对目标施放类----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
AddComponentAction("SCENE", "health", function(inst, doer, actions, right)
    if right and doer.replica.combat ~= nil
    and doer.replica.inventory:EquipHasTag("jiandao")
	and not inst:HasTag("companion")
	and not inst:HasTag("player")
	and inst ~= doer 
	and (inst.components.health or inst.replica.health)
	and (inst.components.combat or inst.replica.combat)
	and doer.currentfeizhen:value() == 1
    then
		table.insert(actions, ACTIONS.GW_ENEMYSELECT)
    end
end)

----引针簇射--------------------
GW_ENEMYSELECT = AddAction("GW_ENEMYSELECT", "引针簇射",function(act)
    local inst = nil
    if act.doer.components.inventory then
        for key, value in pairs(act.doer.components.inventory.equipslots) do
            if value.components.enemyselectgw then
                inst = value
            end
        end
        if inst ~= nil and inst.summonsfy then
            for index, value in ipairs(inst.summonsfy) do
                if value and value:IsValid() and act.target then
					inst.SoundEmitter:PlaySound("Gwen_sound/Gwen_sfx/Gwen_R",nil,.18)----声音飞针
                    value.components.summon_controllergw:Shoot(act.target)
                    value.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)						
                end
            end
            return true
        end
    end
end)

GW_ENEMYSELECT.distance = 16
GW_ENEMYSELECT.priority = 99

AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.GW_ENEMYSELECT, "doshortaction"))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.GW_ENEMYSELECT,"doshortaction"))



----使用类----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
AddComponentAction("INVENTORY", "inspectable", function(inst, doer, actions, right)
    if (inst.prefab == "sewing_kit" 	----针线包20
	or inst.prefab == "silk"			----蜘蛛丝10
	or inst.prefab == "sewing_tape"		----胶布15
	or inst.prefab == "voidcloth_kit"	----虚空套件150血 /100%san
	or inst.prefab == "lunarplant_kit"	----亮茄套件150血 /100%san
	or inst.prefab == "gw_repair"		----修补套件5圣蔼 25%圣蔼上限
	)
	and doer.prefab == "gwen"
	then
        table.insert(actions, ACTIONS.GW_XIUBU)
    end

    if inst.prefab == "gw_gift" and doer.prefab == "gwen" then
        table.insert(actions, ACTIONS.GW_DAKAI)
    end

    if inst.prefab == "gw_time_0"
	and doer.prefab == "gwen"
	then
        if inst:HasTag("gw_state") then
			table.insert(actions, ACTIONS.GW_SHIFANG)
		else
			table.insert(actions, ACTIONS.GW_CHUCUN)
		end
    end
end)

----缝补--------------------
GW_XIUBU = AddAction("GW_XIUBU", "缝补",function(act)
    local target = act.target or act.doer
	if target ~= nil and act.invobject ~= nil
	and target.prefab == "gwen" and target.components.health and not (target.components.health:IsDead() or target:HasTag("playerghost"))
	and act.doer.prefab == "gwen" and act.doer.components.health and act.doer.components.sanity
	then
		if act.invobject.prefab == "sewing_kit" then
			act.invobject.components.finiteuses:Use(1)
			act.doer.components.health:DeltaPenalty(-0.5)
			act.doer.components.health:DoDelta(20)
		end
		if act.invobject.prefab == "silk" then
			act.invobject.components.stackable:Get(1):Remove()
			act.doer.components.health:DeltaPenalty(-0.5)
			act.doer.components.health:DoDelta(10)
		end
		if act.invobject.prefab == "sewing_tape" then
			act.invobject.components.stackable:Get(1):Remove()
			act.doer.components.health:DeltaPenalty(-0.5)
			act.doer.components.health:DoDelta(15)
		end
		if act.invobject.prefab == "voidcloth_kit" then
			act.invobject.components.stackable:Get(1):Remove()
			act.doer.components.health:DeltaPenalty(-1)
			act.doer.components.health:DoDelta(150)
			act.doer.components.sanity:SetPercent(1)
		end
		if act.invobject.prefab == "lunarplant_kit" then
			act.invobject.components.stackable:Get(1):Remove()
			act.doer.components.health:DeltaPenalty(-1)
			act.doer.components.health:DoDelta(150)
			act.doer.components.sanity:SetPercent(1)
		end
		if act.invobject.prefab == "gw_repair" then
			act.invobject.components.stackable:Get(1):Remove()
			act.doer.components.gwen_shengai:DoDelta(5)
			act.doer.components.gwen_competence:Incr_gwen_chengfa(-1)
		end
		return true
	end
end)

GW_XIUBU.mount_valid = true
GW_XIUBU.priority = 50

AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.GW_XIUBU, "dolongaction"))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.GW_XIUBU,"dolongaction"))


----拆包--------------------
GW_DAKAI = AddAction("GW_DAKAI", "拆包~",function(act)
	local owner = act.doer 
	local invobject = act.invobject
	return invobject.gw_dakai(invobject, owner)
end)

GW_DAKAI.mount_valid = true
GW_DAKAI.priority = 50

AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.GW_DAKAI, "dolongaction"))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.GW_DAKAI,"dolongaction"))


AddComponentPostInit("actionqueuer", function(self)
	if self.AddAction then
        self.AddAction("rightclick", "GW_XIUBU", true)
	end
end)

----储存经验--------------------
GW_CHUCUN = AddAction("GW_CHUCUN", "记录往昔",function(act)
    local target = act.target or act.doer
	if target ~= nil and act.invobject ~= nil
	and target.prefab == "gwen" and target.components.health and not (target.components.health:IsDead() or target:HasTag("playerghost"))
	and act.doer.prefab == "gwen"
	then
		act.invobject.gw_time(act.invobject, act.doer)
		return true
	end
end)

GW_CHUCUN.mount_valid = true
GW_CHUCUN.priority = 50

AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.GW_CHUCUN, "dolongaction"))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.GW_CHUCUN,"dolongaction"))

----施放经验--------------------
GW_SHIFANG = AddAction("GW_SHIFANG", "回忆过往",function(act)
    local target = act.target or act.doer
	if target ~= nil and act.invobject ~= nil
	and target.prefab == "gwen" and target.components.health and not (target.components.health:IsDead() or target:HasTag("playerghost"))
	and act.doer.prefab == "gwen"
	then
		act.invobject.gw_time(act.invobject, act.doer)
		return true
	end
end)

GW_SHIFANG.mount_valid = true
GW_SHIFANG.priority = 50

AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.GW_SHIFANG, "dolongaction"))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.GW_SHIFANG,"dolongaction"))


-------------------------------------------------------------
-----地图传送逻辑

---搜查幽魂
local function CollectAllSouls(player)
    local total_souls = 0
    local soul_items = {}
    
    if not player or not player.components.inventory then
        return total_souls, soul_items
    end
    
    local inventory = player.components.inventory
    
    inventory:ForEachItem(function(item)
        if item.prefab == "gw_soul_ball" then
            local stack_size = item.components.stackable and item.components.stackable:StackSize() or 1
            total_souls = total_souls + stack_size
            table.insert(soul_items, {
                item = item,
                stack_size = stack_size,
                source = "inventory",
                container = nil
            })
        end
    end)

    if inventory.equipslots and inventory.equipslots.HANDS then
        local equipped_item = inventory.equipslots.HANDS
        if equipped_item and equipped_item.prefab == "gw_hundeng" 
           and equipped_item.components.container then
            for i = 1, equipped_item.components.container:GetNumSlots() do
                local item = equipped_item.components.container:GetItemInSlot(i)
                if item and item.prefab == "gw_soul_ball" then
                    local stack_size = item.components.stackable and item.components.stackable:StackSize() or 1
                    total_souls = total_souls + stack_size
                    table.insert(soul_items, {
                        item = item,
                        stack_size = stack_size,
                        source = "equipped_hundeng",
                        container = equipped_item.components.container,
                    })
                end
            end
        end
    end
    
    inventory:ForEachItem(function(item)
        if item and item.prefab == "gw_hundeng" 
           and item.components.container then
            for i = 1, item.components.container:GetNumSlots() do
                local container_item = item.components.container:GetItemInSlot(i)
                if container_item and container_item.prefab == "gw_soul_ball" then
                    local stack_size = container_item.components.stackable and container_item.components.stackable:StackSize() or 1
                    total_souls = total_souls + stack_size
                    table.insert(soul_items, {
                        item = container_item,
                        stack_size = stack_size,
                        source = "inventory_hundeng",
                        container = item.components.container,
                    })
                end
            end
        end
    end)
    
    return total_souls, soul_items
end

local GW_MAPTELEPORT = Action({priority = 99 ,  distance = 9999})
GW_MAPTELEPORT.id = 'GW_MAPTELEPORT'
GW_MAPTELEPORT.str = "魂迁"
GW_MAPTELEPORT.fn = function(act)
    if act == nil or act.doer == nil or act.pos == nil then
        return false
    end
    
    local inventory = act.doer.components.inventory
    if not inventory then
        return false
    end
    
    if not act.doer:HasTag("gw_hunqian") then
        return false
    end


	local player_pos = act.doer:GetPosition()
    local target_pos = act.pos:GetPosition()
    local distance = math.sqrt(
        (player_pos.x - target_pos.x) * (player_pos.x - target_pos.x) + 
        (player_pos.z - target_pos.z) * (player_pos.z - target_pos.z)
    )
    local soul_cost = math.ceil(distance / 100)

	-- local total_souls = 0
    -- local soul_items = {}
    
    -- inventory:ForEachItem(function(item)
    --     if item.prefab == "gw_soul_ball" then
    --         local stack_size = item.components.stackable and item.components.stackable:StackSize() or 1
    --         total_souls = total_souls + stack_size
    --         table.insert(soul_items, {item = item, stack_size = stack_size})
    --     end
    -- end)

    local total_souls, soul_items = CollectAllSouls(act.doer)
    
    if total_souls < soul_cost then
        return false
    end

    -- local remaining_cost = soul_cost
    -- for _, soul_data in ipairs(soul_items) do
    --     if remaining_cost <= 0 then break end
        
    --     local soul_item = soul_data.item
    --     inventory:ConsumeByName(soul_item.prefab, remaining_cost)
    --     remaining_cost = 0
    -- end


    local remaining_cost = soul_cost
    local backpack_soul_items = {}
    local container_soul_items = {}
    for _, soul_data in ipairs(soul_items) do
        if soul_data.source == "inventory" then
            table.insert(backpack_soul_items, soul_data)
        else
            table.insert(container_soul_items, soul_data)
        end
    end

    if #backpack_soul_items > 0 then
        local backpack_total = 0
        for _, soul_data in ipairs(backpack_soul_items) do
            backpack_total = backpack_total + soul_data.stack_size
        end
        
        local consume_from_backpack = math.min(remaining_cost, backpack_total)
        if consume_from_backpack > 0 then
            inventory:ConsumeByName("gw_soul_ball", consume_from_backpack)
            remaining_cost = remaining_cost - consume_from_backpack
        end
    end

    if remaining_cost > 0 and #container_soul_items > 0 then
        for _, soul_data in ipairs(container_soul_items) do
            if remaining_cost <= 0 then break end
            
            if soul_data.item and soul_data.item:IsValid() then
                local available = soul_data.stack_size
                local remove_count = math.min(remaining_cost, available)
                
                if remove_count > 0 then
                    if soul_data.item.components.stackable then
                        if remove_count >= available then
                            soul_data.container:RemoveItem(soul_data.item, true)
                        else
                            soul_data.item.components.stackable:Get(remove_count):Remove()
                        end
                    else
                        soul_data.container:RemoveItem(soul_data.item, true)
                    end
                    remaining_cost = remaining_cost - remove_count
                end
            end
        end
    end

    if TheWorld.Map:IsAboveGroundAtPoint(target_pos.x, 0, target_pos.z) then
        act.doer.Physics:Teleport(target_pos.x, 0, target_pos.z)
		act.doer:SnapCamera()
		act.doer.sg:GoToState("gwen_soul_jump")
        if act.doer and act.doer:HasTag("gw_hunqian") then
			--act.doer:RemoveTag("gw_hunqian")
        end
        return true
    end
end

GW_MAPTELEPORT.map_action = true
GW_MAPTELEPORT.rmb = true
GW_MAPTELEPORT.closes_map = true
AddAction(GW_MAPTELEPORT)

local function gw_playercontroller(self)
    local old_GetMapActions = self.GetMapActions
    function self:GetMapActions(position, maptarget,...)
        local LMBaction, RMBaction = old_GetMapActions(self, position, maptarget,...)
        
        if self.inst:HasTag("gw_hunqian") then
            local act = BufferedAction(self.inst, nil, ACTIONS.GW_MAPTELEPORT)
            RMBaction = self:RemapMapAction(act, position)
            return LMBaction, RMBaction
        end
        
        return LMBaction, RMBaction
    end
    
    local old_OnMapAction = self.OnMapAction
    function self:OnMapAction(actioncode, position, maptarget,...)
        old_OnMapAction(self, actioncode, position, maptarget,...)
        
        local act = MOD_ACTIONS_BY_ACTION_CODE[ACTIONS.GW_MAPTELEPORT.mod_name][actioncode]
        if act == nil or not act.map_action then
            return
        end

        if self.ismastersim then
            local LMBaction, RMBaction = self:GetMapActions(position, maptarget)
            if act.rmb then
                if RMBaction then
                    self.locomotor:PushAction(RMBaction, true)
                end
            end
        elseif self.locomotor == nil and not self.inst.gw_itemmaptp then
            self.inst.gw_itemmaptp = true
            if self.inst.gw_item_task_portal == nil then
                self.inst.gw_item_task_portal = self.inst:DoTaskInTime(9, function()
                    self.inst.gw_itemmaptp = false
                    self.inst.gw_item_task_portal = nil
                end)
            end
            SendRPCToServer(RPC.DoActionOnMap, actioncode, position.x, position.z)
        elseif self:CanLocomote() then
            local _, RMBaction = self:GetMapActions(position, maptarget)
            RMBaction.preview_cb = function()
                SendRPCToServer(RPC.DoActionOnMap, actioncode, position.x, position.z)
            end
            self.locomotor:PreviewAction(RMBaction, true)
        end
    end
end

AddComponentPostInit('playercontroller', gw_playercontroller)
local BLINK_MAP_MUST = {'CLASSIFIED', 'globalmapicon', 'fogrevealer'}
ACTIONS_MAP_REMAP[ACTIONS.GW_MAPTELEPORT.code] = function(act, targetpos)
    local doer = act.doer
    if doer == nil then
        return nil
    end
    
    if not doer:HasTag("gw_hunqian") then
        return nil
    end
    
    if not TheWorld.Map:IsVisualGroundAtPoint(targetpos.x, targetpos.y, targetpos.z) then
        local ents = TheSim:FindEntities(targetpos.x, targetpos.y, targetpos.z, PLAYER_REVEAL_RADIUS * 0.4, BLINK_MAP_MUST)
        local revealer
        local MAX_WALKABLE_PLATFORM_DIAMETERSQ = TUNING.MAX_WALKABLE_PLATFORM_RADIUS * TUNING.MAX_WALKABLE_PLATFORM_RADIUS * 4
        
        for _, v in ipairs(ents) do
            if doer:GetDistanceSqToInst(v) > MAX_WALKABLE_PLATFORM_DIAMETERSQ then
                revealer = v
                break
            end
        end
        
        if revealer == nil then
            return nil
        end
        
        targetpos.x, targetpos.y, targetpos.z = revealer.Transform:GetWorldPosition()
        if revealer._target ~= nil then
            local boat = revealer._target:GetCurrentPlatform()
            if boat == nil then
                return nil
            end
            targetpos.x, targetpos.y, targetpos.z = boat.Transform:GetWorldPosition()
        end
    end
    
    return BufferedAction(doer, nil, ACTIONS.GW_MAPTELEPORT, nil, targetpos)
end

ACTIONS.GW_MAPTELEPORT.stroverridefn = function(act)
    if not act or not act.doer or not act.pos then
        return "魂迁"
    end

    local player_pos = act.doer:GetPosition()
    local target_pos = act.pos:GetPosition()

    local distance = math.ceil(math.sqrt((player_pos.x - target_pos.x) * (player_pos.x - target_pos.x) + (player_pos.z - target_pos.z) * (player_pos.z - target_pos.z)))
    local cost = distance/100

	local display_cost
    if cost <= 1 then
        display_cost = 1
    else
        display_cost = math.ceil(cost)
    end

    return string.format("魂迁 (消耗灵魂: %d)", display_cost)
end


AddStategraphActionHandler('wilson', ActionHandler(ACTIONS.GW_MAPTELEPORT, function(inst, action)
    return "doshortaction"
end))
AddStategraphActionHandler('wilson_client', ActionHandler(ACTIONS.GW_MAPTELEPORT, function(inst, action)
    return "doshortaction"
end))