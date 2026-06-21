local brain = require "brains/wiltonmod_pet_brain"

local SetPetScarecrow, UpdatePetInventoryIcon

local assets =
{
    Asset("ANIM", "anim/wiltonmod.zip"),
    Asset("ANIM", "anim/wilton_scarecrow.zip"),
    Asset("ANIM", "anim/wilton_scarecrow1.zip"),
    Asset("ATLAS", "images/inventoryimages/wiltonmod_pet.xml"),
    Asset("ATLAS", "images/inventoryimages/skeleton_scarecrow_icon.xml"),
    Asset("ATLAS", "images/inventoryimages/witherin_spirit_skeleton_icon.xml"),
    Asset("ATLAS", "images/inventoryimages/witherin_spirit_skeleton_scarecrow_icon.xml"),
}

local function UpdatePetInventoryIcon(inst)
    if inst.components == nil or inst.components.inventoryitem == nil then
        return
    end

    local imagename = "wiltonmod_pet"
    local atlasname = "images/inventoryimages/wiltonmod_pet.xml"

    if inst.fy_charcoal and inst.pet_isscarecrow then
        imagename = "witherin_spirit_skeleton_scarecrow_icon"
        atlasname = "images/inventoryimages/witherin_spirit_skeleton_scarecrow_icon.xml"
    elseif inst.fy_charcoal then
        imagename = "witherin_spirit_skeleton_icon"
        atlasname = "images/inventoryimages/witherin_spirit_skeleton_icon.xml"
    elseif inst.pet_isscarecrow then
        imagename = "skeleton_scarecrow_icon"
        atlasname = "images/inventoryimages/skeleton_scarecrow_icon.xml"
    end

    local invitem = inst.components.inventoryitem
    if invitem.imagename ~= imagename or invitem.atlasname ~= atlasname then
        invitem.imagename = imagename
        invitem.atlasname = atlasname
    end
end

-- 结构目标过滤：默认不让骷髅把蜂巢/蜘蛛巢当作攻击目标，除非威尔顿最近主动攻击过该结构。
local function Wilton_IsHiveOrSpiderdenTarget(target)
    return target ~= nil
        and (target:HasTag("beehive") or target:HasTag("spiderden"))
end

local function Wilton_CanPetAttackStructure(inst, target)
    -- 非蜂巢/蜘蛛巢一律放行，保持原有攻击行为不变。
    if not Wilton_IsHiveOrSpiderdenTarget(target) then
        return true
    end
    -- 只有威尔顿的骷髅宠物才应用该规则，其它角色的随从不会额外放开这些结构。
    if inst == nil or inst.components == nil or inst.components.follower == nil then
        return false
    end
    local leader = inst.components.follower:GetLeader()
    if leader == nil or not leader:IsValid() or leader.prefab ~= "wiltonmod" then
        return false
    end
    if target.components == nil or target.components.combat == nil then
        return false
    end
    -- 仅当结构最近一次的 lastattacker 是这位威尔顿时，视为“主动攻击过”的目标，允许骷髅接手攻击。
    return target.components.combat.lastattacker == leader
end

local function retargetfn(inst)
    -- 待机指令：不主动寻找任何攻击目标
    if inst.command_state == "stop" then
        return nil
    end

    local leader = inst.components.follower:GetLeader()
    return leader ~= nil
        and FindEntity(
            leader,
            12,
            function(guy)
                if guy == inst then
                    return false
                end
                if not (guy.components ~= nil and guy.components.combat ~= nil) then
                    return false
                end
                if not inst.components.combat:CanTarget(guy) then
                    return false
                end
                -- 战斗指令：更积极攻击附近非友军单位（排除玩家与同伴）
                if inst.command_state == "fight" then
                    return Wilton_CanPetAttackStructure(inst, guy)
                        and not guy:HasTag("player")
                        and not guy:HasTag("companion")
                        and not guy:HasTag("wiltonmod_pet")
                end
                -- 其它状态维持原有：仅保护领主或自卫
                return guy.components.combat:TargetIs(leader)
                    or guy.components.combat:TargetIs(inst)
            end,
            { "_combat" }, -- see entityreplica.lua
            { "playerghost", "INLIMBO", "wiltonmod_pet" }
        )
        or nil
end

local function keeptargetfn(inst, target)
    return inst.components.follower:IsNearLeader(16)
        and inst.components.combat:CanTarget(target)
        and target.components.minigame_participator == nil
