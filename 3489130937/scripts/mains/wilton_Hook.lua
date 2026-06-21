--- 威尔顿行为 Hook 脚本。
-- 通过对 prefab 与组件的 postinit 改写，调整世界中与威尔顿相关的各种行为（坟墓、骷髅复活、仇恨逻辑等）。
-- 所有改动只在服务端生效，保持联机逻辑一致；本文件不直接处理 UI。

local function HasSkill(inst, name)
    return inst.components.skilltreeupdater and inst.components.skilltreeupdater:IsActivated(name)
end

local function IsWiltonScarecrowSkin(player)
    if player == nil or player.components == nil or player.components.skinner == nil then
        return false
    end

    -- 首选：使用在wiltonmod_skin_api.lua里维护的标记，避免皮肤RPC时序问题
    if player.wilton_is_scarecrow_skin ~= nil then
        return player.wilton_is_scarecrow_skin
    end

    -- 兜底：直接从skinner读取当前皮肤名
    local skinner = player.components.skinner
    local skin_name = skinner.skin_name

    if skin_name == nil and skinner.GetSkinName ~= nil then
        skin_name = skinner:GetSkinName()
    end

    return skin_name == "wiltonmod_scarecrow_none"
end

--- 统一判定：由骷髅兵持有的装备是否应忽略耐久消耗。
-- 条件：
-- * 配置项 "wilton_skeleton_durability" 关闭时，所有骷髅兵装备不掉耐久；
-- * 或者：骷髅兵的领主为威尔顿，且领主学会骷髅巫术2级（wiltonmod_skill2_13）并正在佩戴无名王冠。
local function Wilton_ShouldSkeletonIgnoreDurability(item_inst)
    if item_inst == nil or item_inst.components == nil or item_inst.components.inventoryitem == nil then
        return false
    end

    local owner = item_inst.components.inventoryitem.owner
    if owner == nil or owner.prefab ~= "wiltonmod_pet" then
        return false
    end

    -- 配置项直接关闭骷髅兵耐久消耗：全局生效。
    if not TUNING.WILTON_SKELETON_DURABILITY then
        return true
    end

    -- 技能 + 王冠组合：仅对学习骷髅巫术2级且佩戴无名王冠的威尔顿所召唤的骷髅兵生效。
    local leader = owner.components ~= nil and owner.components.follower ~= nil and owner.components.follower:GetLeader() or nil
    if leader ~= nil and leader.prefab == "wiltonmod" and HasSkill(leader, "wiltonmod_skill2_13") then
        local inv = leader.components ~= nil and leader.components.inventory or nil
        if inv ~= nil then
            local hat = inv:GetEquippedItem(EQUIPSLOTS.HEAD)
            if hat ~= nil and hat.prefab == "wiltonmod_hat" then
                return true
            end
        end
    end

    return false
end

--- 坟墓睡眠回调：玩家在 mound 中睡觉时生成骷髅随从与特效。
-- @param inst EntityScript 坟墓实体
-- @param sleeper EntityScript 进入睡眠的玩家
local function onsleep(inst, sleeper)

    --[[ 
    if target and target.prefab == "mound" then
        inst:Hide()    
        inst.Transform:SetPosition(target.Transform:GetWorldPosition())
    end    
    ]] 
    sleeper.Transform:SetPosition(inst.Transform:GetWorldPosition())

	local skel
	if sleeper and sleeper.prefab == "wiltonmod" and IsWiltonScarecrowSkin(sleeper) then
		-- 使用稻草人皮肤时，墓穴睡眠会在外部生成一个临时稻草人外壳：
		-- * 仅用于表现威尔顿在坟墓中睡觉时的“替身外观”；
		-- * 不参与骨心复活，不应被玩家拆除或点燃；
		-- * 起床时需要自动移除，避免长期残留在场景中。
		skel = SpawnPrefab("scarecrow2")
		if skel ~= nil then
			-- 标记为“坟墓睡眠临时稻草人”，便于 Stategraph 起床阶段精准清理，避免误删真正的复活锚点。
			skel.is_wilton_sleep_scarecrow = true

			-- 墓穴睡眠生成的稻草人只做视觉展示：移除可燃、可传播、可工作与闹鬼交互组件，使其在睡眠期间不可被破坏。
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
		end
	else
		skel = SpawnPrefab("wiltonmod_skeleton")
	end
	if skel ~= nil then
		skel.Transform:SetPosition(sleeper.Transform:GetWorldPosition())
	end

    local fx = SpawnPrefab("chester_transform_fx")
    fx.Transform:SetPosition(sleeper.Transform:GetWorldPosition()) 
end

-- 挖掘坟墓完成后用于随机奖励的掉落表.
-- 键为 prefab 名，值为权重，交给 weighted_random_choice 进行随机选择.
local LOOTS =
{
    nightmarefuel = 1,
    amulet = 1,
    gears = 1,
    redgem = 5,
    bluegem = 5,    
}

--- 尝试在坟墓上生成幽灵.
-- @param inst EntityScript 坟墓或相关实体
-- @param chance number? 生成概率，默认 1 表示必定生成
-- @return boolean 是否成功生成幽灵
local function spawnghost(inst, chance)
    if inst.ghost == nil and math.random() <= (chance or 1) then
        inst.ghost = SpawnPrefab("ghost")
        if inst.ghost ~= nil then
            local x, y, z = inst.Transform:GetWorldPosition()
            inst.ghost.Transform:SetPosition(x - .3, y, z - .3)
            inst:ListenForEvent("onremove", function() inst.ghost = nil end, inst.ghost)
            return true
        end
    end
    return false
end

--- 挖完坟墓后的回调逻辑.
-- 处理理智惩罚、战利品掉落、节日饰品与蝙蝠刷出等效果；如果生成了幽灵则不再掉落其它奖励.
local function onfinishcallback(inst, worker)
    inst.AnimState:PlayAnimation("dug")
    inst:RemoveComponent("workable")

    if worker ~= nil then
        if worker.components.sanity ~= nil and not (worker.prefab == "wiltonmod" and HasSkill(worker, "wiltonmod_skill2_1")) then
            worker.components.sanity:DoDelta(-TUNING.SANITY_SMALL)
        end
        if not spawnghost(inst, inst.ghost_of_a_chance) then
            local item = math.random() < .5 and PickRandomTrinket() or weighted_random_choice(LOOTS) or nil
            if item ~= nil then
                inst.components.lootdropper:SpawnLootPrefab(item)
            end

            if math.random() < TUNING.COOKINGRECIPECARD_GRAVESTONE_CHANCE then
                inst.components.lootdropper:SpawnLootPrefab("cookingrecipecard")
            end

            if math.random() < TUNING.SCRAPBOOK_PAGE_GRAVESTONE_CHANCE then
                inst.components.lootdropper:SpawnLootPrefab("scrapbook_page")
            end

            if IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) then
                local ornament = math.random(NUM_HALLOWEEN_ORNAMENTS * 4)
                if ornament <= NUM_HALLOWEEN_ORNAMENTS then
                    inst.components.lootdropper:SpawnLootPrefab("halloween_ornament_"..tostring(ornament))
                end
                if TheWorld.components.specialeventsetup ~= nil then
                    if math.random() < TheWorld.components.specialeventsetup.halloween_bat_grave_spawn_chance then
                        local num_bats = 3
                        for i = 1, num_bats do
                            inst:DoTaskInTime(0.2 * i + math.random() * 0.3, function()
                                local bat = SpawnPrefab("bat")
                                local pos = FindNearbyLand(inst:GetPosition(), 3)
                                bat.Transform:SetPosition(pos:Get())
                                bat:PushEvent("fly_back")
                            end)
                        end

                        TheWorld.components.specialeventsetup.halloween_bat_grave_spawn_chance = 0
                    else
                        TheWorld.components.specialeventsetup.halloween_bat_grave_spawn_chance = TheWorld.components.specialeventsetup.halloween_bat_grave_spawn_chance + 0.1 + (math.random() * 0.1)
                    end
                end
            end

            -- 20% 概率在挖完坟堆且未生成幽灵时，额外生成一个原版骷髅骨架。
            -- 不替换原有掉落：先按原逻辑完成战利品与节日掉落，再独立判定是否刷出 skeleton。
            if math.random() < 0.2 then
                local x, y, z = inst.Transform:GetWorldPosition()
                local skeleton = SpawnPrefab("skeleton")
                if skeleton ~= nil then
                    skeleton.Transform:SetPosition(x, y, z)
                end
            end
        else
            if IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) then
                inst.components.lootdropper:SpawnLootPrefab("halloween_ornament_1") -- ghost
            end
        end
    end
