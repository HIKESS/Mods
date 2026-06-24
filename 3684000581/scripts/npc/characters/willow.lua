-- scripts/npc/characters/willow.lua
-- Willow（薇洛）：火女，不怕火 + 伯尼战斗部署系统
-- 生命周期：bernie_inactive(背包) → 战斗丢出(丢物品动画) → bernie_big(战斗) → 缩小/死亡(烟雾特效) → bernie_inactive(背包)
-- 数据特化（inventory_slots=12）由 npc_tuning 驱动

local NPC_BERNIE_BIG_BRAIN = require("brains/npc_bernie_big_brain")
local NPC_SPEECH = require("npc_speech")

-- ════════════════════════════════════════════════════════════
--  工具函数
-- ════════════════════════════════════════════════════════════

--- 在薇洛背包中查找 bernie_inactive
local function FindBernieInInventory(inst)
    local inv = inst.components.inventory
    if not inv then return nil end
    for k, v in pairs(inv.itemslots) do
        if v and v.prefab == "bernie_inactive" then
            return v
        end
    end
    return nil
end

--- 在薇洛附近搜索地面上的 NPC bernie_inactive（通过 npc_bernie 标签识别）
local function FindBernieOnGround(inst, radius)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, radius or 20, {"npc_bernie"}, {"INLIMBO"})
    for _, v in ipairs(ents) do
        if v.prefab == "bernie_inactive" and v.components.inventoryitem
           and not v.components.inventoryitem:IsHeld() then
            return v
        end
    end
    return nil
end

--- 加载时搜索地面 bernie_inactive（不依赖 _is_npc_bernie 运行时标记）
--- 存档后 _is_npc_bernie 丢失，需要纯靠 prefab + 地面状态匹配
local function FindAnyBernieOnGround(x, y, z, radius)
    local ents = TheSim:FindEntities(x, y, z, radius or 50, nil, { "INLIMBO" })
    for _, v in ipairs(ents) do
        if v.prefab == "bernie_inactive" and v.components.inventoryitem
           and not v.components.inventoryitem:IsHeld() then
            return v
        end
    end
    return nil
end

--- 确保背包有一个空槽给伯尼（背包满时删除一个非伯尼物品腾出空间）
--- 删除优先级：从最后一格往前，跳过 bernie_inactive
local function EnsureSlotForBernie(inst)
    local inv = inst.components.inventory
    if not inv then return false end
    -- 检查是否已有空槽
    for i = 1, inv.maxslots do
        if not inv:GetItemInSlot(i) then
            return true
        end
    end
    -- 背包满，从后往前找一个非伯尼物品删除
    for i = inv.maxslots, 1, -1 do
        local item = inv:GetItemInSlot(i)
        if item and item.prefab ~= "bernie_inactive" then
            local taken = inv:RemoveItem(item, true)
            if taken and taken:IsValid() then
                taken:Remove()
            end
            return true
        end
    end
    return false
end

-- ════════════════════════════════════════════════════════════
--  薇洛纵火行为（工具函数）
-- ════════════════════════════════════════════════════════════

local NPC_TUNING = require("npc_tuning")

local function IsFriendlyNPC(target)
    return target and target:HasTag("npcfriend") and not target:HasTag("npc_hostile")
end