end

local function OnAttacked(inst, data)
    inst:ClearBufferedAction()

    if data and data.attacker then
        -- 被威尔顿攻击时仍然执行原有掉落逻辑，不受指挥状态影响
        if data.attacker:HasTag("wiltonmod") then
            inst.components.inventory:DropEverything()
            return
        end

        -- 待机指令下不进行自动反击，也不联动其它骷髅
        if inst.command_state == "stop" then
            return
        end

        inst.components.combat:SetTarget(data.attacker)
        inst.components.combat:ShareTarget(data.attacker, 30, function(dude)
            return dude:HasTag("wiltonmod_pet") --and dude.components.follower.leader and inst.components.follower.leader
            --and dude.components.follower.leader == inst.components.follower.leader
            and not dude:HasTag("INLIMBO")
            end, 10)                   
    end
end

local function SetPetScarecrow(inst, enable)
    inst.pet_isscarecrow = enable and true or false
    if inst.pet_isscarecrow then
        if inst.fy_charcoal then
            inst.AnimState:SetBuild("wilton_scarecrow1")
        else
            inst.AnimState:SetBuild("wilton_scarecrow")
        end
    else
        if inst.fy_charcoal then
            inst.AnimState:SetBuild("wiltonmod_skin1")
        else
            inst.AnimState:SetBuild("wiltonmod")
        end
    end

    UpdatePetInventoryIcon(inst)
end

local function SetFossed(inst)
    inst.fy_charcoal = true
    print"fy_charcoal"
    SetPetScarecrow(inst, inst.pet_isscarecrow)
    inst.components.health.fire_damage_scale = 0
    --inst:RemoveComponent("trader")
    --[[[
    if inst.components.burnable then
        inst:RemoveComponent("burnable")
    end
    ]]        
end

local function removeItem(item,num)
    if item.components.stackable then
        item.components.stackable:Get(num):Remove()
    else
        item:Remove()
    end
end

local function ShouldAcceptItem(inst, item)
    if item.prefab == "fossil_piece" and item and inst.fossed == false and not inst:HasTag("INLIMBO") then 
        return true
    end 

    if item.components.equippable ~= nil and item.components.equippable.restrictedtag == nil --and item.components.container == nil 
    and not inst:HasTag("INLIMBO") then
        return true
    end

    return false
end

local function OnGetItemFromPlayer(inst, giver, item)
    if item.components.equippable ~= nil then --and item.components.equippable.equipslot == EQUIPSLOTS.HEAD
        local current = inst.components.inventory:GetEquippedItem(item.components.equippable.equipslot)
        if current ~= nil then
            inst.components.inventory:DropItem(current, true)
        end

        inst.brain:Stop()
        inst.brain:Start()

        --inst.tree_target = nil
        inst.components.inventory:Equip(item)

    elseif item.prefab == "fossil_piece" and inst.fossed == false then
        inst.fossed = true
        --removeItem(item,1)
        SetFossed(inst)
    end
end
   
local function HasSkill(inst, name)
    return inst.components.skilltreeupdater and inst.components.skilltreeupdater:IsActivated(name)
end

-- 亡灵巫术 / 灵魂帷幕相关常量：统一控制骷髅兵护盾与回复节奏。
local SKELETON_SHIELD_COOLDOWN = 10       -- 护盾冷却时间（秒），与需求“每10秒一次”保持一致
local SKELETON_REGEN_INTERVAL  = 5        -- 被动回复周期（秒）
local SKELETON_REGEN_AMOUNT    = 5        -- 每次被动回复的生命值

-- 统一判定：威尔顿是否佩戴对应装备。
-- 这里直接通过装备栏检查，无需依赖额外状态标记，保证多人游戏下的可靠性。
local function LeaderHasCrown(leader)
    if leader == nil or leader.components == nil or leader.components.inventory == nil then
        return false
    end

    local hat = leader.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
    return hat ~= nil and hat.prefab == "wiltonmod_hat"
end

local function LeaderHasSoulVeil(leader)
    if leader == nil or leader.components == nil or leader.components.inventory == nil then
        return false
    end

    local body = leader.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
    return body ~= nil and body.prefab == "wiltonmod_armor"
end

-- 灵魂帷幕3级：骷髅兵每5秒回复固定生命值。
-- 为避免在无领主或领主未点技能时产生多余计算，这里每次执行时都会检查当前领主与技能状态。
local function TryHealFromSoulVeil(inst)
    if inst.components == nil or inst.components.health == nil then
        return
    end

    if inst.components.health:IsDead() or inst:HasTag("INLIMBO") then
        return
    end

    local leader = inst.components.follower ~= nil and inst.components.follower:GetLeader() or nil
    if leader ~= nil and leader:IsValid() and leader.prefab == "wiltonmod"
        and HasSkill(leader, "wiltonmod_skill2_17")
        and LeaderHasSoulVeil(leader) then
        local health = inst.components.health
        local old_percent = health:GetPercent()

        health:DoDelta(SKELETON_REGEN_AMOUNT, false, "wilton_soulveil")

        if health:GetPercent() > old_percent then
            local fx = SpawnPrefab("abigail_shadow_buff_fx")
            if fx ~= nil then
                inst:AddChild(fx)
            end
        end
    end
end

local function CanOnWater(inst)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.GIANTS)
end