end


AddPrefabPostInit("mound", function(inst)
    inst:AddTag("tent")

    if not TheWorld.ismastersim then
        return
    end  

    inst:DoPeriodicTask(0.5, function(inst)
        if inst:HasTag(ACTIONS.DIG.id.."_workable") then
            if inst.components.sleepingbag then
                inst:RemoveComponent("sleepingbag")
            end

        elseif not inst:HasTag(ACTIONS.DIG.id.."_workable") and inst.components.sleepingbag == nil then    
            inst:AddComponent("sleepingbag")
            inst.components.sleepingbag.dryingrate = math.max(0, -TUNING.SLEEP_WETNESS_PER_TICK / TUNING.SLEEP_TICK_PERIOD)
            inst.components.sleepingbag.onsleep = onsleep
            inst.components.sleepingbag.health_tick = 0
        end  
    end) 

    inst.components.workable:SetOnFinishCallback(onfinishcallback)

    ----------------------------------------------------------------------
    -- 乱葬岗3级：幽灵作祟坟墓复活其他玩家
    -- 触发条件：
    -- * 世界中至少存在一名活体威尔顿（wiltonmod）且解锁 wiltonmod_skill2_8；
    -- * 作祟者为玩家幽灵（playerghost 标签）；
    -- * 目标坟墓为未被挖开的 mound（仍挂有 workable 组件，且当前无人睡在里面）。
    -- 效果：
    -- * 立即将作祟的幽灵玩家传送到该坟墓位置，并触发标准的 respawnfromghost 复活流程；
    -- * 坟墓动画切换为 dug 并移除 workable，使其表现为“已挖开”，且不会掉落任何战利品；
    -- * 复活完成后，将该玩家的生命值、饥饿值、理智值统一设置为 50%。
    ----------------------------------------------------------------------
    if inst.components.hauntable ~= nil then
        local old_onhaunt = inst.components.hauntable.onhaunt

        inst.components.hauntable:SetOnHauntFn(function(mound_inst, haunter)
            local handled = false

            -- 仅在作祟者为玩家幽灵、坟墓仍可挖掘时尝试触发乱葬岗3级效果。
            if haunter ~= nil
                and haunter:HasTag("playerghost")
                and mound_inst.components ~= nil
                and mound_inst.components.workable ~= nil then

                -- 检查世界中是否存在至少一名活体威尔顿且已解锁乱葬岗3级。
                local has_massgrave3 = false
                for _, player in ipairs(AllPlayers) do
                    if player ~= nil
                        and player.prefab == "wiltonmod"
                        and not player:HasTag("playerghost")
                        and HasSkill(player, "wiltonmod_skill2_8") then
                        has_massgrave3 = true
                        break
                    end
                end

                if has_massgrave3 and not mound_inst:HasTag("hassleeper") then
                    handled = true

                    -- 坟墓开掘表现：切换为 dug 动画并移除 workable，避免掉落战利品。
                    if mound_inst.AnimState ~= nil then
                        mound_inst.AnimState:PlayAnimation("dug")
                    end
                    mound_inst:RemoveComponent("workable")

                    -- 将玩家幽灵传送到坟墓位置，保证后续复活爬出的位置在坟墓处。
                    local x, y, z = mound_inst.Transform:GetWorldPosition()
                    haunter.Transform:SetPosition(x, y, z)

                    -- 在标准复活流程完成后，将三维统一设置为 50%。
                    local function OnMassGrave3Revive(player, data)
                        player:RemoveEventCallback("ms_respawnedfromghost", OnMassGrave3Revive)

                        if player.components ~= nil then
                            if player.components.health ~= nil then
                                player.components.health:SetPercent(0.5, true)
                            end
                            if player.components.hunger ~= nil and not GetGameModeProperty("no_hunger") then
                                player.components.hunger:SetPercent(0.5, true)
                            end
                            if player.components.sanity ~= nil and not GetGameModeProperty("no_sanity") then
                                player.components.sanity:SetPercent(0.5, true)
                            end
                        end
                    end
                    haunter:ListenForEvent("ms_respawnedfromghost", OnMassGrave3Revive)

                    -- 触发标准的幽灵复活事件：
                    -- 这里不指定 source，沿用游戏原生的默认复活流程，
                    -- 仅通过上面的监听在复活完成时修正三维数值。
                    haunter:PushEvent("respawnfromghost")
                end
            end

            if handled then
                -- 乱葬岗3级作祟视为一次成功的作祟，返回 true 以触发幽灵自身的默认消耗与冷却逻辑。
                return true
            elseif old_onhaunt ~= nil then
                -- 未命中乱葬岗3级条件时，回退到原有 OnHaunt 行为，保持与原版兼容。
                return old_onhaunt(mound_inst, haunter)
            end

            return false
        end)
    end
end)  