--- 搜索纵火目标（优先级：NPC > 玩家 > 可燃物）
local function FindArsonTarget(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local radius = NPC_TUNING.ARSON_SEARCH_RADIUS or 12

    -- 优先级 1：其他 NPC（排除自己）
    local npcs = TheSim:FindEntities(x, y, z, radius, {"npcfriend"}, {"INLIMBO", "playerghost"})
    for _, npc in ipairs(npcs) do
        if npc ~= inst and npc:IsValid() then
            return npc
        end
    end

    -- 优先级 2：玩家角色（排除幽灵）
    local players = TheSim:FindEntities(x, y, z, radius, {"player"}, {"INLIMBO", "playerghost"})
    for _, player in ipairs(players) do
        if player:IsValid() then
            return player
        end
    end

    -- 优先级 3：可燃物（未在燃烧、未烧毁）
    local burnables = TheSim:FindEntities(x, y, z, radius, {"canlight"}, {"INLIMBO", "fire", "burnt", "npc_bernie"})
    for _, obj in ipairs(burnables) do
        if obj:IsValid() and obj.components.burnable
           and not obj.components.burnable.burning then
            return obj
        end
    end

    return nil
end

--- 施加特殊火焰（纯视觉 + 恐吓标志，无伤害、不蔓延）
local function ApplyArsonFire(target, duration, arsonist)
    if not target or not target:IsValid() then return end
    duration = duration or (NPC_TUNING.ARSON_FIRE_DURATION or 3)

    -- 1. 生成火焰视觉效果
    local fx = SpawnPrefab("campfirefire")
    if fx then
        target:AddChild(fx)
        fx.Transform:SetPosition(0, 0, 0)
        fx.persists = false
    end

    local panic_task = nil
    if target.components.health then
        panic_task = target:DoPeriodicTask(0.1, function()
            if target:IsValid() and target.components.health then
                target.components.health.takingfiredamage = true
            end
        end)
    end

    -- 3. 被点目标反应（仅NPC）
    if target._is_wickerbottom and arsonist then
        target:PushEvent("arson_fire_applied", { arsonist = arsonist })
    elseif target.components.talker and target.npc_character_type then
        local react_line = NPC_SPEECH.GetLine(NPC_SPEECH.ARSON_REACT, target.npc_character_type)
        if react_line then
            target:DoTaskInTime(0.5, function()
                if target:IsValid() and target.components.talker then
                    target.components.talker:Say(react_line)
                end
            end)
        end
    end

    -- 4. 到期清理：移除火焰 FX + 重置恐慑标志
    target:DoTaskInTime(duration, function()
        if panic_task then
            panic_task:Cancel()
            panic_task = nil
        end
        if target:IsValid() and target.components.health then
            target.components.health.takingfiredamage = false
        end
        if fx and fx:IsValid() then
            fx:Remove()
        end
    end)
end

--- 纵火定期检查（由 DoPeriodicTask 调用）
local function ArsonPeriodicCheck(inst)
    -- 条件检查
    if inst._is_ghost_mode then return end
    if inst.components.combat and inst.components.combat.target then return end
    if inst._arson_target and inst._arson_target:IsValid() then return end -- 已有目标追踪中

    -- 冷却检查
    if inst._arson_cd and GetTime() < inst._arson_cd then return end

    -- 搜索目标
    local target = FindArsonTarget(inst)
    if target then
        inst._arson_target = target
    end
end

-- ════════════════════════════════════════════════════════════
--  bernie_inactive 配置（NPC 专用）
-- ════════════════════════════════════════════════════════════

local function ConfigureNPCBernieInactive(inst, inactive)
    if not inactive or not inactive:IsValid() then return end
    inactive._is_npc_bernie = true
    inactive._npc_owner = inst
    inactive:AddTag("npc_bernie")

    -- 取消自动复活任务（搜索 AllPlayers 的 tryreanimate）
    if inactive._activatetask then
        inactive._activatetask:Cancel()
        inactive._activatetask = nil
    end

    -- 取消衰变任务
    if inactive._decaytask then
        inactive._decaytask:Cancel()
        inactive._decaytask = nil
    end

    -- 燃料设满 + 不消耗（NPC 不消耗耐久）
    if inactive.components.fueled then
        inactive.components.fueled:SetPercent(1)
        inactive.components.fueled.rate = 0
    end
end

-- ════════════════════════════════════════════════════════════
--  嘲讽机制（简化版，去掉 skilltree 依赖）
-- ════════════════════════════════════════════════════════════

local TAUNT_MUST_TAGS = { "_combat" }
local TAUNT_CANT_TAGS = { "INLIMBO", "player", "companion", "epic", "notaunt" }
local TAUNT_ONEOF_TAGS = { "locomotor", "lunarthrall_plant" }

local function IsTauntableNPC(inst, target)
    return not (target.components.health ~= nil and target.components.health:IsDead())
        and target.components.combat ~= nil
        and not target.components.combat:TargetIs(inst)
        and target.components.combat:CanTarget(inst)
        and (
            target:HasTag("shadowcreature")
            or (target.components.combat:HasTarget() and
                (target.components.combat.target:HasTag("player") or
                 (target.components.combat.target:HasTag("companion") and target.components.combat.target.prefab ~= inst.prefab)))
        )
end

local function TauntCreaturesNPC(inst)
    if not inst.components.health or inst.components.health:IsDead() then return end
    local taunt_dist = NPC_TUNING.BERNIE_TAUNT_DIST or 16
    local x, y, z = inst.Transform:GetWorldPosition()
    for _, v in ipairs(TheSim:FindEntities(x, y, z, taunt_dist, TAUNT_MUST_TAGS, TAUNT_CANT_TAGS, TAUNT_ONEOF_TAGS)) do
        if IsTauntableNPC(inst, v) then
            v.components.combat:SetTarget(inst)
        end
    end
end

-- ════════════════════════════════════════════════════════════
--  索敌逻辑（NPC 大伯尼专用）
-- ════════════════════════════════════════════════════════════

local RETARGET_MUST_TAGS = { "_combat" }
local RETARGET_CANT_TAGS = { "INLIMBO", "player", "companion", "wall", "notaunt" }

local function NPCRetargetFn(inst)
    local leader = inst._npc_leader

    -- 1. 同步薇洛的目标（排除友方单位）
    if leader and leader:IsValid() and leader.components.combat then
        local ltarget = leader.components.combat.target
        if ltarget and ltarget:IsValid() and ltarget.components.health
           and not ltarget.components.health:IsDead()
           and not IsFriendlyNPC(ltarget)
           and not ltarget:HasTag("companion") then
            return ltarget
        end
    end

    -- 2. 搜索附近影怪或攻击薇洛/同伴的敌人
    local taunt_dist = NPC_TUNING.BERNIE_TAUNT_DIST or 16
    return FindEntity(inst, taunt_dist,
        function(v)
            if v.components.health and v.components.health:IsDead() then return false end
            if not v.components.combat then return false end
            if v:HasTag("npc_hostile") then return true end
            -- 影怪
            if v:HasTag("shadowcreature") then return true end
            -- 正在攻击薇洛或NPC同伴的敌人
            if v.components.combat:HasTarget() then
                local ct = v.components.combat.target
                if ct and (ct:HasTag("player") or ct:HasTag("companion") or ct:HasTag("npcfriend")) then
                    return true
                end
            end
            return false
        end,
        RETARGET_MUST_TAGS, RETARGET_CANT_TAGS
    )
end

local function NPCKeepTargetFn(inst, target)
    return target:IsValid()
        and not (target.components.health and target.components.health:IsDead())
        and inst:IsNear(target, 30)
end

-- ════════════════════════════════════════════════════════════
--  bernie_big 配置（NPC 专用）
-- ════════════════════════════════════════════════════════════

local function ConfigureNPCBernieBig(inst, big)
    big._is_npc_bernie = true
    big._npc_leader = inst
    big.persists = false
    big:AddTag("npcfriend_companion")  -- NPC召唤物统一标签，供互助检测 + 闪电排除

    -- 替换大脑
    big:SetBrain(NPC_BERNIE_BIG_BRAIN)

    -- 配置索敌
    if big.components.combat then
        big.components.combat:SetRetargetFunction(1, NPCRetargetFn)
        big.components.combat:SetKeepTargetFunction(NPCKeepTargetFn)
    end

    -- 嘲讽任务（替换为 NPC 简化版）
    if big._taunttask then
        big._taunttask:Cancel()
    end
    local taunt_period = NPC_TUNING.BERNIE_TAUNT_PERIOD or 2
    big._taunttask = big:DoPeriodicTask(taunt_period, TauntCreaturesNPC, 0)

    -- 禁用 EntitySleep → GoInactive（NPC 版由大脑控制）
    big.OnEntitySleep = nil
    big.OnEntityWake = nil

    -- 包装 GoInactive：创建 bernie_inactive 后追加 NPC 配置 + 烟雾回收
    local orig_GoInactive = big.GoInactive
    big.GoInactive = function(b)
        local was_dead = b.components.health and b.components.health:IsDead()
        -- 记录位置（GoInactive 会 Remove bernie_big）
        local bx, by, bz = b.Transform:GetWorldPosition()

        -- 保存当前血量百分比（死亡则恢复满血）
        if was_dead then
            inst._bernie_saved_hp = 1
        elseif b.components.health then
            inst._bernie_saved_hp = b.components.health:GetPercent()
        end

        local inactive = orig_GoInactive(b)
        if inactive then
            ConfigureNPCBernieInactive(inst, inactive)
            if inactive.components.fueled then
                inactive.components.fueled:SetPercent(1)
            end
            inst._bernie_big = nil

            -- 烟雾特效（在大伯尼原位置）
            local fx = SpawnPrefab("small_puff")
            if fx then
                fx.Transform:SetPosition(bx, by, bz)
            end

            -- 直接放入薇洛背包（不留在地面）
            if inst:IsValid() and inst.components.inventory then
                EnsureSlotForBernie(inst)
                inst.components.inventory:GiveItem(inactive)
                inst._bernie_ground = nil
            else
                inst._bernie_ground = inactive
            end

            -- 死亡和普通召回使用不同CD
            if was_dead then
                inst._bernie_deploy_cd = GetTime() + (NPC_TUNING.BERNIE_DEATH_DEPLOY_COOLDOWN or 480)
            else
                inst._bernie_deploy_cd = GetTime() + (NPC_TUNING.BERNIE_DEPLOY_COOLDOWN or 30)
            end
        end
        return inactive
    end

    -- onremove 清理引用
    big:ListenForEvent("onremove", function()
        if inst._bernie_big == big then
            inst._bernie_big = nil
        end
        if big._taunttask then
            big._taunttask:Cancel()
            big._taunttask = nil
        end
    end)

    inst._bernie_big = big
end

-- ════════════════════════════════════════════════════════════
--  部署/回收
-- ════════════════════════════════════════════════════════════

local function DeployBernie(inst)
    -- 防重复
    if inst._bernie_big and inst._bernie_big:IsValid() then return end
    if inst._bernie_deploying then return end
    if inst._is_ghost_mode then return end

    -- 冷却检查
    if inst._bernie_deploy_cd and GetTime() < inst._bernie_deploy_cd then return end

    -- 查找背包中的 bernie_inactive
    local inactive = FindBernieInInventory(inst)
    if not inactive then return end

    -- 强制播放丢物品动画（pickup/pickup_pst，弯腰放置动作）
    if inst.sg and not inst.sg:HasStateTag("busy") then
        inst.sg:GoToState("dopickup")
    end

    -- 召唤出战台词
    if inst.components.talker then
        local line = NPC_SPEECH.GetLine(NPC_SPEECH.BERNIE_DEPLOY, inst.npc_character_type)
        if line then inst.components.talker:Say(line) end
    end

    -- 延迟到弯腰帧（第6帧）丢出伯尼，物品从身上落下而非凭空生成
    local inv = inst.components.inventory
    inst:DoTaskInTime(6 * FRAMES, function()
        if not inst:IsValid() or not inactive or not inactive:IsValid() then return end
        if inv then
            inv:RemoveItem(inactive)
            local x, y, z = inst.Transform:GetWorldPosition()
            inactive.Transform:SetPosition(x, y, z)
            if inactive.components.inventoryitem then
                inactive.components.inventoryitem:OnDropped(true)
            end
        end
        if inactive._activatetask then
            inactive._activatetask:Cancel()
            inactive._activatetask = nil
        end
    end)

    inst._bernie_deploying = true
    inst._bernie_deploy_inactive = inactive  -- 保存引用，延迟后使用

    -- 延迟后变大
    local deploy_delay = NPC_TUNING.BERNIE_DEPLOY_DELAY or 2
    inst:DoTaskInTime(deploy_delay, function()
        inst._bernie_deploying = false

        if not inst:IsValid() or inst._is_ghost_mode then
            -- 薇洛状态异常，把 inactive 放回背包
            if inactive and inactive:IsValid() and inv then
                inv:GiveItem(inactive)
                ConfigureNPCBernieInactive(inst, inactive)
            end
            inst._bernie_deploy_inactive = nil
            return
        end

        -- 检查 inactive 是否被玩家捡走
        local bx, by, bz
        if inactive and inactive:IsValid() then
            if inactive.components.inventoryitem and inactive.components.inventoryitem:IsHeld() then
                -- 被玩家捡走 → 中止部署，等待地面回收
                inst._bernie_deploy_inactive = nil
                return
            end
            bx, by, bz = inactive.Transform:GetWorldPosition()
            inactive:Remove()
        else
            bx, by, bz = inst.Transform:GetWorldPosition()
        end
        inst._bernie_deploy_inactive = nil
        inst._bernie_ground = nil

        -- 生成大伯尼
        local big = SpawnPrefab("bernie_big")
        if big then
            big.Transform:SetPosition(bx, by, bz)
            ConfigureNPCBernieBig(inst, big)
            -- 恢复保存的血量（上次召回时的HP）
            if inst._bernie_saved_hp and big.components.health then
                big.components.health:SetPercent(inst._bernie_saved_hp)
            end
            -- 播放变大动画（SGberniebig activate 包含小→大缩放效果）
            if big.sg then
                big.sg:GoToState("activate")
            end
            -- 同步薇洛当前战斗目标
            if inst.components.combat and inst.components.combat.target then
                big:DoTaskInTime(0.5, function()
                    if big:IsValid() and big.components.combat
                       and inst:IsValid() and inst.components.combat
                       and inst.components.combat.target then
                        big.components.combat:SetTarget(inst.components.combat.target)
                    end
                end)
            end
        end
    end)
end

--- 传送辅助：将实体传送到薇洛附近可行走位置
local function TeleportNearWillow(inst, ent)
    if not ent or not ent:IsValid() then return end
    local ix, iy, iz = inst.Transform:GetWorldPosition()
    local radius = NPC_TUNING.BERNIE_TELEPORT_RADIUS or 5
    local offset = FindWalkableOffset(
        Vector3(ix, iy, iz),
        math.random() * 2 * PI,
        radius, 8, true
    )
    if offset then
        ent.Physics:Teleport(ix + offset.x, iy + offset.y, iz + offset.z)
    else
        ent.Physics:Teleport(ix + 1, iy, iz + 1)
    end
end

-- ════════════════════════════════════════════════════════════
--  伯尼定期任务（传送 + 地面回收）
-- ════════════════════════════════════════════════════════════

--- 启动/重启伯尼定期任务（on_apply 和复活后均调用）
local function StartBernieTasks(inst)
    if inst._bernie_teleport_task then
        inst._bernie_teleport_task:Cancel()
        inst._bernie_teleport_task = nil
    end
    if inst._bernie_recovery_task then
        inst._bernie_recovery_task:Cancel()
        inst._bernie_recovery_task = nil
    end

    -- ─── 定期检查：传送 ───
    local tp_dist_sq = NPC_TUNING.BERNIE_TELEPORT_DIST * NPC_TUNING.BERNIE_TELEPORT_DIST
    inst._bernie_teleport_task = inst:DoPeriodicTask(NPC_TUNING.BERNIE_TELEPORT_INTERVAL, function()
        if not inst:IsValid() or inst._is_ghost_mode then return end

        -- 大伯尼传送
        local big = inst._bernie_big
        if big and big:IsValid() then
            local bx, by, bz = big.Transform:GetWorldPosition()
            local ix, iy, iz = inst.Transform:GetWorldPosition()
            local dsq = (ix - bx) * (ix - bx) + (iz - bz) * (iz - bz)
            if dsq > tp_dist_sq then
                if big.components.combat then
                    big.components.combat:SetTarget(nil)
                end
                TeleportNearWillow(inst, big)
                -- 同步薇洛当前目标（传送后立即战斗）
                if inst.components.combat and inst.components.combat.target then
                    big:DoTaskInTime(0.5, function()
                        if big:IsValid() and big.components.combat
                           and inst:IsValid() and inst.components.combat
                           and inst.components.combat.target then
                            big.components.combat:SetTarget(inst.components.combat.target)
                        end
                    end)
                end
            end
        end

        -- 地面 inactive 兆底回收（正常流程不应出现在地面）
        local ground = inst._bernie_ground
        if ground and ground:IsValid() and not ground.components.inventoryitem:IsHeld() then
            local gx, gy, gz = ground.Transform:GetWorldPosition()
            local fx = SpawnPrefab("small_puff")
            if fx then
                fx.Transform:SetPosition(gx, gy, gz)
            end
            if inst.components.inventory then
                EnsureSlotForBernie(inst)
                inst.components.inventory:GiveItem(ground)
            end
            inst._bernie_ground = nil
        end
    end)

    -- ─── 地面回收：背包无伯尼时定期搜索地面 npc_bernie ───
    local recovery_dist = NPC_TUNING.BERNIE_RECOVERY_DIST or 20
    inst._bernie_recovery_task = inst:DoPeriodicTask(
        NPC_TUNING.BERNIE_RECOVERY_INTERVAL or 15, function()
        if not inst:IsValid() or inst._is_ghost_mode then return end
        -- 大伯尼在场或正在部署
        if inst._bernie_big and inst._bernie_big:IsValid() then return end
        if inst._bernie_deploying then return end
        -- 背包已有伯尼
        if FindBernieInInventory(inst) then return end
        -- 搜索周围地面的 NPC 伯尼（通过 npc_bernie 标签）
        local ground = FindBernieOnGround(inst, recovery_dist)
        if ground and ground:IsValid()
           and not ground.components.inventoryitem:IsHeld() then
            -- 烟雾特效 + 回收到背包
            local gx, gy, gz = ground.Transform:GetWorldPosition()
            local fx = SpawnPrefab("small_puff")
            if fx then fx.Transform:SetPosition(gx, gy, gz) end
            ConfigureNPCBernieInactive(inst, ground)
            if inst.components.inventory then
                EnsureSlotForBernie(inst)
                inst.components.inventory:GiveItem(ground)
            end
            inst._bernie_ground = nil
            -- 找回伯尼对话
            if inst.components.talker then
                local line = NPC_SPEECH.GetLine(NPC_SPEECH.BERNIE_FOUND, inst.npc_character_type)
                if line then inst.components.talker:Say(line) end
            end
        else
            if not inst._bernie_missing_speech_cd or GetTime() > inst._bernie_missing_speech_cd then
                inst._bernie_missing_speech_cd = GetTime() + 60
                if inst.components.talker then
                    local line = NPC_SPEECH.GetLine(NPC_SPEECH.BERNIE_MISSING, inst.npc_character_type)
                    if line then inst.components.talker:Say(line) end
                end
            end
        end
    end)
end

-- ════════════════════════════════════════════════════════════
--  月焰（Lunar Fire）— 战斗中定期朝目标喷射火浪
--  视觉：warg_mutated_breath_fx 无 owner → 纯特效零伤害
--  伤害：自定义锥形 AoE，照搬鹿人冲撞排除友军（玩家/NPC伙伴/召唤物）
-- ════════════════════════════════════════════════════════════

-- 火浪视觉沿喷射方向铺开的四段距离（与原版 flamethrower_fx 一致）
local LUNARFIRE_FLAME_DISTS = { 3, 5, 7, 9 }

-- 友军判定（双保险：目标搜索已用排除标签，这里再挡一层）
local function IsLunarFireFriend(target)
    return target:HasTag("player")
        or target:HasTag("npcfriend")
        or target:HasTag("companion")
        or target:HasTag("npcfriend_companion")
end

-- 角度差（度），返回 0~180
local function LunarFireAngleDiff(a, b)
    local d = (a - b) % 360
    if d > 180 then d = d - 360 end
    return math.abs(d)
end

-- 生成一束纯视觉火浪（无 owner → 不挂伤害更新，绝不伤人）
local function SpawnLunarFireVisual(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local angle = inst.Transform:GetRotation() * DEGREES
    for _, dist in ipairs(LUNARFIRE_FLAME_DISTS) do
        local fx = SpawnPrefab("warg_mutated_breath_fx")
        if fx then
            local scale = 1.4 + math.random() * 0.25
            if dist < 6 then
                scale = scale * 1.2
            elseif dist > 7 then
                scale = scale * (1 + (dist - 7) / 6)
            end
            local jitter = (math.random() - 0.5) * (dist / 10)
            local fx_x = x + math.cos(angle) * dist + math.cos(angle + PI / 2) * jitter
            local fx_z = z - math.sin(angle) * dist - math.sin(angle + PI / 2) * jitter
            fx.Transform:SetPosition(fx_x, 0, fx_z)
            if fx.RestartFX then
                fx:RestartFX(scale) -- 不传 targets / 不设 owner → 纯视觉
            end
        end
    end
end

-- 单次结算：朝目标重新转向 → 喷视觉 → 锥形范围内敌人受伤（排除友军）
local function DoLunarFirePulse(inst)
    if not inst:IsValid() or inst._is_ghost_mode then return end

    -- 仅施法动画期间强制朝向目标；动画结束后交还战斗 AI（不再抢朝向）
    if inst._lunarfire_casting then
        local target = inst._lunarfire_target
        if target and target:IsValid()
           and not (target.components.health and target.components.health:IsDead()) then
            inst:ForceFacePoint(target.Transform:GetWorldPosition())
        end
    end

    -- 视觉火浪
    SpawnLunarFireVisual(inst)

    -- 自定义锥形 AoE 伤害
    local x, y, z = inst.Transform:GetWorldPosition()
    local facing = inst.Transform:GetRotation() -- 度
    local range = NPC_TUNING.LUNARFIRE_RANGE or 9
    local half_angle = NPC_TUNING.LUNARFIRE_HALF_ANGLE or 35
    local dmg = NPC_TUNING.LUNARFIRE_DAMAGE or 20
    local planar = NPC_TUNING.LUNARFIRE_PLANAR_DAMAGE or 30
    local combat = inst.components.combat
    if not combat then return end

    local ents = TheSim:FindEntities(x, 0, z, range, { "_combat" },
        { "INLIMBO", "companion", "player", "npcfriend", "npcfriend_companion",
          "wall", "flight", "invisible", "notarget", "noattack", "playerghost" })
    for _, v in ipairs(ents) do
        if v ~= inst and v:IsValid() and v.components.combat
           and not (v.components.health and v.components.health:IsDead())
           and combat:CanTarget(v) then
            -- 跳过被玩家/NPC魅惑或跟随友方的单位（与鹿人冲撞一致）
            local leader = v.components.follower and v.components.follower:GetLeader()
            if not (leader and (leader:HasTag("player") or leader:HasTag("npcfriend"))) then
                -- 锥形朝向判定
                local vx, vy, vz = v.Transform:GetWorldPosition()
                local to_deg = math.atan2(z - vz, vx - x) / DEGREES
                if LunarFireAngleDiff(facing, to_deg) <= half_angle then
                    v.components.combat:GetAttacked(inst, dmg, nil, nil, { planar = planar })
                end
            end
        end
    end
end

-- 查找打火机（优先手部装备，其次物品栏任意格），返回物品或 nil
local function FindLighter(inst)
    local inv = inst.components.inventory
    if not inv then return nil end
    local equipped = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
    if equipped and equipped.prefab == "lighter" then return equipped end
    for _, v in pairs(inv.itemslots) do
        if v and v.prefab == "lighter" then return v end
    end
    return nil
end

-- 施法结束后恢复武器继续战斗（把打火机换回背包）
-- 仅在"本次施法是我们临时装备的打火机"时才处理；
-- 若打火机是玩家自己装备的（_lunarfire_equipped_lighter=false），保持不动。
local function RestoreWeaponAfterLunarFire(inst)
    if not inst:IsValid() then return end
    if not inst._lunarfire_equipped_lighter then
        inst._lunarfire_prev_weapon = nil
        return
    end
    inst._lunarfire_equipped_lighter = nil

    local inv = inst.components.inventory
    if not inv then
        inst._lunarfire_prev_weapon = nil
        return
    end

    -- 当前已不是打火机（玩家中途手动换装）→ 不干预
    local hands = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
    if not (hands and hands.prefab == "lighter") then
        inst._lunarfire_prev_weapon = nil
        return
    end

    -- 优先恢复施法前的武器（Equip 会把打火机自动换回背包）
    local prev = inst._lunarfire_prev_weapon
    inst._lunarfire_prev_weapon = nil
    if prev and prev:IsValid() and prev.components.inventoryitem
       and prev.components.inventoryitem:IsHeldBy(inst) then
        inv:Equip(prev)
        return
    end

    -- 否则在背包里挑一把伤害最高的武器装备（排除工具/打火机）
    local best, best_dmg = nil, -1
    for i = 1, inv.maxslots do
        local it = inv:GetItemInSlot(i)
        if it and it.components.equippable
           and it.components.equippable.equipslot == EQUIPSLOTS.HANDS
           and it.components.weapon and not it.components.tool
           and not it:HasTag("lighter") then
            local dmg = it.components.weapon:GetDamage(inst) or 0
            if dmg > best_dmg then best_dmg = dmg; best = it end
        end
    end
    if best then
        inv:Equip(best)
    else
        -- 没有武器：仅把打火机卸回背包
        local taken = inv:Unequip(EQUIPSLOTS.HANDS)
        if taken then inv:GiveItem(taken) end
    end
end

-- 施放一次月焰（持续 DURATION 秒）：先确保手持打火机，结束后恢复武器
local function CastLunarFire(inst, target)
    if not inst:IsValid() or inst._is_ghost_mode then return end
    if not target or not target:IsValid() then return end

    local inv = inst.components.inventory
    if not inv then return end

    -- 必须持有打火机才能释放
    local lighter = FindLighter(inst)
    if not lighter then return end

    -- 打火机不在手上时：记录当前武器并装备打火机（旧武器自动回背包）
    -- _lunarfire_equipped_lighter 标记"打火机是我们临时装备的"，
    -- 结束后才换回武器；玩家自己装备的打火机则保持不动。
    local hands = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
    if not (hands and hands.prefab == "lighter") then
        inst._lunarfire_prev_weapon = hands   -- 可能为 nil（原本空手）
        inst._lunarfire_equipped_lighter = true
        inv:Equip(lighter)
    else
        inst._lunarfire_prev_weapon = nil
        inst._lunarfire_equipped_lighter = nil
    end

    inst._lunarfire_target = target
    inst._lunarfire_casting = true   -- 施法动画期间锁定朝向（结束后交还战斗 AI）
    inst:ForceFacePoint(target.Transform:GetWorldPosition())

    -- 施法动画（原版月焰 channelcast 持物引导，锁定 CAST_TIME 秒）
    if inst.sg then
        inst.sg:GoToState("npc_lunarfire")
    end

    -- 喷火音效
    if inst.SoundEmitter then
        inst.SoundEmitter:PlaySound("rifts3/mutated_varg/blast_lp", "lunarfire_loop")
    end

    -- 周期性视觉 + 伤害（持续到 DURATION）
    if inst._lunarfire_pulse_task then
        inst._lunarfire_pulse_task:Cancel()
    end
    local tick = NPC_TUNING.LUNARFIRE_TICK or 0.25
    inst._lunarfire_pulse_task = inst:DoPeriodicTask(tick, DoLunarFirePulse, 0)

    -- 施法动画结束（CAST_TIME）：立刻换回武器恢复战斗，不等火焰消失
    local cast_time = NPC_TUNING.LUNARFIRE_CAST_TIME or 2
    if inst._lunarfire_castend_task then
        inst._lunarfire_castend_task:Cancel()
    end
    inst._lunarfire_castend_task = inst:DoTaskInTime(cast_time, function()
        inst._lunarfire_castend_task = nil
        inst._lunarfire_casting = false   -- 解除强制朝向，交还战斗 AI
        RestoreWeaponAfterLunarFire(inst)
    end)

    -- 火焰到期收尾（DURATION）：停喷 + 收尾音效（武器此前已换回）
    local duration = NPC_TUNING.LUNARFIRE_DURATION or 2
    if duration < cast_time then duration = cast_time end
    if inst._lunarfire_end_task then
        inst._lunarfire_end_task:Cancel()
    end
    inst._lunarfire_end_task = inst:DoTaskInTime(duration, function()
        if inst._lunarfire_pulse_task then
            inst._lunarfire_pulse_task:Cancel()
            inst._lunarfire_pulse_task = nil
        end
        inst._lunarfire_end_task = nil
        inst._lunarfire_target = nil
        inst._lunarfire_casting = false
        if inst.SoundEmitter then
            inst.SoundEmitter:KillSound("lunarfire_loop")
        end
        -- 兜底：若因异常未在 CAST_TIME 换回武器，这里再保证一次
        RestoreWeaponAfterLunarFire(inst)
    end)

    inst._lunarfire_cd = GetTime() + (NPC_TUNING.LUNARFIRE_COOLDOWN or 20)
end

-- 战斗中定期检查：目标在触发范围内、冷却就绪即喷射
local function LunarFirePeriodicCheck(inst)
    if not inst:IsValid() or inst._is_ghost_mode then return end
    if inst._lunarfire_pulse_task then return end -- 正在喷射中

    if inst._lunarfire_equipped_lighter then
        RestoreWeaponAfterLunarFire(inst)
    end

    if inst._lunarfire_cd and GetTime() < inst._lunarfire_cd then return end

    local combat = inst.components.combat
    local target = combat and combat.target
    if not target or not target:IsValid() then return end
    if target.components.health and target.components.health:IsDead() then return end
    if IsLunarFireFriend(target) then return end
    if inst.sg and inst.sg:HasStateTag("busy") then return end

    local trigger = NPC_TUNING.LUNARFIRE_TRIGGER_RANGE or 10
    if inst:GetDistanceSqToInst(target) > trigger * trigger then return end

    if not FindLighter(inst) then return end

    CastLunarFire(inst, target)
end


local function HasLighter(inst)
    local inv = inst.components.inventory
    if not inv then return false end
    local equipped = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
    if equipped and equipped.prefab == "lighter" then return true end
    for _, v in pairs(inv.itemslots) do
        if v and v.prefab == "lighter" then return true end
    end
    return false
end

local function CreateLunarBodyFire(inst)
    if inst._lunarfire_body_fx and inst._lunarfire_body_fx:IsValid() then return end
    local fx = SpawnPrefab("bernie_big_fire")
    if not fx then return end
    fx.entity:SetParent(inst.entity)
    fx.Transform:SetPosition(0, 0, 0)

    fx.AnimState:SetBuild(NPC_TUNING.LUNARFIRE_BODY_BUILD or "bernie_fire_fx")
    local mc = NPC_TUNING.LUNARFIRE_BODY_MULTCOLOUR or { 0.6, 0.12, 0.08, 0.3 }
    fx.AnimState:SetMultColour(mc[1], mc[2], mc[3], mc[4] or 0.3)
    local ac = NPC_TUNING.LUNARFIRE_BODY_ADDCOLOUR
    if ac then
        fx.AnimState:SetAddColour(ac[1], ac[2], ac[3], ac[4] or 0)
    end

    local scale = NPC_TUNING.LUNARFIRE_BODY_SCALE or 0.45
    fx.AnimState:SetScale(scale, scale)

    if fx.Light then
        local lc = NPC_TUNING.LUNARFIRE_BODY_LIGHT_COLOUR or { 180 / 255, 25 / 255, 20 / 255 }
        fx.Light:SetColour(lc[1], lc[2], lc[3])
        fx.Light:SetRadius(NPC_TUNING.LUNARFIRE_BODY_LIGHT_RADIUS or 1.5)
        fx.Light:SetIntensity(NPC_TUNING.LUNARFIRE_BODY_LIGHT_INTENSITY or 0.55)
    end
    if fx.SoundEmitter then
        fx.SoundEmitter:KillSound("firelp")
    end
    inst._lunarfire_body_fx = fx
end

local function RemoveLunarBodyFire(inst)
    if inst._lunarfire_body_fx then
        if inst._lunarfire_body_fx:IsValid() then
            inst._lunarfire_body_fx:Remove()
        end
        inst._lunarfire_body_fx = nil
    end
end

local function RefreshLunarBodyFire(inst)
    if not inst:IsValid() then return end
    if inst._is_ghost_mode or not HasLighter(inst) then
        RemoveLunarBodyFire(inst)
    else
        CreateLunarBodyFire(inst)
    end
end

local function LighterMissingCheck(inst)
    if not inst:IsValid() or inst._is_ghost_mode then return end
    if HasLighter(inst) then
        inst._lighter_missing_next = nil
        return
    end
    if not inst.components.talker then return end
    local now = GetTime()
    if not inst._lighter_missing_next then
        inst._lighter_missing_next = now + 20 + math.random() * 15
    elseif now >= inst._lighter_missing_next then
        local line = NPC_SPEECH.GetLine(NPC_SPEECH.LIGHTER_MISSING, inst.npc_character_type)
        if line then
            inst.components.talker:Say(line)
        end
        inst._lighter_missing_next = now + 20 + math.random() * 15
    end
end

local function StartLunarFireTask(inst)
    if inst._lunarfire_check_task then
        inst._lunarfire_check_task:Cancel()
    end
    inst._lunarfire_check_task = inst:DoPeriodicTask(
        NPC_TUNING.LUNARFIRE_CHECK_INTERVAL or 1,
        LunarFirePeriodicCheck)

    if inst._lunarfire_body_task then
        inst._lunarfire_body_task:Cancel()
    end
    inst._lunarfire_body_task = inst:DoPeriodicTask(
        NPC_TUNING.LUNARFIRE_BODY_CHECK or 2,
        function(i)
            RefreshLunarBodyFire(i)
            LighterMissingCheck(i)
        end)
    RefreshLunarBodyFire(inst)
end

local function StopLunarFire(inst)
    if inst._lunarfire_check_task then
        inst._lunarfire_check_task:Cancel()
        inst._lunarfire_check_task = nil
    end
    if inst._lunarfire_pulse_task then
        inst._lunarfire_pulse_task:Cancel()
        inst._lunarfire_pulse_task = nil
    end
    if inst._lunarfire_castend_task then
        inst._lunarfire_castend_task:Cancel()
        inst._lunarfire_castend_task = nil
    end
    if inst._lunarfire_end_task then
        inst._lunarfire_end_task:Cancel()
        inst._lunarfire_end_task = nil
    end
    inst._lunarfire_target = nil
    inst._lunarfire_casting = false
    if inst.SoundEmitter then
        inst.SoundEmitter:KillSound("lunarfire_loop")
    end
    if inst._lunarfire_body_task then
        inst._lunarfire_body_task:Cancel()
        inst._lunarfire_body_task = nil
    end
    RemoveLunarBodyFire(inst)
end

-- ════════════════════════════════════════════════════════════
--  导出模块
-- ════════════════════════════════════════════════════════════

return {
    on_apply = function(inst, stats)
        if inst.components.health then
            inst.components.health.fire_damage_scale = 0

            if not inst._willow_fire_wrapped then
                inst._willow_fire_wrapped = true
                local _orig_DoFireDamage = inst.components.health.DoFireDamage
                inst.components.health.DoFireDamage = function(self, amount, doer, instant)
                    if self:GetFireDamageScale() <= 0 then
                        return
                    end
                    return _orig_DoFireDamage(self, amount, doer, instant)
                end
            end
        end

        inst._bernie_big = nil           -- 当前大伯尼实体引用
        inst._bernie_ground = nil        -- 地面 bernie_inactive 引用
        inst._bernie_deploying = false   -- 正在部署中标记
        inst._bernie_deploy_cd = 0       -- 部署冷却时间戳
        inst._bernie_saved_hp = 1        -- 伯尼保存血量百分比（1=满血）
        inst._combat_version = 0         -- 战斗版本号（防误回收）

        inst:DoTaskInTime(0, function()
            if not inst:IsValid() then return end
            local inactive = FindBernieInInventory(inst)
            if inactive then
                ConfigureNPCBernieInactive(inst, inactive)
            end
        end)

        inst:ListenForEvent("newcombattarget", function(i, data)
            if not i._is_ghost_mode and data and data.target then
                i._combat_version = (i._combat_version or 0) + 1
                DeployBernie(i)
                if i._bernie_big and i._bernie_big:IsValid() and i._bernie_big.components.combat then
                    i._bernie_big.components.combat:SetTarget(data.target)
                end
            end
        end)

        inst:ListenForEvent("attacked", function(i, data)
            if not i._is_ghost_mode and data and data.attacker then
                i._combat_version = (i._combat_version or 0) + 1
                DeployBernie(i)
                if i._bernie_big and i._bernie_big:IsValid() and i._bernie_big.components.combat then
                    local target = (i.components.combat and i.components.combat.target) or data.attacker
                    if target and target:IsValid() and not target:HasTag("player") then
                        i._bernie_big.components.combat:SetTarget(target)
                    end
                end
            end
        end)

        inst:ListenForEvent("onremove", function()
        end)

        StartBernieTasks(inst)

        inst:ListenForEvent("npc_pre_migration", function(i)
            if i._bernie_deploying and i._bernie_deploy_inactive
               and i._bernie_deploy_inactive:IsValid() then
                if not (i._bernie_deploy_inactive.components.inventoryitem
                        and i._bernie_deploy_inactive.components.inventoryitem:IsHeld()) then
                    ConfigureNPCBernieInactive(i, i._bernie_deploy_inactive)
                    EnsureSlotForBernie(i)
                    i.components.inventory:GiveItem(i._bernie_deploy_inactive)
                end
                i._bernie_deploying = false
                i._bernie_deploy_inactive = nil
            end

            if i._bernie_big and i._bernie_big:IsValid() then
                if i._bernie_big.GoInactive then
                    i._bernie_big:GoInactive()
                else
                    i._bernie_big:Remove()
                    i._bernie_big = nil
                end
            end

            if i._bernie_ground and i._bernie_ground:IsValid()
               and not (i._bernie_ground.components.inventoryitem
                        and i._bernie_ground.components.inventoryitem:IsHeld()) then
                ConfigureNPCBernieInactive(i, i._bernie_ground)
                EnsureSlotForBernie(i)
                i.components.inventory:GiveItem(i._bernie_ground)
                i._bernie_ground = nil
            end

            if not FindBernieInInventory(i) then
                local ground = FindBernieOnGround(i, 50)
                if ground then
                    ConfigureNPCBernieInactive(i, ground)
                    EnsureSlotForBernie(i)
                    i.components.inventory:GiveItem(ground)
                end
            end

            if i._bernie_teleport_task then
                i._bernie_teleport_task:Cancel()
                i._bernie_teleport_task = nil
            end
            if i._bernie_recovery_task then
                i._bernie_recovery_task:Cancel()
                i._bernie_recovery_task = nil
            end
            if i._arson_check_task then
                i._arson_check_task:Cancel()
                i._arson_check_task = nil
            end
            i._arson_target = nil
            StopLunarFire(i)
        end)
        
        inst._arson_cd = 0              -- 纵火冷却时间戳
        inst._arson_target = nil        -- 当前纵火目标
        inst._is_willow = true          -- 标记供行为树检查

        inst._arson_check_task = inst:DoPeriodicTask(
            NPC_TUNING.ARSON_CHECK_INTERVAL or 60,
            ArsonPeriodicCheck)

        inst._lunarfire_cd = 0
        StartLunarFireTask(inst)

        if not inst._lunarfire_body_listeners then
            inst._lunarfire_body_listeners = true
            local function refresh_body_fire()
                RefreshLunarBodyFire(inst)
            end
            inst:ListenForEvent("itemget", refresh_body_fire)
            inst:ListenForEvent("itemlose", refresh_body_fire)
            inst:ListenForEvent("dropitem", refresh_body_fire)
            inst:ListenForEvent("equip", refresh_body_fire)
            inst:ListenForEvent("unequip", refresh_body_fire)
        end

        inst:ListenForEvent("do_arson", function(i, data)
            if not data or not data.target or not data.target:IsValid() then return end

            if i.sg and not i.sg:HasStateTag("busy") then
                i.sg:GoToState("give")
            end

            i:DoTaskInTime(13 * FRAMES, function()
                if not i:IsValid() then return end
                ApplyArsonFire(data.target, NPC_TUNING.ARSON_FIRE_DURATION or 3, i)
            end)

            if i.components.talker then
                local line = NPC_SPEECH.GetLine(NPC_SPEECH.ARSON, i.npc_character_type)
                if line then i.components.talker:Say(line) end
            end

            i._arson_cd = GetTime() + (NPC_TUNING.ARSON_COOLDOWN or 60)
        end)

        if not inst._willow_remove_listener then
            inst._willow_remove_listener = true
            inst:ListenForEvent("onremove", function()
                if inst._bernie_big and inst._bernie_big:IsValid() then
                    inst._bernie_big:Remove()
                end
                inst._bernie_big = nil
                inst._bernie_ground = nil
                if inst._arson_check_task then
                    inst._arson_check_task:Cancel()
                    inst._arson_check_task = nil
                end
                inst._arson_target = nil
                StopLunarFire(inst)
            end)
        end
    end,

    on_death = function(inst)
        if inst._bernie_big and inst._bernie_big:IsValid() then
            if inst._bernie_big.sg then
                inst._bernie_big.sg:GoToState("deactivate")
            elseif inst._bernie_big.GoInactive then
                inst._bernie_big:GoInactive()
            end
        end

        if inst._bernie_teleport_task then
            inst._bernie_teleport_task:Cancel()
            inst._bernie_teleport_task = nil
        end
        if inst._bernie_recovery_task then
            inst._bernie_recovery_task:Cancel()
            inst._bernie_recovery_task = nil
        end

        if inst._arson_check_task then
            inst._arson_check_task:Cancel()
            inst._arson_check_task = nil
        end
        inst._arson_target = nil

        RestoreWeaponAfterLunarFire(inst)

        StopLunarFire(inst)

        return false  -- 继续执行默认幽灵模式
    end,

    on_save = function(inst, data)
        if inst._bernie_big and inst._bernie_big:IsValid() then
            data.bernie_state = "big"
            if inst._bernie_big.components.health then
                data.bernie_big_hp = inst._bernie_big.components.health:GetPercent()
            end
        elseif inst._bernie_deploying and inst._bernie_deploy_inactive
               and inst._bernie_deploy_inactive:IsValid()
               and not (inst._bernie_deploy_inactive.components.inventoryitem
                   and inst._bernie_deploy_inactive.components.inventoryitem:IsHeld()) then
            data.bernie_state = "ground"
            local gx, gy, gz = inst._bernie_deploy_inactive.Transform:GetWorldPosition()
            data.bernie_ground_pos = { x = gx, z = gz }
        elseif inst._bernie_ground and inst._bernie_ground:IsValid()
               and not inst._bernie_ground.components.inventoryitem:IsHeld() then
            data.bernie_state = "ground"
            local gx, gy, gz = inst._bernie_ground.Transform:GetWorldPosition()
            data.bernie_ground_pos = { x = gx, z = gz }
        else
            data.bernie_state = "inventory"
        end
        if inst._bernie_deploy_cd and inst._bernie_deploy_cd > GetTime() then
            data.bernie_cd_remaining = inst._bernie_deploy_cd - GetTime()
        end
        if inst._bernie_saved_hp then
            data.bernie_saved_hp = inst._bernie_saved_hp
        end
        if inst._arson_cd and inst._arson_cd > GetTime() then
            data.arson_cd_remaining = inst._arson_cd - GetTime()
        end
        if inst._lunarfire_cd and inst._lunarfire_cd > GetTime() then
            data.lunarfire_cd_remaining = inst._lunarfire_cd - GetTime()
        end
    end,

    restart_bernie_tasks = function(inst)
        StartBernieTasks(inst)
        if not inst._arson_check_task then
            inst._arson_check_task = inst:DoPeriodicTask(
                NPC_TUNING.ARSON_CHECK_INTERVAL or 60,
                ArsonPeriodicCheck)
        end
        StartLunarFireTask(inst)
    end,

    on_load = function(inst, data)
        if not data then return end

        if data.bernie_cd_remaining and data.bernie_cd_remaining > 0 then
            inst._bernie_deploy_cd = GetTime() + data.bernie_cd_remaining
        end
        if data.bernie_saved_hp then
            inst._bernie_saved_hp = data.bernie_saved_hp
        end

        if data.arson_cd_remaining and data.arson_cd_remaining > 0 then
            inst._arson_cd = GetTime() + data.arson_cd_remaining
        end

        if data.lunarfire_cd_remaining and data.lunarfire_cd_remaining > 0 then
            inst._lunarfire_cd = GetTime() + data.lunarfire_cd_remaining
        end

        inst:DoTaskInTime(0.5, RefreshLunarBodyFire)

        if data.bernie_state == "big" then
            inst:DoTaskInTime(1, function()
                if not inst:IsValid() or inst._is_ghost_mode then return end
                local inv_bernie = FindBernieInInventory(inst)
                if inv_bernie then
                    inst.components.inventory:RemoveItem(inv_bernie)
                    inv_bernie:Remove()
                end

                local x, y, z = inst.Transform:GetWorldPosition()
                local big = SpawnPrefab("bernie_big")
                if big then
                    big.Transform:SetPosition(x + 1, y, z + 1)
                    ConfigureNPCBernieBig(inst, big)
                    if data.bernie_big_hp and big.components.health then
                        big.components.health:SetPercent(data.bernie_big_hp)
                    end
                end
            end)

        elseif data.bernie_state == "ground" then
            inst:DoTaskInTime(2, function()
                if not inst:IsValid() then return end
                local ground = nil
                if data.bernie_ground_pos then
                    ground = FindAnyBernieOnGround(
                        data.bernie_ground_pos.x, 0, data.bernie_ground_pos.z, 10)
                end
                if not ground then
                    local x, y, z = inst.Transform:GetWorldPosition()
                    ground = FindAnyBernieOnGround(x, y, z, 50)
                end
                if ground then
                    ConfigureNPCBernieInactive(inst, ground)
                    local gx, gy, gz = ground.Transform:GetWorldPosition()
                    local fx = SpawnPrefab("small_puff")
                    if fx then
                        fx.Transform:SetPosition(gx, gy, gz)
                    end
                    if inst.components.inventory then
                        EnsureSlotForBernie(inst)
                        inst.components.inventory:GiveItem(ground)
                    end
                    inst._bernie_ground = nil
                end
            end)

        else 
            inst:DoTaskInTime(0, function()
                if not inst:IsValid() then return end
                local inactive = FindBernieInInventory(inst)
                if inactive then
                    ConfigureNPCBernieInactive(inst, inactive)
                else
                    local x, y, z = inst.Transform:GetWorldPosition()
                    local ground = FindAnyBernieOnGround(x, y, z, 50)
                    if ground then
                        ConfigureNPCBernieInactive(inst, ground)
                        local gx, gy, gz = ground.Transform:GetWorldPosition()
                        local fx = SpawnPrefab("small_puff")
                        if fx then
                            fx.Transform:SetPosition(gx, gy, gz)
                        end
                        if inst.components.inventory then
                            EnsureSlotForBernie(inst)
                            inst.components.inventory:GiveItem(ground)
                        end
                    end
                end
            end)
        end
    end,
}