local function CanNotOnWater(inst)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.GIANTS)
end

local function CheckLeaderBuff(inst)
    local leader = inst.components.follower:GetLeader()
    if leader and leader:IsValid() and leader:HasTag("wiltonmod") then
        if HasSkill(leader, "wiltonmod_skill1_1") and not HasSkill(leader, "wiltonmod_skill1_2") then
            inst.components.locomotor:SetExternalSpeedMultiplier(inst, "wiltonmod_skilltree", 1.1)
        end    

        if HasSkill(leader, "wiltonmod_skill1_2") then
            inst.components.locomotor:SetExternalSpeedMultiplier(inst, "wiltonmod_skilltree", 1.25) 
        end    

        if HasSkill(leader, "wiltonmod_skill1_3") then
            CanOnWater(inst)
            inst.components.locomotor:SetExternalSpeedMultiplier(inst, "wiltonmod_skilltree", 1.25)
        else
            CanNotOnWater(inst)
        end                

        if not HasSkill(leader, "wiltonmod_skill1_1") and not HasSkill(leader, "wiltonmod_skill1_2") and not HasSkill(leader, "wiltonmod_skill1_3") then
            inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "wiltonmod_skilltree")                  
        end

        if HasSkill(leader, "wiltonmod_skill1_7") then
            inst.components.health:SetAbsorptionAmount(0.4)
        else
            inst.components.health:SetAbsorptionAmount(0)        
        end 

        -- 骷髅巫术3级：为骷髅兵设置单次受伤上限 10 点，仅在威尔顿佩戴无名王冠时生效。
        if HasSkill(leader, "wiltonmod_skill2_14") and LeaderHasCrown(leader) then
            if inst.components.health ~= nil then
                inst.components.health:SetMaxDamageTakenPerHit(10)
            end
        else
            if inst.components.health ~= nil then
                inst.components.health:SetMaxDamageTakenPerHit(nil)
            end
        end
    else
        -- 失去威尔顿领主时，移除由骷髅巫术3级设置的受伤上限。
        if inst.components.health ~= nil then
            inst.components.health:SetMaxDamageTakenPerHit(nil)
        end
    end    
end

local function TryDoWorkCommand(inst)
    if inst == nil or inst.components == nil or inst:HasTag("INLIMBO") then
        return
    end

    if inst.command_state ~= "work" then
        return
    end

    if inst.sg ~= nil and inst.sg:HasStateTag("busy") then
        return
    end

    if inst.components.combat ~= nil and inst.components.combat:HasTarget() then
        return
    end

    if inst:GetBufferedAction() ~= nil then
        return
    end

    local tool = inst.components.inventory ~= nil and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
    if tool == nil then
        return
    end

    local action = nil
    if tool:HasTag("CHOP_tool") then
        action = ACTIONS.CHOP
    elseif tool:HasTag("MINE_tool") then
        action = ACTIONS.MINE
    elseif tool:HasTag("DIG_tool") then
        action = ACTIONS.DIG
    end

    if action == nil then
        return
    end

    local target = inst.tree_target
    if target ~= nil and (not target:IsValid()) then
        target = nil
        inst.tree_target = nil
    end

    if target ~= nil and target.components ~= nil and target.components.workable ~= nil then
        local wa = target.components.workable:GetWorkAction()
        if wa ~= action or (not target.components.workable:CanBeWorked()) then
            target = nil
        end
    else
        target = nil
    end

    if target == nil then
        if action == ACTIONS.CHOP then
            target = FindEntity(inst, 15, nil, { "CHOP_workable" }, { "INLIMBO" })
        elseif action == ACTIONS.MINE then
            target = FindEntity(inst, 15, nil, { "MINE_workable" }, { "INLIMBO" })
        elseif action == ACTIONS.DIG then
            target = FindEntity(inst, 15, function(ent)
                return ent ~= nil and (ent:HasTag("DIG_workable") or ent:HasTag("stump"))
            end, nil, { "INLIMBO" })
        end
    end

    if target ~= nil and target:IsValid() then
        inst.tree_target = target
        inst:PushBufferedAction(BufferedAction(inst, target, action))
        print("[WILTON_PET_WORK] push work action:", inst.GUID, action.id, target.prefab)
    end