--------------------------------------------------------------------------
-- 乱葬岗2级：月圆刷新已挖坟包
-- 设计目标：
-- * 仅当世界中存在至少一名已解锁 wiltonmod_skill2_7（乱葬岗2级）的威尔顿时，才在月圆触发；
-- * 每次月圆开始时，扫描所有坟墓实体中的 mound：
--   - 若仍为未挖状态（存在 workable 组件），保持不变；
--   - 若已被挖开（workable 被移除，动画为 dug），则重置为“未挖开的坟包”，并重新挂载挖掘逻辑；
-- * 奖励本身依旧沿用 onfinishcallback 中的随机逻辑，重置后下一次挖掘会重新随机一次战利品。
--------------------------------------------------------------------------
AddPrefabPostInit("world", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    --- 月圆状态变化回调：仅在进入月圆的那一刻执行刷新逻辑。
    -- @param world EntityScript 世界实体（即 inst）
    -- @param isfullmoon boolean 当前是否为月圆
    local function OnFullMoonRefreshMounds(world, isfullmoon)
        if not isfullmoon then
            return
        end

        -- 检查当前世界中是否有至少一名已学会“乱葬岗2级”的威尔顿且存活/在场。
        local has_massgrave2 = false
        for _, player in ipairs(AllPlayers) do
            if player ~= nil
                and player.prefab == "wiltonmod"
                and not player:HasTag("playerghost")
                and HasSkill(player, "wiltonmod_skill2_7") then
                has_massgrave2 = true
                break
            end
        end

        if not has_massgrave2 then
            return
        end

        -- 扫描全图坟墓实体：通过 grave 标签筛选，再按 prefab 精确限定到 mound。
        -- 半径取一个足够覆盖整张地图的值，避免遗漏远处坟墓。
        local mounds = TheSim:FindEntities(0, 0, 0, 9999, { "grave" }, { "INLIMBO" })
        for _, mound in ipairs(mounds) do
            if mound ~= nil
                and mound.prefab == "mound"
                and mound.components ~= nil
                and mound.components.workable == nil then
                -- 条件：已被挖开 -> workable 组件不存在，动画通常为 "dug"。
                -- 重置为“未挖开的坟包”外观，并重新挂载可挖组件与威尔顿自定义掉落逻辑。
                if mound.AnimState ~= nil then
                    mound.AnimState:PlayAnimation("gravedirt")
                end

                local x, y, z = mound.Transform:GetWorldPosition()
                local fx = SpawnPrefab("pandorachest_reset")
                if fx ~= nil then
                    fx.Transform:SetPosition(x, y, z)
                end

                mound:AddComponent("workable")
                mound.components.workable:SetWorkAction(ACTIONS.DIG)
                mound.components.workable:SetWorkLeft(1)
                -- 继续复用本文件中重写后的 onfinishcallback，以保持与普通挖坟一致的奖励/事件逻辑。
                mound.components.workable:SetOnFinishCallback(onfinishcallback)
            end
        end
    end

    inst:WatchWorldState("isfullmoon", OnFullMoonRefreshMounds)
end)

--- 为威尔顿建造的墓碑接入“乱葬岗”技能效果：随机外观 + 随机墓志铭。
-- 说明：
-- * 使用原版 gravestone 预制体，不新增自定义预制。
-- * 仅在由 wiltonmod 且已解锁 wiltonmod_skill2_3（乱葬岗1级）建造时，重新随机 4 种外观与墓志铭。
-- * 世界生成的墓碑与其他角色建造的墓碑不受影响。
AddPrefabPostInit("gravestone", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:ListenForEvent("onbuilt", function(grave, data)
        local builder = data ~= nil and data.builder or nil
        if builder == nil or builder.prefab ~= "wiltonmod" then
            return
        end

        if not HasSkill(builder, "wiltonmod_skill2_3") then
            return
        end

        -- 随机 4 种墓碑外观，并播放放置 + 循环动画。
        grave.random_stone_choice = tostring(math.random(4))
        grave.AnimState:PlayAnimation("grave"..grave.random_stone_choice.."_place")
        grave.AnimState:PushAnimation("grave"..grave.random_stone_choice)

        -- 仅当未设置过自定义墓志铭时，随机一条墓志铭并更新检查描述。
        if grave.setepitaph == nil and grave.components ~= nil and grave.components.inspectable ~= nil then
            local count = #STRINGS.EPITAPHS
            if type(count) == "number" and count > 0 then
                grave._epitaph_index = math.random(count)
                grave.components.inspectable:SetDescription(STRINGS.EPITAPHS[grave._epitaph_index])
            end
        end
    end)
end)

SetSharedLootTable('skeleton_cg',
{
    {'boneshard',      1.00},
    {'boneshard',      1.00},
    {'scrapbook_page', 0.10},
})

--- 限制使用 skeleton_cg 掉落表的骷髅/稻草人等预制在一次掉落中生成的骨头碎片数量。
-- 通过包装 lootdropper 的 DropLoot / SpawnLootPrefab，在单次掉落流程中最多生成 2 个 boneshard。
local function SetupSkeletonBoneshardLimit(inst)
    if inst == nil or inst.components == nil or inst.components.lootdropper == nil then
        return
    end

    local lootdropper = inst.components.lootdropper

    if lootdropper._wilton_boneshard_limited then
        return
    end
    lootdropper._wilton_boneshard_limited = true

    lootdropper._wilton_boneshard_max = 2
    lootdropper._wilton_boneshard_count = 0

    local _OldDropLoot = lootdropper.DropLoot
    local _OldSpawnLootPrefab = lootdropper.SpawnLootPrefab

    function lootdropper:DropLoot(...)
        self._wilton_boneshard_count = 0
        if _OldDropLoot ~= nil then
            return _OldDropLoot(self, ...)
        end
    end

    function lootdropper:SpawnLootPrefab(prefab, ...)
        if prefab == "boneshard" then
            local count = self._wilton_boneshard_count or 0
            local max = self._wilton_boneshard_max or 2
            if count >= max then
                return nil
            end
            self._wilton_boneshard_count = count + 1
        end

        if _OldSpawnLootPrefab ~= nil then
            return _OldSpawnLootPrefab(self, prefab, ...)
        end
        return nil
    end
end

--- 骷髅复活为骷髅宠物.
-- @param inst EntityScript 原始骷髅实体（场景骷髅或玩家尸骨）
-- @param player EntityScript 执行复活的威尔顿玩家
local function Skel_Respawn(inst, player)
	local pet = SpawnPrefab("wiltonmod_pet")
	inst:Remove() 

	local x, y, z = inst.Transform:GetWorldPosition()
	pet.sg:GoToState("spawn")
	pet.Transform:SetPosition(x, y, z)

	-- 骷髅宠物的初始外观不再由人物皮肤或骷髅外观决定，
	-- 默认生成普通骷髅宠物；仅在外部显式指定时（如使用“稻草之心”或原骨架本身为稻草人）才启用稻草人形态。
	local use_scarecrow_pet = false
	if pet.SetPetScarecrow ~= nil then
		-- 优先：显式标记的稻草宠物生成（例如使用稻草之心骨心）。
		if inst.is_scarecrow_pet_spawn == true then
			use_scarecrow_pet = true
		-- 其余情况：如果原始骨架本身是稻草人（scarecrow2）或带有 wiltonmod_scarecrow 标签，则继承稻草人外观。
		elseif inst.prefab == "scarecrow2" or inst:HasTag("wiltonmod_scarecrow") then
			use_scarecrow_pet = true
		end
	end

	if use_scarecrow_pet then
		pet:SetPetScarecrow(true)
	end

	if player and player.components.leader and player.components.leader:CountFollowers("wiltonmod_pet") < TUNING.WILTON_SKELETON_COUNT
	and player:HasTag("wiltonmod") then
		player.components.leader:AddFollower(pet)
	end   
end

--- 判断骷髅是否接受玩家给出的物品.
-- 这里只接受带有骨心标签的物品（包括骨心皮肤），用于触发骷髅复活.
local function CanTakeItem(inst, ammo, giver)
    return ammo ~= nil and ammo:HasTag("wiltonmod_boneheart") and giver --and giver:HasTag("wiltonmod")
end

--- 骷髅从玩家手中接到物品时的回调.
-- 若为骨心，则调用 Skel_Respawn 生成骷髅宠物.
local function OnGetItemFromPlayer(inst, giver, item)  
    if item and item:HasTag("wiltonmod_boneheart") and giver then  --and giver:HasTag("wiltonmod")
        -- 通过骨心皮肤区分生成的宠物外观：
        -- * wiltonmod_boneheart       -> 普通骷髅宠物
        -- * wiltonmod_boneheart_skin -> 稻草人骷髅宠物（稻草之心）
        inst.is_scarecrow_pet_spawn = (item.prefab == "wiltonmod_boneheart_skin")

        Skel_Respawn(inst, giver)   
    end      
end

AddPrefabPostInit("skeleton", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst.Skel_Respawn = Skel_Respawn  

    inst:AddComponent("trader")
    inst.components.trader.deleteitemonaccept = true
    inst.components.trader:SetAcceptTest(CanTakeItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer

    inst.components.lootdropper:SetChanceLootTable('skeleton_cg')

    -- 对骷髅骨架的掉落做统一限制：一次掉落中最多生成 2 个 boneshard。
    SetupSkeletonBoneshardLimit(inst)

    -- 如果是通过骷髅配方建造出来的，并且建造时选择了自定义的“稻草人”皮肤，
    -- 就在 onbuilt 阶段把 skeleton 换成 scarecrow2，仅更换外观，不改后续功能（掉落、复活等仍走 scarecrow2/Skel_Respawn 体系）。
    inst:ListenForEvent("onbuilt", function(s, data)
        if data ~= nil and data.builder ~= nil and data.builder.prefab == "wiltonmod" then
            -- _wilton_skeleton_skin 记录在 builder 组件上，不是在玩家实体本身上，这里需要从组件上读取。
            local skin = data.builder.components.builder and data.builder.components.builder._wilton_skeleton_skin
            if data.builder.components.builder then
                data.builder.components.builder._wilton_skeleton_skin = nil
            end
            if skin == "scarecrow2" then
                local x, y, z = s.Transform:GetWorldPosition()
                local new = SpawnPrefab("scarecrow2")
                if new ~= nil then
                    new.Transform:SetPosition(x, y, z)
                    -- 触发 scarecrow2 自身在 wilton_Hook.lua 里的 onbuilt 监听，添加标签与掉落表等逻辑。
                    new:PushEvent("onbuilt", { builder = data.builder, pos = Vector3(x, y, z) })
                end
                s:Remove()
            end
        end
    end)
end)  

AddPrefabPostInit("skeleton_player", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst.Skel_Respawn = Skel_Respawn  

    inst:AddComponent("trader")
    inst.components.trader.deleteitemonaccept = true
    inst.components.trader:SetAcceptTest(CanTakeItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer

    inst.components.lootdropper:SetChanceLootTable('skeleton_cg')

    -- 玩家骷髅同样接入 boneshard 掉落上限控制，保证与场景骷髅一致。
    SetupSkeletonBoneshardLimit(inst)
end) 

AddPrefabPostInit("scarecrow", function(inst)
	if not TheWorld.ismastersim then
		return
	end

	inst.Skel_Respawn = Skel_Respawn

	if inst.components.trader == nil then
		inst:AddComponent("trader")
	end

	local old_test = inst.components.trader.test
	inst.components.trader.deleteitemonaccept = true
	inst.components.trader:SetAcceptTest(function(s, ammo, giver)
		-- 原版稻草人仅在具有可复活标记时才接受骨心，避免普通稻草人建筑被当作复活锚点。
		if s.wilton_bone_revive and CanTakeItem(s, ammo, giver) then
			return true
		end
		if old_test ~= nil then
			return old_test(s, ammo, giver)
		end
		return false
	end)

	local old_accept = inst.components.trader.onaccept
	inst.components.trader.onaccept = function(s, giver, item)
		if s.wilton_bone_revive and item and item:HasTag("wiltonmod_boneheart") and giver then
			OnGetItemFromPlayer(s, giver, item)
			return
		end
		if old_accept ~= nil then
			return old_accept(s, giver, item)
		end
	end

	-- 使用 skeleton_cg 掉落表的稻草人，同样限制骨头碎片的最大掉落数量。
	SetupSkeletonBoneshardLimit(inst)

	inst:ListenForEvent("onbuilt", function(s, data)
		if data ~= nil and data.builder ~= nil and data.builder.prefab == "wiltonmod" then
			s:AddTag("wiltonmod_scarecrow")
			if s.components.lootdropper ~= nil then
				s.components.lootdropper:SetChanceLootTable('skeleton_cg')
			end
		end
	end)
end)

AddPrefabPostInit("scarecrow2", function(inst)
	if not TheWorld.ismastersim then
		return
	end

	inst.Skel_Respawn = Skel_Respawn

	if inst.components.trader == nil then
		inst:AddComponent("trader")
	end

	local old_test = inst.components.trader.test
	inst.components.trader.deleteitemonaccept = true
	inst.components.trader:SetAcceptTest(function(s, ammo, giver)
		-- 只允许带有可复活标记的 scarecrow2 接受骨心，确保仅真正的“复活稻草人”可被骨心复活。
		if s.wilton_bone_revive and CanTakeItem(s, ammo, giver) then
			return true
		end
		if old_test ~= nil then
			return old_test(s, ammo, giver)
		end
		return false
	end)

	local old_accept = inst.components.trader.onaccept
	inst.components.trader.onaccept = function(s, giver, item)
		if s.wilton_bone_revive and item and item:HasTag("wiltonmod_boneheart") and giver then
			OnGetItemFromPlayer(s, giver, item)
			return
		end
		if old_accept ~= nil then
			return old_accept(s, giver, item)
		end
	end

	inst:ListenForEvent("onbuilt", function(s, data)
		if data ~= nil and data.builder ~= nil and data.builder.prefab == "wiltonmod" then
			-- 威尔顿通过“骷髅骨架”配方并选择稻草人皮肤建造出来的 scarecrow2：
			-- * 需要同时作为骷髅宠物的复活锚点，因此这里同时打上外观标记与可复活标记；
			-- * 仅这类稻草人（以及骷髅宠物死亡掉落的稻草人）会在交易逻辑中视作“可被骨心复活”。
			s:AddTag("wiltonmod_scarecrow")
			s.wilton_bone_revive = true
			if s.components.lootdropper ~= nil then
				s.components.lootdropper:SetChanceLootTable('skeleton_cg')
			end
		end
	end)
end)

local function MakeTeam(inst, attacker)
	local leader = SpawnPrefab("teamleader")
	leader:AddTag("penguin")
	local teamleader = leader.components.teamleader
	teamleader.threat = attacker
	teamleader.radius = 10
	teamleader:SetAttackGrpSize(5+math.random(1,3))
	teamleader.timebetweenattacks = 0  -- first attack happens immediately
	teamleader.attackinterval = 2  -- first attack happens immediately
	teamleader.maxchasetime = 10
	teamleader.min_team_size = 0
	teamleader.max_team_size = 8
	teamleader.team_type = inst.components.teamattacker.team_type
	teamleader:NewTeammate(inst)
	teamleader:BroadcastDistress(inst)
end

local RETARGET_MUTATED_MUST_TAGS = { "_combat" }
local RETARGET_MUTATED_CANT_TAGS = { "penguin", "wiltonmod", "wiltonmod_pet" }
local RETARGET_MUTATED_ONEOF_TAGS = {"character","monster","smallcreature","animal","wall"}
local function MutatedRetarget(inst)
    local newtarget = FindEntity(inst, 4, function(guy)
            return inst.components.combat:CanTarget(guy)
            end,
            RETARGET_MUTATED_MUST_TAGS,
            RETARGET_MUTATED_CANT_TAGS,
            RETARGET_MUTATED_ONEOF_TAGS
            )

    local teamattacker = inst.components.teamattacker
    if newtarget and teamattacker and not teamattacker.inteam and not teamattacker:SearchForTeam() then
        MakeTeam(inst, newtarget)
    end

    if teamattacker.inteam and not teamattacker.teamleader:CanAttack() then
        return newtarget
    end
end

AddPrefabPostInit("mutated_penguin", function(inst)
    if not TheWorld.ismastersim then
        return
    end  

    inst.components.combat:SetRetargetFunction(2, MutatedRetarget)
end) 

local function vine_addcoldness(vine, ...)
    local inst = vine.parentplant
    if inst ~= nil and inst:IsValid() then
        inst.components.freezable:AddColdness(...)
        return true
    end
    return false
end

local PLANT_MUST = {"lunarthrall_plant"}
local TARGET_MUST_TAGS = { "_combat", "character" }
local TARGET_CANT_TAGS = { "INLIMBO","lunarthrall_plant", "lunarthrall_plant_end" }  --, "wiltonmod", "wiltonmod_pet"
local function Retarget(inst)
    --print("RETARGET")
    if not inst.no_targeting then
        local target = FindEntity(
            inst,
            TUNING.LUNARTHRALL_PLANT_RANGE,
            function(guy)
                local total = 0
                local x,y,z = inst.Transform:GetWorldPosition()

                if inst.tired then
                    return nil
                end

                local plants = TheSim:FindEntities(x,y,z, 15, PLANT_MUST)
                for i, plant in ipairs(plants)do
                    if plant ~= inst then
                        if plant.components.combat.target and plant.components.combat.target == guy then
                            total = total +1
                        end
                    end
                end
                if total < 3 then
                    return inst.components.combat:CanTarget(guy) and (not guy:HasTag("wiltonmod") or ((guy:HasTag("wiltonmod") or guy:HasTag("wiltonmod_pet")) and inst.atked_table[guy])) 
                end
            end,
            TARGET_MUST_TAGS,
            TARGET_CANT_TAGS
        )

        if inst.vinelimit > 0 then
            if target and ( not inst.components.freezable or not inst.components.freezable:IsFrozen()) then

                local pos = inst:GetPosition()

                local theta = math.random()*TWOPI
                local radius = TUNING.LUNARTHRALL_PLANT_MOVEDIST
                local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
                pos = pos + offset

                if TheWorld.Map:IsVisualGroundAtPoint(pos.x,pos.y,pos.z) then

                    local vine = SpawnPrefab("lunarthrall_plant_vine_end")
                    vine.Transform:SetPosition(pos.x,pos.y,pos.z)
                    vine.Transform:SetRotation(inst:GetAngleToPoint(pos.x, pos.y, pos.z))
                    vine.components.freezable:SetRedirectFn(vine_addcoldness)
                    vine.sg:RemoveStateTag("nub")
                    if inst.tintcolor then
                        vine.AnimState:SetMultColour(inst.tintcolor, inst.tintcolor, inst.tintcolor, 1)
                        vine.tintcolor = inst.tintcolor
                    end

                    inst.components.colouradder:AttachChild(vine)

                    vine.parentplant = inst
                    table.insert(inst.vines,vine)
                    inst.vinelimit = inst.vinelimit -1
                    inst:DoTaskInTime(0,function() vine:ChooseAction() end)

                    return target
                end
            end
        end
    end
end

AddPrefabPostInit("lunarthrall_plant", function(inst)
    if not TheWorld.ismastersim then
        return
    end  

    inst.components.combat:SetRetargetFunction(1, Retarget)

    inst.atked_table = {}
    inst:ListenForEvent("attacked", function(inst, data)
        if data and data.attacker and (data.attacker:HasTag("wiltonmod") or data.attacker:HasTag("wiltonmod_pet")) then
            inst.atked_table[data.attacker] = true
        end    
    end)  

    --inst:ListenForEvent("attacked",OnAttacked)
end) 

AddPrefabPostInit("ghost", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst.atked_table = {}
    inst:ListenForEvent("attacked", function(inst, data)
        if data and data.attacker and data.attacker:HasTag("wiltonmod") then
            inst.atked_table[data.attacker] = true
        end    
    end)     

    local old_auratest = inst.components.aura.auratestfn
    inst.components.aura.auratestfn = function(inst, target)
        if target:HasTag("wiltonmod") and not inst.atked_table[target] then
            return false
        end
        return old_auratest(inst, target)
    end
end)

local function onnear(inst, target)
    if target and (target:HasTag("wiltonmod") or target:HasTag("wiltonmod_pet")) then
        return
    end    

    local target_skilltreeupdater = (target and target.components.skilltreeupdater)
    local childspawner = inst.components.childspawner

    -- Some player skills can prevent killer bees from spawning just as the player walks by.
    if childspawner and not (target_skilltreeupdater and target_skilltreeupdater:IsActivated("wormwood_bugs")) then
        childspawner:ReleaseAllChildren(target, "killerbee")
    end
end

AddPrefabPostInit("wasphive", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst.components.playerprox:SetOnPlayerNear(onnear)
end)

AddPrefabPostInit("boneshard", function(inst)
    if not TheWorld.ismastersim then
        return
    end  

    if inst.components.tradable == nil then
        inst:AddComponent("tradable")
    end
end)    

AddPrefabPostInit("nightmarefuel", function(inst)
    if not TheWorld.ismastersim then
        return
    end  

    if inst.components.tradable == nil then
        inst:AddComponent("tradable")
    end
end)  

AddPrefabPostInitAny(function(inst)
    if not TheWorld.ismastersim then
        return
    end

    if inst.components.equippable and inst.components.tradable == nil then
        inst:AddComponent("tradable")
    end
end)    

local function OnDeath(inst)
	if inst.prefab ~= "wiltonmod" then
		-- 是否在非威尔顿玩家死亡时掉落人肉，由模组配置项 "wilton_drop_humanmeat"（TUNING.WILTON_DROP_HUMANMEAT）统一控制。
		if TUNING.WILTON_DROP_HUMANMEAT then
			local x, y, z = inst.Transform:GetWorldPosition()
			for i = 1, 2 do
				local meat = SpawnPrefab("humanmeat")
				meat.Transform:SetPosition(x, 1.5, z)
			end
		end
		return
	end

	-- 仅当威尔顿使用“复活稻草人”皮肤时，将死亡后生成的玩家尸骨替换为稻草人骨架（scarecrow2），方便后续用骨心复活为对应皮肤的随从。
	if not IsWiltonScarecrowSkin(inst) then
		return
	end

	inst:DoTaskInTime(0, function(player)
		if player == nil or not player:IsValid() then
			return
		end

		local skeleton = FindEntity(player, 2, function(ent)
			return ent.prefab == "skeleton_player"
		end, nil, { "INLIMBO" })

		if skeleton ~= nil and skeleton:IsValid() then
			local sx, sy, sz = skeleton.Transform:GetWorldPosition()
			local scarecrow = SpawnPrefab("scarecrow2")
			if scarecrow ~= nil then
				scarecrow.Transform:SetPosition(sx, sy, sz)
				scarecrow:AddTag("wiltonmod_scarecrow")
				-- 威尔顿死亡后生成的稻草人同样作为“复活稻草人”锚点：允许被骨心交易并触发骷髅宠物复活。
				scarecrow.wilton_bone_revive = true
				-- 使用“复活稻草人”皮肤死亡生成的稻草人：只作为复活锚点，不允许被燃烧或拆除。
				if scarecrow.components.burnable ~= nil then
					scarecrow:RemoveComponent("burnable")
				end
				if scarecrow.components.propagator ~= nil then
					scarecrow:RemoveComponent("propagator")
				end
				if scarecrow.components.workable ~= nil then
					scarecrow:RemoveComponent("workable")
				end
				if scarecrow.components.hauntable ~= nil then
					scarecrow:RemoveComponent("hauntable")
				end
				if scarecrow.components.lootdropper ~= nil then
					scarecrow.components.lootdropper:SetChanceLootTable('skeleton_cg')
				end
			end
			skeleton:Remove()
		end
	end)
end

local function Respawn(inst, data)
	if data and data.source and data.source:HasTag("wiltonmod_boneheart") then
		--print("骨头复活")
		data.source:Remove()
	end    
end

local function DoSave(inst, giver, item)
    item:PushEvent("usereviver", { user = giver })
    giver.hasRevivedPlayer = true
    AwardPlayerAchievement("hasrevivedplayer", giver)
    item:Remove()
    inst:PushEvent("respawnfromghost", { source = item, user = giver })
    giver.components.sanity:DoDelta(TUNING.REVIVE_OTHER_SANITY_BONUS)
end

AddPlayerPostInit(function(inst)
    if not TheWorld.ismastersim then
        return inst
    end

    inst:ListenForEvent("death", OnDeath)
    inst:ListenForEvent("respawnfromghost", Respawn)
    --inst:ListenForEvent("ms_respawnedfromghost", Respawned)  --ThePlayer.components.health:Kill()

    local OldTraderTest = inst.components.trader.test
    inst.components.trader:SetAcceptTest(function(inst, item, ...)
        if inst:HasTag("playerghost") and item ~= nil and item:HasTag("wiltonmod_boneheart") and inst:IsOnPassablePoint() then
            return true
        end 
        if OldTraderTest ~= nil then
            return OldTraderTest(inst, item, ...)
        end
    end)

    local OldOnAccept = inst.components.trader.onaccept
    inst.components.trader:SetOnAccept(function(inst, giver, item, ...)
        if item ~= nil and item:HasTag("wiltonmod_boneheart") and inst:HasTag("playerghost") then
            DoSave(inst, giver, item)
            return
        end

        if OldOnAccept ~= nil then
            return OldOnAccept(inst, giver, item, ...)
        end
    end)

    inst:ListenForEvent("dropitem", function(inst, data)
        if data and data.item and data.item.prefab == "wiltonmod_pet" then
        if inst:HasTag("wiltonmod") and inst.components.leader:CountFollowers("wiltonmod_pet") < TUNING.WILTON_SKELETON_COUNT then
            inst.components.leader:AddFollower(data.item)
        end    
        end
    end)    
end)    

AddComponentPostInit("healer", function(self)
    local OldHeal = self.Heal
    function self:Heal(target, doer, ...)
        if TUNING.WILTON_DISABLE_HEAL
            and target
            and (target:HasTag("wiltonmod") or target:HasTag("wiltonmod_pet"))
            and self.inst
            and self.inst.prefab ~= "wiltonmod_bonepaste" then
            return false
        else
            return OldHeal(self, target, doer, ...)    
        end
    end   
end)

AddComponentPostInit("perishable", function(self)
    local OldPerish = self.Perish
    function self:Perish(...)
        if self.inst and self.inst.components.edible and self.inst.components.edible.foodtype == FOODTYPE.MEAT
        and self.inst.components.inventoryitem ~= nil and self.inst.components.inventoryitem.owner and self.inst.components.inventoryitem.owner.prefab == "wiltonmod_chest" then
            self.onperishreplacement = "boneshard"   
        end
        return OldPerish(self, ...) 
    end  

    -- 为骷髅宠物持有的“新鲜度装备”提供与无限耐久一致的效果：
    -- 当 Wilton_ShouldSkeletonIgnoreDurability 判断该物品应忽略耐久时，
    -- 若该物品同时具有 equippable 组件（视为装备），则通过将本地腐烂倍率
    -- localPerishMultiplyer 置为 0 来冻结新鲜度；条件不再满足时恢复原倍率，
    -- 以免影响后续被其他角色使用时的正常腐烂速度。
    if self.inst ~= nil then
        local function _Wilton_UpdatePetPerish(inst)
            local comp = inst.components ~= nil and inst.components.perishable or nil
            if comp ~= self then
                return
            end

            -- 仅对“新鲜度装备”处理：必须同时具有 perishable 与 equippable 组件，且当前处于已装备状态。
            if inst.components == nil or inst.components.equippable == nil or not inst.components.equippable:IsEquipped() then
                return
            end

            local should_freeze = Wilton_ShouldSkeletonIgnoreDurability(inst)

            if should_freeze then
                if comp._wilton_orig_localmult == nil and comp.GetLocalMultiplier ~= nil then
                    comp._wilton_orig_localmult = comp:GetLocalMultiplier()
                end

                if comp.SetLocalMultiplier ~= nil then
                    -- 冻结腐烂：将本地倍率设为 0，使 Update 中的衰减项为 0。
                    comp:SetLocalMultiplier(0)
                end
            else
                -- 条件不再满足时，恢复原本记录的本地倍率，避免永久修改其它物品行为。
                if comp._wilton_orig_localmult ~= nil and comp.SetLocalMultiplier ~= nil then
                    comp:SetLocalMultiplier(comp._wilton_orig_localmult)
                    comp._wilton_orig_localmult = nil
                end
            end
        end

        -- 为避免组件添加顺序差异导致部分装备（如 hambat）未能注册刷新任务，这里始终启动周期检查，
        -- 在回调内部再通过是否具备 equippable 组件及是否已装备进行快速过滤。
        self.inst:DoPeriodicTask(2, _Wilton_UpdatePetPerish)
        -- 初次创建时立即同步一次状态，避免在下一次 tick 前发生腐烂。
        _Wilton_UpdatePetPerish(self.inst)
    end
end)

--- 护甲耐久 Hook：当佩戴者为骷髅宠物且配置关闭“消耗耐久”时，不再扣减护甲耐久。
-- 通过组件层统一拦截，避免逐个物品修改，保证联机逻辑一致。
AddComponentPostInit("armor", function(self)
    local OldTakeDamage = self.TakeDamage
    function self:TakeDamage(damage, attacker, ...)
        if self.inst ~= nil and Wilton_ShouldSkeletonIgnoreDurability(self.inst) then
            return
        end

        if OldTakeDamage ~= nil then
            return OldTakeDamage(self, damage, attacker, ...)
        end
    end
end)

--- 合成 Hook：允许稻草心皮肤作为骨杖配方所需的骨心材料.
-- 当配方为 wiltonmod_staff1 且玩家背包中普通骨心不足时，优先在调用原始
-- MakeRecipeFromMenu 之前，将部分 `wiltonmod_boneheart_skin` 转换为同等数量的
-- `wiltonmod_boneheart`，这样后续的 HasIngredients/GetIngredients/RemoveIngredients
-- 都可以沿用游戏原生逻辑，避免改动底层配方与组件实现。
AddComponentPostInit("builder", function(self)
    local OldHasIngredients = self.HasIngredients
    function self:HasIngredients(recipe)
        -- 服务端材料判定 Hook：让骨杖配方把稻草心皮肤也视作骨心材料，并在真正需要时把一部分皮肤骨心转换成普通骨心。
        local rec = recipe
        if type(rec) == "string" then
            rec = GetValidRecipe(rec)
        end

        if rec ~= nil and rec.name == "wiltonmod_staff1" then
            if self.freebuildmode then
                return true
            end

            -- 先按原版逻辑检查除骨心之外的所有材料与人物/科技消耗，避免误判。
            if rec.ingredients ~= nil then
                for _, v in ipairs(rec.ingredients) do
                    if v.type ~= "wiltonmod_boneheart" then
                        if not self.inst.components.inventory:Has(v.type, math.max(1, RoundBiasedUp(v.amount * self.ingredientmod)), true) then
                            return false
                        end
                    end
                end
            end

            if rec.character_ingredients ~= nil then
                for _, v in ipairs(rec.character_ingredients) do
                    if not self:HasCharacterIngredient(v) then
                        return false
                    end
                end
            end

            if rec.tech_ingredients ~= nil then
                for _, v in ipairs(rec.tech_ingredients) do
                    if not self:HasTechIngredient(v) then
                        return false
                    end
                end
            end

            local inv = self.inst.components ~= nil and self.inst.components.inventory or nil
            if inv == nil then
                return false
            end

            local need = 0
            if rec.ingredients ~= nil then
                for _, v in ipairs(rec.ingredients) do
                    if v.type == "wiltonmod_boneheart" then
                        need = math.max(1, RoundBiasedUp(v.amount * self.ingredientmod))
                        break
                    end
                end
            end

            if need > 0 then
                local has, num = inv:Has("wiltonmod_boneheart", need, true)
                if not has then
                    local deficit = need - (num or 0)
                    if deficit > 0 then
                        local skins = inv:FindItems(function(item)
                            return item.prefab == "wiltonmod_boneheart_skin"
                        end)

                        if skins ~= nil and #skins > 0 then
                            local total_skin = 0
                            for _, item in ipairs(skins) do
                                if item.components ~= nil and item.components.stackable ~= nil then
                                    total_skin = total_skin + item.components.stackable:StackSize()
                                else
                                    total_skin = total_skin + 1
                                end
                            end

                            if total_skin > 0 then
                                local remaining = math.min(deficit, total_skin)

                                for _, item in ipairs(skins) do
                                    if remaining <= 0 then
                                        break
                                    end

                                    local stacksize = 1
                                    if item.components ~= nil and item.components.stackable ~= nil then
                                        stacksize = item.components.stackable:StackSize()
                                    end

                                    local to_convert = math.min(stacksize, remaining)
                                    if to_convert > 0 then
                                        -- 在玩家背包中生成等量普通骨心，再移除对应数量的稻草心皮肤。
                                        local new = SpawnPrefab("wiltonmod_boneheart")
                                        if new ~= nil then
                                            if new.components ~= nil and new.components.stackable ~= nil then
                                                new.components.stackable:SetStackSize(to_convert)
                                            end
                                            inv:GiveItem(new)
                                        end

                                        if item.components ~= nil and item.components.stackable ~= nil and stacksize > to_convert then
                                            for i = 1, to_convert do
                                                local single = item.components.stackable:Get()
                                                if single ~= nil then
                                                    single:Remove()
                                                end
                                            end
                                        else
                                            item:Remove()
                                        end

                                        remaining = remaining - to_convert
                                    end
                                end
                            end
                        end
                    end
                end
            end

            -- 转换完成后再交给原版逻辑统一校验，保证联机与后续逻辑一致。
            return OldHasIngredients(self, rec)
        end

        return OldHasIngredients(self, recipe)
    end

    local OldMakeRecipeFromMenu = self.MakeRecipeFromMenu
    function self:MakeRecipeFromMenu(recipe, skin, ...)
        if recipe ~= nil
            and recipe.name == "wiltonmod_staff1"
            and self.inst ~= nil
            and self.inst.components ~= nil
            and self.inst.components.inventory ~= nil then
            local inv = self.inst.components.inventory
            local ingrs = recipe.ingredients
            local need = 0

            if ingrs ~= nil then
                for _, v in ipairs(ingrs) do
                    if v.type == "wiltonmod_boneheart" then
                        need = v.amount or 1
                        break
                    end
                end
            end

            if need > 0 then
                local has, num = inv:Has("wiltonmod_boneheart", need, true)
                if not has then
                    local deficit = need - (num or 0)
                    if deficit > 0 then
                        local skins = inv:FindItems(function(item)
                            return item.prefab == "wiltonmod_boneheart_skin"
                        end)

                        if skins ~= nil and #skins > 0 then
                            local total_skin = 0
                            for _, item in ipairs(skins) do
                                if item.components ~= nil and item.components.stackable ~= nil then
                                    total_skin = total_skin + item.components.stackable:StackSize()
                                else
                                    total_skin = total_skin + 1
                                end
                            end

                            if total_skin > 0 then
                                local remaining = math.min(deficit, total_skin)

                                for _, item in ipairs(skins) do
                                    if remaining <= 0 then
                                        break
                                    end

                                    local stacksize = 1
                                    if item.components ~= nil and item.components.stackable ~= nil then
                                        stacksize = item.components.stackable:StackSize()
                                    end

                                    local to_convert = math.min(stacksize, remaining)
                                    if to_convert > 0 then
                                        -- 在玩家背包中生成等量普通骨心，再移除对应数量的稻草心皮肤。
                                        local new = SpawnPrefab("wiltonmod_boneheart")
                                        if new ~= nil then
                                            if new.components ~= nil and new.components.stackable ~= nil then
                                                new.components.stackable:SetStackSize(to_convert)
                                            end
                                            inv:GiveItem(new)
                                        end

                                        if item.components ~= nil and item.components.stackable ~= nil and stacksize > to_convert then
                                            for i = 1, to_convert do
                                                local single = item.components.stackable:Get()
                                                if single ~= nil then
                                                    single:Remove()
                                                end
                                            end
                                        else
                                            item:Remove()
                                        end

                                        remaining = remaining - to_convert
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        if OldMakeRecipeFromMenu ~= nil then
            return OldMakeRecipeFromMenu(self, recipe, skin, ...)
        end
    end
end)

--- 客户端合成栏 Hook：让合成 UI 把带稻草心皮肤的骨心也视作骨杖配方所需材料.
-- 只影响配方 "wiltonmod_staff1" 的 HasIngredients 判定，其它配方仍完全走原版逻辑.
AddClassPostConstruct("components/builder_replica", function(self)
    local OldHasIngredients = self.HasIngredients
    function self:HasIngredients(recipe, ...)
        -- 先走原始逻辑：如果本来就能合成，直接返回 true。
        local ok = OldHasIngredients(self, recipe, ...)
        if ok then
            return true
        end

        -- 统一为 recipe 表，便于读取 name 和材料列表.
        if type(recipe) == "string" then
            recipe = GetValidRecipe(recipe)
        end

        if recipe == nil or recipe.name ~= "wiltonmod_staff1" then
            return ok
        end

        -- 参考游戏原版 builder_replica:HasIngredients 逻辑改写，
        -- 不区分主机 / 客户端，统一走 replica + classified 分支，避免 UI 与服务端状态不一致。
        -- 只在骨心材料上改用 tag 统计，其余仍保持原逻辑.
        if self.classified == nil then
            return ok
        end

        if self.classified.isfreebuildmode:value() then
            return true
        end

        local inv = self.inst.replica ~= nil and self.inst.replica.inventory or nil
        if inv == nil then
            return ok
        end

        local ingrs = recipe.ingredients or {}
        for _, v in ipairs(ingrs) do
            local amount = math.max(1, RoundBiasedUp(v.amount * self:IngredientMod()))
            if v.type == "wiltonmod_boneheart" then
                -- 使用 tag 统计“骨心 + 骨心皮肤”的总量。
                local has_tag, _ = inv:HasItemWithTag("wiltonmod_boneheart", amount)
                if not has_tag then
                    return false
                end
            else
                if not inv:Has(v.type, amount, true) then
                    return false
                end
            end
        end

        if recipe.character_ingredients ~= nil then
            for _, v in ipairs(recipe.character_ingredients) do
                if not self:HasCharacterIngredient(v) then
                    return false
                end
            end
        end

        if recipe.tech_ingredients ~= nil then
            for _, v in ipairs(recipe.tech_ingredients) do
                if not self:HasTechIngredient(v) then
                    return false
                end
            end
        end

        return true
    end
end)

--- 有次数消耗物品 Hook：当使用者为骷髅宠物且配置关闭“消耗耐久”时，不再扣减使用次数.
-- 适用于武器、工具等使用 finiteuses 组件的物品.
AddComponentPostInit("finiteuses", function(self)
    local OldUse = self.Use
    function self:Use(num_uses, ...)
        if self.inst ~= nil and Wilton_ShouldSkeletonIgnoreDurability(self.inst) then
            return
        end

        if OldUse ~= nil then
            return OldUse(self, num_uses, ...)
        end
    end
end)

--- 燃料型耐久 Hook：当装备由骷髅宠物持有且应忽略耐久时，阻止 fueled 组件消耗燃料。
-- 通过拦截 DoDelta 的负向变化（消耗部分），让头灯、火把等在骷髅兵手中保持“无限新鲜度/耐久”，
-- 同时保留为其补充燃料（正向 DoDelta）的正常行为，并避免影响非骷髅兵或普通建筑的燃料逻辑。
AddComponentPostInit("fueled", function(self)
    local OldDoDelta = self.DoDelta
    function self:DoDelta(amount, doer, ...)
        if amount ~= nil and amount < 0 and self.inst ~= nil and Wilton_ShouldSkeletonIgnoreDurability(self.inst) then
            return
        end

        if OldDoDelta ~= nil then
            return OldDoDelta(self, amount, doer, ...)
        end
    end
end)

local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

AddComponentPostInit("childspawner", function(self) 
    function self:DoSpawnChild(target, prefab, radius, ...)
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local spawn_radius = radius
    if spawn_radius == nil then
        if self.spawnradius ~= nil then
            if type(self.spawnradius) == "table" then
                spawn_radius = Lerp(self.spawnradius.min, self.spawnradius.max, math.sqrt(math.random()))
            else
                spawn_radius = self.spawnradius
            end
        else
            spawn_radius = 0.5
        end
    end

    local offset = (self.overridespawnlocation ~= nil and self.overridespawnlocation(self.inst))
        or (self.wateronly and FindSwimmableOffset(Vector3(x, 0, z), math.random() * TWOPI, spawn_radius + self.inst:GetPhysicsRadius(0), 8, false, true, NoHoles))
        or (FindWalkableOffset(Vector3(x, 0, z), math.random() * TWOPI, spawn_radius + self.inst:GetPhysicsRadius(0), 8, false, true, NoHoles, self.allowwater, self.allowboats))
    if not offset then
        return
    end

    prefab =
        self.rarechild ~= nil and
        math.random() < self.rarechildchance and
        self.rarechild or
        prefab or
        self.childname

    local child = SpawnPrefab(FunctionOrValue(prefab, self.inst))

    if child ~= nil then
        child.Transform:SetPosition(x + offset.x, self.spawn_height or 0, z + offset.z)

        if child.components.inventoryitem ~= nil then
            child.components.inventoryitem:InheritWorldWetnessAtTarget(self.inst)
        end

        if target ~= nil and child.components.combat ~= nil then
            if (target:HasTag("wiltonmod") and self.inst.prefab == "wasphive") or not target:HasTag("wiltonmod") then
            child.components.combat:SetTarget(target)
            end
        end

        if self.onspawned ~= nil then
            self.onspawned(self.inst, child)
        end
    end
    return child
    end   
end)

local AttackerS = {
  lunarthrall_plant = true,
  lunarthrall_plant_back = true,
  lunarthrall_plant_vine = true,
  lunarthrall_plant_vine_end = true
}

local AddAnimal = {
  ghost = true,
  mutated_penguin = true,
  walrus = true
}

AddComponentPostInit("combat", function(self)
	--if self.inst.prefab and AttackerS[self.inst.prefab] == nil then
    local _OldTryRetarget = self.TryRetarget
    function self:TryRetarget(...)
		-- 触手：保持原版 Retarget 行为，不屏蔽对威尔顿及骷髅宠物的主动仇恨。
		if self.inst ~= nil and self.inst.prefab == "tentacle" then
			return _OldTryRetarget(self, ...)
		end

		if self.targetfn ~= nil and self.inst.prefab ~= "lunarthrall_plant" then
			local newtarget = self.targetfn(self.inst)
			if newtarget and (newtarget:HasTag("wiltonmod") or newtarget:HasTag("wiltonmod_pet")) 
			and not self.inst:HasTag("shadow") and not self.inst:HasTag("hound")  --and self.inst:HasTag("monster") 
			and not self.inst:HasTag("epic") and (not self.inst:HasTag("character") or AddAnimal[self.inst.prefab]) then
				return
			else
				return _OldTryRetarget(self, ...)                
			end 
		else
			return _OldTryRetarget(self, ...)    
		end
	end 
	--end   
end)

--[[
local Old_FertilizeFn = ACTIONS.FERTILIZE.fn
ACTIONS.FERTILIZE.fn = function(act)
    if act.invobject and act.invobject.prefab == "wiltonmod_bonepaste"
    and act.target and act.target.prefab == "wormwood" then 
        local target = act.target or act.doer
        return act.invobject.components.healer:Heal(target, act.doer)
    end
    return Old_FertilizeFn(act)             
end
]]