end

local function SetCommandState(inst, state)
    -- 指挥状态：nil 表示默认逻辑（跟随+工作+战斗），其它值由法杖命令控制
    inst.command_state = state
end

local function StopFollow(inst)
    local leader = inst.components.follower:GetLeader()
    if leader and leader:IsValid() and leader.components.leader then
        leader.components.leader:RemoveFollower(inst)
    end    
end

local function onload(inst,data)
    if data then
        if data.stop then
            inst:RemoveTag("canbecontroled")
        end

        if data.fossed then
            inst.fossed = data.fossed

            if inst.fossed then
                SetFossed(inst)
            end    
        end
        if data.fy_charcoal then
            inst.fy_charcoal = data.fy_charcoal
        end
        if data.pet_isscarecrow ~= nil then
            inst.pet_isscarecrow = data.pet_isscarecrow
        end
        if data.command_state ~= nil then
            inst.command_state = data.command_state
        end
    end    

    if inst.pet_isscarecrow then
        SetPetScarecrow(inst, true)
    end
end

local function onsave(inst,data)
    data.stop = not inst:HasTag("canbecontroled")
    data.fossed = inst.fossed
    data.fy_charcoal = inst.fy_charcoal
    data.pet_isscarecrow = inst.pet_isscarecrow
    data.command_state = inst.command_state
end

local function OnEquipChanged(inst)
    inst:DoTaskInTime(0, function()
        local self = inst.components.inventory
        for k = 1, self.maxslots do
            local v = self.itemslots[k]
            if v ~= nil then
                if v:HasTag("wilton_temp_gear") then
                    v:Remove()
                else
                    self:DropItem(v, true, true)
                end
            end
        end
    end)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    --inst:AddTag("character")    
    inst:AddTag("notraptrigger")
    inst:AddTag("scarytoprey")
    inst:AddTag("companion")
    inst:AddTag("summonedbyplayer")
    inst:AddTag("nosteal")

    inst:AddTag("whip_crack_imune")

    inst:AddTag("wiltonmod_pet")
    inst:AddTag("wiltonmod_item")
    inst:AddTag("stronggrip")
    inst:AddTag("player_damagescale")

    MakeGhostPhysics(inst, 1, 0.5)
    --MakeCharacterPhysics(inst, 75, .5)
    inst.DynamicShadow:SetSize(1.3, .6)

    inst.Transform:SetFourFaced(inst)

    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("wiltonmod")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:Hide("ARM_carry")
    inst.AnimState:Show("ARM_normal")
    inst.AnimState:Show("HEAD")
    inst.AnimState:Hide("HEAD_HAT")

    inst:AddComponent("talker")
    inst.components.talker.fontsize = 35
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.offset = Vector3(0, -400, 0)
    inst.components.talker:StopIgnoringAll()

    inst.entity:SetPristine()
    inst.fy_charcoal = false
    inst.pet_isscarecrow = false
    if not TheWorld.ismastersim then
        return inst
    end

    -- 默认不设置指挥状态，保持旧版本行为，只有通过法杖下达指令后才切换
    inst.command_state = nil

    inst:AddComponent("inspectable")
    inst:AddComponent("knownlocations")

    inst:AddComponent("locomotor")
    inst.components.locomotor:SetSlowMultiplier( 0.75 )
    inst.components.locomotor.pathcaps = { ignorecreep = true }
    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED * TUNING.WILTON_SKELETON_SPEED

    inst.fossed = false

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.WILTONMOD_HEALTH)
    --inst.components.health.canheal = false
    inst.components.health.canmurder = false

    -- 配置项：骷髅兵无敌开关，开启后直接将生命组件设为无敌，屏蔽一切伤害结算。
    if TUNING.WILTON_SKELETON_INVINCIBLE then
        inst.components.health:SetInvincible(true)
    end

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(10)
    -- 使用与威尔顿本体一致的攻击倍率配置，保证配置项对随从同样生效
    if type(TUNING.WILTON_ATTACK_MULT) == "number" then
        inst.components.combat.damagemultiplier = TUNING.WILTON_ATTACK_MULT
    end
    inst.components.combat:SetAttackPeriod(TUNING.WILSON_ATTACK_PERIOD)
    inst.components.combat:SetRange(TUNING.DEFAULT_ATTACK_RANGE)
    inst.components.combat.hiteffectsymbol = "torso"
    inst.components.combat:SetRetargetFunction(2, retargetfn)
    inst.components.combat:SetKeepTargetFunction(keeptargetfn)        
    local OldIsValidTarget = inst.components.combat.IsValidTarget
    inst.components.combat.IsValidTarget = function(self, target, ...)
        local owner = inst.components.follower.leader
        if target and target ~= inst and owner and owner.components.combat:IsValidTarget(target) and not inst:HasTag("INLIMBO") then
            return true
        end    

        return OldIsValidTarget(self, target, ...) 
    end

    local OldCanTarget = inst.components.combat.CanTarget
    inst.components.combat.CanTarget = function(self, target, ...)
        local owner = inst.components.follower.leader
        if target and target ~= inst and owner and owner.components.combat:CanTarget(target) and not inst:HasTag("INLIMBO") then
            return true
        end    

        return OldCanTarget(self, target, ...) 
    end

    local OldSetTarget = inst.components.combat.SetTarget
    inst.components.combat.SetTarget = function(self, target, ...)
        local owner = inst.components.follower.leader
        if target and target ~= inst and owner and owner.components.combat.target
        and target ~= owner.components.combat.target and not inst:HasTag("INLIMBO") then
            target = owner.components.combat.targe
        end        

        -- 结构体（蜂巢/蜘蛛巢）目标：默认不接受为骷髅当前攻击目标，除非威尔顿最近主动攻击过该结构。
        if target ~= nil and not Wilton_CanPetAttackStructure(inst, target) then
            target = nil
        end

        return OldSetTarget(self, target, ...) 
    end

    -- 亡灵巫术2级：为骷髅兵提供“物理免疫护盾”，每10秒至多触发一次。
    -- 这里通过包裹 Combat:GetAttacked 在伤害结算前将本次伤害置零，并播放与骨甲相同的护盾特效。
    local OldGetAttacked = inst.components.combat.GetAttacked
    inst.components.combat.GetAttacked = function(self, attacker, damage, weapon, stimuli, spdamage, ...)
        -- 仅在服务端参与结算，且当前存在威尔顿领主并习得亡灵巫术2级时启用护盾逻辑。
        local leader = inst.components.follower ~= nil and inst.components.follower:GetLeader() or nil
        if leader ~= nil and leader:IsValid() and leader.prefab == "wiltonmod"
            and HasSkill(leader, "wiltonmod_skill2_16")
            and LeaderHasSoulVeil(leader) then
            if damage ~= nil and damage > 0 and not inst:HasTag("INLIMBO") and inst.components.health ~= nil and not inst.components.health:IsDead() then
                local t = GetTime()
                if inst._wilton_last_shield_time == nil or (t - inst._wilton_last_shield_time) >= SKELETON_SHIELD_COOLDOWN then
                    inst._wilton_last_shield_time = t

                    -- 复用骨甲的阴影护盾特效：shadow_shield1~3 为三种变化，这里简单随机一种即可。
                    local fx_index = math.random(1, 3)
                    local fx = SpawnPrefab("shadow_shield"..tostring(fx_index))
                    if fx ~= nil and fx.entity ~= nil then
                        fx.entity:SetParent(inst.entity)
                    end

                    -- 本次物理伤害被完全吸收，后续护甲与生命结算看到的是0伤害。
                    damage = 0
                end
            end
        end

        return OldGetAttacked(self, attacker, damage, weapon, stimuli, spdamage, ...)
    end

    inst:ListenForEvent("attacked", OnAttacked)

    inst:AddComponent("lootdropper")
    function inst.components.lootdropper:GenerateLoot()
        if inst.pet_isscarecrow then
            return {"scarecrow2"}
        end
        return {"skeleton"}
    end

    local _OldSpawnLootPrefab = inst.components.lootdropper.SpawnLootPrefab
    function inst.components.lootdropper:SpawnLootPrefab(prefab, ...)
        local loot = _OldSpawnLootPrefab(self, prefab, ...)
        if loot and prefab == "scarecrow2" and inst.pet_isscarecrow then
            loot:AddTag("wiltonmod_scarecrow")
            -- 记录由骷髅宠物死亡生成的特殊稻草人，用于骨心复活与存档还原。
            loot.wilton_bone_revive = true
            if loot.components.lootdropper ~= nil then
                loot.components.lootdropper:SetChanceLootTable('skeleton_cg')
            end
        end
        return loot
    end

    inst:AddComponent("follower") 
    inst.components.follower:KeepLeaderOnAttacked()
    inst.components.follower.keepdeadleader = true
    inst.components.follower.keepleaderduringminigame = true 

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.nobounce = true
    inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.canaccepttarget = false 
    --inst.components.inventoryitem.cangoincontainer = false
    --inst.components.inventoryitem.canonlygoinpocket = true
    inst.components.inventoryitem.imagename = "wiltonmod_pet"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/wiltonmod_pet.xml" 

    inst:AddComponent("inventory")
    inst.components.inventory.IsInsulated = function(self, ...)
        return true
    end

    inst:ListenForEvent("unequip", OnEquipChanged)

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer

    local OldAcceptGift = inst.components.trader.AcceptGift 
    inst.components.trader.AcceptGift = function(self, giver, item, count, ...) 
        if item and item.prefab == "fossil_piece" then
            self.acceptstacks = false
            self.deleteitemonaccept = true
        else
            self.acceptstacks = true
            self.deleteitemonaccept = false
        end    
        return OldAcceptGift(self, giver, item, count, ...) 
    end


    MakeMediumBurnableCharacter(inst, "torso")
    inst.components.burnable:SetBurnTime(TUNING.PLAYER_BURN_TIME)
    inst.components.burnable.nocharring = true

    MakeLargeFreezableCharacter(inst, "torso")
    inst.components.freezable:SetResistance(4)
    inst.components.freezable:SetDefaultWearOffTime(TUNING.PLAYER_FREEZE_WEAR_OFF_TIME)

    inst:DoPeriodicTask(0.5, CheckLeaderBuff)
    inst:DoPeriodicTask(0.5, TryDoWorkCommand)
    -- 灵魂帷幕3级：骷髅兵每5秒被动回复生命，由 TryHealFromSoulVeil 根据当前领主与技能状态决定是否生效。
    inst:DoPeriodicTask(SKELETON_REGEN_INTERVAL, TryHealFromSoulVeil)

    inst:SetBrain(brain)
    inst:SetStateGraph("SGwiltonmod_pet") 

    inst:ListenForEvent("enterlimbo", function(inst)
        if inst.brain then
            inst.brain:Stop()
        end

        if inst.sg then
            inst.sg:GoToState("idle")
            inst.sg:Stop()
        end  
    end)    

    inst:ListenForEvent("exitlimbo", function(inst)
        if inst.brain then        
            inst.brain:Start()
        end

        if inst.sg then
            inst.sg:Start() 
            inst.sg:GoToState("idle")
        end
    end)

    inst.SetPetScarecrow = SetPetScarecrow
    inst.StopFollow = StopFollow
    inst.SetCommandState = SetCommandState

    inst.OnSave = onsave
    inst.OnLoad = onload
    inst:ListenForEvent("death", function(inst, data)
        -- 销毁所有临时军械库装备，避免掉落被玩家拾取
        if inst.components.inventory ~= nil then
            for k = 1, inst.components.inventory.maxslots do
                local v = inst.components.inventory.itemslots[k]
                if v ~= nil and v:HasTag("wilton_temp_gear") then
                    v:Remove()
                end
            end
            for _, v in pairs(inst.components.inventory.equipslots) do
                if v ~= nil and v:HasTag("wilton_temp_gear") then
                    v:Remove()
                end
            end
        end

        if inst.fy_charcoal then
            SpawnPrefab("charcoal").Transform:SetPosition(inst.Transform:GetWorldPosition())
        end
    end)

    return inst
end

return Prefab("wiltonmod_pet", fn, assets)
